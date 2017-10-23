#!/usr/bin/perl
use warnings;
use strict;
use DBI;
use DBD::mysql;
use XML::Simple;
use RRDs;
use Crypt::CBC;
use MIME::Base64;
use POSIX qw/ceil floor/;

#apache cpu 记录的是 进程所占时间的百分比
#对于 apache cpu 累计时间可能会有减少的情况, 原因可能是某些进程结束消失, 导致总时间有减少..
#apache 是基于进程的, 可能在计算cpu总时间时存在问题
#程序中目前的处理办法是发生此种情况 认为cpu时间变化率为0
#apache traffic 单位是kB
#apache request 单位是条数

our $debug = 1;
our $max_process_num = 2;
our $exist_process = 0;
our %device_info;
our @device_arr;

our $time_now_utc = time;
our($min,$hour,$mday,$mon,$year) = (localtime $time_now_utc)[1..5];
($min,$hour,$mday,$mon,$year) = (sprintf("%02d", $min),sprintf("%02d", $hour),sprintf("%02d", $mday),sprintf("%02d", $mon + 1),$year+1900);
our $time_now_str = "$year$mon$mday$hour$min"."00";

unless(-e "./app_errlog_cache")
{
    mkdir "./app_errlog_cache",0755;
}

our($mysql_user,$mysql_passwd) = &get_local_mysql_config();
my $dbh=DBI->connect("DBI:mysql:database=audit_sec;host=localhost;mysql_connect_timeout=5",$mysql_user,$mysql_passwd,{RaiseError=>1});

my $utf8 = $dbh->prepare("set names utf8");
$utf8->execute();
$utf8->finish();

my $sqr_select = $dbh->prepare("select * from app_config where enable = 1");
$sqr_select->execute();
while(my $ref_select = $sqr_select->fetchrow_hashref())
{
	my $device_ip = $ref_select->{"device_ip"};
	my $app_name = $ref_select->{"app_name"};
    my $port = $ref_select->{"port"};
	my $username = $ref_select->{"username"};
	my $password = $ref_select->{"password"};

	unless(defined $device_ip && ($device_ip =~ /(\d{1,3}\.){3}\d{1,3}/ || $device_ip eq "localhost"))
	{
		next;
	}

	unless(exists $device_info{$device_ip})
	{
		my %tmp;
		$device_info{$device_ip} = \%tmp;
	}
    
    unless(exists $device_info{$device_ip}->{$port})
    {
        my %tmp;
        $device_info{$device_ip}->{$port} = \%tmp;
    }

	unless(exists $device_info{$device_ip}->{$port}->{$app_name})
	{
		my @tmp;
		if($app_name eq "apache")
		{
            my $last_traffic = undef;
            my $last_traffic_time = undef;
            my $last_cpu = undef;
            my $last_cpu_time = undef;
            my $last_request = undef;
            my $last_request_time = undef;

			my $sqr_cache_select = $dbh->prepare("select app_type,unix_timestamp(datetime),last_value from app_cache where device_ip='$device_ip' and port=$port and app_name='apache'");
			$sqr_cache_select->execute();
			while(my $ref_cache_select = $sqr_cache_select->fetchrow_hashref())
            {
                my $app_type = $ref_cache_select->{"app_type"};

                if($app_type eq "apache_traffic")
                {
                    $last_traffic = $ref_cache_select->{"last_value"};
                    $last_traffic_time = $ref_cache_select->{"unix_timestamp(datetime)"};
                }
                elsif($app_type eq "apache_cpu")
                {
                    $last_cpu = $ref_cache_select->{"last_value"};
                    $last_cpu_time = $ref_cache_select->{"unix_timestamp(datetime)"};
                }
                elsif($app_type eq "apache_request")
                {
                    $last_request = $ref_cache_select->{"last_value"};
                    $last_request_time = $ref_cache_select->{"unix_timestamp(datetime)"};
                }
            }
			$sqr_cache_select->finish();

			unless( (defined $last_traffic && $last_traffic =~ /^[\d\.]+$/) &&
                    (defined $last_traffic_time && $last_traffic_time =~ /^\d+$/) &&
                    (defined $last_cpu && $last_cpu =~ /^[\d\.]+$/) &&
                    (defined $last_cpu_time && $last_cpu_time =~ /^\d+$/) &&
                    (defined $last_request && $last_request =~ /^[\d\.]+$/) &&
                    (defined $last_request_time && $last_request_time =~ /^\d+$/))
			{
                $last_traffic = undef;
                $last_traffic_time = undef;
                $last_cpu = undef;
                $last_cpu_time = undef;
                $last_request = undef;
                $last_request_time = undef;
			}

			@tmp = ($last_traffic,$last_request_time,$last_cpu,$last_cpu_time,$last_request,$last_request_time);
		}
		elsif($app_name eq "mysql")
		{
            my $last_questions = undef;
            my $last_questions_time = undef;

			my $sqr_cache_select = $dbh->prepare("select app_type,unix_timestamp(datetime),last_value from app_cache where device_ip='$device_ip' and port=$port and app_name='mysql'");
			$sqr_cache_select->execute();
			while(my $ref_cache_select = $sqr_cache_select->fetchrow_hashref())
            {
                my $app_type = $ref_cache_select->{"app_type"};

                if($app_type eq "mysql_questions")
                {
                    $last_questions = $ref_cache_select->{"last_value"};
                    $last_questions_time = $ref_cache_select->{"unix_timestamp(datetime)"};
                }
            }
			$sqr_cache_select->finish();

            unless( (defined $last_questions && $last_questions =~ /^[\d\.]+$/) &&
                    (defined $last_questions_time && $last_questions_time =~ /^\d+$/))
			{
                $last_questions = undef;
                $last_questions_time = undef;
			}

			@tmp = ($username,$password,$last_questions,$last_questions_time);
		}
        elsif($app_name eq "tomcat")
		{
            my $last_traffic = undef;
            my $last_traffic_time = undef;
            my $last_cpu = undef;
            my $last_cpu_time = undef;
            my $last_request = undef;
            my $last_request_time = undef;

			my $sqr_cache_select = $dbh->prepare("select app_type,unix_timestamp(datetime),last_value from app_cache where device_ip='$device_ip' and port=$port and app_name='tomcat'");
			$sqr_cache_select->execute();
			while(my $ref_cache_select = $sqr_cache_select->fetchrow_hashref())
            {
                my $app_type = $ref_cache_select->{"app_type"};

                if($app_type eq "tomcat_traffic")
                {
                    $last_traffic = $ref_cache_select->{"last_value"};
                    $last_traffic_time = $ref_cache_select->{"unix_timestamp(datetime)"};
                }
                elsif($app_type eq "tomcat_cpu")
                {
                    $last_cpu = $ref_cache_select->{"last_value"};
                    $last_cpu_time = $ref_cache_select->{"unix_timestamp(datetime)"};
                }
                elsif($app_type eq "tomcat_request")
                {
                    $last_request = $ref_cache_select->{"last_value"};
                    $last_request_time = $ref_cache_select->{"unix_timestamp(datetime)"};
                }
            }
			$sqr_cache_select->finish();

			unless( (defined $last_traffic && $last_traffic =~ /^[\d\.]+$/) &&
                    (defined $last_traffic_time && $last_traffic_time =~ /^\d+$/) &&
                    (defined $last_cpu && $last_cpu =~ /^[\d\.]+$/) &&
                    (defined $last_cpu_time && $last_cpu_time =~ /^\d+$/) &&
                    (defined $last_request && $last_request =~ /^[\d\.]+$/) &&
                    (defined $last_request_time && $last_request_time =~ /^\d+$/))
			{
                $last_traffic = undef;
                $last_traffic_time = undef;
                $last_cpu = undef;
                $last_cpu_time = undef;
                $last_request = undef;
                $last_request_time = undef;
			}

			@tmp = ($username,$password,$last_traffic,$last_request_time,$last_cpu,$last_cpu_time,$last_request,$last_request_time);
		}
        elsif($app_name eq "nginx")
		{
            my $last_request = undef;
            my $last_request_time = undef;
            my $last_accept = undef;
            my $last_accept_time = undef;
            my $last_handled = undef;
            my $last_handled_time = undef;

			my $sqr_cache_select = $dbh->prepare("select app_type,unix_timestamp(datetime),last_value from app_cache where device_ip='$device_ip' and port=$port and app_name='nginx'");
			$sqr_cache_select->execute();
			while(my $ref_cache_select = $sqr_cache_select->fetchrow_hashref())
            {
                my $app_type = $ref_cache_select->{"app_type"};

                if($app_type eq "nginx_request")
                {
                    $last_request = $ref_cache_select->{"last_value"};
                    $last_request_time = $ref_cache_select->{"unix_timestamp(datetime)"};
                }
                elsif($app_type eq "nginx_accept")
                {
                    $last_accept = $ref_cache_select->{"last_value"};
                    $last_accept_time = $ref_cache_select->{"unix_timestamp(datetime)"};
                }
                elsif($app_type eq "nginx_handled")
                {
                    $last_handled = $ref_cache_select->{"last_value"};
                    $last_handled_time = $ref_cache_select->{"unix_timestamp(datetime)"};
                }
            }
			$sqr_cache_select->finish();

			unless( (defined $last_request && $last_request =~ /^[\d\.]+$/) &&
                    (defined $last_request_time && $last_request_time =~ /^\d+$/) && 
                    (defined $last_accept && $last_accept =~ /^[\d\.]+$/) && 
                    (defined $last_accept_time && $last_accept_time =~ /^[\d\.]+$/) &&
                    (defined $last_handled && $last_handled =~ /^[\d\.]+$/) &&
                    (defined $last_handled_time && $last_handled_time =~ /^[\d\.]+$/))
			{
                $last_request = undef;
                $last_request_time = undef;
                $last_accept = undef;
                $last_accept_time = undef;
                $last_handled = undef;
                $last_handled_time = undef;
			}

			@tmp = ($last_request,$last_request_time,$last_accept,$last_accept_time,$last_handled,$last_handled_time);
		}

		$device_info{$device_ip}->{$port}->{$app_name} = \@tmp;
	}
}
$sqr_select->finish();
my $rc = $dbh->disconnect;

