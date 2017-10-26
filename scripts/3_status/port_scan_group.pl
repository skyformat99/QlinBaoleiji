#!/usr/bin/perl
use warnings;
use strict;
use DBI;
use DBD::mysql;
use POSIX qw/ceil floor/;
use Crypt::CBC;
use MIME::Base64;

our $debug = 1;
our $max_process_num = 2;
our $exist_process = 0;

our $time_now_utc = time;
our($min,$hour,$mday,$mon,$year) = (localtime $time_now_utc)[1..5];
($min,$hour,$mday,$mon,$year) = (sprintf("%02d", $min),sprintf("%02d", $hour),sprintf("%02d", $mday),sprintf("%02d", $mon + 1),$year+1900);
our $time_now_str = "$year$mon$mday$hour$min"."00";
our $send_time = "$year-$mon-$mday $hour:$min";

our($mysql_user,$mysql_passwd) = &get_local_mysql_config();
our $dbh=DBI->connect("DBI:mysql:database=cacti;host=localhost;mysql_connect_timeout=5",$mysql_user,$mysql_passwd,{RaiseError=>1});

our $utf8 = $dbh->prepare("set names utf8");
$utf8->execute();
$utf8->finish();

our $sqr_truncate = $dbh->prepare("truncate tcp_port_err");
$sqr_truncate->execute();
$sqr_truncate->finish();

our @ref_ip_arr;
my $sqr_select = $dbh->prepare("select ip from tcp_port group by ip");
$sqr_select->execute();
while(my $ref_select = $sqr_select->fetchrow_hashref())
{
    my $ip = $ref_select->{"ip"};
    my @value;

    my $sqr_select_port = $dbh->prepare("select tcpport,timeout from tcp_port where ip = '$ip'");
    $sqr_select_port->execute();
    while(my $ref_select_port = $sqr_select_port->fetchrow_hashref())
    {
        my $port = $ref_select_port->{"tcpport"};
        my $timeout = $ref_select_port->{"timeout"};
        unless(defined $timeout) {$timeout = 0;}

        push @value, $port,$timeout;
    }
    $sqr_select_port->finish();

    my @host = ($ip,\@value);
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
					exec "/home/wuxiaolong/port_warning_group.pl",$time_now_str,$send_time;
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
		&port_scan($temp->[0],@{$temp->[1]});
		exit(0);
	}
	++$exist_process;
}

