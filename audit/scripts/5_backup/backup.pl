#!/usr/bin/perl
use warnings;
use strict;
use DBI;
use DBD::mysql;
use Expect;
use Fcntl;
use POSIX ":sys_wait_h"; 
use Crypt::CBC;
use MIME::Base64;

our $fd_lock;
our $lock_file = "/tmp/.backup_lock";
sysopen($fd_lock, $lock_file, O_RDWR|O_CREAT|O_EXCL) or die "another instance running";

#lftp -c 'mirror -Rn --exclude=wxl_tmp/ --exclude=2015-02-01/ /opt/freesvr/audit/gateway/log/rdp/replay/ sftp://root:freesvr!@#@172.16.210.99:2288/opt/opt/freesvr/audit/gateway/log/rdp/replay/'; echo "lftp status:$?"
#lftp -c 'mirror -RLpn --exclude=wxl_tmp/ --exclude=2015-02-01/ /opt/freesvr/audit/gateway/log/rdp/replay/ ftp://administrator:freesvr123@172.16.210.30:21/opt/freesvr/audit/gateway/log/rdp/replay/'; echo "lftp status:$?"

our $debug = 1;
$SIG{ALRM}=\&alarm_process;
our($mysql_user,$mysql_passwd) = &get_local_mysql_config();
our $process_time = 7200;
our $cur_host;
our @backup_ip;
our $time_now_utc = time;
our($min,$hour,$mday,$mon,$year) = (localtime $time_now_utc)[1..5];
($min,$hour,$mday,$mon,$year) = (sprintf("%02d", $min),sprintf("%02d", $hour),sprintf("%02d", $mday),sprintf("%02d", $mon + 1),$year+1900);
our $time_now_str = "$year$mon$mday$hour$min"."00";

if(-e "/tmp/audit_sec_backup.sql")
{
    unlink "/tmp/audit_sec_backup.sql";
}

&read_mysql();
foreach my $ref(@backup_ip)
{
    $cur_host = $ref->[0];
    alarm($process_time);
    &backup(@$ref);
    alarm(0);
}
close $fd_lock;
unlink $lock_file;
exit 0;

sub read_mysql
{
    my $dbh=DBI->connect("DBI:mysql:database=audit_sec;host=localhost;mysql_connect_timeout=5",$mysql_user,$mysql_passwd,{RaiseError=>1});
    my $utf8 = $dbh->prepare("set names utf8");
    $utf8->execute();
    $utf8->finish();

    my $sqr_select = $dbh->prepare("select ip,port,dbactive,fileactive,user,udf_decrypt(passwd),mysqluser,udf_decrypt(mysqlpasswd),path,dbname,protocol from backup_setting where (dbactive=1 or fileactive=1) and session_flag=0");
    $sqr_select->execute(); 
    while(my $ref = $sqr_select->fetchrow_hashref())
    {                   
        my $ip = $ref->{"ip"};
        my $port = $ref->{"port"};
        my $dbactive = $ref->{"dbactive"};
        my $fileactive = $ref->{"fileactive"};
        my $user = $ref->{"user"};
        my $passwd = $ref->{"udf_decrypt(passwd)"};
        my $mysqluser = $ref->{"mysqluser"};
        my $mysqlpasswd = $ref->{"udf_decrypt(mysqlpasswd)"};
        my $path_prefix = $ref->{"path"};
        my $dbname = $ref->{"dbname"};
        my $protocol = $ref->{"protocol"};

        $path_prefix =~ s/\/$//;				#去掉 path 前缀最后的 /
            my @temp = ($ip,$port,$dbactive,$fileactive,$user,$passwd,$mysqluser,$mysqlpasswd,$path_prefix,$dbname,$protocol);
        push @backup_ip,\@temp;
    }           
    $sqr_select->finish();
    $dbh->disconnect();
}

sub create_tmp_dir
{
    my($work_dir) = @_;
    my $today_dir;
    mkdir "$work_dir/wxl_tmp",0755;
    opendir(my $dir_handle,$work_dir);
    while(my $file = readdir($dir_handle))
    {
        if($file eq "." || $file eq ".." || $file eq "wxl_tmp")
        {
            next;
        }

        unless(-d "$work_dir/$file")
        {
            rename "$work_dir/$file", "$work_dir/wxl_tmp/$file";
        }

        if($file =~ /(\d+)-(\d+)-(\d+)/ || $file =~ /(\d+)_(\d+)_(\d+)/)
        {
            if((int($1) == $year) && (int($2) == $mon) && (int($3) == $mday))
            {
                $today_dir = $file;
                next;
            }
        }
        else
        {
            rename "$work_dir/$file", "$work_dir/wxl_tmp/$file";
        }
    }
    close $dir_handle;
    return $today_dir;
}

