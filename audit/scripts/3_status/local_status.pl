#!/usr/bin/perl
use warnings;
use strict;
use POSIX qw/ceil floor/;

our $test_process = "xinetd;sshd;ssh-audit;lsof";
our $test_port = "80;1521;12345";

our $device_ip = '172.16.210.246';
our $remote_ip = '172.16.210.99';
our $remote_user = 'monitor';
our $remote_port = 2288;
our $remote_path = '/tmp/remote_server_status';

our $time_now_utc = time;
my($min,$hour,$mday,$mon,$year) = (localtime $time_now_utc)[1..5];
($min,$hour,$mday,$mon,$year) = (sprintf("%02d", $min),sprintf("%02d", $hour),sprintf("%02d", $mday),sprintf("%02d", $mon + 1),$year+1900);
our $time_now_str = "$year$mon$mday$hour$min"."00";

our $dir = "/home/wuxiaolong/local_status_file/";
our $log_dir = "/home/wuxiaolong/local_status_log/";

our $file = "$dir${device_ip}_$time_now_str";
our $log_file = "${log_dir}local_status_error_log";

unless(-e $dir)
{
	mkdir $dir,0755;
}

unless(-e $log_dir)
{
	mkdir $log_dir,0755;
}

$SIG{ALRM}=\&alarm_process;

alarm(120);

open(my $fd_fw,">$file");
open(my $fd_fw_log,">>$log_file");

print $fd_fw "time\t$time_now_utc\n";
#my $result = `/usr/bin/top -b -n 1 | head -n 5 | grep -i 'cpu'`;
my $result = `/usr/bin/top -b -n 4 | grep -E -i '^cpu'`;
my $cpu = undef;
my $cpu_io = undef;
foreach my $line(split /\n/,$result)
{
	if($line =~ /(\d+\.\d+)%id.*(\d+\.\d+)%wa/i)
	{
		$cpu = $1;
        $cpu_io = $2;
	}
}

if(defined $cpu)
{
	$cpu = floor(100 - $cpu);
	print $fd_fw "cpu\t$cpu\n";
}

if(defined $cpu_io)
{
    $cpu_io = floor($cpu_io);
    print $fd_fw "cpu_io\t$cpu_io\n";
}

$result = `/usr/bin/free | grep -i 'mem'`;
foreach my $line(split /\n/,$result)
{
	if($line =~ /^mem/i)
	{
		my($total,$used,$buffers,$cache) = (split /\s+/,$line)[1,2,5,6];
		if($total =~ /^[\d\.]+$/ && $used =~ /^[\d\.]+$/ && $buffers =~ /^[\d\.]+$/ && $cache =~ /^[\d\.]+$/)
		{
			my $memory = floor(($used-$buffers-$cache)/$total*100);
			print $fd_fw "memory\t$memory\n";
			last;
		}
	}
}

$result = `/usr/bin/free | grep -i 'swap'`;
foreach my $line(split /\n/,$result)
{
	if($line =~ /^swap/i)
	{
		my($total,$used) = (split /\s+/,$line)[1,2];
		if($total =~ /^[\d\.]+$/ && $used =~ /^[\d\.]+$/ && $total > 0)
		{
			my $swap = floor($used/$total*100);
			print $fd_fw "swap\t$swap\n";
			last;
		}
	}
}

$result = `/bin/df`;
foreach my $line(split /\n/,$result)
{
	if($line =~ /(\d+)%\s*(\/\S*)/i)
	{
		my $disk_val = $1;
		my $disk_name = $2;
		if($disk_name =~ /shm/i){next;}
		print $fd_fw "$disk_name\t$disk_val\n";
	}
}

my @test_process_arr = split /;/,$test_process;
foreach my $process_name(@test_process_arr)
{
	$result = `ps -ef | grep $process_name | grep -v grep`;
	if($result eq "")
	{
		print $fd_fw "process:$process_name\t0\n";
	}
	else
	{
		print $fd_fw "process:$process_name\t1\n";
	}
}

my @test_port_arr = split /;/,$test_port;
my %local_tcp_port;

$result = `netstat -ant`;
foreach my $line(split /\n/,$result)
{
	my $local_addr = (split /\s+/,$line)[3];
	unless($local_addr =~ /:(\d+)$/)
	{
		next;
	}
	else
	{
		my $port = $1;
		unless(defined $local_tcp_port{$port})
		{
			$local_tcp_port{$port} = 1;
		}
	}
}

foreach my $port(@test_port_arr)
{
	if(exists $local_tcp_port{$port})
	{
		print $fd_fw "port:$port\t1\n";
	}
	else
	{
		print $fd_fw "port:$port\t0\n";
	}
}

close $fd_fw;

&scp_file();
unlink $file;

sub scp_file
{
	my $cmd = "scp -P $remote_port -q -r $file $remote_user"."@"."$remote_ip:$remote_path";
	my $status = system($cmd);
	if($status != 0)
	{
		print $fd_fw_log "$time_now_str\tscp错误, 返回码 $status\n";
	}
}

sub alarm_process
{
	print $fd_fw_log "程序超时\n";
	close $fd_fw_log;
	close $fd_fw;
	unlink $file;
	exit(1);
}
