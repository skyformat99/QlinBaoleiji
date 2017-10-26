#!/usr/bin/perl
use warnings;
use strict;
use DBI;
use DBD::mysql;
use Crypt::CBC;
use MIME::Base64;
use Fcntl;

our $fd_lock;
our $lock_file = "/tmp/.windows_login_lock";
sysopen($fd_lock, $lock_file, O_RDWR|O_CREAT|O_EXCL) or die "another instance running";

our $log_srever = '1.1.1.1';
our $expire_time = 3600;
our $is_cross_login;
our %right_login_ips;

&read_log_conf();

our($mysql_user,$mysql_passwd) = &get_local_mysql_config();
our $dbh=DBI->connect("DBI:mysql:database=audit_sec;host=localhost;mysql_connect_timeout=5",$mysql_user,$mysql_passwd,{RaiseError=>1});
our $utf8 = $dbh->prepare("set names utf8");
$utf8->execute();
$utf8->finish();

open(our $fd_fr,"</var/log/mem/windows.log") or die $!;
open(our $fd_fw,">>./windows_err.log");

while(my $log = <$fd_fr>)
{
	chomp $log;
	if($log =~ /^\s*$/){next;}

	my @unit_temp = split  /\|\|/,$log;
	my($log_host,$log_facility,$log_priority,$log_level,$log_tag,$log_datetime,$log_program,$log_msg);
	if(scalar @unit_temp == 8)
	{
		($log_host,$log_facility,$log_priority,$log_level,$log_tag,$log_datetime,$log_program,$log_msg) = @unit_temp;
	}
	else
	{
		($log_host,$log_facility,$log_priority,$log_level,$log_tag,$log_datetime,$log_program,$log_msg) = @unit_temp[0..6];
		$log_msg = join("||",@unit_temp[7..((scalar @unit_temp)-1)]);
	}

	unless(defined $log_program || defined $log_msg){next;}

#开始权限分析

	if($log_msg =~ /创建.*用户帐户/i)
	{   
		if($log_msg =~ /新的帐户名:\s*(\S*)/i)			#2003
		{   
			my $user = $1;
			&authpriv_insert($log_datetime,$log_host,"用户添加",$user,"NULL",$log_msg);
		}
		if($log_msg =~ /.*新帐户.*帐户名:\s*(\S*)/i)	#2008
		{   
			my $user = $1;
			&authpriv_insert($log_datetime,$log_host,"用户添加",$user,"NULL",$log_msg);
		}
	}
	elsif($log_msg =~ /删除.*用户帐户/i)
	{   
		if($log_msg =~ /帐户名称:\s*(\S*)/i)			#2003
		{   
			my $user = $1;
			&authpriv_insert($log_datetime,$log_host,"用户删除",$user,"NULL",$log_msg);
		}
		if($log_msg =~ /.*目标帐户.*帐户名:\s*(\S*)/i)	#2008
		{   
			my $user = $1;
			&authpriv_insert($log_datetime,$log_host,"用户删除",$user,"NULL",$log_msg);
		}
	}
	elsif($log_msg =~ /添加.*成员/i)
	{   
		if($log_msg =~ /成员名称:\s*(\S*).*目标帐户名称:\s*(\S*)/i)			#2003
		{   
			my $user = ($1 eq "-") ? "NULL" : $1;
			my $group = $2;
			&authpriv_insert($log_datetime,$log_host,"添加用户到组",$user,$group,$log_msg);
		}
		if($log_msg =~ /.*成员.*帐户名:\s*(\S*).*组名:\s*(\S*)/i)	#2008
		{   
			my $user = ($1 eq "-") ? "NULL" : $1;
			my $group = $2;
			&authpriv_insert($log_datetime,$log_host,"添加用户到组",$user,$group,$log_msg);
		}
	}
	elsif($log_msg =~ /删除.*本地组:\s*成员名称:/i)							#2003从组中删除用户
	{
		if($log_msg =~ /成员名称:\s*(\S*).*目标帐户名称:\s*(\S*)/i)
		{   
			my $user = ($1 eq "-") ? "NULL" : $1;
			my $group = $2;
			&authpriv_insert($log_datetime,$log_host,"从组中删除用户",$user,$group,$log_msg);
		}
	}
	elsif($log_msg =~ /删除.*成员/i)											#2008从组中删除用户
	{   
		if($log_msg =~ /.*成员.*帐户名:\s*(\S*).*组名:\s*(\S*)/i)	
		{   
			my $user = ($1 eq "-") ? "NULL" : $1;
			my $group = $2;
			&authpriv_insert($log_datetime,$log_host,"从组中删除用户",$user,$group,$log_msg);
		}
	}
	elsif($log_msg =~ /创建.*本地组/i)
	{   
		if($log_msg =~ /新帐户名称:\s*(\S*)/i)						#2003
		{   
			my $group = $1;
			&authpriv_insert($log_datetime,$log_host,"用户组添加","NULL",$group,$log_msg);
		}
		if($log_msg =~ /.*新组.*组名:\s*(\S*)/i)					#2008
		{   
			my $group = $1;
			&authpriv_insert($log_datetime,$log_host,"用户组添加","NULL",$group,$log_msg);
		}
	}
	elsif($log_msg =~ /删除.*本地组/i)
	{   
		if($log_msg =~ /目标帐户名称:\s*(\S*)/i)						#2003
		{   
			my $group = $1;
			&authpriv_insert($log_datetime,$log_host,"用户组删除","NULL",$group,$log_msg);
		}
		if($log_msg =~ /.*组.*组名:\s*(\S*)/i)					#2008
		{   
			my $group = $1;
			&authpriv_insert($log_datetime,$log_host,"用户组删除","NULL",$group,$log_msg);
		}
	}
	elsif($log_msg =~ /设置.*帐户密码/i)				#2003设置密码
	{   
		if($log_msg =~ /目标帐户名:\s*(\S*)/i)
		{   
			my $user = $1;
			&authpriv_insert($log_datetime,$log_host,"用户修改密码",$user,"NULL",$log_msg);
		}
	}
	elsif($log_msg =~ /重置.*帐户密码/i)                #2008设置密码
	{
		if($log_msg =~ /.*目标帐户.*帐户名:\s*(\S*)/i)	#2008
		{   
			my $user = $1;
			&authpriv_insert($log_datetime,$log_host,"用户修改密码",$user,"NULL",$log_msg);
		}
	}

#权限分析结束

	if(defined $is_cross_login && $is_cross_login == 1 && !exists $right_login_ips{$log_host})
	{           
		&cross_insert($log_host,$log_facility,$log_priority,$log_level,$log_tag,$log_datetime,$log_program,$log_msg);
	}

	if($log_msg =~ /登录失败/i)
	{
		&loginfail_process($log_host,$log_msg,$log_datetime);
		next;
	}

	if($log_msg =~ /登录成功/i)
	{
		&loginsuccess_process($log_host,$log_msg,$log_datetime);
		next;
	}

	if($log_msg =~ /用户注销/i)
	{
		&logincancel_process($log_host,$log_msg,$log_datetime);
		next;
	}
}

