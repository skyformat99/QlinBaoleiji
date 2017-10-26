#!/usr/bin/perl
use warnings;
use strict;
use DBI;
use DBD::mysql;
use Expect;
use File::Basename;
use Crypt::CBC;
use MIME::Base64;

our $time_now_utc = time;
my($min,$hour,$mday,$mon,$year) = (localtime $time_now_utc)[1..5];
($min,$hour,$mday,$mon,$year) = (sprintf("%02d", $min),sprintf("%02d", $hour),sprintf("%02d", $mday),sprintf("%02d", $mon + 1),$year+1900);
our $time_now_str = "$year$mon$mday$hour$min"."00";
our $date_today = "$year$mon$mday";

our($mysql_user,$mysql_passwd) = &get_local_mysql_config();
my $dbh=DBI->connect("DBI:mysql:database=audit_sec;host=localhost;mysql_connect_timeout=5",$mysql_user,$mysql_passwd,{RaiseError=>1});
my $utf8 = $dbh->prepare("set names utf8");
$utf8->execute();
$utf8->finish();

&unlink_func();

my $sql_cmd = "select device_ip,device_type,hostname,asset_name,asset_department,asset_location,asset_company,asset_start,asset_usedtime,asset_warrantdate,asset_status from servers";
&file_create($sql_cmd,"/tmp/servers.csv");

$sql_cmd = "SELECT a.*,b.login_method login_method_name,c.device_type device_type_name FROM devices a LEFT JOIN login_template b ON a.login_method=b.id LEFT JOIN login_template c ON a.device_type=c.id Where 1=1 ORDER BY INET_ATON(device_ip) asc ,a.luser ASC";
&file_create($sql_cmd,"/tmp/system_account.csv");

$sql_cmd = "SELECT b.*,IF(LENGTH(a.username)=0,'空用户',a.username) username FROM appdevices a LEFT JOIN apppub b ON a.apppubid=b.id WHERE b.id IS NOT NULL AND 1=1 ORDER BY device_ip desc ,username ASC";
&file_create($sql_cmd,"/tmp/app_account.csv");

