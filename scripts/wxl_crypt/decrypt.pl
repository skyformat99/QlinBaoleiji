#!/usr/bin/perl
use warnings;
use strict;
use Crypt::CBC;
use MIME::Base64;

our $cipher = Crypt::CBC->new( -key => 'freesvr', -cipher => 'Blowfish', -iv => 'freesvr1', -header => 'none');
#my $ciphertext = "kRFrR0JoTujFYcB+C8UT0g==";
my $ciphertext = "JZ1EzZwjYXo=";
$ciphertext = decode_base64($ciphertext);
my $plaintext  = $cipher->decrypt($ciphertext);
print $plaintext,"\n";
