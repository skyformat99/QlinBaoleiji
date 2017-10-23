#!/usr/bin/perl
use warnings;
use strict;
use DBI;
use DBD::mysql;
use RRDs;
use Crypt::CBC;
use MIME::Base64;
use POSIX qw/ceil floor/;

our($mysql_user,$mysql_passwd) = &get_local_mysql_config();
our $cipher = Crypt::CBC->new( -key => 'freesvr', -cipher => 'Blowfish', -iv => 'freesvr1', -header => 'none');
our $remote_mysql_user = "freesvr";
our $remote_mysql_passwd = "zT6fYu8HhLQ=";
$remote_mysql_passwd = decode_base64($mysql_passwd);
$remote_mysql_passwd = $cipher->decrypt($mysql_passwd);

our $rrd_prefix = "/opt/freesvr/nm/status_monitor";

our $time_now_utc = time;
our($min,$hour,$mday,$mon,$year) = (localtime $time_now_utc)[1..5];
($min,$hour,$mday,$mon,$year) = (sprintf("%02d", $min),sprintf("%02d", $hour),sprintf("%02d", $mday),sprintf("%02d", $mon + 1),$year+1900);
our $time_now_str = "$year$mon$mday$hour$min"."00";

our %config_hash;

unless($rrd_prefix =~ /\/$/)
{
	$rrd_prefix .= "/";
}

unless(-e $rrd_prefix)
{
	`mkdir -p $rrd_prefix`;
}

&init_config();

foreach my $host(keys %config_hash)
{
	my $remote_dbh = &create_connection($host,$config_hash{$host});

	my $dbh=DBI->connect("DBI:mysql:database=audit_nm;host=localhost;mysql_connect_timeout=5",$mysql_user,$mysql_passwd,{RaiseError=>1});
	my $utf8 = $dbh->prepare("set names utf8");
	$utf8->execute(); 
	$utf8->finish();

	unless(defined $remote_dbh)
	{
		&insert_into_table($dbh,$host,undef,-100);
		&update_rrd($dbh,$host,undef,-100);
		&warning_func_host($dbh,$host,'mysql 无法连接');
		$dbh->disconnect();
		next;
	}

	$utf8 = $remote_dbh->prepare("set names utf8");
	$utf8->execute();
	$utf8->finish();

	my $sqr_select = $remote_dbh->prepare("select UNIX_TIMESTAMP(datetime),type,value from local_status");
	$sqr_select->execute();
	while(my $ref_select = $sqr_select->fetchrow_hashref())
	{            
		my $datatime = $ref_select->{"UNIX_TIMESTAMP(datetime)"};
		my $type = $ref_select->{"type"};
		my $value = $ref_select->{"value"};

		if(abs($datatime - $time_now_utc) < 600)
		{
			&insert_into_table($dbh,$host,$type,$value);
			&update_rrd($dbh,$host,$type,$value);
			&warning_func_type($dbh,$host,$type,$value);
		}
		else
		{
			&insert_into_table($dbh,$host,undef,-100);
			&update_rrd($dbh,$host,undef,-100);
			&warning_func_host($dbh,$host,'local_status 表中时间与本机时间间隔大于5分钟');
			last;
		}
	}
	$sqr_select->finish();

	$dbh->disconnect();
	$remote_dbh->disconnect();
}

defined(my $pid = fork) or die "cannot fork:$!";
unless($pid){
#	exec "/home/wuxiaolong/3_status/snmp_ssh_warning.pl";
}
exit;

sub init_config
{
	my $dbh=DBI->connect("DBI:mysql:database=audit_nm;host=localhost;mysql_connect_timeout=5",$mysql_user,$mysql_passwd,{RaiseError=>1});
	my $utf8 = $dbh->prepare("set names utf8");
	$utf8->execute(); 
	$utf8->finish();

	my $sqr_select = $dbh->prepare("select host,port from device_mysql_info");
	$sqr_select->execute();
	while(my $ref_select = $sqr_select->fetchrow_hashref())
	{            
		my $host = $ref_select->{"host"};
		my $port = $ref_select->{"port"};

#		unless(defined $host && $host =~ /(\d{1,3}\.){3}\d{1,3}/)
		unless(defined $host)
		{
			next;
		}

		my @temp = ($port);
		unless(exists $config_hash{$host})
		{
			$config_hash{$host} = \@temp;
		}
	}
	$sqr_select->finish();
	$dbh->disconnect();
}

