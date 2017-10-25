#!/usr/bin/perl
use warnings;
use strict;
use DBI;
use DBD::mysql;
use Expect;
use RRDs;
use Crypt::CBC;
use MIME::Base64;
use POSIX qw/ceil floor/;

our $debug_file_flag = 1;
our $debug_file_path = "/tmp/snmp_ssh_debug";
our $debug_warning = 1;

our $debug = 1;
our $status_path = '/tmp/remote_server_status/';
our $max_process_num = 5;
our $exist_process = 0;
our $process_time = 120;			#进程存活时间
our $host;							#用于子进程记录自己的host
our $root_path = "linux_root";		#linux根目录代名词,避免 / 的出现

our $time_now_utc = time;
my($min,$hour,$mday,$mon,$year) = (localtime $time_now_utc)[1..5];
($min,$hour,$mday,$mon,$year) = (sprintf("%02d", $min),sprintf("%02d", $hour),sprintf("%02d", $mday),sprintf("%02d", $mon + 1),$year+1900);
our $time_now_str = "$year$mon$mday$hour$min"."00";

unless(-e $status_path && -d _)
{
	if(-e _)
	{
		unlink $status_path;
	}
	mkdir $status_path,0755;
}

our($mysql_user,$mysql_passwd) = &get_local_mysql_config();
my $dbh=DBI->connect("DBI:mysql:database=audit_sec;host=localhost;mysql_connect_timeout=5",$mysql_user,$mysql_passwd,{RaiseError=>1});

my $utf8 = $dbh->prepare("set names utf8");
$utf8->execute();
$utf8->finish();

our @ref_ip_arr;
our %cache_value;

my $sqr_select = $dbh->prepare("select device_ip,device_type,monitor,snmpkey from servers where monitor!=0 group by device_ip");
$sqr_select->execute();
while(my $ref_select = $sqr_select->fetchrow_hashref())
{       
	my $device_ip = $ref_select->{"device_ip"};
	my $device_type = $ref_select->{"device_type"};
	my $monitor = $ref_select->{"monitor"};
	my $snmpkey = $ref_select->{"snmpkey"};

	if($monitor == 1)
	{
		unless(defined $snmpkey)
		{
			next;
		}
		my @host = ($monitor,$device_ip,$device_type,$snmpkey);
		push @ref_ip_arr,\@host;
	}
	elsif($monitor == 2)
	{
		my @host = ($monitor,$device_ip);
		push @ref_ip_arr,\@host;    
	}
	elsif($monitor == 3)
	{
		my @host = ($monitor,$device_ip);
		push @ref_ip_arr,\@host;
	}
}                   
$sqr_select->finish();

$sqr_select = $dbh->prepare("select device_ip,type,value from snmp_status_cache");
$sqr_select->execute();
while(my $ref_select = $sqr_select->fetchrow_hashref())
{       
	my $device_ip = $ref_select->{"device_ip"};
	my $type = $ref_select->{"type"};
	my $value = $ref_select->{"value"};

    unless(exists $cache_value{$device_ip})
    {
        my %tmp;
        $cache_value{$device_ip} = \%tmp;
    }

    unless(exists $cache_value{$device_ip}->{$type})
    {
        $cache_value{$device_ip}->{$type} = $value;
    }
}                   
$sqr_select->finish();

my $rc = $dbh->disconnect;

if(scalar @ref_ip_arr == 0) {exit;}

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
				my $dbh=DBI->connect("DBI:mysql:database=audit_sec;host=localhost;mysql_connect_timeout=5",$mysql_user,$mysql_passwd,{RaiseError=>1});

				my $utf8 = $dbh->prepare("set names utf8");
				$utf8->execute();
				$utf8->finish();

                &clean_cache_val($dbh);
				&set_device_nan_val($dbh);
				&set_process_nan_val($dbh);
				&set_port_nan_val($dbh);
				defined(my $pid_ssh_warning = fork) or die "cannot fork:$!";
				unless($pid_ssh_warning){
					exec "/home/wuxiaolong/3_status/snmp_ssh_warning.pl";
                    exit;
				}

				defined(my $pid_process_warning = fork) or die "cannot fork:$!";
				unless($pid_process_warning){
#					exec "/home/wuxiaolong/3_status/snmp_process_warning.pl";
                    exit;
				}

				defined(my $pid_port_warning = fork) or die "cannot fork:$!";
				unless($pid_port_warning){
#					exec "/home/wuxiaolong/3_status/snmp_port_warning.pl";
                    exit;
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
		$SIG{ALRM}=\&alarm_process;
		$host = $temp->[1];
		alarm($process_time);

		my $dbh=DBI->connect("DBI:mysql:database=audit_sec;host=localhost;mysql_connect_timeout=5",$mysql_user,$mysql_passwd,{RaiseError=>1});

		my $utf8 = $dbh->prepare("set names utf8");
		$utf8->execute();
		$utf8->finish();

		if($temp->[0] == 1)
		{
			&get_sys_runtime($dbh,$temp->[1],$temp->[3]);
			if($temp->[2] == 2){&linux_snmp($dbh,$temp->[0],$temp->[1],$temp->[3]);}
			elsif($temp->[2] == 4 || $temp->[2] == 20){&windows_snmp($dbh,$temp->[0],$temp->[1],$temp->[3]);}
			elsif($temp->[2] == 11){&cisco_snmp($dbh,$temp->[0],$temp->[1],$temp->[3]);}
		}
		elsif($temp->[0] == 2)
		{
			&ssh_status($dbh,$temp->[0],$temp->[1]);
		}
		elsif($temp->[0] == 3)
		{
			&read_file($dbh,$temp->[0],$temp->[1]);
		}
		exit 0;
	}
	++$exist_process;
}

sub get_sys_runtime
{
	my($dbh,$device_ip,$snmpkey) = @_;
	my $result = `snmpwalk -v 2c -c $snmpkey $device_ip DISMAN-EVENT-MIB::sysUpTimeInstance 2>&1`;
	foreach my $line(split /\r*\n/,$result)
	{
		if($line =~ /sysUpTimeInstance/i && $line =~ /Timeticks\s*:\s*\((\d+)\)/i)
		{
			my $sys_start_time = $1;

			my $sqr_select = $dbh->prepare("select count(*) from servers where device_ip = '$device_ip' and snmpkey = '$snmpkey'");
			$sqr_select->execute();
			my $ref_select = $sqr_select->fetchrow_hashref();
			my $ip_num = $ref_select->{"count(*)"};
			$sqr_select->finish();

			if($ip_num == 0)
			{
				my $sqr_insert = $dbh->prepare("insert into servers (device_ip,snmpkey,snmptime) values ('$device_ip','$snmpkey',$sys_start_time)");
				$sqr_insert->execute();
				$sqr_insert->finish();
			}
			else
			{
				if($device_ip eq "103.30.148.1")
				{
					print "update servers set snmptime = $sys_start_time where device_ip = '$device_ip' and snmpkey = '$snmpkey'\n";
				}
				my $sqr_update = $dbh->prepare("update servers set snmptime = $sys_start_time where device_ip = '$device_ip' and snmpkey = '$snmpkey'");
				$sqr_update->execute();
				$sqr_update->finish();
			}
		}
	}
}