if(scalar keys %device_info == 0){exit 0;}
foreach my $device_ip(keys %device_info)
{
    foreach my $port(keys %{$device_info{$device_ip}})
    {
        my @tmp = ($device_ip,$port);
        push @device_arr, \@tmp;
    }
}

if($max_process_num > scalar @device_arr){$max_process_num = scalar @device_arr;}

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

				&set_nan_val($dbh); 
                defined(my $pid = fork) or die "cannot fork:$!";
                unless($pid){
                    exec "/home/wuxiaolong/3_status/app_warning.pl";
                }           
                exit;
            }
        }
    }
}

sub fork_process
{
	my $ref_arr = shift @device_arr;
    my $device_ip = $ref_arr->[0];
    my $port = $ref_arr->[1];

	unless(defined $device_ip){return;}
	my $pid = fork();
	if (!defined($pid))
	{
		print "Error in fork: $!";
		exit 1;
	}

	if ($pid == 0)
	{
        foreach my $tmp_ip(keys %device_info)
        {
            if($device_ip ne $tmp_ip)
            {
                delete $device_info{$tmp_ip};
                next;
            }

            foreach my $tmp_port(keys %{$device_info{$tmp_ip}})
            {
                if($port != $tmp_port)
                {
                    delete $device_info{$tmp_ip}->{$tmp_port};
                }
            }
        }

        my $dbh=DBI->connect("DBI:mysql:database=audit_sec;host=localhost;mysql_connect_timeout=5",$mysql_user,$mysql_passwd,{RaiseError=>1});

        my $utf8 = $dbh->prepare("set names utf8");
        $utf8->execute();
        $utf8->finish();

        foreach my $app_name(keys %{$device_info{$device_ip}->{$port}})
        {
            if($app_name eq 'apache')
            {
                my $result = &apache_process($dbh,1,$device_ip,$port,$app_name,$device_info{$device_ip}->{$port}->{$app_name});
                if($result)
                {
                    &apache_process($dbh,2,$device_ip,$port,$app_name,$device_info{$device_ip}->{$port}->{$app_name});
                }
            }
            elsif($app_name eq 'mysql')
            {
                my $result = &mysql_process($dbh,1,$device_ip,$port,$app_name,$device_info{$device_ip}->{$port}->{$app_name});
                if($result)
                {
                    &mysql_process($dbh,2,$device_ip,$port,$app_name,$device_info{$device_ip}->{$port}->{$app_name});
                }
            }
            elsif($app_name eq 'tomcat')
            {
                my $result = &tomcat_process($dbh,1,$device_ip,$port,$app_name,$device_info{$device_ip}->{$port}->{$app_name});
                if($result)
                {
                    &tomcat_process($dbh,2,$device_ip,$port,$app_name,$device_info{$device_ip}->{$port}->{$app_name});
                }
            }
            elsif($app_name eq 'nginx')
            {
                my $result = &nginx_process($dbh,1,$device_ip,$port,$app_name,$device_info{$device_ip}->{$port}->{$app_name});
                if($result)
                {
                    &nginx_process($dbh,2,$device_ip,$port,$app_name,$device_info{$device_ip}->{$port}->{$app_name});
                }
            }
        }
        exit 0;
    }
    ++$exist_process;
}

