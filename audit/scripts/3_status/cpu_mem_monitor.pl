#!/usr/bin/perl
use warnings;
use strict;
use DBI;
use DBD::mysql;
use RRDs;
use POSIX qw/ceil floor/;
use Crypt::CBC;
use MIME::Base64;

our $debug = 1;
our $max_process_num = 5;
our $exist_process = 0;
our @device_info_ips;
our %device_info;

our $time_now_utc = time;
our($min,$hour,$mday,$mon,$year) = (localtime $time_now_utc)[1..5];
($min,$hour,$mday,$mon,$year) = (sprintf("%02d", $min),sprintf("%02d", $hour),sprintf("%02d", $mday),sprintf("%02d", $mon + 1
),$year+1900);
our $time_now_str = "$year$mon$mday$hour$min"."00";

our($mysql_user,$mysql_passwd) = &get_local_mysql_config();
my $dbh=DBI->connect("DBI:mysql:database=audit_sec;host=localhost;mysql_connect_timeout=5",$mysql_user,$mysql_passwd,{RaiseError=>1});

my $utf8 = $dbh->prepare("set names utf8");
$utf8->execute();
$utf8->finish();

my $sqr_select = $dbh->prepare("select device_ip,snmpkey,type,oid from device_oid");
$sqr_select->execute();
while(my $ref_select = $sqr_select->fetchrow_hashref())
{
	my $device_ip = $ref_select->{"device_ip"};
	my $snmpkey = $ref_select->{"snmpkey"};
	my $type = $ref_select->{"type"};
	my $oid  = $ref_select->{"oid"};

	unless(defined $device_info{$device_ip})
	{
		my @type_arr;
		my @tmp = ($snmpkey,\@type_arr);
		$device_info{$device_ip} = \@tmp;
	}

	my @tmp = ($type,$oid);
	push @{$device_info{$device_ip}->[1]},\@tmp;
}
$sqr_select->finish();
my $rc = $dbh->disconnect;

if(scalar keys %device_info == 0){exit 0;}
@device_info_ips = keys %device_info;
if($max_process_num > scalar @device_info_ips){$max_process_num = scalar @device_info_ips;}

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
			if($exist_process == 0)
			{  
				my $dbh=DBI->connect("DBI:mysql:database=audit_sec;host=localhost;mysql_connect_timeout=5",$mysql_user,$mysql_passwd,{RaiseError=>1});

				my $utf8 = $dbh->prepare("set names utf8");
				$utf8->execute();
				$utf8->finish();

				&set_nan_val($dbh);
				exit;
			}
		}
	}
}

sub fork_process
{   
	my $device_ip = shift @device_info_ips;
	unless(defined $device_ip){return;}
	my $pid = fork();
	if (!defined($pid))
	{   
		print "Error in fork: $!";
		exit 1;
	}

	if ($pid == 0)
	{   
		my @temp_ips = keys %device_info;
		foreach my $key(@temp_ips)
		{   
			if($device_ip ne $key)
			{   
				delete $device_info{$key};
			}
		}

		my $dbh=DBI->connect("DBI:mysql:database=audit_sec;host=localhost;mysql_connect_timeout=5",$mysql_user,$mysql_passwd,{RaiseError=>1});
		my $utf8 = $dbh->prepare("set names utf8");
		$utf8->execute();
		$utf8->finish();

		&device_process($dbh,$device_ip);
		exit 0;
	}

	++$exist_process;
}

sub device_process
{
	my($dbh,$device_ip) = @_;
	my $snmpkey = $device_info{$device_ip}->[0];
	foreach my $ref_type(@{$device_info{$device_ip}->[1]})
	{
		my $type = $ref_type->[0];
		my $oid = $ref_type->[1];
		my $val = undef;

		if($type eq "cpu")
		{
			$val = &get_cpu_value($device_ip,$snmpkey,$oid);
		}
		elsif($type eq "memory")
		{
			$val = &get_mem_value($device_ip,$snmpkey,$oid);
		}

		if(defined $val && $val =~ /^[\d\.]+$/)
		{
			&normal_insert($dbh,$device_ip,$type,$val);
			&update_rrd($dbh,$device_ip,$type,$val);
		}
	}
}

sub get_cpu_value
{
	my($device_ip,$snmpkey,$oid) = @_;
	my $sum = 0;
	my $num = 0;

	my $result = `snmpwalk -v 2c -c $snmpkey $device_ip $oid 2>&1`;
	foreach my $line(split /\n/,$result)
	{
		if($line =~ /Timeout.*No Response from/i)
		{
			if($debug == 1)
			{
				print "主机 $device_ip SNMP无法连接\n";
			}
			exit;
		}

		if($line =~ /Gauge32\s*:\s*(\d+)/i)
		{
			$sum += $1;
			++$num;
		}
	}

	my $fin_val = undef;

	if($num != 0 && $sum =~ /^[\d\.]+$/)
	{
		$fin_val = floor($sum * 100 / $num) / 100;
	}
	return $fin_val;
}