sub linux_snmp
{
	my($dbh,$monitor,$device_ip,$snmpkey) = @_;
	unless(defined $snmpkey) {return;}

    my $debug_fd;
    if($debug_file_flag == 1)
    {
        open($debug_fd,">>$debug_file_path");
    }

	my $status = 1;

	if($debug == 1)
	{
		print "主机 $device_ip 开始SNMP获取状态\n";
	}

	my $cpu = `snmpwalk -v 2c -c $snmpkey $device_ip .1.3.6.1.4.1.2021.11.9.0 2>&1`;
    if($debug_file_flag == 1)
    {
        my $content = $cpu;
        $content =~ s/\n/\t/g;
        print $debug_fd "$device_ip,$time_now_str,cpu,1,$content\n";
        print  "$device_ip,$time_now_str,cpu,1,$content\n";
    }

    if($cpu =~ /^\s*$/ || $cpu =~ /Timeout.*No Response from/i)
    {
        sleep 5;
        if($debug_file_flag == 1)
        {
            my $content = $cpu;
            $content =~ s/\n/\t/g;
            print $debug_fd "$device_ip,$time_now_str,cpu,2,$content\n";
        }

        $cpu = `snmpwalk -v 2c -c $snmpkey $device_ip .1.3.6.1.4.1.2021.11.9.0 2>&1`;
    }

	if($cpu =~ /Timeout.*No Response from/i)
	{
		if($debug == 1)
		{
			print "主机 $device_ip SNMP无法连接\n";
		}

		&err_process($dbh,$device_ip,7,'主机SNMP无法连接'); 
		return;
	}

	if($cpu =~ /INTEGER\s*:\s*(\d+)/i)
	{
		$cpu = $1;
	}

	if($cpu =~ /^[\d\.]+$/)
	{
		&insert_into_nondisk($dbh,$device_ip,'cpu',$cpu,$time_now_str);
		&update_rrd($dbh,$device_ip,'cpu',$cpu,undef,undef);
		my $tmp_status = &warning_func($dbh,$time_now_str,$monitor,$device_ip,$cpu,'cpu',undef);
		if($status == 1 && $tmp_status != 1)
		{
			$status = $tmp_status;
		}
	
		if($debug == 1)
		{
			print "主机 $device_ip cpu:$cpu\n";
		}
	}

	my $cpu_io = `snmpwalk -v 2c -c $snmpkey $device_ip .1.3.6.1.4.1.2021.11.54 2>&1`;
    if($debug_file_flag == 1)
    {
        my $content = $cpu_io;
        $content =~ s/\n/\t/g;
        print $debug_fd "$device_ip,$time_now_str,cpu_io,1,$content\n";
    }

    if($cpu_io =~ /^\s*$/ || $cpu_io =~ /Timeout.*No Response from/i)
    {
        sleep 5;
        if($debug_file_flag == 1)
        {
            my $content = $cpu_io;
            $content =~ s/\n/\t/g;
            print $debug_fd "$device_ip,$time_now_str,cpu_io,2,$content\n";
        }

        $cpu_io = `snmpwalk -v 2c -c $snmpkey $device_ip .1.3.6.1.4.1.2021.11.54 2>&1`;
    }

	if($cpu_io =~ /Counter32\s*:\s*(\d+)/i)
	{
		$cpu_io = $1;
	}

	if($cpu_io =~ /^[\d\.]+$/)
    {
        my $last_value = $cache_value{$device_ip}->{"cpu_io"};
        &insert_into_cache($dbh,$device_ip,'cpu_io',$cpu_io);

        if($last_value > 0)
        {
            $cpu_io = ($cpu_io - $last_value)/100/300;
            $cpu_io = floor($cpu_io*1000)/10;
        }
        else
        {
            $cpu_io = -100;
        }

        &insert_into_nondisk($dbh,$device_ip,'cpu_io',$cpu_io,$time_now_str);
		&update_rrd($dbh,$device_ip,'cpu_io',$cpu_io,undef,undef);

        if($cpu_io >= 0)
        {
            my $tmp_status = &warning_func($dbh,$time_now_str,$monitor,$device_ip,$cpu,'cpu',undef);
            if($status == 1 && $tmp_status != 1)
            {
                $status = $tmp_status;
            }
        }

		if($debug == 1)
		{
            if($cpu_io >= 0)
            {
                print "主机 $device_ip cpu_io:$cpu_io\n";
            }
            else
            {
                print "主机 $device_ip cpu_io:无缓存记录\n";
            }
		}
    }

	my $memtotal=undef;my $memavail=undef;my $memcache=undef;my $membuff=undef;my $swaptotal=undef;my $swapavail=undef;
    if($debug_file_flag == 1)
    {
        print $debug_fd "$device_ip,$time_now_str,memory,1,";
    }

    foreach(`snmpwalk -v 2c -c $snmpkey $device_ip .1.3.6.1.4.1.2021.4 2>&1`)
    {
        if($debug_file_flag == 1)
        {
            print $debug_fd "$_\t";
        }

        if($_ =~ /memTotalReal/i && $_ =~ /INTEGER\s*:\s*(\d+)/i){$memtotal = $1;}
        if($_ =~ /memAvailReal/i && $_ =~ /INTEGER\s*:\s*(\d+)/i){$memavail = $1;}
        if($_ =~ /memCached/i && $_ =~ /INTEGER\s*:\s*(\d+)/i){$memcache = $1;}
        if($_ =~ /memBuffer/i && $_ =~ /INTEGER\s*:\s*(\d+)/i){$membuff = $1;}
        if($_ =~ /memTotalSwap/i && $_ =~ /INTEGER\s*:\s*(\d+)/i){$swaptotal = $1;}
		if($_ =~ /memAvailSwap/i && $_ =~ /INTEGER\s*:\s*(\d+)/i){$swapavail = $1;}
	}
    if($debug_file_flag == 1)
    {
        print $debug_fd "\n";
    }


#	unless($memtotal =~ /^[\d\.]+$/ && $memavail =~ /^[\d\.]+$/ && $memcache =~ /^[\d\.]+$/ && $membuff =~ /^[\d\.]+$/ && $swaptotal =~ /^[\d\.]+$/ && $swapavail =~ /^[\d\.]+$/ && $swaptotal > 0)
    unless(defined $memtotal && defined $memavail && defined $memcache && defined $membuff && defined $swaptotal && defined $swapavail && $swaptotal>0)
    {
        sleep 5;
        if($debug_file_flag == 1)
        {
            print $debug_fd "$device_ip,$time_now_str,memory,2,";
        }

        foreach(`snmpwalk -v 2c -c $snmpkey $device_ip .1.3.6.1.4.1.2021.4 2>&1`)
        {
            if($debug_file_flag == 1)
            {
                print $debug_fd "$_\t";
            }

            if($_ =~ /memTotalReal/i && $_ =~ /INTEGER\s*:\s*(\d+)/i){$memtotal = $1;}
            if($_ =~ /memAvailReal/i && $_ =~ /INTEGER\s*:\s*(\d+)/i){$memavail = $1;}
            if($_ =~ /memCached/i && $_ =~ /INTEGER\s*:\s*(\d+)/i){$memcache = $1;}
            if($_ =~ /memBuffer/i && $_ =~ /INTEGER\s*:\s*(\d+)/i){$membuff = $1;}
            if($_ =~ /memTotalSwap/i && $_ =~ /INTEGER\s*:\s*(\d+)/i){$swaptotal = $1;}
            if($_ =~ /memAvailSwap/i && $_ =~ /INTEGER\s*:\s*(\d+)/i){$swapavail = $1;}
        }
        if($debug_file_flag == 1)
        {
            print $debug_fd "\n";
        }
    }

    if(defined $memtotal && $memtotal =~ /^[\d\.]+$/ && defined $memavail && $memavail =~ /^[\d\.]+$/ && defined $memcache && $memcache =~ /^[\d\.]+$/ && defined $membuff && $membuff =~ /^[\d\.]+$/)
    {
        my $mem = floor(($memtotal-$memavail-$memcache-$membuff)/$memtotal*100);
		&insert_into_nondisk($dbh,$device_ip,'memory',$mem,$time_now_str);
		&update_rrd($dbh,$device_ip,'memory',$mem,undef,undef);
		my $tmp_status = &warning_func($dbh,$time_now_str,$monitor,$device_ip,$mem,'memory',undef);
		if($status == 1 && $tmp_status != 1)
		{             
			$status = $tmp_status;
		}

		if($debug == 1)
		{
			print "主机 $device_ip mem:$mem\n";
		}
	}

	if(defined $swaptotal && $swaptotal =~ /^[\d\.]+$/ && defined $swapavail && $swapavail =~ /^[\d\.]+$/ && $swaptotal > 0)
	{
		my $swap = floor(($swaptotal-$swapavail)/$swaptotal*100);

		&insert_into_nondisk($dbh,$device_ip,'swap',$swap,$time_now_str);
		&update_rrd($dbh,$device_ip,'swap',$swap,undef,undef);
		my $tmp_status = &warning_func($dbh,$time_now_str,$monitor,$device_ip,$swap,'swap',undef);
		if($status == 1 && $tmp_status != 1)
		{             
			$status = $tmp_status;
		}   

		if($debug == 1)
		{
			print "主机 $device_ip  swap:$swap\n";
		}
	}

	my %disk_num;
    foreach my $num(0..1)
    {
        if($debug_file_flag == 1)
        {
            print $debug_fd "$device_ip,$time_now_str,disk,",$num+1,",";
        }

        foreach(`snmpwalk -v 2c -c $snmpkey $device_ip 1.3.6.1.2.1.25.2 2>&1`)
        {
            if($debug_file_flag == 1)
            {
                print $debug_fd "$_\t";
            }

            if($_ =~ /hrStorageDescr.(\d+).*STRING\s*:\s*(\/.*)$/i)
            {
                unless(exists $disk_num{$1})
                {
                    my @tmp = ($2,undef,undef);
                    $disk_num{$1} = \@tmp;
                }
            }

            if($_ =~ /hrStorageSize.(\d+).*INTEGER\s*:\s*(\d+)$/i)
            {
                if(exists $disk_num{$1})
                {
                    $disk_num{$1}->[1] = $2;
                }
            }
            if($_ =~ /hrStorageUsed.(\d+).*INTEGER\s*:\s*(\d+)$/i)
            {
                if(exists $disk_num{$1})
                {
                    $disk_num{$1}->[2] = $2;
                }
            }
        }
        if($debug_file_flag == 1)
        {
            print $debug_fd "\n";
        }

        if($num == 0 && scalar keys %disk_num != 0)
        {
            last;
        }

        sleep 5;
    }

    foreach(keys %disk_num)
    {
        if(defined $disk_num{$_}->[1] && $disk_num{$_}->[1] != 0 && defined $disk_num{$_}->[2] && $disk_num{$_}->[1] =~ /^[\d\.]+$/ && $disk_num{$_}->[2] =~ /^[\d\.]+$/)
        {
            $disk_num{$_}->[1] = $disk_num{$_}->[2]/$disk_num{$_}->[1];
            $disk_num{$_}->[1] = floor($disk_num{$_}->[1]*100);
        }
        else
        {
            $disk_num{$_}->[1] = undef;
        }
    }

    foreach(keys %disk_num)
    {
        unless(defined $disk_num{$_}->[1])
        {
            next;
        }

        &insert_into_disk($dbh,$device_ip,$disk_num{$_}->[0],$disk_num{$_}->[1],$time_now_str);
        my $tmp_status = &warning_func($dbh,$time_now_str,$monitor,$device_ip,$disk_num{$_}->[1],'disk',$disk_num{$_}->[0]);
        if($status == 1 && $tmp_status != 1)
        {             
            $status = $tmp_status;
        }   

        my $disk_name = $disk_num{$_}->[0];
        $disk_name =~ s/^\///;
        $disk_name =~ s/\//-/g;

        if($disk_name eq ""){$disk_name = $root_path;}

        &update_rrd($dbh,$device_ip,$disk_name,$disk_num{$_}->[1],$disk_num{$_}->[0],undef);

        if($debug == 1)
        {
            print "主机 $device_ip disk:$disk_name val:$disk_num{$_}->[1]\n";
        }
    }

    my $sqr_update = $dbh->prepare("update servers set status = $status where device_ip = '$device_ip' and monitor!=0");
    $sqr_update->execute();
    $sqr_update->finish();

    if($debug == 1)
    {
        print "主机 $device_ip SNMP状态获取完成\n";
    }
}

sub windows_snmp
{
    my($dbh,$monitor,$device_ip,$snmpkey) = @_;
    unless(defined $snmpkey) {return;}

    my $status = 1;

    if($debug == 1)
    {
        print "主机 $device_ip 开始SNMP获取状态\n";
    }

    my $cpu_num = 0;my $cpu_value = 0;
    my $cpu = `snmpwalk -v 2c -c $snmpkey $device_ip .1.3.6.1.2.1.25.3.3 2>&1`;
    if($cpu =~ /^\s*$/ || $cpu =~ /Timeout.*No Response from/i)
    {
        sleep 5;
        $cpu = `snmpwalk -v 2c -c $snmpkey $device_ip .1.3.6.1.2.1.25.3.3 2>&1`;
    }

    foreach($cpu)
    {
        if($_ =~ /Timeout.*No Response from/i)
        {
            &err_process($dbh,$device_ip,7,'主机SNMP无法连接'); 

            if($debug == 1)
            {
				print "主机 $device_ip SNMP无法连接\n";
			}
			return;
		}

		if($_ =~ /hrProcessorLoad/i && $_ =~ /INTEGER\s*:\s*(\d+)/i)
		{
			$cpu_value += $1;
			++$cpu_num;
		}
	}

	if($cpu_num != 0)
	{
		$cpu_value = floor($cpu_value/$cpu_num);
	}
	else
	{
		$cpu_value = undef;
	}

	if($cpu_value =~ /^[\d\.]+$/)
	{
		&insert_into_nondisk($dbh,$device_ip,'cpu',$cpu_value,$time_now_str);
		&update_rrd($dbh,$device_ip,'cpu',$cpu_value,undef,undef);
		my $tmp_status = &warning_func($dbh,$time_now_str,$monitor,$device_ip,$cpu_value,'cpu',undef);
		if($status == 1 && $tmp_status != 1)
		{
			$status = $tmp_status;
		}

		if($debug == 1)
		{
			print "主机 $device_ip cpu:$cpu_value\n";
		}
	}

	my %disk_num;
    foreach my $num(0..1)
    {
        foreach(`snmpwalk -v 2c -c $snmpkey $device_ip .1.3.6.1.2.1.25.2 2>&1`)
        {
            if($_ =~ /hrStorageDescr\.(\d+).*STRING\s*:\s*(\S+)\s*Label/i)
            {
                unless(defined $disk_num{$1})
                {
                    my @tmp = ($2,undef,undef);
                    $disk_num{$1} = \@tmp;
                }
            }

            if($_ =~ /hrStorageDescr\.(\d+).*STRING\s*:\s*(.*Memory)/i)
            {
                unless(defined $disk_num{$1})
                {
                    my @tmp = ($2,undef,undef);
                    $disk_num{$1} = \@tmp;
                }
            }

            if($_ =~ /hrStorageSize\.(\d+).*INTEGER\s*:\s*(\d+)/i)
            {
                if(exists $disk_num{$1})
                {
                    $disk_num{$1}->[1] = $2;
                }
            }

            if($_ =~ /hrStorageUsed.(\d+).*INTEGER\s*:\s*(\d+)$/i)
            {
                if(exists $disk_num{$1})
                {
                    $disk_num{$1}->[2] = $2;
                }
            }
        }

        if($num == 0 && scalar keys %disk_num != 0)
        {
            last;
        }

        sleep 5;
    }

    foreach(keys %disk_num)
    {
        if(defined $disk_num{$_}->[1] && $disk_num{$_}->[1] != 0 && defined $disk_num{$_}->[2] && $disk_num{$_}->[1] =~ /^[\d\.]+$/ && $disk_num{$_}->[2] =~ /^[\d\.]+$/)
        {
            $disk_num{$_}->[1] = $disk_num{$_}->[2]/$disk_num{$_}->[1];
            $disk_num{$_}->[1] = floor($disk_num{$_}->[1]*100);
        }
        else
        {
            $disk_num{$_}->[1] = undef;
        }
    }

	foreach(keys %disk_num)
	{
		unless(defined $disk_num{$_}->[1])
		{
			next;
		}

		if($disk_num{$_}->[0] =~ /Virtual/i)
		{
			&insert_into_nondisk($dbh,$device_ip,'swap',$disk_num{$_}->[1],$time_now_str);
			&update_rrd($dbh,$device_ip,'swap',$disk_num{$_}->[1],undef,undef);
			my $tmp_status = &warning_func($dbh,$time_now_str,$monitor,$device_ip,$disk_num{$_}->[1],'swap',undef);
			if($status == 1 && $tmp_status != 1)
			{             
				$status = $tmp_status;
			}   

			if($debug == 1)
			{
				print "主机 $device_ip swap:$disk_num{$_}->[1]\n";
			}
		}
		elsif($disk_num{$_}->[0] =~ /Physical/i)
		{
			&insert_into_nondisk($dbh,$device_ip,'memory',$disk_num{$_}->[1],$time_now_str);
			&update_rrd($dbh,$device_ip,'memory',$disk_num{$_}->[1],undef,undef);
			my $tmp_status = &warning_func($dbh,$time_now_str,$monitor,$device_ip,$disk_num{$_}->[1],'memory',undef);
			if($status == 1 && $tmp_status != 1)
			{             
				$status = $tmp_status;
			}   

			if($debug == 1)
			{
				print "主机 $device_ip mem:$disk_num{$_}->[1]\n";
			}
		}
		else
		{
			$disk_num{$_}->[0] =~ s/:\\/_driver/g;
			&insert_into_disk($dbh,$device_ip,$disk_num{$_}->[0],$disk_num{$_}->[1],$time_now_str);
			my $tmp_status = &warning_func($dbh,$time_now_str,$monitor,$device_ip,$disk_num{$_}->[1],'disk',$disk_num{$_}->[0]);
			if($status == 1 && $tmp_status != 1)
			{             
				$status = $tmp_status;
			}   

			my $disk_name = $disk_num{$_}->[0];
			$disk_name =~ s/^\///;
			$disk_name =~ s/\//-/g;

			if($disk_name eq ""){$disk_name = $root_path;}

			&update_rrd($dbh,$device_ip,$disk_name,$disk_num{$_}->[1],$disk_num{$_}->[0],undef);
			if($debug == 1)
			{
				print "主机 $device_ip disk:$disk_name val:$disk_num{$_}->[1]\n";
			}
		}
	}

	my $sqr_update = $dbh->prepare("update servers set status = $status where device_ip = '$device_ip' and monitor!=0");
	$sqr_update->execute();
	$sqr_update->finish();

	if($debug == 1)
	{
		print "主机 $device_ip SNMP状态获取完成\n";
	}
}