sub apache_process
{
    my($dbh,$call_count,$device_ip,$port,$app_name,$ref_arr) = @_;
    my $last_traffic = $ref_arr->[0];
    my $last_traffic_time = $ref_arr->[1];
    my $last_cpu = $ref_arr->[2];
    my $last_cpu_time = $ref_arr->[3];
    my $last_request = $ref_arr->[4];
    my $last_request_time = $ref_arr->[5];

    my $url = "http://$device_ip:$port/server-status";
    if(system("wget -t 1 -T 3 '$url' -O /tmp/server_status_${device_ip}_$port 1>/tmp/apacheERR_${device_ip}_$port 2>&1") != 0)
    {
        if($call_count != 1)
        {
            &err_process($dbh,$device_ip,$port,$app_name,"无法获得主机 apache 应用状态, http连接出错");
            if($debug == 1)
            {
                print "$device_ip:$port $app_name, 无法获得主机 apache 应用状态, http连接出错\n";
            }
        }
        unlink "/tmp/apacheERR_${device_ip}_$port";
        unlink "/tmp/server_status_${device_ip}_$port";
        return 1;
    }

    $url = "http://$device_ip:$port/server-status?auto";
    if(system("wget -t 1 -T 3 '$url' -O /tmp/server_status_auto_${device_ip}_$port 1>/tmp/apacheERR_auto_${device_ip}_$port 2>&1") != 0)
    {
        if($call_count != 1)
        {
            &err_process($dbh,$device_ip,$port,$app_name,"无法获得主机 apache 应用状态, http连接出错");
            if($debug == 1)
            {
                print "$device_ip:$port $app_name, 无法获得主机 apache 应用状态, http连接出错\n";
            }
        }
        unlink "/tmp/apacheERR_auto_${device_ip}_$port";
        unlink "/tmp/server_status_auto_${device_ip}_$port";
        return 1;
    }

    my($traffic,$cpu,$request,$connect,$process) = &get_apache_status($device_ip,$port);
    if($call_count == 1 && (!defined $traffic || !defined $cpu || !defined $request || !defined $connect || !defined $process))
    {
        unlink "/tmp/apacheERR_${device_ip}_$port";
        unlink "/tmp/server_status_${device_ip}_$port";
        unlink "/tmp/apacheERR_auto_${device_ip}_$port";
        unlink "/tmp/server_status_auto_${device_ip}_$port";
        return 1;
    }

    if(defined $traffic)
    {
        &insert_into_cache($dbh,$device_ip,$port,'apache','apache_traffic',$traffic);

        if(defined $last_traffic && $traffic >= $last_traffic)
        {
            my $value = ($traffic - $last_traffic) / ($time_now_utc - $last_traffic_time);

            &insert_into_status($dbh,$device_ip,$port,'apache','traffic rate','apache_traffic',$value);
            &update_rrd($dbh,$device_ip,$port,'apache','traffic rate','apache_status','traffic_rate',$value);
            &warning_func($dbh,$device_ip,$port,'apache','traffic rate',$value);

            if($debug == 1)
            {
                print "$device_ip:$port apache: traffic_rate\t$value\n";
			}
        }
        else
        {
            &insert_into_status($dbh,$device_ip,$port,'apache','traffic rate','apache_traffic',-100);
            &update_rrd($dbh,$device_ip,$port,'apache','traffic rate','apache_status','traffic_rate',-100);
        }
    }
    else
    {
        rename "/tmp/apacheERR_auto_${device_ip}_$port", "./app_errlog_cache/apache_err_auto_${device_ip}_${port}_$time_now_str";
        rename "/tmp/server_status_auto_${device_ip}_$port", "./app_errlog_cache/apache_stat_auto_${device_ip}_${port}_$time_now_str";

        &insert_into_status($dbh,$device_ip,$port,'apache','traffic rate','apache_traffic',-100);
        &update_rrd($dbh,$device_ip,$port,'apache','traffic rate','apache_status','traffic_rate',-100);
        &warning_func($dbh,$device_ip,$port,'apache','traffic rate',-100);

        if($debug == 1)
        {
            print "$device_ip:$port apache: traffic_rate\t没取到值\n";
        }
    }

    if(defined $cpu)
    {
        &insert_into_cache($dbh,$device_ip,$port,'apache','apache_cpu',$cpu);

        #if(defined $last_cpu && $cpu >= $last_cpu)
        if(defined $last_cpu)
        {
            #my $value = ($cpu - $last_cpu) / ($time_now_utc - $last_cpu_time) * 100;
            my $value = 0;
            if($cpu >= $last_cpu)
            {
                $value = ($cpu - $last_cpu) / ($time_now_utc - $last_cpu_time) * 100;
            }

            &insert_into_status($dbh,$device_ip,$port,'apache','cpu load','apache_cpu',$value);
			&update_rrd($dbh,$device_ip,$port,'apache','cpu load','apache_status','cpu_load',$value);
            &warning_func($dbh,$device_ip,$port,'apache','cpu load',$value);

			if($debug == 1)
			{
				print "$device_ip:$port apache: cpu_load\t$value\n";
			}
        }
        else
        {
            &insert_into_status($dbh,$device_ip,$port,'apache','cpu load','apache_cpu',-100);
			&update_rrd($dbh,$device_ip,$port,'apache','cpu load','apache_status','cpu_load',-100);
        }
    }
    else
    {
        rename "/tmp/apacheERR_${device_ip}_$port", "./app_errlog_cache/apache_err_${device_ip}_${port}_$time_now_str";
        rename "/tmp/server_status_${device_ip}_$port", "./app_errlog_cache/apache_stat_${device_ip}_${port}_$time_now_str";

        &insert_into_status($dbh,$device_ip,$port,'apache','cpu load','apache_cpu',-100);
        &update_rrd($dbh,$device_ip,$port,'apache','cpu load','apache_status','cpu_load',-100);
        &warning_func($dbh,$device_ip,$port,'apache','cpu load',-100);

        if($debug == 1)
        {
            print "$device_ip:$port apache: cpu_load\t没取到值\n";
        }
    }

    if(defined $request)
    {
        &insert_into_cache($dbh,$device_ip,$port,'apache','apache_request',$request);

        if(defined $last_request && $request >= $last_request)
        {
            my $value = ($request - $last_request) / ($time_now_utc - $last_request_time);

            &insert_into_status($dbh,$device_ip,$port,'apache','request rate','apache_request',$value);
			&update_rrd($dbh,$device_ip,$port,'apache','request rate','apache_status','request_rate',$value);
            &warning_func($dbh,$device_ip,$port,'apache','request rate',$value);

			if($debug == 1)
			{
				print "$device_ip:$port apache: request_rate\t$value\n";
			}
        }
        else
        {
            &insert_into_status($dbh,$device_ip,$port,'apache','request rate','apache_request',-100);
			&update_rrd($dbh,$device_ip,$port,'apache','request rate','apache_status','request_rate',-100);
        }
    }
    else
    {
        &insert_into_status($dbh,$device_ip,$port,'apache','request rate','apache_request',-100);
        &update_rrd($dbh,$device_ip,$port,'apache','request rate','apache_status','request_rate',-100);
        &warning_func($dbh,$device_ip,$port,'apache','request rate',-100);

        if($debug == 1)
        {
            print "$device_ip:$port apache: request_rate\t没取到值\n";
        }
    }

    if(defined $connect)
    {
        my $value = $connect;

        &insert_into_status($dbh,$device_ip,$port,'apache','process num',undef,$value);
        &update_rrd($dbh,$device_ip,$port,'apache','process num','apache_status','process_num',$value);
        &warning_func($dbh,$device_ip,$port,'apache','process num',$value);

        if($debug == 1)
        {
            print "$device_ip:$port apache: process_num\t$value\n";
        }
    }
    else
    {
        &insert_into_status($dbh,$device_ip,$port,'apache','process num',undef,-100);
        &update_rrd($dbh,$device_ip,$port,'apache','process num','apache_status','process_num',-100);
        &warning_func($dbh,$device_ip,$port,'apache','process num',-100);

        if($debug == 1)
        {
            print "$device_ip:$port apache: process_num\t没取到值\n";
        }
    }

    if(defined $process)
    {
        my $value = $process;

        &insert_into_status($dbh,$device_ip,$port,'apache','busy process',undef,$value);
        &update_rrd($dbh,$device_ip,$port,'apache','busy process','apache_status','busy_process',$value);
        &warning_func($dbh,$device_ip,$port,'apache','busy process',$value);

        if($debug == 1)
        {
            print "$device_ip:$port apache: busy_process\t$value\n";
        }
    }
    else
    {
        &insert_into_status($dbh,$device_ip,$port,'apache','busy process',undef,-100);
        &update_rrd($dbh,$device_ip,$port,'apache','busy process','apache_status','busy_process',-100);
        &warning_func($dbh,$device_ip,$port,'apache','busy process',-100);

        if($debug == 1)
        {
            print "$device_ip:$port apache: busy_process\t没取到值\n";
        }
    }

    unlink "/tmp/apacheERR_${device_ip}_$port";
	unlink "/tmp/server_status_${device_ip}_$port";
    unlink "/tmp/apacheERR_auto_${device_ip}_$port";
    unlink "/tmp/server_status_auto_${device_ip}_$port";
    return 0;
}

sub get_apache_status
{
    my($device_ip,$port) = @_;

    my $traffic = undef;
    my $cpu = undef;
    my $request = undef;
    my $connect = undef;
    my $process = undef;

	open(my $fd_fr,"</tmp/server_status_auto_${device_ip}_$port");
	foreach my $line(<$fd_fr>)
	{
		chomp $line;

        if($line =~ /Total\s*Accesses\s*:\s*(\d+)/i)
        {
            $request = $1;
        }
        elsif($line =~ /Total\s*kBytes\s*:\s*(\d+)/i)
        {
            $traffic = $1;
        }
        elsif($line =~ /BusyWorkers\s*:\s*(\d+)/i)
        {
            $process = $1; 
            unless(defined $connect)
            {
                $connect = $process; 
            }
            else
            {
                $connect += $process;
            }
        }
        elsif($line =~ /IdleWorkers\s*:\s*(\d+)/i)
        {
            unless(defined $connect)
            {
                $connect = $1; 
            }
            else
            {
                $connect += $1;
            }
        }
    }
    close $fd_fr;

	open($fd_fr,"</tmp/server_status_${device_ip}_$port");
	foreach my $line(<$fd_fr>)
	{
		chomp $line;

		if($line =~ /CPU Usage\s*:\s*u\s*([\.\d]+)\s*s\s*([\.\d]+)\s*cu\s*([\.\d]+)\s*cs\s*([\.\d]+)/i)
		{
			$cpu = $1 + $2 + $3 + $4;
		}
    }
    close $fd_fr;

    return($traffic,$cpu,$request,$connect,$process)
}

sub insert_into_cache
{
    my($dbh,$device_ip,$port,$app_name,$app_type,$last_value) = @_;

    my $cmd;

	my $sqr_select = $dbh->prepare("select count(*) from app_cache where device_ip='$device_ip' and port=$port and app_name='$app_name' and app_type='$app_type'");
	$sqr_select->execute();
	my $ref_select = $sqr_select->fetchrow_hashref();
	my $num = $ref_select->{"count(*)"};
	$sqr_select->finish();

    if($num == 0)
    {
        $cmd = "insert into app_cache(device_ip,port,datetime,app_name,app_type,last_value) values('$device_ip',$port,'$time_now_str','$app_name','$app_type',$last_value)";
    }
    else
    {
        $cmd = "update app_cache set datetime='$time_now_str', last_value=$last_value where device_ip='$device_ip' and port=$port and app_name='$app_name' and app_type='$app_type'";
    }

    my $sqr_update = $dbh->prepare("$cmd");
    $sqr_update->execute();
    $sqr_update->finish();
}

