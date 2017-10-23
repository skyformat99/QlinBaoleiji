#!/usr/bin/perl
use warnings;
use strict;
use DBI;
use DBD::mysql;
use RRDs;
use Crypt::CBC;
use MIME::Base64;
use POSIX qw/ceil floor/;

our $device_ip = '118.186.17.101';
our $log_name = "/home/wuxiaolong/dns/log/named.log";
our $rrd_path = "/home/wuxiaolong/dns/rrd/";
our $log_path = "/home/wuxiaolong/dns/log/";

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

our $time_now_utc = time;
our($min,$hour,$mday,$mon,$year) = (localtime $time_now_utc)[1..5];
($min,$hour,$mday,$mon,$year) = (sprintf("%02d", $min),sprintf("%02d", $hour),sprintf("%02d", $mday),sprintf("%02d", $mon + 1),$year+1900);
our $time_now_str = "$year$mon$mday$hour$min"."00";

our($mysql_user,$mysql_passwd) = &get_local_mysql_config();
our $dbh=DBI->connect("DBI:mysql:database=named;host=localhost;mysql_connect_timeout=5",$mysql_user,$mysql_passwd,{RaiseError=>1});
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

my @result = (sort {$client{$b} <=> $client{$a} or $a cmp $b} keys %client)[0..9];

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

close($fd_fr);
open(my $fd_fw,">$log_name") or die $!;
close($fd_fw);      

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
