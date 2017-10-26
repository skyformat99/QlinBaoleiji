#!/usr/bin/perl
use warnings;
use strict;
use DBI;
use DBD::mysql;
use Expect;
use File::Basename;
use File::HomeDir;
use Fcntl;
use Crypt::CBC;
use MIME::Base64;

our $fd_lock;
our $lock_file = "/tmp/.backup_passwd_lock";
sysopen($fd_lock, $lock_file, O_RDWR|O_CREAT|O_EXCL) or die "another instance running";

$SIG{ALRM}=sub{ die "alarm timeout\n" };
alarm 7200;

our $local_ip = "103.30.149.78";

our $time_now_utc = time;
my($min,$hour,$mday,$mon,$year) = (localtime $time_now_utc)[1..5];
($min,$hour,$mday,$mon,$year) = (sprintf("%02d", $min),sprintf("%02d", $hour),sprintf("%02d", $mday),sprintf("%02d", $mon + 1),$year+1900);
our $time_now_str = "$year$mon$mday$hour$min"."00";
our $date_today = "$year-$mon-$mday";

if(-e "/tmp/backup_passwd_dir")
{
    `rm -fr /tmp/backup_passwd_dir`;
}

mkdir "/tmp/backup_passwd_dir";

our @backup_passwd_file;
our @backup_passwd_id;

our($mysql_user,$mysql_passwd) = &get_local_mysql_config();
our $dbh=DBI->connect("DBI:mysql:database=audit_sec;host=localhost;mysql_connect_timeout=5",$mysql_user,$mysql_passwd,{RaiseError=>1});
my $utf8 = $dbh->prepare("set names utf8");
$utf8->execute();
$utf8->finish();

&create_backup_file();

print "backup file num\n";
print scalar @backup_passwd_file,"\n";

my $sqr_select = $dbh->prepare("select ip,port,path,user,udf_decrypt(passwd),protocol from backup_setting where session_flag=2");
$sqr_select->execute();
while(my $ref = $sqr_select->fetchrow_hashref())
{
    my $ip = $ref->{"ip"};
    my $port = $ref->{"port"};
    my $path = $ref->{"path"};
    my $user = $ref->{"user"};
    my $passwd = $ref->{"udf_decrypt(passwd)"};
    my $protocol = $ref->{"protocol"};

    if($protocol =~ /sftp/i)
    {
        my $cmd = "sftp -oPort=$port $user\@$ip";
        &sftp_process($ip,$passwd,$user,$path,$cmd);
    }
    else
    {
        my $cmd = "ftp $ip";
        print $cmd,"\n";
        &ftp_process($ip,$passwd,$user,$path,$cmd);   
    }
}
$sqr_select->finish();

`rm -fr /tmp/backup_passwd_dir`;

foreach my $id(@backup_passwd_id)
{
    my $sqr_update = $dbh->prepare("update passwordkey set backup=1 where id = $id");
    $sqr_update->execute();
    $sqr_update->finish();
}

close $fd_lock;
unlink $lock_file;

sub create_backup_file
{
    my $sqr_select = $dbh->prepare("select id, udf_encrypt(key_str), key_date, zip_file from passwordkey where backup=0 and zip_file is not null and zip_file != ''");
    $sqr_select->execute();
    while(my $ref = $sqr_select->fetchrow_hashref())
    {
        my $id = $ref->{"id"};
        my $encrypt_keystr = $ref->{"udf_encrypt(key_str)"};
        my $key_date = $ref->{"key_date"};
        my $zip_file = $ref->{"zip_file"}.".zip";

        unless(-e $zip_file)
        {
            &log_process(undef,0,"$zip_file dose not exist");
            next;
        }
=pod
        my $passwordkey_file = "/tmp/backup_passwd_dir/passwordkey-$key_date";
        $passwordkey_file  =~ s/:/-/g;
        $passwordkey_file  =~ s/\s+/_/g;

        my $passwordkey_file_zip = "$passwordkey_file.zip";
        $passwordkey_file_zip =~ s/:/-/g;
        $passwordkey_file_zip =~ s/\s+/_/g;

        open(my $fd_fw,">$passwordkey_file");
        print $fd_fw $encrypt_keystr;
        close $fd_fw;

        if(system("zip -qj $passwordkey_file_zip '$passwordkey_file' '$zip_file'") != 0)
        {
            &log_process(undef,0,"zip meet err");
            `rm -fr /tmp/backup_passwd_dir`;
            exit 1;
        }

        unlink $passwordkey_file;
=cut
#        push @backup_passwd_file, $passwordkey_file_zip;
        push @backup_passwd_file, $zip_file;
        push @backup_passwd_id, $id;
    }
    $sqr_select->finish();
}