sub create_connection
{
	my($host,$arr_ref) = @_;
	my $port = $arr_ref->[0];

	my $dsn = "DBI:mysql:database=audit_sec;host=$host";
	if(defined $port && $port > 0)
	{
		$dsn .= ";port=$port";
	}
	$dsn .= ";mysql_connect_timeout=5";

	my $remote_dbh = DBI->connect("$dsn",$remote_mysql_user,$remote_mysql_passwd,{RaiseError=>0});

	return $remote_dbh;
}

sub insert_into_table
{
	my($dbh,$host,$type,$value) = @_;

	unless(defined $type)
	{
		my $sqr_select = $dbh->prepare("select count(*) from device_status where host = '$host'");
		$sqr_select->execute();
		my $ref_select = $sqr_select->fetchrow_hashref();
		my $host_num = $ref_select->{"count(*)"};
		$sqr_select->finish();

		if($host_num == 0)
		{
			my $sqr_insert = $dbh->prepare("insert into device_status (host,datetime,value) values ('$host','$time_now_str',$value)");
			$sqr_insert->execute();
			$sqr_insert->finish();
		}
		else
		{
			my $sqr_update = $dbh->prepare("update device_status set value = $value,datetime='$time_now_str' where host = '$host'");
			$sqr_update->execute();
			$sqr_update->finish();
		}

		return;
	}

	my $sqr_delete = $dbh->prepare("delete from device_status where host = '$host' and type is null");
	$sqr_delete->execute();
	$sqr_delete->finish();

	my $sqr_select = $dbh->prepare("select count(*) from device_status where host = '$host' and type = '$type'");
	$sqr_select->execute();
	my $ref_select = $sqr_select->fetchrow_hashref();
	my $type_num = $ref_select->{"count(*)"};
	$sqr_select->finish();

	if($type_num == 0)
	{
		my $sqr_insert = $dbh->prepare("insert into device_status (host,datetime,type) values ('$host','$time_now_str','$type')");
		$sqr_insert->execute();
		$sqr_insert->finish();
	}

	if(defined $value)
	{
		my $sqr_update = $dbh->prepare("update device_status set value = $value,datetime='$time_now_str' where host = '$host' and type = '$type'");
		$sqr_update->execute();
		$sqr_update->finish();
	}
	else
	{
		my $sqr_update = $dbh->prepare("update device_status set value = null,datetime='$time_now_str' where host = '$host' and type = '$type'");
		$sqr_update->execute();
		$sqr_update->finish();
	}
}

