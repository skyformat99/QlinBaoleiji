#!/usr/bin/perl
use warnings;
use strict;
use DBI;
use DBD::mysql;
use Socket;
use Fcntl;
use IO::Select;
use Time::HiRes qw(gettimeofday);
use POSIX qw/ceil floor/;
use Crypt::CBC;
use MIME::Base64;

our $max_process_num = 2;
our $exist_process = 0;

our $time_now_utc = time;
our($min,$hour,$mday,$mon,$year) = (localtime $time_now_utc)[1..5];
($min,$hour,$mday,$mon,$year) = (sprintf("%02d", $min),sprintf("%02d", $hour),sprintf("%02d", $mday),sprintf("%02d", $mon + 1),$year+1900);
our $time_now_str = "$year$mon$mday$hour$min"."00";
our $send_time = "$year-$mon-$mday $hour:$min";

our($mysql_user,$mysql_passwd) = &get_local_mysql_config();
our $dbh=DBI->connect("DBI:mysql:database=audit_sec;host=localhost;mysql_connect_timeout=5",$mysql_user,$mysql_passwd,{RaiseError=>1});

our $utf8 = $dbh->prepare("set names utf8");
$utf8->execute();
$utf8->finish();

our $sqr_truncate = $dbh->prepare("truncate tcp_port_err");
$sqr_truncate->execute();
$sqr_truncate->finish();

our @ref_ip_arr;
my $sqr_select = $dbh->prepare("select ip,tcpport,timeout from tcp_port");
$sqr_select->execute();
while(my $ref_select = $sqr_select->fetchrow_hashref())
{
	my $ip = $ref_select->{"ip"};
	my $port = $ref_select->{"tcpport"};
	my $timeout = $ref_select->{"timeout"};

	my @host = ($ip,$port,$timeout);
	push @ref_ip_arr,\@host;
}
$sqr_select->finish();
my $rc = $dbh->disconnect;

if($max_process_num > scalar @ref_ip_arr){$max_process_num = scalar @ref_ip_arr;}
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
				defined(my $pid = fork) or die "cannot fork:$!";
				unless($pid){
					exec "/home/wuxiaolong/3_status/port_warning_group.pl",$time_now_str,$send_time;
				}           
				exit;
			}
		}
	}
}

sub fork_process
{
	my $temp = shift @ref_ip_arr;
	unless(defined $temp){return;}
	my $pid = fork();
	if (!defined($pid))
	{
		print "Error in fork: $!";
		exit 1;
	}

	if ($pid == 0)
	{
		&port_scan($temp->[0],$temp->[1],$temp->[2]);
		exit(0);
	}
	++$exist_process;
}

sub socket_connect
{
    my($ip,$port) = @_;

    my $destination=sockaddr_in($port,inet_aton($ip));

    socket(my $sock,AF_INET,SOCK_STREAM,6) or die "Can't make socket: $!";
    fcntl($sock, F_SETFL, fcntl($sock, F_GETFL, 0) | O_NONBLOCK);
    my $sel_socket = new IO::Select($sock);

    my ($start_sec, $start_usec) = gettimeofday();

    connect($sock, $destination);

    my ($read_set, $write_set, $error_set) = IO::Select->select($sel_socket, $sel_socket, $sel_socket, 5);
    if (defined $read_set || defined $write_set)
    {
#        print "ok\n";
        my ($end_sec, $end_usec) = gettimeofday();
        close $sock;
        my $time = ($end_sec-$start_sec)*1000+($end_usec-$start_usec)/1000;
        return $time;
    }
    else
    {
#        print "no ok\n";
        close $sock;
        return 0;
    }
}

sub port_scan
{
	my($ip,$port,$timeout) = @_;

	my $dbh=DBI->connect("DBI:mysql:database=audit_sec;host=localhost;mysql_connect_timeout=5",$mysql_user,$mysql_passwd,{RaiseError=>1});
	    
	my $utf8 = $dbh->prepare("set names utf8");
	$utf8->execute();
	$utf8->finish();
	
	my $min_time = 0;
	foreach(1..3)
	{
		my $temp = &socket_connect($ip,$port);
		if($min_time == 0)
		{
			if($temp != 0){$min_time = $temp;}
		}
		else
		{
			if($temp != 0 && $temp < $min_time){$min_time = $temp;}
		}
	}

	if($min_time != 0 && $min_time < $timeout)
	{
		my $sqr_insert = $dbh->prepare("insert into tcp_port_value (datetime,ip,tcpport,time) values ('$time_now_str','$ip',$port,$min_time)");
		$sqr_insert->execute();
		$sqr_insert->finish();
	}
	else
	{
		my $sqr_insert = $dbh->prepare("insert into tcp_port_err (ip,tcpport,time_err,time_thold) values ('$ip',$port,$min_time,$timeout)");
		$sqr_insert->execute();
		$sqr_insert->finish();
	}
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
