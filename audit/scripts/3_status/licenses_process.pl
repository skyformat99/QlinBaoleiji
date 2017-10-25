#!/usr/bin/perl
use warnings;
use strict;
use DBI;
use DBD::mysql;
use Crypt::CBC;
use MIME::Base64;

our $time_now_utc = time;
our($min,$hour,$mday,$mon,$year) = (localtime $time_now_utc)[1..5];
($min,$hour,$mday,$mon,$year) = (sprintf("%02d", $min),sprintf("%02d", $hour),sprintf("%02d", $mday),sprintf("%02d", $mon + 1),$year+1900);
our $time_now_str = "$year$mon$mday$hour$min"."00";

our($mysql_user,$mysql_passwd) = &get_local_mysql_config();
my $dbh=DBI->connect("DBI:mysql:database=audit_sec;host=localhost;mysql_connect_timeout=5",$mysql_user,$mysql_passwd,{RaiseError=>1});
my $utf8 = $dbh->prepare("set names utf8");
$utf8->execute();
$utf8->finish();

my $sqr_truncate = $dbh->prepare("truncate snmp_nm_other");
$sqr_truncate->execute();
$sqr_truncate->finish();

my $context = `/opt/freesvr/audit/sbin/license-print`;
my($licenses_time,$licenses_num,$licenses_SN) = split /\s+/,$context;

if($licenses_time eq "-1")
{
	$licenses_time = $licenses_num = $licenses_SN = undef;
}
else
{
	$licenses_time =~ s/-//g;
}

my $sqr_select = $dbh->prepare("select count(*) from servers");
$sqr_select->execute();
my $ref_select = $sqr_select->fetchrow_hashref();
my $servers_num = $ref_select->{"count(*)"};
$sqr_select->finish();

$sqr_select = $dbh->prepare("select count(*) from member");
$sqr_select->execute();
$ref_select = $sqr_select->fetchrow_hashref();
my $member_num = $ref_select->{"count(*)"};
$sqr_select->finish();

$sqr_select = $dbh->prepare("select count(*) from devices");
$sqr_select->execute();
$ref_select = $sqr_select->fetchrow_hashref();
my $devices_num = $ref_select->{"count(*)"};
$sqr_select->finish();

my $insert_attr = "(datetime";
my $insert_val = "('$time_now_str'";

if(defined $licenses_time && $licenses_time =~ /\d+/)
{
	$insert_attr .= ",licenses_time";
	$insert_val .= ",'$licenses_time'";
}

if(defined $licenses_num && $licenses_num =~ /\d+/)
{
	$insert_attr .= ",licenses_num";
	$insert_val .= ",$licenses_num";
}

if(defined $licenses_SN)
{
	$insert_attr .= ",licenses_SN";
	$insert_val .= ",'$licenses_SN'";
}

$insert_attr .= ",servers_num,member_num,devices_num)";
$insert_val .= ",$servers_num,$member_num,$devices_num)";

#print "insert into snmp_nm_other $insert_attr values $insert_val\n";
#exit;

my $sqr_insert = $dbh->prepare("insert into snmp_nm_other $insert_attr values $insert_val");
$sqr_insert->execute();
$sqr_insert->finish();

$dbh->disconnect();

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