sub port_scan
{
	if($debug == 1)
	{
		unless(-e "/home/wuxiaolong/temp_log")
		{
			mkdir "/home/wuxiaolong/temp_log";
		}
		open(our $fd_fw,">>/home/wuxiaolong/temp_log/portscan.$time_now_str") or die $!;
	}

	my $dbh=DBI->connect("DBI:mysql:database=cacti;host=localhost;mysql_connect_timeout=5",$mysql_user,$mysql_passwd,{RaiseError=>1});
        
    my $utf8 = $dbh->prepare("set names utf8");
    $utf8->execute();
    $utf8->finish();
        
    my($ip,@val) = @_;
    my %ports;
    my $num = scalar @val;
    my $flag = 0;
            
    foreach my $i(0..int(($num-1)/2))
    {           
        $ports{$val[2*$i]} = $val[2*$i+1];
    }           
                
    my $nmap_str = "nmap -n -sT -p ".join(",",keys %ports)." $ip";
    my $nmap = `$nmap_str`;
    
    my @lines = split /\n/,$nmap;

    foreach my $line(@lines)
    {
#        if($line =~ /MAC\s*Address/i || $line =~ /Nmap\s*finished/i || $line =~ /^$/) {next;}
		if($line =~ /MAC\s*Address/i) {next;}
		if($flag == 1 && $line =~ /^$/) {last;}

        if($flag == 1)
        {
            my($port,$status) = (split /\s+/,$line)[0,1];
            $port = (split /\//,$port)[0];
        
            unless($status eq "open")
            {
				if($debug == 1)
				{
					print $fd_fw "$ip,$port  :  status: $status\n";
				}

                my $sqr_insert = $dbh->prepare("insert into tcp_port_value (datetime,ip,tcpport,time) values ('$time_now_str','$ip',$port,999999)");
                $sqr_insert->execute();
                $sqr_insert->finish();

                $sqr_insert = $dbh->prepare("insert into tcp_port_err (ip,tcpport,time_err,time_thold) values ('$ip',$port,0,$ports{$port})");
                $sqr_insert->execute();
                $sqr_insert->finish();

				my $sqr_update = $dbh->prepare("update tcp_port set status = 0 where ip = '$ip' and tcpport = $port");
				$sqr_update->execute();
				$sqr_update->finish();

                delete $ports{$port};
            }
        }
        elsif($line =~ /PORT\s*STATE\s*SERVICE/i)
        {
            $flag = 1;
        }
    }

    if($flag == 0)
    {
        foreach my $port(keys %ports)
        {
			if($debug == 1)
			{
				print $fd_fw "$ip,$port  :  nmap没有扫描到\n";
			}

            my $sqr_insert = $dbh->prepare("insert into tcp_port_value (datetime,ip,tcpport,time) values ('$time_now_str','$ip',$port,999999)");
            $sqr_insert->execute();
            $sqr_insert->finish();

            $sqr_insert = $dbh->prepare("insert into tcp_port_err (ip,tcpport,time_err,time_thold) values ('$ip',$port,0,$ports{$port})");
            $sqr_insert->execute();
            $sqr_insert->finish();

			my $sqr_update = $dbh->prepare("update tcp_port set status = 0 where ip = '$ip' and tcpport = $port");
			$sqr_update->execute();
			$sqr_update->finish();
        }
        return;
    }


    foreach my $port(keys %ports)
    {
        my $result = `tcptraceroute $ip $port -f 29 | tail -n 1`;

        if($result =~ /ms/i)
        {
            $result =~ s/(\d+)\s*ms/$1ms/g;
        }
        my @time = (split /\s+/,$result)[-3,-2,-1];

        my $min_time = 0;
        foreach(@time)
        {
            if($_ =~ /ms/i && $_ =~ /(\d+\.\d+)/i)
            {
                if($min_time == 0){$min_time = $1;}
                elsif($1<$min_time){$min_time = $1;}
            }
        }

		$min_time /= 1000;
        if($min_time == 0)
        {
			if($debug == 1)
			{
				print $fd_fw "$ip,$port  :  tcptraceroute 没有扫到,$result\n";
			}

            my $sqr_insert = $dbh->prepare("insert into tcp_port_value (datetime,ip,tcpport,time) values ('$time_now_str','$ip',$port,999999)");
            $sqr_insert->execute();
            $sqr_insert->finish();

            $sqr_insert = $dbh->prepare("insert into tcp_port_err (ip,tcpport,time_err,time_thold) values ('$ip',$port,0,$ports{$port})");
            $sqr_insert->execute();
            $sqr_insert->finish();

			my $sqr_update = $dbh->prepare("update tcp_port set status = 0 where ip = '$ip' and tcpport = $port");
			$sqr_update->execute();
			$sqr_update->finish();

        }
        elsif($min_time < $ports{$port})
        {
			if($debug == 1)
			{
				print $fd_fw "$ip,$port  :  tcptraceroute 成功,$result, 最小值 $min_time\n";
			}

			my $sqr_insert = $dbh->prepare("insert into tcp_port_value (datetime,ip,tcpport,time) values ('$time_now_str','$ip',$port,$min_time)");
            $sqr_insert->execute();
            $sqr_insert->finish();

			my $sqr_update = $dbh->prepare("update tcp_port set status = 1 where ip = '$ip' and tcpport = $port");
			$sqr_update->execute();
			$sqr_update->finish();
        }
        else
        {
			my $tmp_thold = $ports{$port};
			if($debug == 1)
			{
				print $fd_fw "$ip,$port  :  tcptraceroute 成功,$result, 最小值 $min_time, 阈值 $tmp_thold\n";
			}

            my $sqr_insert = $dbh->prepare("insert into tcp_port_value (datetime,ip,tcpport,time) values ('$time_now_str','$ip',$port,$min_time)");
            $sqr_insert->execute();
            $sqr_insert->finish();

            $sqr_insert = $dbh->prepare("insert into tcp_port_err (ip,tcpport,time_err,time_thold) values ('$ip',$port,$min_time,$ports{$port})");
            $sqr_insert->execute();
            $sqr_insert->finish();

			my $sqr_update = $dbh->prepare("update tcp_port set status = 0 where ip = '$ip' and tcpport = $port");
			$sqr_update->execute();
			$sqr_update->finish();
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
