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

our($mysql_user,$mysql_passwd) = &get_local_mysql_config();
our $dbh=DBI->connect("DBI:mysql:database=audit_sec;host=localhost;mysql_connect_timeout=5","root",$mysql_passwd,{RaiseError=>1});
our($time_now,$send_time) = @ARGV;

our $mail = $dbh->prepare("select mailserver,account,password from alarm");
$mail->execute();
our $ref_mail = $mail->fetchrow_hashref();
our $mailserver = $ref_mail->{"mailserver"};
our $mailfrom = $ref_mail->{"account"};
our $mailpwd = $ref_mail->{"password"};
$mail->finish();

our @ref_warn;

our $sqr_select = $dbh->prepare("select device_ip,type,value_err,value_thold,disk from snmp_err");
$sqr_select->execute();
while(my $ref_select = $sqr_select->fetchrow_hashref())
{   
	my $device_ip = $ref_select->{"device_ip"};
	my $type = $ref_select->{"type"};
	my $value_err = $ref_select->{"value_err"};
	my $value_thold = $ref_select->{"value_thold"};
	my $disk = $ref_select->{"disk"};

	my @err_value;
	if(defined $disk){@err_value = ($device_ip,$type,$value_err,$value_thold,$disk);}
	else{@err_value = ($device_ip,$type,$value_err,$value_thold);}

	push @ref_warn,\@err_value;
}           
$sqr_select->finish();

if(scalar @ref_warn == 0){exit 0;}

our $subject = "snmp扫描告警,$send_time";
our $msg = "超值告警\n";
our $alarm = 0;

foreach my $temp(@ref_warn)
{
	if($temp->[1] ne "disk"){$msg .= "设备ip:$temp->[0],超值类型:$temp->[1],实际值:$temp->[2],阀值:$temp->[3]\n";}
	else
	{
		$msg .= "设备ip:$temp->[0],超值类型:$temp->[1],分区:$temp->[4],实际值:$temp->[2],阀值:$temp->[3]\n";
	}
}

$sqr_select = $dbh->prepare("select email from member where level=1 and email!='' and email is not null");
$sqr_select->execute();
while(my $ref_select = $sqr_select->fetchrow_hashref())
{
	my $mailto = $ref_select->{"email"};
	&send_mail($mailto,$subject,$msg,$mailserver,$mailfrom,$mailpwd);
}
$sqr_select->finish();

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
