#!/usr/bin/perl
use warnings;
use strict;
use DBI;
use DBD::mysql;
use RRDs;
use Crypt::CBC;
use MIME::Base64;
use POSIX qw/ceil floor/;

our $debug = 1;
our($mysql_user,$mysql_passwd) = &get_local_mysql_config();
our $dbh=DBI->connect("DBI:mysql:database=audit_sec;host=localhost;mysql_connect_timeout=5",$mysql_user,$mysql_passwd,{RaiseError=>1});

our $utf8 = $dbh->prepare("set names utf8");
$utf8->execute();
$utf8->finish();

our $time_now_utc = time;
my($min,$hour,$mday,$mon,$year) = (localtime $time_now_utc)[1..5];
($min,$hour,$mday,$mon,$year) = (sprintf("%02d", $min),sprintf("%02d", $hour),sprintf("%02d", $mday),sprintf("%02d", $mon + 1),$year+1900);
our $time_now_str = "$year$mon$mday$hour$min"."00";

my $ssh_conn = int(`ps -ef | grep -v 'grep' | grep -c 'ssh-audit'`) -1;
if($ssh_conn =~ /^[+-]{0,1}[\d\.]+$/)
{
	$ssh_conn = $ssh_conn < 0 ? 0 : $ssh_conn;
	$ssh_conn = ceil($ssh_conn/2);
	&normal_insert($ssh_conn,'ssh并发数');
	&update_rrd($ssh_conn,'ssh并发数');
	&warning_func($ssh_conn,'ssh并发数');
}

my $telnet_conn = int(`ps -ef | grep -v 'grep' | grep -c 'telnet'`) -1;
if($telnet_conn =~ /^[+-]{0,1}[\d\.]+$/)
{
	$telnet_conn = $telnet_conn < 0 ? 0 : $telnet_conn;
	&normal_insert($telnet_conn,'telnet并发数');
	&update_rrd($telnet_conn,'telnet并发数');
	&warning_func($telnet_conn,'telnet并发数');
}

my $graph_conn = int(`ps -ef | grep -v 'grep' | grep -c 'Freesvr_RDP'`) -1;
if($graph_conn =~ /^[+-]{0,1}[\d\.]+$/)
{
	$graph_conn = $graph_conn < 0 ? 0 : $graph_conn;
	&normal_insert($graph_conn,'图形会话并发数');
	&update_rrd($graph_conn,'图形会话并发数');
	&warning_func($graph_conn,'图形会话并发数');
}

my $ftp_conn = int(`ps -ef | grep -v 'grep' | grep -c 'ftp-audit'`) -1;
if($ftp_conn =~ /^[+-]{0,1}[\d\.]+$/)
{
	$ftp_conn = $ftp_conn < 0 ? 0 : $ftp_conn;
	&normal_insert($ftp_conn,'ftp连接数');
	&update_rrd($ftp_conn,'ftp连接数');
	&warning_func($ftp_conn,'ftp连接数');
}

my $db_conn = int(`ps -ef | grep -v 'grep' | grep -c 'freesvr_pcap_audit.pl'`);
if($db_conn =~ /^[\d\.]+$/)
{
	&normal_insert($db_conn,'数据库并发数');
	&update_rrd($db_conn,'数据库并发数');
	&warning_func($db_conn,'数据库并发数');
}

my $cpu = `/usr/bin/top -b -n 2 | grep -E -i '^cpu'`;
foreach my $line(split /\n/,$cpu)
{   
	if($line =~ /(\d+\.\d+)%id/i || $line =~ /(\d+\.\d+)\s*id/i)
	{
		$cpu = $line;
	}
}   

if($cpu =~ /(\d+\.\d+)%id/i || $cpu =~ /(\d+\.\d+)\s*id/i) {$cpu = $1;}
if($cpu =~ /^[\d\.]+$/)
{
	$cpu = 100 - $cpu;
	$cpu = floor($cpu*100)/100;
	&normal_insert($cpu,'cpu');
	&update_rrd($cpu,'cpu');
	&warning_func($cpu,'cpu');
}

my $memory = `free | grep -i 'mem'`;
my($total,$used,$buffers,$cache) = (split /\s+/,$memory)[1,2,5,6];
if($total =~ /^[\d\.]+$/ && $used =~ /^[\d\.]+$/ && $cache =~ /^[\d\.]+$/ && $buffers =~ /^[\d\.]+$/)
{
	$memory = ceil(($used-$buffers-$cache)/$total*100);
	&normal_insert($memory,'memory');
	&update_rrd($memory,'memory');
	&warning_func($memory,'memory');
}

