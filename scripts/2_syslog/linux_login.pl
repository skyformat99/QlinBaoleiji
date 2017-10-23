#!/usr/bin/perl
use warnings;
use strict;
use DBI;
use DBD::mysql;
use Crypt::CBC;
use MIME::Base64;
use Fcntl;

our $fd_lock;
our $lock_file = "/tmp/.linux_login_lock";
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

open(our $fd_fr,"</var/log/mem/linux.log") or die $!;
open(our $fd_fw,">>./linux_err.log");
#open(our $fd_fr,"<linux.log") or die $!;

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
	unless($log_priority eq "info" || $log_priority eq "notice"){next;}

#处理权限
	if($log_msg =~ /useradd/i)
	{
		if($log_msg =~ /new\s*user.*name=(.*?),/i)
		{
			my $user = $1;
			&authpriv_insert($log_datetime,$log_host,"用户添加",$user,"NULL",$log_msg);
		}
		if($log_msg =~ /new\s*group.*name=(.*?),/i)
		{
			my $group = $1;
			&authpriv_insert($log_datetime,$log_host,"用户组添加","NULL",$group,$log_msg);
		}
	}

	if($log_msg =~ /userdel/i)
	{
		if($log_msg =~ /delete\s*user.*[`'](.*?)[\\'`]/i)
		{
			my $user = $1;
			&authpriv_insert($log_datetime,$log_host,"用户删除",$user,"NULL",$log_msg);
		}
		if($log_msg =~ /removed\s*group.*[`'](.*?)[\\'`]/i)
		{
			my $group = $1;
			&authpriv_insert($log_datetime,$log_host,"用户组删除","NULL",$group,$log_msg);
		}
	}

	if($log_msg =~ /groupadd/i)
	{
		if($log_msg =~ /new\s*group.*name=(.*?),/i)
		{
			my $group = $1;
			&authpriv_insert($log_datetime,$log_host,"用户组添加","NULL",$group,$log_msg);
		}
	}

	if($log_msg =~ /groupdel/i)
	{
		if($log_msg =~ /removed\s*group.*[`'](.*?)[\\'`]/i)
		{
			my $group = $1;
			&authpriv_insert($log_datetime,$log_host,"用户组删除","NULL",$group,$log_msg);
		}
	}

	if($log_msg =~ /passwd\s*:\s*chauthtok/i)
	{
		if($log_msg =~ /password\s*changed\s*for\s*(.*?)$/i)
		{
			my $user = $1;
			&authpriv_insert($log_datetime,$log_host,"用户修改密码",$user,"NULL",$log_msg);
		}
	}

	if($log_msg =~ /usermod/i)
	{
		if($log_msg =~ /\block\b\s*user.*?[`'](.*?)[\\'`]/i)
		{
			my $user = $1;
			&authpriv_insert($log_datetime,$log_host,"用户锁定",$user,"NULL",$log_msg);
		}
		elsif($log_msg =~ /\bunlock\b\s*user.*?[`'](.*?)[\\'`]/i)
		{
			my $user = $1;
			&authpriv_insert($log_datetime,$log_host,"用户解锁",$user,"NULL",$log_msg);
		}
		elsif($log_msg =~ /\bchange\b\s*user.*?[`'](.*?)[\\'`]/i)
		{
			my $user = $1;
			&authpriv_insert($log_datetime,$log_host,"修改用户权限",$user,"NULL",$log_msg);
		}
		elsif($log_msg =~ /add.*?[`'](.*?)[\\'`].*group.*[`'](.*?)[\\'`]/i)
		{
			my $user = $1;
			my $group = $2;
			&authpriv_insert($log_datetime,$log_host,"添加用户到组",$user,$group,$log_msg);
		}
		elsif($log_msg =~ /delete.*?[`'](.*?)[\\'`].*group.*[`'](.*?)[\\'`]/i)
		{
			my $user = $1;
			my $group = $2;
			&authpriv_insert($log_datetime,$log_host,"从组中删除用户",$user,$group,$log_msg);
		}
		elsif($log_msg =~ /user.*?[`'](.*?)[\\'`]/i)
		{
			my $user = $1;
			&authpriv_insert($log_datetime,$log_host,"其它usermod操作",$user,"NULL",$log_msg);
		}
	}

