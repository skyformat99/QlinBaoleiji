#!/usr/bin/perl
use warnings;
use strict;
use DBI;
use DBD::mysql;
use Crypt::CBC;
use MIME::Base64;
use POSIX qw/ceil floor/;

our($mysql_user,$mysql_passwd) = &get_local_mysql_config();
our $dbh=DBI->connect("DBI:mysql:database=audit_sec;host=localhost;mysql_connect_timeout=5",$mysql_user,$mysql_passwd,{RaiseError=>1});

our $utf8 = $dbh->prepare("set names utf8");
$utf8->execute();
$utf8->finish();

our $time_now_utc = time;
my($min,$hour,$mday,$mon,$year) = (localtime $time_now_utc)[1..5];
($min,$hour,$mday,$mon,$year) = (sprintf("%02d", $min),sprintf("%02d", $hour),sprintf("%02d", $mday),sprintf("%02d", $mon + 1),$year+1900);
our $time_now_str = "$year$mon$mday$hour$min"."00";

our %thold_hash;
our @abnormal_val;

our $sqr_select_last = $dbh->prepare("select unix_timestamp(max(datetime)) from status");
$sqr_select_last->execute();
our $ref_select_last = $sqr_select_last->fetchrow_hashref();
our $last_datetime = defined $ref_select_last->{"unix_timestamp(max(datetime))"}?$ref_select_last->{"unix_timestamp(max(datetime))"}:-1;
$sqr_select_last->finish();

$sqr_select_last = $dbh->prepare("select net_eth0_inall,net_eth0_outall,net_eth1_inall,net_eth1_outall from status where unix_timestamp(datetime)=$last_datetime");
$sqr_select_last->execute();
$ref_select_last = $sqr_select_last->fetchrow_hashref();
our $eth0_in_last = defined $ref_select_last->{"net_eth0_inall"}?$ref_select_last->{"net_eth0_inall"}:-1;
our $eth0_out_last = defined $ref_select_last->{"net_eth0_outall"}?$ref_select_last->{"net_eth0_outall"}:-1;
our $eth1_in_last = defined $ref_select_last->{"net_eth1_inall"}?$ref_select_last->{"net_eth1_inall"}:-1;
our $eth1_out_last = defined $ref_select_last->{"net_eth1_outall"}?$ref_select_last->{"net_eth1_outall"}:-1;
$sqr_select_last->finish();

$sqr_select_last = $dbh->prepare("select name,thold from status_warning");
$sqr_select_last->execute();
while($ref_select_last = $sqr_select_last->fetchrow_hashref())
{
	my $name = $ref_select_last->{"name"};
	my $thold = $ref_select_last->{"thold"};
	if(defined $name && defined $thold)
	{
		$thold_hash{$name} = $thold;
	}
}
$sqr_select_last->finish();

our $ssh_conn = int(`ps -ef | grep -v 'grep' | grep -c 'ssh-audit'`) -1;
$ssh_conn = $ssh_conn < 0 ? 0 : $ssh_conn;
$ssh_conn = ceil($ssh_conn/2);
if(exists $thold_hash{"ssh"} && $ssh_conn > $thold_hash{"ssh"})
{
	push @abnormal_val,"ssh",$ssh_conn;
}

our $telnet_conn = int(`ps -ef | grep -v 'grep' | grep -c 'telnet'`) -1;
$telnet_conn = $telnet_conn < 0 ? 0 : $telnet_conn;
$telnet_conn = ceil($telnet_conn);
if(exists $thold_hash{"telnet"} && $telnet_conn > $thold_hash{"telnet"})
{
	push @abnormal_val,"telnet",$telnet_conn;
}

our $graph_conn = int(`ps -ef | grep -v 'grep' | grep -c 'Freesvr_RDP'`) -1;
$graph_conn = $graph_conn < 0 ? 0 : $graph_conn;
if(exists $thold_hash{"rdp"} && $graph_conn > $thold_hash{"rdp"})
{
	push @abnormal_val,"rdp",$graph_conn;
}

our $ftp_conn = int(`ps -ef | grep -v 'grep' | grep -c 'ftp-audit'`) -1;
$ftp_conn = $ftp_conn < 0 ? 0 : $ftp_conn;
if(exists $thold_hash{"ftp"} && $ftp_conn > $thold_hash{"ftp"})
{
	push @abnormal_val,"ftp",$ftp_conn;
}

our $db_conn = int(`ps -ef | grep -v 'grep' | grep -c 'freesvr_pcap_audit.pl'`);
if(exists $thold_hash{"db"} && $db_conn > $thold_hash{"db"})
{
	push @abnormal_val,"db",$db_conn;
}

our $cpu = `/usr/bin/top -b -n 1 | head -n 5 | grep -i 'cpu'`;
#$cpu = (split /,/,$cpu)[3];
if($cpu =~ /(\d+\.\d+)%id/i) {$cpu = $1;}
$cpu = 100 -$cpu;
if(exists $thold_hash{"cpu"} && $cpu > $thold_hash{"cpu"})
{
	push @abnormal_val,"cpu",$cpu;
}

