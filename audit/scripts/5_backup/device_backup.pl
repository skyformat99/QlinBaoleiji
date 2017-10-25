#!/usr/bin/perl
use warnings;
use strict;
use DBI;
use DBD::mysql;
use Expect;
use File::HomeDir;
use Crypt::CBC;
use MIME::Base64;

our $log_flag = 1;
our $cipher = Crypt::CBC->new( -key => 'freesvr', -cipher => 'Blowfish', -iv => 'freesvr1', -header => 'none');
our $remote_mysql_user = "freesvr";
our $remote_mysql_passwd = "zT6fYu8HhLQ=";
$remote_mysql_passwd = decode_base64($remote_mysql_passwd);
$remote_mysql_passwd = $cipher->decrypt($remote_mysql_passwd);

our $time_now_utc = time;
our($min,$hour,$mday,$mon,$year) = (localtime $time_now_utc)[1..5];
($min,$hour,$mday,$mon,$year) = (sprintf("%02d", $min),sprintf("%02d", $hour),sprintf("%02d", $mday),sprintf("%02d", $mon + 1),$year+1900);
our $time_now_str = "$year$mon$mday$hour$min"."00";

our @backup_files = qw#
/opt/freesvr/audit/gateway/log/telnet/
/opt/freesvr/audit/gateway/log/ssh/
/opt/freesvr/audit/gateway/log/rdp/
/opt/freesvr/audit/ftp-audit/backup/upload/
/opt/freesvr/audit/ftp-audit/backup/download/
/opt/freesvr/audit/log/sftp/
#;

our %local_database;
our %all_tables;

our($mysql_user,$mysql_passwd) = &get_local_mysql_config();
our $dbh=DBI->connect("DBI:mysql:database=audit_nm;host=localhost;mysql_connect_timeout=5",$mysql_user,$mysql_passwd,{RaiseError=>1});
my $utf8 = $dbh->prepare("set names utf8");
$utf8->execute();
$utf8->finish();

&init_database();
&init_tables();

my $sqr_select = $dbh->prepare("select host from device_mysql_info");
$sqr_select->execute();
while(my $ref_select = $sqr_select->fetchrow_hashref())
{
	my $host = $ref_select->{"host"};

    unless(defined $host)
    {
        next;
    }

	unless($host eq "localhost")
	{
		&mysql_backup($host);
		&file_backup($host);
	}
}
$sqr_select->finish();
$dbh->disconnect();

sub init_database
{
	my $sqr_select = $dbh->prepare("show databases");
	$sqr_select->execute();
	while(my $ref_select = $sqr_select->fetchrow_arrayref())
	{
		my $database = $ref_select->[0];
		unless(exists $local_database{$database})
		{
			$local_database{$database} = 1;
		}
	}
}

sub init_tables
{
	my @tables = qw/
		admin_log                              
		alarm                                  
		appcomm                                
		appdevices                             
		appgroup                               
		appicon                                
		applogin                               
		appmember                              
		appprogram                             
		apppserver                             
		apppub                                 
		appresourcegroup                       
        commands
		devices                                
		forbidden_commands                     
		forbidden_commands_groups              
		forbidden_commands_user                
		forbidden_groups                       
		ftpcomm                                
		ftpsessions                            
		lgroup                                 
		lgroup_appresourcegrp                  
		lgroup_devgrp                          
		lgroup_resourcegrp                     
		login4approve                          
		login_tab                              
		login_template                         
		loginacct                              
		loginacctcode                          
		logincommit                            
		loginlog                               
		luser                                  
		luser_appresourcegrp                   
		luser_devgrp                           
		luser_resourcegrp                      
		member                                 
		rdpsessions                            
		servergroup                            
		servers                                
		sessions                               
		setting                                
		sftpcomm                               
		sftpsessions
        resourcegroup
        sub_sessions
        usergroup
        sessiondesc
        defaultpolicy
		/;

	foreach my $table(@tables)
	{
		unless(exists $all_tables{$table})
		{
			$all_tables{$table} = 1;
		}
	}
}

