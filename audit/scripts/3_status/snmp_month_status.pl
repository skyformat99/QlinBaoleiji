#!/usr/bin/perl
use warnings;
use strict;
use DBI;
use DBD::mysql;
use Crypt::CBC;
use MIME::Base64;

our %device_value;

our($mysql_user,$mysql_passwd) = &get_local_mysql_config();
our $dbh=DBI->connect("DBI:mysql:database=audit_sec;host=localhost;mysql_connect_timeout=5",$mysql_user,$mysql_passwd,{RaiseError=>1});

our $sqr_select = $dbh->prepare("select * from snmp_day_status where date >= now()-interval 1 month and date < now()");
$sqr_select->execute();
while(my $ref_select = $sqr_select->fetchrow_hashref())
{
	my $device_ip = $ref_select->{"device_ip"};
	my $date = $ref_select->{"date"};
	my $type = $ref_select->{"type"};
	my $avg_value = $ref_select->{"avg_value"};
	my $max_value = $ref_select->{"max_value"};
	my $disk = $ref_select->{"disk"};

	$date =~ s/-//g;

	if(defined $disk)
	{
		unless(exists $device_value{"$device_ip,$type,$disk"})
		{
			push @{$device_value{"$device_ip,$type,$disk"}},$date,$avg_value,$max_value,1;
		}
		else
		{
			if($device_value{"$device_ip,$type,$disk"}->[0] > $date){$device_value{"$device_ip,$type,$disk"}->[0] = $date;}
			if($device_value{"$device_ip,$type,$disk"}->[2] < $max_value){$device_value{"$device_ip,$type,$disk"}->[2] = $max_value;}
			$device_value{"$device_ip,$type,$disk"}->[1] += $avg_value;
			++$device_value{"$device_ip,$type,$disk"}->[3];
		}
	}
	else
	{
		unless(exists $device_value{"$device_ip,$type"})
		{
			push @{$device_value{"$device_ip,$type"}},$date,$avg_value,$max_value,1;
		}
		else
		{
			if($device_value{"$device_ip,$type"}->[0] > $date){$device_value{"$device_ip,$type,$disk"}->[0] = $date;}
			if($device_value{"$device_ip,$type"}->[2] < $max_value){$device_value{"$device_ip,$type,$disk"}->[2] = $max_value;}
			$device_value{"$device_ip,$type"}->[1] += $avg_value;
			++$device_value{"$device_ip,$type"}->[3];

		}
	}
}
$sqr_select->finish();

foreach my $key(keys %device_value)
{
	my @device_info = split /,/,$key;
	my $device_ip = $device_info[0];
	my $type = $device_info[1];
	my $disk;
	if($type eq 'disk'){$disk = $device_info[2];}

	my $date_start = $device_value{"$key"}->[0];
	my $avg_value = $device_value{"$key"}->[1]/$device_value{"$key"}->[3];
	my $max_value = $device_value{"$key"}->[2];

	if($type eq 'disk')
	{
		my $sqr_insert = $dbh->prepare("insert into snmp_month_status (device_ip,date_start,date_end,type,avg_value,max_value,disk) values ('$device_ip','$date_start',(CURDATE()-interval 1 day),'$type',$avg_value,$max_value,'$disk')");
		$sqr_insert->execute();
		$sqr_insert->finish();
	}
	else
	{
		my $sqr_insert = $dbh->prepare("insert into snmp_month_status (device_ip,date_start,date_end,type,avg_value,max_value) values ('$device_ip','$date_start',(CURDATE()-interval 1 day),'$type',$avg_value,$max_value)");
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