our $memory = `free | grep -i 'mem'`;
my($total,$used,$buffers,$cache) = (split /\s+/,$memory)[1,2,5,6];
$memory = ceil(($used-$buffers-$cache)/$total*100);
if(exists $thold_hash{"memory"} && $memory > $thold_hash{"memory"})
{
	push @abnormal_val,"memory",$memory;
}

our $swap = `free | grep -i 'swap'`;
($total,$used) = (split /\s+/,$swap)[1,2];
$swap = ceil($used/$total*100);
if(exists $thold_hash{"swap"} && $swap > $thold_hash{"swap"})
{
	push @abnormal_val,"swap",$swap;
}

our $disk = `df | grep '/\$'`;
$disk = (split /\s+/,$disk)[4];
if($disk =~ /(\d+)%/){$disk = $1;}
if(exists $thold_hash{"disk"} && $disk > $thold_hash{"disk"})
{
	push @abnormal_val,"disk",$disk;
}

if(scalar @abnormal_val != 0)
{
	defined(my $pid = fork) or die "cannot fork:$!";
	unless($pid)
	{ 
		exec "/home/wuxiaolong/3_status/status_warning.pl",@abnormal_val;
	}
}

our $eth0_in_now = -1;our $eth0_out_now = -1;our $eth1_in_now = -1;our $eth1_out_now = -1;
our $eth0_in_value = -1;our $eth0_out_value = -1;our $eth1_in_value = -1;our $eth1_out_value = -1;
our $eth0_info = `/sbin/ifconfig eth0 2>&1| grep -i 'RX byte'`;
if(defined $eth0_info && $eth0_info =~ /RX\s*bytes\s*:\s*(\d+)/i){$eth0_in_now = $1;}
if(defined $eth0_info && $eth0_info =~ /TX\s*bytes\s*:\s*(\d+)/i){$eth0_out_now = $1;}

our $eth1_info = `/sbin/ifconfig eth1 2>&1| grep -i 'RX byte'`;
if(defined $eth1_info && $eth1_info =~ /RX\s*bytes\s*:\s*(\d+)/i){$eth1_in_now = $1;}
if(defined $eth1_info && $eth1_info =~ /TX\s*bytes\s*:\s*(\d+)/i){$eth1_out_now = $1;}

if($last_datetime != -1 && $eth0_in_now != -1 && $eth0_in_last != -1)
{
	$eth0_in_value = ($eth0_in_now-$eth0_in_last)/($time_now_utc-$last_datetime)*8;
	$eth0_out_value = ($eth0_out_now-$eth0_out_last)/($time_now_utc-$last_datetime)*8;
	if($eth0_in_value < 0){$eth0_in_value = -1;}
	if($eth0_out_value < 0){$eth0_out_value = -1;}
}

if($last_datetime != -1 && $eth1_out_now != -1 && $eth1_in_last != -1)
{
	$eth1_in_value = ($eth1_in_now-$eth1_in_last)/($time_now_utc-$last_datetime)*8;
	$eth1_out_value = ($eth1_out_now-$eth1_out_last)/($time_now_utc-$last_datetime)*8;
	if($eth1_in_value < 0){$eth1_in_value = -1;}
	if($eth1_out_value < 0){$eth1_out_value = -1;}
}

&mysql_insert($eth0_in_value,$eth0_out_value,$eth0_in_now,$eth0_out_now,$eth1_in_value,$eth1_out_value,$eth1_in_now,$eth1_out_now);


