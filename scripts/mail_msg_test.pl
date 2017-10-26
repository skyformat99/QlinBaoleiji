#!/usr/bin/perl
use strict;
use warnings;

use DBI;
use DBD::mysql;
use Mail::Sender;
use Encode;
use URI::Escape;
use URI::URL;

my $mailserver = 'smtp.163.com';
my $mailfrom = 'testnetmwd@163.com';
my $mailpwd = 'netmwd123';
#邮件发送地址
my $mailto = 'wxl890206@126.com';

my $subject = "你好";
my $msg = "你好";

=pod
my $status = &send_mail($mailto,$subject,$msg,$mailserver,$mailfrom,$mailpwd);
if($status == 2)
{
	print "邮件发送失败\n";
}
else
{
	print "邮件发送成功\n";
}
=cut

#要短信测试时 取消下面注释
my $tel = "13311507286";
my $status = &send_msg($tel,$msg);
if($status == 2)
{
	print "短信发送失败\n";
}
else
{
	print "短信发送成功\n";
}

sub send_mail
{   
	my($mailto,$subject,$msg,$mailserver,$mailfrom,$mailpwd) = @_;

	my $sender = new Mail::Sender;
	$subject =  encode("gb2312", decode("utf8", $subject));           #freesvr 专用
	$msg =  encode("gb2312", decode("utf8", $msg));              #freesvr 专用

		if ($sender->MailMsg({
					smtp => $mailserver,
					from => $mailfrom,
					to => $mailto,
					subject => $subject,
					msg => $msg,
					auth => 'LOGIN',
					authid => $mailfrom,
					authpwd => $mailpwd,
#               encoding => 'gb2312',
					})<0){
			return 2;
		}
		else
		{
			return 1;
		}
}

sub send_msg
{
	my ($mobile_tel,$msg) = @_;
	my $sp_no = "955589903";
	my $mobile_type = "1";
	$msg =  encode("gb2312", decode("utf8", $msg));
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