my $sqr_exipre = $dbh->prepare("update log_windows_login set endtime = from_unixtime(UNIX_TIMESTAMP(starttime)+$expire_time) where endtime is null and unix_timestamp()-UNIX_TIMESTAMP(starttime)>$expire_time");
$sqr_exipre->execute();
$sqr_exipre->finish();

close($fd_fr);
close($fd_fw);
open($fd_fw,">/var/log/mem/windows.log") or die $!;
close($fd_fw);
close $fd_lock;
unlink $lock_file;

sub read_log_conf
{
    open(my $fd_config,"</home/wuxiaolong/2_syslog/log.conf") or die $!;
    while(my $line = <$fd_config>)
    {
        chomp $line;
        my($name,$value) = split /=/,$line;

        unless(defined $name && defined $value){next;}
        $name =~ s/\s+//g;
        $value =~ s/\s+//g;

        if($name eq "cross_login")
        {
            $is_cross_login = $value;
        }
        if($name eq "login_ip")
        {
            my @tmp_right_login_ips = split /;/,$value;
            foreach(@tmp_right_login_ips)
            {
                $_ =~ s/\s+//g;
                $right_login_ips{$_} = 1;
            }
        }
    }
}

sub cross_insert
{
    my($host,$facility,$priority,$level,$tag,$datetime,$program,$msg) = @_;
    my $sqr_insert = $dbh->prepare("insert into log_eventlogs (host, facility, priority, level, tag, datetime, program,msg,logserver,msg_level,event) values ('$host','$facility','$priority','$level','$tag','$datetime','$program','$msg','$log_srever',3,'>
跨权登录')");
    $sqr_insert->execute();
    $sqr_insert->finish();
}

sub loginfail_process
{
	my($host,$msg,$datetime) = @_;
	my $srcip;
    my $port;
    my $user="UNKNOWN";
    my $protocol;
	my $sqr_insert;

	if($msg =~ /源网络地址:\s*(\S+)/i)
	{
		if($1 eq "-")
		{
			if($msg =~ /用户名:\s*(\S+)/i)
            {
                $user = $1;
            }

            if($msg =~ /登录进程:\s*(\S+)/)
            {
                $protocol = $2;
            }

            unless(defined $protocol)
            {
                print $fd_fw "protocol not defined in line ",__LINE__,"\n";
                print $fd_fw $msg,"\n";
                return;
            }

            if($user =~ /域/i)
            {
                $sqr_insert = $dbh->prepare("insert into log_windows_login (starttime,endtime,host,protocol,active,msg,logserver) values ('$datetime','$datetime','$host','$protocol',0,'$msg','$log_srever')");
			}
			else
			{
				$sqr_insert = $dbh->prepare("insert into log_windows_login (starttime,endtime,host,protocol,active,user,msg,logserver) values ('$datetime','$datetime','$host','$protocol',0,'$user','$msg','$log_srever')");
			}
		}
		else
		{
			$srcip = $1;
			if($msg =~ /用户名:\s*(\S+)/i)
            {
                $user = $1;
            } 
			if($msg =~ /源端口:\s*(\d+)/i)
            {
                $port = $2;
            }

            unless(defined $port)
            {
                print $fd_fw "port not defined in line ",__LINE__,"\n";
                print $fd_fw $msg,"\n";
                return;
            }

			if($srcip eq "127.0.0.1"){$protocol = "local";}
			else{$protocol = "RDP";}

			if($user =~ /域/i)
			{
				$sqr_insert = $dbh->prepare("insert into log_windows_login (starttime,endtime,host,protocol,active,msg,logserver)values ('$datetime','$datetime','$host','$protocol',0,'$msg','$log_srever')");
			}
			else
			{
				$sqr_insert = $dbh->prepare("insert into log_windows_login (starttime,endtime,host,port,srchost,protocol,active,user,msg,logserver) values ('$datetime','$datetime','$host',$port,'$srcip','$protocol',0,'$user','$msg','$log_srever')");
			}
		}
		$sqr_insert->execute();
		$sqr_insert->finish();
	}
}

sub loginsuccess_process
{
	my($host,$msg,$datetime) = @_;
	my $srcip;my $port;my $user;my $protocol;my $login_id;

	if($msg =~ /用户名:\s*(\S+).*\s+登录\s*ID:\s+\((\S+)\).*源网络地址:\s*(\S+)\s+源端口:\s*(\S+)/i)
	{
		$user = $1;$login_id = $2;$srcip = $3;$port = $4;
	}

    unless(defined $user && defined $login_id && defined $srcip && defined $port)
    {
        print $fd_fw "some var not defined in line ",__LINE__,"\n";
        print $fd_fw $msg,"\n";
        return;
    }

	if($srcip eq "127.0.0.1"){$protocol = "local";}
	else{$protocol = "RDP";}

	my $sqr_insert;

	if($srcip eq '-' && $port eq '-')
	{
		$sqr_insert = $dbh->prepare("insert into log_windows_login (starttime,login_id,host,protocol,active,user,msg,logserver) values ('$datetime','$login_id','$host','$protocol',1,'$user','$msg','$log_srever')");
	}
	elsif($srcip eq '-')
	{
		$sqr_insert = $dbh->prepare("insert into log_windows_login (starttime,login_id,host,port,protocol,active,user,msg,logserver) values ('$datetime','$login_id','$host',$port,'$protocol',1,'$user','$msg','$log_srever')");
	}
	elsif($port eq '-')
	{
		$sqr_insert = $dbh->prepare("insert into log_windows_login (starttime,login_id,host,srchost,protocol,active,user,msg,logserver) values ('$datetime','$login_id','$host','$srcip','$protocol',1,'$user','$msg','$log_srever')");
	}
	else
	{
		$sqr_insert = $dbh->prepare("insert into log_windows_login (starttime,login_id,host,port,srchost,protocol,active,user,msg,logserver) values ('$datetime','$login_id','$host',$port,'$srcip','$protocol',1,'$user','$msg','$log_srever')");
	}

	$sqr_insert->execute();
	$sqr_insert->finish();
}

sub logincancel_process
{
	my($host,$msg,$datetime) = @_;
	my $user;my $login_id;

	if($msg =~ /用户名:\s*(\S+).*\s+登录\s*ID:\s+\((\S+)\)/i)
	{
		$user = $1;$login_id = $2;
	}

    unless(defined $user && defined $login_id)
    {
        print $fd_fw "some var not defined in line ",__LINE__,"\n";
        print $fd_fw $msg,"\n";
        return;
    }

	my $sqr_update = $dbh->prepare("update log_windows_login set endtime='$datetime' where endtime is NULL and login_id='$login_id' and user='$user' and host='$host' and UNIX_TIMESTAMP(starttime)<=UNIX_TIMESTAMP('$datetime')");
	$sqr_update->execute();
	$sqr_update->finish();
}

sub authpriv_insert
{
	my($datetime,$ip,$event,$username,$group,$loginfo) = @_;
	my $str_authpriv;

	if($username eq "NULL" && $group eq "NULL"){return;}

	if($username eq "NULL")
	{
		$str_authpriv = "insert into log_windows_authpriv (datetime,ip,event,groupname,loginfo) values ('$datetime','$ip','$event','$group','$loginfo')";
	}
	elsif($group eq "NULL")
	{
		$str_authpriv = "insert into log_windows_authpriv (datetime,ip,event,username,loginfo) values ('$datetime','$ip','$event','$username','$loginfo')";
	}
	else
	{
		$str_authpriv = "insert into log_windows_authpriv (datetime,ip,event,username,groupname,loginfo) values ('$datetime','$ip','$event','$username','$group','$loginfo')";
	}

	my $insert = $dbh->prepare("$str_authpriv");
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
