#!/usr/bin/perl
use warnings;
use strict;
use DBI;
use DBD::mysql;
use Crypt::CBC;
use MIME::Base64;

our $user = "admin";
our $passwd = "12345678";

our($mysql_user,$mysql_passwd) = &get_local_mysql_config();
our $dbh=DBI->connect("DBI:mysql:database=audit_sec;host=localhost;mysql_connect_timeout=120",$mysql_user,$mysql_passwd,{RaiseError=>1});
our $utf8 = $dbh->prepare("set names utf8");
$utf8->execute();
$utf8->finish();

my $sqr_select = $dbh->prepare("select count(*) count from setting where sname='RdpToLocal'");
$sqr_select->execute();
my $ref_select = $sqr_select->fetchrow_hashref();
my $count = $ref_select->{"count"};
$sqr_select->finish();

if($count == 0)
{
    my $sqr_insert = $dbh->prepare("insert into setting(sname,svalue) values('RdpToLocal',1)");
    $sqr_insert->execute();
    $sqr_insert->finish();
}

our $file_radius = 1;   # 1 means radius
our %master;
our %slave;

&read_conf();
unless(defined $master{"ip"} && defined $master{"port"} && defined $master{"secret"}
    && defined $slave{"ip"} && defined $slave{"port"} && defined $slave{"secret"})
{
    print "freesvr_authd_config error\n";
    exit 1;
}

if(&test_connection(\%master)==0 && &test_connection(\%slave)==0)
{
#   ------------local------------
    my $sqr_update = $dbh->prepare("update setting set svalue=1 where sname='RdpToLocal'");
    $sqr_update->execute();
    $sqr_update->finish();

    if($file_radius == 1)
    {
        &file_to_local();
    }
}
else
{
#   ------------radius------------
    my $sqr_update = $dbh->prepare("update setting set svalue=0 where sname='RdpToLocal'");
    $sqr_update->execute();
    $sqr_update->finish();

    if($file_radius == 1)
    {
        &file_to_radius();
    }
}

sub file_to_radius
{
    my @cache;
    my %hash_cache;

    open(my $fd_fr, "</opt/freesvr/audit/authd/etc/freesvr_authd_config");
    while(my $line = <$fd_fr>)
    {
        chomp $line;
        if($line =~ /MasterRadiusServerAddress/i)
        {
            if(!exists $hash_cache{"ip"})
            {
                $line =~ s/^#//;
            }
            else
            {
                $line = "#".$line;
            }
            $hash_cache{"ip"} = 1;
        }
        elsif($line =~ /MasterRadiusServerPort/i)
        {
            if(!exists $hash_cache{"port"})
            {
                $line =~ s/^#//;
            }
            else
            {
                $line = "#".$line;
            }
            $hash_cache{"port"} = 1;
        }
        elsif($line =~ /MasterRadiusServerSecret/i)
        {
            if(!exists $hash_cache{"secret"})
            {
                $line =~ s/^#//;
            }
            else
            {
                $line = "#".$line;
            }
            $hash_cache{"secret"} = 1;
        }
        push @cache,$line;
    }
    close $fd_fr;

    open(my $fd_fw, ">/tmp/freesvr_authd_config");
    foreach my $line(@cache)
    {
        print $fd_fw $line,"\n";
    }
    close $fd_fw;
    rename("/tmp/freesvr_authd_config","/opt/freesvr/audit/authd/etc/freesvr_authd_config");
}

sub file_to_local
{
    my @cache;
    my %hash_cache;

    open(my $fd_fr, "</opt/freesvr/audit/authd/etc/freesvr_authd_config");
    while(my $line = <$fd_fr>)
    {
        chomp $line;
        if($line =~ /MasterRadiusServerAddress/i)
        {
            if(exists $hash_cache{"ip"})
            {
                $line =~ s/^#//;
            }
            else
            {
                $line = "#".$line;
            }
            $hash_cache{"ip"} = 1;
        }
        elsif($line =~ /MasterRadiusServerPort/i)
        {
            if(exists $hash_cache{"port"})
            {
                $line =~ s/^#//;
            }
            else
            {
                $line = "#".$line;
            }
            $hash_cache{"port"} = 1;
        }
        elsif($line =~ /MasterRadiusServerSecret/i)
        {
            if(exists $hash_cache{"secret"})
            {
                $line =~ s/^#//;
            }
            else
            {
                $line = "#".$line;
            }
            $hash_cache{"secret"} = 1;
        }
        push @cache,$line;
    }
    close $fd_fr;

    open(my $fd_fw, ">/tmp/freesvr_authd_config");
    foreach my $line(@cache)
    {
        print $fd_fw $line,"\n";
    }
    close $fd_fw;
    rename("/tmp/freesvr_authd_config","/opt/freesvr/audit/authd/etc/freesvr_authd_config");
}

sub test_connection
{
    my($ref) = @_;
    my $str = `/opt/freesvr/auth/bin/radtest $user $passwd $ref->{"ip"}\:$ref->{"port"} 1 $ref->{"secret"}`;

    foreach my $line(split /\n/,$str)
    {
        if($line =~ /^rad_recv:\s*(\S+)\s*packet/)
        {
            if($1 eq "Access-Accept")
            {
                return 1;
            }
            else
            {
                return 0;
            }
        }
    }
}

sub read_conf
{
    open(my $fd_fr, "</opt/freesvr/audit/authd/etc/freesvr_authd_config");
    while(my $line = <$fd_fr>)
    {
        chomp $line;
        if($line =~ /MasterRadiusServerAddress/i && !exists $master{"ip"})
        {
            $master{"ip"} = (split /\s+/,$line)[1];
            if($line =~ /^\#/)
            {
                $file_radius = 0;
            }
        }
        elsif($line =~ /MasterRadiusServerPort/i && !exists $master{"port"})
        {
            $master{"port"} = (split /\s+/,$line)[1];
        }
        elsif($line =~ /MasterRadiusServerSecret/i && !exists $master{"secret"})
        {
            $master{"secret"} = (split /\s+/,$line)[1];
        }
        elsif($line =~ /SlaveRadiusServerAddress/i && !exists $slave{"ip"})
        {
            $slave{"ip"} = (split /\s+/,$line)[1];
        }
        elsif($line =~ /SlaveRadiusServerPort/i && !exists $slave{"port"})
        {
            $slave{"port"} = (split /\s+/,$line)[1];
        }
        elsif($line =~ /SlaveRadiusServerSecret/i && !exists $slave{"secret"})
        {
            $slave{"secret"} = (split /\s+/,$line)[1];
        }
    }
    close $fd_fr;
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
