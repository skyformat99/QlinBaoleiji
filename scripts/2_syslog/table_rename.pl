#!/usr/bin/perl
use strict;
use warnings;
use DBI;
use DBD::mysql;
use Crypt::CBC;
use MIME::Base64;

our %table_names;

our($sec,$min,$hour,$mday,$mon,$year) = (localtime)[0..5];
($mday,$mon,$year) = (sprintf("%02d", $mday),sprintf("%02d", $mon + 1),$year+1900);
our $date = $year.$mon.$mday;

our($mysql_user,$mysql_passwd) = &get_local_mysql_config();
our $dbh=DBI->connect("DBI:mysql:database=audit_sec;host=localhost;mysql_connect_timeout=5",$mysql_user,$mysql_passwd,{RaiseError=>1});

our $sqr = $dbh->prepare("show tables");
$sqr->execute();
while(my @row=$sqr->fetchrow_array())
{
	$table_names{$row[0]} = 1;
}
$sqr->finish();

unless(exists $table_names{"log_logs$date"})
{
	$sqr = $dbh->prepare("rename table log_logs to log_logs$date");
	$sqr->execute();
	$sqr->finish();

	$sqr = $dbh->prepare("CREATE TABLE `log_logs` (`host` varchar(32) default NULL,`facility` varchar(10) default NULL,`priority` varchar(10) default NULL,`level` varchar(10) default NULL,`tag` varchar(10) default NULL,`datetime` datetime default NULL,`program` varchar(15) default NULL,`msg` mediumtext,`seq` bigint(20) unsigned NOT NULL auto_increment,`logserver` varchar(32) default NULL,PRIMARY KEY  (`seq`),KEY `host` (`host`),KEY `program` (`program`),KEY `datetime` (`datetime`),KEY `priority` (`priority`),KEY `facility` (`facility`)) ENGINE=MyISAM AUTO_INCREMENT=1 DEFAULT CHARSET=utf8 ");
	$sqr->execute();
	$sqr->finish();
}

unless(exists $table_names{"log_linux_login$date"})
{
	$sqr = $dbh->prepare("rename table log_linux_login to log_linux_login$date");
	$sqr->execute();
	$sqr->finish();

	$sqr = $dbh->prepare("CREATE TABLE `log_linux_login` (`starttime` datetime default NULL,`endtime` datetime default NULL,`login_mod` varchar(15) default NULL,`pid` int(8) default NULL,`level` tinyint(1) default NULL,`host` varchar(32) default NULL,`srchost` varchar(32) default NULL,`protocol` varchar(10) default NULL,`active` tinyint(1) default NULL,`user` varchar(10) default NULL,`uid` tinyint(1) default NULL,`msg` mediumtext,`logserver` varchar(32) default NULL,`port` mediumint(8) default NULL,`id` int(11) NOT NULL auto_increment,PRIMARY KEY  (`id`),KEY `endtime` (`endtime`),KEY `host` (`host`),KEY `srchost` (`srchost`),KEY `pid` (`pid`),KEY `starttime` (`starttime`)) ENGINE=MyISAM AUTO_INCREMENT=1 DEFAULT CHARSET=gb2312");
	$sqr->execute();
	$sqr->finish();
}

unless(exists $table_names{"log_windows_login$date"})
{
    $sqr = $dbh->prepare("rename table log_windows_login to log_windows_login$date");
    $sqr->execute();
    $sqr->finish();

	$sqr = $dbh->prepare("CREATE TABLE `log_windows_login` (`starttime` datetime default NULL,`endtime` datetime default NULL,`login_id` varchar(20) default NULL,`level` tinyint(1) default NULL,`host` varchar(32) default NULL,`srchost` varchar(32) default NULL,`protocol` varchar(10) default NULL,`active` tinyint(1) default NULL,`user` varchar(15) default NULL,`msg` mediumtext,`logserver` varchar(32) default NULL,`port` mediumint(8) default NULL,`id` int(11) NOT NULL auto_increment,PRIMARY KEY  (`id`),KEY `endtime` (`endtime`),KEY `host` (`host`),KEY `port` (`port`),KEY `srchost` (`srchost`),KEY `starttime` (`starttime`),KEY `user` (`user`),KEY `protocol` (`protocol`),KEY `active` (`active`)) ENGINE=MyISAM AUTO_INCREMENT=1 DEFAULT CHARSET=utf8");
    $sqr->execute();
    $sqr->finish();
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
