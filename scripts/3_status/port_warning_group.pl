#!/usr/bin/perl
use strict;
use warnings;

use DBI;
use DBD::mysql;
use Mail::Sender;
use Encode;
use URI::Escape;
use URI::URL;
use Crypt::CBC;
use MIME::Base64;

our $time_now_utc = time;
my($min,$hour,$mday,$mon,$year) = (localtime $time_now_utc)[1..5];
($min,$hour,$mday,$mon,$year) = (sprintf("%02d", $min),sprintf("%02d", $hour),sprintf("%02d", $mday),sprintf("%02d", $mon + 1),$year+1900);
our $time_now_str = "$year$mon$mday$hour$min"."00";
our $time_now_subject = "$year-$mon-$mday $hour:$min";

our($mysql_user,$mysql_passwd) = &get_local_mysql_config();
our $dbh=DBI->connect("DBI:mysql:database=audit_sec;host=localhost;mysql_connect_timeout=3600",$mysql_user,$mysql_passwd,{RaiseError=>1});
our $utf8 = $dbh->prepare("set names utf8");
$utf8->execute();
$utf8->finish();

my $alarm_status = 1;
my $mail_status = 1;
my $sms_status = 1;

&mail_alarm_process($dbh);
&sms_alarm_process($dbh);

if($mail_status == 2 || $sms_status == 2)
{
    $alarm_status = 2;
}

my $sqr_update = $dbh->prepare("update tcp_port_alarm set alarm=$alarm_status where alarm=0");
$sqr_update->execute();
$sqr_update->finish();

sub mail_alarm_process
{
    my($dbh) = @_;

    my %group_hash;

    my $mail = $dbh->prepare("select mailserver,account,password from alarm");
    $mail->execute();
    my $ref_mail = $mail->fetchrow_hashref();
    my $mailserver = $ref_mail->{"mailserver"};
    my $mailfrom = $ref_mail->{"account"};
    my $mailpwd = $ref_mail->{"password"};
    $mail->finish();

    my $subject = "端口扫描告警,$time_now_subject\n";

    my $sqr_select = $dbh->prepare("select ip,datetime,context from tcp_port_alarm where alarm = 0");
    $sqr_select->execute();
    while(my $ref_select = $sqr_select->fetchrow_hashref())
    {
        my $device_ip = $ref_select->{"ip"};
        my $datetime = $ref_select->{"datetime"};
        my $context = $ref_select->{"context"};

        unless(defined $context && $context ne "")
        {
            next;
        }

        my $sqr_select_email = $dbh->prepare("select email from member where uid IN(select memberid from snmp_alert_user a left join snmp_alert b on a.snmp_alert_id=b.seq where b.groupid=(select groupid from servers where device_ip='$device_ip') and b.enable=1) and email != ''");
        $sqr_select_email->execute();
        while(my $ref_select_email = $sqr_select_email->fetchrow_hashref())
        {
            my $email = $ref_select_email->{"email"};

            unless(defined $email)
            {
                next;
            }

            unless(defined $group_hash{$email})
            {
                $group_hash{$email} = "$datetime 端口扫描告警:\n";
            }

            $group_hash{$email} .= "$device_ip $context\n";
        }
        $sqr_select_email->finish();
    }

    foreach my $email(keys %group_hash)
    {
        my $status = &send_mail($email,$subject,$group_hash{$email},$mailserver,$mailfrom,$mailpwd);
        if($status == 2)
        {
            $mail_status = $status;
        }
    }
}

sub sms_alarm_process
{
    my($dbh) = @_;

    my %group_hash;

    my $msg = undef;

    my $sqr_select = $dbh->prepare("select ip,datetime,context from tcp_port_alarm where alarm = 0");
    $sqr_select->execute();
    while(my $ref_select = $sqr_select->fetchrow_hashref())
    {
        my $device_ip = $ref_select->{"ip"};
        my $datetime = $ref_select->{"datetime"};
        my $context = $ref_select->{"context"};

        unless(defined $context && $context ne "")
        {
            next;
        }

        my $sqr_select_sms = $dbh->prepare("select mobilenum from member where uid IN(select memberid from snmp_alert_user a left join snmp_alert b on a.snmp_alert_id=b.seq where b.groupid=(select groupid from servers where device_ip='$device_ip') and b.enable=1) and mobilenum != ''");
        $sqr_select_sms->execute();
        while(my $ref_select_sms = $sqr_select_sms->fetchrow_hashref())
        {
            my $mobilenum = $ref_select_sms->{"mobilenum"};

            unless(defined $mobilenum)
            {
                next;
            }

            unless(defined $group_hash{$mobilenum})
            {
                $group_hash{$mobilenum} = "$datetime 端口扫描告警:\n";
            }

            $group_hash{$mobilenum} .= "$device_ip $context\n";
        }
        $sqr_select_sms->finish();
    }

    foreach my $mobile(keys %group_hash)
    {
        my $status = &send_msg($mobile,$group_hash{$mobile});
        if($status == 2)
        {
            $sms_status = $status;
        }
    }
}

sub send_mail
{
    my($mailto,$subject,$msg,$mailserver,$mailfrom,$mailpwd) = @_;

#    print "$mailto\n$msg\n";
    my $sender = new Mail::Sender;
#   $subject = encode_mimewords($subject,'Charset','UTF-8');
    $subject =  encode("gb2312", decode("utf8", $subject));           #freesvr 专用;
#   $msg = encode_mimewords($msg,'Charset','gb2312');
    $msg =  encode("gb2312", decode("utf8", $msg));              #freesvr 专用;

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
#    print "$mobile_tel\n$msg\n";
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