sub upload
{
    my($ip,$port,$user,$passwd,$work_dir,$path_prefix,$protocol,$today_dir) = @_;
    $path_prefix =~ s/\/$//;

    my $status=2;
    my $mkdir_cmd;
    my $user_passwd = $user;
    my $login_str;
    my $mirror_opt;
    my $exclude_opt = "--exclude=wxl_tmp/";

    if(defined $passwd && $passwd ne "")
    {
        $user_passwd .= ":$passwd";
    }

    if(defined $today_dir)
    {
        $exclude_opt .= " --exclude=$today_dir/";
    }

    if($protocol eq "ftp")
    {
        unless($port =~ /\d+/)
        {
            $port = 21;
        }
        $login_str = "ftp://$user_passwd\@$ip:$port";
        $mirror_opt = "-RLpn";
    }
    else
    {
        unless($port =~ /\d+/)
        {
            $port = 22;
        }
        $login_str = "sftp://$user_passwd\@$ip:$port";
        $mirror_opt = "-Rn";
    }

    $mkdir_cmd = "lftp -c 'mkdir -pf $login_str$path_prefix$work_dir'";
    print "create remote dir $login_str$path_prefix$work_dir, cmd: $mkdir_cmd\n";
    system("$mkdir_cmd 1>/dev/null 2>&1");
    sleep(1);

    my $upload_cmd = "lftp -c 'mirror $mirror_opt $exclude_opt $work_dir/ $login_str$path_prefix$work_dir/'; echo \"lftp status:\$?\"";
    print "upload dir $work_dir, cmd: $upload_cmd\n";
    foreach my $line(split /\n/, `$upload_cmd`)
    {
        if($line =~ /lftp\s*status:\s*(\d+)/i && $1==0)
        {
            print "upload success: $work_dir\n";
            $status = 1;
        }
    }
    sleep(1);
    return $status;
}

sub del_tmp_dir
{
    my($work_dir) = @_;
    opendir(my $dir_handle,"$work_dir/wxl_tmp");
    while(my $file = readdir($dir_handle))
    {   
        if($file eq "." || $file eq "..")
        {   
            next;
        }

        rename "$work_dir/wxl_tmp/$file", "$work_dir/$file";
    }
    close $dir_handle;
    rmdir "$work_dir/wxl_tmp";
}