sub sftp_process
{
    my($ip,$passwd,$user,$path,$cmd) = @_;

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

        my @results = $exp->expect(300,
                [
                qr/password:/i,
                sub {
                my $self = shift ;
                $self->send_slow(0.1,"$passwd\n");
                exp_continue;
                }
                ],

                [
                qr/sftp>/i,
                sub {
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
                        qr/Host key verification failed/i,
                    sub
                    {
                        my $tmp = &rsa_err_process($user,$ip);
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
                        &log_process($ip,0,"passwd err");
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

                if($flag == 0)
                {
                    foreach my $file(@backup_passwd_file)
                    {
                        &sftp_trans($exp,$ip,$path,$file);
                    }
                }
                elsif($flag == 4)
                {
                    if(defined $results[1])
                    {
                        &log_process($ip,0,"$cmd exec error");
                    }
                }

                $exp->close();
    }

    if($count >= 10)
    {
        &log_process($ip,0,"rsa err and fail to fix");
        return;
    }
}

sub sftp_trans
{
    my ($exp,$ip,$path,$file) = @_;
    my $success_flag = 0;
    my $cmd = "put $file $path";
    $exp->send("$cmd\n");
    $exp->expect(2, undef);

    foreach my $line(split /\n/,$exp->before())
    {
        my $percentage;

        if($line =~ /(\d+)%/)
        {
            $percentage = $1;
            $success_flag = 1;
        }

        if(defined $percentage && $percentage == 100)
        {
            $success_flag = 2;
            last;
        }
    }

    if($success_flag == 0)
    {
        &log_process($ip,0,"$cmd exec err in sftp");
    }
    else
    {
        if($success_flag == 2)
        {
            &log_process($ip,1,"sftp success finish $file");
        }
        else
        {
            while(1)
            {
                $exp->expect(1, undef);
                foreach my $line(split /\n/,$exp->before())
                {
                    if($line =~ /100%/)
                    {
                        &log_process($ip,1,"sftp success finish $file");
                        $success_flag = 2;
                        last;
                    }
                }

                if($success_flag == 2)
                {
                    last;
                }
            }
        }
    }
}

sub rsa_err_process
{
    my($user,$ip) = @_;
    my $home = File::HomeDir->users_home($user);
    unless(defined $home)
    {
        &log_process($ip,0,"cant find home dir for user $user");
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

sub ftp_process
{
    print "ftp process begin\n";
    my($ip,$passwd,$user,$path,$cmd) = @_; 
    $path =~ s/\/$//;

    my $exp = Expect->new;
    $exp->log_stdout(0);
    $exp->spawn($cmd);
    $exp->debug(0);

    my $flag = 1;

    my @results = $exp->expect(300,
            [
            qr/Name.*:/i,
            sub {
            print "input name\n";
            my $self = shift ;
            $self->send_slow(0.1,"$user\n");
            exp_continue;
            }
            ],

            [
            qr/Password:/i,
            sub {
            print "input passwd\n";
            my $self = shift ;
            $self->send_slow(0.1,"$passwd\n");
            exp_continue;
            }
            ],

            [
            qr/230 User.*logged in/i,
            sub {
            print "User logged in\n";
            $flag = 0;
            exp_continue;
            }
            ],

            [
            qr/ftp>/i,
            sub {
                if($flag == 0)
                {
                    print "ftp login\n";
                    $flag = 2;
                }
                else
                {
                    print "ftp login fail\n";
                }
            }
            ],
                );

            if($flag == 2)
            {
                my $flag = &ftp_setBinary($exp,$ip);
                if($flag == 0)
                {
                    foreach my $file(@backup_passwd_file)
                    {
                        &ftp_trans($exp,$ip,$path,$file);
                    }
                }
            }
            else
            {
                if(defined $results[1])
                {
                    &log_process($ip,0,"$cmd exec error");
                }
            }
}

sub ftp_setBinary
{
    print "ftp set binary mode\n";
    my($exp,$ip) = @_;
    my $flag = 1;
    my $cmd = "binary";
    $exp->send("$cmd\n");
    $exp->expect(2, undef);
    foreach my $line(split /\n/,$exp->before())
    {
        if($line =~ /200.*set to I/i)
        {
            $flag = 0;
            last;
        }
    }

    if($flag != 0)
    {
        &log_process($ip,0,"ftp set binary mode fail");
        print "ftp set binary mode fail\n";
    }
    else
    {
        print "ftp set binary mode success\n"
    }
    $exp->clear_accum();

    return $flag;
}

sub ftp_trans
{
    my($exp,$ip,$path,$file) = @_;
    print "ftp trans $file begin\n";

    my $flag = 1;
#   $cmd = "put /home/lwm_2014_3_19.tar.gz $path/lwm_2014_3_19.tar.gz";
    my $cmd = "put $file $path/".basename $file;
    $exp->send("$cmd\n");
    $exp->expect(2, undef);

    foreach my $line(split /\n/,$exp->before())
    {
        print $line,"\n";
        if($flag == 0)
        {
            print "in #1 loop\n";
            $flag = 2;
            if($line =~ /Transfer complete/i)
            {
                &log_process($ip,1,"ftp success $file");
            }
            else
            {
                &log_process($ip,0,"ftp fail $file");
            }
            last;
        }

        if($line =~ /Opening BINARY mode data connection/i || $line =~ /Data connection already open/i)
        {
            $flag = 0;
        }
    }
    $exp->clear_accum();

    if($flag == 0)
    {
        while(1)
        {
            print "in #2 loop\n";
            $exp->expect(1, undef);
            foreach my $line(split /\n/,$exp->before())
            {
                print "in #2 inner loop\n";
                print $line,"\n";
                $flag = 2;
                if($line =~ /Transfer complete/i)
                {
                    &log_process($ip,1,"ftp success $file");
                }
                else
                {
                    &log_process($ip,1,"ftp fail $file");
                }
                last;
            }

            if($flag == 2)
            {
                last;
            }
        }
    }
}

sub log_process
{
    my($host,$result,$reason) = @_;

    $reason =~ s/'//g;

    my $cmd;

    if(defined $host)
    {
        $cmd = "insert into backup_passwd_log(datetime,host,result,reason) values('$time_now_str','$host',$result,'$reason')";
    }
    else
    {
        $cmd = "insert into backup_passwd_log(datetime,result,reason) values('$time_now_str',$result,'$reason')";
    }

    my $insert = $dbh->prepare("$cmd");
    $insert->execute();
    $insert->finish();
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