$sql_cmd = "SELECT *,if(luid,1,if(ludid,2,if(lgid,3,4))) AS orderby FROM ( SELECT id,device_ip,username,login_method FROM devices WHERE id IN(SELECT devicesid FROM luser WHERE 1=1 UNION SELECT devicesid FROM resourcegroup WHERE groupname IN (SELECT b.groupname FROM luser_resourcegrp a LEFT JOIN resourcegroup b ON a.resourceid=b.id WHERE 1=1 ) UNION SELECT devicesid FROM lgroup WHERE 1=1 UNION SELECT devicesid FROM resourcegroup WHERE groupname IN (SELECT b.groupname FROM lgroup_resourcegrp a LEFT JOIN resourcegroup b ON a.resourceid=b.id WHERE 1=1 )) AND device_ip IN(SELECT device_ip FROM servers WHERE groupid='0'))ds LEFT JOIN ( SELECT '1' as l11,l1.id luid,l1.devicesid ludevicesid,l1.weektime lupolicyname,l1.forbidden_commands_groups lufcg,l1.sourceip lusourceip,l1.syslogalert lusyslogalert, l1.mailalert lumailalert, l1.loginlock luloginlock,l1.autosu luautosu,m.username luname,m.realname lurealname,m.uid,m.groupid lugroupid,ug.groupname ugname FROM luser l1 LEFT JOIN member m ON l1.memberid=m.uid LEFT JOIN usergroup ug ON m.groupid=ug.id WHERE m.uid IS NOT NULL ) lu ON ds.id=lu.ludevicesid LEFT JOIN ( SELECT '2' as l12,l2.id ludid,r.devicesid luddevicesid, l2.resourceid luresourceid,l2.weektime ludpolicyname,l2.forbidden_commands_groups ludfcg,l2.sourceip ludsourceip,l2.syslogalert ludsyslogalert, l2.mailalert ludmailalert, l2.loginlock ludloginlock,l2.autosu ludautosu,m.username ludname,m.realname ludrealname FROM ( SELECT ra.id,ra.groupname,rb.devicesid FROM resourcegroup ra LEFT JOIN resourcegroup rb on ra.groupname=rb.groupname where ra.devicesid=0 and rb.devicesid!=0 ) r LEFT JOIN luser_resourcegrp l2 ON r.id=l2.resourceid LEFT JOIN member m ON l2.memberid=m.uid WHERE m.uid IS NOT NULL ) lud ON ds.id=lud.luddevicesid LEFT JOIN ( SELECT '3' as l13,l3.id lgid,l3.devicesid lgdevicesid,l3.groupid lggroupid,l3.weektime lgpolicyname,l3.forbidden_commands_groups lgfcg,l3.sourceip lgsourceip,l3.syslogalert lgsyslogalert, l3.mailalert lgmailalert, l3.loginlock lgloginlock,l3.autosu lgautosu,ug.GroupName lgname FROM lgroup l3 LEFT JOIN usergroup ug ON l3.groupid=ug.id WHERE ug.id IS NOT NULL ) lg ON ds.id=lg.lgdevicesid LEFT JOIN ( SELECT '4' as l14,l4.id lgdid,r.devicesid lgddevicesid,l4.resourceid lgresourceid,l4.weektime lgdpolicyname,l4.forbidden_commands_groups lgdfcg,l4.sourceip ldgsourceip,l4.syslogalert ldgsyslogalert, l4.mailalert ldgmailalert, l4.loginlock ldgloginlock,l4.autosu ldgautosu,ug.GroupName lgdname,l4.groupid ldgresgrpid FROM( SELECT ra.id,ra.groupname,rb.devicesid FROM resourcegroup ra LEFT JOIN resourcegroup rb on ra.groupname=rb.groupname where ra.devicesid=0 and rb.devicesid!=0 ) r LEFT JOIN lgroup_resourcegrp l4 ON r.id=l4.resourceid LEFT JOIN usergroup ug ON l4.groupid=ug.id WHERE ug.id IS NOT NULL ) lgd ON ds.id=lgd.lgddevicesid WHERE (luid IS NOT NULL or ludid IS NOT NULL or lgid IS NOT NULL or lgdid IS NOT NULL) ORDER BY device_ip asc , IFNULL(luname,IFNULL(ludname, IFNULL(lgname,lgdname))) ASC";
&file_create($sql_cmd,"/tmp/system_permission.csv");

my $sqr_select = $dbh->prepare("select ip,port,path,user,udf_decrypt(passwd),protocol from backup_setting where session_flag=100");
$sqr_select->execute();
while(my $ref = $sqr_select->fetchrow_hashref())
{
    my $ip = $ref->{"ip"};
    my $port = $ref->{"port"};
    my $path = $ref->{"path"};
    my $user = $ref->{"user"};
    my $passwd = $ref->{"udf_decrypt(passwd)"};
    my $protocol = $ref->{"protocol"};

    &upload($ip,$port,$passwd,$user,$path,$protocol,"/tmp/servers.csv","/tmp/system_account.csv","/tmp/app_account.csv","/tmp/system_permission.csv");
}
$sqr_select->finish();

&unlink_func();

sub unlink_func
{
    if(-e "/tmp/servers.csv")
    {
        unlink "/tmp/servers.csv";
    }

    if(-e "/tmp/system_account.csv")
    {
        unlink "/tmp/system_account.csv";
    }

    if(-e "/tmp/app_account.csv")
    {
        unlink "/tmp/app_account.csv";
    }

    if(-e "/tmp/system_permission.csv")
    {
        unlink "/tmp/system_permission.csv";
    }
}