sub mysql_backup
{
	my($host) = @_;

	my @remote_tables = &get_tables($host);

	my $db_name = $host;
	$db_name =~ s/\./_/g;

	if(exists $local_database{$db_name})
	{
		my $sqr_drop = $dbh->prepare("drop database $db_name");
		$sqr_drop->execute();
		$sqr_drop->finish();
	}

	my $sqr_create = $dbh->prepare("create database $db_name");
	$sqr_create->execute();
	$sqr_create->finish();

	my $cmd = "mysqldump -h $host -u $remote_mysql_user -p$remote_mysql_passwd audit_sec ".join(" ",@remote_tables)." > /tmp/remote_bk.sql";
	if(system($cmd))
	{
		print "$host mysqldump cmd error\n";
		unlink "/tmp/remote_bk.sql";
		return;
	}

	$cmd = "mysql -h localhost -u root $db_name</tmp/remote_bk.sql";
	if(system($cmd))
	{
		print "$host mysql cmd error\n";
	}

	unlink "/tmp/remote_bk.sql";
	return;
}

sub get_tables
{
	my($host) = @_;
	my @tmp_tables;

	my $remote_dbh = DBI->connect("DBI:mysql:database=audit_sec;host=$host;mysql_connect_timeout=5","$remote_mysql_user","$remote_mysql_passwd",{RaiseError=>0});
	my $utf8 = $remote_dbh->prepare("set names utf8");
	$utf8->execute();
	$utf8->finish();

	my $sqr_select = $remote_dbh->prepare("show tables");
	$sqr_select->execute();
	while(my $ref_select = $sqr_select->fetchrow_arrayref())
	{
		my $table = $ref_select->[0];
		if(exists $all_tables{$table})
		{
			push @tmp_tables,$table;
		}
	}
	$remote_dbh->disconnect();
	return @tmp_tables;
}

sub file_backup
{
	my($host) = @_;
	my $dst_path = "/opt/data/${host}_bk/";

	unless(-e $dst_path)
	{
		mkdir $dst_path,0755;
	}

	foreach my $file(@backup_files)
	{
		$file =~ s/\/$//;
		my $cmd = "rsync -av -e 'ssh -p 2288' root\@$host:$file $dst_path";

		if($cmd =~ /ftp-audit/)
		{
			$cmd .= "ftp/";
		}

        &ssh_process($cmd);
	}
}

sub ssh_process
{
    my($cmd) = @_;
    my $user;
    my $ip;

    if($cmd =~ /.*\s+(.*)\@/)
    {
        $user = $1;
    }
    else
    {
        if($log_flag == 1)
        {
            &err_process("need user in cmd: $cmd"); 
        }
        return;
    }

    if($cmd =~ /\@(.*):/)
    {
        $ip = $1;
    }
    else
    {
        if($log_flag == 1)
        {
            &err_process("need ip in cmd: $cmd"); 
        }
        return;
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
                qr/(receiving|sending).*file list/i,
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
                        if($log_flag == 1)
                        {
                            &err_process("$cmd exec error"); 
                        }
                    }
                }

                $exp->soft_close();
    }

    if($count >= 10)
    {
        if($log_flag == 1)
        {
            &err_process("rsa err and fail to fix"); 
        }
        return;
    }
}

sub rsa_err_process
{
    my($user,$ip) = @_;
    my $home = File::HomeDir->users_home($user);
    unless(defined $home)
    {
        if($log_flag == 1)
        {
            &err_process("cant find home dir for user $user"); 
        }
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

sub err_process
{
    my($context) = @_;
    $context =~ s/'/\\\'/g;

    my $sqr_insert = $dbh->prepare("insert into device_backup_errlog(datetime,context) values('$time_now_str','$context')");
    $sqr_insert->execute();
    $sqr_insert->finish();
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
