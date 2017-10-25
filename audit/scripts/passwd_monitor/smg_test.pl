#!/usr/bin/perl
use warnings;
use strict;
use Encode;
use URI::Escape;
#use URI::URL;
#use LWP::UserAgent; 
use SOAP::Lite;

our $mobile_user = "ywsj";
our $mobile_passwd = "ywsj";
our $depart_no = "9931";
our $ip = "10.20.1.176";

&send_msg("18001259390","测试");

sub send_msg
{
    my ($mobile_tel,$msg) = @_;
    
    $msg = encode("utf8", decode("utf8", $msg));
    $msg = uri_escape($msg);

    my $client = SOAP::Lite->service('http://10.20.1.176:8888/WebService.asmx?WSDL');
#    my $result = $client->SendMsg($mobile_user,$mobile_passwd,$depart_no,$mobile_tel,$msg);
    my $result = $client->SendMsg(
            SOAP::Data->name('username')->value($mobile_user),
            SOAP::Data->name('password')->value($mobile_passwd),
            SOAP::Data->name('depid')->value($depart_no),
            SOAP::Data->name('mobile')->value($mobile_tel),
            SOAP::Data->name('content')->value($msg),
            );
    print $result,"\n";
}
