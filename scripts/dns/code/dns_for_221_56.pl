#!/usr/bin/perl
use warnings;
use strict;
use DBI;
use DBD::mysql;
use RRDs;
use POSIX qw/ceil floor/;

our $device_ip = '221.207.58.56';
our $log_name = "/var/log/mem/dns.log";
our $rrd_path = "/var/log/mem/";
our $log_path = "/var/log/mem/";

unless($rrd_path =~ /\/$/)
{
	$rrd_path .= "/";
}

unless($log_path =~ /\/$/)
{
	$log_path .= "/";
}

foreach my $file(glob "$log_path*log.*")
{
	if(-f $file)
	{
		unlink $file;
	}
}

unless(-e $log_name)
{
	exit;
}

our $time_now_utc = time;
our($min,$hour,$mday,$mon,$year) = (localtime $time_now_utc)[1..5];
($min,$hour,$mday,$mon,$year) = (sprintf("%02d", $min),sprintf("%02d", $hour),sprintf("%02d", $mday),sprintf("%02d", $mon + 1),$year+1900);
our $time_now_str = "$year$mon$mday$hour$min"."00";

our $dbh=DBI->connect("DBI:mysql:database=named;host=221.207.58.50;mysql_connect_timeout=5","freesvr","freesvr",{RaiseError=>1});
our $utf8 = $dbh->prepare("set names utf8");
$utf8->execute();
$utf8->finish();

my $sum = 0;
my $right = 0;

my %client;
my %url;

