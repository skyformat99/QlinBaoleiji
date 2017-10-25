#!/usr/bin/perl
use warnings;
use strict;
use DBI;
use DBD::mysql;
use Crypt::CBC;
use MIME::Base64;

my $ip_ARGV = $ARGV[0];
unless(defined $ip_ARGV)
{
    &log_process(undef, "need an arg, like 172.16.210.0/24");
    exit 1;
}

our $time_now_utc = time;
my($min,$hour,$mday,$mon,$year) = (localtime $time_now_utc)[1..5];
($min,$hour,$mday,$mon,$year) = (sprintf("%02d", $min),sprintf("%02d", $hour),sprintf("%02d", $mday),sprintf("%02d", $mon + 1),$year+1900);
our $time_now_str = "$year$mon$mday$hour$min"."00";
our $date_today = "$year-$mon-$mday";

our($mysql_user,$mysql_passwd) = &get_local_mysql_config();
our $dbh=DBI->connect("DBI:mysql:database=audit_sec;host=localhost;mysql_connect_timeout=5",$mysql_user,$mysql_passwd,{RaiseError=>1});
our $utf8 = $dbh->prepare("set names utf8");
$utf8->execute();
$utf8->finish();

#my $cmd = "/usr/bin/nmap -O 172.16.210.0/24";
my $cmd = "/usr/local/bin/nmap -O $ip_ARGV";
my @output = split /\n/,`$cmd`;

my @cache_str;

foreach my $line(@output)
{
    chomp $line;
    if($line =~ /^$/)
    {
        my $device_ip;
        my $device_type = 0;
        my $flag = 0;
        foreach my $str(@cache_str)
        {
#            print $str,"\n";
            if($str =~ /^Nmap\s*scan\s*report/i)
            {
                $device_ip = (split /\s+/,$str)[-1];
                $device_ip =~ s/\(//g;
                $device_ip =~ s/\)//g;
            }
            elsif($flag == 0 && $str =~ /^Running/i)
            {
                $device_type = &match($str);
                $flag = 1;
            }
            elsif($flag == 0 && $str =~ /^OS\s*details/i)
            {
                $device_type = &match($str);
                $flag = 1;
            }
        }
        @cache_str = ();

        if(defined $device_ip)
        {
            my $sqr_insert = $dbh->prepare("replace into servers_nmap(ip,device_type) values('$device_ip',$device_type)");
            $sqr_insert->execute();
            $sqr_insert->finish();
        }
    }
    else
    {
        push @cache_str,$line;
    }
}

sub match
{
    my($str) = @_;
    my @types;
    if($str =~ /Linux/i)
    {
        push @types,2;
    }
    if($str =~ /windows/i)
    {
        push @types,4;
    }
    if($str =~ /AIX/i)
    {
        push @types,9;
    }
    if($str =~ /HP-UX/i)
    {
        push @types,10;
    }
    if($str =~ /cisco/i)
    {
        push @types,11;
    }
    if($str =~ /HuaWei/i)
    {
        push @types,12;
    }
    if($str =~ /Solaris/i)
    {
        push @types,13;
    }
    if($str =~ /Netscreen/i)
    {
        push @types,15;
    }
    if($str =~ /AS400/i)
    {
        push @types,19;
    }
    if($str =~ /H3C/i)
    {
        push @types,27;
    }
    if($str =~ /Humber/i)
    {
        push @types,28;
    }

    if(scalar @types != 1)
    {
        return 0;
    }
    else
    {
        return $types[0];
    }
}

sub log_process
{
    my($device_ip,$msg) = @_;
    print "$msg\n";
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
