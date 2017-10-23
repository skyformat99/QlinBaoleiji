#!/usr/bin/perl
use warnings;
use strict;
use DBI;
use DBD::mysql;
use Crypt::CBC;
use MIME::Base64;

our %device_info;
our %device_exist;

our($mysql_user,$mysql_passwd) = &get_local_mysql_config();
my $dbh=DBI->connect("DBI:mysql:database=audit_sec;host=localhost;mysql_connect_timeout=5",$mysql_user,$mysql_passwd,{RaiseError=>1});
            
my $utf8 = $dbh->prepare("set names utf8");
$utf8->execute();
$utf8->finish();

my($device_ip,$snmpkey) = @ARGV;
unless(defined $device_ip)
{
	print "need ip\n";
	exit;
}

unless(defined $snmpkey)
{
	print "need snmpkey\n";
	exit;
}

my $result = `snmpwalk -v 2c -c $snmpkey $device_ip SNMPv2-MIB::sysDescr.0 2>&1`;
foreach my $line(split /\r*\n/,$result)
{
	if($line =~ /sysDescr\.0/i && $line =~ /STRING\s*:\s*(.*)$/i)
	{
		my $snmp_desc = $1;

		my $sqr_select = $dbh->prepare("select count(*) from servers where device_ip = '$device_ip' and snmpkey = '$snmpkey'");
		$sqr_select->execute();
		my $ref_select = $sqr_select->fetchrow_hashref();
		my $ip_num = $ref_select->{"count(*)"};
		$sqr_select->finish();

		if($ip_num == 0)
		{
			my $sqr_insert = $dbh->prepare("insert into servers (device_ip,snmpkey,snmpdesc) values ('$device_ip','$snmpkey','$snmp_desc')");
			$sqr_insert->execute();
			$sqr_insert->finish();
		}
		else
		{
			my $sqr_update = $dbh->prepare("update servers set snmpdesc = '$snmp_desc' where device_ip = '$device_ip' and snmpkey = '$snmpkey'");
			$sqr_update->execute();
			$sqr_update->finish();
		}
	}
}

$result = `snmpwalk -v 2c -c $snmpkey $device_ip DISMAN-EVENT-MIB::sysUpTimeInstance 2>&1`;
foreach my $line(split /\r*\n/,$result)
{
	if($line =~ /sysUpTimeInstance/i && $line =~ /Timeticks\s*:\s*\((\d+)\)/i)
	{
		my $sys_start_time = $1;

		my $sqr_select = $dbh->prepare("select count(*) from servers where device_ip = '$device_ip' and snmpkey = '$snmpkey'");
		$sqr_select->execute();
		my $ref_select = $sqr_select->fetchrow_hashref();
		my $ip_num = $ref_select->{"count(*)"};
		$sqr_select->finish();

		if($ip_num == 0)
		{
			my $sqr_insert = $dbh->prepare("insert into servers (device_ip,snmpkey,snmptime) values ('$device_ip','$snmpkey',$sys_start_time)");
			$sqr_insert->execute();
			$sqr_insert->finish();
		}
		else
		{
			my $sqr_update = $dbh->prepare("update servers set snmptime = $sys_start_time where device_ip = '$device_ip' and snmpkey = '$snmpkey'");
			$sqr_update->execute();
			$sqr_update->finish();
		}
	}
}

my $sqr_select = $dbh->prepare("select port_index,port_describe,port_type,port_speed,normal_status,enable from snmp_interface where device_ip = '$device_ip'");
$sqr_select->execute();
while(my $ref_select = $sqr_select->fetchrow_hashref())
{
	my $port = $ref_select->{"port_index"};
	my $port_describe = $ref_select->{"port_describe"};
	my $port_type = $ref_select->{"port_type"};
	my $port_speed = $ref_select->{"port_speed"};
	my $normal_status = $ref_select->{"normal_status"};
	my $enable = $ref_select->{"enable"};
	unless(defined $device_exist{$port})
	{
		my @tmp = ($port_describe,$port_type,$port_speed,$normal_status,$enable);
		$device_exist{$port} = \@tmp;
	}
}
$sqr_select->finish();

