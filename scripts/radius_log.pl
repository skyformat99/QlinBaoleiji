#!/usr/bin/perl
use warnings;
use strict;
use DBI;
use DBD::mysql;
use Crypt::CBC;
use MIME::Base64;

our $log_server = "118.186.17.101";

our($mysql_user,$mysql_passwd) = &get_local_mysql_config();
our $dbh=DBI->connect("DBI:mysql:database=radius;host=localhost;mysql_connect_timeout=5",$mysql_user,$mysql_passwd,{RaiseError=>1});
our $utf8 = $dbh->prepare("set names utf8");
$utf8->execute();
$utf8->finish();

open(my $fd_fr,"</var/log/mem/logtest1.log") or die $!;
foreach my $line(<$fd_fr>)
{
	chomp $line;
	my @unit_temp = split  /\|\|/,$line;
	my($log_host,$log_facility,$log_priority,$log_level,$log_tag,$log_datetime,$log_program,$log_msg);
	if(scalar @unit_temp == 8)
	{
		 ($log_host,$log_facility,$log_priority,$log_level,$log_tag,$log_datetime,$log_program,$log_msg) = @unit_temp;
	}
	else
	{
		($log_host,$log_facility,$log_priority,$log_level,$log_tag,$log_datetime,$log_program,$log_msg) = @unit_temp[0..6];
		if(defined $unit_temp[7])
		{
			$log_msg = join("||",@unit_temp[7..((scalar @unit_temp)-1)]);
		}
		else
		{
			$log_msg = undef;
		}
	}

	my $insert_cmd1 = "insert into logs(";
	my $insert_cmd2 = "values(";
	if(defined $log_host)
	{
		$insert_cmd1 .= "host,";
		$insert_cmd2 .= "'$log_host',";
	}

	if(defined $log_facility)
	{
		$insert_cmd1 .= "facility,";
		$insert_cmd2 .= "'$log_facility',";
	}

	if(defined $log_priority)
	{
		$insert_cmd1 .= "priority,";
		$insert_cmd2 .= "'$log_priority',";
	}

	if(defined $log_level)
	{
		$insert_cmd1 .= "level,";
		$insert_cmd2 .= "'$log_level',";
	}

	if(defined $log_tag)
	{
		$insert_cmd1 .= "tag,";
		$insert_cmd2 .= "'$log_tag',";
	}

	if(defined $log_datetime)
	{
		$insert_cmd1 .= "datetime,";
		$insert_cmd2 .= "'$log_datetime',";
	}

	if(defined $log_program)
	{
		$insert_cmd1 .= "program,";
		$insert_cmd2 .= "'$log_program',";
	}

	if(defined $log_msg)
	{
		$insert_cmd1 .= "msg,";
		$insert_cmd2 .= "'$log_msg',";
	}

	$insert_cmd1 .= "logserver)";
	$insert_cmd2 .= "'$log_server')";

	my $sqr_insert = $dbh->prepare("$insert_cmd1 $insert_cmd2");
	$sqr_insert->execute();
	$sqr_insert->finish();
}

$dbh->disconnect();
close $fd_fr;
open(my $fd_fw,">/var/log/mem/logtest1.log") or die $!;
close $fd_fw;  

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
