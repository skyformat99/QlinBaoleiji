#!/usr/bin/perl
use warnings;
use strict;
use DBI;
use DBD::mysql;
use File::Basename;
use Crypt::CBC;
use MIME::Base64;

# backup_session_log 表中 status 含义
# 0 正确
# 1 rsync连接出错
# 2 指定文件不存在

our $localIp = '172.16.210.253';
our($table_name,$idnum) = @ARGV;

unless($idnum =~ /\d+/)
{
    print "sid in not a num\n";
    exit 1;
}

our $time_now_utc = time;
my($min,$hour,$mday,$mon,$year) = (localtime $time_now_utc)[1..5];
($min,$hour,$mday,$mon,$year) = (sprintf("%02d", $min),sprintf("%02d", $hour),sprintf("%02d", $mday),sprintf("%02d", $mon + 1),$year+1900);
our $time_now_str = "$year$mon$mday$hour$min"."00";

our($mysql_user,$mysql_passwd) = &get_local_mysql_config();
my $dbh=DBI->connect("DBI:mysql:database=audit_sec;host=localhost;mysql_connect_timeout=5",$mysql_user,$mysql_passwd,{RaiseError=>1});
my $utf8 = $dbh->prepare("set names utf8");
$utf8->execute();
$utf8->finish();

my $sqr_select = $dbh->prepare("select ip,port,mysqluser,udf_decrypt(mysqlpasswd) from backup_setting where session_flag=1");
$sqr_select->execute();
while(my $ref = $sqr_select->fetchrow_hashref())
{
	my $ip = $ref->{"ip"};
	my $port = $ref->{"port"};
	my $mysqluser = $ref->{"mysqluser"};
	my $mysqlpasswd = $ref->{"udf_decrypt(mysqlpasswd)"};

	&session_func($ip,$port,$mysqluser,$mysqlpasswd);
}
$sqr_select->finish();
$dbh->disconnect();

sub session_func
{
	my($ip,$port,$mysqluser,$mysqlpasswd) = @_;

	my $dbh=DBI->connect("DBI:mysql:database=audit_sec;host=$ip;mysql_connect_timeout=5","$mysqluser","$mysqlpasswd",{RaiseError=>1});
	my $utf8 = $dbh->prepare("set names utf8");
	$utf8->execute();
	$utf8->finish();

    my $flag;
    if($table_name eq "sessions")
    {
        $flag = &backup_session($dbh,$ip,$port,"sessions","sid","server_addr","logfile","replayfile");
    }
    elsif($table_name eq "rdpsessions")
    {
        $flag = &backup_session($dbh,$ip,$port,"rdpsessions","sid","proxy_addr","replayfile","keydir");
    }
    elsif($table_name eq "ftpcomm")
    {
        $flag = &backup_ftp($dbh,$ip,$port,"ftpcomm","ftpsessions","sid","auditaddr","filename");
    }
    elsif($table_name eq "sftpcomm")
    {
        $flag = &backup_ftp($dbh,$ip,$port,"sftpcomm","sftpsessions","sid","audit_addr","filename");
    }
    else
    {
        print "table name error\n";
        $flag = 1;
    }
	$dbh->disconnect();
    exit $flag;
}

