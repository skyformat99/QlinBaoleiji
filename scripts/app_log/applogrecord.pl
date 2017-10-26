#!/usr/bin/perl
use warnings;
use strict;
use DBI;
use DBD::mysql;
use Mail::Sender;
use Encode;
use URI::Escape;
use URI::URL;
use Crypt::CBC;
use MIME::Base64;

our $cipher = Crypt::CBC->new( -key => 'freesvr', -cipher => 'Blowfish', -iv => 'freesvr1', -header => 'none');
our $remote_mysql_user = "root";
our $remote_mysql_passwd = "JZ1EzZwjYXo=";
$remote_mysql_passwd = decode_base64($remote_mysql_passwd);
$remote_mysql_passwd = $cipher->decrypt($remote_mysql_passwd);

our $log_path = "/var/log/memapp";
$log_path =~ s/\/$//g;
our $remote_host = "localhost";
our $remote_user = "root";
our $remote_passwd = "";

my($sec,$min,$hour,$mday,$mon,$year) = (localtime)[0..5];
($sec,$min,$hour,$mday,$mon,$year) = (sprintf("%02d", $sec),sprintf("%02d", $min),sprintf("%02d", $hour),sprintf("%02d", $mday),sprintf("%02d", $mon + 1),$year+1900);
our $time_now_str = "$year$mon$mday$hour$min"."00";
our $warning_time = "$year-$mon-$mday $hour:$min:00";

our($mysql_user,$mysql_passwd) = &get_local_mysql_config();
our $dbh=DBI->connect("DBI:mysql:database=audit_sec;host=localhost;mysql_connect_timeout=5",$mysql_user,$mysql_passwd,{RaiseError=>1});
our $utf8 = $dbh->prepare("set names utf8");
$utf8->execute();
$utf8->finish();

our $remote_dbh=DBI->connect("DBI:mysql:database=audit_sec;host=$remote_host;mysql_connect_timeout=5",$remote_mysql_user,$remote_mysql_passwd,{RaiseError=>1});
$utf8 = $remote_dbh->prepare("set names utf8");
$utf8->execute();
$utf8->finish();

our $send_interval = 30;
our %mail_msg;
our %sms_msg;
our %sended_mail;
our %sended_sms;

our %warning_list;
&init_warning();
&init_sended_info();

my $dir;
opendir $dir,$log_path;
while(my $file = readdir $dir)
{
    if($file =~ /^\./ || !($file =~ /.*\d{14}$/))
    {
        next;
    }

    &log_process($file);
    unlink "$log_path/$file";
}

my $mail = $dbh->prepare("select mailserver,account,password from alarm");
$mail->execute();
my $ref_mail = $mail->fetchrow_hashref();
my $mailserver = $ref_mail->{"mailserver"};
my $mailfrom = $ref_mail->{"account"};
my $mailpwd = $ref_mail->{"password"};
$mail->finish();

my $subject = "应用日志告警,$warning_time\n";
foreach my $email(keys %mail_msg)
{
    $mail_msg{$email}->[1] .= ")";
    my $status = &send_mail($email,$subject,$mail_msg{$email}->[0],$mailserver,$mailfrom,$mailpwd);
    my $sqr_update = $dbh->prepare("update applog_warning set mail_status=$status where id in $mail_msg{$email}->[1]");
    $sqr_update->execute();
    $sqr_update->finish();
}

foreach my $mobile(keys %sms_msg)
{
    $sms_msg{$mobile}->[1] .= ")";
    my $status = 1;
    foreach my $msg(split /\n/, $sms_msg{$mobile}->[0])
    {
        my $tmp_status = &send_msg($mobile,$msg);
        if($tmp_status == 2)
        {
            $status = 2;
        }
    }

    my $sqr_update = $dbh->prepare("update applog_warning set sms_status=$status where id in $sms_msg{$mobile}->[1]");
    $sqr_update->execute();
    $sqr_update->finish();
}

