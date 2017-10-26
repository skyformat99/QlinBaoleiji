#!/usr/bin/perl
use warnings;
use strict;
use DBI;
use DBD::mysql;
use Crypt::CBC;
use MIME::Base64;

our($mysql_user,$mysql_passwd) = &get_local_mysql_config();
our $dbh=DBI->connect("DBI:mysql:database=audit_sec;host=localhost;mysql_connect_timeout=5",$mysql_user,$mysql_passwd,{RaiseError=>1});

our $sqr_select = $dbh->prepare("select count(*) from status_day_count where date >= now()-interval 1 month and date < now()");
$sqr_select->execute();
our $ref_select = $sqr_select->fetchrow_hashref();
our $num = $ref_select->{"count(*)"};
$sqr_select->finish();

our $eth0_num=0;our $eth1_num=0;

$sqr_select = $dbh->prepare("select min(date) from status_day_count where date >= now()-interval 1 month and date < now()");
$sqr_select->execute();
$ref_select = $sqr_select->fetchrow_hashref();
our $min_date = $ref_select->{"min(date)"};
$sqr_select->finish();
if(!defined $min_date){exit;}

our $ssh_conn=0;our $telnet_conn=0;our $graph_conn=0;our $ftp_conn=0;our $db_conn=0;our $cpu=0;our $memory=0;our $swap=0;our $disk=0;our $eth0_in=0;our $eth0_out;our $eth1_in=0;our $eth1_out=0;

$sqr_select = $dbh->prepare("select * from status_day_count where date >= now()-interval 1 month and date < now()");
$sqr_select->execute();
while($ref_select = $sqr_select->fetchrow_hashref())
{
	$ssh_conn += $ref_select->{"ssh_conn"};
	$telnet_conn += $ref_select->{"telnet_conn"};
	$graph_conn += $ref_select->{"graph_conn"};
	$ftp_conn += $ref_select->{"ftp_conn"};
	$db_conn += $ref_select->{"db_conn"};
	$cpu += $ref_select->{"cpu"};
	$memory += $ref_select->{"memory"};
	$swap += $ref_select->{"swap"};
	$disk += $ref_select->{"disk"};
	if(defined $ref_select->{"net_eth0_in"})
	{
		$eth0_in += $ref_select->{"net_eth0_in"};
		$eth0_out += $ref_select->{"net_eth0_out"};
		++$eth0_num;
	}
	if(defined $ref_select->{"net_eth1_in"})
	{
		$eth1_in += $ref_select->{"net_eth1_in"};
		$eth1_out += $ref_select->{"net_eth1_out"};
		++$eth1_num;
	}
}

$ssh_conn /= $num;
$telnet_conn /= $num;
$graph_conn /= $num;
$ftp_conn /= $num;
$db_conn /= $num;
$cpu /= $num;
$memory /= $num;
$swap /= $num;
$disk /= $num;
if($eth0_num != 0)
{
	$eth0_in /= $eth0_num;
	$eth0_out /= $eth0_num;
}
else
{
	$eth0_in = $eth0_out = -1;
}
if($eth1_num != 0)
{
	$eth1_in /= $eth1_num;
	$eth1_out /= $eth1_num;
}
else
{
	$eth1_in = $eth1_out = -1;
}

our $sqr_insert;
if($eth0_in == -1 && $eth1_in == -1)
{
	$sqr_insert = $dbh->prepare("insert into status_month_count (date_start,date_end,ssh_conn,telnet_conn,graph_conn,ftp_conn,db_conn,cpu,memory,swap,disk) values ('$min_date',(CURDATE()-interval 1 day),$ssh_conn,$telnet_conn,$graph_conn,$ftp_conn,$db_conn,$cpu,$memory,$swap,$disk)");
}
elsif($eth0_in != -1 && $eth1_in == -1)
{
	$sqr_insert = $dbh->prepare("insert into status_month_count (date_start,date_end,ssh_conn,telnet_conn,graph_conn,ftp_conn,db_conn,cpu,memory,swap,disk,net_eth0_in,net_eth0_out) values ('$min_date',(CURDATE()-interval 1 day),$ssh_conn,$telnet_conn,$graph_conn,$ftp_conn,$db_conn,$cpu,$memory,$swap,$disk,$eth0_in,$eth0_out)");
}
elsif($eth0_in == -1 && $eth1_in != -1)
{
	$sqr_insert = $dbh->prepare("insert into status_month_count (date_start,date_end,ssh_conn,telnet_conn,graph_conn,ftp_conn,db_conn,cpu,memory,swap,disk,net_eth1_in,net_eth1_out) values ('$min_date',(CURDATE()-interval 1 day),$ssh_conn,$telnet_conn,$graph_conn,$ftp_conn,$db_conn,$cpu,$memory,$swap,$disk,$eth1_in,$eth1_out)");
}
else
{
	$sqr_insert = $dbh->prepare("insert into status_month_count (date_start,date_end,ssh_conn,telnet_conn,graph_conn,ftp_conn,db_conn,cpu,memory,swap,disk,net_eth0_in,net_eth0_out,net_eth1_in,net_eth1_out) values ('$min_date',(CURDATE()-interval 1 day),$ssh_conn,$telnet_conn,$graph_conn,$ftp_conn,$db_conn,$cpu,$memory,$swap,$disk,$eth0_in,$eth0_out,$eth1_in,$eth1_out)");
}

$sqr_insert->execute();
$sqr_insert->finish();

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
