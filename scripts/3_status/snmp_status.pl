#!/usr/bin/perl
use warnings;
use strict;
use DBI;
use DBD::mysql;
use Crypt::CBC;
use MIME::Base64;
use POSIX qw/ceil floor/;

our $max_process_num = 2;
our $exist_process = 0;

our $time_now_utc = time;
our($min,$hour,$mday,$mon,$year) = (localtime $time_now_utc)[1..5];
($min,$hour,$mday,$mon,$year) = (sprintf("%02d", $min),sprintf("%02d", $hour),sprintf("%02d", $mday),sprintf("%02d", $mon + 1),$year+1900);
our $time_now_str = "$year$mon$mday$hour$min"."00";
our $send_time = "$year-$mon-$mday $hour:$min";
our $date = "$year$mon$mday";

our($mysql_user,$mysql_passwd) = &get_local_mysql_config();
our $dbh=DBI->connect("DBI:mysql:database=audit_sec;host=localhost;mysql_connect_timeout=5",$mysql_user,$mysql_passwd,{RaiseError=>1});

our $utf8 = $dbh->prepare("set names utf8");
$utf8->execute();
$utf8->finish();

our $sqr_truncate = $dbh->prepare("truncate snmp_err");
$sqr_truncate->execute();
$sqr_truncate->finish();

our @ref_ip_arr;
my $sqr_select = $dbh->prepare("select device_ip,type,snmpkey from snmp_servers where snmpstatus=1");
$sqr_select->execute();
while(my $ref_select = $sqr_select->fetchrow_hashref())
{
	my $device_ip = $ref_select->{"device_ip"};
	my $type = $ref_select->{"type"};
	my $snmpkey = $ref_select->{"snmpkey"};

	my @host = ($device_ip,$type,$snmpkey);
	push @ref_ip_arr,\@host;
}
$sqr_select->finish();
my $rc = $dbh->disconnect;

if($max_process_num > scalar @ref_ip_arr){$max_process_num = scalar @ref_ip_arr;}
while(1)
{
	if($exist_process < $max_process_num)
	{
		&fork_process();
	}
	else
	{
		while(wait())
		{
			--$exist_process;
			&fork_process();
			if($exist_process == 0)
			{
				defined(my $pid = fork) or die "cannot fork:$!";
				unless($pid){
					exec "/home/wuxiaolong/3_status/snmp_warning.pl",$time_now_str,$send_time;
				}
				exit;
			}
		}
	}
}

sub fork_process
{
	my $temp = shift @ref_ip_arr;
	unless(defined $temp){return;}
	my $pid = fork();
	if (!defined($pid))
	{
		print "Error in fork: $!";
		exit 1;
	}

	if ($pid == 0)
	{
		if($temp->[1] == 2){&linux_snmp($temp->[0],$temp->[2]);}
		elsif($temp->[1] == 4){&windows_snmp($temp->[0],$temp->[2]);}
		elsif($temp->[1] == 11){&cisco_snmp($temp->[0],$temp->[2]);}
		exit(0);
	}
	++$exist_process;
}

