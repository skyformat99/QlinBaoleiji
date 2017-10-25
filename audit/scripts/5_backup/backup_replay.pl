#!/usr/bin/perl
use warnings;
use strict;
use Fcntl;
use Crypt::CBC;
use MIME::Base64;

our $fd_lock;
our $lock_file = "/tmp/.backup_replay_lock";
sysopen($fd_lock, $lock_file, O_RDWR|O_CREAT|O_EXCL) or die "another instance running";

#lftp -c 'mirror -Rn --exclude=wxl_tmp/ --exclude=2015-02-01/ /opt/freesvr/audit/gateway/log/rdp/replay/ sftp://root:freesvr!@#@172.16.210.99:2288/opt/opt/freesvr/audit/gateway/log/rdp/replay/'; echo "lftp status:$?"
#lftp -c 'mirror -RLpn --exclude=wxl_tmp/ --exclude=2015-02-01/ /opt/freesvr/audit/gateway/log/rdp/replay/ ftp://administrator:freesvr123@172.16.210.30:21/opt/freesvr/audit/gateway/log/rdp/replay/'; echo "lftp status:$?"
# lftp -c 'put -c 1 -o ftp://administrator:Freesvr!@#@172.16.210.102:21/sql/1'; echo "lftp status:$?"

our $days_diff = 0;
if(defined $ARGV[0])
{
    $days_diff = $ARGV[0];
}

our $time_now_utc = time;
our($min,$hour,$mday,$mon,$year) = (localtime $time_now_utc)[1..5];
($min,$hour,$mday,$mon,$year) = (sprintf("%02d", $min),sprintf("%02d", $hour),sprintf("%02d", $mday),sprintf("%02d", $mon + 1),$year+1900);
our $time_now_str = "$year$mon$mday$hour$min"."00";
our $time_now_date = "$year$mon$mday";

our $backup_end_date = $time_now_utc - $days_diff*86400;
($mday,$mon,$year) = (localtime $backup_end_date)[3..5];
($mday,$mon,$year) = (sprintf("%02d", $mday),sprintf("%02d", $mon + 1),$year+1900);
$backup_end_date = "$year$mon$mday";

&backup("172.16.210.102",21,"administrator","Freesvr!@#","/","ftp");
&backup_db("172.16.210.102",21,"administrator","Freesvr!@#","/sql","ftp");

close $fd_lock;
unlink $lock_file;
exit 0;

sub create_tmp_dir
{
    my($work_dir) = @_;
    my $today_dir;
    mkdir "$work_dir/wxl_tmp",0755;
    opendir(my $dir_handle,$work_dir);
    while(my $file = readdir($dir_handle))
    {
        if($file eq "." || $file eq ".." || $file eq "wxl_tmp")
        {
            next;
        }

        unless(-d "$work_dir/$file")
        {
            rename "$work_dir/$file", "$work_dir/wxl_tmp/$file";
            next;
        }

        if($file =~ /(\d+)-(\d+)-(\d+)/)
        {
            if((int($1) == $year) && (int($2) == $mon) && (int($3) == $mday))
            {
                $today_dir = $file;
                next;
            }
        }
        else
        {
            rename "$work_dir/$file", "$work_dir/wxl_tmp/$file";
        }
    }
    close $dir_handle;
    return $today_dir;
}

