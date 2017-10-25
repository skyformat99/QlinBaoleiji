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

my $sqr_select_count = $dbh->prepare("select server,user,srcip,protocol,status from log_login_day_count where date>=CURDATE()-interval 1 week and date<CURDATE() group by server,user,srcip,protocol,status");
$sqr_select_count->execute();
while(my $ref_select_count = $sqr_select_count->fetchrow_hashref())
{
	my $sql_count = "select min(date),sum(count) from log_login_day_count where ";
	my $sql_insert_format = "insert into log_login_week_count (date_end";
	my $sql_insert_value = " values (CURDATE()-interval 1 day";


	my $server = $ref_select_count->{"server"};
	if(defined $server)
	{
		$sql_count.="server = '$server' and ";
		$sql_insert_format.= ",server";
		$sql_insert_value.= ",'$server'";
	}
	else{$sql_count.="server is null and ";}

	my $user = $ref_select_count->{"user"};
	if(defined $user)
	{
		$sql_count.="user = '$user' and ";
		$sql_insert_format.= ",user";
		$sql_insert_value.= ",'$user'";
	}
	else{$sql_count.="user is null and ";}

	my $srcip = $ref_select_count->{"srcip"};
	if(defined $srcip)
	{
		$sql_count.="srcip = '$srcip' and ";
		$sql_insert_format.= ",srcip";
		$sql_insert_value.= ",'$srcip'";
	}
	else{$sql_count.="srcip is null and ";}

	my $protocol = $ref_select_count->{"protocol"};
	if(defined $protocol)
	{
		$sql_count.="protocol = '$protocol' and ";
		$sql_insert_format.= ",protocol";
		$sql_insert_value.= ",'$protocol'";
	}
	else{$sql_count.="protocol is null and ";}

	my $status = $ref_select_count->{"status"};
	if(defined $status)
	{
		$sql_count.="status = '$status' ";
		$sql_insert_format.= ",status";
		$sql_insert_value.= ",'$status'";
	}
	else{$sql_count.="status is null ";}

	my $sqr_select_dateandcount = $dbh->prepare("$sql_count");
	$sqr_select_dateandcount->execute();
	my $ref_select_dateandcount = $sqr_select_dateandcount->fetchrow_hashref();
	my $date_min = $ref_select_dateandcount->{"min(date)"};
	my $sum_count = $ref_select_dateandcount->{"sum(count)"};

	$sql_insert_format.= ",date_start";
	$sql_insert_value.= ",'$date_min'";

	$sql_insert_format.= ",week_num";
	$sql_insert_value.= ",DATE_FORMAT('$date_min','%v')";

	$sql_insert_format.=",count)";
	$sql_insert_value.= ",$sum_count)";

	my $sqr_insert = $dbh->prepare("$sql_insert_format$sql_insert_value");
	$sqr_insert->execute();
	$sqr_insert->finish();
}
$sqr_select_count->finish();

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
