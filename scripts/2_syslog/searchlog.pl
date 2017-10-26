#!/usr/bin/perl
use strict;
use warnings;
use DBI;
use DBD::mysql;
use Crypt::CBC;
use MIME::Base64;

our($mysql_user,$mysql_passwd) = &get_local_mysql_config();
our $dbh=DBI->connect("DBI:mysql:database=audit_sec;host=localhost;mysql_connect_timeout=5",$mysql_user,$mysql_passwd,{RaiseError=>1});

my $sqr_sql_select = $dbh->prepare("select `sql`,seq from log_searchlogs where status = 0");
$sqr_sql_select->execute();
while(my $ref_sql_select = $sqr_sql_select->fetchrow_hashref())
{
	my $sql = $ref_sql_select->{"sql"};
	my $seq = $ref_sql_select->{"seq"};
	my $tablename = "searchlog$seq";

	my $sqr_sql_update = $dbh->prepare("update log_searchlogs set starttime = now() where seq = $seq");
	$sqr_sql_update->execute();
	$sqr_sql_update->finish();

	my $sqr_sql_create = $dbh->prepare("create table $tablename $sql");
	$sqr_sql_create->execute();
	$sqr_sql_create->finish();

	$sqr_sql_update = $dbh->prepare("update log_searchlogs set endtime = now(),tables = '$tablename',status = 1 where seq = $seq");
	$sqr_sql_update->execute();
	$sqr_sql_update->finish();
}
$sqr_sql_select->finish();

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