my $swap = `free | grep -i 'swap'`;
($total,$used) = (split /\s+/,$swap)[1,2];
if($total =~ /^[\d\.]+$/ && $used =~ /^[\d\.]+$/)
{
	$swap = ceil($used/$total*100);
	&normal_insert($swap,'swap');
	&update_rrd($swap,'swap');
	&warning_func($swap,'swap');
}

my $disk = `df | grep '/\$'`;
$disk = (split /\s+/,$disk)[4];
if($disk =~ /(\d+)%/){$disk = $1;}
if($disk =~ /^[\d\.]+$/)
{
	&normal_insert($disk,'disk');
	&update_rrd($disk,'disk');
	&warning_func($disk,'disk');
}

my @mysql_linknums = split /\n/,`mysqladmin processlist`;
my $mysql_linknum = 0;
foreach(@mysql_linknums)
{
	if($_ =~ /^\+/){next;}
	my $temp = (split /\|/,$_)[1];
	if($temp =~ /\d+/){++$mysql_linknum;}
}
if($mysql_linknum =~ /^[\d\.]+$/)
{
	&normal_insert($mysql_linknum,'mysql连接数');
	&update_rrd($mysql_linknum,'mysql连接数');
	&warning_func($mysql_linknum,'mysql连接数');
}

my $http_link = int(`netstat -an | grep 443 | grep -c ESTABLISHED`);
if($http_link =~ /^[\d\.]+$/)
{
	&normal_insert($http_link,'http连接数');
	&update_rrd($http_link,'http连接数');
	&warning_func($http_link,'http连接数');
}

my $tcp_link = int(`netstat -tn | grep -c ESTABLISHED`);
if($tcp_link =~ /^[\d\.]+$/)
{
	&normal_insert($tcp_link,'tcp连接数');
	&update_rrd($tcp_link,'tcp连接数');
	&warning_func($tcp_link,'tcp连接数');
}

&local_eth_process("eth0");
&local_eth_process("eth1");

&set_nan_val();

