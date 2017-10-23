#!/usr/bin/perl
use strict;
use warnings;

use DBI;
use DBD::mysql;
use Mail::Sender;
use Encode;
use URI::Escape;
use LWP::Simple;
use Crypt::CBC;
use MIME::Base64;

our $time_now_utc = time;
my($min,$hour,$mday,$mon,$year) = (localtime $time_now_utc)[1..5];
($min,$hour,$mday,$mon,$year) = (sprintf("%02d", $min),sprintf("%02d", $hour),sprintf("%02d", $mday),sprintf("%02d", $mon + 1),$year+1900);
our $time_now_str = "$year$mon$mday$hour$min"."00";

our($mysql_user,$mysql_passwd) = &get_local_mysql_config();
our $dbh=DBI->connect("DBI:mysql:database=audit_sec;host=localhost;mysql_connect_timeout=5",$mysql_user,$mysql_passwd,{RaiseError=>1});

our $utf8 = $dbh->prepare("set names utf8");
$utf8->execute();
$utf8->finish();

my %thold_hash;

my $status = 0;
my $mailserver;
my $mailfrom;
my $mailpwd;

my $sqr_select = $dbh->prepare("select MailServer,account,password from alarm");
$sqr_select->execute();
my $ref_select = $sqr_select->fetchrow_hashref();
$mailserver = $ref_select->{"MailServer"};
$mailfrom = $ref_select->{"account"};
$mailpwd = $ref_select->{"password"};
$sqr_select->finish();

$sqr_select = $dbh->prepare("select name,thold from status_warning");
$sqr_select->execute();
while($ref_select = $sqr_select->fetchrow_hashref())
{
	my $name = $ref_select->{"name"};
	my $thold = $ref_select->{"thold"};
	if(defined $name && defined $thold)
	{
		$thold_hash{$name} = $thold;
	}
}
$sqr_select->finish();

my $subject = "主机信息告警";
my $msg = "";

my $pair_num = (scalar @ARGV)/2;
foreach my $i(0..($pair_num - 1))
{
	my $name = $ARGV[2*$i];
	my $value = $ARGV[2*$i+1];
	my $thold = $thold_hash{$name};

	$msg .= $name;

	if($name eq "ssh" || $name eq "telnet" || $name eq "rdp" || $name eq "ftp" || $name eq "db")
	{
		$msg .= "会话数";
	}
	$msg .= "超值\t当前值:$value,阈值:$thold\n";
}

$sqr_select = $dbh->prepare("select email from member where level=1");
$sqr_select->execute();
while($ref_select = $sqr_select->fetchrow_hashref())
{
#	my $email = $ref_select->{"email"};
	my $email = 'wxl@freesvr.com.cn';
#	$status = &send_mail($email,$subject,$msg,$mailserver,$mailfrom,$mailpwd);
	$status = &send_mail($email,$subject,$msg,'mail.freesvr.com.cn','wxl@freesvr.com.cn','12345678');
}
$sqr_select->finish();

foreach my $i(0..($pair_num - 1))
{
	my $name = $ARGV[2*$i];
	my $value = $ARGV[2*$i+1];
	my $thold = $thold_hash{$name};

	my $sqr_insert = $dbh->prepare("insert into status_abnormal(name,value,datetime,mail_stat) values('$name',$value,'$time_now_str',$status)");
	$sqr_insert->execute();
	$sqr_insert->finish();
}

sub send_mail
{
	my($mailto,$subject,$msg,$mailserver,$mailfrom,$mailpwd) = @_;

	my $sender = new Mail::Sender;
#	$subject = encode_mimewords($subject,'Charset','UTF-8');
	$subject =  encode("gb2312", decode("utf8", $subject));           #freesvr 专用
#	$msg = encode_mimewords($msg,'Charset','gb2312');
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
#				encoding => 'gb2312',
					})<0){
			return 0;
		}
		else
		{
			return 1;
	}
}

sub send_msg
{
	my ($mobile_tel,$msg) = @_;
	my $sp_no = "9555899";
	my $mobile_type = "1";
	$msg =  encode("gb2312", decode("utf8", $msg));
	$msg = uri_escape($msg);

	my $url = "http://192.168.4.71:8080/smsServer/service.action?branch_no=10&password=010&depart_no=10001&message_type=1&batch_no=4324&priority=1&sp_no=$sp_no&mobile_type=$mobile_type&mobile_tel=$mobile_tel&message=$msg";

#	$url = URI::URL->new($url); 
	
	if(defined(get($url)))
	{
		return 1;
	} 
	else
	{
		return 2;
	}
}

sub get_local_mysql_config
{
    my $tmp_mysql_user = "root";
    my $tmp_mysql_passwd = "";
    open(my $fd_fr, "</opt/freesvr/audit/etc/perl.cnf");
    while(my $line = <$fd_fr>)
    {
        $line =~ s/\s//g;
        my($name, $val) = split /:/, $line;
        if($name eq "mysql_user")
        {
            $tmp_mysql_user = $val;
        }
        elsif($name eq "mysql_passwd")
        {
            $tmp_mysql_passwd = $val;
        }
    }

    my $cipher = Crypt::CBC->new( -key => 'freesvr', -cipher => 'Blowfish', -iv => 'freesvr1', -header => 'none');
    $tmp_mysql_passwd = decode_base64($tmp_mysql_passwd);
    $tmp_mysql_passwd  = $cipher->decrypt($tmp_mysql_passwd);
    close $fd_fr;
    return ($tmp_mysql_user, $tmp_mysql_passwd);
}
