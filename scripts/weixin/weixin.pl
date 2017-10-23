#!/usr/bin/perl
use warnings;
use strict;
use DBI;
use DBD::mysql;
use Crypt::CBC;
use MIME::Base64;
use POSIX qw/ceil floor/;

our $cipher = Crypt::CBC->new( -key => 'freesvr', -cipher => 'Blowfish', -iv => 'freesvr1', -header => 'none');
our $remote_mysql_user = "ctsi";
our $remote_mysql_passwd = "3a33NO0nmkLF5WXEF1oWNw==";
$remote_mysql_passwd = decode_base64($remote_mysql_passwd);
$remote_mysql_passwd = $cipher->decrypt($remote_mysql_passwd);

my($sec,$min,$hour,$mday,$mon,$year) = (localtime)[0..5];
($sec,$min,$hour,$mday,$mon,$year) = (sprintf("%02d", $sec),sprintf("%02d", $min),sprintf("%02d", $hour),sprintf("%02d", $mday),sprintf("%02d", $mon + 1),$year+1900);
our $time_now_str = "$year$mon$mday$hour$min"."00";
our $date_now_str = "$year-$mon-$mday";

our($mysql_user,$mysql_passwd) = &get_local_mysql_config();
my $local_dbh=DBI->connect("DBI:mysql:database=audit_sec;host=localhost;mysql_connect_timeout=5",$mysql_user,$mysql_passwd,{RaiseError=>1});
my $utf8 = $local_dbh->prepare("set names utf8");
$utf8->execute();
$utf8->finish();

my $remote_dbh=DBI->connect("DBI:mysql:database=ecitic;host=10.110.24.11;mysql_connect_timeout=5",$remote_mysql_user,$remote_mysql_passwd,{RaiseError=>1});
$utf8 = $remote_dbh->prepare("set names utf8");
$utf8->execute();
$utf8->finish();

my $sqr_select = $remote_dbh->prepare("SELECT sum(NEW)sumAttentnum,sum(REG)sumRegnum,sum(BIND)sumBindnum FROM wxtl_stat_user_op_info group by STAT_DATE HAVING STAT_DATE = '$date_now_str'");
$sqr_select->execute();
my $ref_select = $sqr_select->fetchrow_hashref();
my $sumAttentnum = $ref_select->{"sumAttentnum"};
my $sumRegnum = $ref_select->{"sumRegnum"};
my $sumBindnum = $ref_select->{"sumBindnum"};
$sqr_select->finish();

$sqr_select = $remote_dbh->prepare("select count(*) '订单数',sum(payprice) + sum(feevalue) '总金额' from ecitic.wxtl_order where orderstate=1 and date_format (traninserttime,'%Y-%m-%d')= '$date_now_str'");
$sqr_select->execute();
$ref_select = $sqr_select->fetchrow_hashref();
my $sumpaynum = $ref_select->{"订单数"};
my $summoneynum = $ref_select->{"总金额"};
$sqr_select->finish();

$sqr_select = $remote_dbh->prepare("select sum(total_fee)/100 '支付金额' from ecitic.wxtl_order_pay p,ecitic.wxtl_order o where p.transaction_id=o.completeid and p.out_trade_no=o.orderid and p.trade_state=0 and date_format (time_end,'%Y-%m-%d')= '$date_now_str'");
$sqr_select->execute();
$ref_select = $sqr_select->fetchrow_hashref();
my $sumpaymoneynum = $ref_select->{"支付金额"};
$sqr_select->finish();

my $cmd1 = "insert into weixin(date";
my $cmd2 = "values ('$date_now_str'";

if(defined $sumAttentnum)
{
    $cmd1 .= ",sumAttentnum";
    $cmd2 .= ",".floor($sumAttentnum);
}

if(defined $sumRegnum)
{
    $cmd1 .= ",sumRegnum";
    $cmd2 .= ",".floor($sumRegnum);
}

if(defined $sumBindnum)
{
    $cmd1 .= ",sumBindnum";
    $cmd2 .= ",".floor($sumBindnum);
}

if(defined $sumpaynum)
{
    $cmd1 .= ",sumpaynum";
    $cmd2 .= ",".floor($sumpaynum);
}

if(defined $summoneynum)
{
    $cmd1 .= ",summoneynum";
    $cmd2 .= ",".floor($summoneynum);
}

if(defined $sumpaymoneynum)
{
    $cmd1 .= ",sumpaymoneynum";
    $cmd2 .= ",".floor($sumpaymoneynum);
}

$cmd1 .= ")";
$cmd2 .= ")";

my $sqr_insert = $local_dbh->prepare("$cmd1 $cmd2");
$sqr_insert->execute();
$sqr_insert->finish();

$remote_dbh->disconnect();
$local_dbh->disconnect();

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
