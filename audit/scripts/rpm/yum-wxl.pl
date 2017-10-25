#!/usr/bin/perl
use warnings;
use strict;

open(my $fd_fr,"<./yum.log");

foreach my $line(<$fd_fr>)
{
	chomp $line;
	my $packge_name = (split /\s+/,$line)[4];
	print $packge_name,"\n";
}