sub cisco_snmp
{
	my($dbh,$monitor,$device_ip,$snmpkey) = @_;
	unless(defined $snmpkey) {return;}

	my $status = 1;

	if($debug == 1)
	{
		print "主机 $device_ip 开始SNMP获取状态\n";
	}

	my $cpu_num = 0;my $cpu_value = undef;
    my $cpu = `snmpwalk -v 2c -c $snmpkey $device_ip .1.3.6.1.4.1.9.9.109.1.1.1.1.5 2>&1`;
    if($cpu =~ /^\s*$/ || $cpu =~ /Timeout.*No Response from/i)
    {
        sleep 5;
        $cpu = `snmpwalk -v 2c -c $snmpkey $device_ip .1.3.6.1.4.1.9.9.109.1.1.1.1.5 2>&1`;
    }

	foreach($cpu)
	{
		if($_ =~ /Timeout.*No Response from/i)
		{
			&err_process($dbh,$device_ip,7,'主机SNMP无法连接'); 

			if($debug == 1)
			{
				print "主机 $device_ip SNMP无法连接\n";
			}
			return;
		}

		if($_ =~ /Gauge32\s*:\s*(\d+)$/i)
		{
			++$cpu_num;
            if(defined $cpu_value)
            {
                $cpu_value += $1;
            }
            else
            {
                $cpu_value = $1;
            }
		}
	}

    if($cpu_num != 0)
    {
        $cpu_value = floor($cpu_value/$cpu_num);
    }

	if(defined $cpu_value && $cpu_value =~ /^[\d\.]+$/)
	{
		&insert_into_nondisk($dbh,$device_ip,'cpu',$cpu_value,$time_now_str);
		&update_rrd($dbh,$device_ip,'cpu',$cpu_value,undef,undef);
		my $tmp_status = &warning_func($dbh,$time_now_str,$monitor,$device_ip,$cpu_value,'cpu',undef);
		if($status == 1 && $tmp_status != 1)
		{
			$status = $tmp_status;
		}

		if($debug == 1)
		{
			print "主机 $device_ip cpu:$cpu_value\n";
		}
	}

	my $mem_used = undef;my $mem_free = undef;my $mem = 0;
	foreach(`snmpwalk -v 2c -c $snmpkey $device_ip 1.3.6.1.4.1.9.9.48.1.1.1`)
	{
		if($_ =~ /\.9\.9\.48\.1\.1\.1\.5\.1/i && $_ =~ /Gauge32\s*:\s*(\d+)$/i){$mem_used = $1;}
		if($_ =~ /\.9\.9\.48\.1\.1\.1\.6\.1/i && $_ =~ /Gauge32\s*:\s*(\d+)$/i){$mem_free = $1;}
	}       

    unless(defined $mem_used && $mem_used =~ /^[\d\.]+$/ && defined $mem_free && $mem_free =~ /^[\d\.]+$/)
    {
        sleep 5;
        foreach(`snmpwalk -v 2c -c $snmpkey $device_ip 1.3.6.1.4.1.9.9.48.1.1.1`)
        {
            if($_ =~ /\.9\.9\.48\.1\.1\.1\.5\.1/i && $_ =~ /Gauge32\s*:\s*(\d+)$/i){$mem_used = $1;}
            if($_ =~ /\.9\.9\.48\.1\.1\.1\.6\.1/i && $_ =~ /Gauge32\s*:\s*(\d+)$/i){$mem_free = $1;}
        }       
    }

    if(defined $mem_used && $mem_used =~ /^[\d\.]+$/ && defined $mem_free && $mem_free =~ /^[\d\.]+$/)
    {
        $mem = floor($mem_used/($mem_used+$mem_free)*100);
		&insert_into_nondisk($dbh,$device_ip,'memory',$mem,$time_now_str);
		&update_rrd($dbh,$device_ip,'memory',$mem,undef,undef);
		my $tmp_status = &warning_func($dbh,$time_now_str,$monitor,$device_ip,$mem,'memory',undef);
		if($status == 1 && $tmp_status != 1)
		{             
			$status = $tmp_status;
		}   

		if($debug == 1)
		{
			print "主机 $device_ip mem:$mem\n";
		}
	}

	my $sqr_update = $dbh->prepare("update servers set status = $status where device_ip = '$device_ip' and monitor!=0");
	$sqr_update->execute();
	$sqr_update->finish();

	if($debug == 1)
	{
		print "主机 $device_ip SNMP状态获取完成\n";
	}
}

sub ssh_status
{
	my($dbh,$monitor,$des_ip) = @_;

	my $sqr_select = $dbh->prepare("select login_method,username,udf_decrypt(cur_password),port from devices where master_user=1 and device_ip = '$des_ip'");
	$sqr_select->execute();
	my $ref_select = $sqr_select->fetchrow_hashref();
	my $user = $ref_select->{"username"};
	my $passwd = $ref_select->{"udf_decrypt(cur_password)"};
	my $port = $ref_select->{"port"};
	$sqr_select->finish();

	my $cmd = "ssh -l $user $des_ip -p $port";
#	print $cmd,"\n";

	if($debug == 1)
	{
		print "主机 $des_ip 开始ssh: ssh -l $user $des_ip -p $port\n";
	}

	my $exp = Expect->new;
	$exp->log_stdout(0);
	$exp->spawn($cmd);
	$exp->debug(0);

	my @results = $exp->expect(20,[
			qr/password/i,
			sub {
			my $self = shift ;

			$self->send_slow(0.1,"$passwd\n");
			}
			],
			[
			qr/yes\/no/i,
			sub {
			my $self = shift ;
			$self->send_slow(0.1,"yes\n");
			exp_continue;
			}
			],
			);

	if(defined $results[1])
	{
		my $errno;
		if($results[1] =~ /(\d+).*:.*/i) 
		{
			$errno = $1;
		}
		else 
		{
			&err_process($dbh,$des_ip,8,$results[1]); 
			if($debug == 1)
			{
				print "主机 $des_ip 其他错误退出\n";
			}
			return;
		}

		my $output = $exp->before();
		my @context = split /\n/,$output;

		if($errno == 1)
		{
			&err_process($dbh,$des_ip,2,'ssh cmd timeout'); 
			if($debug == 1)
			{
				print "主机 $des_ip ssh命令超时\n";
			}
			return;
		}
		elsif($errno == 3)
		{
			foreach my $line(@context)
			{
				if($line =~ /No\s*route\s*to\s*host/i)
				{
					&err_process($dbh,$des_ip,3,"no route to dst host:$des_ip"); 
					if($debug == 1)
					{
						print "主机 $des_ip no route to dst host\n";
					}
					return;
				}

				if($line =~ /Connection\s*refused/i)
				{
					&err_process($dbh,$des_ip,4,"connection refused by dst host:$des_ip, maybe sshd is closed"); 
					if($debug == 1)
					{
						print "主机 $des_ip connection refused, maybe sshd is closed\n";
					}
					return;
				}

				if($line =~ /Host\s*key\s*verification\s*failed/i)
				{
					&err_process($dbh,$des_ip,6,"Host key verification failed:$des_ip"); 
					if($debug == 1)
					{
						print "主机 $des_ip Host key verification failed\n";
					}
					return;
				}
			}
		}
		else
		{
			&err_process($dbh,$des_ip,8,$results[1]); 
			if($debug == 1)
			{
				print "主机 $des_ip 其他错误退出\n";
			}
			return;
		}
	}

	$exp->expect(3, undef);

	my $output = $exp->before();
	my @context = split /\n/,$output;
	foreach my $line(@context)
	{
		if($line =~ /Permission\s*denied/i)
		{
			&err_process($dbh,$des_ip,5,"passwd for $des_ip is wrong"); 
			if($debug == 1)
			{
				print "主机 $des_ip passwd is wrong\n";
			}
			return;
		}
		elsif($line =~ /\]#/i)
		{
			if($debug == 1)
			{
				print "主机 $des_ip 登陆成功\n";
			}
			&status_monitor($dbh,$monitor,$exp,$des_ip);
			return;
		}
	}
}