sub update_rrd
{
	my($dbh,$host,$type,$value) = @_;

	unless(defined $value)
	{
		return;
	}

	if(!defined $value || $value < 0)
	{
		$value = 'U';
	}

	my $start_time = (floor($time_now_utc/300))*300;

	unless(defined $type)
	{
		my $sqr_select = $dbh->prepare("select count(*) from device_status where host = '$host'");
		$sqr_select->execute();
		my $ref_select = $sqr_select->fetchrow_hashref();
		my $host_num = $ref_select->{"count(*)"};
		$sqr_select->finish();

		if($host_num != 0)
		{
			$sqr_select = $dbh->prepare("select type,rrdfile from device_status where host = '$host'");
			$sqr_select->execute();
			while(my $ref_select = $sqr_select->fetchrow_hashref())
			{
				my $type = $ref_select->{"type"};
				my $rrdfile = $ref_select->{"rrdfile"};

				unless(defined $type && defined $rrdfile)
				{
					next;
				}

				unless(-e $rrdfile)
				{
					my $sqr_update = $dbh->prepare("update device_status set rrdfile = null where host = '$host' and type = '$type'");
					$sqr_update->execute();
					$sqr_update->finish();
				}
				else
				{
					RRDs::update(
							$rrdfile,
							'-t', 'val',
							'--', join(':', "$start_time", "$value"),
							);
				}
			}
			$sqr_select->finish();
		}

		return;
	}

	my $sqr_select = $dbh->prepare("select rrdfile from device_status where host = '$host' and type = '$type'");
	$sqr_select->execute();
	my $ref_select = $sqr_select->fetchrow_hashref();
	my $rrdfile = $ref_select->{"rrdfile"};
	$sqr_select->finish();

	my $dir = "$rrd_prefix$host";
	if(! -e $dir)
	{   
		mkdir $dir,0755;
	}

	my $file = $dir."/${host}_$type.rrd";

	unless(-e $file)
	{
		my $create_time = $start_time - 300;
		RRDs::create($file,
				'--start', "$create_time",
				'--step', '300',
				'DS:val:GAUGE:600:U:U',
				'RRA:AVERAGE:0.5:1:576',
				'RRA:AVERAGE:0.5:12:192',
				'RRA:AVERAGE:0.5:288:32',
				'RRA:MAX:0.5:1:576',
				'RRA:MAX:0.5:12:192',
				'RRA:MAX:0.5:288:32',
				'RRA:MIN:0.5:1:576',
				'RRA:MIN:0.5:12:192',
				'RRA:MIN:0.5:288:32',
				);
	}

	unless(defined $rrdfile && $rrdfile eq $file)
	{
		my $sqr_update = $dbh->prepare("update device_status set rrdfile = '$file' where type = '$type'");
		$sqr_update->execute();
		$sqr_update->finish();

		if(defined $rrdfile && -e $rrdfile)
		{
			unlink $rrdfile;
		}
	}

	RRDs::update(
			$file,
			'-t', 'val',
			'--', join(':', "$start_time", "$value"),
			);
}

sub warning_func_host
{
	my($dbh,$host,$context) = @_;

	my $mail_alarm_status = -1;
	my $sms_alarm_status = -1;
	my $sms_out_interval = 0;               #短信 是否超过时间间隔;
	my $mail_out_interval = 0;              #邮件 是否超过时间间隔;

	my $sqr_select = $dbh->prepare("select max(mail_alarm),max(sms_alarm),max(unix_timestamp(mail_last_sendtime)),max(unix_timestamp(sms_last_sendtime)),min(send_interval) from device_status where host = '$host'");
	$sqr_select->execute();
	my $ref_select = $sqr_select->fetchrow_hashref();
	my $mail_alarm = $ref_select->{"max(mail_alarm)"};
	my $sms_alarm = $ref_select->{"max(sms_alarm)"};
	my $mail_last_sendtime = $ref_select->{"max(unix_timestamp(mail_last_sendtime))"};
	my $sms_last_sendtime = $ref_select->{"max(unix_timestamp(sms_last_sendtime))"};
	my $send_interval = $ref_select->{"min(send_interval)"};
	$sqr_select->finish();

	unless(defined $mail_alarm)
	{
		$mail_alarm = 0;
	}

	unless(defined $mail_last_sendtime)
	{
		$mail_out_interval = 1;
	}
	elsif(($time_now_utc - $mail_last_sendtime) > ($send_interval * 60))
	{
		$mail_out_interval = 1;
	}

	if($mail_alarm == 1)
	{
		if($mail_out_interval == 1)
		{
			$mail_alarm_status = -1;
		}
		else
		{
			$mail_alarm_status = 3;
		}
	}
	elsif($mail_alarm == 0)
	{
		$mail_alarm_status = 0;
	}

	unless(defined $sms_alarm)
	{
		$sms_alarm = 0;
	}

	unless(defined $sms_last_sendtime)
	{
		$sms_out_interval = 1;
	}
	elsif(($time_now_utc - $sms_last_sendtime) > ($send_interval * 60))
	{
		$sms_out_interval = 1;
	}

	if($sms_alarm == 1)
	{
		if($sms_out_interval == 1)
		{
			$sms_alarm_status = -1;
		}
		else
		{
			$sms_alarm_status = 3;
		}
	}
	elsif($sms_alarm == 0)
	{
		$sms_alarm_status = 0;
	}

	my $sqr_insert = $dbh->prepare("insert into device_status_warning_log (host,datetime,mail_status,sms_status,context,status) values ('$host','$time_now_str',$mail_alarm_status,$sms_alarm_status,'$context',0)");
	$sqr_insert->execute();
	$sqr_insert->finish();
}