sub mysql_process
{
	my($dbh,$call_count,$device_ip,$port,$app_name,$ref_arr) = @_;
	my $username = $ref_arr->[0];
	my $password = $ref_arr->[1];
	my $last_questions = $ref_arr->[2];
	my $last_questions_time = $ref_arr->[3];

	my $cmd;
	if(defined $password && $password ne "")
	{
		$cmd = "/opt/freesvr/sql/bin/mysqladmin --connect_timeout=5 -h $device_ip -P $port -u $username -p$password status 1>/tmp/mysql_status_${device_ip}_$port 2>/tmp/mysqERR_${device_ip}_$port";
	}
	else
	{
		$cmd = "/opt/freesvr/sql/bin/mysqladmin --connect_timeout=5 -h $device_ip -P $port -u $username status 1>/tmp/mysql_status_${device_ip}_$port 2>/tmp/mysqERR_${device_ip}_$port";
	}

	if(system("$cmd") != 0)
    {
        if($call_count != 1)
        {
            &err_process($dbh,$device_ip,$port,$app_name,"无法获得主机 mysql 应用状态, mysqladmin指令返回错误");
            if($debug == 1)
            {
                print "$device_ip:$port $app_name, 无法获得主机 mysql 应用状态, mysqladmin指令返回错误\n";
            }
        }
        unlink "/tmp/mysql_status_${device_ip}_$port";
        unlink "/tmp/mysqERR_${device_ip}_$port";
        return 1;
    }

    my($questions,$open_tables,$open_files,$threads) = &get_mysql_status($device_ip,$port);
    if($call_count == 1 && (!defined $questions || !defined $open_tables || !defined $open_files || !defined $threads))
    {
        unlink "/tmp/mysql_status_${device_ip}_$port";
        unlink "/tmp/mysqERR_${device_ip}_$port";
        return 1;
    }

    if(defined $questions)
    {
        &insert_into_cache($dbh,$device_ip,$port,'mysql','mysql_questions',$questions);

        if(defined $last_questions && $questions >= $last_questions)
        {
            my $value = ($questions - $last_questions) / ($time_now_utc - $last_questions_time);

            &insert_into_status($dbh,$device_ip,$port,'mysql','questions rate','mysql_questions',$value);
			&update_rrd($dbh,$device_ip,$port,'mysql','questions rate','mysql_status','questions_rate',$value);
            &warning_func($dbh,$device_ip,$port,'mysql','questions rate',$value);

			if($debug == 1)
			{
				print "$device_ip:$port mysql: questions_rate\t$value\n";
			}
        }
        else
        {
            &insert_into_status($dbh,$device_ip,$port,'mysql','questions rate','mysql_questions',-100);
			&update_rrd($dbh,$device_ip,$port,'mysql','questions rate','mysql_status','questions_rate',-100);
        }
    }
    else
    {
        rename "/tmp/mysql_status_${device_ip}_$port", "./app_errlog_cache/mysql_status_${device_ip}_${port}_$time_now_str";
        rename "/tmp/mysqERR_${device_ip}_$port", "./app_errlog_cache/mysqERR_${device_ip}_${port}_$time_now_str";

        &insert_into_status($dbh,$device_ip,$port,'mysql','questions rate','mysql_questions',-100);
        &update_rrd($dbh,$device_ip,$port,'mysql','questions rate','mysql_status','questions_rate',-100);
        &warning_func($dbh,$device_ip,$port,'mysql','questions rate',-100);

        if($debug == 1)
        {
            print "$device_ip:$port mysql: questions_rate\t没取到值\n";
        }
    }

    if(defined $open_tables)
    {
        my $value = $open_tables;

        &insert_into_status($dbh,$device_ip,$port,'mysql','open tables',undef,$value);
        &update_rrd($dbh,$device_ip,$port,'mysql','open tables','mysql_status','open_tables',$value);
        &warning_func($dbh,$device_ip,$port,'mysql','open tables',$value);

        if($debug == 1)
        {
            print "$device_ip:$port mysql: open_tables\t$value\n";
        }
    }
    else
    {
        &insert_into_status($dbh,$device_ip,$port,'mysql','open tables',undef,-100);
        &update_rrd($dbh,$device_ip,$port,'mysql','open tables','mysql_status','open_tables',-100);
        &warning_func($dbh,$device_ip,$port,'mysql','open tables',-100);

        if($debug == 1)
        {
            print "$device_ip:$port mysql: open_tables\t没取到值\n";
        }
    }

    if(defined $open_files)
    {
        my $value = $open_files;

        &insert_into_status($dbh,$device_ip,$port,'mysql','open files',undef,$value);
        &update_rrd($dbh,$device_ip,$port,'mysql','open files','mysql_status','open_files',$value);
        &warning_func($dbh,$device_ip,$port,'mysql','open files',$value);

        if($debug == 1)
        {
            print "$device_ip:$port mysql: open_files\t$value\n";
        }
    }
    else
    {
        &insert_into_status($dbh,$device_ip,$port,'mysql','open files',undef,-100);
        &update_rrd($dbh,$device_ip,$port,'mysql','open files','mysql_status','open_files',-100);
        &warning_func($dbh,$device_ip,$port,'mysql','open files',-100);

        if($debug == 1)
        {
            print "$device_ip:$port mysql: open_files\t没取到值\n";
        }
    }

    if(defined $threads)
    {
        my $value = $threads;

        &insert_into_status($dbh,$device_ip,$port,'mysql','threads',undef,$value);
        &update_rrd($dbh,$device_ip,$port,'mysql','threads','mysql_status','threads',$value);
        &warning_func($dbh,$device_ip,$port,'mysql','threads',$value);

        if($debug == 1)
        {
            print "$device_ip:$port mysql: threads\t$value\n";
        }
    }
    else
    {
        &insert_into_status($dbh,$device_ip,$port,'mysql','threads',undef,-100);
        &update_rrd($dbh,$device_ip,$port,'mysql','threads','mysql_status','threads',-100);
        &warning_func($dbh,$device_ip,$port,'mysql','threads',-100);

        if($debug == 1)
        {
            print "$device_ip:$port mysql: threads\t没取到值\n";
        }
    }

    unlink "/tmp/mysql_status_${device_ip}_$port";
    unlink "/tmp/mysqERR_${device_ip}_$port";
    return 0;
}

sub get_mysql_status
{
    my($device_ip,$port) = @_;

    my $questions = undef;
    my $open_tables = undef;
    my $open_files = undef;
    my $threads = undef;

	open(my $fd_fr,"</tmp/mysql_status_${device_ip}_$port");
	foreach my $line(<$fd_fr>)
	{
        if($line =~ /Threads\s*:\s*(\d+)/i)
        {
            $threads = $1;
        }

        if($line =~ /Questions\s*:\s*(\d+)/i)
        {
            $questions = $1;
        }

        if($line =~ /Opens\s*:\s*(\d+)/i)
        {
            $open_files = $1;
        }

        if($line =~ /Open\s*tables\s*:\s*(\d+)/i)
        {
            $open_tables = $1;
        }
    }
    return ($questions,$open_tables,$open_files,$threads);
}

