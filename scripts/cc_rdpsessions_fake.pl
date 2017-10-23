#!/usr/bin/perl
use warnings;
use strict;
use DBI;
use DBD::mysql;
use Crypt::CBC;
use MIME::Base64;

our($mysql_user,$mysql_passwd) = &get_local_mysql_config();
our $dbh=DBI->connect("DBI:mysql:database=cc;host=localhost;mysql_connect_timeout=5",$mysql_user,$mysql_passwd,{RaiseError=>1});
our $utf8 = $dbh->prepare("set names utf8");
$utf8->execute();
$utf8->finish();

our $sqr_select = $dbh->prepare("select max(sid) from rdpsessions where end<'20140426000000'");
$sqr_select->execute();
our $ref_select = $sqr_select->fetchrow_hashref();
our $sid = $ref_select->{"max(sid)"};
$sqr_select->finish();

our $get_pos = $sid+1;
foreach my $num(1..$sid)
{
    $sqr_select = $dbh->prepare("select sid from rdpsessions where sid=$num");
    $sqr_select->execute();
    $ref_select = $sqr_select->fetchrow_hashref();
    my $tmp = $ref_select->{"max(sid)"};
    $sqr_select->finish();

    unless(defined $sid)
    {
        next;
    }

    $sqr_select = $dbh->prepare("select replayfile, keydir, clipboarddir from rdpsessions where sid=$get_pos");
    $sqr_select->execute();
    $ref_select = $sqr_select->fetchrow_hashref();
    my $replayfile = $ref_select->{"replayfile"};
    my $keydir = $ref_select->{"keydir"};
    my $clipboarddir = $ref_select->{"clipboarddir"};
    $sqr_select->finish();

    ++$get_pos;

    my $sqr_update = $dbh->prepare("update rdpsessions set replayfile='$replayfile', keydir='$keydir', clipboarddir='$clipboarddir' where sid=$num");
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