#权限处理结束


	if($log_program eq "su")
	{
		my $su_insert;
		if($log_msg =~ /authentication\s+failure/)
		{
			$su_insert = $dbh->prepare("insert into log_eventlogs (host, facility, priority, level, tag, datetime, program,msg,logserver,msg_level,event) values ('$log_host','$log_facility','$log_priority','$log_level','$log_tag','$log_datetime','$log_program','$log_msg','$log_srever',3,'sudo 错误')");
			$su_insert->execute();
			$su_insert->finish();
			next;
		}
		if($log_msg =~ /pam_unix\(su-l:session\):\s+session\s+opened\s+for\s+user/)
		{
			$su_insert = $dbh->prepare("insert into log_eventlogs (host, facility, priority, level, tag, datetime, program,msg,logserver,msg_level,event) values ('$log_host','$log_facility','$log_priority','$log_level','$log_tag','$log_datetime','$log_program','$log_msg','$log_srever',1,'sudo 成功')");
			$su_insert->execute();
			$su_insert->finish();
			next;
		}

	}

	if(defined $is_cross_login && $is_cross_login == 1 && !exists $right_login_ips{$log_host})
	{
		&cross_insert($log_host,$log_facility,$log_priority,$log_level,$log_tag,$log_datetime,$log_program,$log_msg);
	}

	if($log_program eq "sshd")
	{
		my $pid;
		if($log_msg =~  /sshd\s*\[(.*?)\]/){$pid = $1;}
        unless(defined $pid)
        {
            print $fd_fw "pid not defined in line ",__LINE__,"\n";
            print $fd_fw $log_msg,"\n";
            next;
        }

		if($log_msg =~  /sftp/i)
		{
			&sftp_process($log_host,$log_program,$log_msg,$log_datetime,$pid);
			next;
		}

		if($log_msg =~ /accept/i)
		{
			&accept_process($log_host,$log_program,$log_msg,$log_datetime,$pid);
			next;
		}

		if($log_msg =~ /failed password/i)
		{
			&sshfail_process($log_host,$log_program,$log_msg,$log_datetime,$pid);
			next;
		}

		if($log_msg =~ /\bdisconnect\b/i)
		{
			&sshdisconnect_process($log_host,$log_program,$log_msg,$log_datetime,$pid);
			next;
		}

		if($log_msg =~ /pam_unix/i)
		{
			if($log_msg =~ /opened/i)
			{
				my $uid;
				if($log_msg =~ /.*uid\s*=(\d+)/i)
                {
                    $uid = $1;
                }

                unless(defined $uid)
                {
                    print $fd_fw "uid not defined in line ",__LINE__,"\n";
                    print $fd_fw $log_msg,"\n";
                    next;
                }

                my $sqr_update = $dbh->prepare("update log_linux_login set uid=$uid where uid is NULL and host='$log_host' and pid=$pid and UNIX_TIMESTAMP(starttime)<=UNIX_TIMESTAMP('$log_datetime')");
                $sqr_update->execute();
                $sqr_update->finish();
				next;
			}

			if($log_msg =~ /closed/i)
			{
				my $sqr_update = $dbh->prepare("update log_linux_login set endtime='$log_datetime' where endtime is NULL and host='$log_host' and pid=$pid and uid is not null and UNIX_TIMESTAMP(starttime)<=UNIX_TIMESTAMP('$log_datetime')");
				$sqr_update->execute();
				$sqr_update->finish();
				next;
			}
		}
	}

	if($log_program eq "login")
	{
		if(($log_msg =~ /pam_unix\(login:auth\)/i) && ($log_msg =~ /failure/i))
		{
			&loginfail_process($log_host,$log_program,$log_msg,$log_datetime);
			next;
		}

		if($log_msg =~ /LOGIN ON/i)
		{
			&logon_process($log_host,$log_program,$log_msg,$log_datetime);
			next;
		}

		if(($log_msg =~ /pam_unix\(login:session\)/i) && ($log_msg =~ /closed/i))
		{
			my $user;
			if($log_msg =~ /user\s+(\S+)/i)
            {
                $user = $1;
            }

            unless(defined $user)
            {
                print $fd_fw "user not defined in line ",__LINE__,"\n";
                print $fd_fw $log_msg,"\n";
                next;
            }

            my $sqr_update = $dbh->prepare("update log_linux_login set endtime='$log_datetime' where endtime is NULL and host='$log_host' and user='$user' and UNIX_TIMESTAMP(starttime)<=UNIX_TIMESTAMP('$log_datetime')");
            $sqr_update->execute();
			$sqr_update->finish();
		}
	}
}

