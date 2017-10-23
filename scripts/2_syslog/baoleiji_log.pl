#!/usr/bin/perl
use warnings;
use strict;
use DBI;
use DBD::mysql;
use Time::Local;
use Crypt::CBC;
use MIME::Base64;

our $file = "/var/log/audit.log";
our $debug_file = "/home/wuxiaolong/2_syslog/baoleiji.debuglog";
our $debug_flag = 1;

our %months = (
        "Jan" => 0,
        "Feb" => 1,
        "Mar" => 2,
        "Apr" => 3,
        "May" => 4,
        "Jun" => 5,
        "Jul" => 6,
        "Aug" => 7,
        "Sep" => 8,
        "Oct" => 9,
        "Nov" => 10,
        "Dec" => 11,
        );

our %login_protocal = (
        "ssh" => 3,
        "telnet" => 5,
        "ftp" => 6,
        "sftp" => 7,
        "RDP" => 8,
        "apppub" => 26,
        );

our($mysql_user,$mysql_passwd) = &get_local_mysql_config();
our $dbh=DBI->connect("DBI:mysql:database=audit_sec;host=localhost;mysql_connect_timeout=5",$mysql_user,$mysql_passwd,{RaiseError=>1});
our $utf8 = $dbh->prepare("set names utf8");
$utf8->execute();
$utf8->finish();

open(my $fd_debug,">>$debug_file");

open(our $fd_fr, "<$file");
while(my $log=<$fd_fr>)
{
	chomp $log;

	eval
	{
		&log_process($log);
	};

	if($@)
	{
		&write_debug_log("Runtime Error in <log_process> $log, $@");
		next;
	}
}
close $fd_fr;
close $fd_debug;

&clean_file();

sub log_process
{
	my($log) = @_;
	my $level = 0;
	my $pre_level = 7;
	my $login_detail = 0;

	if($log =~ /Authentication\s*status:\s*no/i)
	{
		$level = 3;
		$pre_level = 5;
		$login_detail = 1;
	}

	my $starttime = undef;
	if($log =~ /^(.*?\d{2}:\d{2}:\d{2})/)
	{
		$starttime = $1;
		$starttime = &getUnixTime($starttime);
	}

	my $pre_starttime = undef;
	if($log =~ /\(time:\s*(.*?\d{2}:\d{2}:\d{2})\)/)
	{
		$pre_starttime = $1;
		$pre_starttime = &getUnixTime($pre_starttime);
	}

	my $login_mod = undef;
	if($log =~ /login\s*protocol\s*:\s*([^\)]*)/i)
	{
		$login_mod = $login_protocal{$1};
	}

	my $pid = undef;
	if($log =~ /authd\s*pid\s*:\s*(\d+)/i)
	{
		$pid = $1;
	}

	my $host = undef;
	if($log =~ /server\s*ip\s*:\s*([^\)]*)/i)
	{
		$host = $1;
		$host =~ s/^\(//;
	}

	my $srchost = undef;
	if($log =~ /source\s*ip\s*:\s*([^\)]*)/i)
	{
		$srchost = $1;
		$srchost =~ s/^\(//;
	}

	my $user = undef;
	if($log =~ /system\s*username\s*:\s*([^\)]*)/i)
	{
		$user = $1;
		$user =~ s/^\(//;
	}

	my $realuser = undef;
	if($log =~ /audit\s*username\s*:\s*([^\)]*)/i)
	{
		$realuser = $1;
		$realuser =~ s/^\(//;
	}

	my $logserver = undef;
	if($log =~ /audit\s*ip\s*:\s*([^\)]*)/i)
	{
		$logserver = $1;
		$logserver =~ s/^\(//;
	}

    $log =~ s/'/\\'/g;

	my $sqr_insert = $dbh->prepare("insert into log_login(host,level,pre_level,starttime,pre_starttime,login_mod,login_detail,pid,srchost,user,realuser,msg,logserver,blj) values ('$host',$level,$pre_level,from_unixtime($starttime),from_unixtime($pre_starttime),$login_mod,$login_detail,$pid,'$srchost','$user','$realuser','$log','$logserver',1)");
	$sqr_insert->execute();
	$sqr_insert->finish();
}

sub getUnixTime
{
	my($timestr) = @_;
	$timestr =~ s/^\s+//;

	my $time_now_utc = time;

	my($mon,$mday,$time) = split /\s+/,$timestr;
	my($hour,$min,$sec) = split /:/,$time;
	my $year = (localtime $time_now_utc)[5];
	$mon = $months{$mon};

	my $unix_time = timelocal($sec,$min,$hour,$mday,$mon,$year);
	if($unix_time > $time_now_utc)
	{
		$unix_time = timelocal($sec,$min,$hour,$mday,$mon,$year-1);
	}
	return $unix_time;
}

sub clean_file
{
	open(our $fd_fw, ">$file");
	close $fd_fw;
}

sub write_debug_log
{   
	my($info) = @_;
	unless($debug_flag)
	{
		return;
	}

	my $time_now_utc = time;
	my($sec,$min,$hour,$mday,$mon,$year) = (localtime $time_now_utc)[0..5];
	($sec,$min,$hour,$mday,$mon,$year) = (sprintf("%02d", $sec),sprintf("%02d", $min),sprintf("%02d", $hour),sprintf("%02d", $mday),sprintf("%02d", $mon+1),$year+1900);
	my $time_now_str = "$year-$mon-$mday $hour:$min:$sec";

	print $fd_debug "$time_now_str\t$info\n";
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
