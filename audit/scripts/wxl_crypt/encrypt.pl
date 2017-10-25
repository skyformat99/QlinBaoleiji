#!/usr/bin/perl
use warnings;
use strict;
use Crypt::CBC;
use MIME::Base64;

our $text = $ARGV[0];
unless(defined $text)
{
    $text = "";
}
our $cipher = Crypt::CBC->new( -key => 'freesvr', -cipher => 'Blowfish', -iv => 'freesvr1', -header => 'none');
my $ciphertext = $cipher->encrypt($text);
print encode_base64($ciphertext);
