#!/usr/bin/perl
use warnings;
use strict;
use DBI;
use DBD::mysql;
use Crypt::CBC;
use MIME::Base64;

our($mysql_user,$mysql_passwd) = &get_local_mysql_config();
our $dbh=DBI->connect("DBI:mysql:database=audit_sec;host=localhost;mysql_connect_timeout=120",$mysql_user,$mysql_passwd,{RaiseError=>1});
our $utf8 = $dbh->prepare("set names utf8");
$utf8->execute();
$utf8->finish();

&file_del();
#&database_del();
exit 0;

sub file_del
{
    my $sqr_select = $dbh->prepare("select ifnull(time, 0) `interval`, name from autodelete where file_or_db=0");
    $sqr_select->execute();
    while(my $ref_select = $sqr_select->fetchrow_hashref())
    {
        my $interval = $ref_select->{"interval"};
        my $dir = $ref_select->{"name"};

        my $file_end_time = time - $interval * 3600 * 24;
        my ($year,$mon,$day) = (localtime $file_end_time)[5,4,3];
        ($year,$mon,$day) =  ($year+1900,sprintf("%02d", $mon+1),sprintf("%02d", $day));
        $file_end_time = $year.$mon.$day;

        if($dir =~ /ftp-audit/ || $dir =~ /sftp/) 
        {
            &ftp_file_del($dir, $interval);
        }
        else
        {
            &normal_file_del($dir, $file_end_time);
        }
    }
    $sqr_select->finish();
}

sub normal_file_del
{
    my ($del_dir, $file_end_time) = @_;
    $del_dir =~ s/\/$//;
    unless(-e $del_dir)
    {
        return;
    }

    opendir(my $dir,$del_dir);
    foreach my $file(readdir $dir)
    {
        my ($year,$mon,$day);
        if($file =~ /^\d{4}-\d{1,2}-\d{1,2}/) 
        {
            ($year,$mon,$day) = split /-/,$file;
        } 
        elsif($file =~ /^\d{4}_\d{1,2}_\d{1,2}/) 
        {
            ($year,$mon,$day) = split /_/,$file;
        }
        else 
        {
            next;
        }

        ($mon,$day) =  (sprintf("%02d", $mon),sprintf("%02d", $day));
        my $file_time = $year.$mon.$day;

        if($file_time < $file_end_time)
        {
            $file = "$del_dir/$file";
            print "del: $file\n";
            `rm -fr $file`;
        }
    }
    closedir $dir;
}

sub ftp_file_del
{
    my ($del_dir, $interval) = @_;
    $del_dir =~ s/\/$//;
    unless(-e $del_dir)
    {
        return;
    }

    opendir(my $dir,$del_dir);
    foreach my $file(readdir $dir)
    {
        $file = "$del_dir/$file";
        if(-f $file)
        {
            my $file_interval = -M $file;
            if($file_interval > $interval)
            {
                print "del: $del_dir/$file\n";
                unlink($file)
            }
        }
    }
    closedir $dir;
}

sub database_del
{
    my $sqr_select = $dbh->prepare("select ifnull(time, 0) `interval`, name from autodelete where file_or_db=1");
    $sqr_select->execute();
    while(my $ref_select = $sqr_select->fetchrow_hashref())
    {
        my $interval = $ref_select->{"interval"};
        my $dbname = $ref_select->{"name"};

        if($dbname eq "audit_sec")
        {
#            &audit_sec_process("audit_sec", $interval);
        }
        elsif($dbname eq "log")
        {
#            &log_process("log", $interval);
        }
        elsif($dbname eq "dbaudit")
        {
#            &dbaudit_process("dbaudit", $interval);
        }
    }
    $sqr_select->finish();
}

sub delete_func
{
    my($database_name,$table_name,$col_name,$interval) = @_;

    my $sqr_delete = $dbh->prepare("delete from $database_name.$table_name where date($col_name) < date_sub(curdate(),interval $interval day)");
    $sqr_delete->execute();
    $sqr_delete->finish();
}

sub audit_sec_process
{
    my($database_name, $interval) = @_;
    my %table_name;

    my $sqr_table = $dbh->prepare("show tables from $database_name");
    $sqr_table->execute();
    while(my $ref_table = $sqr_table->fetchrow_arrayref())
    {
        $table_name{$ref_table->[0]} = 1;
    }
    $sqr_table->finish();

    my %table_col = ("rdpsessions" => "datetime",
            "sessions" => "datetime",
            "commands" => "datetime",
            "ftpsessions" => "datetime",
            "ftpcomm" => "datetime",
            "sftpsessions" => "datetime",
            "sftpcomm" => "datetime",
            );

    foreach my $key(keys %table_col)
    {
        if(exists $table_name{$key})
        {
            &delete_func($database_name,$key,$table_col{$key},$interval);
        }
    }
}

sub log_process
{
    my($database_name, $interval) = @_;
    my %table_name;

    my $sqr_table = $dbh->prepare("show tables from $database_name");
    $sqr_table->execute();
    while(my $ref_table = $sqr_table->fetchrow_arrayref())
    {
        $table_name{$ref_table->[0]} = 1;
    }
    $sqr_table->finish();

    my %table_col = ("eventlogs" => "datetime",
            "windows_login" => "starttime",
            "countlogs_minuter_server" => "date",
            "countlogs_minuter_level" => "date",
            "countlogs_minuter_detailed" => "date",
            "countlogs_hour_server" => "date",
            "countlogs_hour_level" => "date",
            "countlogs_hour_detailed" => "date",
            "login_day_count" => "date",
            "logs" => "datetime",
            "linux_login" => "starttime",
            "alllogs" => "datetime"
            );

    foreach my $key(keys %table_col)
    {
        if(exists $table_name{$key})
        {
            &delete_func($database_name,$key,$table_col{$key},$interval);
        }
    }
}

sub dbaudit_process
{
	my($database_name, $interval) = @_;
	my %table_name;

	my $sqr_table = $dbh->prepare("show tables from $database_name");
	$sqr_table->execute();
	while(my $ref_table = $sqr_table->fetchrow_arrayref())
	{
		$table_name{$ref_table->[0]} = 1;
	}
	$sqr_table->finish();

	my %table_col = ("oracle_sessions" => "start",
			"oracle_commands" => "at",
			"sybase_sessions" => "start",
			"sybase_commands" => "at",
			"mysql_sessions" => "start",
			"mysql_commands" => "at",
			"db2_sessions" => "start",
			"db2_commands" => "at",
			"sqlserver_sessions" => "start",
			"sqlserver_commands" => "at",
			);

	foreach my $key(keys %table_col)
	{  
		if(exists $table_name{$key})
		{
			&delete_func($database_name,$key,$table_col{$key},$interval);
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