sub local_eth_process
{
	my($eth) = @_;

	my $eth_in_now = undef;
	my $eth_in_last = undef;
	my $cache_in_exist = 0;
	my $in_exist = 0;

	my $eth_out_now = undef;
	my $eth_out_last = undef;
	my $cache_out_exist = 0;
	my $out_exist = 0;

	my $eth_info = `/sbin/ifconfig $eth 2>&1| grep -i 'RX byte'`;
    if(defined $eth_info && !($eth_info =~ /^\s*$/))
    {
        if(defined $eth_info && $eth_info =~ /RX\s*bytes\s*:\s*(\d+)/i){$eth_in_now = $1*8;}
        if(defined $eth_info && $eth_info =~ /TX\s*bytes\s*:\s*(\d+)/i){$eth_out_now = $1*8;}
    }
    else
    {
        my $in_eth_info = `/sbin/ifconfig $eth 2>&1| grep -i 'RX.*byte'`;
        my $out_eth_info = `/sbin/ifconfig $eth 2>&1| grep -i 'TX.*byte'`;
        if(defined $in_eth_info && $in_eth_info =~ /RX.*bytes\s*(\d+)/i){print "$1\n";$eth_in_now = $1*8;}
        if(defined $out_eth_info && $out_eth_info =~ /TX.*bytes\s*(\d+)/i){$eth_out_now = $1*8;}
    }

    my $sqr_select = $dbh->prepare("select count(*) from local_status_cache where type = '${eth}_in_bitRate'");
    $sqr_select->execute();
    my $ref_select = $sqr_select->fetchrow_hashref();
    $cache_in_exist = $ref_select->{"count(*)"};
    $sqr_select->finish();

	$sqr_select = $dbh->prepare("select count(*) from local_status where type = '${eth}_in_bitRate'");
	$sqr_select->execute();
	$ref_select = $sqr_select->fetchrow_hashref();
	$in_exist = $ref_select->{"count(*)"};
	$sqr_select->finish();

	$sqr_select = $dbh->prepare("select value from local_status_cache where type = '${eth}_in_bitRate'");
	$sqr_select->execute();
	$ref_select = $sqr_select->fetchrow_hashref();
	my $value = $ref_select->{"value"};
	if(defined $value)
	{
		$eth_in_last = $value;
	}
	$sqr_select->finish();

	$sqr_select = $dbh->prepare("select count(*) from local_status_cache where type = '${eth}_out_bitRate'");
	$sqr_select->execute();
	$ref_select = $sqr_select->fetchrow_hashref();
	$cache_out_exist = $ref_select->{"count(*)"};
	$sqr_select->finish();

	$sqr_select = $dbh->prepare("select count(*) from local_status where type = '${eth}_out_bitRate'");
	$sqr_select->execute();
	$ref_select = $sqr_select->fetchrow_hashref();
	$out_exist = $ref_select->{"count(*)"};
	$sqr_select->finish();

	$sqr_select = $dbh->prepare("select value from local_status_cache where type = '${eth}_out_bitRate'");
	$sqr_select->execute();
	$ref_select = $sqr_select->fetchrow_hashref();
	$value = $ref_select->{"value"};
	if(defined $value)
	{
		$eth_out_last = $value;
	}
	$sqr_select->finish();

	if(defined $eth_in_now)
	{
		my $cmd;

		if($in_exist == 0)
		{
			$cmd = "insert into local_status (datetime,type) values ('$time_now_str','${eth}_in_bitRate')";
		}
		else
		{
			$cmd = "update local_status set value = null, datetime = '$time_now_str' where type = '${eth}_in_bitRate'";
		}

		my $sqr_update = $dbh->prepare("$cmd");
		$sqr_update->execute();
		$sqr_update->finish();

		if($cache_in_exist == 0)
		{
			$cmd = "insert into local_status_cache (datetime,type,value) values ('$time_now_str','${eth}_in_bitRate',$eth_in_now)";
			&update_rrd(-100,'${eth}_in_bitRate');
		}
		else
		{
			$cmd = "update local_status_cache set datetime = '$time_now_str',value = $eth_in_now where type = '${eth}_in_bitRate'";
		}
		$sqr_update = $dbh->prepare("$cmd");
		$sqr_update->execute();
		$sqr_update->finish();
	}
	else
	{
		if($in_exist != 0)
		{
			$sqr_select = $dbh->prepare("select rrdfile from local_status where type = '${eth}_in_bitRate'");
			$sqr_select->execute();
			$ref_select = $sqr_select->fetchrow_hashref();
			my $file = $ref_select->{"rrdfile"};
			$sqr_select->finish();

			if(-e $file)
			{
				unlink $file;
			}

			my $sqr_delete = $dbh->prepare("delete from local_status where type = '${eth}_in_bitRate'");
			$sqr_delete->execute();
			$sqr_delete->finish();

			$sqr_delete = $dbh->prepare("delete from local_status_cache where type = '${eth}_in_bitRate'");
			$sqr_delete->execute();
			$sqr_delete->finish();

			&warning_func(-100,"${eth}_in_bitRate");

			if($debug == 1)
			{
				print "${eth}_in_bitRate 无法取到值, 关闭\n";
			}
		}
	}

	if(defined $eth_out_now)
	{
		my $cmd;

		if($out_exist == 0)
		{
			$cmd = "insert into local_status (datetime,type) values ('$time_now_str','${eth}_out_bitRate')";
		}
		else
		{
			$cmd = "update local_status set value = null, datetime = '$time_now_str' where type = '${eth}_out_bitRate'";
		}

		my $sqr_update = $dbh->prepare("$cmd");
		$sqr_update->execute();
		$sqr_update->finish();

		$sqr_update = $dbh->prepare("update local_status set value = null, datetime = '$time_now_str' where type = '${eth}_out_bitRate'");
		$sqr_update->execute();
		$sqr_update->finish();

		if($cache_out_exist == 0)
		{
			$cmd = "insert into local_status_cache (datetime,type,value) values ('$time_now_str','${eth}_out_bitRate',$eth_out_now)";
			&update_rrd(-100,'${eth}_out_bitRate');
		}
		else
		{
			$cmd = "update local_status_cache set datetime = '$time_now_str',value = $eth_out_now where type = '${eth}_out_bitRate'";
		}
		$sqr_update = $dbh->prepare("$cmd");
		$sqr_update->execute();
		$sqr_update->finish();
	}
	else
	{
		if($out_exist != 0)
		{
			$sqr_select = $dbh->prepare("select rrdfile from local_status where type = '${eth}_out_bitRate'");
			$sqr_select->execute();
			$ref_select = $sqr_select->fetchrow_hashref();
			my $file = $ref_select->{"rrdfile"};
			$sqr_select->finish();

			if(-e $file)
			{
				unlink $file;
			}

			my $sqr_delete = $dbh->prepare("delete from local_status where type = '${eth}_out_bitRate'");
			$sqr_delete->execute();
			$sqr_delete->finish();

			$sqr_delete = $dbh->prepare("delete from local_status_cache where type = '${eth}_out_bitRate'");
			$sqr_delete->execute();
			$sqr_delete->finish();

			&warning_func(-100,"${eth}_out_bitRate");

			if($debug == 1)
			{
				print "${eth}_out_bitRate 无法取到值, 关闭\n";
			}
		}
	}

	if(defined $eth_in_now && defined $eth_in_last)
	{
		my $eth_in_rate = ($eth_in_now-$eth_in_last)/300;
		$eth_in_rate = floor($eth_in_rate*100)/100;
		&normal_insert($eth_in_rate,"${eth}_in_bitRate");
		&update_rrd($eth_in_rate,"${eth}_in_bitRate");
		&warning_func($eth_in_rate,"${eth}_in_bitRate");
	}

	if(defined $eth_out_now && defined $eth_out_last)
	{
		my $eth_out_rate = ($eth_out_now-$eth_out_last)/300;
		$eth_out_rate = floor($eth_out_rate*100)/100;
		&normal_insert($eth_out_rate,"${eth}_out_bitRate");
		&update_rrd($eth_out_rate,"${eth}_out_bitRate");
		&warning_func($eth_out_rate,"${eth}_out_bitRate");
	}
}