sub log_process
{
    my($file) = @_;

    print $file,"\n";
    my($num1,$num2,$num3,$num4) = (split /\./,$file)[-5,-4,-3,-2];
    unless((defined $num1 && $num1<=255) && (defined $num2 && $num2<=255)
            && (defined $num3 && $num3<=255) && defined $num4 && $num4<=255)
    {
        return;
    }

    my $host = join(".", ($num1,$num2,$num3,$num4));
    print $host,"\n";

    open(my $fd_fr,"<$log_path/$file");
    foreach my $msg(<$fd_fr>)
    {
        chomp $msg;
        unless(defined $msg){next;}

        $msg =~ s/'/\\'/g;

        my $sqr_insert = $remote_dbh->prepare("insert into applog(datetime,host,msg) values('$time_now_str','$host','$msg')");
        $sqr_insert->execute();
        $sqr_insert->finish();

        my($mail_alarm,$sms_alarm,$instruction) = &is_warning($msg);
        if($mail_alarm == 1 || $sms_alarm == 1)
        {
            $sqr_insert = $dbh->prepare("insert into applog_warning(datetime,host,msg) values('$time_now_str','$host','$msg')");
            $sqr_insert->execute();
            $sqr_insert->finish();

            my $sqr_select = $dbh->prepare("select max(id) from applog_warning");
            $sqr_select->execute();
            my $ref_select = $sqr_select->fetchrow_hashref();
            my $last_id = $ref_select->{"max(id)"};
            $sqr_select->finish();

            if(exists $sended_mail{$msg})
            {
                my $sqr_update = $dbh->prepare("update applog_warning set mail_status=3 where id=$last_id");
                $sqr_update->execute();
                $sqr_update->finish();
            }
            elsif($mail_alarm == 0)
            {
                my $sqr_update = $dbh->prepare("update applog_warning set mail_status=0 where id=$last_id");
                $sqr_update->execute();
                $sqr_update->finish();
            }
            else
            {
                my $sqr_select = $dbh->prepare("select email from member where uid IN(select memberid from snmp_alert_user a left join snmp_alert b on a.snmp_alert_id=b.seq where (b.groupid=(select groupid from servers where device_ip='$host') or b.groupid=0) and b.enable=1) and email != ''");
                $sqr_select->execute();
                while($ref_select = $sqr_select->fetchrow_hashref())
                {
                    my $email = $ref_select->{"email"};
                    if(defined $email)
                    {
                        my $warning_msg;
                        if(defined $instruction)
                        {
                            $warning_msg = "APP告警服务器:$host 说明:$instruction 消息:$msg\n";
                        }
                        else
                        {
                            $warning_msg = "APP告警服务器:$host $msg\n";
                        }

                        unless(defined $mail_msg{$email})
                        {
                            my @tmp = ($warning_msg, "($last_id");
                            $mail_msg{$email} = \@tmp;
                        }
                        else
                        {
                            $mail_msg{$email}->[0] .= $warning_msg;
                            $mail_msg{$email}->[1] .= ",$last_id";
                        }
                    }
                }
                $sqr_select->finish();
            }

            if(exists $sended_sms{$msg})
            {
                my $sqr_update = $dbh->prepare("update applog_warning set sms_status=3 where id=$last_id");
                $sqr_update->execute();
                $sqr_update->finish();
            }
            elsif($sms_alarm == 0)
            {
                my $sqr_update = $dbh->prepare("update applog_warning set sms_status=0 where id=$last_id");
                $sqr_update->execute();
                $sqr_update->finish();
            }
            else
            {
                my $sqr_select = $dbh->prepare("select mobilenum from member where uid IN(select memberid from snmp_alert_user a left join snmp_alert b on a.snmp_alert_id=b.seq where (b.groupid=(select groupid from servers where device_ip='$host') or b.groupid=0) and b.enable=1) and mobilenum != ''");
                $sqr_select->execute();
                while($ref_select = $sqr_select->fetchrow_hashref())
                {
                    my $mobilenum = $ref_select->{"mobilenum"};
                    if(defined $mobilenum)
                    {
                        my $warning_msg;
                        if(defined $instruction)
                        {
                            $warning_msg = "APP告警服务器:$host 说明:$instruction 消息:$msg\n";
                        }
                        else
                        {
                            $warning_msg = "APP告警服务器:$host $msg\n";
                        }

                        unless(defined $sms_msg{$mobilenum})
                        {
                            my @tmp = ($warning_msg, "($last_id");
                            $sms_msg{$mobilenum} = \@tmp;
                        }
                        else
                        {
                            $sms_msg{$mobilenum}->[0] .= $warning_msg;
                            $sms_msg{$mobilenum}->[1] .= ",$last_id";
                        }
                    }
                }
                $sqr_select->finish();
            }
        }
    }
}

sub init_warning
{
    my $sqr_select = $dbh->prepare("select msg,instruction,mail_alarm,sms_alarm from applog_config");
    $sqr_select->execute();
    while(my $ref_select = $sqr_select->fetchrow_hashref())
    {
        my $mail_alarm = $ref_select->{"mail_alarm"};
        my $sms_alarm = $ref_select->{"sms_alarm"};
        my $instruction = $ref_select->{"instruction"};
        my $msg = $ref_select->{"msg"};
        unless(defined $msg)
        {
            $msg = "NULL";
        }

        unless(exists $warning_list{$msg})
        {
            my @tmp=($mail_alarm,$sms_alarm,$instruction);
            $warning_list{$msg} = \@tmp;
        }
    }
    $sqr_select->finish();
}

sub init_sended_info
{
    my $sqr_select = $dbh->prepare("select msg from applog_warning where datetime>=('$time_now_str'-interval $send_interval minute) and mail_status=1");
    $sqr_select->execute();
    while(my $ref_select = $sqr_select->fetchrow_hashref())
    {
        my $msg = $ref_select->{"msg"};
        unless(exists $sended_mail{$msg})
        {
            $sended_mail{$msg} = 1;
        }
    }
    $sqr_select->finish();

    $sqr_select = $dbh->prepare("select msg from applog_warning where datetime>=('$time_now_str'-interval $send_interval minute) and sms_status=1");
    $sqr_select->execute();
    while(my $ref_select = $sqr_select->fetchrow_hashref())
    {
        my $msg = $ref_select->{"msg"};
        unless(exists $sended_sms{$msg})
        {
            $sended_sms{$msg} = 1;
        }
    }
    $sqr_select->finish();
}

sub is_warning
{
    my($msg) = @_;

	if(exists $warning_list{"NULL"})
    {
        my $ref = $warning_list{"NULL"};
        return ($ref->[0],$ref->[1],$ref->[2]);
    }
	else
	{
		foreach my $regex(keys %warning_list)
		{
			if($msg =~ /$regex/)
            {
                my $ref = $warning_list{$regex};
                return ($ref->[0],$ref->[1],$ref->[2]);
            }
		}
		return (0,0,undef);
	}
}

sub send_mail 
{   
    my($mailto,$subject,$msg,$mailserver,$mailfrom,$mailpwd) = @_;
    
#   print "$mailto\n$msg\n";
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
#   print "$mobile_tel\n$msg\n";
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
