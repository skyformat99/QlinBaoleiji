#!/usr/bin/perl
use warnings;
use strict;
use DBI;
use DBD::mysql;
use Crypt::CBC;
use MIME::Base64;

our($mysql_user,$mysql_passwd) = &get_local_mysql_config();
our $dbh=DBI->connect("DBI:mysql:database=audit_sec;host=localhost;mysql_connect_timeout=5",$mysql_user,$mysql_passwd,{RaiseError=>1});
our $utf8 = $dbh->prepare("set names utf8");
$utf8->execute();
$utf8->finish();

our $time_now_utc = time;
our($min,$hour,$mday,$mon,$year) = (localtime $time_now_utc)[1..5];
($min,$hour,$mday,$mon,$year) = (sprintf("%02d", $min),sprintf("%02d", $hour),sprintf("%02d", $mday),sprintf("%02d", $mon + 1),$year+1900);
our $time_now_str = "$year$mon$mday$hour$min"."00";

my $sqr_select = $dbh->prepare("select device_ip,port from devices group by device_ip,port");
$sqr_select->execute();
while(my $ref_select = $sqr_select->fetchrow_hashref())
{
    my $device_ip = $ref_select->{"device_ip"};
    my $port = $ref_select->{"port"};

    my $nmap = `nmap -n -sT -p $port $device_ip`;
    my $flag = 0;
    
    my @lines = split /\n/,$nmap;
    foreach my $line(@lines)
    {
		if($flag == 1 && $line =~ /MAC\s*Address/i) {last;}

        if($flag == 1)
        {
            my($port,$status) = (split /\s+/,$line)[0,1];
            $port = (split /\//,$port)[0];
        
            if($status =~ /open/i)
            {
                my $sqr_update = $dbh->prepare("update devices set nmap_status=1,nmap_time='$time_now_str' where device_ip='$device_ip' and port=$port");
                $sqr_update->execute();
                $sqr_update->finish();
            }
            else
            {
                my $sqr_update = $dbh->prepare("update devices set nmap_status=0,nmap_time='$time_now_str' where device_ip='$device_ip' and port=$port");
                $sqr_update->execute();
                $sqr_update->finish();
            }
        }
        elsif($line =~ /PORT\s*STATE\s*SERVICE/i)
        {
            $flag = 1;
        }
    }
    if($flag == 0)
    {
        my $sqr_update = $dbh->prepare("update devices set nmap_status=0,nmap_time='$time_now_str' where device_ip='$device_ip' and port=$port");
        $sqr_update->execute();
        $sqr_update->finish();
    }
}
$sqr_select->finish();
my $rc = $dbh->disconnect;

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