sub tomcat_process
{
	my($dbh,$call_count,$device_ip,$port,$app_name,$ref_arr) = @_;
    my $username = $ref_arr->[0];
    my $password = $ref_arr->[1];
	my $last_traffic = $ref_arr->[2];
    my $last_traffic_time = $ref_arr->[3];
	my $last_cpu = $ref_arr->[4];
    my $last_cpu_time = $ref_arr->[5];
    my $last_request = $ref_arr->[6];
    my $last_request_time = $ref_arr->[7];

    my $url = "http://$username:$password\@$device_ip:$port/manager/status?XML=true";
	if(system("wget -t 1 -T 3 '$url' -O /tmp/tomcat_status_${device_ip}_$port.xml 1>/dev/null 2>&1") != 0)
    {
        if($call_count != 1)
        {
            &err_process($dbh,$device_ip,$port,$app_name,"无法获得主机 tomcat 应用状态, http连接出错");
            if($debug == 1)
            {
                print "$device_ip:$port $app_name, 无法获得主机 tomcat 应用状态, http连接出错\n";
            }
        }
        unlink "/tmp/tomcat_status_${device_ip}_$port";
        return 1;
    }

    my($traffic,$cpu,$request,$memory,$thread) = &get_tomcat_status($device_ip,$port);
    if($call_count == 1 && (!defined $traffic || !defined $cpu || !defined $request || !defined $memory || !defined $thread))
    {
        unlink "/tmp/tomcat_status_${device_ip}_$port.xml";
        return 1;
    }

    if(defined $traffic)
    {
        &insert_into_cache($dbh,$device_ip,$port,'tomcat','tomcat_traffic',$traffic);

        if(defined $last_traffic && $traffic >= $last_traffic)
        {
            my $value = ($traffic - $last_traffic) / ($time_now_utc - $last_traffic_time);

            &insert_into_status($dbh,$device_ip,$port,'tomcat','traffic rate','tomcat_traffic',$value);
			&update_rrd($dbh,$device_ip,$port,'tomcat','traffic rate','tomcat_status','traffic_rate',$value);
            &warning_func($dbh,$device_ip,$port,'tomcat','traffic rate',$value);

			if($debug == 1)
			{
				print "$device_ip:$port tomcat: traffic_rate\t$value\n";
			}
        }
        else
        {
            &insert_into_status($dbh,$device_ip,$port,'tomcat','traffic rate','tomcat_traffic',-100);
            &update_rrd($dbh,$device_ip,$port,'tomcat','traffic rate','tomcat_status','traffic_rate',-100);
        }
    }
    else
    {
        &insert_into_status($dbh,$device_ip,$port,'tomcat','traffic rate','tomcat_traffic',-100);
        &update_rrd($dbh,$device_ip,$port,'tomcat','traffic rate','tomcat_status','traffic_rate',-100);
        &warning_func($dbh,$device_ip,$port,'tomcat','traffic rate',-100);

        if($debug == 1)
        {
            print "$device_ip:$port tomcat: traffic_rate\t没取到值\n";
        }
    }

    if(defined $cpu)
    {
        &insert_into_cache($dbh,$device_ip,$port,'tomcat','tomcat_cpu',$cpu);

        if(defined $last_cpu && $cpu >= $last_cpu)
        {
            my $value = (($cpu - $last_cpu)/1000) / ($time_now_utc - $last_cpu_time) * 100;

            &insert_into_status($dbh,$device_ip,$port,'tomcat','cpu load','tomcat_cpu',$value);
			&update_rrd($dbh,$device_ip,$port,'tomcat','cpu load','tomcat_status','cpu_load',$value);
            &warning_func($dbh,$device_ip,$port,'tomcat','cpu load',$value);

			if($debug == 1)
			{
				print "$device_ip:$port tomcat: cpu_load\t$value\n";
			}
        }
        else
        {
            &insert_into_status($dbh,$device_ip,$port,'tomcat','cpu load','tomcat_cpu',-100);
			&update_rrd($dbh,$device_ip,$port,'tomcat','cpu load','tomcat_status','cpu_load',-100);
        }
    }
    else
    {
        &insert_into_status($dbh,$device_ip,$port,'tomcat','cpu load','tomcat_cpu',-100);
        &update_rrd($dbh,$device_ip,$port,'tomcat','cpu load','tomcat_status','cpu_load',-100);
        &warning_func($dbh,$device_ip,$port,'tomcat','cpu load',-100);

        if($debug == 1)
        {
            print "$device_ip:$port tomcat: cpu_load\t没取到值\n";
        }
    }

    if(defined $request)
    {
        &insert_into_cache($dbh,$device_ip,$port,'tomcat','tomcat_request',$request);

        if(defined $last_request && $request >= $last_request)
        {
            my $value = ($request - $last_request) / ($time_now_utc - $last_request_time);

            &insert_into_status($dbh,$device_ip,$port,'tomcat','request rate','tomcat_request',$value);
			&update_rrd($dbh,$device_ip,$port,'tomcat','request rate','tomcat_status','request_rate',$value);
            &warning_func($dbh,$device_ip,$port,'tomcat','request rate',$value);

			if($debug == 1)
			{
				print "$device_ip:$port tomcat: request_rate\t$value\n";
			}
        }
        else
        {
            &insert_into_status($dbh,$device_ip,$port,'tomcat','request rate','tomcat_request',-100);
			&update_rrd($dbh,$device_ip,$port,'tomcat','request rate','tomcat_status','request_rate',-100);
        }
    }
    else
    {
        &insert_into_status($dbh,$device_ip,$port,'tomcat','request rate','tomcat_request',-100);
        &update_rrd($dbh,$device_ip,$port,'tomcat','request rate','tomcat_status','request_rate',-100);
        &warning_func($dbh,$device_ip,$port,'tomcat','request rate',-100);

        if($debug == 1)
        {
            print "$device_ip:$port tomcat: request_rate\t没取到值\n";
        }
    }

    if(defined $memory)
    {
        my $value = $memory;

        &insert_into_status($dbh,$device_ip,$port,'tomcat','memory usage',undef,$value);
        &update_rrd($dbh,$device_ip,$port,'tomcat','memory usage','tomcat_status','memory_usage',$value);
        &warning_func($dbh,$device_ip,$port,'tomcat','memory usage',$value);

        if($debug == 1)
        {
            print "$device_ip:$port tomcat: memory_usage\t$value\n";
        }
    }
    else
    {
        &insert_into_status($dbh,$device_ip,$port,'tomcat','memory usage',undef,-100);
        &update_rrd($dbh,$device_ip,$port,'tomcat','memory usage','tomcat_status','memory_usage',-100);
        &warning_func($dbh,$device_ip,$port,'tomcat','memory usage',-100);

        if($debug == 1)
        {
            print "$device_ip:$port tomcat: memory_usage\t没取到值\n";
        }
    }

    if(defined $thread)
    {
        my $value = $thread;

        &insert_into_status($dbh,$device_ip,$port,'tomcat','busy thread',undef,$value);
        &update_rrd($dbh,$device_ip,$port,'tomcat','busy thread','tomcat_status','busy_thread',$value);
        &warning_func($dbh,$device_ip,$port,'tomcat','busy thread',$value);

        if($debug == 1)
        {
            print "$device_ip:$port tomcat: busy_thread\t$value\n";
        }
    }
    else
    {
        &insert_into_status($dbh,$device_ip,$port,'tomcat','busy thread',undef,-100);
        &update_rrd($dbh,$device_ip,$port,'tomcat','busy thread','tomcat_status','busy_thread',-100);
        &warning_func($dbh,$device_ip,$port,'tomcat','busy thread',-100);

        if($debug == 1)
        {
            print "$device_ip:$port tomcat: busy_thread\t没取到值\n";
        }
    }

	unlink "/tmp/tomcat_status_${device_ip}_$port.xml";
    return 0;
}

sub get_tomcat_status
{
    my($device_ip,$port) = @_;

    my $traffic = undef;
    my $cpu = undef;
    my $request = undef;
    my $memory = undef;
    my $thread = undef;

    my $tomcat_status = XMLin("/tmp/tomcat_status_${device_ip}_$port.xml");

    my $free_memory = $tomcat_status->{"jvm"}->{"memory"}->{"free"};
    my $total_memory = $tomcat_status->{"jvm"}->{"memory"}->{"total"};
    $memory = ($total_memory-$free_memory)/$total_memory * 100;
    $memory = floor($memory*100)/100;

    $thread = $tomcat_status->{"connector"}->{"http-8080"}->{"threadInfo"}->{"currentThreadsBusy"};
    $request = $tomcat_status->{"connector"}->{"http-8080"}->{"requestInfo"}->{"requestCount"};
    $cpu = $tomcat_status->{"connector"}->{"http-8080"}->{"requestInfo"}->{"processingTime"};
    $traffic = $tomcat_status->{"connector"}->{"http-8080"}->{"requestInfo"}->{"bytesSent"}/1024;
    $traffic = floor($traffic);

    return ($traffic,$cpu,$request,$memory,$thread);
}