my $context = `snmpwalk  -v 2c -c $snmpkey $device_ip ifIndex`;
foreach my $line(split /\n/,$context)
{
	if($line =~ /INTEGER\s*:*\s*(\d+)/i)
	{
		my $index_num = $1;
		unless(exists $device_info{$index_num})
		{
			my @temp;
			$device_info{$index_num} = \@temp;
		}
	}
}

$context = `snmpwalk  -v 2c -c $snmpkey $device_ip ifDescr`;
foreach my $line(split /\n/,$context)
{
	if($line =~ /ifDescr\D*(\d+).*STRING\s*:*\s*(.+)$/i)
	{
		my $index_num = $1;
		my $port_describe = $2;
		if(exists $device_info{$index_num})
		{
			push @{$device_info{$index_num}}, $port_describe;
		}
	}
}

$context = `snmpwalk  -v 2c -c $snmpkey $device_ip ifType`;
foreach my $line(split /\n/,$context)
{
	if($line =~ /ifType\D*(\d+).*INTEGER\s*:*\s*(.+)$/i)
	{
		my $index_num = $1;
		my $port_type = $2;
		$port_type =~ s/\(.*\)//;
		if(exists $device_info{$index_num})
		{
			push @{$device_info{$index_num}}, $port_type;
		}
	}
}

$context = `snmpwalk  -v 2c -c $snmpkey $device_ip ifSpeed`;
foreach my $line(split /\n/,$context)
{
	if($line =~ /ifSpeed\D*(\d+).*Gauge32\s*:*\s*(\d+)$/i)
	{
		my $index_num = $1;
		my $port_speed = $2;
		if(exists $device_info{$index_num})
		{
			push @{$device_info{$index_num}}, $port_speed;
		}
	}
}

$context = `snmpwalk  -v 2c -c $snmpkey $device_ip ifOperStatus`;
foreach my $line(split /\n/,$context)
{
	if($line =~ /ifOperStatus\D*(\d+).*INTEGER\s*:*\s*(.+)$/i)
	{
		my $index_num = $1;
		my $port_status = $2;
		$port_status =~ s/\(.*\)//;
		if(exists $device_info{$index_num})
		{
			push @{$device_info{$index_num}}, $port_status;
		}
	}
}

foreach my $key(keys %device_info)
{
	if(exists $device_exist{$key})
	{
		if($device_exist{$key}->[0] eq $device_info{$key}->[0] && $device_exist{$key}->[1] eq $device_info{$key}->[1] && $device_exist{$key}->[2] == $device_info{$key}->[2] && $device_exist{$key}->[3] eq $device_info{$key}->[3] && $device_exist{$key}->[4] == 1)
		{
			delete $device_exist{$key};
		}
		else
		{
			delete $device_exist{$key};
			my $sqr_update = $dbh->prepare("update snmp_interface set port_describe = '$device_info{$key}->[0]', port_type = '$device_info{$key}->[1]', port_speed = $device_info{$key}->[2], normal_status = '$device_info{$key}->[3]', cur_status = '$device_info{$key}->[3]', enable =1 where device_ip = '$device_ip' and port_index = $key"); 
			$sqr_update->execute();
			$sqr_update->finish();
		}
	}
	else
	{
		my $sqr_insert = $dbh->prepare("insert into snmp_interface (device_ip,port_index,port_describe,port_type,port_speed,normal_status,cur_status) values ('$device_ip',$key,'$device_info{$key}->[0]','$device_info{$key}->[1]',$device_info{$key}->[2],'$device_info{$key}->[3]','$device_info{$key}->[3]')"); 
		$sqr_insert->execute();
		$sqr_insert->finish();
	}
}

foreach my $key(keys %device_exist)
{
	my $sqr_update = $dbh->prepare("update snmp_interface set enable = 0 where device_ip = '$device_ip' and port_index = $key"); 
	$sqr_update->execute();
	$sqr_update->finish();
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