sub upload
{
    my($ip,$port,$user,$passwd,$work_dir,$path_prefix,$protocol,$today_dir) = @_;
    $path_prefix =~ s/\/$//;

    my $status=2;
    my $mkdir_cmd;
    my $user_passwd = $user;
    my $login_str;
    my $mirror_opt;
    my $exclude_opt = "--exclude=wxl_tmp/";

    if(defined $passwd && $passwd ne "")
    {
        $user_passwd .= ":$passwd";
    }

    if(defined $today_dir)
    {
        $exclude_opt .= " --exclude=$today_dir/";
    }

    if($protocol eq "ftp")
    {
        unless($port =~ /\d+/)
        {
            $port = 21;
        }
        $login_str = "ftp://$user_passwd\@$ip:$port";
        $mirror_opt = "-RLpc";
    }
    else
    {
        unless($port =~ /\d+/)
        {
            $port = 22;
        }
        $login_str = "sftp://$user_passwd\@$ip:$port";
        $mirror_opt = "-Rc";
    }
    $mirror_opt .= " --older-than=$backup_end_date";

    $mkdir_cmd = "lftp -c 'mkdir -pf $login_str$path_prefix$work_dir'";
    print $mkdir_cmd,"\n";
    system("$mkdir_cmd 1>/dev/null 2>&1");
    sleep 2;

    my $upload_cmd = "lftp -c 'mirror $mirror_opt $exclude_opt $work_dir/ $login_str$path_prefix$work_dir/'; echo \"lftp status:\$?\"";
    print $upload_cmd,"\n";
    foreach my $line(split /\n/, `$upload_cmd`)
    {
        if($line =~ /lftp\s*status:\s*(\d+)/i && $1==0)
        {
            print "upload success: $work_dir\n";
            $status = 1;
        }
    }
    sleep 2;
    return $status;
}

sub del_tmp_dir
{
    my($work_dir) = @_;
    opendir(my $dir_handle,"$work_dir/wxl_tmp");
    while(my $file = readdir($dir_handle))
    {   
        if($file eq "." || $file eq "..")
        {   
            next;
        }

        rename "$work_dir/wxl_tmp/$file", "$work_dir/$file";
    }
    close $dir_handle;
    rmdir "$work_dir/wxl_tmp";
}

sub backup
{
    my($ip,$port,$user,$passwd,$path_prefix,$protocol) = @_;
    my $last_date;

    my @work_dirs = qw#/opt/freesvr/audit/gateway/log/telnet/cache
    /opt/freesvr/audit/gateway/log/telnet/replay
    /opt/freesvr/audit/gateway/log/ssh/cache
    /opt/freesvr/audit/gateway/log/ssh/replay
    /opt/freesvr/audit/gateway/log/rdp/replay
    /opt/freesvr/audit/gateway/log/rdp/key#;

    foreach my $work_dir(@work_dirs)
    {
        my $today_dir = &create_tmp_dir($work_dir);

        my $tmp_status = &upload($ip,$port,$user,$passwd,$work_dir,$path_prefix,$protocol,$today_dir);
        if($tmp_status != 1)
        {
            print "upload to $ip failed\n";
        }
        &del_tmp_dir($work_dir);
    }
}

sub backup_db
{
    my($ip,$port,$user,$passwd,$path_prefix,$protocol) = @_;
    my $cmd = "mysqldump -h localhost -u root audit_sec | gzip >/tmp/audit_sec_$time_now_date.sql.gz";
    if(system($cmd) != 0)
    {
        print "dump audit_sec failed\n";
        return
    }

    my $status=2;
    my $login_str;
    my $user_passwd = $user;

    if(defined $passwd && $passwd ne "")
    {
        $user_passwd .= ":$passwd";
    }

    if($protocol eq "ftp")
    {
        unless($port =~ /\d+/)
        {
            $port = 21;
        }
        $login_str = "ftp://$user_passwd\@$ip:$port";
    }
    else
    {
        unless($port =~ /\d+/)
        {
            $port = 22;
        }
        $login_str = "sftp://$user_passwd\@$ip:$port";
    }

    my $mkdir_cmd = "lftp -c 'mkdir -pf $login_str$path_prefix'";
    print $mkdir_cmd,"\n";
    system("$mkdir_cmd 1>/dev/null 2>&1");
    sleep 2;
   
    my $upload_cmd = "lftp -c 'put -c /tmp/audit_sec_$time_now_date.sql.gz -o $login_str$path_prefix/audit_sec_$time_now_date.sql.gz'; echo \"lftp status:\$?\"";
    print $upload_cmd,"\n";
    foreach my $line(split /\n/, `$upload_cmd`)
    {
        if($line =~ /lftp\s*status:\s*(\d+)/i && $1==0)
        {
            print "upload success: /tmp/audit_sec_$time_now_date.sql.gz\n";
            $status = 1;
        }
    }
    sleep 2;
    unlink "/tmp/audit_sec_$time_now_date.sql.gz";
    return $status;
}