my $sqr_exipre = $dbh->prepare("update log_linux_login set endtime = from_unixtime(UNIX_TIMESTAMP(starttime)+$expire_time) where endtime is null and unix_timestamp()-UNIX_TIMESTAMP(starttime)>$expire_time");
$sqr_exipre->execute();
$sqr_exipre->finish();

close($fd_fr);
close($fd_fw);
open($fd_fw,">/var/log/mem/linux.log") or die $!;
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
	my $sqr_insert = $dbh->prepare("insert into log_eventlogs (host, facility, priority, level, tag, datetime, program,msg,logserver,msg_level,event) values ('$host','$facility','$priority','$level','$tag','$datetime','$program','$msg','$log_srever',3,'跨权登录')");
	$sqr_insert->execute();
	$sqr_insert->finish();
}

sub accept_process
{
	my($host,$program,$msg,$datetime,$pid) = @_;
	my $srcip;my $port;my $user;my $protocol;my $mod;
	if($msg =~ /password/i){$mod = "password";}
	if($msg =~ /publickey/i){$mod = "publickey";}
	if($msg =~ /for\s*(.*)\sfrom\s*(\d+\.\d+\.\d+\.\d+).*port\s*(\d+).*\s+(.+)$/i)
	{
		$user = $1;$srcip = $2;$port = $3;$protocol = $4;
	}

    unless(defined $user && defined $srcip && defined $port && defined $protocol && defined $mod)
    {
        print $fd_fw "some var not defined in line ",__LINE__,"\n";
        print $fd_fw $msg,"\n";
        return;
    }

	my $sqr_insert = $dbh->prepare("insert into log_linux_login (starttime,login_mod,pid,host,port,srchost,protocol,active,user,msg,logserver) values ('$datetime','$program-$mod',$pid,'$host',$port,'$srcip','$protocol',1,'$user','$msg','$log_srever')");
	$sqr_insert->execute();
	$sqr_insert->finish();
}

sub sftp_process
{
	my($host,$program,$msg,$datetime,$pid) = @_;
	my $sqr_select = $dbh->prepare("select login_mod,port,srchost,active,user,uid from log_linux_login where host='$host' and pid=$pid");
	$sqr_select->execute();
	my $ref_select = $sqr_select->fetchrow_hashref();
	my $login_mod = $ref_select->{"login_mod"};
	my $port = $ref_select->{"port"};
	my $srchost = $ref_select->{"srchost"};
	my $active = $ref_select->{"active"};
	my $user = $ref_select->{"user"};
	my $uid = $ref_select->{"uid"};

	$sqr_select->finish();
	unless(defined $srchost && defined $port && defined $user && defined $uid){return;}

	my $sqr_insert = $dbh->prepare("insert into log_linux_login (starttime,login_mod,pid,host,port,srchost,protocol,active,user,msg,logserver,uid) values ('$datetime','$login_mod',$pid,'$host',$port,'$srchost','sftp',1,'$user','$msg','$log_srever',$uid)");
	$sqr_insert->execute();
	$sqr_insert->finish();
}

sub sshfail_process
{
	my($host,$program,$msg,$datetime,$pid) = @_;
	my $srcip;my $port;my $user;my $protocol;my $mod="password";

	if($msg =~ /for\s*(.*)\sfrom\s*(\d+\.\d+\.\d+\.\d+).*port\s*(\d+).*\s+(.+)$/i)
	{
		$user = $1;$srcip = $2;$port = $3;$protocol = $4;
	}

    unless(defined $user && defined $srcip && defined $port && defined $protocol)
    {
        print $fd_fw "some var not defined in line ",__LINE__,"\n";
        print $fd_fw $msg,"\n";
        return;
    }

	my $sqr_insert = $dbh->prepare("insert into log_linux_login (starttime,endtime,login_mod,pid,host,port,srchost,protocol,active,user,msg,logserver) values ('$datetime','$datetime','$program-$mod',$pid,'$host',$port,'$srcip','$protocol',0,'$user','$msg','$log_srever')");
	$sqr_insert->execute();
	$sqr_insert->finish();
}

