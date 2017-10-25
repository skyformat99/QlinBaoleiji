#!/usr/bin/perl
use strict;
use warnings;

use DBI;
use DBD::mysql;
use Mail::Sender;
use Encode;
use URI::Escape;
use URI::URL;
use LWP::Simple;
use Crypt::CBC;
use MIME::Base64;

our($mysql_user,$mysql_passwd) = &get_local_mysql_config();
our $dbh=DBI->connect("DBI:mysql:database=cacti;host=localhost;mysql_connect_timeout=5",$mysql_user,$mysql_passwd,{RaiseError=>1});
our($sec,$min,$hour,$mday,$mon,$year) = (localtime)[0..5];
($sec,$min,$hour,$mday,$mon,$year) = (sprintf("%02d", $sec),sprintf("%02d", $min),sprintf("%02d", $hour),sprintf("%02d", $mday),sprintf("%02d", $mon + 1),$year+1900);
our $mysql_time=int($year.$mon.$mday.$hour.$min."00");
our $send_time = "$year-$mon-$mday $hour:$min";

our $mail = $dbh->prepare("select smtpip,smtpuser,smtppwd from ossim.alert_mailsms");
$mail->execute();
our $ref_mail = $mail->fetchrow_hashref();
our $mailserver = $ref_mail->{"smtpip"};
our $mailfrom = $ref_mail->{"smtpuser"};
our $mailpwd = $ref_mail->{"smtppwd"};
$mail->finish();

our %groupmsg_hash;
our %groupip_hash;
our %ipgroup_hash;
our %mail_status;
our %fail_ip_count;
our @result;

foreach my $record(@ARGV)
{
	my ($average,$type,$rrd_id,$ip,$name,$mail_alert,$sms_alert,$graph_template_id,$thold) = split /\t/,$record;
	if($average == -1 || $average == -2)
	{
		unless(&scan($ip))
		{
			next;
		}
	}

	push @result, $record;
}

our $sqr_groupname = $dbh->prepare("select host_group_name,host_ip from ossim.host_group_reference");
$sqr_groupname->execute();
while(my $ref_groupname = $sqr_groupname->fetchrow_hashref())
{
	my $host_group_name = $ref_groupname->{"host_group_name"};
	my $host_ip = $ref_groupname->{"host_ip"};
	push @{$ipgroup_hash{$host_ip}},$host_group_name;
	push @{$groupip_hash{$host_group_name}},$host_ip;
}
$sqr_groupname->finish();

#foreach my $record(@ARGV)
foreach my $record(@result)
{
	my ($average,$type,$rrd_id,$ip,$name,$mail_alert,$sms_alert,$graph_template_id,$thold) = split /\t/,$record;
	if($mail_alert == 0){next;}
	$mail_status{$ip} = 1; 

	my $send_value = $average;
	if($type == 2)
	{
		if($send_value > 100){next;}
		$send_value = &round($send_value,2);
		$send_value .= "%";
	}	
	elsif($type == 1 || $type == 3 || $type == 11)
	{
		$send_value = int($send_value*100);
		if($send_value > 100){next;}
		$send_value = &round($send_value,2);
		$send_value .= "%";
	}
	elsif($type >=4 && $type <= 9)
	{
		$send_value = &shift_size($send_value);
	}
	else
	{
		$send_value = &switch_func($send_value,$graph_template_id);
	}


	my $sqr_hostname = $dbh->prepare("select hostname from ossim.host where ip = \"$ip\"");
	$sqr_hostname->execute();
	my $ref_hostname = $sqr_hostname->fetchrow_hashref();
	my $hostname = $ref_hostname->{"hostname"};
	$sqr_hostname->finish();

	unless(exists $ipgroup_hash{$ip})
	{
		next;
	}

	my @group_name = @{$ipgroup_hash{$ip}};
	foreach(@group_name)
	{
		unless(exists $groupmsg_hash{$_}){$groupmsg_hash{$_} = "$send_time\n";}
		unless(exists $fail_ip_count{$_}){$fail_ip_count{$_} = 0;}
		if($average == -1 || $average == -2)
		{
			++$fail_ip_count{$_};
			$groupmsg_hash{$_} .= "$hostname,$name,获取主机状态失败\n";
		}
		else {$groupmsg_hash{$_} .= "$hostname,$name,当前值:$send_value, 超过阈值\n";}

	}
}

