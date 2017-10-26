#!/usr/bin/perl
use warnings;
use strict;
use DBI;
use DBD::mysql;
use Crypt::CBC;
use MIME::Base64;
use Fcntl;

our $fd_lock;
our $lock_file = "/tmp/.relation_lock";
sysopen($fd_lock, $lock_file, O_RDWR|O_CREAT|O_EXCL) or die "another instance running";

our $time_diff = 5;
our $time_reminder = 1000;

our($mysql_user,$mysql_passwd) = &get_local_mysql_config();
our $dbh=DBI->connect("DBI:mysql:database=audit_sec;host=localhost;mysql_connect_timeout=5",$mysql_user,$mysql_passwd,{RaiseError=>1});
my $sqr_select_ids = $dbh->prepare("select idsip,idsmsg,level,datetime,relationid,serverip from log_relationidslog");
$sqr_select_ids->execute();
while(my $ref_select_ids = $sqr_select_ids->fetchrow_hashref())
{
    my $idsip = $ref_select_ids->{"idsip"};
    my $idsmsg = $ref_select_ids->{"idsmsg"};
    my $level = defined $ref_select_ids->{"level"} ?  $ref_select_ids->{"level"} : "NULL";;
    my $datetime = $ref_select_ids->{"datetime"};
    my $relationid = $ref_select_ids->{"relationid"};
    my $serverip = $ref_select_ids->{"serverip"};

    my $sqr_select_server = $dbh->prepare("select servermsg from log_relationserverlog where serverip = '$serverip' and relationid = $relationid and ABS(UNIX_TIMESTAMP(datetime)-UNIX_TIMESTAMP('$datetime') < $time_diff)");
    $sqr_select_server->execute();
    my $ref_select_server = $sqr_select_server->fetchrow_hashref();
    if(defined $ref_select_server->{"servermsg"})
    {
        my $servermsg = $ref_select_server->{"servermsg"};
        my $sqr_insert;
        if($level eq "NULL")
        {
            $sqr_insert = $dbh->prepare("insert into log_relationlog (idsip,idsmsg,serverip,servermsg,relationid) values('$idsip','$idsmsg','$serverip','$servermsg',$relationid)");
        }
        else
        {
            $sqr_insert = $dbh->prepare("insert into log_relationlog (idsip,idsmsg,serverip,servermsg,level,relationid) values('$idsip','$idsmsg','$serverip','$servermsg','$level',$relationid)");
        }
        $sqr_insert->execute();
        $sqr_insert->finish();

        my $sqr_delete = $dbh->prepare("delete from log_relationserverlog where serverip = '$serverip' and relationid = $relationid and servermsg = '$servermsg' and ABS(UNIX_TIMESTAMP(datetime)-UNIX_TIMESTAMP('$datetime') < $time_diff)");
        $sqr_delete->execute();
        $sqr_delete->finish();

        $sqr_delete = $dbh->prepare("delete from log_relationidslog where idsip = '$idsip' and idsmsg = '$idsmsg' and datetime = '$datetime' and relationid = $relationid and serverip = '$serverip'");
        $sqr_delete->execute();
        $sqr_delete->finish();
    }
    $sqr_select_server->finish();
}
$sqr_select_ids->finish();

my $sqr_delete = $dbh->prepare("delete from log_relationserverlog where UNIX_TIMESTAMP()-UNIX_TIMESTAMP(datetime) > $time_reminder");
$sqr_delete->execute();
$sqr_delete->finish();

$sqr_delete = $dbh->prepare("delete from log_relationidslog where UNIX_TIMESTAMP()-UNIX_TIMESTAMP(datetime) > $time_reminder");
$sqr_delete->execute();
$sqr_delete->finish();
close $fd_lock;
unlink $lock_file;

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
