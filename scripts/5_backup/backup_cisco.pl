#!/usr/bin/perl
use warnings;
use strict;
use DBI;
use DBD::mysql;
use File::HomeDir;
use Expect;
use Crypt::CBC;
use MIME::Base64;

our $tftp_root = "/opt/freesvr/tftproot";
$tftp_root =~ s/\/$//;

our $time_now_utc = time;
my($min,$hour,$mday,$mon,$year) = (localtime $time_now_utc)[1..5];
($min,$hour,$mday,$mon,$year) = (sprintf("%02d", $min),sprintf("%02d", $hour),sprintf("%02d", $mday),sprintf("%02d", $mon + 1),$year+1900);
our $time_now_str = "$year$mon$mday$hour$min"."00";
our $date_today = "$year-$mon-$mday";

our $max_process_num = 2;
our $exist_process = 0;
our %device_info;
our @device_arr;

unless(-d "$tftp_root/$date_today")
{
    if(-e "$tftp_root/$date_today")
    {
        unlink "$tftp_root/$date_today";
    }

    my $oldmaskval = umask(0);
    mkdir "$tftp_root/$date_today", 0777;
    umask($oldmaskval);
}

our($mysql_user,$mysql_passwd) = &get_local_mysql_config();
my $dbh=DBI->connect("DBI:mysql:database=audit_sec;host=localhost;mysql_connect_timeout=5",$mysql_user,$mysql_passwd,{RaiseError=>1});
my $utf8 = $dbh->prepare("set names utf8");
$utf8->execute();
$utf8->finish();

#my $sqr_select = $dbh->prepare("select a.id,device_ip,username,udf_decrypt(cur_password) passwd,port,device_type,login_method,`interval`,unix_timestamp(lastruntime) lastruntime,su,name,startup,running from autobackup_index as a join devices as d on a.deviceid=d.id");
my $sqr_select = $dbh->prepare("select b.id,d.device_ip,d.username,udf_decrypt(cur_password) password,port,device_type,login_method,b.interval,unix_timestamp(b.lastruntime) lastruntime,b.su,b.name,b.startup,b.running from autobackup_index_devices a left join autobackup_index b on a.autobackup_id=b.id left join devices d on a.devicesid=d.id");
$sqr_select->execute();
while(my $ref = $sqr_select->fetchrow_hashref())
{
    my $id = $ref->{"id"};
    my $device_ip = $ref->{"device_ip"};
    my $username = $ref->{"username"};
    my $passwd = $ref->{"passwd"};
    my $port = $ref->{"port"};
    my $device_type = $ref->{"device_type"};
    my $login_method = $ref->{"login_method"};
    my $interval = $ref->{"interval"};
    my $lastruntime = $ref->{"lastruntime"};
    my $su = $ref->{"su"};
    my $name = $ref->{"name"};
    my $startup = $ref->{"startup"};
    my $running = $ref->{"running"};

    unless(defined $device_ip)
    {
        next;
    }

    unless(!defined $lastruntime || $time_now_utc-$lastruntime >= $interval*3600*24)
    {
        next;
    }

    my @tmp = ($id,$username,$passwd,$port,$device_type,$login_method,$su,$name,$startup,$running);
    $device_info{$device_ip} = \@tmp;
}
$sqr_select->finish();
$dbh->disconnect();

if(scalar keys %device_info == 0) {exit;}
@device_arr = keys %device_info;
if($max_process_num > scalar @device_arr){$max_process_num = scalar @device_arr;}

while(1)
{
    if($exist_process < $max_process_num)
    {
        &fork_process();
    }
    else
    {
        while(wait())
        {
            --$exist_process;
            &fork_process();
            if($exist_process == 0)
            {
                exit;
            }
        }
    }
}

sub fork_process
{
    my $device_ip = shift @device_arr;
    unless(defined $device_ip){return;}
    my $pid = fork();
    if (!defined($pid))
    {
        print "Error in fork: $!";
        exit 1;
    }

    if ($pid == 0)
    {
        my @temp_ips = keys %device_info;
        foreach my $key(@temp_ips)
        {
            if($device_ip ne $key)
            {
                delete $device_info{$key};
            }
        }

        my $dbh=DBI->connect("DBI:mysql:database=audit_sec;host=localhost;mysql_connect_timeout=5",$mysql_user,$mysql_passwd,{RaiseError=>1});
        my $utf8 = $dbh->prepare("set names utf8");
        $utf8->execute();
        $utf8->finish();
        
        my $device_type = $device_info{$device_ip}->[4];
        if($device_type == 11)
        {
            &cisco_process($dbh,$device_ip,@{$device_info{$device_ip}});
        }

        exit 0;
    }
    ++$exist_process;
}

