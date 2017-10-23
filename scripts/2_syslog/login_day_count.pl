#!/usr/bin/perl
use warnings;
use strict;
use DBI;
use DBD::mysql;
use Crypt::CBC;
use MIME::Base64;

our($mysql_user,$mysql_passwd) = &get_local_mysql_config();
our $dbh=DBI->connect("DBI:mysql:database=audit_sec;host=localhost;mysql_connect_timeout=5",$mysql_user,$mysql_passwd,{RaiseError=>1});

our $utf8 = $dbh->prepare("set names utf8");
$utf8->execute();
$utf8->finish();

our @login_table = qw/log_linux_login log_windows_login/;

#linux count

&login_count(-1,$login_table[0]);
&login_count(0,$login_table[0]);
&login_count(1,$login_table[0]);

#window count

&login_count(1,$login_table[1]);
&login_count(0,$login_table[1]);

sub login_count
{
    my($active,$table) = @_;
    my $sqr_select_count = $dbh->prepare("select host,user,srchost,protocol from $table where active = $active and starttime>=CURDATE()-interval 1 day and starttime<CURDATE() group by host,user,srchost,protocol");
    $sqr_select_count->execute();
    while(my $ref_select_count = $sqr_select_count->fetchrow_hashref())
    {
        my $sql_count = "select count(*) from $table where ";
        my $sql_insert_format = "insert into login_day_count (date";
        my $sql_insert_value = " values (CURDATE()-interval 1 day";

        my $host = $ref_select_count->{"host"};
        if(defined $host)
        {
            $sql_count.="host = '$host' and ";
            $sql_insert_format.= ",server";
            $sql_insert_value.= ",'$host'";
        }
        else{$sql_count.="host is null and ";}

        my $user = $ref_select_count->{"user"};
        if(defined $user)
        {
            $sql_count.="user = '$user' and ";
            $sql_insert_format.= ",user";
            $sql_insert_value.= ",'$user'";
        }
        else{$sql_count.="user is null and ";}

        my $srchost = $ref_select_count->{"srchost"};
        if(defined $srchost)
        {
            $sql_count.="srchost = '$srchost' and ";
            $sql_insert_format.= ",srcip";
            $sql_insert_value.= ",'$srchost'";
        }
        else{$sql_count.="srchost is null and ";}

        my $protocol = $ref_select_count->{"protocol"};
        if(defined $protocol)
        {
            $sql_count.="protocol = '$protocol' ";
            $sql_insert_format.= ",protocol";
            $sql_insert_value.= ",'$protocol'";
        }
        else{$sql_count.="protocol is null ";}

        $sql_count.="and active = $active and starttime>=CURDATE()-interval 1 day and starttime<CURDATE()";

        my $sqr_select_count = $dbh->prepare("$sql_count");
        $sqr_select_count->execute();
        my $ref_select_count = $sqr_select_count->fetchrow_hashref();
        my $count = $ref_select_count->{"count(*)"};
        $sqr_select_count->finish();

        $sql_insert_format.=",status";
        if($active == -1){$sql_insert_value.= ",'退出'";}
        elsif($active == 0){$sql_insert_value.= ",'错误'";}
        else{$sql_insert_value.= ",'成功'";}

        $sql_insert_format.=",count)";
        $sql_insert_value.= ",$count)";

        my $sqr_insert_count = $dbh->prepare("$sql_insert_format$sql_insert_value");
        $sqr_insert_count->execute();
        $sqr_insert_count->finish();
    }
    $sqr_select_count->finish();
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