sub file_create
{
    my($sql_cmd,$file) = @_;

    open(my $fd_fw,">$file");

    my $sqr_select = $dbh->prepare("$sql_cmd");
    $sqr_select->execute();
    while(my $ref = $sqr_select->fetchrow_arrayref())
    {
        my @tmp_arr = @$ref;
        my $end_pos = scalar @tmp_arr - 1;

        if($file eq "/tmp/servers.csv")
        {
            $tmp_arr[1] = &devive_type_process($tmp_arr[1]);
        }

        foreach(0..$end_pos)
        {
            if(!defined $tmp_arr[$_] || $tmp_arr[$_] eq "null" || $tmp_arr[$_] eq "NULL" || $tmp_arr[$_] eq "")
            {
                $tmp_arr[$_] = "空";
            }
        }

        my $line = join(",",@tmp_arr);
        print $fd_fw $line,"\n";
    }
    $sqr_select->finish();

    close $fd_fw;
}

sub devive_type_process
{
    my($id) = @_;
    my $device_type;
    my $sqr_select = $dbh->prepare("select device_type from login_template where id=$id");
    $sqr_select->execute();
    my $ref = $sqr_select->fetchrow_hashref();
    $device_type = $ref->{"device_type"};
    $sqr_select->finish();

    
    if(!defined $device_type || $device_type eq "null" || $device_type eq "NULL" || $device_type eq "")
    {
        $device_type = "空";
    }

    return $device_type;
}

sub upload
{
    my($ip,$port,$passwd,$user,$path,$protocol,@files) = @_;

    $path =~ s/\/$//;
    my $des_path = "$path/tmp";
    my $login_str = "sftp://$user:$passwd\@$ip:$port";
    if($protocol eq "ftp")
    {
        $login_str = "ftp://$user:$passwd\@$ip:$port";
    }

    my $mkdir_cmd = "lftp -c 'mkdir -pf $login_str$des_path'";
    print "create remote dir $login_str$des_path, cmd: $mkdir_cmd\n";
    system("$mkdir_cmd 1>/dev/null 2>&1");
    sleep(1);

    foreach my $file(@files)
    {
        my $cmd = "";
        my $flag = 1;
        print "upload $file\n";
        my $file_name = basename $file;
        $cmd = "lftp -c 'put $file -o $login_str$des_path/$file_name'; echo \"lftp status:\$?\"";
        print $cmd,"\n";

        my $output = `$cmd`;
        foreach my $line(split /\n/,$output)
        {
            if($line =~ /lftp\s*status:\s*(\d+)/i && $1==0)
            {
                print "upload $file success\n";
                $flag = 0;
            }
        }

        if($flag != 0)
        {
            print "upload $file failed, debug info: $output\n"
        }
        sleep(2);
    }
}

sub rsa_err_process
{
    my($user,$ip) = @_;
    my $home = File::HomeDir->users_home($user);
    unless(defined $home)
    {
        &log_process($ip,"cant find home dir for user $user");
        return 1;
    }

    my @file_lines;
    $home =~ s/\/$//;
    open(my $fd_fr,"<$home/.ssh/known_hosts");
    foreach my $line(<$fd_fr>)
    {
        if($line =~ /^$ip/)
        {
            next;
        }

        push @file_lines,$line;
    }
    close $fd_fr;

    open(my $fd_fw,">$home/.ssh/known_hosts");
    foreach my $line(@file_lines)
    {
        print $fd_fw $line;
    }
    close $fd_fw;

    return 0;
}

sub log_process
{
    my($host,$err_str) = @_;

    my $cmd;

    if(defined $host)
    {
        $cmd = "insert into backup_passwd_log(datetime,host,reason) values('$time_now_str','$host','$err_str')";
    }
    else
    {
        $cmd = "insert into backup_passwd_log(datetime,reason) values('$time_now_str','$err_str')";
    }

    my $insert = $dbh->prepare("$cmd");
    $insert->execute();
    $insert->finish();
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