sub nginx_process
{
	my($dbh,$call_count,$device_ip,$port,$app_name,$ref_arr) = @_;
    my $last_request = $ref_arr->[0];
    my $last_request_time = $ref_arr->[1];
    my $last_accept = $ref_arr->[2];
    my $last_accept_time = $ref_arr->[3];
    my $last_handled = $ref_arr->[4];
    my $last_handled_time = $ref_arr->[5];

    my $url = "http://$device_ip:$port/nginx_status";
    if(system("wget -t 1 -T 3 '$url' -O /tmp/nginx_status_${device_ip}_$port 1>/dev/null 2>&1") != 0)
    {
        if($call_count != 1)
        {
            &err_process($dbh,$device_ip,$port,$app_name,"无法获得主机 nginx 应用状态, http连接出错");
            if($debug == 1)
            {
                print "$device_ip:$port $app_name, 无法获得主机 nginx 应用状态, http连接出错\n";
            }
        }
        unlink "/tmp/nginx_status_${device_ip}_$port";
        return 1;
    }

    my($connect,$accept,$handled,$request,$reading,$writing,$waiting) = &get_nginx_status($device_ip,$port);
    if($call_count == 1 && (!defined $connect || !defined $accept || !defined $handled || !defined $request || !defined $reading || !defined $writing || !defined $waiting))
    {
        unlink "/tmp/nginx_status_${device_ip}_$port";
        return 1;
    }

    if(defined $connect)
    {
        my $value = $connect;

        &insert_into_status($dbh,$device_ip,$port,'nginx','connect num',undef,$value);
        &update_rrd($dbh,$device_ip,$port,'nginx','connect num','nginx_status','connect_num',$value);
        &warning_func($dbh,$device_ip,$port,'nginx','connect num',$value);

        if($debug == 1)
        {
            print "$device_ip:$port nginx: connect_num\t$value\n";
        }
    }
    else
    {
        &insert_into_status($dbh,$device_ip,$port,'nginx','connect num',undef,-100);
        &update_rrd($dbh,$device_ip,$port,'nginx','connect num','nginx_status','connect_num',-100);
        &warning_func($dbh,$device_ip,$port,'nginx','connect num',-100);

        if($debug == 1)
        {
            print "$device_ip:$port nginx: connect_num\t没取到值\n";
        }
    }

    if(defined $accept)
    {
        &insert_into_cache($dbh,$device_ip,$port,'nginx','nginx_accept',$accept);

        if(defined $last_accept && $accept >= $last_accept)
        {
            my $value = floor(($accept - $last_accept)/($time_now_utc - $last_accept_time) * 300);

            &insert_into_status($dbh,$device_ip,$port,'nginx','server accept','nginx_accept',$value);
			&update_rrd($dbh,$device_ip,$port,'nginx','server accept','nginx_status','server_accept',$value);
            &warning_func($dbh,$device_ip,$port,'nginx','server accept',$value);

			if($debug == 1)
			{
				print "$device_ip:$port nginx: server_accept\t$value\n";
			}
        }
        else
        {
            &insert_into_status($dbh,$device_ip,$port,'nginx','server accept','nginx_accept',-100);
			&update_rrd($dbh,$device_ip,$port,'nginx','server accept','nginx_status','server_accept',-100);
        }
    }
    else
    {
        &insert_into_status($dbh,$device_ip,$port,'nginx','server accept','nginx_accept',-100);
        &update_rrd($dbh,$device_ip,$port,'nginx','server accept','nginx_status','server_accept',-100);
        &warning_func($dbh,$device_ip,$port,'nginx','server accept',-100);

        if($debug == 1)
        {
            print "$device_ip:$port nginx: server_accept\t没取到值\n";
        }
    }

    if(defined $handled)
    {
        &insert_into_cache($dbh,$device_ip,$port,'nginx','nginx_handled',$handled);

        if(defined $last_handled && $handled >= $last_handled)
        {
            my $value = floor(($handled-$last_handled)/($time_now_utc-$last_handled_time)*300);

            &insert_into_status($dbh,$device_ip,$port,'nginx','server handled','nginx_handled',$value);
			&update_rrd($dbh,$device_ip,$port,'nginx','server handled','nginx_status','server_handled',$value);
            &warning_func($dbh,$device_ip,$port,'nginx','server handled',$value);

			if($debug == 1)
			{
				print "$device_ip:$port nginx: server_handled\t$value\n";
			}
        }
        else
        {
            &insert_into_status($dbh,$device_ip,$port,'nginx','server handled','nginx_handled',-100);
			&update_rrd($dbh,$device_ip,$port,'nginx','server handled','nginx_status','server_handled',-100);
        }
    }
    else
    {
        &insert_into_status($dbh,$device_ip,$port,'nginx','server handled','nginx_handled',-100);
        &update_rrd($dbh,$device_ip,$port,'nginx','server handled','nginx_status','server_handled',-100);
        &warning_func($dbh,$device_ip,$port,'nginx','server handled',-100);

        if($debug == 1)
        {
            print "$device_ip:$port nginx: server_handled\t没取到值\n";
        }
    }

    if(defined $request)
    {
        &insert_into_cache($dbh,$device_ip,$port,'nginx','nginx_request',$request);

        if(defined $last_request && $request >= $last_request)
        {
            my $value = ($request - $last_request) / ($time_now_utc - $last_request_time);

            &insert_into_status($dbh,$device_ip,$port,'nginx','request rate','nginx_request',$value);
			&update_rrd($dbh,$device_ip,$port,'nginx','request rate','nginx_status','request_rate',$value);
            &warning_func($dbh,$device_ip,$port,'nginx','request rate',$value);

			if($debug == 1)
			{
				print "$device_ip:$port nginx: request_rate\t$value\n";
			}
        }
        else
        {
            &insert_into_status($dbh,$device_ip,$port,'nginx','request rate','nginx_request',-100);
			&update_rrd($dbh,$device_ip,$port,'nginx','request rate','nginx_status','request_rate',-100);
        }
    }
    else
    {
        &insert_into_status($dbh,$device_ip,$port,'nginx','request rate','nginx_request',-100);
        &update_rrd($dbh,$device_ip,$port,'nginx','request rate','nginx_status','request_rate',-100);
        &warning_func($dbh,$device_ip,$port,'nginx','request rate',-100);

        if($debug == 1)
        {
            print "$device_ip:$port nginx: request_rate\t没取到值\n";
        }
    }

    if(defined $reading)
    {
        my $value = $reading;

        &insert_into_status($dbh,$device_ip,$port,'nginx','reading num',undef,$value);
        &update_rrd($dbh,$device_ip,$port,'nginx','reading num','nginx_status','reading_num',$value);
        &warning_func($dbh,$device_ip,$port,'nginx','reading num',$value);

        if($debug == 1)
        {
            print "$device_ip:$port nginx: reading_num\t$value\n";
        }
    }
    else
    {
        &insert_into_status($dbh,$device_ip,$port,'nginx','reading num',undef,-100);
        &update_rrd($dbh,$device_ip,$port,'nginx','reading num','nginx_status','reading_num',-100);
        &warning_func($dbh,$device_ip,$port,'nginx','reading num',-100);

        if($debug == 1)
        {
            print "$device_ip:$port nginx: reading_num\t没取到值\n";
        }
    }

    if(defined $writing)
    {
        my $value = $writing;

        &insert_into_status($dbh,$device_ip,$port,'nginx','writing num',undef,$value);
        &update_rrd($dbh,$device_ip,$port,'nginx','writing num','nginx_status','writing_num',$value);
        &warning_func($dbh,$device_ip,$port,'nginx','writing num',$value);

        if($debug == 1)
        {
            print "$device_ip:$port nginx: writing_num\t$value\n";
        }
    }
    else
    {
        &insert_into_status($dbh,$device_ip,$port,'nginx','writing num',undef,-100);
        &update_rrd($dbh,$device_ip,$port,'nginx','writing num','nginx_status','writing_num',-100);
        &warning_func($dbh,$device_ip,$port,'nginx','writing num',-100);

        if($debug == 1)
        {
            print "$device_ip:$port nginx: writing_num\t没取到值\n";
        }
    }

    if(defined $waiting)
    {
        my $value = $waiting;

        &insert_into_status($dbh,$device_ip,$port,'nginx','waiting num',undef,$value);
        &update_rrd($dbh,$device_ip,$port,'nginx','waiting num','nginx_status','waiting_num',$value);
        &warning_func($dbh,$device_ip,$port,'nginx','waiting num',$value);

        if($debug == 1)
        {
            print "$device_ip:$port nginx: waiting_num\t$value\n";
        }
    }
    else
    {
        &insert_into_status($dbh,$device_ip,$port,'nginx','waiting num',undef,-100);
        &update_rrd($dbh,$device_ip,$port,'nginx','waiting num','nginx_status','waiting_num',-100);
        &warning_func($dbh,$device_ip,$port,'nginx','waiting num',-100);

        if($debug == 1)
        {
            print "$device_ip:$port nginx: waiting_num\t没取到值\n";
        }
    }

	unlink "/tmp/nginx_status_${device_ip}_$port";
    return 0;
}

