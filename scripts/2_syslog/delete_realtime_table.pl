#!/usr/bin/perl
use warnings;
use strict;
use DBI;
use DBD::mysql;
use Crypt::CBC;
use MIME::Base64;

our $exist_line = 1000;

our($mysql_user,$mysql_passwd) = &get_local_mysql_config();
our $dbh=DBI->connect("DBI:mysql:database=audit_sec;host=localhost;mysql_connect_timeout=5",$mysql_user,$mysql_passwd,{RaiseError=>1});

our $utf8 = $dbh->prepare("set names utf8");
$utf8->execute();
$utf8->finish();


my $sqr_count = $dbh->prepare("select count(seq) from log_realtimelogs");
$sqr_count->execute();
my $ref_count = $sqr_count->fetchrow_hashref();
my $count = $ref_count->{"count(seq)"};
$sqr_count->finish();

if($count > $exist_line)
{
	my $delete_realtimelogs = $dbh->prepare("delete from log_realtimelogs where seq <= ((select max(seq) from (select seq from realtimelogs) as real2)-$exist_line)");
	$delete_realtimelogs->execute();
	$delete_realtimelogs->finish();
}

my $delete_linux_login = $dbh->prepare("delete from log_linux_login where endtime<curdate()-interval 1 week");
$delete_linux_login->execute();
$delete_linux_login->finish();

my $delete_windows_login = $dbh->prepare("delete from log_windows_login where endtime<curdate()-interval 1 week");
$delete_windows_login->execute();
$delete_windows_login->finish();

my $delete_logs_login = $dbh->prepare("delete from log_logs where datetime<curdate()-interval 1 week");
$delete_logs_login->execute();
$delete_logs_login->finish();

my $delete_status_login = $dbh->prepare("delete from log_status where datetime<curdate()-interval 1 week");
$delete_status_login->execute();
$delete_status_login->finish();

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
