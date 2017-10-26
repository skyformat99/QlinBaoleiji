#!/usr/bin/perl
use warnings;
use strict;
use POSIX qw/ceil floor/;

our $time_now_utc = time;
our($min,$hour,$mday,$mon,$year) = (localtime $time_now_utc)[1..5];
($min,$hour,$mday,$mon,$year) = (sprintf("%02d", $min),sprintf("%02d", $hour),sprintf("%02d", $mday),sprintf("%02d", $mon + 1),$year+1900);
our $time_now_str = "$year$mon$mday$hour$min"."00";
our $send_time = "$year-$mon-$mday $hour:$min";
our $date = "$year$mon$mday";

my($device_ip,$snmpkey) = @ARGV;
if(defined $device_ip && defined $snmpkey)
{
	&ArrayAPV_snmp_mem($device_ip,$snmpkey);
}
else
{
	print "argument is error\n";
}

sub ArrayAPV_snmp_mem
{
	my($device_ip,$snmpkey) = @_;

	my $mem_used = 0;my $mem_free = 0;my $mem = 0;
	foreach(`snmpwalk -v 2c -c $snmpkey $device_ip .1.3.6.1.4.1.7564.4.1.0 2>&1`)
	{
		if($_ =~ /\.9\.9\.48\.1\.1\.1\.5\.1/i && $_ =~ /Gauge32\s*:\s*(\d+)$/i){$mem_used = $1;}
		if($_ =~ /\.9\.9\.48\.1\.1\.1\.6\.1/i && $_ =~ /Gauge32\s*:\s*(\d+)$/i){$mem_free = $1;}
	}
	$mem = floor($mem_used/($mem_used+$mem_free)*100);

	print "memory:$mem\n";
}

