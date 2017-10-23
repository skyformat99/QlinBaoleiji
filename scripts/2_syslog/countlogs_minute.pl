#!/usr/bin/perl
use warnings;
use strict;
use DBI;
use DBD::mysql;
use Crypt::CBC;
use MIME::Base64;

our($mysql_user,$mysql_passwd) = &get_local_mysql_config();
our $dbh=DBI->connect("DBI:mysql:database=audit_sec;host=localhost;mysql_connect_timeout=5",$mysql_user,$mysql_passwd,{RaiseError=>1});

my $sqr_select_time = $dbh->prepare("select max(date) from log_countlogs_minuter_detailed");
$sqr_select_time->execute();
my $ref_select_time = $sqr_select_time->fetchrow_hashref();
our $time = $ref_select_time->{"max(date)"};
$sqr_select_time->finish();

#server count
my $sqr_select_server = $dbh->prepare("select host,alllog from log_countlogs_minuter_detailed where date = '$time'");
$sqr_select_server->execute();
while(my $ref_select_server = $sqr_select_server->fetchrow_hashref())
{
	my $host = $ref_select_server->{"host"};
	my $log_count = $ref_select_server->{"alllog"};

	my $sqr_insert = $dbh->prepare("insert into log_countlogs_minuter_server (date,host,alllog) values ('$time','$host',$log_count)");
	$sqr_insert->execute();
	$sqr_insert->finish();
}
$sqr_select_server->finish();

#level count
my $log_sum_level = 0;
my @level = qw/DEBUG INFO NOTICE WARNING ERR CRIT ALERT EMERG/;
foreach(@level)
{
	my $sqr_select_level = $dbh->prepare("select sum($_) from log_countlogs_minuter_detailed where date = '$time'");
	$sqr_select_level->execute();
	my $ref_select_level = $sqr_select_level->fetchrow_hashref();
	my $log_count = $ref_select_level->{"sum($_)"};
	$log_sum_level += $log_count;
	$sqr_select_level->finish();

	my $sqr_insert = $dbh->prepare("insert into log_countlogs_minuter_level (date,level,alllog) values ('$time','$_',$log_count)");
	$sqr_insert->execute();
	$sqr_insert->finish();
}

=pod
#all count
my $debug_sum=0;my $info_sum=0;my $notice_sum=0;my $warning_sum=0;my $err_sum=0;my $crit_sum=0;my $alert_sum=0;my $emerg_sum=0;my $actionlog_sum=0;my $alllog_sum=0;
my $sqr_select_datailed = $dbh->prepare("select * from countlogs");
$sqr_select_datailed->execute();
while(my $ref_select_datailed = $sqr_select_datailed->fetchrow_hashref())
{
	my $host = $ref_select_datailed->{"host"};
	my $debug = $ref_select_datailed->{"DEBUG"};
	$debug_sum += $debug;

	my $info = $ref_select_datailed->{"INFO"};
	$info_sum += $info;

	my $notice = $ref_select_datailed->{"NOTICE"};
	$notice_sum += $notice;

	my $warning = $ref_select_datailed->{"WARNING"};
	$warning_sum += $warning;

	my $err = $ref_select_datailed->{"ERR"};
	$err_sum += $err;

	my $crit = $ref_select_datailed->{"CRIT"};
	$crit_sum += $crit;
	my $alert = $ref_select_datailed->{"ALERT"};
	$alert_sum += $alert;

	my $emerg = $ref_select_datailed->{"EMERG"};
	$emerg_sum += $emerg;

	my $actionlog = $ref_select_datailed->{"actionlog"};
	$actionlog_sum += $actionlog;

	my $alllog = $ref_select_datailed->{"alllog"};
	$alllog_sum += $alllog;

	my $sqr_insert = $dbh->prepare("insert into countlogs_minuter_detailed (host,date,DEBUG,INFO,NOTICE,WARNING,ERR,CRIT,ALERT,EMERG,actionlog,alllog) values ('$host','$time',$debug,$info,$notice,$warning,$err,$crit,$alert,$emerg,$actionlog,$alllog)");
	$sqr_insert->execute();
	$sqr_insert->finish();
}
$sqr_select_datailed->finish();

$sqr_insert_sum = $dbh->prepare("insert into countlogs_minuter_detailed (host,date,DEBUG,INFO,NOTICE,WARNING,ERR,CRIT,ALERT,EMERG,actionlog,alllog) values ('all','$time',$debug_sum,$info_sum,$notice_sum,$warning_sum,$err_sum,$crit_sum,$alert_sum,$emerg_sum,$actionlog_sum,$alllog_sum)");
$sqr_insert_sum->execute();
$sqr_insert_sum->finish();

#truncate
my $sqr_truncate = $dbh->prepare("truncate countlogs");
$sqr_truncate->execute();
$sqr_truncate->finish();
=cut

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
