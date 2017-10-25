#!/usr/bin/perl
use warnings;
use strict;
use DBI;
use DBD::mysql;
use Crypt::CBC;
use MIME::Base64;

our $host = "118.186.17.101";

our $time_now_utc = time;
our($min,$hour,$mday,$mon,$year) = (localtime $time_now_utc)[1..5];
($min,$hour,$mday,$mon,$year) = (sprintf("%02d", $min),sprintf("%02d", $hour),sprintf("%02d", $mday),sprintf("%02d", $mon + 1),$year+1900);
our $time_now_str = "$year$mon$mday$hour$min"."00";

our($mysql_user,$mysql_passwd) = &get_local_mysql_config();
my $dbh=DBI->connect("DBI:mysql:database=audit_nm;host=localhost;mysql_connect_timeout=5",$mysql_user,$mysql_passwd,{RaiseError=>1});
my $utf8 = $dbh->prepare("set names utf8");
$utf8->execute();
$utf8->finish();

my $sqr_truncate = $dbh->prepare("truncate snmp_nm_weblogin");
$sqr_truncate->execute();
$sqr_truncate->finish();

opendir(my $dir,"/tmp");
foreach my $file(readdir $dir)
{
	if($file =~ /^sess_/i)
	{
		open(my $fd,"</tmp/$file");

		my $username = undef;
		my $logintime = undef;
		my $startonlinetime = undef;
		my $sourceip = undef;
		my $level = undef;

		foreach my $line(<$fd>)
		{
			my @attr_arr = split /;/,$line;
			foreach my $attr(@attr_arr)
			{
				if($attr =~ /ADMIN_USERNAME.*\"(.*)\"/i)
				{
					$username = $1;
				}
				elsif($attr =~ /ADMIN_LEVEL.*\"(.*)\"/i)
				{
					$level = $1;
				}
				elsif($attr =~ /ADMIN_LOGINDATE.*\"(.*)\"/i)
				{
					$logintime = $1;
				}
				elsif($attr =~ /startonlinetime/i)
				{
					$startonlinetime = (split /:/,$attr)[1];
				}
				elsif($attr =~ /ADMIN_IP.*\"(.*)\"/i)
				{
					$sourceip = $1;
				}
			}
		}

		if(defined $username && defined $logintime && defined $startonlinetime && defined $sourceip && defined $level)
		{
			my $sqr_insert = $dbh->prepare("insert into snmp_nm_weblogin (host,datetime,username,logintime,startonlinetime,sourceip,level) values ('$host','$time_now_str','$username','$logintime',FROM_UNIXTIME($startonlinetime),'$sourceip',$level)");
			$sqr_insert->execute();
			$sqr_insert->finish();
		}

=pod
		my $insert_attr = "(host,datetime";
		my $insert_val = "('$host','$time_now_str'";

		if(defined $username)
		{
			$insert_attr .= ",username";
			$insert_val .= ",'$username'";
		}

		if(defined $logintime)
		{
			$insert_attr .= ",logintime";
			$insert_val .= ",'$logintime'";
		}

		if(defined $startonlinetime)
		{
			$insert_attr .= ",startonlinetime";
			$insert_val .= ",FROM_UNIXTIME($startonlinetime)";
		}

		if(defined $sourceip)
		{
			$insert_attr .= ",sourceip";
			$insert_val .= ",'$sourceip'";
		}

		$insert_attr .= ")";
		$insert_val .= ")";

		my $sqr_insert = $dbh->prepare("insert into snmp_nm_weblogin $insert_attr values $insert_val");
		$sqr_insert->execute();
		$sqr_insert->finish();
=cut
		close $file;
	}
}
closedir $dir;
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