sub linux_snmp
{
	my($device_ip,$snmpkey) = @_;
	my $flag = 1;

	my $dbh=DBI->connect("DBI:mysql:database=audit_sec;host=localhost;mysql_connect_timeout=5",$mysql_user,$mysql_passwd,{RaiseError=>1});

	my $utf8 = $dbh->prepare("set names utf8");
	$utf8->execute();
	$utf8->finish();

	my $cpu = `snmpwalk -v 2c -c $snmpkey $device_ip .1.3.6.1.4.1.2021.11.9.0 2>&1`;

	if($cpu =~ /Timeout.*No Response from/i){return;}

	if($cpu =~ /INTEGER\s*:\s*(\d+)/i)
	{
		$cpu = $1;
	}
	&insert_into_nondisk($dbh,$device_ip,'cpu',$cpu);

	my $memtotal=0;my $memavail=0;my $memcache=0;my $membuff=0;my $swaptotal=0;my $swapavail=0;
	foreach(`snmpwalk -v 2c -c $snmpkey $device_ip .1.3.6.1.4.1.2021.4`)
	{
		if($_ =~ /memTotalReal/i && $_ =~ /INTEGER\s*:\s*(\d+)/i){$memtotal = $1;}
		if($_ =~ /memAvailReal/i && $_ =~ /INTEGER\s*:\s*(\d+)/i){$memavail = $1;}
		if($_ =~ /memCached/i && $_ =~ /INTEGER\s*:\s*(\d+)/i){$memcache = $1;}
		if($_ =~ /memBuffer/i && $_ =~ /INTEGER\s*:\s*(\d+)/i){$membuff = $1;}
		if($_ =~ /memTotalSwap/i && $_ =~ /INTEGER\s*:\s*(\d+)/i){$swaptotal = $1;}
		if($_ =~ /memAvailSwap/i && $_ =~ /INTEGER\s*:\s*(\d+)/i){$swapavail = $1;}
	}

	my $mem = floor(($memtotal-$memavail-$memcache-$membuff)/$memtotal*100);
	my $swap = floor(($swaptotal-$swapavail)/$swaptotal*100);

	&insert_into_nondisk($dbh,$device_ip,'memory',$mem);
	&insert_into_nondisk($dbh,$device_ip,'swap',$swap);

	my %disk_num;
	foreach(`snmpwalk -v 2c -c $snmpkey $device_ip 1.3.6.1.2.1.25.2`)
	{
		if($_ =~ /hrStorageDescr.(\d+).*STRING\s*:\s*(\/.*)$/i)
		{
			push @{$disk_num{$1}},$2;
		}

		if($_ =~ /hrStorageSize.(\d+).*INTEGER\s*:\s*(\d+)$/i)
		{
			if(exists $disk_num{$1})
			{
				push @{$disk_num{$1}},$2;
			}
		}
		if($_ =~ /hrStorageUsed.(\d+).*INTEGER\s*:\s*(\d+)$/i)
		{
			if(exists $disk_num{$1})
			{
				$disk_num{$1}->[1] = $2/$disk_num{$1}->[1];
				$disk_num{$1}->[1] = floor($disk_num{$1}->[1]*100);
			}
		}
	}

	foreach(keys %disk_num)
	{
		&insert_into_disk($dbh,$device_ip,$disk_num{$_}->[0],$disk_num{$_}->[1]);
	}
}

sub cisco_snmp
{
	my($device_ip,$snmpkey) = @_;

	my $dbh=DBI->connect("DBI:mysql:database=audit_sec;host=localhost;mysql_connect_timeout=5",$mysql_user,$mysql_passwd,{RaiseError=>1});

	my $utf8 = $dbh->prepare("set names utf8");
	$utf8->execute();
	$utf8->finish();

	my $cpu_num = 0;my $cpu_value = 0;
	foreach(`snmpwalk -v 2c -c $snmpkey $device_ip .1.3.6.1.4.1.9.9.109.1.1.1.1.5 2>&1`)
	{
		++$cpu_num;
	
		if($_ =~ /Timeout.*No Response from/i){return;}

		if($_ =~ /Gauge32\s*:\s*(\d+)$/i){$cpu_value += $1;}
	}
	$cpu_value = floor($cpu_value/$cpu_num);

	&insert_into_nondisk($dbh,$device_ip,'cpu',$cpu_value);

	my $mem_used = 0;my $mem_free = 0;my $mem = 0;
	foreach(`snmpwalk -v 2c -c $snmpkey $device_ip 1.3.6.1.4.1.9.9.48.1.1.1`)
	{
		if($_ =~ /\.9\.9\.48\.1\.1\.1\.5\.1/i && $_ =~ /Gauge32\s*:\s*(\d+)$/i){$mem_used = $1;}
		if($_ =~ /\.9\.9\.48\.1\.1\.1\.6\.1/i && $_ =~ /Gauge32\s*:\s*(\d+)$/i){$mem_free = $1;}
	}
	$mem = floor($mem_used/($mem_used+$mem_free)*100);
	&insert_into_nondisk($dbh,$device_ip,'memory',$mem);
}

