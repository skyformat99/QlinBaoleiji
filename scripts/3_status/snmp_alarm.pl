#!/usr/bin/perl
use warnings;
use strict;
use DBI;
use DBD::mysql;
use Crypt::CBC;
use MIME::Base64;
use POSIX qw/ceil floor/;

our $max_process_num = 2;
our $exist_process = 0;

our $dbh=DBI->connect("DBI:mysql:database=audit_sec;host=localhost;mysql_connect_timeout=5",$mysql_user,$mysql_passwd,{RaiseError=>1});

our $utf8 = $dbh->prepare("set names utf8");
$utf8->execute();
$utf8->finish();

our @ref_ip_arr;
my $sqr_select = $dbh->prepare("select device_ip,type,snmpkey from snmp_servers where snmpscan=1");
$sqr_select->execute();
while(my $ref_select = $sqr_select->fetchrow_hashref())
{
	my $device_ip = $ref_select->{"device_ip"};
	my $type = $ref_select->{"type"};
	my $snmpkey = $ref_select->{"snmpkey"};

	my @host = ($device_ip,$type,$snmpkey);
	push @ref_ip_arr,\@host;
}
$sqr_select->finish();
my $rc = $dbh->disconnect;

if($max_process_num > scalar @ref_ip_arr){$max_process_num = scalar @ref_ip_arr;}
while(1)
{
	if($exist_process < $max_process_num)
	{
		&fork_process();
	}
	else
	{
		while(wait())
		{
			--$exist_process;
			&fork_process();
			if($exist_process == 0){exit;}
		}
	}
}

sub fork_process
{
	my $temp = shift @ref_ip_arr;
	unless(defined $temp){return;}
	my $pid = fork();
	if (!defined($pid))
	{
		print "Error in fork: $!";
		exit 1;
	}

	if ($pid == 0)
	{
		if($temp->[1] == 2){&linux_snmp($temp->[0],$temp->[2]);}
		elsif($temp->[1] == 4){&windows_snmp($temp->[0],$temp->[2]);}
		elsif($temp->[1] == 11){&cisco_snmp($temp->[0],$temp->[2]);}
		exit(0);
	}
	++$exist_process;
}

sub linux_snmp
{
	my($device_ip,$snmpkey) = @_;

	my $dbh=DBI->connect("DBI:mysql:database=audit_sec;host=localhost;mysql_connect_timeout=5",$mysql_user,$mysql_passwd,{RaiseError=>1});
	    
	my $utf8 = $dbh->prepare("set names utf8");
	$utf8->execute();
	$utf8->finish();

	&insert_into_nondisk($dbh,$device_ip,'cpu');
	&insert_into_nondisk($dbh,$device_ip,'memory');
	&insert_into_nondisk($dbh,$device_ip,'swap');

	my %disk_num;
	foreach(`snmpwalk -v 2c -c $snmpkey $device_ip 1.3.6.1.2.1.25.2`)
	{
		if($_ =~ /hrStorageDescr.(\d+).*STRING\s*:\s*(\/.*)$/i)
		{
			push @{$disk_num{$1}},$2;
		}
	}

	foreach(keys %disk_num)
	{
		&insert_into_disk($dbh,$device_ip,$disk_num{$_}->[0]);
	}
}

sub cisco_snmp
{
	my($device_ip,$snmpkey) = @_;

	my $dbh=DBI->connect("DBI:mysql:database=audit_sec;host=localhost;mysql_connect_timeout=5",$mysql_user,$mysql_passwd,{RaiseError=>1});
	    
	my $utf8 = $dbh->prepare("set names utf8");
	$utf8->execute();
	$utf8->finish();

	&insert_into_nondisk($dbh,$device_ip,'cpu');
	&insert_into_nondisk($dbh,$device_ip,'memory');
}

sub windows_snmp
{
	my($device_ip,$snmpkey) = @_;

	my $dbh=DBI->connect("DBI:mysql:database=audit_sec;host=localhost;mysql_connect_timeout=5",$mysql_user,$mysql_passwd,{RaiseError=>1});

	my $utf8 = $dbh->prepare("set names utf8");
	$utf8->execute();
	$utf8->finish();

	&insert_into_nondisk($dbh,$device_ip,'cpu');
	&insert_into_nondisk($dbh,$device_ip,'memory');
	&insert_into_nondisk($dbh,$device_ip,'swap');

	my %disk_num;
	foreach(`snmpwalk -v 2c -c $snmpkey $device_ip .1.3.6.1.2.1.25.2`)
	{
		if($_ =~ /hrStorageDescr\.(\d+).*STRING\s*:\s*(\S+)\s*Label/i)
		{
			push @{$disk_num{$1}},$2;
		}
	}

	foreach(keys %disk_num)
	{
		&insert_into_disk($dbh,$device_ip,$disk_num{$_}->[0]);
	}
}

sub insert_into_nondisk
{
	my($dbh,$device_ip,$type) = @_;
	my $sqr_select_count = $dbh->prepare("select count(*) from snmp_alarm where device_ip = '$device_ip' and type = '$type'");
	$sqr_select_count->execute();
	my $ref_select_count = $sqr_select_count->fetchrow_hashref();
	my $count = $ref_select_count->{"count(*)"};
	$sqr_select_count->finish();

	if($count == 0)
	{
		my $sqr_insert = $dbh->prepare("insert into snmp_alarm (device_ip,type) values ('$device_ip','$type')");
		$sqr_insert->execute();
		$sqr_insert->finish();
	}

}

sub insert_into_disk
{
	my($dbh,$device_ip,$disk) = @_;
	my $sqr_select_count = $dbh->prepare("select count(*) from snmp_alarm where device_ip = '$device_ip' and type = 'disk' and disk = '$disk'");
	$sqr_select_count->execute();
	my $ref_select_count = $sqr_select_count->fetchrow_hashref();
	my $count = $ref_select_count->{"count(*)"};
	$sqr_select_count->finish();

	if($count == 0)
	{
		my $sqr_insert = $dbh->prepare("insert into snmp_alarm (device_ip,type,disk) values ('$device_ip','disk','$disk')");
		$sqr_insert->execute();
		$sqr_insert->finish();
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
