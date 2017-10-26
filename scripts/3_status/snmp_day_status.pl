#!/usr/bin/perl
use warnings;
use strict;
use DBI;
use DBD::mysql;
use Crypt::CBC;
use MIME::Base64;

my($mday,$mon,$year) = (localtime)[3..5];
($mday,$mon,$year) = (sprintf("%02d", $mday),sprintf("%02d", $mon + 1),$year+1900);
our $date = "$year$mon$mday";

our($mysql_user,$mysql_passwd) = &get_local_mysql_config();
our $dbh=DBI->connect("DBI:mysql:database=audit_sec;host=localhost;mysql_connect_timeout=5",$mysql_user,$mysql_passwd,{RaiseError=>1});

my $sqr_select = $dbh->prepare("select * from snmp_day_count where date >= now()-interval 1 day and date < now()");
$sqr_select->execute();
while(my $ref_select = $sqr_select->fetchrow_hashref())
{
	my $device_ip = $ref_select->{"device_ip"};
	my $date = $ref_select->{"date"};
	my $type = $ref_select->{"type"};
	my $avg_value = $ref_select->{"total_value"}/$ref_select->{"count"};
	my $max_value = $ref_select->{"max_value"};
	my $disk = $ref_select->{"disk"};

	if(defined $disk)
	{
		my $sqr_insert = $dbh->prepare("insert into snmp_day_status(device_ip,date,type,avg_value,max_value,disk) values ('$device_ip','$date','$type',$avg_value,$max_value,'$disk')");
		$sqr_insert->execute();
		$sqr_insert->finish();
	}
	else
	{
		my $sqr_insert = $dbh->prepare("insert into snmp_day_status(device_ip,date,type,avg_value,max_value) values ('$device_ip','$date','$type',$avg_value,$max_value)");
		$sqr_insert->execute();
		$sqr_insert->finish();
	}
}
$sqr_select->finish();

my $sqr_delete = $dbh->prepare("delete from snmp_day_count where date <= now()-interval 1 day");
$sqr_delete->execute();
$sqr_delete->finish();

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