sub read_file
{
	my($dbh,$monitor,$device_ip) = @_;
	sleep 30;
	my $exist_file = 0;
	my @delete_files;

	my @name_val;
	my $last_file_time = 0;

	my $dir;
	opendir $dir,$status_path;
	while(my $file = readdir $dir)
	{
		if($file =~ /^\./){next;}
		my($server_ip,$time) = split /_/,$file;

		if($device_ip eq $server_ip)
		{
			push @delete_files, "$status_path$file";
			unless($time > $last_file_time)
			{
				next;
			}

			@name_val = ();
			$exist_file = 1;
			open(my $fd_fr_status,"<$status_path$file");
			foreach my $line(<$fd_fr_status>)
			{
				my($name,$val) = split /\s+/,$line;

				my @tmp = ($name,$val);
				push @name_val,\@tmp;
			}

			close $fd_fr_status;
		}
	}

	my $status = 1;
	foreach my $ref(@name_val)
	{
		my $name = $ref->[0];
		my $val = $ref->[1];

		if($name eq "time")
		{
			next;
		}

		if($name eq "cpu" || $name eq "cpu_io" ||$name eq "memory" || $name eq "swap")
		{
			if($val =~ /^[\d\.]+$/)
			{
				&insert_into_nondisk($dbh,$device_ip,$name,$val,$time_now_str);
				&update_rrd($dbh,$device_ip,$name,$val,undef,$time_now_utc);
				my $tmp_status = &warning_func($dbh,$time_now_str,$monitor,$device_ip,$val,$name,undef);
				if($status == 1 && $tmp_status != 1)
				{             
					$status = $tmp_status;
				}   

				if($debug == 1)
				{
					print "主机 $device_ip $name:$val\n";
				}
			}
		}
		elsif($name =~ /process:/i)
		{
			my $process_name = (split /:/,$name)[1];
			if($val =~ /^[\d\.]+$/)
			{
				&insert_into_process($dbh,$device_ip,$process_name,$val,$time_now_str);
				&update_rrd_process($dbh,$device_ip,$process_name,$val,$time_now_utc);
				my $tmp_status = &warning_func_process($dbh,$time_now_str,$device_ip,$process_name,$val);

				if($status == 1 && $tmp_status != 1)
				{             
					$status = $tmp_status;
				}   

				if($debug == 1)
				{
					print "主机 $device_ip 进程: $process_name 状态: $val\n";
				}
			}
		}
		elsif($name =~ /port:/i)
		{
			my $port = (split /:/,$name)[1];
			if($val =~ /^[\d\.]+$/)
			{
				&insert_into_port($dbh,$device_ip,$port,$val,$time_now_str);
				&update_rrd_port($dbh,$device_ip,$port,$val,$time_now_utc);
                my $tmp_status = &warning_func_port($dbh,$time_now_str,$device_ip,$port,$val);

				if($status == 1 && $tmp_status != 1)
				{             
					$status = $tmp_status;
				}   

				if($debug == 1)
				{
					print "主机 $device_ip 端口: $port 状态: $val\n";
				}
			}
		}
		else
		{
			if($val =~ /^[\d\.]+$/)
			{
				&insert_into_disk($dbh,$device_ip,$name,$val,$time_now_str);
				my $tmp_status = &warning_func($dbh,$time_now_str,$monitor,$device_ip,$val,'disk',$name);
				if($status == 1 && $tmp_status != 1)
				{             
					$status = $tmp_status;
				}   

				my $disk_name = $name;
				$disk_name =~ s/^\///;
				$disk_name =~ s/\//-/g;

				if($disk_name eq ""){$disk_name = $root_path;}

				&update_rrd($dbh,$device_ip,$disk_name,$val,$name,$time_now_utc);

				if($debug == 1)
				{
					print "主机 $device_ip disk:$disk_name val:$val\n";
				}
			}
		}
	}

	my $sqr_update = $dbh->prepare("update servers set status = $status where device_ip = '$device_ip' and monitor!=0");
	$sqr_update->execute();
	$sqr_update->finish();

	if($debug == 1)
	{
		print "主机 $device_ip 读文件状态获取完成\n";
	}

	foreach my $tmp_file(@delete_files)
	{
		unlink $tmp_file;
	}

	if($exist_file == 0)
	{
		&err_process($dbh,$device_ip,10,'没有找到主机对应的文件');
		print "$device_ip 没有找到主机对应的文件\n";
		return;
	}
}

sub err_process
{
	my($dbh,$host,$errno,$err_str) = @_;

	my $insert;
	if(defined $err_str)
	{
		$insert = $dbh->prepare("insert into status_log(datetime,host,result,reason) values($time_now_str,'$host',$errno,'$err_str')");
	}
	else
	{
		$insert = $dbh->prepare("insert into status_log(datetime,host,result) values($time_now_str,'$host',$errno)");
	}
	$insert->execute();
	$insert->finish();
}

sub status_monitor
{
	my($dbh,$monitor,$exp,$device_ip) = @_;
	my $status = 1;

	my $cmd = "/usr/bin/top -b -n 2 | grep -E -i '^cpu'";

	$exp->send("$cmd\n");
	$exp->expect(6, undef);

	my $result = $exp->before();
	my @context = split /\n/,$result;

	my $cpu_info;
	foreach my $line(@context)
	{
		if($line =~ /(\d+\.\d+)%id.*(\d+\.\d+)%wa/i)
		{
			$cpu_info = $line;
		}
	}

	@context = ();
	push @context,$cpu_info;

	foreach my $line(@context)
	{
		if($line =~ /(\d+\.\d+)%id.*(\d+\.\d+)%wa/i)
		{
			my $cpu = $1;
            my $cpu_io = $2;
			$cpu = floor(100 - $cpu);
            $cpu_io = floor($cpu_io);

			&insert_into_nondisk($dbh,$device_ip,'cpu',$cpu,$time_now_str);
			&update_rrd($dbh,$device_ip,'cpu',$cpu,undef,undef);
			my $tmp_status = &warning_func($dbh,$time_now_str,$monitor,$device_ip,$cpu,'cpu',undef);
            if($status == 1 && $tmp_status != 1)
			{
				$status = $tmp_status;
			}

            &insert_into_nondisk($dbh,$device_ip,'cpu_io',$cpu_io,$time_now_str);
            &update_rrd($dbh,$device_ip,'cpu_io',$cpu_io,undef,undef);
            $tmp_status = &warning_func($dbh,$time_now_str,$monitor,$device_ip,$cpu_io,'cpu_io',undef);
            if($status == 1 && $tmp_status != 1)
			{
				$status = $tmp_status;
			}

			if($debug == 1)
			{
				print "主机 $device_ip cpu:$cpu\n";
			}
			last;
		}
	}

	$cmd = "free | grep -i 'mem'";
	$exp->send("$cmd\n");
	$exp->expect(2, undef);

	$result = $exp->before();
	@context = split /\n/,$result;

	foreach my $line(@context)
	{
		if($line =~ /^mem/i)
		{
			my($total,$used,$buffers,$cache) = (split /\s+/,$line)[1,2,5,6];

			if($total =~ /^[\d\.]+$/ && $used =~ /^[\d\.]+$/ && $buffers =~ /^[\d\.]+$/ && $cache =~ /^[\d\.]+$/)
			{
				my $memory = floor(($used-$buffers-$cache)/$total*100);
				&insert_into_nondisk($dbh,$device_ip,'memory',$memory,$time_now_str);
				&update_rrd($dbh,$device_ip,'memory',$memory,undef,undef);
				my $tmp_status = &warning_func($dbh,$time_now_str,$monitor,$device_ip,$memory,'memory',undef);
				if($status == 1 && $tmp_status != 1)
				{             
					$status = $tmp_status;
				}   

				if($debug == 1)
				{
					print "主机 $device_ip mem:$memory\n";
				}
				last;
			}
		}
	}

	$cmd = "free | grep -i 'swap'";
	$exp->send("$cmd\n");
	$exp->expect(2, undef);

	$result = $exp->before();
	@context = split /\n/,$result;

	foreach my $line(@context)
	{
		if($line =~ /^swap/i)
		{
			my($total,$used) = (split /\s+/,$line)[1,2];
			if($total =~ /^[\d\.]+$/ && $used =~ /^[\d\.]+$/ && $total > 0)
			{
				my $swap = floor($used/$total*100);
				&insert_into_nondisk($dbh,$device_ip,'swap',$swap,$time_now_str);
				&update_rrd($dbh,$device_ip,'swap',$swap,undef,undef);
				my $tmp_status = &warning_func($dbh,$time_now_str,$monitor,$device_ip,$swap,'swap',undef);
				if($status == 1 && $tmp_status != 1)
				{             
					$status = $tmp_status;
				}   

				if($debug == 1)
				{
					print "主机 $device_ip swap:$swap\n";
				}
				last;
			}
		}
	}

	$cmd = "df";
	$exp->send("$cmd\n");
	$exp->expect(2, undef);

	$result = $exp->before();
	@context = split /\n/,$result;

	foreach my $line(@context)
	{
		if($line =~ /(\d+)%\s*(\/\S*)/i)
		{
			my $disk_val = $1;
			my $disk_name = $2;
			if($disk_name =~ /shm/i){next;}
			&insert_into_disk($dbh,$device_ip,$disk_name,$disk_val,$time_now_str);
			my $tmp_status = &warning_func($dbh,$time_now_str,$monitor,$device_ip,$disk_val,'disk',$disk_name);
			if($status == 1 && $tmp_status != 1)
			{             
				$status = $tmp_status;
			}   

			my $disk_tmp = $disk_name;
			$disk_name =~ s/^\///;
			$disk_name =~ s/\//-/g;

			if($disk_name eq ""){$disk_name = $root_path;}

			&update_rrd($dbh,$device_ip,$disk_name,$disk_val,$disk_tmp,undef);
			if($debug == 1)
			{
				print "主机 $device_ip disk:$disk_name val: $disk_val\n";
			}
		}
	}

	my $sqr_update = $dbh->prepare("update servers set status = $status where device_ip = '$device_ip' and monitor!=0");
	$sqr_update->execute();
	$sqr_update->finish();

	if($debug == 1)
	{
		print "主机 $device_ip ssh状态获取完成\n";
	}
}

sub insert_into_cache
{
	my($dbh,$device_ip,$type,$value) = @_;

    my $sqr_select = $dbh->prepare("select count(*) from snmp_status_cache where device_ip = '$device_ip' and type = '$type'");
    $sqr_select->execute();
    my $ref_select = $sqr_select->fetchrow_hashref();
    my $count = $ref_select->{"count(*)"};
    $sqr_select->finish();

    if($count == 0)
    {
		my $sqr_insert = $dbh->prepare("insert into snmp_status_cache (device_ip,datetime,type,value) values ('$device_ip','$time_now_str','$type',$value)");
		$sqr_insert->execute();
		$sqr_insert->finish();
    }
    else
    {
        my $sqr_update = $dbh->prepare("update snmp_status_cache set value = $value, datetime = '$time_now_str' where device_ip = '$device_ip' and type = '$type'");
        $sqr_update->execute();
        $sqr_update->finish();
    }
}

sub insert_into_nondisk
{
	my($dbh,$device_ip,$type,$value,$cur_time) = @_;

	my $sqr_select = $dbh->prepare("select count(*) from snmp_status where device_ip = '$device_ip' and type = '$type'");
	$sqr_select->execute();
	my $ref_select = $sqr_select->fetchrow_hashref();
	my $device_num = $ref_select->{"count(*)"};
	$sqr_select->finish();

	if($device_num == 0)
	{
		my $sqr_insert = $dbh->prepare("insert into snmp_status (device_ip,type) values ('$device_ip','$type')");
		$sqr_insert->execute();
		$sqr_insert->finish();

		$sqr_select = $dbh->prepare("select enable from snmp_status where device_ip = '$device_ip' and type = '$type'");
		$sqr_select->execute();
		$ref_select = $sqr_select->fetchrow_hashref();
		my $enable = $ref_select->{"enable"};
		$sqr_select->finish();

		if($enable != 1)
		{
			if($debug == 1)
			{
				my $sqr_update = $dbh->prepare("update snmp_status set enable = 1 where device_ip = '$device_ip' and type = '$type'");
				$sqr_update->execute();
				$sqr_update->finish();

				$sqr_update = $dbh->prepare("update snmp_status set value = $value, datetime = '$cur_time' where device_ip = '$device_ip' and type = '$type'");
				$sqr_update->execute();
				$sqr_update->finish();
			}
		}
		else
		{
			my $sqr_update = $dbh->prepare("update snmp_status set value = $value, datetime = '$cur_time' where device_ip = '$device_ip' and type = '$type'");
			$sqr_update->execute();
			$sqr_update->finish();
		}
	}
	else
	{
		$sqr_select = $dbh->prepare("select enable from snmp_status where device_ip = '$device_ip' and type = '$type'");
		$sqr_select->execute();
		$ref_select = $sqr_select->fetchrow_hashref();
		my $enable = $ref_select->{"enable"};
		$sqr_select->finish();

		if($enable == 1)
		{
			my $sqr_update = $dbh->prepare("update snmp_status set value = $value, datetime = '$cur_time' where device_ip = '$device_ip' and type = '$type'");
			$sqr_update->execute();
			$sqr_update->finish();
		}
		else
		{
			my $sqr_update = $dbh->prepare("update snmp_status set value = null, datetime = null where device_ip = '$device_ip' and type = '$type'");
			$sqr_update->execute();
			$sqr_update->finish();
		}
	}
}