sub warning_func_type
{       
	my($dbh,$host,$type,$value) = @_;

	unless(defined $value)
	{
		return;
	}

	my $mail_alarm_status = -1;
	my $sms_alarm_status = -1;
	my $sms_out_interval = 0;               #短信 是否超过时间间隔;
	my $mail_out_interval = 0;              #邮件 是否超过时间间隔;

	my $sqr_select = $dbh->prepare("select mail_alarm,sms_alarm,highvalue,lowvalue,unix_timestamp(mail_last_sendtime),unix_timestamp(sms_last_sendtime),send_interval from device_status where host = '$host' and type = '$type'");
	$sqr_select->execute();
	my $ref_select = $sqr_select->fetchrow_hashref();
	my $mail_alarm = $ref_select->{"mail_alarm"};
	my $sms_alarm = $ref_select->{"sms_alarm"};
	my $highvalue = $ref_select->{"highvalue"};
	my $lowvalue = $ref_select->{"lowvalue"};
	my $mail_last_sendtime = $ref_select->{"unix_timestamp(mail_last_sendtime)"};
	my $sms_last_sendtime = $ref_select->{"unix_timestamp(sms_last_sendtime)"};
	my $send_interval = $ref_select->{"send_interval"};
	$sqr_select->finish();

	unless(defined $mail_alarm)
	{
		$mail_alarm = 0;
	}

	unless(defined $mail_last_sendtime)
	{
		$mail_out_interval = 1;
	}
	elsif(($time_now_utc - $mail_last_sendtime) > ($send_interval * 60))
	{
		$mail_out_interval = 1;
	}

	if($mail_alarm == 1)
	{
		if($mail_out_interval == 1)
		{
			$mail_alarm_status = -1;
		}
		else
		{
			$mail_alarm_status = 3;
		}
	}
	elsif($mail_alarm == 0)
	{
		$mail_alarm_status = 0;
	}

	unless(defined $sms_alarm)
	{
		$sms_alarm = 0;
	}

	unless(defined $sms_last_sendtime)
	{
		$sms_out_interval = 1;
	}
	elsif(($time_now_utc - $sms_last_sendtime) > ($send_interval * 60))
	{
		$sms_out_interval = 1;
	}

	if($sms_alarm == 1)
	{
		if($sms_out_interval == 1)
		{
			$sms_alarm_status = -1;
		}
		else
		{
			$sms_alarm_status = 3;
		}
	}
	elsif($sms_alarm == 0)
	{
		$sms_alarm_status = 0;
	}

	if($value < 0)
	{   
		my $sqr_insert = $dbh->prepare("insert into device_status_warning_log (host,type,datetime,mail_status,sms_status,value,context,status) values ('$host','$type','$time_now_str',$mail_alarm_status,$sms_alarm_status,$value,'$host $type 无法得到值',2)");
		$sqr_insert->execute();
		$sqr_insert->finish();
	}
	elsif((defined $highvalue && $value > $highvalue) || (defined $lowvalue && $value < $lowvalue))
	{
		my $thold;

		my $tmp_context = "";
		if(defined $highvalue && $value > $highvalue)
		{   
			$thold = $highvalue;
			$tmp_context = "大于最大值 $highvalue";
		}
		else
		{   
			$thold = $lowvalue;
			$tmp_context = "小于最小值 $lowvalue";
		}

		my $sqr_insert = $dbh->prepare("insert into device_status_warning_log (host,type,datetime,mail_status,sms_status,value,thold,context,status) values ('$host','$type','$time_now_str',$mail_alarm_status,$sms_alarm_status,$value,$thold,'$host $type 超值, 当前值 $value $tmp_context',2)");
		$sqr_insert->execute();
		$sqr_insert->finish();
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
