#!/usr/bin/perl
use warnings;
use strict;
use DBI;
use DBD::mysql;
use File::Basename;
use File::Copy;
use Expect;
use File::HomeDir;
use Crypt::CBC;
use MIME::Base64;

our($mysql_user,$mysql_passwd) = &get_local_mysql_config();
our $cipher = Crypt::CBC->new( -key => 'freesvr', -cipher => 'Blowfish', -iv => 'freesvr1', -header => 'none');
our $remote_mysql_user = "freesvr";
our $remote_mysql_passwd = "JZ1EzZwjYXo=";
$remote_mysql_passwd = decode_base64($remote_mysql_passwd);
$remote_mysql_passwd = $cipher->decrypt($remote_mysql_passwd);

our($slave_ip,$backup_ip) = @ARGV;
our $master_ip;
our @my_cnf;

foreach my $line(`/sbin/ifconfig eth0`)
{
	chomp $line;
	if($line =~ /inet addr\s*:\s*(\S+)/)
	{
		$master_ip = $1;
	}
}

if($master_ip eq "")
{
	print "ifconfig cmd err\n";
	exit 1;
}

open(my $fd_fr,"</opt/freesvr/1/etc/my.cnf");
foreach my $line(<$fd_fr>)
{
	chomp $line;
	push @my_cnf,$line;
}

close $fd_fr;

our @add_context_master = (
		"log-bin=mysql-bin",
		"server-id=100",
		"log-slave-updates",
		"slave-skip-errors=all",
		"sync_binlog = 1",
		"innodb_flush_log_at_trx_commit = 1",
		"log-warnings",
		"replicate-do-db=audit_sec",
		"replicate-ignore-db=mysql",
		"auto_increment_increment=2",
		"auto_increment_offset=1",
		"master-host     =   $slave_ip",
		"master-user     =   freesvr",
		"master-password =   freesvr",
		"master-port     = 3306",
		"replicate_ignore_table = audit_sec.backup_log",
		"replicate_ignore_table = audit_sec.backup_setting",
		"replicate_ignore_table = audit_sec.loadbalance",
		"replicate_ignore_table = audit_sec.local_status",
		"replicate_ignore_table = audit_sec.local_status_cache",
		"replicate_ignore_table = audit_sec.local_status_err",
		"replicate_ignore_table = audit_sec.local_status_warning_log",
		);

our @add_context_slave = (
		"log-bin=mysql-bin",
		"server-id=101",
		"replicate-do-db=audit_sec",
		"replicate-ignore-db=mysql",
		"log-slave-updates",
		"slave-skip-errors=all",
		"sync_binlog = 1",
		"auto_increment_increment=2",
		"auto_increment_offset=2",
		"master-host     =   $master_ip",
		"master-user     =   freesvr",
		"master-password =   freesvr",
		"master-port     = 3306",
		"replicate_ignore_table = audit_sec.backup_log",
		"replicate_ignore_table = audit_sec.backup_setting",
		"replicate_ignore_table = audit_sec.loadbalance",
		"replicate_ignore_table = audit_sec.local_status",
		"replicate_ignore_table = audit_sec.local_status_cache",
		"replicate_ignore_table = audit_sec.local_status_err",
		"replicate_ignore_table = audit_sec.local_status_warning_log",
		);

#master mysql_cnf_process
&mysql_process("/opt/freesvr/1/etc/my_master.cnf",\@add_context_master);

#slave mysql_cnf_process
&mysql_process("/opt/freesvr/1/etc/my_slave.cnf",\@add_context_slave);

unless(-e "/opt/freesvr/1/ha/keepalived.conf")
{
	print "/opt/freesvr/1/ha/keepalived.conf 不存在\n";
	exit 1;
}

unless(-e "/etc/keepalived/")
{
	`mkdir -p /etc/keepalived/`;
}

copy("/opt/freesvr/1/ha/keepalived.conf","/etc/keepalived/keepalived_master.conf");
copy("/opt/freesvr/1/ha/keepalived.conf","/etc/keepalived/keepalived_slave.conf");

&master_keepalived_process("/etc/keepalived/keepalived_master.conf");
&slave_keepalived_process("/etc/keepalived/keepalived_slave.conf");