sub get_nginx_status
{
    my($device_ip,$port) = @_;

    my $connect = undef;
    my $accept = undef;
    my $handled = undef;
    my $request = undef;
    my $reading = undef;
    my $writing = undef;
    my $waiting = undef;

	open(my $fd_fr,"</tmp/nginx_status_${device_ip}_$port");
	foreach my $line(<$fd_fr>)
	{
		chomp $line;

        if($line =~ /Active connections\s*:\s*(\d+)/i)
        {
            $connect = $1;
        }

        if($line =~ /\s*(\d+)\s*(\d+)\s*(\d+)/i)
        {
            $accept = $1;
            $handled = $2;
            $request = $3;
        }

        if($line =~ /Reading:\s*(\d+).*Writing:\s*(\d+).*Waiting:\s*(\d+)/i)
        {
            $reading = $1;
            $writing = $2;
            $waiting = $3;
        }
    }
    close $fd_fr;

    return($connect,$accept,$handled,$request,$reading,$writing,$waiting);
}

sub insert_into_status
{
	my($dbh,$device_ip,$port,$app_name,$app_type,$cache_type,$value) = @_;

	my $sqr_select = $dbh->prepare("select count(*) from app_status where device_ip='$device_ip' and port=$port and app_name='$app_name' and app_type='$app_type'");
	$sqr_select->execute();
	my $ref_select = $sqr_select->fetchrow_hashref();
	my $device_num = $ref_select->{"count(*)"};
	$sqr_select->finish();

	if($device_num == 0)
	{
		my $sqr_insert = $dbh->prepare("insert into app_status(device_ip,port,app_name,app_type) values('$device_ip',$port,'$app_name','$app_type')");
		$sqr_insert->execute();
		$sqr_insert->finish();

		$sqr_select = $dbh->prepare("select enable from app_status where device_ip='$device_ip' and port=$port and app_name='$app_name' and app_type='$app_type'");
		$sqr_select->execute();
		$ref_select = $sqr_select->fetchrow_hashref();
		my $enable = $ref_select->{"enable"};
		$sqr_select->finish();

		if($enable != 1)
		{
			if($debug == 1)
			{
				my $sqr_update = $dbh->prepare("update app_status set enable=1 where device_ip='$device_ip' and port=$port and app_name='$app_name' and app_type='$app_type'");
				$sqr_update->execute();
				$sqr_update->finish();

				$sqr_update = $dbh->prepare("update app_status set value=$value, datetime='$time_now_str' where device_ip='$device_ip' and port=$port and app_name='$app_name' and app_type='$app_type'");
				$sqr_update->execute();
				$sqr_update->finish();
			}
			elsif(defined $cache_type)
			{
				my $sqr_delete = $dbh->prepare("delete from app_cache where device_ip='$device_ip' and and port=$port and app_name='$app_name' and app_type='$cache_type'");
				$sqr_delete->execute();
				$sqr_delete->finish();
			}
		}
		else
		{
			my $sqr_update = $dbh->prepare("update app_status set value=$value, datetime='$time_now_str' where device_ip='$device_ip' and port=$port and app_name='$app_name' and app_type='$app_type'");
			$sqr_update->execute();
			$sqr_update->finish();
		}
	}
	else
	{
		my $sqr_select = $dbh->prepare("select enable from app_status where device_ip='$device_ip' and port=$port and app_name='$app_name' and app_type='$app_type'");
		$sqr_select->execute();
		$ref_select = $sqr_select->fetchrow_hashref();
		my $enable = $ref_select->{"enable"};
		$sqr_select->finish();

		if($enable == 1)
		{
			my $sqr_update = $dbh->prepare("update app_status set value=$value, datetime='$time_now_str' where device_ip='$device_ip' and port=$port and app_name='$app_name' and app_type='$app_type'");
			$sqr_update->execute();
			$sqr_update->finish();
		}
		else
		{
			my $sqr_update = $dbh->prepare("update app_status set value=null, datetime=null where device_ip='$device_ip' and port=$port and app_name='$app_name' and app_type='$app_type'");
			$sqr_update->execute();
			$sqr_update->finish();

            if(defined $cache_type)
            {
                my $sqr_delete = $dbh->prepare("delete from app_cache where device_ip='$device_ip' and port=$port and app_name='$app_name' and app_type='$cache_type'");
                $sqr_delete->execute();
                $sqr_delete->finish();
            }
		}
	}
}

