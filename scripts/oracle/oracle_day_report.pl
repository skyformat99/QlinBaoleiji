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

our $time_now_utc = time;
my($min,$hour,$mday,$mon,$year) = (localtime $time_now_utc)[1..5];
$min = $hour = 0;

$time_now_utc = timelocal(0,$min,$hour,$mday,$mon,$year);
($min,$hour,$mday,$mon,$year) = (sprintf("%02d", $min),sprintf("%02d", $hour),sprintf("%02d", $mday),sprintf("%02d", $mon + 1),$year+1900);
our $time_now_str = "$year$mon$mday$hour$min"."00";
our $date_now_str = "$year$mon$mday";

our $fetch_interval = '1day';
    
our($mysql_user,$mysql_passwd) = &get_local_mysql_config();
my $dbh=DBI->connect("DBI:mysql:database=audit_sec;host=localhost;mysql_connect_timeout=5",$mysql_user,$mysql_passwd,{RaiseError=>1});
my $utf8 = $dbh->prepare("set names utf8");
$utf8->execute();
$utf8->finish();

my $sqr_select = $dbh->prepare("select oracle_ip,tablespace_name,file_id,file_name,rrdfile from oracle_tablespace where rrdfile != '' and rrdfile is not null");
$sqr_select->execute();
while(my $ref_select = $sqr_select->fetchrow_hashref())
{       
    my $oracle_ip = $ref_select->{"oracle_ip"};
    my $tablespace_name = $ref_select->{"tablespace_name"};
    my $file_id = $ref_select->{"file_id"};
    my $file_name = $ref_select->{"file_name"};
    my $rrdfile = $ref_select->{"rrdfile"};

    unless(-e $rrdfile){next;}

    my @tmp = ($oracle_ip,'tablespace',$tablespace_name,$file_id,$file_name,$rrdfile);
    push @ref_ip_arr,\@tmp;
}
$sqr_select->finish();

$sqr_select = $dbh->prepare("select oracle_ip,diskgroup_id,diskgroup_name,rrdfile from oracle_diskgroup where rrdfile != '' and rrdfile is not null");
$sqr_select->execute();
while(my $ref_select = $sqr_select->fetchrow_hashref())
{       
    my $oracle_ip = $ref_select->{"oracle_ip"};
    my $diskgroup_id = $ref_select->{"diskgroup_id"};
    my $diskgroup_name = $ref_select->{"diskgroup_name"};
    my $rrdfile = $ref_select->{"rrdfile"};

    unless(-e $rrdfile){next;}

    my @tmp = ($oracle_ip,'diskgroup',$diskgroup_id,$diskgroup_name,$rrdfile);
    push @ref_ip_arr,\@tmp;
}
$sqr_select->finish();

$sqr_select = $dbh->prepare("select oracle_ip,disk_name,disk_path,rrdfile from oracle_disk where rrdfile != '' and rrdfile is not null");
$sqr_select->execute();
while(my $ref_select = $sqr_select->fetchrow_hashref())
{       
    my $oracle_ip = $ref_select->{"oracle_ip"};
    my $disk_name = $ref_select->{"disk_name"};
    my $disk_path = $ref_select->{"disk_path"};
    my $rrdfile = $ref_select->{"rrdfile"};

    unless(-e $rrdfile){next;}

    my @tmp = ($oracle_ip,'disk',$disk_name,$disk_path,$rrdfile);
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
        my $oracle_ip = $temp->[0];
        my $type = $temp->[1];
        my $rrdfile = $temp->[-1];

        my $dbh=DBI->connect("DBI:mysql:database=audit_sec;host=localhost;mysql_connect_timeout=5",$mysql_user,$mysql_passwd,{RaiseError=>1});
        my $utf8 = $dbh->prepare("set names utf8");
        $utf8->execute();
        $utf8->finish();

        my @results = &rrd_fetch($rrdfile,'val');
        &insert_table($dbh,$oracle_ip,$type,$temp,@results);
        exit 0;
    }
    ++$exist_process;
}

sub rrd_fetch
{
    my($rrdfile,$name) = @_;

    my ($start,$step,$ds_names,$data) = RRDs::fetch($rrdfile, "AVERAGE", "-s", "$time_now_utc-$fetch_interval", "-e", "$time_now_utc");

    my $pos = 0;
    foreach my $tmp_name(@$ds_names)
    {
        if($tmp_name eq $name)
        {
            last;
        }
        ++$pos;
    }

    my $nan_num = 0;
    my $sum = 0;
    my $val_num = 0;

    foreach my $line(@$data)
    {
        if(defined $line->[$pos])
        {
            $sum += $line->[$pos];
            ++$val_num;
        }
        else
        {
            ++$nan_num;
        }
    }

    --$nan_num;

    my $avg;
    if($val_num != 0)
    {
        $avg = $sum / $val_num;
    }

    ($start,$step,$ds_names,$data) = RRDs::fetch($rrdfile, "MAX", "-s", "$time_now_utc-$fetch_interval", "-e", "$time_now_utc");

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

    ($start,$step,$ds_names,$data) = RRDs::fetch($rrdfile, "MIN", "-s", "$time_now_utc-$fetch_interval", "-e", "$time_now_utc");

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
    return ($avg,$max,$min,$nan_num);
}

sub insert_table
{
    my($dbh,$oracle_ip,$type,$ref,$avg,$max,$min,$nan_num) = @_;

    unless(defined $avg){$avg = -1;}
    unless(defined $max){$max = -1;}
    unless(defined $min){$min = -1;}

    $avg = sprintf("%.2f", $avg);
    $max = sprintf("%.2f", $max);
    $min = sprintf("%.2f", $min);

    my $cmd;
    if($type eq "tablespace")
    {
        my $tablespace_name = $ref->[2];
        my $file_id = $ref->[3];
        my $file_name = $ref->[4];
        $cmd = "insert into oracle_tablespace_day_report(oracle_ip,date,tablespace_name,file_id,file_name,avg_free,noval) values('$oracle_ip','$date_now_str','$tablespace_name',$file_id,'$file_name',$avg,$nan_num)";
    }
    elsif($type eq "diskgroup")
    {
        my $diskgroup_id = $ref->[2];
        my $diskgroup_name = $ref->[3];
        $cmd = "insert into oracle_diskgroup_day_report(oracle_ip,date,diskgroup_id,diskgroup_name,avg_free,noval) values('$oracle_ip','$date_now_str',$diskgroup_id,'$diskgroup_name',$avg,$nan_num)";
    }
    elsif($type eq "disk")
    {
        my $disk_name = $ref->[2];
        my $disk_path = $ref->[3];
        $cmd = "insert into oracle_disk_day_report(oracle_ip,date,disk_name,disk_path,avg_free,noval) values('$oracle_ip','$date_now_str','$disk_name','$disk_path',$avg,$nan_num)";
    }

    my $sqr_insert = $dbh->prepare("$cmd");
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