open(my $fd_fr,"<$log_name") or die $!;
foreach my $line(<$fd_fr>)
{
	chomp $line;
	if($line =~ /^\s*$/)
	{
		next;
	}

	++$sum;

	if($line =~ /queries\s*:.*\+\s*$/i)
	{
		++$right;
	}

	if($line =~ /client\s+(\d+\.\d+\.\d+\.\d+)#/i)
	{
		unless(exists $client{$1})
		{
			$client{$1} = 0;
		}
		++$client{$1};
	}

	if($line =~ /query:\s+(\S+)/i)
	{
		unless(exists $url{$1})
		{
			$url{$1} = 0;
		}
		++$url{$1};
	}
	elsif($line =~ /query\s*\(cache\)\s*\'(.*)\'/i)
	{
		my $tmp = $1;
		$tmp =~ s/\/.*//g;

		unless(exists $url{$tmp})
		{
			$url{$tmp} = 0;
		}
		++$url{$tmp};
	}
	elsif($line =~ /resolving\s*\'(.*)\'/i)
	{
		my $tmp = $1;
		$tmp =~ s/\/.*//g;

		unless(exists $url{$tmp})
		{
			$url{$tmp} = 0;
		}
		++$url{$tmp};
	}
}

close($fd_fr);
open(my $fd_fw,">$log_name") or die $!;
close($fd_fw);      

my @result = (sort {$client{$b} <=> $client{$a} or $a cmp $b} keys %client)[0..9];
my @ips = @result;

foreach(@result)
{
	unless(defined $_)
	{
		last;
	}

	my $sqr_insert = $dbh->prepare("insert into dns_IP_top(device_ip,datetime,client_ip,count) values('$device_ip','$time_now_str','$_',$client{$_})");
	$sqr_insert->execute();
	$sqr_insert->finish();
}

@result = (sort {$url{$b} cmp $url{$a} or $a cmp $b} keys %url)[0..9];
my @domains =  @result;

foreach(@result)
{
	unless(defined $_)
	{
		last;
	}

	my $sqr_insert = $dbh->prepare("insert into dns_url_top(device_ip,datetime,url,count) values('$device_ip','$time_now_str','$_',$url{$_})");
	$sqr_insert->execute();
	$sqr_insert->finish();
}

&rrd_process($sum,"querynum");
&rrd_process($right,"normalnum");
&rrd_process($sum-$right,"abnormalnum");

&warning($sum,$right,$sum-$right,\@ips,\%client,\@domains,\%url);

sub rrd_process
{
	my($value,$name) = @_;

	if(!defined $value || $value < 0)
	{
		$value = 'U';
	}

	my $start_time = time;
	$start_time = (floor($start_time/300))*300;

	$rrd_path =~ s/\/$//g;
	$rrd_path .= "/";

	unless(-e $rrd_path)
	{
		`mkdir -p $rrd_path`;
	}

	my $file = $rrd_path."$device_ip"."_$name.rrd";

	unless(-e $file)
	{
		my $create_time = $start_time - 300;
		RRDs::create($file,
				'--start', "$create_time",
				'--step', '300',
				'DS:val:GAUGE:600:U:U',
				'RRA:AVERAGE:0.5:1:576',
				'RRA:AVERAGE:0.5:12:192',
				'RRA:AVERAGE:0.5:288:32',
				'RRA:MAX:0.5:1:576',
				'RRA:MAX:0.5:12:192',
				'RRA:MAX:0.5:288:32',
				'RRA:MIN:0.5:1:576',
				'RRA:MIN:0.5:12:192',
				'RRA:MIN:0.5:288:32',
				);
	}

	RRDs::update(
			$file,
			'-t', 'val',
			'--', join(':', "$start_time", "$value"),
			);
}

sub warning
{
	my($num,$normalnum,$abnormalnum,$ref_ips,$ref_client,$ref_domains,$ref_url) = @_;

	my $sqr_select = $dbh->prepare("select traffic,sourceipnum,domainnum,num,abnormalnum,normalnum,ddos from dnssetting");
	$sqr_select->execute();
	my $ref_select = $sqr_select->fetchrow_hashref();
	my $traffic_thold = $ref_select->{"traffic"};
	my $sourceipnum_thold = $ref_select->{"sourceipnum"};
	my $domainnum_thold = $ref_select->{"domainnum"};
	my $num_thold = $ref_select->{"num"};
	my $abnormalnum_thold = $ref_select->{"abnormalnum"};
	my $normalnum_thold = $ref_select->{"normalnum"};
	my $ddos = $ref_select->{"ddos"};
	$sqr_select->finish();

	&traffic_warning($traffic_thold,$ddos);

	if(($num/300) > $num_thold)
	{
		my $sqr_insert = $dbh->prepare("insert into dnsseclog(host,DDos_tpye,datetime,cur_val,thold,ddos) values('$device_ip','DNS总查询率','$time_now_str',$num/300,$num_thold,$ddos)");
		$sqr_insert->execute();
		$sqr_insert->finish();
	}

	foreach(@$ref_ips)
	{
		unless(defined $_)
		{
			last;
		}

		if(($ref_client->{$_}/300) > $sourceipnum_thold)
		{
			my $sqr_insert = $dbh->prepare("insert into dnsseclog(host,DDos_tpye,datetime,cur_val,thold,ddos) values('$device_ip','$_ DNS查询率','$time_now_str',$ref_client->{$_}/300,$sourceipnum_thold,$ddos)");
			$sqr_insert->execute();
			$sqr_insert->finish();
		}
	}

	foreach(@$ref_domains)
	{
		unless(defined $_)
		{
			last;
		}

		if(($ref_url->{$_}/300) > $domainnum_thold)
		{
			my $sqr_insert = $dbh->prepare("insert into dnsseclog(host,DDos_tpye,datetime,cur_val,thold,ddos) values('$device_ip','域名 $_ DNS查询率','$time_now_str',$ref_url->{$_}/300,$domainnum_thold,$ddos)");
			$sqr_insert->execute();
			$sqr_insert->finish();
		}
	}

	if(($normalnum/300) > $normalnum_thold)
	{
		my $sqr_insert = $dbh->prepare("insert into dnsseclog(host,DDos_tpye,datetime,cur_val,thold,ddos) values('$device_ip','正常请求','$time_now_str',$normalnum/300,$normalnum_thold,$ddos)");
		$sqr_insert->execute();
		$sqr_insert->finish();
	}

	if(($abnormalnum/300) > $abnormalnum_thold)
	{
		my $sqr_insert = $dbh->prepare("insert into dnsseclog(host,DDos_tpye,datetime,cur_val,thold,ddos) values('$device_ip','不正常请求','$time_now_str',$abnormalnum/300,$abnormalnum_thold,$ddos)");
		$sqr_insert->execute();
		$sqr_insert->finish();
	}
}

sub traffic_warning
{
	my($traffic_thold,$ddos) = @_;

	my $traffic_now = undef;

	my $sqr_select = $dbh->prepare("select count(*) from dnstraffic_record where host = '$device_ip'");
	$sqr_select->execute();
	my $ref_select = $sqr_select->fetchrow_hashref();
	my $count = $ref_select->{"count(*)"};
	$sqr_select->finish();

	my $eth_info = `/sbin/ifconfig eth0 2>&1| grep -i 'RX byte'`;
	if(defined $eth_info && $eth_info =~ /RX\s*bytes\s*:\s*(\d+)/i)
	{
		$traffic_now = $1*8;
	}

	unless(defined $traffic_now)
	{
		return;
	}

	if($count == 0)
	{
		my $sqr_insert = $dbh->prepare("insert into dnstraffic_record(host,datetime,val) values('$device_ip','$time_now_str',$traffic_now)");
		$sqr_insert->execute();
		$sqr_insert->finish();
		return;
	}

	$sqr_select = $dbh->prepare("select UNIX_TIMESTAMP(datetime),val from dnstraffic_record where host = '$device_ip'");
	$sqr_select->execute();
	$ref_select = $sqr_select->fetchrow_hashref();
	my $time_old_utc = $ref_select->{"UNIX_TIMESTAMP(datetime)"};
	my $traffic_old = $ref_select->{"val"};
	$sqr_select->finish();

	my $sqr_update = $dbh->prepare("update dnstraffic_record set datetime = '$time_now_str',val = $traffic_now where host = '$device_ip'");
	$sqr_update->execute();
	$sqr_update->finish();

	my $traffic_rate = ($traffic_now-$traffic_old)/($time_now_utc-$time_old_utc);
	$traffic_rate = floor($traffic_rate*100)/100;

	if($traffic_rate > $traffic_thold)
	{
		my $sqr_insert = $dbh->prepare("insert into dnsseclog(host,DDos_tpye,datetime,cur_val,thold,ddos) values('$device_ip','DNS流量','$time_now_str',$traffic_rate,$traffic_thold,$ddos)");
		$sqr_insert->execute();
		$sqr_insert->finish();
	}
}