sub update_rrd
{           
	my($dbh,$device_ip,$port,$app_name,$app_type,$dir_name,$file_name,$val) = @_;

	if(!defined $val || $val < 0)
	{
		$val = 'U';
	}

	my $sqr_select = $dbh->prepare("select enable,rrdfile from app_status where device_ip='$device_ip' and port=$port and app_name='$app_name' and app_type='$app_type'");
	$sqr_select->execute();
	my $ref_select = $sqr_select->fetchrow_hashref();
	my $enable = $ref_select->{"enable"};
	my $rrdfile = $ref_select->{"rrdfile"};
	$sqr_select->finish();

	my $start_time = time;
	$start_time = (floor($start_time/300))*300;

	my $dir = "/opt/freesvr/nm/$device_ip";
	if(! -e $dir)
	{
		mkdir $dir,0755;
	}   

	$dir = "$dir/$dir_name";
	if(! -e $dir)
	{
		mkdir $dir,0755;
	}   

	my $file = $dir."/${file_name}_$port.rrd";

	unless(defined $enable && $enable == 1) 
	{
		unless(defined $rrdfile && -e $rrdfile && $rrdfile eq $file)
		{
			if(defined $rrdfile && -e $rrdfile)
			{
				unlink $rrdfile;
				my $sqr_update = $dbh->prepare("update app_status set rrdfile=null where device_ip='$device_ip' and port=$port and app_name='$app_name' and app_type='$app_type'");
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
		my $sqr_update = $dbh->prepare("update app_status set rrdfile='$file' where device_ip='$device_ip' and port=$port and app_name='$app_name' and app_type='$app_type'");
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
			'--', join(':', "$start_time", "$val"),
			);
}

sub warning_func
{
	my($dbh,$device_ip,$port,$app_name,$app_type,$value) = @_;

    my $status;
    my $mail_alarm_status = -1;
    my $sms_alarm_status = -1;
    my $mail_out_interval = 0;              #邮件 是否超过时间间隔;
    my $sms_out_interval = 0;               #短信 是否超过时间间隔;

	my $sqr_select = $dbh->prepare("select enable,mail_alarm,sms_alarm,highvalue,lowvalue,unix_timestamp(mail_last_sendtime),unix_timestamp(sms_last_sendtime),send_interval from app_status where device_ip='$device_ip' and port=$port and app_name='$app_name' and app_type='$app_type'");
	$sqr_select->execute();
	my $ref_select = $sqr_select->fetchrow_hashref();
    my $enable = $ref_select->{"enable"};
    my $mail_alarm = $ref_select->{"mail_alarm"};
    my $sms_alarm = $ref_select->{"sms_alarm"};
    my $highvalue = $ref_select->{"highvalue"};
    my $lowvalue = $ref_select->{"lowvalue"};
    my $mail_last_sendtime = $ref_select->{"unix_timestamp(mail_last_sendtime)"};
    my $sms_last_sendtime = $ref_select->{"unix_timestamp(sms_last_sendtime)"};
    my $send_interval = $ref_select->{"send_interval"};
    $sqr_select->finish();

    unless(defined $enable && $enable == 1)
    {
        return 0;
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

    if($value < 0)
    {
        $status = 0;
        my $sqr_insert = $dbh->prepare("insert into app_warning_log (device_ip,port,datetime,app_name,app_type,mail_status,sms_status,cur_val,context) values ('$device_ip',$port,'$time_now_str','$app_name','$app_type',$mail_alarm_status,$sms_alarm_status,$value,'无法得到值')");
        $sqr_insert->execute();
        $sqr_insert->finish();
    }
    elsif(defined $highvalue && defined $lowvalue && ($value > $highvalue || $value < $lowvalue))
    {
        $status = 2;
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
        
        $value = floor($value*100)/100;

        my $sqr_insert = $dbh->prepare("insert into app_warning_log (device_ip,port,datetime,app_name,app_type,mail_status,sms_status,cur_val,thold,context) values ('$device_ip',$port,'$time_now_str','$app_name','$app_type',$mail_alarm_status,$sms_alarm_status,$value,$thold,'当前值 $value $tmp_context')");
        $sqr_insert->execute();
        $sqr_insert->finish();
    }
    else
    {
        $status = 1;
    }

    return $status;
}

sub err_process
{
    my($dbh,$device_ip,$port,$app_name,$context) = @_;
    my $sqr_insert = $dbh->prepare("insert into app_errlog (device_ip,port,app_name,datetime,context) values ('$device_ip',$port,'$app_name','$time_now_str','$context')");
    $sqr_insert->execute();
    $sqr_insert->finish();
}

sub set_nan_val
{
    my($dbh) = @_;

    my %apache_types = ('traffic rate' => 'apache_traffic',
            'cpu load' => 'apache_cpu',
            'request rate' => 'apache_request',
            'process num' => undef,
            'busy process' => undef,
            );

    foreach my $type(keys %apache_types)
    {
        my $sqr_select = $dbh->prepare("select device_ip,port from app_config where app_name='apache' and device_ip!='' and port is not null and enable=1");
        $sqr_select->execute();
        while(my $ref_select = $sqr_select->fetchrow_hashref())
        {
            my $file = $type;
            $file =~ s/\s+/_/g;
            my $device_ip = $ref_select->{"device_ip"};
            my $port = $ref_select->{"port"};
            if(&isexist($dbh,$device_ip,$port,'apache',$type))
            {
                next;
            }
            &insert_into_status($dbh,$device_ip,$port,'apache',$type,$apache_types{$type},-100);
            &update_rrd($dbh,$device_ip,$port,'apache',$type,'apache_status',$file,-100);
            &warning_func($dbh,$device_ip,$port,'apache',$type,-100);

            if($debug == 1)
            {
                print "$device_ip apache: $type\t没取到值\n";
            }
        }
        $sqr_select->finish();
    }

    my %mysql_types = ('questions rate' => 'mysql_questions',
            'open tables' => undef,
            'open files' => undef,
            'threads' => undef,
            );

    foreach my $type(keys %mysql_types)
    {
        my $sqr_select = $dbh->prepare("select device_ip,port from app_config where app_name='mysql' and device_ip!='' and port is not null and enable=1");
        $sqr_select->execute();
        while(my $ref_select = $sqr_select->fetchrow_hashref())
        {
            my $file = $type;
            $file =~ s/\s+/_/g;
            my $device_ip = $ref_select->{"device_ip"};
            my $port = $ref_select->{"port"};
            if(&isexist($dbh,$device_ip,$port,'mysql',$type))
            {
                next;
            }
            &insert_into_status($dbh,$device_ip,$port,'mysql',$type,$mysql_types{$type},-100);
            &update_rrd($dbh,$device_ip,$port,'mysql',$type,'mysql_status',$file,-100);
            &warning_func($dbh,$device_ip,$port,'mysql',$type,-100);

            if($debug == 1)
            {
                print "$device_ip mysql: $type\t没取到值\n";
            }
        }
        $sqr_select->finish();
    }

    my %tomcat_types = ('traffic rate' => 'tomcat_traffic',
            'cpu load' => 'tomcat_cpu',
            'request rate' => 'tomcat_request',
            'memory usage' => undef,
            'busy thread' => undef,
            );

    foreach my $type(keys %tomcat_types)
    {
        my $sqr_select = $dbh->prepare("select device_ip,port from app_config where app_name='tomcat' and device_ip!='' and port is not null and enable=1");
        $sqr_select->execute();
        while(my $ref_select = $sqr_select->fetchrow_hashref())
        {
            my $file = $type;
            $file =~ s/\s+/_/g;
            my $device_ip = $ref_select->{"device_ip"};
            my $port = $ref_select->{"port"};
            if(&isexist($dbh,$device_ip,$port,'tomcat',$type))
            {
                next;
            }
            &insert_into_status($dbh,$device_ip,$port,'tomcat',$type,$tomcat_types{$type},-100);
            &update_rrd($dbh,$device_ip,$port,'tomcat',$type,'tomcat_status',$file,-100);
            &warning_func($dbh,$device_ip,$port,'tomcat',$type,-100);

            if($debug == 1)
            {
                print "$device_ip tomcat: $type\t没取到值\n";
            }
        }
        $sqr_select->finish();
    }

    my %nginx_types = ('connect num' => undef,
            'server accept' => 'nginx_accept',
            'server handled' => 'nginx_handled',
            'request rate' => 'nginx_request',
            'reading num' => undef,
            'writing num' => undef,
            'waiting num' => undef,
            );

    foreach my $type(keys %nginx_types)
    {
        my $sqr_select = $dbh->prepare("select device_ip,port from app_config where app_name='nginx' and device_ip!='' and port is not null and enable=1");
        $sqr_select->execute();
        while(my $ref_select = $sqr_select->fetchrow_hashref())
        {
            my $file = $type;
            $file =~ s/\s+/_/g;
            my $device_ip = $ref_select->{"device_ip"};
            my $port = $ref_select->{"port"};
            if(&isexist($dbh,$device_ip,$port,'nginx',$type))
            {
                next;
            }
            &insert_into_status($dbh,$device_ip,$port,'nginx',$type,$nginx_types{$type},-100);
            &update_rrd($dbh,$device_ip,$port,'nginx',$type,'nginx_status',$file,-100);
            &warning_func($dbh,$device_ip,$port,'nginx',$type,-100);

            if($debug == 1)
            {
                print "$device_ip nginx: $type\t没取到值\n";
            }
        }
        $sqr_select->finish();
    }

    $sqr_select = $dbh->prepare("select b.device_ip,b.port,b.app_name,b.app_type from app_config a left join app_status b on a.device_ip=b.device_ip and a.port=b.port and a.app_name=b.app_name where datetime<'$time_now_str' and a.device_ip!='' and a.port is not null and a.enable=1");
    $sqr_select->execute();
    while(my $ref_select = $sqr_select->fetchrow_hashref())
    {
        my $device_ip = $ref_select->{"device_ip"};
        my $port = $ref_select->{"port"};
        my $app_name = $ref_select->{"app_name"};
        my $app_type = $ref_select->{"app_type"};

        my $file = $app_type;
        $file =~ s/\s+/_/g;

        my $dir;
        my $cache_type;
        if($app_name =~ /mysql/)
        {
            $dir = 'mysql_status';
            $cache_type = $mysql_types{$app_type};
        }
        elsif($app_name =~ /apache/)
        {
            $dir = 'apache_status';
            $cache_type = $apache_types{$app_type};
        }
        elsif($app_name =~ /tomcat/)
        {
            $dir = 'tomcat_status';
            $cache_type = $tomcat_types{$app_type};
        }
        elsif($app_name =~ /nginx/)
        {
            $dir = 'nginx_status';
            $cache_type = $nginx_types{$app_type};
        }

        &insert_into_status($dbh,$device_ip,$port,$app_name,$app_type,$cache_type,-100);
        &update_rrd($dbh,$device_ip,$port,$app_name,$app_type,$dir,$file,-100);
        &warning_func($dbh,$device_ip,$port,$app_name,$app_type,-100);

        if($debug == 1)
        {
            print "$device_ip:$port $app_name: $app_type\t没取到值\n";
        }
    }
    $sqr_select->finish();
}

sub isexist
{
    my($dbh,$device_ip,$port,$app_name,$app_type) = @_;
    my $sqr_select = $dbh->prepare("select count(*) from app_status where device_ip='$device_ip' and port=$port and app_name='$app_name' and app_type='$app_type'");
    $sqr_select->execute();
    my $ref_select = $sqr_select->fetchrow_hashref();
    my $num = $ref_select->{"count(*)"};
    $sqr_select->finish();
    if($num==0)
    {
        return 0;
    }
    else
    {
        return 1;
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