sub normal_insert
{
	my($value,$type) = @_;

	my $sqr_select = $dbh->prepare("select count(*) from local_status where type = '$type'");
	$sqr_select->execute();
	my $ref_select = $sqr_select->fetchrow_hashref();
	my $type_num = $ref_select->{"count(*)"};
	$sqr_select->finish();

	if($type_num == 0)
	{
		my $sqr_insert = $dbh->prepare("insert into local_status (type) values ('$type')");
		$sqr_insert->execute();
		$sqr_insert->finish();

		$sqr_select = $dbh->prepare("select enable from local_status where type = '$type'");
		$sqr_select->execute();
		$ref_select = $sqr_select->fetchrow_hashref();
		my $enable = $ref_select->{"enable"};
		$sqr_select->finish();

		if($enable != 1)
		{
			if($debug == 1)
			{
				my $sqr_update = $dbh->prepare("update local_status set enable = 1 where type = '$type'");       
				$sqr_update->execute();
				$sqr_update->finish();

				$sqr_update = $dbh->prepare("update local_status set value = $value, datetime = '$time_now_str' where type = '$type'");
				$sqr_update->execute();
				$sqr_update->finish();
			}
		}
		else
		{
			my $sqr_update = $dbh->prepare("update local_status set value = $value, datetime = '$time_now_str' where type = '$type'");
			$sqr_update->execute();
			$sqr_update->finish();
		}
	}
	else
	{
		$sqr_select = $dbh->prepare("select enable from local_status where type = '$type'");
		$sqr_select->execute();
		$ref_select = $sqr_select->fetchrow_hashref();
		my $enable = $ref_select->{"enable"};
		$sqr_select->finish();

		if($enable == 1)
		{
			my $sqr_update = $dbh->prepare("update local_status set value = $value, datetime = '$time_now_str' where type = '$type'");
			$sqr_update->execute();
			$sqr_update->finish();
		}
		else
		{
			my $sqr_update = $dbh->prepare("update local_status set value = null, datetime = null where type = '$type'");
			$sqr_update->execute();
			$sqr_update->finish();
		}
	}
}

sub warning_func
{
	my($value,$type) = @_;
	my $mail_alarm_status = -1;
	my $sms_alarm_status = -1;
	my $sms_out_interval = 0;               #短信 是否超过时间间隔
	my $mail_out_interval = 0;              #邮件 是否超过时间间隔

	my $sqr_select = $dbh->prepare("select mail_alarm,sms_alarm,highvalue,lowvalue,unix_timestamp(mail_last_sendtime),unix_timestamp(sms_last_sendtime),send_interval from local_status where type = '$type'");
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
		my $sqr_insert = $dbh->prepare("insert into local_status_warning_log (type,datetime,mail_status,sms_status,value,context) values ('$type','$time_now_str',$mail_alarm_status,$sms_alarm_status,$value,'本机 $type 无法得到值')");
		$sqr_insert->execute();
		$sqr_insert->finish();
	}
	elsif(defined $highvalue && defined $lowvalue && ($value > $highvalue || $value < $lowvalue))
	{
		my $thold;

		my $tmp_context = "";
		if($value > $highvalue)
		{
			$thold = $highvalue;
			$tmp_context = "大于最大值 $highvalue";
		}
		else
		{
			$thold = $lowvalue;
			$tmp_context = "小于最小值 $lowvalue";
		}

		my $sqr_insert = $dbh->prepare("insert into local_status_warning_log (type,datetime,mail_status,sms_status,value,thold,context) values ('$type','$time_now_str',$mail_alarm_status,$sms_alarm_status,$value,$thold,'本机 $type 超值, 当前值 $value $tmp_context')");
		$sqr_insert->execute();
		$sqr_insert->finish();
	}
}

