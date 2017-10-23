#!/usr/bin/perl
use warnings;
use strict;
use DBI;
use DBD::mysql;
use Expect;
use File::HomeDir;
use Crypt::CBC;
use MIME::Base64;

our $time_now_utc = time;
my($min,$hour,$mday,$mon,$year) = (localtime $time_now_utc)[1..5];
($min,$hour,$mday,$mon,$year) = (sprintf("%02d", $min),sprintf("%02d", $hour),sprintf("%02d", $mday),sprintf("%02d", $mon + 1),$year+1900);
our $time_now_str = "$year$mon$mday$hour$min"."00";
our $date_today = "$year$mon$mday";

our($mysql_user,$mysql_passwd) = &get_local_mysql_config();
my $dbh=DBI->connect("DBI:mysql:database=audit_sec;host=localhost;mysql_connect_timeout=5",$mysql_user,$mysql_passwd,{RaiseError=>1});
my $utf8 = $dbh->prepare("set names utf8");
$utf8->execute();
$utf8->finish();

my $passwd_option = "";
if(defined $mysql_passwd && $mysql_passwd ne "")
{
    $passwd_option = "-p$mysql_passwd";
}
my $cmd = "mysqldump -h localhost -u $mysql_user $passwd_option audit_sec>/tmp/audit_sec_backup_$time_now_str.sql";

if(system($cmd) != 0)
{
    unlink "/tmp/audit_sec_backup_$time_now_str.sql";
    print "mysqldump for audit_sec error\n";
    exit 1;
}

if(system("zip -qj '/tmp/audit_sec_backup_$time_now_str.sql.zip' '/tmp/audit_sec_backup_$time_now_str.sql'") != 0)
{
    unlink "/tmp/audit_sec_backup_$time_now_str.sql";
    unlink "/tmp/audit_sec_backup_$time_now_str.sql.zip";
    print "zip sql dump error\n";
    exit 1;
}

unlink "/tmp/audit_sec_backup_$time_now_str.sql";

my $sqr_select = $dbh->prepare("select ip,port,path,user,udf_decrypt(passwd) from backup_setting where session_flag=100");
$sqr_select->execute();
while(my $ref = $sqr_select->fetchrow_hashref())
{
    my $ip = $ref->{"ip"};
    my $port = $ref->{"port"};
    my $path = $ref->{"path"};
    my $user = $ref->{"user"};
    my $passwd = $ref->{"udf_decrypt(passwd)"};

    if(&transport($ip,$port,$path,$user,$passwd) != 0)
    {
        print "upload to $ip failed\n";
        exit 1;
    }
}
$sqr_select->finish();

unlink "/tmp/audit_sec_backup_$time_now_str.sql.zip";

sub transport
{
	my($ip,$port,$path,$user,$passwd) = @_;

    $path =~ s/\/$//;

	my $cmd = "lftp -c 'put /tmp/audit_sec_backup_$time_now_str.sql.zip -o ftp://$user:$passwd\@$ip:$port$path/audit_sec_backup_$time_now_str.sql.zip'; echo \"lftp status:\$?\"";
	print $cmd,"\n";
	my $flag = 1;
	foreach my $line(split /\n/,`$cmd`)
	{
		if($line =~ /lftp\s*status:\s*(\d+)/i && $1==0)
		{
			$flag = 0;
		}

		if($line =~ /No\s*such\s*file/i)
		{
			$flag = 2;
			last;
		}
	}
	return $flag;
}

sub log_process
{
    my($host,$err_str) = @_;

    my $cmd;

    if(defined $host)
    {
        $cmd = "insert into backup_passwd_log(datetime,host,reason) values('$time_now_str','$host','$err_str')";
    }
    else
    {
        $cmd = "insert into backup_passwd_log(datetime,reason) values('$time_now_str','$err_str')";
    }

    my $insert = $dbh->prepare("$cmd");
    $insert->execute();
    $insert->finish();
}

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