sub mysql_insert
{
	my($net_eth0_in,$net_eth0_out,$net_eth0_inall,$net_eth0_outall,$net_eth1_in,$net_eth1_out,$net_eth1_inall,$net_eth1_outall) = @_;
	my $sqr_insert;
	if($net_eth0_in == -1 && $net_eth0_inall == -1 && $net_eth1_in == -1 && $net_eth1_inall == -1)
	{
		$sqr_insert = $dbh->prepare("insert into status (datetime,ssh_conn,telnet_conn,graph_conn,ftp_conn,db_conn,cpu,memory,swap,disk) values ('$time_now_str',$ssh_conn,$telnet_conn,$graph_conn,$ftp_conn,$db_conn,$cpu,$memory,$swap,$disk)");

	}
	elsif($net_eth0_in == -1 && $net_eth0_inall == -1 && $net_eth1_in == -1 && $net_eth1_inall != -1)
	{
		$sqr_insert = $dbh->prepare("insert into status (datetime,ssh_conn,telnet_conn,graph_conn,ftp_conn,db_conn,cpu,memory,swap,disk,net_eth1_inall,net_eth1_outall) values ('$time_now_str',$ssh_conn,$telnet_conn,$graph_conn,$ftp_conn,$db_conn,$cpu,$memory,$swap,$disk,$net_eth1_inall,$net_eth1_outall)");
	}
	elsif($net_eth0_in == -1 && $net_eth0_inall == -1 && $net_eth1_in != -1 && $net_eth1_inall != -1)
	{
		$sqr_insert = $dbh->prepare("insert into status (datetime,ssh_conn,telnet_conn,graph_conn,ftp_conn,db_conn,cpu,memory,swap,disk,net_eth1_in,net_eth1_out,net_eth1_inall,net_eth1_outall) values ('$time_now_str',$ssh_conn,$telnet_conn,$graph_conn,$ftp_conn,$db_conn,$cpu,$memory,$swap,$disk,$net_eth1_in,$net_eth1_out,$net_eth1_inall,$net_eth1_outall)");
	}
	elsif($net_eth0_in == -1 && $net_eth0_inall != -1 && $net_eth1_in == -1 && $net_eth1_inall == -1)
	{
		$sqr_insert = $dbh->prepare("insert into status (datetime,ssh_conn,telnet_conn,graph_conn,ftp_conn,db_conn,cpu,memory,swap,disk,net_eth0_inall,net_eth0_outall) values ('$time_now_str',$ssh_conn,$telnet_conn,$graph_conn,$ftp_conn,$db_conn,$cpu,$memory,$swap,$disk,$net_eth0_inall,$net_eth0_outall)");
	}
	elsif($net_eth0_in == -1 && $net_eth0_inall != -1 && $net_eth1_in == -1 && $net_eth1_inall != -1)
	{
		$sqr_insert = $dbh->prepare("insert into status (datetime,ssh_conn,telnet_conn,graph_conn,ftp_conn,db_conn,cpu,memory,swap,disk,net_eth0_inall,net_eth0_outall,net_eth1_inall,net_eth1_outall) values ('$time_now_str',$ssh_conn,$telnet_conn,$graph_conn,$ftp_conn,$db_conn,$cpu,$memory,$swap,$disk,$net_eth0_inall,$net_eth0_outall,$net_eth1_inall,$net_eth1_outall)");
	}
	elsif($net_eth0_in == -1 && $net_eth0_inall != -1 && $net_eth1_in != -1 && $net_eth1_inall != -1)
	{
		$sqr_insert = $dbh->prepare("insert into status (datetime,ssh_conn,telnet_conn,graph_conn,ftp_conn,db_conn,cpu,memory,swap,disk,net_eth0_inall,net_eth0_outall,net_eth1_in,net_eth1_out,net_eth1_inall,net_eth1_outall) values ('$time_now_str',$ssh_conn,$telnet_conn,$graph_conn,$ftp_conn,$db_conn,$cpu,$memory,$swap,$disk,$net_eth0_inall,$net_eth0_outall,$net_eth1_in,$net_eth1_out,$net_eth1_inall,$net_eth1_outall)");
	}
	elsif($net_eth0_in != -1 && $net_eth0_inall != -1 && $net_eth1_in == -1 && $net_eth1_inall == -1)
	{
		$sqr_insert = $dbh->prepare("insert into status (datetime,ssh_conn,telnet_conn,graph_conn,ftp_conn,db_conn,cpu,memory,swap,disk,net_eth0_in,net_eth0_out,net_eth0_inall,net_eth0_outall) values ('$time_now_str',$ssh_conn,$telnet_conn,$graph_conn,$ftp_conn,$db_conn,$cpu,$memory,$swap,$disk,$net_eth0_in,$net_eth0_out,$net_eth0_inall,$net_eth0_outall)");
	}
	elsif($net_eth0_in != -1 && $net_eth0_inall != -1 && $net_eth1_in == -1 && $net_eth1_inall != -1)
	{
		$sqr_insert = $dbh->prepare("insert into status (datetime,ssh_conn,telnet_conn,graph_conn,ftp_conn,db_conn,cpu,memory,swap,disk,net_eth0_in,net_eth0_out,net_eth0_inall,net_eth0_outall,net_eth1_inall,net_eth1_outall) values ('$time_now_str',$ssh_conn,$telnet_conn,$graph_conn,$ftp_conn,$db_conn,$cpu,$memory,$swap,$disk,$net_eth0_in,$net_eth0_out,$net_eth0_inall,$net_eth0_outall,$net_eth1_inall,$net_eth1_outall)");
	}
	else
	{
		$sqr_insert = $dbh->prepare("insert into status (datetime,ssh_conn,telnet_conn,graph_conn,ftp_conn,db_conn,cpu,memory,swap,disk,net_eth0_in,net_eth0_out,net_eth0_inall,net_eth0_outall,net_eth1_in,net_eth1_out,net_eth1_inall,net_eth1_outall) values ('$time_now_str',$ssh_conn,$telnet_conn,$graph_conn,$ftp_conn,$db_conn,$cpu,$memory,$swap,$disk,$net_eth0_in,$net_eth0_out,$net_eth0_inall,$net_eth0_outall,$net_eth1_in,$net_eth1_out,$net_eth1_inall,$net_eth1_outall)");
	}

	$sqr_insert->execute();
	$sqr_insert->finish();
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
