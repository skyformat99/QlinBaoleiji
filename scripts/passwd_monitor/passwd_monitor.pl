#!/usr/bin/perl
use warnings;
use strict;
use Time::Local;
use DBI;
use DBD::mysql;
use Encode;
use URI::Escape;
use URI::URL;
use Crypt::CBC;
use MIME::Base64;

our $cipher = Crypt::CBC->new( -key => 'freesvr', -cipher => 'Blowfish', -iv => 'freesvr1', -header => 'none');
our $remote_mysql_passwd = "zT6fYu8HhLQ=";
$remote_mysql_passwd = decode_base64($remote_mysql_passwd);
$remote_mysql_passwd = $cipher->decrypt($remote_mysql_passwd);

our $mobile_user = "ywsj";
our $mobile_passwd = "ywsj";
our $depart_no = "9931";

our $time_now_utc = time;
our($min,$hour,$mday,$mon,$year) = (localtime $time_now_utc)[1..5];
our $today_start_utc = timelocal(0,0,0,$mday,$mon,$year);
($min,$hour,$mday,$mon,$year) = (sprintf("%02d", $min),sprintf("%02d", $hour),sprintf("%02d", $mday),sprintf("%02d", $mon + 1),$year+1900);
our $time_now_str = "$year$mon$mday$hour$min"."00";
our $today_end_utc = $today_start_utc + 86400;
our $time_msg_time = "$year-$mon-$mday";

our %device_status;

our($mysql_user,$mysql_passwd) = &get_local_mysql_config();
our $dbh=DBI->connect("DBI:mysql:database=audit_nm;host=localhost;mysql_connect_timeout=5",$mysql_user,$mysql_passwd,{RaiseError=>1});
my $utf8 = $dbh->prepare("set names utf8");
$utf8->execute();
$utf8->finish();

my $sqr_select = $dbh->prepare("select host from device_mysql_info");
$sqr_select->execute();
while(my $ref_select = $sqr_select->fetchrow_hashref())
{   
    my $host = $ref_select->{"host"};

    unless(defined $host && $host ne "localhost")
    {   
        next;
    }

    unless(defined $device_status{$host})
    {
        $device_status{$host} = 1;
    }

    $device_status{$host} = &device_log_process($host,'freesvr',$remote_mysql_passwd);
}
$sqr_select->finish();

my $success_device = 0;
my $fail_device = 0;
my $success_num = 0;
my $fail_num = 0;
foreach my $host(keys %device_status)
{
    unless(defined $device_status{$host})
    {
        ++$fail_device;
        &insert_into_passwd_report($host,-1,-1);
        next;
    }

    ++$success_device;
    $success_num += $device_status{$host}->[0];
    $fail_num += $device_status{$host}->[1];
    &insert_into_passwd_report($host,$device_status{$host}->[0],$device_status{$host}->[1]);
}

my $mobile_content = "服务器密码修改通知,$time_msg_time";
if($success_device > 0)
{
    $mobile_content .= ",共计成功取得${success_device}台堡垒机信息";
}

if($fail_device > 0)
{
    $mobile_content .= ",${fail_device}台堡垒机未取得成功";
}

if($success_num > 0)
{
    $mobile_content .= ",共计成功修改${success_num}个系统用户口令";
}

if($fail_num > 0)
{
    $mobile_content .= ",${fail_num}个系统用户口令修改未成功";
}

$sqr_select = $dbh->prepare("select mobile_num from users where username = 'admin'");
$sqr_select->execute();
while(my $ref_select = $sqr_select->fetchrow_hashref())
{
    my $mobile_tel = $ref_select->{"mobile_num"};

    my $status = &send_msg($mobile_tel,$mobile_content);
    my $insert = $dbh->prepare("insert into passwd_monitor_send_record(mobile_num,datetime,result) values('$mobile_tel','$time_now_str',$status)");
    $insert->execute();
    $insert->finish();
}
$sqr_select->finish();

sub send_msg
{
    my ($mobile_tel,$msg) = @_;

    $msg = encode("utf8", decode("utf8", $msg));
    $msg = uri_escape($msg);

    my $url = "https://10.20.36.37/soap.php?content=$msg&mobile=$mobile_tel";

    $url = URI::URL->new($url);

    if(system("wget --no-check-certificate -t 1 -T 3 '$url' -O - 1>/dev/null 2>&1") == 0)
    {
        return 1;
    }
    else
    {
        return 0;
    }
}

sub device_log_process
{
    my($host,$remote_mysql_user,$remote_mysql_passwd) = @_;
    my @count = (0,0);

    my $remote_dbh = DBI->connect("DBI:mysql:database=audit_sec;host=$host;mysql_connect_timeout=5",$remote_mysql_user,$remote_mysql_passwd,{RaiseError=>0});

    unless(defined $remote_dbh)
    {
        return undef;
    }

    my $utf8 = $remote_dbh->prepare("set names utf8");
    $utf8->execute();
    $utf8->finish();

    my $sqr_select = $remote_dbh->prepare("select time,device_ip,username,update_success_flag,password from log where UNIX_TIMESTAMP(time)>=$today_start_utc and UNIX_TIMESTAMP(time)<$today_end_utc");
    $sqr_select->execute();
    while(my $ref_select = $sqr_select->fetchrow_hashref())
    {
        my $time = $ref_select->{"time"};
        my $device_ip = $ref_select->{"device_ip"};
        my $username = $ref_select->{"username"};
        my $flag = $ref_select->{"update_success_flag"};
        my $password = $ref_select->{"password"};

        my $cmd;
        if(defined $password)
        {
            $cmd = "insert into password_log(time,device_ip,username,update_success_flag,password,host) values('$time','$device_ip','$username','$flag','$password','$host')";
        }
        else
        {
            $cmd = "insert into password_log(time,device_ip,username,update_success_flag,host) values('$time','$device_ip','$username','$flag','$host')";
        }

        my $insert = $dbh->prepare("$cmd");
        $insert->execute();
        $insert->finish();

        if($flag =~ /Yes/i)
        {
            ++$count[0];
        }
        else
        {
            ++$count[1];
        }
    }
    $sqr_select->finish();

    $remote_dbh->disconnect();

    return \@count;
}

sub insert_into_passwd_report
{
    my($host,$success,$fail) = @_;

    my $insert = $dbh->prepare("insert into passwd_monitor_report(host,datetime,success,fail) values('$host','$time_now_str',$success,$fail)");
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