sub sshdisconnect_process
{
	my($host,$program,$msg,$datetime,$pid) = @_;
	my $srcip;my $port;my $protocol="ssh2";my $mod="password";

	if($msg =~ /from\s*(.*):\s*(\d+)/i)
	{
		$srcip = $1;$port = $2;
	}

    unless(defined $srcip && defined $port)
    {
        print $fd_fw "some var not defined in line ",__LINE__,"\n";
        print $fd_fw $msg,"\n";
        return;
    }

	my $sqr_insert = $dbh->prepare("insert into log_linux_login (starttime,endtime,login_mod,pid,host,port,srchost,protocol,active,msg,logserver) values ('$datetime','$datetime','$program-$mod',$pid,'$host',$port,'$srcip','$protocol',-1,'$msg ','$log_srever')");
	$sqr_insert->execute();
	$sqr_insert->finish();
}

sub loginfail_process
{
	my($host,$program,$msg,$datetime) = @_;
	my $uid;my $user;my $protocol;

	if($msg =~ /uid=(\d+)/i){$uid = $1;}
	if($msg =~ /tty=(\S+)/i){$protocol = $1;}
	if($msg =~ /user=(\S+)/i){$user = $1;}

    unless(defined $uid && defined $protocol)
    {
        print $fd_fw "some var not defined in line ",__LINE__,"\n";
        print $fd_fw $msg,"\n";
        return;
    }

	my $sqr_insert;
	if(defined $user)
    {
        $sqr_insert = $dbh->prepare("insert into log_linux_login (starttime,endtime,login_mod,host,protocol,active,msg,logserver,uid,user) values ('$datetime','$datetime','$program','$host','$protocol',0,'$msg','$log_srever',$uid,'$user')");
    }
	else
    {
        $sqr_insert = $dbh->prepare("insert into log_linux_login (starttime,endtime,login_mod,host,protocol,active,msg,logserver,uid) values ('$datetime','$datetime','$program','$host','$protocol',0,'$msg','$log_srever',$uid)");
    }

	$sqr_insert->execute();
	$sqr_insert->finish();
}

sub logon_process
{
	my($host,$program,$msg,$datetime) = @_;
	my $user;my $protocol;

	if($msg =~ /.*\:\s*(\S+).*\s+(.*)$/i)
	{
		$user = lc($1);
		$protocol = $2;
	}

    unless(defined $user && defined $protocol)
    {
        print $fd_fw "some var not defined in line ",__LINE__,"\n";
        print $fd_fw $msg,"\n";
        return;
    }

	my $sqr_update = $dbh->prepare("update log_linux_login set endtime='$datetime' where endtime is NULL and host='$host' and user='$user' and login_mod = 'login' and UNIX_TIMESTAMP(starttime)<=UNIX_TIMESTAMP('$datetime')");
	$sqr_update->execute();
	$sqr_update->finish();

	my $sqr_insert = $dbh->prepare("insert into log_linux_login (starttime,login_mod,host,protocol,active,msg,logserver,user) values ('$datetime','$program','$host','$protocol',1,'$msg','$log_srever','$user')");
	$sqr_insert->execute();
	$sqr_insert->finish();
}

sub authpriv_insert
{
	my($datetime,$ip,$event,$username,$group,$loginfo) = @_;
	my $str_authpriv;

	if($username eq "NULL" && $group eq "NULL"){return;}

	if($username eq "NULL")
	{
		$str_authpriv = "insert into log_linux_authpriv (datetime,ip,event,groupname,loginfo) values ('$datetime','$ip','$event','$group','$loginfo')";
	}
	elsif($group eq "NULL")
	{
		$str_authpriv = "insert into log_linux_authpriv (datetime,ip,event,username,loginfo) values ('$datetime','$ip','$event','$username','$loginfo')";
	}
	else
	{
		$str_authpriv = "insert into log_linux_authpriv (datetime,ip,event,username,groupname,loginfo) values ('$datetime','$ip','$event','$username','$group','$loginfo')";
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