sub cisco_process
{
    my($dbh,$device_ip,$id,$username,$passwd,$port,$device_type,$login_method,$su,$name,$startup,$running) = @_;

    my $exp = Expect->new;
    $exp->log_stdout(0);
    $exp->debug(0);

    my $login_flag = 0;
    if($login_method == 5)
    {
        $login_flag = &cisco_telnet_process($exp,$device_ip,$username,$passwd,$port);
    }
    elsif($login_method == 3 || $login_method == 25)
    {
        my $version = "";
        if($login_method == 25)
        {
            $version = "-1";
        }
        $login_flag = &cisco_ssh_process($exp,$device_ip,$version,$username,$passwd,$port);
    }

    my $startup_flag = 1;
    my $running_flag = 1;
    if($login_flag != 0)
    {
        if($startup == 1)
        {
            $startup_flag = &copy_startup_file($exp,$device_ip);
        }

        if($running == 1)
        {
            $running_flag = &copy_running_file($exp,$device_ip);
        }
    }

    if($startup_flag == 1 && $running_flag == 1)
    {
        my $sqr_insert = $dbh->prepare("insert into autobackup_log(serverip,backuptime,statuts,name) values('$device_ip','$time_now_str',1,'$name')");
        $sqr_insert->execute();
        $sqr_insert->finish();

        my $sqr_update = $dbh->prepare("update autobackup_index set lastruntime='$time_now_str' where id=$id");
        $sqr_update->execute();
        $sqr_update->finish();
    }
    else
    {
        my $sqr_insert = $dbh->prepare("insert into autobackup_log(serverip,backuptime,statuts,name) values('$device_ip','$time_now_str',0,'$name')");
        $sqr_insert->execute();
        $sqr_insert->finish();
    }
}

sub cisco_telnet_process
{
    my($exp,$device_ip,$username,$passwd,$port) = @_;

    my $login_flag = 0;
    $exp->spawn("telnet $device_ip $port");
    my @results = $exp->expect(30,
            [
            qr/Username:/i,
            sub {
            my $self = shift ; 
            $self->send_slow(0.1,"$username\n");
            exp_continue;
            }
            ],

            [
            qr/Password:/i,
            sub {
            my $self = shift ; 
            $self->send_slow(0.1,"$passwd\n");
            exp_continue;
            }
            ],

            [   
            qr/Router\#/i,
            sub {
                &log_process($device_ip,"$device_ip cisco telnet login success");
                $login_flag = 1;
            }
            ],  
                );

            if($login_flag == 1)
            {
                return 1;
            }

            if(defined $results[1])
            {
                &log_process($device_ip,"'telnet $device_ip' exec error $results[1]");
            }

            return 0;
}

sub cisco_ssh_process
{
    my($exp,$device_ip,$version,$username,$passwd,$port) = @_;

    my $count = 0;
    my $flag = 1;

    while($count < 10 && $flag == 1)
    {
        ++$count;

        $exp->spawn("ssh $version -l $username $device_ip -p $port");

        my @results = $exp->expect(20,
                [
                qr/Router\#/i,
                sub {
                $flag = 0;
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
                        $flag = &rsa_err_process($username,$device_ip);
                    }
                ],
                    );

                if($flag == 0)
                {
                    &log_process($device_ip,"$device_ip cisco ssh login success");
                    return 1;
                }
                elsif($flag != 1)
                {
                    &log_process($device_ip,"$device_ip cisco ssh login fail");
                    return 0;
                }
    }

    &log_process($device_ip,"$device_ip cisco ssh login fail");
    return 0;
}

sub copy_startup_file
{
    my($exp,$device_ip) = @_;
    my $cmd = "copy startup-config tftp://172.16.210.116/$date_today/${device_ip}_startup";
    $exp->send("$cmd\n");

    my $flag = 0;
    while(1)
    {
        $exp->expect(1, undef);
        foreach my $line(split /\n/,$exp->before())
        {
            print $line,"\n";
            if($line =~ /Router\#/i)
            {
                $flag = 1;
                last;
            }

            if($line =~ /Address or name of remote/i)
            {
                $exp->send("\n");
            }

            if($line =~ /Destination filename/i)
            {
                $exp->send("\n");
            }
        }
        $exp->clear_accum();

        if($flag == 1)
        {
            last;
        }
    }

    if(-e "$tftp_root/$date_today/${device_ip}_startup")
    {
        &log_process($device_ip,"$device_ip cisco startup backup success");
        return 1;
    }
    &log_process($device_ip,"$device_ip cisco startup backup fail");
    return 0;
}

sub copy_running_file
{
    my($exp,$device_ip) = @_;
    my $cmd = "copy running-config tftp://172.16.210.116/$date_today/${device_ip}_running";
    $exp->send("$cmd\n");

    my $flag = 0;
    while(1)
    {
        $exp->expect(1, undef);
        foreach my $line(split /\n/,$exp->before())
        {
            print $line,"\n";
            if($line =~ /Router\#/i)
            {
                $flag = 1;
                last;
            }

            if($line =~ /Address or name of remote/i)
            {
                $exp->send("\n");
            }

            if($line =~ /Destination filename/i)
            {
                $exp->send("\n");
            }
        }
        $exp->clear_accum();

        if($flag == 1)
        {
            last;
        }
    }

    if(-e "$tftp_root/$date_today/${device_ip}_running")
    {
        &log_process($device_ip,"$device_ip cisco running backup success");
        return 1;
    }
    &log_process($device_ip,"$device_ip cisco running backup fail");
    return 0;
}

sub log_process
{
    my($device_ip,$msg) = @_;
    print "$msg\n";
}

sub rsa_err_process
{
    my($user,$ip) = @_;
    my $home = File::HomeDir->users_home($user);
    unless(defined $home)
    {
        print "cant find home dir for user $user\n";
        return 2;
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

    return 1;
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