sub insert_into_disk
{
	my($dbh,$device_ip,$disk,$value,$cur_time) = @_;

	my $disk_name;
	if(defined $disk)
	{
		$disk =~ s/\\/\\\\/g;
#		print $disk,"\n";

		$disk_name = $disk;
		$disk_name =~ s/^\///;
		$disk_name =~ s/\//-/g;
		if($disk_name eq ""){$disk_name = $root_path;}
	}

	if($value < 0)
	{
		my $cmd;

		if(defined $disk)
		{
			$cmd = "select count(*) from snmp_status where device_ip = '$device_ip' and type = 'disk' and disk = '$disk'"
		}
		else
		{
			$cmd = "select count(*) from snmp_status where device_ip = '$device_ip' and type = 'disk'";
		}

		my $sqr_select = $dbh->prepare("$cmd");
		$sqr_select->execute();
		my $ref_select = $sqr_select->fetchrow_hashref();
		my $device_num = $ref_select->{"count(*)"};
		$sqr_select->finish();

		if($device_num == 0)
		{
			if(defined $disk)
			{
				$cmd = "insert into snmp_status (device_ip,type,disk) values ('$device_ip','disk','$disk')";
			}
			else
			{
				$cmd = "insert into snmp_status (device_ip,type) values ('$device_ip','disk')";
			}

			my $sqr_insert = $dbh->prepare("$cmd");
			$sqr_insert->execute();
			$sqr_insert->finish();

			if(defined $disk)
			{
				$cmd = "select enable from snmp_status where device_ip = '$device_ip' and type = 'disk' and disk = '$disk'";
			}
			else
			{
				$cmd = "select enable from snmp_status where device_ip = '$device_ip' and type = 'disk'";
			}

			$sqr_select = $dbh->prepare("$cmd");
			$sqr_select->execute();
			$ref_select = $sqr_select->fetchrow_hashref();
			my $enable = $ref_select->{"enable"};
			$sqr_select->finish();

			if($enable != 1)
			{
				if($debug == 1)
				{
					if(defined $disk)
					{
						$cmd = "update snmp_status set enable = 1 where device_ip = '$device_ip' and type = 'disk' and disk = '$disk'";
					}
					else
					{
						$cmd = "update snmp_status set enable = 1 where device_ip = '$device_ip' and type = 'disk'";
					}

					my $sqr_update = $dbh->prepare("$cmd");
					$sqr_update->execute();
					$sqr_update->finish();

					if(defined $disk)
					{
						$cmd = "update snmp_status set value = $value, datetime = '$cur_time' where device_ip = '$device_ip' and type = 'disk' and disk = '$disk'";
					}
					else
					{
						$cmd = "update snmp_status set value = $value, datetime = '$cur_time' where device_ip = '$device_ip' and type = 'disk'";
					}

					$sqr_update = $dbh->prepare("$cmd");
					$sqr_update->execute();
					$sqr_update->finish();
				}
			}
			else
			{
				if(defined $disk)
				{
					$cmd = "update snmp_status set value = $value, datetime = '$cur_time' where device_ip = '$device_ip' and type = 'disk' and disk = '$disk'";
				}
				else
				{
					$cmd = "update snmp_status set value = $value, datetime = '$cur_time' where device_ip = '$device_ip' and type = 'disk'";
				}

				my $sqr_update = $dbh->prepare("$cmd");
				$sqr_update->execute();
				$sqr_update->finish();
			}
		}
		else
		{
			if(defined $disk)
			{
				$cmd = "select seq,enable from snmp_status where device_ip = '$device_ip' and type = 'disk' and disk = '$disk'";
			}
			else
			{
				$cmd = "select seq,enable from snmp_status where device_ip = '$device_ip' and type = 'disk'";
			}

			$sqr_select = $dbh->prepare("$cmd");
			$sqr_select->execute();
			while($ref_select = $sqr_select->fetchrow_hashref())
			{
				my $enable = $ref_select->{"enable"};
				my $disk_seq = $ref_select->{"seq"};

				if($enable == 1)
				{
					my $sqr_update = $dbh->prepare("update snmp_status set value = $value, datetime = '$cur_time' where device_ip = '$device_ip' and type = 'disk' and seq = $disk_seq");
					$sqr_update->execute();
					$sqr_update->finish();
				}
				else
				{
					my $sqr_update = $dbh->prepare("update snmp_status set value = null, datetime = null where device_ip = '$device_ip' and type = 'disk' and seq = $disk_seq");
					$sqr_update->execute();
					$sqr_update->finish();
				}
			}
			$sqr_select->finish();
		}
	}
	else
	{
		my $sqr_select = $dbh->prepare("select count(*) from snmp_status where device_ip = '$device_ip' and type = 'disk' and disk = '$disk'");
		$sqr_select->execute();
		my $ref_select = $sqr_select->fetchrow_hashref();
		my $device_num = $ref_select->{"count(*)"};
		$sqr_select->finish();

		if($device_num == 0)
		{
			$sqr_select = $dbh->prepare("select seq from snmp_status where device_ip = '$device_ip' and type = 'disk' and disk is null");
			$sqr_select->execute();
			$ref_select = $sqr_select->fetchrow_hashref();
			my $disk_seq = $ref_select->{"seq"};
			$sqr_select->finish();

			if(defined $disk_seq)
			{
				my $sqr_delete = $dbh->prepare("delete from snmp_status where seq = $disk_seq");
				$sqr_delete->execute();
				$sqr_delete->finish();
			}

			my $sqr_insert = $dbh->prepare("insert into snmp_status (device_ip,type,disk) values ('$device_ip','disk','$disk')");
			$sqr_insert->execute();
			$sqr_insert->finish();

			$sqr_select = $dbh->prepare("select enable from snmp_status where device_ip = '$device_ip' and type = 'disk' and disk = '$disk'");
			$sqr_select->execute();
			$ref_select = $sqr_select->fetchrow_hashref();
			my $enable = $ref_select->{"enable"};
			$sqr_select->finish();

			if($enable != 1)
			{
				if($debug == 1)
				{
					my $sqr_update = $dbh->prepare("update snmp_status set enable = 1 where device_ip = '$device_ip' and type = 'disk' and disk = '$disk'");
					$sqr_update->execute();
					$sqr_update->finish();

					$sqr_update = $dbh->prepare("update snmp_status set value = $value, datetime = '$cur_time' where device_ip = '$device_ip' and type = 'disk' and disk = '$disk'");
					$sqr_update->execute();
					$sqr_update->finish();
				}
			}
			else
			{
				my $sqr_update = $dbh->prepare("update snmp_status set value = $value, datetime = '$cur_time' where device_ip = '$device_ip' and type = 'disk' and disk = '$disk'");
				$sqr_update->execute();
				$sqr_update->finish();
			}

		}
		else
		{
			$sqr_select = $dbh->prepare("select enable from snmp_status where device_ip = '$device_ip' and type = 'disk' and disk = '$disk'");
			$sqr_select->execute();
			$ref_select = $sqr_select->fetchrow_hashref();
			my $enable = $ref_select->{"enable"};
			$sqr_select->finish();

			if($enable == 1)
			{
				my $sqr_update = $dbh->prepare("update snmp_status set value = $value, datetime = '$cur_time' where device_ip = '$device_ip' and type = 'disk' and disk = '$disk'");
				$sqr_update->execute();
				$sqr_update->finish();
			}
			else
			{
				my $sqr_update = $dbh->prepare("update snmp_status set value = null, datetime = null where device_ip = '$device_ip' and type = 'disk' and disk = '$disk'");
				$sqr_update->execute();
				$sqr_update->finish();
			}
		}
	}
}

sub insert_into_process
{
	my($dbh,$device_ip,$name,$val,$cur_time) = @_;

	my $sqr_select = $dbh->prepare("select count(*) from snmp_check_process where device_ip = '$device_ip' and process = '$name'");
	$sqr_select->execute();
	my $ref_select = $sqr_select->fetchrow_hashref();
	my $device_num = $ref_select->{"count(*)"};
	$sqr_select->finish();

	if($device_num == 0)
	{
		my $sqr_insert = $dbh->prepare("insert into snmp_check_process (device_ip,process) values ('$device_ip','$name')");
		$sqr_insert->execute();
		$sqr_insert->finish();

		$sqr_select = $dbh->prepare("select enable from snmp_check_process where device_ip = '$device_ip' and process = '$name'");
		$sqr_select->execute();
		$ref_select = $sqr_select->fetchrow_hashref();
		my $enable = $ref_select->{"enable"};
		$sqr_select->finish();

		if($enable != 1)
		{
			if($debug == 1)
			{
				my $sqr_update = $dbh->prepare("update snmp_check_process set enable = 1 where device_ip = '$device_ip' and process = '$name'");
				$sqr_update->execute();
				$sqr_update->finish();

				$sqr_update = $dbh->prepare("update snmp_check_process set process_status = $val, datetime = '$cur_time' where device_ip = '$device_ip' and process = '$name'");
				$sqr_update->execute();
				$sqr_update->finish();
			}
		}
		else
		{
			my $sqr_update = $dbh->prepare("update snmp_check_process set process_status = $val, datetime = '$cur_time' where device_ip = '$device_ip' and process = '$name'");
			$sqr_update->execute();
			$sqr_update->finish();
		}
	}
	else
	{
		$sqr_select = $dbh->prepare("select enable from snmp_check_process where device_ip = '$device_ip' and process = '$name'");
		$sqr_select->execute();
		$ref_select = $sqr_select->fetchrow_hashref();
		my $enable = $ref_select->{"enable"};
		$sqr_select->finish();

		if($enable == 1)
		{
			my $sqr_update = $dbh->prepare("update snmp_check_process set process_status = $val, datetime = '$cur_time' where device_ip = '$device_ip' and process = '$name'");
			$sqr_update->execute();
			$sqr_update->finish();
		}
		else
		{
			my $sqr_update = $dbh->prepare("update snmp_check_process set process_status = null, datetime = null where device_ip = '$device_ip' and process = '$name'");
			$sqr_update->execute();
			$sqr_update->finish();
		}
	}
}

sub insert_into_port
{
	my($dbh,$device_ip,$port,$val,$cur_time) = @_;

	unless(defined $port)
	{
		my $sqr_update = $dbh->prepare("update snmp_check_port set port_status = $val, datetime = '$cur_time' where device_ip = '$device_ip'");
		$sqr_update->execute();
		$sqr_update->finish();
		return;
	}

	my $sqr_select = $dbh->prepare("select count(*) from snmp_check_port where device_ip = '$device_ip' and port = $port");
	$sqr_select->execute();
	my $ref_select = $sqr_select->fetchrow_hashref();
	my $device_num = $ref_select->{"count(*)"};
	$sqr_select->finish();

	if($device_num == 0)
	{
		my $sqr_insert = $dbh->prepare("insert into snmp_check_port (device_ip,port) values ('$device_ip',$port)");
		$sqr_insert->execute();
		$sqr_insert->finish();

		$sqr_select = $dbh->prepare("select enable from snmp_check_port where device_ip = '$device_ip' and port = $port");
		$sqr_select->execute();
		$ref_select = $sqr_select->fetchrow_hashref();
		my $enable = $ref_select->{"enable"};
		$sqr_select->finish();

		if($enable != 1)
		{
			if($debug == 1)
			{
				my $sqr_update = $dbh->prepare("update snmp_check_port set enable = 1 where device_ip = '$device_ip' and port = $port");
				$sqr_update->execute();
				$sqr_update->finish();

				$sqr_update = $dbh->prepare("update snmp_check_port set port_status = $val, datetime = '$cur_time' where device_ip = '$device_ip' and port = $port");
				$sqr_update->execute();
				$sqr_update->finish();
			}
		}
		else
		{
			my $sqr_update = $dbh->prepare("update snmp_check_port set port_status = $val, datetime = '$cur_time' where device_ip = '$device_ip' and port = $port");
			$sqr_update->execute();
			$sqr_update->finish();
		}
	}
	else
	{
		$sqr_select = $dbh->prepare("select enable from snmp_check_port where device_ip = '$device_ip' and port = $port");
		$sqr_select->execute();
		$ref_select = $sqr_select->fetchrow_hashref();
		my $enable = $ref_select->{"enable"};
		$sqr_select->finish();

		if($enable == 1)
		{
			my $sqr_update = $dbh->prepare("update snmp_check_port set port_status = $val, datetime = '$cur_time' where device_ip = '$device_ip' and port = $port");
			$sqr_update->execute();
			$sqr_update->finish();
		}
		else
		{
			my $sqr_update = $dbh->prepare("update snmp_check_port set port_status = null, datetime = null where device_ip = '$device_ip' and port = $port");
			$sqr_update->execute();
			$sqr_update->finish();
		}
	}
}

