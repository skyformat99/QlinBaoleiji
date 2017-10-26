#!/usr/bin/perl
use strict;
use warnings;

use DBI;
use DBD::mysql;
use Encode;
use URI::Escape;
use URI::URL;

my($tel,$msg) = @ARGV;
my $status = &send_msg($tel,$msg);

if($status == 2)
{
	print "短信发送失败\n";
    exit 0;
}
else
{
	print "短信发送成功\n";
    exit 1;
}

sub send_msg
{
	my ($mobile_tel,$msg) = @_;
	my $sp_no = "955589903";
	my $mobile_type = "1";
	$msg = encode("gb2312", decode("utf8", $msg));
	$msg = uri_escape($msg);

	my $url = "http://192.168.4.71:8080/smsServer/service.action?branch_no=10&password=010&depart_no=10001&message_type=1&batch_no=4324&priority=1&sp_no=$sp_no&mobile_type=$mobile_type&mobile_tel=$mobile_tel&message=$msg";

	$url = URI::URL->new($url);

	if(system("wget -t 1 -T 3 '$url' -O - 1>/dev/null 2>&1") == 0)
	{
		return 1;
	}
	else
	{
		return 2;
	}
}