sub backup
{
    my($ip,$port,$dbactive,$fileactive,$user,$passwd,$mysqluser,$mysqlpasswd,$path_prefix,$dbname,$protocol) = @_;
    my $file_status = 0;
    my $db_status = 0;
    my $last_date;

    my $dbh=DBI->connect("DBI:mysql:database=audit_sec;host=localhost;mysql_connect_timeout=5",$mysql_user,$mysql_passwd,{RaiseError=>1});
    my $utf8 = $dbh->prepare("set names utf8");
    $utf8->execute();
    $utf8->finish();

    my $sqr_insert = $dbh->prepare("insert into backup_log(ip,starttime) values('$ip',now())");
    $sqr_insert->execute();
    $sqr_insert->finish();

    if($fileactive != 0)
    {
        my $file_status = 1;

        my @work_dirs = qw#/opt/freesvr/audit/gateway/log/db2
            /opt/freesvr/audit/gateway/log/mysql
            /opt/freesvr/audit/gateway/log/oracle
            /opt/freesvr/audit/gateway/log/sybase
            /opt/freesvr/audit/gateway/log/sqlserver
            /opt/freesvr/audit/gateway/log/telnet/cache
            /opt/freesvr/audit/gateway/log/telnet/replay
            /opt/freesvr/audit/gateway/log/ssh/cache
            /opt/freesvr/audit/gateway/log/ssh/replay
            /opt/freesvr/audit/gateway/log/rdp/replay
            /opt/freesvr/audit/gateway/log/rdp/key#;

        foreach my $work_dir(@work_dirs)
        {
            unless(-d $work_dir)
            {
                next;
            }

            my $today_dir = &create_tmp_dir($work_dir);

            my $tmp_status = &upload($ip,$port,$user,$passwd,$work_dir,$path_prefix,$protocol,$today_dir);
            if($tmp_status != 1)
            {
                $file_status = 2;
            }

            &del_tmp_dir($work_dir);
            print "\n";
        }

        my $sqr_update = $dbh->prepare("update backup_log set filelog=$file_status where ip='$ip' and endtime is null");
        $sqr_update->execute();
        $sqr_update->finish();
    }
    else
    {
        my $sqr_update = $dbh->prepare("update backup_log set filelog=0 where ip='$ip' and endtime is null");
        $sqr_update->execute();
        $sqr_update->finish();
    }

    if($dbactive == 1 || $dbactive == 2)
	{
		my $cmd;
		if($dbactive == 1)
		{
			$cmd = "mysqldump -h localhost -u root audit_sec>/tmp/audit_sec_backup.sql";
		}
		else
		{
			my @tables = qw/
				ac_group                  
				ac_network                
				admin_log                 
				alarm                     
				alert_mailsms             
				appdevices                
				appgroup                  
				appmember                 
				appprogram                
				apppserver                
				apppub                    
				appresourcegroup          
				appurl                    
				dangerscmds               
				defaultpolicy             
				dev                       
				device                    
				device_html               
				device_oid                
				devices                   
				devices_password          
				forbidden_commands        
				forbidden_commands_groups 
				forbidden_commands_user   
				forbidden_groups  
				http_process              
				http_process_alarm        
				ip                        
				ldap                      
				ldapdevice                
				ldapmanager               
				ldapuser                  
				lgroup                    
				lgroup_appresourcegrp     
				lgroup_devgrp             
				lgroup_resourcegrp        
				login_tab                 
				login_template            
				loginacctcode             
				luser                     
				luser_appresourcegrp      
				luser_devgrp              
				luser_resourcegrp         
				member                    
				password_cache            
				password_policy           
				password_rules            
				passwordkey               
				prompts                   
				proxyip                   
				radcheck                  
				radgroupcheck             
				radgroupreply             
				radhuntcheck              
				radhuntgroup              
				radhuntgroupcheck         
				radhuntreply              
				radkey                    
				radreply                  
				radsourcecheck            
				radsourcegroup            
				radsourcegroupcheck       
				radsourcereply            
				radwmkey                  
				random                    
				rdptoapp                  
				resourcegroup             
				restrictacl               
				restrictpolicy            
				servergroup               
				servers                   
				setting                   
				sourceip                  
				sourceiplist              
				sshkey                    
				sshkeyname                
				sshprivatekey             
				sshpublickey              
				strategy                  
				weektime 
				/;

			$cmd = "mysqldump -h localhost -u root audit_sec ".join(" ",@tables)." >/tmp/audit_sec_backup.sql";
		}

		unless(-e "/tmp/audit_sec_backup.sql")
		{
			if($debug == 1)
			{
				print $cmd,"\n";
			}

			$db_status = system($cmd);
			$db_status = ($db_status == 0) ? 1 : 2;
			if($db_status == 2)
			{
				&err_process($dbh,$ip,"主机 mysqldump数据库 $dbname 错误");
				if($debug == 1)
				{
					print "主机 $ip mysqldump数据库 $dbname 错误\n";
				}

				my $sqr_update = $dbh->prepare("update backup_log set dblog=2 where ip='$ip' and endtime is null");
				$sqr_update->execute();
				$sqr_update->finish();
				unlink "/tmp/audit_sec_backup.sql";
				if($debug == 1)
				{
					print "主机 $ip 删除 audit_sec_backup.sql\n";
				}
			}
		}

		my $sqr_select = $dbh->prepare("select dblog from backup_log where ip='$ip' and endtime is null");
		$sqr_select->execute();
		my $ref = $sqr_select->fetchrow_hashref();
		if(!defined $ref->{"dblog"})
		{
			$cmd = "mysql -h $ip -u $mysqluser ";
			if(defined $mysqlpasswd)
			{
				$cmd .= "-p$mysqlpasswd ";
			}
			$cmd .= "audit_sec</tmp/audit_sec_backup.sql";
			if($debug == 1)
			{
				print $cmd,"\n";
			}
			$db_status = system($cmd);
			$db_status = ($db_status == 0) ? 1 : 2;

			if($db_status == 2)
			{
				&err_process($dbh,$ip,"主机 备份数据库 $dbname 错误");
				if($debug == 1)
				{
					print "主机 $ip 备份数据库 $dbname 错误\n";
				}
			}

			my $sqr_update = $dbh->prepare("update backup_log set dblog=$db_status where ip='$ip' and endtime is null");
			$sqr_update->execute();
			$sqr_update->finish();

			unlink "/tmp/audit_sec_backup.sql";
			if($debug == 1)
			{
				print "主机 $ip 删除 audit_sec_backup.sql\n";
			}
		}
	}
	else
	{
		my $sqr_update = $dbh->prepare("update backup_log set dblog = 0 where ip='$ip' and endtime is null");
		$sqr_update->execute();
		$sqr_update->finish();
	}

	my $sqr_update = $dbh->prepare("update backup_log set endtime=now() where ip='$ip' and endtime is null");
	$sqr_update->execute();
	$sqr_update->finish();

	$dbh->disconnect();
}

sub alarm_process
{       
	my $dbh=DBI->connect("DBI:mysql:database=audit_sec;host=localhost;mysql_connect_timeout=5",$mysql_user,$mysql_passwd,{RaiseError=>1});

	my $utf8 = $dbh->prepare("set names utf8");
	$utf8->execute();
	$utf8->finish();

	&err_process($dbh,$cur_host,"程序超时");
	$dbh->disconnect();
	exit;
}

sub err_process
{
	my($dbh,$host,$err_str) = @_;

	my $insert = $dbh->prepare("insert into backup_err_log(datetime,host,reason) values('$time_now_str','$host','$err_str')");
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
