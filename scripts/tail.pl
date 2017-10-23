#!/usr/bin/perl
use strict;
use warnings;

our($file,$num) = @ARGV;
unless(defined $num)
{
    $num = 10;
}

my @lines;
open(our $fd_fr,"<$file");
foreach my $line(<$fd_fr>)
{
    if(scalar @lines >= $num)
    {
        shift @lines;
    }
    push @lines,$line;
}

print @lines;

while(1)
{
    sleep 1;
    foreach my $line(<$fd_fr>)
    {
        print $line
    }
}