sub get_mem_value
{
	my($device_ip,$snmpkey,$oid) = @_;
	my $sum = 0;
	my $num = 0;

	my $result = `snmpwalk -v 2c -c $snmpkey $device_ip $oid 2>&1`;
	foreach my $line(split /\n/,$result)
	{
		if($line =~ /Timeout.*No Response from/i)
		{
			if($debug == 1)
			{
				print "主机 $device_ip SNMP无法连接\n";
			}
			exit;
		}

		if($line =~ /(INTEGER|Gauge32)\s*:\s*(\d+)/i)
		{
			$sum += $1;
			++$num;
		}
	}

	my $fin_val = undef;

	if($num != 0 && $sum =~ /^[\d\.]+$/)
	{
		$fin_val = floor($sum * 100 / $num) / 100;
	}
	return $fin_val;
}

sub normal_insert
{
	my($dbh,$device_ip,$type,$value) = @_;
	my $sqr_update = $dbh->prepare("update device_oid set datetime = '$time_now_str', value = $value where device_ip = '$device_ip' and type = '$type'");
	$sqr_update->execute();
	$sqr_update->finish();
}

sub update_rrd
{
	my($dbh,$device_ip,$type,$value) = @_;

	if(!defined $value || $value < 0)
	{
		$value = 'U';
	} 

	my $sqr_select = $dbh->prepare("select enable_rrd,rrdfile from device_oid where device_ip = '$device_ip' and type = '$type'");
	$sqr_select->execute();
	my $ref_select = $sqr_select->fetchrow_hashref();
	my $enable = $ref_select->{"enable_rrd"};
	my $rrdfile = $ref_select->{"rrdfile"};
	$sqr_select->finish();

	my $start_time = time;
	$start_time = (floor($start_time/300))*300;

	my $dir = "/opt/freesvr/nm/$device_ip/";
	if(! -e $dir)
	{
		mkdir $dir,0755;
	}   

	$dir = "/opt/freesvr/nm/$device_ip/device_status/";
	if(! -e $dir)
	{
		mkdir $dir,0755;
	}   

	my $file = $dir."$type.rrd";

	unless(defined $enable && $enable == 1)
	{
		unless(defined $rrdfile && -e $rrdfile && $rrdfile eq $file)
		{
			if(defined $rrdfile && -e $rrdfile)
			{
				unlink $rrdfile;
				my $sqr_update = $dbh->prepare("update device_oid set rrdfile = null where device_ip = '$device_ip' and type = '$type'");
				$sqr_update->execute();
				$sqr_update->finish();
				return;
			}
		}
	}

	if(! -e $file)
	{
		my $create_time = $start_time - 300;
		RRDs::create($file,
				'--start', "$create_time",
				'--step', '300',
				'DS:val:GAUGE:600:U:U',
				'RRA:AVERAGE:0.5:1:576',
				'RRA:AVERAGE:0.5:12:192',
				'RRA:AVERAGE:0.5:288:32',
				'RRA:MAX:0.5:1:576',
				'RRA:MAX:0.5:12:192',
				'RRA:MAX:0.5:288:32',
				'RRA:MIN:0.5:1:576',
				'RRA:MIN:0.5:12:192',
				'RRA:MIN:0.5:288:32',
				);
	}

	unless(defined $rrdfile && $rrdfile eq $file)
	{
		my $sqr_update = $dbh->prepare("update device_oid set rrdfile = '$file' where device_ip = '$device_ip' and type = '$type'");
		$sqr_update->execute();
		$sqr_update->finish();

		if(defined $rrdfile && -e $rrdfile)
		{
			unlink $rrdfile;
		}
	}

	RRDs::update(
			$file,
			'-t', 'val',
			'--', join(':', "$start_time", "$value"),
			);
}

sub set_nan_val
{
	my($dbh) = @_;

	my $sqr_select = $dbh->prepare("select device_ip,type from device_oid where datetime < '$time_now_str'");
	$sqr_select->execute();
	while(my $ref_select = $sqr_select->fetchrow_hashref())
	{
		my $device_ip = $ref_select->{"device_ip"};
		my $type = $ref_select->{"type"};

		&normal_insert($dbh,$device_ip,$type,-100);
		&update_rrd($dbh,$device_ip,$type,-100);

		if($debug == 1)
		{
			print "主机 $device_ip: $type 没有取到值\n";
		}
	}
	$sqr_select->finish();
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
