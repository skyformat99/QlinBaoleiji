#!/usr/bin/perl
use warnings;
use strict;
use DBI;
use DBD::mysql;
use Fcntl;
use File::Basename;
use Crypt::CBC;
use MIME::Base64;

#lftp -c 'mirror -n  sftp://root:freesvr123@172.16.210.249:2288/opt/freesvr/audit/gateway/log/ssh/replay/2013-10-27 /tmp/xlwu/tmp/as/gd/2013-10-27'

# backup_session_log 表中 status 含义
# 0 正确
# 1 rsync连接出错
# 2 指定文件不存在

our $sessions_intrerval = 30;
our $backup_ip = "";

our $time_now_utc = time;
my($min,$hour,$mday,$mon,$year) = (localtime $time_now_utc)[1..5];
($min,$hour,$mday,$mon,$year) = (sprintf("%02d", $min),sprintf("%02d", $hour),sprintf("%02d", $mday),sprintf("%02d", $mon + 1),$year+1900);
our $time_now_str = "$year$mon$mday$hour$min"."00";

our $fd_lock;
our $lock_file = "/tmp/.backup_session_lock";
sysopen($fd_lock, $lock_file, O_RDWR|O_CREAT|O_EXCL) or die "another instance running";

our($mysql_user,$mysql_passwd) = &get_local_mysql_config();
my $dbh=DBI->connect("DBI:mysql:database=audit_sec;host=localhost;mysql_connect_timeout=5",$mysql_user,$mysql_passwd,{RaiseError=>1});
my $utf8 = $dbh->prepare("set names utf8");
$utf8->execute();
$utf8->finish();

&get_backup_ip();

print "backup files in sessions\n";
&backup_session($dbh,"sessions","sid","server_addr","logfile","replayfile", "timestampdiff(SECOND, end, now())>$sessions_intrerval");

print "backup files in rdpsessions\n";
&backup_session($dbh,"rdpsessions","sid","proxy_addr","replayfile","keydir", "rdp_runnig=0");

print "backup files in ftpsessions\n";
&backup_ftp($dbh,"ftpcomm","ftpsessions","sid","auditaddr","filename");

print "backup files in sftpsessions\n";
&backup_ftp($dbh,"sftpcomm","sftpsessions","sid","audit_addr","filename");

$dbh->disconnect();

close $fd_lock;
unlink $lock_file;

sub get_backup_ip
{
    my $sqr_select = $dbh->prepare("show slave status");
    $sqr_select->execute();
    my $ref = $sqr_select->fetchrow_hashref();
    $backup_ip = $ref->{"Master_Host"};
	$sqr_select->finish();
}

sub backup_ftp
{
    my($dbh,$table_file,$table_id,$id,$addr,$file) = @_;

    print "sql: select $table_file.$id,$file,$addr from $table_file left join $table_id on $table_file.$id=$table_id.$id where $addr='$backup_ip' and backup=0\n";
    my $sqr_select = $dbh->prepare("select $table_file.$id,$file,$addr from $table_file left join $table_id on $table_file.$id=$table_id.$id where $addr='$backup_ip' and backup=0");
    $sqr_select->execute();
    while(my $ref = $sqr_select->fetchrow_hashref())
	{
		my $sid = $ref->{$id};
		my $path = $ref->{$file};
		my $ip_addr = $ref->{$addr};

        if(defined $path)
        {
            $path =~ s/"//g;
        }

		my $flag;
		unless(defined $path && $path =~ /^\//)
		{
			$flag = 2;
		}
		else
		{
            print "get $file, path: $path\n";
			$flag = &transport($ip_addr,$path);
		}

		my $sqr_insert = $dbh->prepare("insert into backup_session_log(datetime,ip_addr,table_name,sessionid,status) values('$time_now_str','$ip_addr','$table_file',$sid,$flag)");
		$sqr_insert->execute();
		$sqr_insert->finish();

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
}

sub backup_session
{
	my($dbh,$table,$id,$addr,$file1,$file2, $extra) = @_;

    my $sql = "select $id,$file1,$file2,$addr from $table where $addr='$backup_ip' and backup=0";
    if(length($extra) != 0)
    {
        $sql .= " and $extra";
    }
    print "sql: $sql\n";
	my $sqr_select = $dbh->prepare($sql);
	$sqr_select->execute();
	while(my $ref = $sqr_select->fetchrow_hashref())
	{
		my $sid = $ref->{$id};
		my $path1 = $ref->{$file1};
		my $path2 = $ref->{$file2};
		my $ip_addr = $ref->{$addr};

        if(defined $path1)
        {
            $path1 =~ s/"//g;
        }

        if(defined $path2)
        {
            $path2 =~ s/"//g;
        }

		my $flag1;
		unless(defined $path1 && $path1 =~ /^\//)
		{
			$flag1 = 2;
		}
		else
		{
            print "get $file1, path: $path1\n";
			$flag1 = &transport($ip_addr,$path1);
		}

		my $flag2;
		unless(defined $path2 && $path2 =~ /^\//)
		{
			$flag2 = 2;
		}
		else
		{
            print "get $file2, path: $path2\n";
			$flag2 = &transport($ip_addr,$path2);
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

		my $sqr_insert = $dbh->prepare("insert into backup_session_log(datetime,ip_addr,table_name,sessionid,status) values('$time_now_str','$ip_addr','$table',$sid,$flag)");
		$sqr_insert->execute();
		$sqr_insert->finish();

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
}

sub transport
{
	my($ip,$file) = @_;

	my $dir = dirname $file;
    unless(-e $dir)
    {
        `mkdir -p $dir`;
    }
	my $cmd = "lftp -c 'get sftp://root\@$ip:2288$file -o $dir'; echo \"lftp status:\$?\"";
	print "cmd: $cmd\n";
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
