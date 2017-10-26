#!/usr/bin/perl
use warnings;
use strict;
use POSIX qw/ceil floor/;

our $thold_mem = 100;

our $time_now_utc = time;
my($min,$hour,$mday,$mon,$year) = (localtime $time_now_utc)[1..5];
($min,$hour,$mday,$mon,$year) = (sprintf("%02d", $min),sprintf("%02d", $hour),sprintf("%02d", $mday),sprintf("%02d", $mon + 1),$year+1900);
our $time_now_str = "$year$mon$mday$hour$min"."00";

open(our $fd_fw,">>/tmp/mem_detect") or die $!;

foreach(`ps aux`)
{
	my $line = $_;
	my($pid,$mem) = (split /\s+/,$_)[1,5];
	unless($pid =~ /\d+/){next;}

	if($mem > ($thold_mem*1024*1024))
	{
		print $fd_fw $time_now_str,"\t",floor($mem/1024/1024),"MB\tPID:$pid\n";
		if(($line =~ /freesvr_audit_gateway/i) || ($line =~ /freesvr_sshproxy_telnet/i))
		{
			kill 2,$pid;
		}
	}
}