sub update_rrd
{
	my($value,$type) = @_;

	if(!defined $value || $value < 0)
	{
		$value = 'U';
	}

	my $sqr_select = $dbh->prepare("select enable,rrdfile from local_status where type = '$type'");
	$sqr_select->execute();
	my $ref_select = $sqr_select->fetchrow_hashref();
	my $enable = $ref_select->{"enable"};
	my $rrdfile = $ref_select->{"rrdfile"};
	$sqr_select->finish();

	my $start_time = time;
	$start_time = (floor($start_time/300))*300;

	my $dir = "/opt/freesvr/nm/localhost_status";
	if(! -e $dir)
	{
		mkdir $dir,0755;
	}

	my $file = $dir."/$type.rrd";

	unless(defined $enable && $enable == 1)
	{
		unless(defined $rrdfile && -e $rrdfile && $rrdfile eq $file)
		{
			if(defined $rrdfile && -e $rrdfile)
			{
				unlink $rrdfile;
				my $sqr_update = $dbh->prepare("update local_status set rrdfile = null where type = '$type'");
				$sqr_update->execute();
				$sqr_update->finish();
				return;
			}
		}
	}

	if(! -e $file)
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
		my $sqr_update = $dbh->prepare("update local_status set rrdfile = '$file' where type = '$type'");
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

sub set_nan_val
{
	my @type_arr = ('ssh并发数',
			'telnet并发数',
			'图形会话并发数',
			'ftp连接数',
			'数据库并发数',
			'cpu',
			'memory',
			'swap',
			'disk',
			'mysql连接数',
			'http连接数',
			'tcp连接数',
			'eth0_in_bitRate',
			'eth0_out_bitRate',
			);

	foreach my $type(@type_arr)
	{
		my $sqr_select = $dbh->prepare("select count(*) from local_status where type = '$type'");
		$sqr_select->execute();
		my $ref_select = $sqr_select->fetchrow_hashref();
		my $num = $ref_select->{"count(*)"};
		if($num == 0)
		{
			&normal_insert(-100,$type);
			&update_rrd(-100,$type);
			&warning_func(-100,$type);

			if($debug == 1)
			{
				print "本机 $type 没有取到值\n";
			}
		}
		$sqr_select->finish();
	}

	my $sqr_select = $dbh->prepare("select seq,type from local_status where datetime < '$time_now_str'");
	$sqr_select->execute();
	while(my $ref_select = $sqr_select->fetchrow_hashref())
	{
		my $seq = $ref_select->{"seq"};
		my $type = $ref_select->{"type"};

		&normal_insert(-100,$type);
		&update_rrd(-100,$type);
		&warning_func(-100,$type);

		if($debug == 1)
		{
			print "本机 $type 没有取到值\n";
		}
	}
	$sqr_select->finish();

	$sqr_select = $dbh->prepare("select max(value) from local_status_warning_log where datetime = '$time_now_str'");
	$sqr_select->execute();
	while(my $ref_select = $sqr_select->fetchrow_hashref())
	{
		my $value = $ref_select->{"max(value)"};
		if(defined $value && $value < 0)
		{
			my $mail_alarm_status = 0;
			my $sms_alarm_status = 0;

			my $sqr_select_status = $dbh->prepare("select mail_status,sms_status from local_status_warning_log where datetime = '$time_now_str'");
			$sqr_select_status->execute();
			while(my $ref_select_status = $sqr_select_status->fetchrow_hashref())
			{
				my $mail_status = $ref_select_status->{"mail_status"};
				my $sms_status = $ref_select_status->{"sms_status"};

				if($mail_status != 0 && $mail_alarm_status != -1)
				{
					$mail_alarm_status = $mail_status;
				}

				if($sms_status != 0 && $sms_alarm_status != -1)
				{
					$sms_alarm_status = $sms_status;
				}
			}
			$sqr_select_status->finish();

			my $sqr_delete = $dbh->prepare("delete from local_status_warning_log where datetime = '$time_now_str'"); 
			$sqr_delete->execute();
			$sqr_delete->finish();

			my $sqr_insert = $dbh->prepare("insert into local_status_warning_log (datetime,mail_status,sms_status,value,context) values ('$time_now_str',$mail_alarm_status,$sms_alarm_status,-100,'本机信息 无法得到值')");
			$sqr_insert->execute();
			$sqr_insert->finish();
		}
	}
	$sqr_select->finish();
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