our $subject = "监控系统告警,$send_time";

foreach my $group_name(keys %groupmsg_hash)
{
	my $failipcount = scalar(@{$groupip_hash{$group_name}});
	if($failipcount == $fail_ip_count{$group_name}){$groupmsg_hash{$group_name} = $send_time."\n所有主机状态获取失败\n";}
	my $sqr_des = $dbh->prepare("select email from ossim.users where groupmanager = \"$group_name\"");
	$sqr_des->execute();
#	print $groupmsg_hash{$group_name},"\n";
	while(my $ref_des = $sqr_des->fetchrow_hashref())
	{
		my $email = $ref_des->{"email"};
		my $status = &send_mail($email,$subject,$groupmsg_hash{$group_name},$mailserver,$mailfrom,$mailpwd);
		if($status == 2)
		{
				foreach my $ip(@{$groupip_hash{$group_name}})
				{
					$mail_status{$ip} = 2;
				}
		}
	}
	$sqr_des->finish();
}

#message
foreach my $record(@result)
{
	my ($average,$type,$rrd_id,$ip,$name,$mail_alert,$sms_alert,$graph_template_id,$thold) = split /\t/,$record;

	my $send_value = $average;
	if($type == 2)
	{
		if($send_value > 100){next;}
		$send_value = &round($send_value,2);
		$send_value .= "%";
	}
	elsif($type == 1 || $type == 3 || $type == 11)
	{
		$send_value = int($send_value*100);
		if($send_value > 100){next;}
		$send_value = &round($send_value,2);
		$send_value .= "%";
	}
	elsif($type >=4 && $type <= 9)
	{
		$send_value = &shift_size($send_value*8);
	}
	else
	{
		$send_value = &switch_func($send_value,$graph_template_id);
	}

	my $sqr_hostname = $dbh->prepare("select hostname from ossim.host where ip = \"$ip\"");
	$sqr_hostname->execute();
	my $ref_hostname = $sqr_hostname->fetchrow_hashref();
	my $hostname = $ref_hostname->{"hostname"};
	$sqr_hostname->finish();

	my $mail_flag;my $sms_flag;

	if($mail_alert == 0){$mail_flag = 0;}
	else{$mail_flag =  $mail_status{$ip};}

	if($sms_alert == 0){$sms_flag = 0;}
	else
	{
		my $msg;
		if($average == -1 || $average == -2){$msg = "$send_time\n$hostname,$name,获取主机状态失败\n";}
		else{$msg = "$send_time\n$hostname,$name,当前值:$send_value, 超过阈值\n";}

		unless(exists $ipgroup_hash{$ip})
		{
			next;
		}
		my @group = @{$ipgroup_hash{$ip}};
		foreach my $groupmanager(@group)
		{
			my $sqr_des = $dbh->prepare("select mobile from ossim.users where groupmanager = \"$groupmanager\"");
			$sqr_des->execute();
			while(my $ref_des = $sqr_des->fetchrow_hashref())
			{
				my $mobile = $ref_des->{"mobile"};
				$sms_flag = &send_msg($mobile,$msg);
			}
		}
	}

	if($sms_flag == 1 || $mail_flag == 1 )
	{
		my $sqr_updatetime = $dbh->prepare("update list_host set last_sendtime = unix_timestamp() where id = $rrd_id");
		$sqr_updatetime->execute();
		$sqr_updatetime->finish();
	}
	my $sqr_insert = $dbh->prepare("insert into listdata_log (ip,last_value,name,time,thold,mail,sms) values ('$ip',$average,'$name',$mysql_time,$thold,$mail_flag,$sms_flag)");
	$sqr_insert->execute();
	$sqr_insert->finish();
}

