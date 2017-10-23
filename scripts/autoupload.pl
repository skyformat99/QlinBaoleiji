#!/usr/bin/perl
use warnings;
use strict;
use DBI;
use DBD::mysql;
use Expect;
use File::Basename;
use File::HomeDir;
use Crypt::CBC;
use MIME::Base64;

our($search_id) = @ARGV;

unless(defined $search_id)
{
    print "need an id in autorun_index\n";
    exit 1;
}

our($mysql_user,$mysql_passwd) = &get_local_mysql_config();
my $dbh=DBI->connect("DBI:mysql:database=audit_sec;host=localhost;mysql_connect_timeout=5",$mysql_user,$mysql_passwd,{RaiseError=>1});

my $utf8 = $dbh->prepare("set names utf8");
$utf8->execute();
$utf8->finish();

my $sqr_select = $dbh->prepare("select deviceid,scriptpath,uploadpath from autorun_index where id=$search_id");
$sqr_select->execute();
my $ref_select = $sqr_select->fetchrow_hashref();
my $device_id = $ref_select->{"deviceid"};
my $script_path = $ref_select->{"scriptpath"};
my $upload_path = $ref_select->{"uploadpath"};
$sqr_select->finish();

$sqr_select = $dbh->prepare("select device_ip,login_method,username,port,udf_decrypt(cur_password) from devices where id=$device_id");
$sqr_select->execute();
$ref_select = $sqr_select->fetchrow_hashref();
my $device_ip = $ref_select->{"device_ip"};
my $login_method = $ref_select->{"login_method"};
my $username = $ref_select->{"username"};
my $port = $ref_select->{"port"};
my $passwd = $ref_select->{"udf_decrypt(cur_password)"};
$sqr_select->finish();

unless($login_method == 3)
{
    print "device_id $device_id, device_ip $device_ip not ssh potocal\n";
    exit 1;
}

my $cmd = "scp -P $port -r $upload_path $username\@$device_ip:$script_path;echo \"scp status:\$?\"";
print $cmd,"\n";

my $status = &upload_process($cmd,$device_ip,$username,$passwd);

if($status == 0)
{
    print "scp success\n";
    $status = 1;
}
else
{
    print "scp fail\n";
    $status = 0;
}

my $sqr_update = $dbh->prepare("update autorun_index set status=$status where id=$search_id");
$sqr_update->execute();
$sqr_update->finish();
$dbh->disconnect();

sub upload_process
{
    my($cmd,$device_ip,$username,$passwd) = @_;

    my $result = 1;
    my $count = 0;
    my $flag = 1;

    while($count < 10 && $flag == 1)
    {
        ++$count;
        my $rsa_flag = 0;

        my $exp = Expect->new;
        $exp->log_stdout(0);
        $exp->spawn($cmd);
        $exp->debug(0);

        my @results = $exp->expect(undef,
                [
                qr/scp\s*status:/i,
                sub {
                my $self = shift ;
                $result = (split /\n/,$self->after())[0];
                $result = (split /\s+/, $result)[0];
                $flag = 0;
                }
                ],

                [
                qr/continue connecting.*yes\/no.*/i,
                sub {
                my $self = shift ;
                $self->send_slow(0.1,"yes\n");
                exp_continue;
                }
                ],

                [
                qr/password:/i,
                sub {
                my $self = shift ;
                $self->send_slow(0.1,"$passwd\n");
                exp_continue;
                }
                ],

                    [
                        qr/Host key verification failed/i,
                    sub
                    {
                        my $tmp = &rsa_err_process($username,$device_ip);
                        if($tmp == 0)
                        {
                            $rsa_flag = 1;
                        }
                        else
                        {
                            $rsa_flag = 2;
                        }
                    }
                ],

                    [
                        qr/Permission denied/i,
                    sub
                    {
                        print "$device_ip ssh passwd error\n";
                        $flag = 3;
                    }
                ],
                    );

                if($rsa_flag == 1)
                {
                    $flag = 1;
                }
                elsif($rsa_flag == 2)
                {
                    $flag = 2;
                }
                elsif($rsa_flag == 0 && $flag != 0 && $flag != 3)
                {
                    $flag = 4;
                }

                if($flag == 4 && defined $results[1])
                {
                    print "$device_ip $cmd exec error\n";
                }

                $exp->close();
    }

    if($count >= 10)
    {
        print "$device_ip rsa err and fail to fix\n";
    }

    return $result;
}

sub rsa_err_process
{
    my($user,$ip) = @_;
    my $home = File::HomeDir->users_home($user);
    unless(defined $home)
    {   
        print "$ip cant find home dir for user $user\n";
        return 1;
    }

    my @file_lines;
    $home =~ s/\/$//;
    open(my $fd_fr,"<$home/.ssh/known_hosts");
    foreach my $line(<$fd_fr>)
    {   
        if($line =~ /^$ip/)
        {   
            next;
        }

        push @file_lines,$line;
    }
    close $fd_fr;

    open(my $fd_fw,">$home/.ssh/known_hosts");
    foreach my $line(@file_lines)
    {   
        print $fd_fw $line;
    }
    close $fd_fw;

    return 0;
}

sub get_local_mysql_config
{
    my $tmp_mysql_user = "root";
    my $tmp_mysql_passwd = "";
    open(my $fd_fr, "</opt/freesvr/audit/etc/perl.cnf");
    while(my $line = <$fd_fr>)
    {
        $line =~ s/\s//g;
        my($name, $val) = split /:/, $line;
        if($name eq "mysql_user")
        {
            $tmp_mysql_user = $val;
        }
        elsif($name eq "mysql_passwd")
        {
            $tmp_mysql_passwd = $val;
        }
    }

    my $cipher = Crypt::CBC->new( -key => 'freesvr', -cipher => 'Blowfish', -iv => 'freesvr1', -header => 'none');
    $tmp_mysql_passwd = decode_base64($tmp_mysql_passwd);
    $tmp_mysql_passwd  = $cipher->decrypt($tmp_mysql_passwd);
    close $fd_fr;
    return ($tmp_mysql_user, $tmp_mysql_passwd);
}
