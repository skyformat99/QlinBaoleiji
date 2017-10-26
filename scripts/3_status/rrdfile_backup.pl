#!/usr/bin/perl
use warnings;
use strict;
use DBI;
use DBD::mysql;
use Crypt::CBC;
use MIME::Base64;

our $backup_path = "/opt/freesvr/nm/backup";

$backup_path =~ s/\/$//;
unless(-e $backup_path)
{
    `mkdir -p $backup_path`;
}

our $time_now_utc = time;
our($min,$hour,$mday,$mon,$year) = (localtime $time_now_utc)[1..5];
($min,$hour,$mday,$mon,$year) = (sprintf("%02d", $min),sprintf("%02d", $hour),sprintf("%02d", $mday),sprintf("%02d", $mon + 1),$year+1900);
our $time_now_str = "$year$mon$mday$hour$min"."00";
our $date_now_str = "$year-$mon-$mday";

unless(-e "$backup_path/$date_now_str")
{
    mkdir "$backup_path/$date_now_str",0755;
}

our($mysql_user,$mysql_passwd) = &get_local_mysql_config();
our $dbh=DBI->connect("DBI:mysql:database=audit_sec;host=localhost;mysql_connect_timeout=5",$mysql_user,$mysql_passwd,{RaiseError=>1});
my $utf8 = $dbh->prepare("set names utf8");
$utf8->execute();
$utf8->finish();

&snmp_status_backup("device_status");
&app_status_backup("app_status");
&local_status_backup("localhost_status");

my $sqr_insert = $dbh->prepare("insert into rrdfile_backup_log(date,backup_path) values('$date_now_str','$backup_path/$date_now_str')");
$sqr_insert->execute();
$sqr_insert->finish();

$dbh->disconnect;

sub snmp_status_backup
{
    my($sub_dir) = @_;
    my $sqr_select = $dbh->prepare("select device_ip,rrdfile from snmp_status where enable = 1");
    $sqr_select->execute();
    while(my $ref_select = $sqr_select->fetchrow_hashref())
    {
        my $device_ip = $ref_select->{"device_ip"};
        my $rrdfile = $ref_select->{"rrdfile"};

        unless(-e $rrdfile)
        {
            next;
        }

        unless(-e "$backup_path/$date_now_str/$device_ip")
        {
            mkdir "$backup_path/$date_now_str/$device_ip",0755;
        }

        unless(-e "$backup_path/$date_now_str/$device_ip/$sub_dir")
        {
            mkdir "$backup_path/$date_now_str/$device_ip/$sub_dir",0755;
        }

        `cp $rrdfile $backup_path/$date_now_str/$device_ip/$sub_dir`;
    }
    $sqr_select->finish();
}

sub app_status_backup
{
    my($sub_dir) = @_;
    my $sqr_select = $dbh->prepare("select device_ip,app_name,rrdfile from app_status where enable = 1");
    $sqr_select->execute();
    while(my $ref_select = $sqr_select->fetchrow_hashref())
    {
        my $device_ip = $ref_select->{"device_ip"};
        my $app_name = $ref_select->{"app_name"};
        my $rrdfile = $ref_select->{"rrdfile"};

        $app_name .= "_status";
        unless(-e $rrdfile)
        {
            next;
        }

        unless(-e "$backup_path/$date_now_str/$device_ip")
        {
            mkdir "$backup_path/$date_now_str/$device_ip",0755;
        }

        unless(-e "$backup_path/$date_now_str/$device_ip/$sub_dir")
        {
            mkdir "$backup_path/$date_now_str/$device_ip/$sub_dir",0755;
        }

        unless(-e "$backup_path/$date_now_str/$device_ip/$sub_dir/$app_name")
        {
            mkdir "$backup_path/$date_now_str/$device_ip/$sub_dir/$app_name",0755;
        }

        `cp $rrdfile $backup_path/$date_now_str/$device_ip/$sub_dir/$app_name`;
    }
    $sqr_select->finish();
}

sub local_status_backup
{
    my($sub_dir) = @_;
    my $sqr_select = $dbh->prepare("select rrdfile from local_status where enable = 1");
    $sqr_select->execute();
    while(my $ref_select = $sqr_select->fetchrow_hashref())
    {
        my $rrdfile = $ref_select->{"rrdfile"};

        unless(-e $rrdfile)
        {
            next;
        }

        unless(-e "$backup_path/$date_now_str/$sub_dir")
        {
            mkdir "$backup_path/$date_now_str/$sub_dir",0755;
        }

        `cp $rrdfile $backup_path/$date_now_str/$sub_dir`;
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
