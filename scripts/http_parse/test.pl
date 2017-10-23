#!/usr/bin/perl
use warnings;
use strict;

my @patterns;
open(our $fd_fr, "<./pattern");
while(my $line = <$fd_fr>)
{
    chomp $line;
    push @patterns, $line;
}
close $fd_fr;

open($fd_fr, "<./http.log");
while(my $log = <$fd_fr>)
{
    chomp $log;
    foreach my $p(@patterns)
    {
        if($log =~ $p)
        {
#            print "$log match $p\n";
            my $tmp=1;
            while(1)
            {
                my $res = eval '$'.$tmp;
                unless(defined $res)
                {
                    last;
                }

                if($tmp % 2 == 1) 
                {
                    print "$res:"
                }
                else
                {
                    print "$res, "
                }
                ++$tmp;
            }
            print "\n";
        }
    }
}
close $fd_fr;