sub backup_ftp
{
	my($dbh,$ip,$port,$table_file,$table_id,$id,$addr,$file) = @_;

    my $return_val = 1;
	my $sqr_select = $dbh->prepare("select $table_file.$id,$file,$addr from $table_file left join $table_id on $table_file.$id=$table_id.$id where $addr is not null and $addr!='$localIp' and $addr!='127.0.0.1' and backupflag=1 and $table_file.$id = $idnum");
	$sqr_select->execute();
	while(my $ref = $sqr_select->fetchrow_hashref())
	{
		my $sid = $ref->{"$id"};
		my $path = $ref->{"$file"};
		my $ip_addr = $ref->{"$addr"};

#		$path =~ s/^"//;
#		$path =~ s/"$//;
		$path =~ s/"//g;

        my $flag;
		unless(defined $path && $path =~ /^\//)
		{
			$flag = 2;
		}
		else
		{
			$flag = &transport($ip,$port,$path);
		}

#		my $sqr_insert = $dbh->prepare("insert into backup_session_log(datetime,ip_addr,table_name,sessionid,status) values('$time_now_str','$ip_addr','$table_file',$sid,$flag)");
#		$sqr_insert->execute();
#		$sqr_insert->finish();

        if($flag == 0)
        {
            $return_val = 0;
        }
        else
        {
            $return_val = 1;
        }

		if($flag == 0)
		{
			$flag = 1;
		}
		elsif($flag == 1)
		{
			$flag = 0;
		}

		my $sqr_update = $dbh->prepare("update $table_file set backup = $flag where $id=$sid");
		$sqr_update->execute();
		$sqr_update->finish();
	}
	$sqr_select->finish();
    return $return_val;
}

sub backup_session
{
	my($dbh,$ip,$port,$table,$id,$addr,$file1,$file2) = @_;

    my $return_val = 1;
	my $sqr_select = $dbh->prepare("select $id,$file1,$file2,$addr from $table where $addr is not null and $addr!='$localIp' and $addr!='127.0.0.1' and $id = $idnum");
	$sqr_select->execute();
	while(my $ref = $sqr_select->fetchrow_hashref())
	{
		my $sid = $ref->{"$id"};
		my $path1 = $ref->{"$file1"};
		my $path2 = $ref->{"$file2"};
		my $ip_addr = $ref->{"$addr"};

#		$path1 =~ s/^"//;
#		$path1 =~ s/"$//;
		$path1 =~ s/"//g;

#		$path2 =~ s/^"//;
#		$path2 =~ s/"$//;
		$path2 =~ s/"//g;

		my $flag1;
		unless(defined $path1 && $path1 =~ /^\//)
		{
			$flag1 = 2;
		}
		else
		{
			$flag1 = &transport($ip,$port,$path1);
		}

		my $flag2;
		unless(defined $path2 && $path2 =~ /^\//)
		{
			$flag2 = 2;
		}
		else
		{
			$flag2 = &transport($ip,$port,$path2);
		}

		my $flag;
		if($flag1 == 0 && $flag2 == 0)
		{
			$flag = 0;
		}
		elsif($flag1 == 2 || $flag2 == 2)
		{
			$flag = 2;
		}
		else
		{
			$flag = 1;
		}

#		my $sqr_insert = $dbh->prepare("insert into backup_session_log(datetime,ip_addr,table_name,sessionid,status) values('$time_now_str','$ip_addr','$table',$sid,$flag)");
#		$sqr_insert->execute();
#		$sqr_insert->finish();

        if($flag == 0)
        {
            $return_val = 0;
        }
        else
        {
            $return_val = 1;
        }

		if($flag == 0)
		{
			$flag = 1;
		}
		elsif($flag == 1)
		{
			$flag = 0;
		}

		my $sqr_update = $dbh->prepare("update $table set backup = $flag where $id=$sid");
		$sqr_update->execute();
		$sqr_update->finish();
	}
	$sqr_select->finish();
    return $return_val;
}

sub transport
{
	my($ip,$port,$path) = @_;

	my $dir = dirname $path;
	unless(-e $dir)
	{
		$dir =~ s/'/'\\''/g;
		`mkdir -p '$dir'`;
	}

	my $dst_file = $path;
	$dst_file =~ s/'/'\\''/g;
	$dst_file =~ s/"/\\"/g;
	$dst_file = "'\"$dst_file\"'";

	my $src_file = $path;
	$src_file =~ s/'/'\\''/g;
	$src_file = "'$src_file'";

	my $flag = 0;
	foreach my $line(split /\n/,`rsync -aq -e 'ssh -p $port' root\@$ip:$dst_file $src_file 2>&1`)
	{
		$flag = 1;
		if($line =~ /No\s*such\s*file\s*or\s*directory/i)
		{
			$flag = 2;
			last;
		}
	}

	return $flag;
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
