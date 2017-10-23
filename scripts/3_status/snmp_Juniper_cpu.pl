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
	&Juniper_snmp_cpu($device_ip,$snmpkey);
}
else
{
	print "argument is error\n";
}

sub Juniper_snmp_cpu
{
	my($device_ip,$snmpkey) = @_;

	my $cpu_num = 0;my $cpu_value = 0;
	foreach(`snmpwalk -v 2c -c $snmpkey $device_ip 1.3.6.1.4.1.3224.16.1.1 2>&1`)
	{
		++$cpu_num;
	
		if($_ =~ /Timeout.*No Response from/i){return;}

		if($_ =~ /Gauge32\s*:\s*(\d+)$/i){$cpu_value += $1;}
	}
	$cpu_value = floor($cpu_value/$cpu_num);

	print "cpu:$cpu_value\n";
}

