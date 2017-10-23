#!/usr/bin/perl
use warnings;
use strict;
use DBI;
use DBD::mysql;
use Crypt::CBC;
use MIME::Base64;

our($mysql_user,$mysql_passwd) = &get_local_mysql_config();
our($cmd) = @ARGV;
our $database = "ms";

unless(defined $cmd)
{
    print "usage:\n";
    print "change_db.pl [ password | setting | all ]\n";
    exit 1;
}

if($cmd eq "password")
{
    &change_passwd();
}
elsif($cmd eq "setting")
{
    &restore_setting();
}
elsif($cmd eq "all")
{
    &change_passwd();
    &restore_setting();
}
else
{
    print "usage:\n";
    print "change_db.pl [ password | setting | all ]\n";
    exit 1;
}

sub change_passwd
{
    my $dbh=DBI->connect("DBI:mysql:database=$database;host=localhost;mysql_connect_timeout=5",$mysql_user,$mysql_passwd,{RaiseError=>1});
    my $utf8 = $dbh->prepare("set names utf8");
    $utf8->execute();
    $utf8->finish();

    my $sqr_update = $dbh->prepare("update member set password=udf_encrypt('12345678') where username='admin'");
    $sqr_update->execute();
    $sqr_update->finish();

    $sqr_update = $dbh->prepare("update radcheck set value='\$1\$qY9g/6K4\$I9wfX36O3v9VprOmp56tq/' where username='admin'");
    $sqr_update->execute();
    $sqr_update->finish();

    print "change password finish\n";
}

sub restore_setting
{
    if(system("mysql $database</opt/freesvr/audit/s.sql") == 0)
    {
        print "table setting restore success\n";
    }
    else
    {
        print "table setting restore fail\n";
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