sub warning_func
{
	my($dbh,$cur_time,$monitor,$device_ip,$cur_val,$type,$disk) = @_;
	my $status;
	my $mail_alarm_status = -1;
	my $sms_alarm_status = -1;
	my $mail_out_interval = 0;				#邮件 是否超过时间间隔
	my $sms_out_interval = 0;				#短信 是否超过时间间隔
	my $cmd;

	if(!defined $monitor)
	{
		$monitor = "";
	}
	elsif($monitor == 1)
	{
		$monitor = "snmp";
	}
	elsif($monitor == 2)
	{
		$monitor = "ssh";
	}
	elsif($monitor == 3)
	{
		$monitor = "读文件";
	}


	if(defined $disk)
	{
		$disk =~ s/\\/\\\\/g;
	}

	if(defined $disk)
	{
		$cmd = "select mail_alarm,sms_alarm,highvalue,lowvalue,enable,unix_timestamp(mail_last_sendtime),unix_timestamp(sms_last_sendtime),send_interval from snmp_status where device_ip = '$device_ip' and type = 'disk' and disk = '$disk'";
	}
	else
	{
		$cmd = "select mail_alarm,sms_alarm,highvalue,lowvalue,enable,unix_timestamp(mail_last_sendtime),unix_timestamp(sms_last_sendtime),send_interval from snmp_status where device_ip = '$device_ip' and type = '$type'";
	}

	my $sqr_select = $dbh->prepare("$cmd");
	$sqr_select->execute();
	my $ref_select = $sqr_select->fetchrow_hashref();
	my $mail_alarm = $ref_select->{"mail_alarm"};
	my $sms_alarm = $ref_select->{"sms_alarm"};
	my $highvalue = $ref_select->{"highvalue"};
	my $lowvalue = $ref_select->{"lowvalue"};
	my $enable = $ref_select->{"enable"};
	my $mail_last_sendtime = $ref_select->{"unix_timestamp(mail_last_sendtime)"};
	my $sms_last_sendtime = $ref_select->{"unix_timestamp(sms_last_sendtime)"};
	my $send_interval = $ref_select->{"send_interval"};
	$sqr_select->finish();

    unless(defined $enable && $enable == 1)
    {
        return 1;
    }

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

	if($cur_val < 0)
	{
		$status = 0;
		if(defined $disk)
		{
			$cmd = "insert into snmp_status_warning_log (device_ip,datetime,mail_status,sms_status,monitor,type,cur_val,disk,context) values ('$device_ip','$cur_time',$mail_alarm_status,$sms_alarm_status,'$monitor','$type',$cur_val,'$disk','$type: $disk 无法得到值')";
		}
		else
		{
			$cmd = "insert into snmp_status_warning_log (device_ip,datetime,mail_status,sms_status,monitor,type,cur_val,context) values ('$device_ip','$cur_time',$mail_alarm_status,$sms_alarm_status,'$monitor','$type',$cur_val,'$type 无法得到值')";
		}

		my $sqr_insert = $dbh->prepare("$cmd");
		$sqr_insert->execute();
		$sqr_insert->finish();
	}
	elsif(defined $highvalue && defined $lowvalue && ($cur_val > $highvalue || $cur_val < $lowvalue))
	{
		$status = 2;
		my $thold;

		my $tmp_context = "";
		if($cur_val > $highvalue)
		{
			$thold = $highvalue;
			$tmp_context = "大于最大值 $highvalue";
		}
		else
		{
			$thold = $lowvalue;
			$tmp_context = "小于最小值 $lowvalue";
		}

		if(defined $disk)
		{
			$cmd = "insert into snmp_status_warning_log (device_ip,datetime,mail_status,sms_status,monitor,type,cur_val,thold,disk,context) values ('$device_ip','$cur_time',$mail_alarm_status,$sms_alarm_status,'$monitor','$type',$cur_val,$thold,'$disk','$type: $disk 超值, 当前值 $cur_val $tmp_context')";
		}
		else
		{
			$cmd = "insert into snmp_status_warning_log (device_ip,datetime,mail_status,sms_status,monitor,type,cur_val,thold,context) values ('$device_ip','$cur_time',$mail_alarm_status,$sms_alarm_status,'$monitor','$type',$cur_val,$thold,'$type 超值, 当前值 $cur_val $tmp_context')";
		}

		my $sqr_insert = $dbh->prepare("$cmd");
		$sqr_insert->execute();
		$sqr_insert->finish();
	}
	else
	{
		$status = 1;
	}

	return $status;
}

sub warning_func_process
{
	my($dbh,$cur_time,$device_ip,$process_name,$cur_val) = @_;
	my $status;
	my $mail_alarm_status = -1;
	my $sms_alarm_status = -1;
	my $mail_out_interval = 0;				#邮件 是否超过时间间隔
	my $sms_out_interval = 0;				#短信 是否超过时间间隔

	my $sqr_select = $dbh->prepare("select mail_alarm,sms_alarm,unix_timestamp(mail_last_sendtime),unix_timestamp(sms_last_sendtime),send_interval from snmp_check_process where device_ip = '$device_ip'");
	$sqr_select->execute();
	my $ref_select = $sqr_select->fetchrow_hashref();
	my $mail_alarm = $ref_select->{"mail_alarm"};
	my $sms_alarm = $ref_select->{"sms_alarm"};
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

    if(! defined $process_name)
    {
		$status = 0;
		my $sqr_insert = $dbh->prepare("insert into snmp_check_process_warning_log(device_ip,datetime,val,mail_status,sms_status,context) values ('$device_ip','$cur_time',$cur_val,$mail_alarm_status,$sms_alarm_status,'$device_ip 所有进程无法得到值')");
		$sqr_insert->execute();
		$sqr_insert->finish();
	}
	elsif($cur_val < 0)
	{
		$status = 0;
		my $sqr_insert = $dbh->prepare("insert into snmp_check_process_warning_log(device_ip,datetime,process,val,mail_status,sms_status,context) values ('$device_ip','$cur_time','$process_name',$cur_val,$mail_alarm_status,$sms_alarm_status,'$process_name 无法得到值')");
		$sqr_insert->execute();
		$sqr_insert->finish();
	}
	elsif($cur_val == 0)
	{
		$status = 2;
		my $sqr_insert = $dbh->prepare("insert into snmp_check_process_warning_log(device_ip,datetime,process,val,mail_status,sms_status,context) values ('$device_ip','$cur_time','$process_name',$cur_val,$mail_alarm_status,$sms_alarm_status,'$process_name 进程不存在')");
		$sqr_insert->execute();
		$sqr_insert->finish();
	}
	else
	{
		$status = 1;
	}

	return $status;
}

sub warning_func_port
{
	my($dbh,$cur_time,$device_ip,$port,$cur_val) = @_;
	my $status;
	my $mail_alarm_status = -1;
	my $sms_alarm_status = -1;
	my $mail_out_interval = 0;				#邮件 是否超过时间间隔
	my $sms_out_interval = 0;				#短信 是否超过时间间隔

	my $sqr_select = $dbh->prepare("select mail_alarm,sms_alarm,unix_timestamp(mail_last_sendtime),unix_timestamp(sms_last_sendtime),send_interval from snmp_check_port where device_ip = '$device_ip'");
	$sqr_select->execute();
	my $ref_select = $sqr_select->fetchrow_hashref();
	my $mail_alarm = $ref_select->{"mail_alarm"};
	my $sms_alarm = $ref_select->{"sms_alarm"};
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

    if(! defined $port)
    {
		$status = 0;
		my $sqr_insert = $dbh->prepare("insert into snmp_check_port_warning_log(device_ip,datetime,val,mail_status,sms_status,context) values ('$device_ip','$cur_time',$cur_val,$mail_alarm_status,$sms_alarm_status,'$device_ip 所有端口无法得到值')");
		$sqr_insert->execute();
		$sqr_insert->finish();
	}
	elsif($cur_val < 0)
	{
		$status = 0;
		my $sqr_insert = $dbh->prepare("insert into snmp_check_port_warning_log(device_ip,datetime,port,val,mail_status,sms_status,context) values ('$device_ip','$cur_time',$port,$cur_val,$mail_alarm_status,$sms_alarm_status,'$port 无法得到值')");
		$sqr_insert->execute();
		$sqr_insert->finish();
	}
	elsif($cur_val == 0)
	{
		$status = 2;
		my $sqr_insert = $dbh->prepare("insert into snmp_check_port_warning_log(device_ip,datetime,port,val,mail_status,sms_status,context) values ('$device_ip','$cur_time',$port,$cur_val,$mail_alarm_status,$sms_alarm_status,'$port 端口未扫描到')");
		$sqr_insert->execute();
		$sqr_insert->finish();
	}
	else
	{
		$status = 1;
	}

	return $status;
}

