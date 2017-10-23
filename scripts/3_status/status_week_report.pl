#!/usr/bin/perl
use warnings;
use strict;
use Time::Local;
use DBI;
use DBD::mysql;
use RRDs;
use Crypt::CBC;
use MIME::Base64;
use POSIX qw/ceil floor/;

our @ref_ip_arr;
our $max_process_num = 5;
our $exist_process = 0;
our $process_time = 120; 

our $time_now_utc = time;
my($min,$hour,$mday,$mon,$year) = (localtime $time_now_utc)[1..5];
$min = $hour = 0;

$time_now_utc = timelocal(0,$min,$hour,$mday,$mon,$year);
($min,$hour,$mday,$mon,$year) = (sprintf("%02d", $min),sprintf("%02d", $hour),sprintf("%02d", $mday),sprintf("%02d", $mon + 1),$year+1900);
our $time_now_str = "$year$mon$mday$hour$min"."00";

our $fetch_interval = '1week';

our($mysql_user,$mysql_passwd) = &get_local_mysql_config();
my $dbh=DBI->connect("DBI:mysql:database=audit_sec;host=localhost;mysql_connect_timeout=5",$mysql_user,$mysql_passwd,{RaiseError=>1});

my $utf8 = $dbh->prepare("set names utf8");
$utf8->execute();
$utf8->finish();

my $sqr_select = $dbh->prepare("select device_ip,type,disk,rrdfile from snmp_status where rrdfile != '' and rrdfile is not null");
$sqr_select->execute();
while(my $ref_select = $sqr_select->fetchrow_hashref())
{
	my $device_ip = $ref_select->{"device_ip"};
	my $type = $ref_select->{"type"};
	my $disk = $ref_select->{"disk"};
	my $rrdfile = $ref_select->{"rrdfile"};

	unless(-e $rrdfile){next;}

	my @tmp = ($device_ip,$type,$disk,$rrdfile);
	push @ref_ip_arr,\@tmp;
}
$sqr_select->finish();
my $rc = $dbh->disconnect;

if(scalar @ref_ip_arr == 0) {exit;}

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
			if($exist_process == 0)
			{
				exit;
			}
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
		$SIG{ALRM}=\&alarm_process;
		my $dbh=DBI->connect("DBI:mysql:database=audit_sec;host=localhost;mysql_connect_timeout=5",$mysql_user,$mysql_passwd,{RaiseError=>1});

		my $utf8 = $dbh->prepare("set names utf8");
		$utf8->execute();
		$utf8->finish();

		if($temp->[1] eq 'cpu')
		{
			my @results = &rrd_fetch($temp->[3],'val');
			&insert_table($dbh,$temp->[0],undef,'snmp_week_report_cpu',@results);
		}
		elsif($temp->[1] eq 'memory')
		{
			my @results = &rrd_fetch($temp->[3],'val');
			&insert_table($dbh,$temp->[0],undef,'snmp_week_report_memory',@results);
		}
		elsif($temp->[1] eq 'swap')
		{
			my @results = &rrd_fetch($temp->[3],'val');
			&insert_table($dbh,$temp->[0],undef,'snmp_week_report_swap',@results);
		}
		elsif($temp->[1] eq 'disk')
		{
			my @results = &rrd_fetch($temp->[3],'val');
			&insert_table($dbh,$temp->[0],$temp->[2],'snmp_week_report_disk',@results);
		}


		exit 0;
	}
	++$exist_process;
}

sub rrd_fetch
{
	my($rrd_file,$name) = @_;

	my ($start,$step,$ds_names,$data) = RRDs::fetch($rrd_file, "AVERAGE", "-s", "$time_now_utc-$fetch_interval", "-e", "$time_now_utc");

	my $pos = 0;
	foreach my $tmp_name(@$ds_names)
	{
		if($tmp_name eq $name)
		{
			last;
		}
		++$pos;
	}

	my $sum = 0;
	my $val_num = 0;

	foreach my $line(@$data)
	{
		if(defined $line->[$pos])
		{
			$sum += $line->[$pos];
			++$val_num;
		}
	}


	my $avg;
	if($val_num != 0)
	{
		$avg = $sum / $val_num;
	}

	($start,$step,$ds_names,$data) = RRDs::fetch($rrd_file, "MAX", "-s", "$time_now_utc-$fetch_interval", "-e", "$time_now_utc");

	my $max;
	foreach my $line(@$data)
	{
		if(defined $line->[$pos])
		{
			if(defined $max && $max < $line->[$pos])
			{
				$max = $line->[$pos];;
			}
			elsif(!defined $max)
			{
				$max = $line->[$pos];
			}
		}
	}

	($start,$step,$ds_names,$data) = RRDs::fetch($rrd_file, "MIN", "-s", "$time_now_utc-$fetch_interval", "-e", "$time_now_utc");

	my $min;
	foreach my $line(@$data)
	{
		if(defined $line->[$pos])
		{
			if(defined $min && $min > $line->[$pos])
			{
				$min = $line->[$pos];;
			}
			elsif(!defined $min)
			{
				$min = $line->[$pos];
			}
		}
	}
	return ($avg,$max,$min);
}

sub insert_table
{
	my($dbh,$device_ip,$disk,$table_name,$avg,$max,$min) = @_;

	unless(defined $avg){$avg = -1;}
	unless(defined $max){$max = -1;}
	unless(defined $min){$min = -1;}

	$avg = sprintf("%.2f", $avg);
	$max = sprintf("%.2f", $max);
	$min = sprintf("%.2f", $min);

	my $select_table = $table_name;
	$select_table =~ s/week/day/g;

	my $sqr_select;
	unless(defined $disk)
	{
		$sqr_select = $dbh->prepare("select sum(novalue) from $select_table where device_ip = '$device_ip' and datetime >= now()-interval 1 week and datetime < now()");
	}
	else
	{
		$sqr_select = $dbh->prepare("select sum(novalue) from $select_table where device_ip = '$device_ip' and disk = '$disk' and datetime >= now()-interval 1 week and datetime < now()");
	}
	$sqr_select->execute();
	my $ref_select = $sqr_select->fetchrow_hashref();
	my $nan_num = $ref_select->{"sum(novalue)"};
	$sqr_select->finish();

	unless(defined $nan_num)
	{
		$nan_num = -1;
	}

	my $sqr_insert;
	unless(defined $disk)
	{
		$sqr_insert = $dbh->prepare("insert into $table_name(device_ip,datetime,avg_val,high_val,low_val,novalue) values('$device_ip','$time_now_str',$avg,$max,$min,$nan_num)");
	}
	else
	{
		$sqr_insert = $dbh->prepare("insert into $table_name(device_ip,datetime,disk,avg_val,high_val,low_val,novalue) values('$device_ip','$time_now_str','$disk',$avg,$max,$min,$nan_num)");
	}
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
