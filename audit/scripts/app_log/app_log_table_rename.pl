#!/usr/bin/perl
use strict;
use warnings;
use DBI;
use DBD::mysql;
use Crypt::CBC;
use MIME::Base64;

our %table_names;

our($sec,$min,$hour,$mday,$mon,$year) = (localtime)[0..5];
($mday,$mon,$year) = (sprintf("%02d", $mday),sprintf("%02d", $mon + 1),$year+1900);
our $date = $year.$mon.$mday;

our($mysql_user,$mysql_passwd) = &get_local_mysql_config();
our $dbh=DBI->connect("DBI:mysql:database=audit_sec;host=localhost;mysql_connect_timeout=5",$mysql_user,$mysql_passwd,{RaiseError=>1});

our $sqr = $dbh->prepare("show tables");
$sqr->execute();
while(my @row=$sqr->fetchrow_array())
{
	$table_names{$row[0]} = 1;
}
$sqr->finish();

unless(exists $table_names{"applog$date"})
{
	$sqr = $dbh->prepare("rename table applog to applog$date");
	$sqr->execute();
	$sqr->finish();

	$sqr = $dbh->prepare("create table applog select * from applog$date where 1=2");
	$sqr->execute();
	$sqr->finish();
}
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
