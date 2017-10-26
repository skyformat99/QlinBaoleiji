#!/usr/bin/perl
use warnings;
use strict;
use DBI;
use DBD::mysql;
use Crypt::CBC;
use MIME::Base64;

our($mysql_user,$mysql_passwd) = &get_local_mysql_config();
our $dbh=DBI->connect("DBI:mysql:database=audit_sec;host=localhost;mysql_connect_timeout=5",$mysql_user,$mysql_passwd,{RaiseError=>1});

#server count
my $sqr_select_server = $dbh->prepare("select host from log_countlogs_minuter_server where date>=date_format(now(),'%Y%m%d000000') - interval 1 day and date<date_format(now(),'%Y%m%d000000') group by host");
$sqr_select_server->execute();
while(my $ref_select_server = $sqr_select_server->fetchrow_hashref())
{
	my $host = $ref_select_server->{"host"};

	my $sqr_select_count = $dbh->prepare("select sum(alllog) from log_countlogs_minuter_server where host = '$host' and date>=date_format(now(),'%Y%m%d000000') - interval 1 day and date<date_format(now(),'%Y%m%d000000')");
	$sqr_select_count->execute();
	my $ref_select_count = $sqr_select_count->fetchrow_hashref();
	my $log_count = $ref_select_count->{"sum(alllog)"};
	$sqr_select_count->finish();

	my $sqr_insert = $dbh->prepare("insert into log_countlogs_day_server (date,host,alllog) values (date_format(now(),'%Y%m%d000000') - interval 1 day,'$host',$log_count)");
	$sqr_insert->execute();
	$sqr_insert->finish();
}
$sqr_select_server->finish();

#level count
my @level = qw/DEBUG INFO NOTICE WARNING ERR CRIT ALERT EMERG/;
foreach(@level)
{
	my $sqr_select_level = $dbh->prepare("select sum(alllog) from log_countlogs_minuter_level where level = '$_' and date>=date_format(now(),'%Y%m%d000000') - interval 1 day and date<date_format(now(),'%Y%m%d000000')");
	$sqr_select_level->execute();
	my $ref_select_level = $sqr_select_level->fetchrow_hashref();
	my $log_count = $ref_select_level->{"sum(alllog)"};
	$sqr_select_level->finish();
	unless(defined $log_count){$log_count = 0;}

	my $sqr_insert = $dbh->prepare("insert into log_countlogs_day_level (date,level,alllog) values (date_format(now(),'%Y%m%d000000') - interval 1 day,'$_',$log_count)");
	$sqr_insert->execute();
	$sqr_insert->finish();
}

#all count
$sqr_select_server = $dbh->prepare("select host from log_countlogs_minuter_detailed where date>=date_format(now(),'%Y%m%d000000') - interval 1 day and date<date_format(now(),'%Y%m%d000000') group by host");
$sqr_select_server->execute();
while(my $ref_select_server = $sqr_select_server->fetchrow_hashref())
{
	my $host = $ref_select_server->{"host"};

	my $sqr_select_datailed = $dbh->prepare("select sum(DEBUG),sum(INFO),sum(NOTICE),sum(WARNING),sum(ERR),sum(CRIT),sum(ALERT),sum(EMERG),sum(actionlog),sum(alllog) from log_countlogs_minuter_detailed where host = '$host' and date>=date_format(now(),'%Y%m%d000000') - interval 1 day and date<date_format(now(),'%Y%m%d000000')");
	$sqr_select_datailed->execute();
	my $ref_select_datailed = $sqr_select_datailed->fetchrow_hashref();

	my $debug = $ref_select_datailed->{"sum(DEBUG)"};
	my $info = $ref_select_datailed->{"sum(INFO)"};
	my $notice = $ref_select_datailed->{"sum(NOTICE)"};
	my $warning = $ref_select_datailed->{"sum(WARNING)"};
	my $err = $ref_select_datailed->{"sum(ERR)"};
	my $crit = $ref_select_datailed->{"sum(CRIT)"};
	my $alert = $ref_select_datailed->{"sum(ALERT)"};
	my $emerg = $ref_select_datailed->{"sum(EMERG)"};
	my $actionlog = $ref_select_datailed->{"sum(actionlog)"};
	my $alllog = $ref_select_datailed->{"sum(alllog)"};

	my $sqr_insert = $dbh->prepare("insert into log_countlogs_day_detailed (host,date,DEBUG,INFO,NOTICE,WARNING,ERR,CRIT,ALERT,EMERG,actionlog,alllog) values ('$host',date_format(now(),'%Y%m%d000000') - interval 1 day,$debug,$info,$notice,$warning,$err,$crit,$alert,$emerg,$actionlog,$alllog)");
	$sqr_insert->execute();
	$sqr_insert->finish();

	$sqr_select_datailed->finish();
}
$sqr_select_server->finish();


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