&file_rename_transmission();

&restart_mysql();
&restart_keepalive();

&file_modify_process("/etc/xrdp/global.cfg","global-server",$master_ip);
&file_modify_process("/opt/freesvr/audit/sshgw-audit/etc/freesvr-ssh-proxy_config","AuditAddress",$master_ip);
&file_modify_process("/opt/freesvr/audit/etc/global.cfg","global-server",$master_ip);
&file_modify_process("/opt/freesvr/audit/ftp-audit/etc/freesvr-ftp-audit.conf","AuditAddress",$master_ip);
&file_modify_process("/home/wuxiaolong/5_backup/backup_session.pl","our\\s+\\\$localIp",$master_ip);
&iptables_process($slave_ip);

&cron_modify_process("/home/wuxiaolong/5_backup/backup_session.pl");

&restart_program();

&slave_program_exec();

&sql_process();

sub mysql_process
{
	my($file,$ref_add_context) = @_;

	my @file_context;

	foreach my $line(@my_cnf)
	{
		if($line =~ /^#/ || $line =~ /^\s*$/)
		{
			push @file_context,$line;
			next;
		}

		chomp $line;
		my $flag = 0;
		my($key,$value) = (split /=/,$line)[0,1];
		$key =~ s/\s//g;
		if(defined $value){$value =~ s/\s//g;}

		foreach my $add_line(@$ref_add_context)
		{
			my($tmp_key,$tmp_value) = (split /=/,$add_line)[0,1];
			$tmp_key =~ s/\s//g;
			if(defined $tmp_value){$tmp_value =~ s/\s//g;}

			if($tmp_key eq "replicate_ignore_table" && $tmp_key eq $key)
			{
				if($value eq $tmp_value)
				{
					$flag = 1;
					last;
				}
			}
			elsif($tmp_key eq $key)
			{
				$flag = 1;
				last;
			}
		}

		if($flag == 0)
		{
			push @file_context,$line;
		}
	}

	foreach my $add_line(@$ref_add_context)
	{
		push @file_context,$add_line;
	}

	open(my $fd_fw,">$file");
	foreach my $line(@file_context)
	{
		print $fd_fw $line,"\n";
	}

	close $fd_fw;
}

sub master_keepalived_process
{
	my($file) = @_;

	my @file_context;
	my $flag = 0;

	open(my $fd_fr,"<$file");
	foreach my $line(<$fd_fr>)
	{
		chomp $line;

		if($line =~ /virtual_ipaddress/i)
		{
			$flag = 1;
		}

		if($flag == 1 && $line =~ /(\d{1,3}\.){3}\d{1,3}/)
		{
			$line =~ s/(\d{1,3}\.){3}\d{1,3}/$backup_ip/;
			$flag = 0;
		}

		push @file_context,$line;
	}
	close $fd_fr;

	open(my $fd_fw,">$file");
	foreach my $line(@file_context)
	{
		print $fd_fw $line,"\n";
	}

	close $fd_fw;
}

sub slave_keepalived_process
{
	my($file) = @_;

	my @file_context;
	my $flag = 0;

	open(my $fd_fr,"<$file");
	foreach my $line(<$fd_fr>)
	{
		chomp $line;

		if($line =~ /^\s*priority/i)
		{
			$line =~ s/\d+/10/;
		}

		if($line =~ /virtual_ipaddress/i)
		{
			$flag = 1;
		}

		if($flag == 1 && $line =~ /(\d{1,3}\.){3}\d{1,3}/)
		{
			$line =~ s/(\d{1,3}\.){3}\d{1,3}/$backup_ip/;
			$flag = 0;
		}

		push @file_context,$line;
	}
	close $fd_fr;

	open(my $fd_fw,">$file");
	foreach my $line(@file_context)
	{
		print $fd_fw $line,"\n";
	}

	close $fd_fw;
}

sub file_rename_transmission
{
	rename "/opt/freesvr/1/etc/my_master.cnf", "/etc/my.cnf";
	rename "/etc/keepalived/keepalived_master.conf","/etc/keepalived/keepalived.conf";

	my $cmd = "rsync -av -e 'ssh -p 2288' /opt/freesvr/1/etc/my_slave.cnf root\@$slave_ip:/etc/my.cnf";
    $cmd =~ /^(.*)$/;
    $cmd = $1;
	&rsync_process($cmd);

	$cmd = "rsync -av -e 'ssh -p 2288' /etc/keepalived/keepalived_slave.conf root\@$slave_ip:/etc/keepalived/keepalived.conf";
	&rsync_process($cmd);

	unlink "/opt/freesvr/1/etc/my_master.cnf";
	unlink "/opt/freesvr/1/etc/my_slave.cnf";
	unlink "/etc/keepalived/keepalived_master.conf";
	unlink "/etc/keepalived/keepalived_slave.conf";
}

sub rsync_process
{
	my($cmd) = @_;
	my $user;
	my $ip;

	if($cmd =~ /.*\s+(.*)\@/)
	{
		$user = $1;
	}

	if($cmd =~ /\@(.*):/)
	{
		$ip = $1;
	}

	my $count = 0;
	my $flag = 1;

	while($count < 10 && $flag == 1)
	{               
		++$count;   
		my $rsa_flag = 0;

		my $exp = Expect->new;
		$exp->log_stdout(0);
		$exp->spawn($cmd);
		$exp->debug(0);

		my @results = $exp->expect(20,
				[
				qr/continue connecting.*yes\/no.*/i,
				sub {
				my $self = shift ;
				$self->send_slow(0.1,"yes\n");
				exp_continue;
				}
				],

				[
				qr/building.*file list/i,
				sub{
				$flag = 0;
				}
				],

				[
				qr/Host key verification failed/i,
				sub
				{
					my $tmp = &rsa_err_process($user,$ip);
					if($tmp == 0)
					{
						$rsa_flag = 1;
					}
					else
					{
						$rsa_flag = 2;
					}
				}
		],
			);

		if($rsa_flag == 1)
		{
			$flag = 1;
		}
		elsif($rsa_flag == 2)
		{
			$flag = 2;
		}
		elsif($rsa_flag == 0 && $flag != 0)
		{
			$flag = 3;
		}

		if($flag == 0)
		{
			$exp->expect(undef, undef);
		}
		elsif($flag != 1 && $flag != 2)
		{
			if(defined $results[1])
			{
				print "$cmd exec error\n";
				exit 1;
			}
		}

		$exp->soft_close();
	}

	if($count >= 10)
	{
		print "rsa err and fail to fix\n";
		exit 1;
	}
}

sub restart_mysql
{
	my $cmd = "/etc/init.d/mysqld stop 1>/dev/null 2>&1";
	system($cmd);

	my $file = "/opt/freesvr/sql/var/localhost-relay-bin.index";
	my $dir = dirname $file;

	unless(-e $dir)
	{
		$cmd = "mkdir -p $dir";
		system($cmd);
	}

	foreach my $file(glob "/opt/freesvr/sql/var/localhost-relay-bin.*")
	{
		unlink $file;
	}

	open(my $fd_fw,">$file");
	close $fd_fw;

	my $user = getpwnam "mysql";
	my $group = getgrnam "mysql";
	chown $user,$group,$file;

	$cmd = "/etc/init.d/mysqld start 1>/dev/null 2>&1";
	if(system($cmd) != 0)
	{
		print "mysql 启动失败\n";
		exit 1;
	}
}

sub file_modify_process
{
	my($file,$attr,$ip) = @_;
	my $dir = dirname $file;
	my $file_name = basename $file;
	my $backup_name = $file_name.".backup";

	unless(-e "$dir/$backup_name")
	{
		copy($file,"$dir/$backup_name");
	}

	open(my $fd_fr,"<$file");

	my @file_context;
	my $flag = 0;
	foreach my $line(<$fd_fr>)
	{
		chomp $line;
		if($line =~ /^$attr/i)
		{
			$line =~ s/(\d{1,3}\.){3}\d{1,3}/$ip/;
		}

		push @file_context,$line;
	}

	close $fd_fr;

	open(my $fd_fw,">$file");
	foreach my $line(@file_context)
	{
		print $fd_fw $line,"\n";
	}

	close $fd_fw;
}

sub iptables_process
{
    my($peer_ip) = @_;
    my $file = "/etc/sysconfig/iptables";

    my $dir = dirname $file;
    my $file_name = basename $file;
    my $backup_name = $file_name.".backup";

	unless(-e "$dir/$backup_name")
	{
		copy($file,"$dir/$backup_name");
	}

    open(my $fd_fr,"<$file");
    my @file_context;
    my $flag = 0;
    foreach my $line(<$fd_fr>)
    {
        chomp $line;
        if($line =~ /^-A\s*RH-Firewall/i)
        {
            if($flag == 0)
            {
                $flag = 1;
            }

            if($line =~ /-s\s*$peer_ip/i)
            {
                $flag = 2;
            }
        }

        if($line =~ /^-A\s*RH-Firewall.*REJECT/i && $flag == 1)
        {
            $flag = 3;
            push @file_context,"-A RH-Firewall-1-INPUT -s $peer_ip -j ACCEPT";
        }

        push @file_context,$line;
    }

    close $fd_fr;

	open(my $fd_fw,">$file");
	foreach my $line(@file_context)
	{
		print $fd_fw $line,"\n";
	}

	close $fd_fw;
    if(system("service iptables restart 1>/dev/null 2>&1") != 0)
    {
        print "iptables restart 失败\n";
        exit 1;
    }
}

sub cron_modify_process
{
    my($file) = @_;

	if(-e "/var/spool/cron/root")
	{
		open(my $fd_fr,"</var/spool/cron/root");
		my @file_context;
		my $flag = 0;
		foreach my $line(<$fd_fr>)
		{
			chomp $line;
			if($line =~ /$file/i)
			{
				$flag = 1;
				$line = "*/10 * * * * $file";
			}

			push @file_context,$line;
		}

		if($flag == 0)
		{
			push @file_context,"*/10 * * * * $file";
		}

		close $fd_fr;

		open(my $fd_fw,">/var/spool/cron/root");
		foreach my $line(@file_context)
		{
			print $fd_fw $line,"\n";
		}

		close $fd_fw;
	}
	else
	{
		open(my $fd_fw,">/var/spool/cron/root");
		print $fd_fw "*/10 * * * * $file\n";
		close $fd_fw;
	}
}

sub restart_program
{
	my %service_hash;
	open(my $fd_fr,"</opt/freesvr/audit/etc/process.ini");

	foreach my $line(<$fd_fr>)
	{
		chomp $line;
		$line =~ s/^\[//;
		$line =~ s/\]$//;
		my ($name,$cmd) = split /=/,$line;

		unless($name eq "ftp-audit" || $name eq "Freesvr_RDP" || $name eq "ssh-audit")
		{
			next;
		}

		unless(exists $service_hash{$name})
		{
			my @temp_arr;
			push @temp_arr,$cmd;
			if($name eq "ftp-audit") {push @temp_arr,21;}
			elsif($name eq "Freesvr_RDP") {push @temp_arr,3389;}
			elsif($name eq "ssh-audit") {push @temp_arr,22;}

			$service_hash{$name} = \@temp_arr;
		}
	}

	foreach my $process_name(keys %service_hash)
	{
		my $val = $service_hash{$process_name};

		&stop_process($process_name,$val->[0],$val->[1]);
		sleep 1;
		my $status = &start_process($process_name,$val->[0],$val->[1]);
		if($status == 0)
		{
			print "$process_name 启动失败\n";
			exit 1;
		}
	}
}

sub restart_keepalive
{
	while(1)
	{
		my $result = `ps -ef | grep keepalived | grep -v -E "vim|grep|perl"`;
		if($result ne "")
		{
			my @result_arr = split /\n/,$result;
			foreach my $line(@result_arr)
			{
				my $pid = (split /\s+/,$line)[1];
				unless($pid =~ /\d+/) {next;}
				kill 9,$pid;
			}   
			next;
		}
		else
		{
			last;
		}
	}

	if(system("/usr/local/sbin/keepalived") != 0)
	{
		print "keepalived 启动失败\n";
		exit 1;
	}
}

sub slave_program_exec
{
	my $cmd = "ssh -l root $slave_ip -p 2288";

	my $user = "root";
	my $ip = $slave_ip;

	my $count = 0;
	my $flag = 1;

	while($count < 10 && $flag == 1)
	{
		++$count;
		my $rsa_flag = 0;

		my $exp = Expect->new;
		$exp->log_stdout(0);
		$exp->spawn($cmd);
		$exp->debug(0);

		my @results = $exp->expect(20,
				[
				qr/~\]/i,
				sub {
				$flag = 0;
				}
				],

				[
				qr/continue connecting.*yes\/no.*/i,
				sub {
				my $self = shift ;
				$self->send_slow(0.1,"yes\n");
				exp_continue;
				}
				],

				[
				qr/Host key verification failed/i,
				sub
				{
					my $tmp = &rsa_err_process($user,$ip);
					if($tmp == 0)
					{
						$rsa_flag = 1;
					}
					else
					{
						$rsa_flag = 2;
					}
				}
		],
			);

		if($rsa_flag == 1)
		{
			$flag = 1;
		}
		elsif($rsa_flag == 2)
		{
			$flag = 2;
		}
		elsif($rsa_flag == 0 && $flag != 0)
		{
			$flag = 3;
		}

		if($flag == 0)
		{
			$cmd = "/home/wuxiaolong/mysql_keepalived/habackup.pl $master_ip";
			$exp->send("$cmd\n");

			while(1)
			{
				my $exec_flag = 0;
				$exp->expect(1, undef);
				foreach my $line(split /\n/,$exp->before())
				{
					if($line =~ /fail/)
					{
						print "/home/wuxiaolong/habackup.pl in $slave_ip exec err\n";
						exit 1;
					}

					if($line =~ /success/)
					{
						$exec_flag = 1;
						last;
					}
				}

				if($exec_flag == 1)
				{
					last;
				}
			}
		}
		elsif($flag != 1 && $flag != 2)
		{
			if(defined $results[1])
			{
				print "$cmd exec error\n";
				exit 1;
			}
		}

		$exp->close();
	}

	if($count >= 10)
	{
		print "rsa err and fail to fix\n";
		exit 1;
	}
}

sub sql_process
{
	my $local_dbh=DBI->connect("DBI:mysql:database=audit_sec;host=localhost;mysql_connect_timeout=5",$mysql_user,$mysql_passwd,{RaiseError=>1});

	my $utf8 = $local_dbh->prepare("set names utf8");
	$utf8->execute();
	$utf8->finish();

	my $sqr_exec = $local_dbh->prepare("show master status");
	$sqr_exec->execute();
	my $ref_exec = $sqr_exec->fetchrow_hashref();
	my $local_file = $ref_exec->{"File"};
	my $local_position = $ref_exec->{"Position"};
	$sqr_exec->finish();

	my $remote_dbh=DBI->connect("DBI:mysql:database=audit_sec;host=$slave_ip;mysql_connect_timeout=5",$remote_mysql_user,$remote_mysql_passwd,{RaiseError=>1});

	$utf8 = $remote_dbh->prepare("set names utf8");
	$utf8->execute();
	$utf8->finish();

	$sqr_exec = $remote_dbh->prepare("show master status");
	$sqr_exec->execute();
	$ref_exec = $sqr_exec->fetchrow_hashref();
	my $remote_file = $ref_exec->{"File"};
	my $remote_position = $ref_exec->{"Position"};
	$sqr_exec->finish();

	$sqr_exec = $local_dbh->prepare("stop slave");
	$sqr_exec->execute();
	$sqr_exec->finish();

	$sqr_exec = $local_dbh->prepare("reset slave");
	$sqr_exec->execute();
	$sqr_exec->finish();

	$sqr_exec = $local_dbh->prepare("change master to master_host='$slave_ip',master_user='freesvr',master_password='freesvr',master_log_file='$remote_file',master_log_pos= $remote_position");
	$sqr_exec->execute();
	$sqr_exec->finish();

	$sqr_exec = $local_dbh->prepare("start slave");
	$sqr_exec->execute();
	$sqr_exec->finish();

	$sqr_exec = $remote_dbh->prepare("stop slave");
	$sqr_exec->execute();
	$sqr_exec->finish();

	$sqr_exec = $remote_dbh->prepare("reset slave");
	$sqr_exec->execute();
	$sqr_exec->finish();

	$sqr_exec = $remote_dbh->prepare("change master to master_host='$master_ip',master_user='freesvr',master_password='freesvr',master_log_file='$local_file',master_log_pos= $local_position");
	$sqr_exec->execute();
	$sqr_exec->finish();

	$sqr_exec = $remote_dbh->prepare("start slave");
	$sqr_exec->execute();
	$sqr_exec->finish();

	my $sqr_select = $local_dbh->prepare("select count(*) from backup_setting where ip = '$slave_ip' and dbname = 'audit_sec' and mysqluser = 'freesvr' and udf_decrypt(mysqlpasswd) = 'freesvr' and session_flag = 1");
	$sqr_select->execute();
	my $ref_select = $sqr_select->fetchrow_hashref();
	if($ref_select->{"count(*)"} == 0)
	{
		my $sqr_insert = $local_dbh->prepare("insert into backup_setting(ip,dbname,mysqluser,mysqlpasswd,session_flag) values('$slave_ip','audit_sec','freesvr',udf_encrypt('freesvr'),1)");
		$sqr_insert->execute();
		$sqr_insert->finish();
	}
	$sqr_select->finish();

	$sqr_select = $remote_dbh->prepare("select count(*) from backup_setting where ip = '$master_ip' and dbname = 'audit_sec' and mysqluser = 'freesvr' and udf_decrypt(mysqlpasswd) = 'freesvr' and session_flag = 1");
	$sqr_select->execute();
	$ref_select = $sqr_select->fetchrow_hashref();
	if($ref_select->{"count(*)"} == 0)
	{
		my $sqr_insert = $remote_dbh->prepare("insert into backup_setting(ip,dbname,mysqluser,mysqlpasswd,session_flag) values('$master_ip','audit_sec','freesvr',udf_encrypt('freesvr'),1)");
		$sqr_insert->execute();
		$sqr_insert->finish();
	}
	$sqr_select->finish();
}

sub rsa_err_process
{
	my($user,$ip) = @_;
	my $home = File::HomeDir->users_home($user);
	unless(defined $home)
	{   
		print "cant find home dir for user $user\n";
		return 1;
	}

	my @file_lines;
	$home =~ s/\/$//;
	open(my $fd_fr,"<$home/.ssh/known_hosts");
	foreach my $line(<$fd_fr>)
	{   
		if($line =~ /^$ip/)
		{   
			next;
		}

		push @file_lines,$line;
	}
	close $fd_fr;

	open(my $fd_fw,">$home/.ssh/known_hosts");
	foreach my $line(@file_lines)
	{   
		print $fd_fw $line;
	}
	close $fd_fw;

	return 0;
}

sub stop_process
{
	my($name,$cmd,$port) = @_;
	my $result = `/usr/sbin/lsof -n -i:$port`;
	if($result ne "")
	{
		my %pid_arr;
		my @result_arr = split /\n/,$result;
		foreach my $line(@result_arr)
		{
			my $pid = (split /\s+/,$line)[1];
			unless($pid =~ /\d+/) {next;}
			unless(exists $pid_arr{$pid})
			{
				$pid_arr{$pid} = 1;
			}
		}

		foreach my $pid(keys %pid_arr)
		{
			kill 9,$pid;
		}
	}
}

sub start_process
{   
	my($name,$cmd,$port) = @_;

	my $delete_file;
	if($name eq "Freesvr_RDP")
	{   
		$delete_file = "/var/run/freesvr_rdp[proxy].pid";
	}

	if(defined $delete_file)
	{   
		unlink $delete_file;
	}

	my $result = `/usr/sbin/lsof -n -i:$port`;
	if($result eq "")
	{   
		if(system("$cmd 1>/dev/null 2>&1") == 0)
		{
			return 1;
		}
		else
		{
			return 0;
		}
	}
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
