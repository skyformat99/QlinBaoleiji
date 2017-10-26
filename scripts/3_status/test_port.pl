#!/usr/bin/perl
use warnings;
use strict;

my($device_ip,$port) = @ARGV;

unless(defined $device_ip && $device_ip =~ /(\d{1,3}\.){3}\d{1,3}/)
{
	exit(0);
}

unless(defined $port)
{
	exit(0);
}

my $flag = 0;
my $nmap_str = "nmap -n -sT -P0 -p $port $device_ip";

my $nmap = `$nmap_str`;

foreach my $line(split /\n/,$nmap)
{   
	if($line =~ /MAC\s*Address/i) {next;}
	if($flag == 1 && $line =~ /^$/) {last;}

	if($flag == 1)
	{   
		my($port,$status) = (split /\s+/,$line)[0,1];
		$port = (split /\//,$port)[0];

		if($status eq "open")
		{
			exit(1);
		}
		else
		{
			exit(0);
		}
	}
	elsif($line =~ /PORT\s*STATE\s*SERVICE/i)
	{
		$flag = 1;
	}
}

if($flag == 0)
{
	exit(0);
}
