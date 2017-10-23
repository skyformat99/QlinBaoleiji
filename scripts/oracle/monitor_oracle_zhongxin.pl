#!/usr/bin/perl
use strict;
use warnings;

use DBI;
use DBD::Oracle;
use DBD::mysql;
use DBD::Oracle qw(:ora_session_modes);
use Crypt::CBC;
use MIME::Base64;

$ENV{ORACLE_HOME}="/usr/local/oracle";
$ENV{TNS_ADMIN}="/usr/local/oracle/NETWORK/ADMIN";
$ENV{NLS_LANG}="AMERICAN_AMERICA.ZHS16GBK";
our $output_path = "/home/wuxiaolong/oracle/oracle_result";
$output_path =~ s/\/$//;

sub monitor_oracle;
monitor_oracle("RAC3");

sub monitor_oracle
{
	my $oracle_sid=shift;
	my ($oracle_user,$oracle_pass) = ("ctsi","02pF9OHys31l2+CJTExFCQ==");
    $oracle_pass = decode_base64($oracle_pass);
    $oracle_pass = $cipher->decrypt($oracle_pass);

	my $dbh;
	my $output;
	open (my $output_fd,">",\$output) or die($!);
	$dbh= DBI->connect("dbi:Oracle:$oracle_sid","$oracle_user","$oracle_pass");


	if(!defined($dbh))
	{
	    die "oracle conn err\n";
	}
	my $sth;
	my $sql;
	my $sqlcmd;

	$sqlcmd="select tablespace_name,
			    file_id,
			    file_name,
			    round(bytes / (1024 * 1024), 0) filesize 
			    from dba_data_files order by tablespace_name";
	$sth = $dbh->prepare($sqlcmd);
	$sth->execute();
	while(my ($tablespace_name,$file_id,$file_name,$filesize)=$sth->fetchrow())
	{
	    print $output_fd "tablespace_name=$tablespace_name,",
		"file_id=$file_id,",
		"file_name=$file_name,",
		"filesize=$filesize(M)\n";
	}

    print $output_fd "######\n";

	$sqlcmd="select sum(bytes) / (1024 * 1024) as free_space, tablespace_name
	from dba_free_space
	group by tablespace_name
	";
	$sth = $dbh->prepare($sqlcmd);
	$sth->execute();
	while(my ($free_space,$tablespace_name)=$sth->fetchrow())
	{
	    print $output_fd "tablespace_name=$tablespace_name,",
		"free_space=$free_space(M)\n";
	}

    print $output_fd "######\n";

	$sqlcmd="
	select username, sid, opname,
	round(sofar * 100 / totalwork, 0) || '%' as progress,
	time_remaining,
	sql_text
	from v\$session_longops, v\$sql
	where time_remaining <> 0
	and sql_address = address
	and sql_hash_value = hash_value
	";
	$sth = $dbh->prepare($sqlcmd);
	$sth->execute();
	while(my ($free_space,$tablespace_name)=$sth->fetchrow())
	{
	    print $output_fd "tablespace_name=$tablespace_name,",
		"free_space=$free_space(M)\n";
	}

    print $output_fd "######\n";

	$sqlcmd="select name, path, mode_status, state, disk_number,failgroup from v\$asm_disk";
	$sth = $dbh->prepare($sqlcmd);
	$sth->execute();
	while(my ($name,$path,$mode_status,$state,$disk_number,$failgroup)=$sth->fetchrow())
	{
	    print $output_fd "name=$name,",
		"path=$path,",
		"mode_status=$mode_status,",
		"state=$state,",
		"disk_number=$disk_number,",
		"failgroup=$failgroup\n";
	}

    print $output_fd "######\n";

	$sqlcmd="select group_number,name,TOTAL_MB, FREE_MB from v\$asm_diskgroup";
	$sth = $dbh->prepare($sqlcmd);
	$sth->execute();
	while(my ($group_number,$name,$TOTAL_MB,$FREE_MB)=$sth->fetchrow())
	{
	    print $output_fd "group_number=$group_number,",
		"name=$name,",
		"TOTAL_MB=$TOTAL_MB,",
		"FREE_MB=$FREE_MB\n";
	}

    print $output_fd "######\n";

	$sqlcmd="select name,path,total_mb,free_mb,failgroup from v\$asm_disk";
	$sth = $dbh->prepare($sqlcmd);
	$sth->execute();
	while(my ($name,$path,$total_mb,$free_mb,$failgroup)=$sth->fetchrow())
	{
	    print $output_fd "name=$name,",
		"path=$path,",
		"total_mb=$total_mb,",
		"free_mb=$free_mb,",
		"failgroup=$failgroup\n";
	}
    print $output_fd "######\n";
	$dbh->disconnect();
    open(my $outfilefd,">$output_path/$oracle_sid") or die($!);
	print $outfilefd $output;
    close $outfilefd;
    close $output_fd;
}