sub update_rrd
{
	my($dbh,$device_ip,$type_name,$value,$disk,$start_time) = @_;

	if(!defined $value || $value < 0)
	{
		$value = 'U';
	}

	my $enable;
	my $rrdfile;

	if(defined $disk)
	{
		$disk =~ s/\\/\\\\/g;
		my $sqr_select = $dbh->prepare("select enable,rrdfile from snmp_status where device_ip = '$device_ip' and type = 'disk' and disk = '$disk'");
		$sqr_select->execute();
		my $ref_select = $sqr_select->fetchrow_hashref();
		$enable = $ref_select->{"enable"};
		$rrdfile = $ref_select->{"rrdfile"};
		$sqr_select->finish();
	}
	else
	{
		my $sqr_select = $dbh->prepare("select enable,rrdfile from snmp_status where device_ip = '$device_ip' and type = '$type_name'");
		$sqr_select->execute();
		my $ref_select = $sqr_select->fetchrow_hashref();
		$enable = $ref_select->{"enable"};
		$rrdfile = $ref_select->{"rrdfile"};
		$sqr_select->finish();
	}

	unless(defined $start_time)
	{
		$start_time = time;
	}

	$start_time = (floor($start_time/300))*300;

	my $dir = "/opt/freesvr/nm/$device_ip";
	if(! -e $dir)
	{
		mkdir $dir,0755;
	}

	$dir = "/opt/freesvr/nm/$device_ip/device_status";
	if(! -e $dir)
	{
		mkdir $dir,0755;
	}

	my $file = $dir."/$type_name.rrd";

	unless(defined $enable && $enable == 1) 
	{
		unless(defined $rrdfile && -e $rrdfile && $rrdfile eq $file)
		{
			if(defined $rrdfile && -e $rrdfile)
			{
				unlink $rrdfile;
				my $update_cmd;
				if(defined $disk)
				{
					$update_cmd = "update snmp_status set rrdfile = null where device_ip = '$device_ip' and type = 'disk' and disk = '$disk'";
				}
				else
				{
					$update_cmd = "update snmp_status set rrdfile = null where device_ip = '$device_ip' and type = '$type_name'";
				}
				my $sqr_update = $dbh->prepare("$update_cmd");
				$sqr_update->execute();
				$sqr_update->finish();
				return;
			}
		}
        else
        {
            $value = 'U';
            RRDs::update(
                    $file,       
                    '-t', 'val',     
                    '--', join(':', "$start_time", "$value"), 
                    ); 
            return;
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
				'RRA:AVERAGE:0.5:288:65',
				'RRA:AVERAGE:0.5:2016:55',
				'RRA:MAX:0.5:1:576',
				'RRA:MAX:0.5:12:192',
				'RRA:MAX:0.5:288:65',
				'RRA:MAX:0.5:2016:55',
				'RRA:MIN:0.5:1:576',
				'RRA:MIN:0.5:12:192',
				'RRA:MIN:0.5:288:65',
				'RRA:MIN:0.5:2016:55',
				);
	}

	unless(defined $rrdfile && $rrdfile eq $file) 
	{
		my $sqr_update;
		if(defined $disk)
		{
			$sqr_update = $dbh->prepare("update snmp_status set rrdfile = '$file' where device_ip = '$device_ip' and type = 'disk' and disk = '$disk'");
		}
		else
		{
			$sqr_update = $dbh->prepare("update snmp_status set rrdfile = '$file' where device_ip = '$device_ip' and type = '$type_name'");
		}
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

sub update_rrd_process
{
	my($dbh,$device_ip,$name,$value,$start_time) = @_;

	if(!defined $value || $value < 0)
	{
		$value = 'U';
	}

	my $sqr_select = $dbh->prepare("select enable,rrdfile from snmp_check_process where device_ip = '$device_ip' and process = '$name'");
	$sqr_select->execute();
	my $ref_select = $sqr_select->fetchrow_hashref();
	my $enable = $ref_select->{"enable"};
	my $rrdfile = $ref_select->{"rrdfile"};
	$sqr_select->finish();
	
	unless(defined $start_time)
	{
		$start_time = time;
	}

	$start_time = (floor($start_time/300))*300;

	my $dir = "/opt/freesvr/nm/$device_ip";
	if(! -e $dir)
	{
		mkdir $dir,0755;
	}

	$dir = "/opt/freesvr/nm/$device_ip/process_status";
	if(! -e $dir)
	{
		mkdir $dir,0755;
	}

	my $file = $dir."/$name.rrd";

	unless(defined $enable && $enable == 1) 
	{
		unless(defined $rrdfile && -e $rrdfile && $rrdfile eq $file)
		{
			if(defined $rrdfile && -e $rrdfile)
			{
				unlink $rrdfile;
				my $sqr_update = $dbh->prepare("update snmp_check_process set rrdfile = null where device_ip = '$device_ip' and process = '$name'");
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
				'RRA:AVERAGE:0.5:288:65',
				'RRA:AVERAGE:0.5:2016:55',
				'RRA:MAX:0.5:1:576',
				'RRA:MAX:0.5:12:192',
				'RRA:MAX:0.5:288:65',
				'RRA:MAX:0.5:2016:55',
				'RRA:MIN:0.5:1:576',
				'RRA:MIN:0.5:12:192',
				'RRA:MIN:0.5:288:65',
				'RRA:MIN:0.5:2016:55',
				);
	}

	unless(defined $rrdfile && $rrdfile eq $file) 
	{
		my $sqr_update = $dbh->prepare("update snmp_check_process set rrdfile = '$file' where device_ip = '$device_ip' and process = '$name'");
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

sub update_rrd_port
{
	my($dbh,$device_ip,$port,$value,$start_time) = @_;

	if(!defined $value || $value < 0)
	{
		$value = 'U';
	}

	my $sqr_select = $dbh->prepare("select enable,rrdfile from snmp_check_port where device_ip = '$device_ip' and port = $port");
	$sqr_select->execute();
	my $ref_select = $sqr_select->fetchrow_hashref();
	my $enable = $ref_select->{"enable"};
	my $rrdfile = $ref_select->{"rrdfile"};
	$sqr_select->finish();
	
	unless(defined $start_time)
	{
		$start_time = time;
	}

	$start_time = (floor($start_time/300))*300;

	my $dir = "/opt/freesvr/nm/$device_ip";
	if(! -e $dir)
	{
		mkdir $dir,0755;
	}

	$dir = "/opt/freesvr/nm/$device_ip/port_status";
	if(! -e $dir)
	{
		mkdir $dir,0755;
	}

	my $file = $dir."/$port.rrd";

	unless(defined $enable && $enable == 1) 
	{
		unless(defined $rrdfile && -e $rrdfile && $rrdfile eq $file)
		{
			if(defined $rrdfile && -e $rrdfile)
			{
				unlink $rrdfile;
				my $sqr_update = $dbh->prepare("update snmp_check_port set rrdfile = null where device_ip = '$device_ip' and port = '$port'");
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
				'RRA:AVERAGE:0.5:288:65',
				'RRA:AVERAGE:0.5:2016:55',
				'RRA:MAX:0.5:1:576',
				'RRA:MAX:0.5:12:192',
				'RRA:MAX:0.5:288:65',
				'RRA:MAX:0.5:2016:55',
				'RRA:MIN:0.5:1:576',
				'RRA:MIN:0.5:12:192',
				'RRA:MIN:0.5:288:65',
				'RRA:MIN:0.5:2016:55',
				);
	}

	unless(defined $rrdfile && $rrdfile eq $file) 
	{
		my $sqr_update = $dbh->prepare("update snmp_check_port set rrdfile = '$file' where device_ip = '$device_ip' and port = $port");
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

sub clean_cache_val
{
	my($dbh) = @_;

    my $sqr_delete = $dbh->prepare("delete from snmp_status_cache where datetime<'$time_now_str'");
    $sqr_delete->execute();
    $sqr_delete->finish();
}

sub set_device_nan_val
{
	my($dbh) = @_;

	my %ip_status;
	my $sqr_select = $dbh->prepare("select device_ip,device_type,monitor from servers where monitor!=0 and device_ip not in (select device_ip from snmp_status where type = 'cpu' group by device_ip) group by device_ip");
	$sqr_select->execute();
	while(my $ref_select = $sqr_select->fetchrow_hashref())
	{
		my $device_ip = $ref_select->{"device_ip"};
		my $device_type = $ref_select->{"device_type"};
		my $monitor = $ref_select->{"monitor"};

		if(($monitor==1 && ($device_type==2 || $device_type==4 || $device_type==11 || $device_type==20 || $device_type==30 )) || $monitor==2 || $monitor==3)
		{
			unless(exists $ip_status{$device_ip})
			{
				$ip_status{$device_ip} = 1;
			}

			&insert_into_nondisk($dbh,$device_ip,'cpu',-100,$time_now_str);
			&update_rrd($dbh,$device_ip,'cpu',-100,undef,undef);
			my $tmp_status = &warning_func($dbh,$time_now_str,$monitor,$device_ip,-100,'cpu',undef);
			if(($ip_status{$device_ip} == 1 && $tmp_status != 1) || ($ip_status{$device_ip} != 0 && $tmp_status == 0))
			{
				$ip_status{$device_ip} = $tmp_status;
			}

			if($debug == 1)
			{
				print "主机 $device_ip cpu:取不到值\n";
			}
		}
	}
	$sqr_select->finish();

	$sqr_select = $dbh->prepare("select device_ip,device_type,monitor from servers where monitor!=0 and device_ip not in (select device_ip from snmp_status where type = 'cpu_io' group by device_ip) group by device_ip");
	$sqr_select->execute();
	while(my $ref_select = $sqr_select->fetchrow_hashref())
	{
		my $device_ip = $ref_select->{"device_ip"};
		my $device_type = $ref_select->{"device_type"};
		my $monitor = $ref_select->{"monitor"};

#		if(($monitor==1 && ($device_type==2 || $device_type==4 || $device_type==20 || $device_type==30)) || $monitor==2 || $monitor==3)
		if(($monitor==1 && $device_type==2) || $monitor==2 || $monitor==3)
		{
			unless(exists $ip_status{$device_ip})
			{
				$ip_status{$device_ip} = 1;
			}

			&insert_into_nondisk($dbh,$device_ip,'cpu_io',-100,$time_now_str);
			&update_rrd($dbh,$device_ip,'cpu_io',-100,undef,undef);
			my $tmp_status = &warning_func($dbh,$time_now_str,$monitor,$device_ip,-100,'cpu_io',undef);
			if(($ip_status{$device_ip} == 1 && $tmp_status != 1) || ($ip_status{$device_ip} != 0 && $tmp_status == 0))
			{
				$ip_status{$device_ip} = $tmp_status;
			}

			if($debug == 1)
			{
				print "主机 $device_ip cpu_io:取不到值\n";
			}
		}
	}
	$sqr_select->finish();

	$sqr_select = $dbh->prepare("select device_ip,device_type,monitor from servers where monitor!=0 and device_ip not in (select device_ip from snmp_status where type = 'memory' group by device_ip) group by device_ip");
	$sqr_select->execute();
	while(my $ref_select = $sqr_select->fetchrow_hashref())
	{
		my $device_ip = $ref_select->{"device_ip"};
		my $device_type = $ref_select->{"device_type"};
		my $monitor = $ref_select->{"monitor"};

		if(($monitor==1 && ($device_type==2 || $device_type==4 || $device_type==11 || $device_type==20 || $device_type==30)) || $monitor==2 || $monitor==3)
		{
			unless(exists $ip_status{$device_ip})
			{
				$ip_status{$device_ip} = 1;
			}

			&insert_into_nondisk($dbh,$device_ip,'memory',-100,$time_now_str);
			&update_rrd($dbh,$device_ip,'memory',-100,undef,undef);
			my $tmp_status = &warning_func($dbh,$time_now_str,$monitor,$device_ip,-100,'memory',undef);
			if(($ip_status{$device_ip} == 1 && $tmp_status != 1) || ($ip_status{$device_ip} != 0 && $tmp_status == 0))
			{
				$ip_status{$device_ip} = $tmp_status;
			}

			if($debug == 1)
			{
				print "主机 $device_ip memory:取不到值\n";
			}
		}
	}
	$sqr_select->finish();

	$sqr_select = $dbh->prepare("select device_ip,device_type,monitor from servers where monitor!=0 and device_ip not in (select device_ip from snmp_status where type = 'disk' group by device_ip) group by device_ip");
	$sqr_select->execute();
	while(my $ref_select = $sqr_select->fetchrow_hashref())
	{
		my $device_ip = $ref_select->{"device_ip"};
		my $device_type = $ref_select->{"device_type"};
		my $monitor = $ref_select->{"monitor"};

		if(($monitor==1 && ($device_type==2 || $device_type==4 || $device_type==20 || $device_type==30)) || $monitor==2 || $monitor==3)
		{
			unless(exists $ip_status{$device_ip})
			{
				$ip_status{$device_ip} = 1;
			}

			&insert_into_disk($dbh,$device_ip,undef,-100,$time_now_str);
			my $tmp_status = &warning_func($dbh,$time_now_str,$monitor,$device_ip,-100,'disk',undef);
			if(($ip_status{$device_ip} == 1 && $tmp_status != 1) || ($ip_status{$device_ip} != 0 && $tmp_status == 0))
			{
				$ip_status{$device_ip} = $tmp_status;
			}

			if($debug == 1)
			{
				print "主机 $device_ip disk:取不到值\n";
			}
		}
	}
	$sqr_select->finish();

	$sqr_select = $dbh->prepare("select snmp_status.device_ip,type,disk,value,servers.monitor from snmp_status left join servers on snmp_status.device_ip = servers.device_ip where snmp_status.datetime < '$time_now_str' and servers.monitor!=0");
	$sqr_select->execute();
	while(my $ref_select = $sqr_select->fetchrow_hashref())
	{
		my $device_ip = $ref_select->{"device_ip"};
		my $type = $ref_select->{"type"};
		my $disk = $ref_select->{"disk"};
        my $value = $ref_select->{"value"};
		my $monitor = $ref_select->{"monitor"};

		unless(defined $disk) {$disk = undef;}

		unless(exists $ip_status{$device_ip})
		{
			$ip_status{$device_ip} = 1;
		}

		if($type ne "disk")
		{
			&insert_into_nondisk($dbh,$device_ip,$type,-100,$time_now_str);
			&update_rrd($dbh,$device_ip,$type,-100,undef,undef);
            my $tmp_status = 1;

            if($monitor==1 && $value>=0)
            {
                my $sqr_insert = $dbh->prepare("insert into snmp_status_warning_log (device_ip,datetime,mail_status,sms_status,monitor,type,cur_val,context) values ('$device_ip','$time_now_str',0,0,'snmp','$type',-100,'$type 无法得到值')");
                $sqr_insert->execute();
                $sqr_insert->finish();
            }
            else
            {
                $tmp_status = &warning_func($dbh,$time_now_str,$monitor,$device_ip,-100,$type,undef);
            }

			if(($ip_status{$device_ip} == 1 && $tmp_status != 1) || ($ip_status{$device_ip} != 0 && $tmp_status == 0))
			{
				$ip_status{$device_ip} = $tmp_status;
			}

			if($debug == 1)
			{
				print "主机 $device_ip $type:取不到值\n";
			}
		}
		else
		{
            my $tmp_status = 1;
			&insert_into_disk($dbh,$device_ip,$disk,-100,$time_now_str);
			if(defined $disk)
			{
				my $disk_name = $disk;
				$disk_name =~ s/^\///;
				$disk_name =~ s/\//-/g;

				if($disk_name eq ""){$disk_name = $root_path;}

				&update_rrd($dbh,$device_ip,$disk_name,-100,$disk,undef);
			}

            if($monitor==1 && $value>=0)
            {
                my $sqr_insert = $dbh->prepare("insert into snmp_status_warning_log (device_ip,datetime,mail_status,sms_status,monitor,type,cur_val,disk,context) values ('$device_ip','$time_now_str',0,0,'snmp','disk',-100,'$disk','disk: $disk 无法得到值')");
                $sqr_insert->execute();
                $sqr_insert->finish();
            }
            else
            {
                $tmp_status = &warning_func($dbh,$time_now_str,$monitor,$device_ip,-100,'disk',$disk);
            }

			if(($ip_status{$device_ip} == 1 && $tmp_status != 1) || ($ip_status{$device_ip} != 0 && $tmp_status == 0))
			{
				$ip_status{$device_ip} = $tmp_status;
			}

			if($debug == 1)
			{
				if(defined $disk)
				{
					print "主机 $device_ip disk $disk:取不到值\n";
				}
				else
				{
					print "主机 $device_ip disk:取不到值\n";
				}
			}
		}
	}
	$sqr_select->finish();

	$sqr_select = $dbh->prepare("select snmp_status.device_ip from snmp_status left join servers on snmp_status.device_ip = servers.device_ip where servers.monitor!=0 group by device_ip HAVING max(value) < 0");
	$sqr_select->execute();
	while(my $ref_select = $sqr_select->fetchrow_hashref())
	{
		my $device_ip = $ref_select->{"device_ip"};
		
		my $mail_alarm_status = 0;
		my $sms_alarm_status = 0;
		my $monitor;
		my $sqr_select_status = $dbh->prepare("select mail_status,sms_status,monitor from snmp_status_warning_log where device_ip = '$device_ip' and datetime = '$time_now_str'");
		$sqr_select_status->execute();
		while(my $ref_select_status = $sqr_select_status->fetchrow_hashref())
		{
			my $mail_status = $ref_select_status->{"mail_status"};
			my $sms_status = $ref_select_status->{"sms_status"};
			$monitor = $ref_select_status->{"monitor"};

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
		
		my $sqr_delete = $dbh->prepare("delete from snmp_status_warning_log where device_ip = '$device_ip' and datetime = '$time_now_str'");
		$sqr_delete->execute();
		$sqr_delete->finish();

		my $sqr_insert = $dbh->prepare("insert into snmp_status_warning_log (device_ip,datetime,mail_status,sms_status,monitor,cur_val,context) values ('$device_ip','$time_now_str',$mail_alarm_status,$sms_alarm_status,'$monitor',-100,'无法得到值')");
		$sqr_insert->execute();
		$sqr_insert->finish();
	}
	$sqr_select->finish();

	foreach my $device_ip(keys %ip_status)
	{
		my $sqr_update = $dbh->prepare("update servers set status = $ip_status{$device_ip} where device_ip = '$device_ip' and monitor!=0");
		$sqr_update->execute();
		$sqr_update->finish();
	}
}

sub set_process_nan_val
{
	my($dbh) = @_;
	my %ip_status;

	my $sqr_select = $dbh->prepare("select device_ip from servers where monitor=3 and device_ip not in (select device_ip from snmp_check_process group by device_ip) group by device_ip");
	$sqr_select->execute();
	while(my $ref_select = $sqr_select->fetchrow_hashref())
	{
        my $device_ip = $ref_select->{"device_ip"};
        my $tmp_status = &warning_func_process($dbh,$time_now_str,$device_ip,undef,-1);

        unless(exists $ip_status{$device_ip})
        {
            $ip_status{$device_ip}=1;
        }

        if(($ip_status{$device_ip} == 1 && $tmp_status != 1) || ($ip_status{$device_ip} != 0 && $tmp_status == 0))
        {
            $ip_status{$device_ip} = $tmp_status;
        }

		if($debug == 1)
		{
			print "主机 $device_ip 进程信息没有取到\n";
		}
	}
	$sqr_select->finish();

	$sqr_select = $dbh->prepare("select snmp_check_process.device_ip,process from snmp_check_process left join servers on snmp_check_process.device_ip = servers.device_ip where snmp_check_process.datetime < '$time_now_str' and servers.monitor=3");
	$sqr_select->execute();
	while(my $ref_select = $sqr_select->fetchrow_hashref())
	{
		my $device_ip = $ref_select->{"device_ip"};
		my $process_name = $ref_select->{"process"};

		unless(defined $process_name){next;}

		&insert_into_process($dbh,$device_ip,$process_name,-1,$time_now_str);
		&update_rrd_process($dbh,$device_ip,$process_name,-1,$time_now_utc);
        my $tmp_status = &warning_func_process($dbh,$time_now_str,$device_ip,$process_name,-1);

        unless(exists $ip_status{$device_ip})
        {
            $ip_status{$device_ip}=1;
        }

        if(($ip_status{$device_ip} == 1 && $tmp_status != 1) || ($ip_status{$device_ip} != 0 && $tmp_status == 0))
        {
            $ip_status{$device_ip} = $tmp_status;
        }

		if($debug == 1)
		{
			print "主机 $device_ip 进程: $process_name 没有取到\n";
		}
	}
	$sqr_select->finish();

	$sqr_select = $dbh->prepare("select snmp_check_process.device_ip from snmp_check_process left join servers on snmp_check_process.device_ip = servers.device_ip where servers.monitor=3 group by device_ip HAVING max(process_status) < 0");
	$sqr_select->execute();
	while(my $ref_select = $sqr_select->fetchrow_hashref())
	{
        my $device_ip = $ref_select->{"device_ip"};
		
		my $mail_alarm_status = 0;
		my $sms_alarm_status = 0;
		my $monitor;
		my $sqr_select_status = $dbh->prepare("select mail_status,sms_status from snmp_check_process_warning_log where device_ip = '$device_ip' and datetime = '$time_now_str'");
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
		
		my $sqr_delete = $dbh->prepare("delete from snmp_check_process_warning_log where device_ip = '$device_ip' and datetime = '$time_now_str'");
		$sqr_delete->execute();
		$sqr_delete->finish();

		my $sqr_insert = $dbh->prepare("insert into snmp_check_process_warning_log(device_ip,datetime,val,mail_status,sms_status,context) values ('$device_ip','$time_now_str',-1,$mail_alarm_status,$sms_alarm_status,'$device_ip 所有进程无法得到值')");
		$sqr_insert->execute();
		$sqr_insert->finish();
	}
	$sqr_select->finish();

	foreach my $device_ip(keys %ip_status)
	{
		my $sqr_update = $dbh->prepare("update servers set status = $ip_status{$device_ip} where device_ip = '$device_ip' and monitor!=0");
		$sqr_update->execute();
		$sqr_update->finish();
	}
}

sub set_port_nan_val
{
	my($dbh) = @_;
	my %ip_status;

	my $sqr_select = $dbh->prepare("select device_ip from servers where monitor=3 and device_ip not in (select device_ip from snmp_check_port group by device_ip) group by device_ip");
	$sqr_select->execute();
	while(my $ref_select = $sqr_select->fetchrow_hashref())
	{
        my $device_ip = $ref_select->{"device_ip"};
        my $tmp_status = &warning_func_port($dbh,$time_now_str,$device_ip,undef,-1);

        unless(exists $ip_status{$device_ip})
        {
            $ip_status{$device_ip}=1;
        }

        if(($ip_status{$device_ip} == 1 && $tmp_status != 1) || ($ip_status{$device_ip} != 0 && $tmp_status == 0))
        {
            $ip_status{$device_ip} = $tmp_status;
        }

		if($debug == 1)
		{
			print "主机 $device_ip 端口信息没有取到\n";
		}
	}
	$sqr_select->finish();

	$sqr_select = $dbh->prepare("select snmp_check_port.device_ip,snmp_check_port.port from snmp_check_port left join servers on snmp_check_port.device_ip = servers.device_ip where snmp_check_port.datetime<'$time_now_str' and servers.monitor=3");
	$sqr_select->execute();
	while(my $ref_select = $sqr_select->fetchrow_hashref())
	{
		my $device_ip = $ref_select->{"device_ip"};
		my $port = $ref_select->{"port"};

		unless(defined $port){next;}

        &insert_into_port($dbh,$device_ip,$port,-1,$time_now_str);
		&update_rrd_port($dbh,$device_ip,$port,-1,$time_now_utc);
        my $tmp_status = &warning_func_port($dbh,$time_now_str,$device_ip,$port,-1);

        unless(exists $ip_status{$device_ip})
        {
            $ip_status{$device_ip}=1;
        }

        if(($ip_status{$device_ip} == 1 && $tmp_status != 1) || ($ip_status{$device_ip} != 0 && $tmp_status == 0))
        {
            $ip_status{$device_ip} = $tmp_status;
        }

		if($debug == 1)
		{
			print "主机 $device_ip 端口: $port 没有取到\n";
		}
	}
	$sqr_select->finish();

	$sqr_select = $dbh->prepare("select snmp_check_port.device_ip from snmp_check_port left join servers on snmp_check_port.device_ip = servers.device_ip where servers.monitor=3 group by device_ip HAVING max(port_status) < 0");
	$sqr_select->execute();
	while(my $ref_select = $sqr_select->fetchrow_hashref())
	{
        my $device_ip = $ref_select->{"device_ip"};
		
		my $mail_alarm_status = 0;
		my $sms_alarm_status = 0;
		my $monitor;
		my $sqr_select_status = $dbh->prepare("select mail_status,sms_status from snmp_check_port_warning_log where device_ip = '$device_ip' and datetime = '$time_now_str'");
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
		
		my $sqr_delete = $dbh->prepare("delete from snmp_check_port_warning_log where device_ip = '$device_ip' and datetime = '$time_now_str'");
		$sqr_delete->execute();
		$sqr_delete->finish();

		my $sqr_insert = $dbh->prepare("insert into snmp_check_port_warning_log(device_ip,datetime,val,mail_status,sms_status,context) values ('$device_ip','$time_now_str',-1,$mail_alarm_status,$sms_alarm_status,'$device_ip 所有端口无法得到值')");
		$sqr_insert->execute();
		$sqr_insert->finish();
	}
	$sqr_select->finish();

	foreach my $device_ip(keys %ip_status)
	{
		my $sqr_update = $dbh->prepare("update servers set status = $ip_status{$device_ip} where device_ip = '$device_ip' and monitor!=0");
		$sqr_update->execute();
		$sqr_update->finish();
	}
}

sub alarm_process
{
	my $dbh=DBI->connect("DBI:mysql:database=audit_sec;host=localhost;mysql_connect_timeout=5",$mysql_user,$mysql_passwd,{RaiseError=>1});

	my $utf8 = $dbh->prepare("set names utf8");
	$utf8->execute();
	$utf8->finish();

	my $sqr_select = $dbh->prepare("select monitor,device_type from servers where device_ip = '$host' and monitor!=0");
	$sqr_select->execute();
	my $ref_select = $sqr_select->fetchrow_hashref();
	my $monitor = $ref_select->{"monitor"};
	my $device_type = $ref_select->{"device_type"};
	$sqr_select->finish();

	my $only_cpu_mem = 0;
	if($device_type == 11)
	{
		$only_cpu_mem = 1;
	}

	if(!defined $monitor)
	{
		$monitor = "";
	}
	elsif($monitor == 1)
	{
		$monitor = "snmp";
	}
	elsif($monitor == 2)
	{
		$monitor = "ssh";
	}
	elsif($monitor == 3)
	{
		$monitor = "读文件";
	}

	&err_process($dbh,$host,1,"程序超时"); 
	exit;
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