sub windows_snmp
{
	my($device_ip,$snmpkey) = @_;

	my $dbh=DBI->connect("DBI:mysql:database=audit_sec;host=localhost;mysql_connect_timeout=5",$mysql_user,$mysql_passwd,{RaiseError=>1});

	my $utf8 = $dbh->prepare("set names utf8");
	$utf8->execute();
	$utf8->finish();

	my $cpu_num = 0;my $cpu_value = 0;
	foreach(`snmpwalk -v 2c -c $snmpkey $device_ip .1.3.6.1.2.1.25.3.3 2>&1`)
	{
		if($_ =~ /Timeout.*No Response from/i){return;}

		if($_ =~ /hrProcessorLoad/i && $_ =~ /INTEGER\s*:\s*(\d+)/i)
		{
			$cpu_value += $1;
			++$cpu_num;
		}
	}
	$cpu_value = floor($cpu_value/$cpu_num);

	&insert_into_nondisk($dbh,$device_ip,'cpu',$cpu_value);

	my %disk_num;
	foreach(`snmpwalk -v 2c -c $snmpkey $device_ip .1.3.6.1.2.1.25.2`)
	{
		if($_ =~ /hrStorageDescr\.(\d+).*STRING\s*:\s*(\S+)\s*Label/i)
		{
			push @{$disk_num{$1}},$2;
		}

		if($_ =~ /hrStorageDescr\.(\d+).*STRING\s*:\s*(.*Memory)/i)
		{
			push @{$disk_num{$1}},$2;
		}

		if($_ =~ /hrStorageSize\.(\d+).*INTEGER\s*:\s*(\d+)/i)
		{
			if(exists $disk_num{$1})
			{
				push @{$disk_num{$1}},$2;
			}
		}

		if($_ =~ /hrStorageUsed.(\d+).*INTEGER\s*:\s*(\d+)$/i)
		{
			if(exists $disk_num{$1})
			{
				$disk_num{$1}->[1] = $2/$disk_num{$1}->[1];
				$disk_num{$1}->[1] = floor($disk_num{$1}->[1]*100);
			}
		}
	}

	foreach(keys %disk_num)
	{
		if($disk_num{$_}->[0] =~ /Virtual/i)
		{
			&insert_into_nondisk($dbh,$device_ip,'swap',$disk_num{$_}->[1]);
		}
		elsif($disk_num{$_}->[0] =~ /Physical/i)
		{
			&insert_into_nondisk($dbh,$device_ip,'memory',$disk_num{$_}->[1]);
		}
		else
		{
			&insert_into_disk($dbh,$device_ip,$disk_num{$_}->[0],$disk_num{$_}->[1]);
		}
	}
}