sub round
{
	my($value,$precision) = @_;
	return int($value*(10**$precision))/(10**$precision);
}

sub shift_size
{
	my($send_value) = @_;
	if($send_value < 1024)
	{
		$send_value = &round($send_value,2);
		$send_value .= "b";
	}
	elsif($send_value >= 1024 && $send_value < 1024*1024)
	{
		$send_value = &round(($send_value/1024),2);
		$send_value .= "Kb";
	}
	elsif($send_value >= 1024*1024 && $send_value < 1024*1024*1024)
	{
		$send_value = &round(($send_value/(1024*1024)),2);
		$send_value .= "Mb";
	}
	else
	{
		$send_value = &round(($send_value/(1024*1024*1024)),2);
		$send_value .= "Gb";
	}
	return $send_value;
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
#modify 20140122, 192.168.11.71->192.168.4.71
	my $url = "http://192.168.4.71:8080/smsServer/service.action?branch_no=10&password=010&depart_no=10001&message_type=1&batch_no=4324&priority=1&sp_no=$sp_no&mobile_type=$mobile_type&mobile_tel=$mobile_tel&message=$msg";

	$url = URI::URL->new($url); 
	
#	if(defined(get($url)))
	if(system("wget -t 1 -T 3 '$url' -O - 1>/dev/null 2>&1") == 0)
	{
		return 1;
	} 
	else
	{
		return 2;
	}
}

sub switch_func
{
	my($send_value,$template_id) = @_;
	if($template_id == 168 || $template_id == 170 || $template_id == 218 || $template_id == 182 || $template_id == 184 || $template_id == 196 || $template_id == 197 || $template_id == 198 || $template_id == 199 || $template_id == 218 || $template_id == 220 || $template_id == 222 || $template_id == 224)
	{
		$send_value = &round($send_value,0);
		$send_value .= '个';
		return $send_value;
	}
	elsif($template_id == 169 || $template_id == 171 || $template_id == 219 || $template_id == 223)
	{
		$send_value = &shift_size($send_value);
		return $send_value;
	}
	elsif($template_id == 183 || $template_id == 186 || ($template_id >= 206 && $template_id <= 217) || $template_id == 221 || $template_id == 225)
	{
		$send_value = &shift_size($send_value*1024*1024);
		return $send_value;
	}
	elsif(($template_id >= 188 && $template_id <= 193) || ($template_id >= 200 && $template_id <= 205) || $template_id == 194 || $template_id == 195)
	{
		$send_value /= 100;
		$send_value = &round($send_value,2);
		$send_value .= '%';
		return $send_value;
	}
	elsif($template_id == 37)
	{
		$send_value = &shift_size($send_value*8);
		return $send_value;
	}
	else
	{
		return &round($send_value,2);
	}
}

sub scan
{
	my($ip) = @_;
	my $flag = 0;
	my $cmd = "nmap -n -sU -p 161 $ip";
	my $nmap = `$cmd`;
	foreach my $line(split /\n/,$nmap)
	{
		if($line =~ /MAC\s*Address/i) {next;}
		if($flag == 1 && $line =~ /^$/) {last;}

		if($flag == 1)
		{
			my($port,$status) = (split /\s+/,$line)[0,1];
			$port = (split /\//,$port)[0];

			foreach my $status_str(split /\|/,$status)
			{
				if($status_str eq "open")
				{
					print "$ip,$port  :  status: $status_str\n";
					return 1;
				}
			}
		}
		elsif($line =~ /PORT\s*STATE\s*SERVICE/i)
		{
			$flag = 1;
		}
	}
	return 0;
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