sub insert_into_nondisk
{
	my($dbh,$device_ip,$type,$value) = @_;
	my $sqr_insert = $dbh->prepare("insert into snmp_status (device_ip,datetime,type,value) values ('$device_ip','$time_now_str','$type',$value)");
	$sqr_insert->execute();
	$sqr_insert->finish();

	my $sqr_select_count = $dbh->prepare("select count(*) from snmp_day_count where date = '$date' and device_ip = '$device_ip' and type = '$type'");
	$sqr_select_count->execute();
	my $ref_select_count = $sqr_select_count->fetchrow_hashref();
	my $count = $ref_select_count->{"count(*)"};
	$sqr_select_count->finish();

	if($count == 0)
	{
		$sqr_insert = $dbh->prepare("insert into snmp_day_count (device_ip,date,type,total_value,max_value,count) values ('$device_ip','$date','$type',$value,$value,1)");
		$sqr_insert->execute();
		$sqr_insert->finish();
	}
	else
	{
		my $total_value; my $max_value; my $count;
		my $sqr_select_value = $dbh->prepare("select total_value,max_value,count from snmp_day_count where date = '$date' and device_ip = '$device_ip' and type = '$type'");
		$sqr_select_value->execute();
		while(my $ref_select_value = $sqr_select_value->fetchrow_hashref())
		{
			$total_value = $ref_select_value->{"total_value"};
			$max_value = $ref_select_value->{"max_value"};
			$count = $ref_select_value->{"count"};
		}

		$total_value += $value;
		$max_value = ($max_value > $value ? $max_value:$value);
		++$count;
		$sqr_select_value->finish();

		my $sqr_update = $dbh->prepare("update snmp_day_count set total_value = $total_value,max_value = $max_value,count = $count where date = '$date' and device_ip = '$device_ip' and type = '$type'");
		$sqr_update->execute();
		$sqr_update->finish();
	}

	my $sqr_select_thold = $dbh->prepare("select value from snmp_alarm where device_ip = '$device_ip' and type = '$type'");
	$sqr_select_thold->execute();
	my $ref_select_thold = $sqr_select_thold->fetchrow_hashref();
	my $thold = $ref_select_thold->{"value"};
	$sqr_select_thold->finish();

	if(defined $thold)
	{
		if($value > $thold)
		{
			$sqr_insert = $dbh->prepare("insert into snmp_err (device_ip,type,value_err,value_thold) values ('$device_ip','$type',$value,$thold)");
			$sqr_insert->execute();
			$sqr_insert->finish();
		}
	}
}

sub insert_into_disk
{
	my($dbh,$device_ip,$disk,$value) = @_;
	my $sqr_insert = $dbh->prepare("insert into snmp_status (device_ip,datetime,type,value,disk) values ('$device_ip','$time_now_str','disk',$value,'$disk')");
	$sqr_insert->execute();
	$sqr_insert->finish();

	my $sqr_select_count = $dbh->prepare("select count(*) from snmp_day_count where date = '$date' and device_ip = '$device_ip' and type = 'disk' and disk = '$disk'");
	$sqr_select_count->execute();
	my $ref_select_count = $sqr_select_count->fetchrow_hashref();
	my $count = $ref_select_count->{"count(*)"};
	$sqr_select_count->finish();

	if($count == 0)
	{
		my $sqr_insert = $dbh->prepare("insert into snmp_day_count (device_ip,date,type,total_value,max_value,disk,count) values ('$device_ip','$date','disk',$value,$value,'$disk',1)");
		$sqr_insert->execute();
		$sqr_insert->finish();
	}
	else
	{
		my $total_value; my $max_value; my $count;
		my $sqr_select_value = $dbh->prepare("select total_value,max_value,count from snmp_day_count where date = '$date' and device_ip = '$device_ip' and type = 'disk' and disk = '$disk'");
		$sqr_select_value->execute();
		while(my $ref_select_value = $sqr_select_value->fetchrow_hashref())
		{
			$total_value = $ref_select_value->{"total_value"};
			$max_value = $ref_select_value->{"max_value"};
			$count = $ref_select_value->{"count"};
		}

		$total_value += $value;
		$max_value = ($max_value > $value ? $max_value:$value);
		++$count;
		$sqr_select_value->finish();

		my $sqr_update = $dbh->prepare("update snmp_day_count set total_value = $total_value,max_value = $max_value,count = $count where date = '$date' and device_ip = '$device_ip' and type = 'disk' and disk = '$disk'");
		$sqr_update->execute();
		$sqr_update->finish();
	}

	my $sqr_select_thold = $dbh->prepare("select value from snmp_alarm where device_ip = '$device_ip' and type = 'disk' and disk = '$disk'");
	$sqr_select_thold->execute();
	my $ref_select_thold = $sqr_select_thold->fetchrow_hashref();
	my $thold = $ref_select_thold->{"value"};
	$sqr_select_thold->finish();

	if(defined $thold)
	{
		if($value > $thold)
		{
			$sqr_insert = $dbh->prepare("insert into snmp_err (device_ip,type,value_err,value_thold,disk) values ('$device_ip','disk',$value,$thold,'$disk')");
			$sqr_insert->execute();
			$sqr_insert->finish();
		}
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
