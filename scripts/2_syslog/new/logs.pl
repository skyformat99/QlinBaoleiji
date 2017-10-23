#!/usr/bin/perl
use warnings;
use strict;
use DBI;
use DBD::mysql;

use Fcntl;
use Fcntl qw(:flock);
use Proc::Daemon;

use threads;
use threads::shared;
use Thread::Semaphore;

use Mail::Sender;
use Encode;
use URI::Escape;
use URI::URL;
use Crypt::CBC;
use MIME::Base64;

our $fd_lock;
our $lock_file = "/tmp/.logs_lock";
sysopen($fd_lock, $lock_file, O_RDWR|O_CREAT|O_EXCL) or die "another instance running";

our $conf_path = "/home/wuxiaolong/2_syslog/new/log.conf";
our $log_server :shared= undef;
our $fifo :shared= undef;
our $log_path :shared= undef;
our $debug_file :shared= undef;
our $mysql_log_host :shared= undef;
our $send_interval :shared = 30;
our $load_policy_interval :shared = 300;
our $load_rule_interval :shared = 300;
our $warning_hash_interval :shared = 300;

&read_conf();
unless(defined $log_server && defined $fifo && defined $log_path && defined $debug_file && defined $mysql_log_host)
{
    print "both <log_server>,<fifo>,<log_path>,<debug_file>,<mysql_log_host> need to be config in the $conf_path\n";
    exit 1;
}
#print "$log_server,$fifo,$log_path,$debug_file,$mysql_log_host,$send_interval,$load_policy_interval,$warning_hash_interval\n";

unless(-d $log_path)
{
    mkdir $log_path,0755;
}

our $ref_policy :shared=undef;
our $g_policy = Thread::Semaphore->new();
our $ref_rule :shared=undef;
our $g_rule = Thread::Semaphore->new();
our %mail_msg :shared;
our $g_mail_msg = Thread::Semaphore->new();
our %sms_msg :shared;
our $g_sms_msg = Thread::Semaphore->new();

our $g_deadlock = Thread::Semaphore->new(0);

#our $daemon = Proc::Daemon->new();
#$daemon->init();

&load_policy();
&load_rule();

my $t1 = threads->create(\&t_load_policy);
$t1->detach();

my $t2 = threads->create(\&t_log_process);
$t2->detach();

my $t3 = threads->create(\&t_poll_warning_hash);
$t3->detach();

my $t4 = threads->create(\&t_load_rule);
$t4->detach();

$g_deadlock->down();

sub t_log_process
{
    &write_debug_log("t_log_process start");

    my($mysql_user,$mysql_passwd) = &get_local_mysql_config();
    my $dbh=DBI->connect("DBI:mysql:database=audit_sec;host=$mysql_log_host;mysql_connect_timeout=5;mysql_init_command=set names utf8",$mysql_user,$mysql_passwd,{RaiseError=>1});
    $dbh->{mysql_auto_reconnect} = 1;

    while(1)
    {
        open(my $fd_fr,"<$fifo");
        while(my $log=<$fd_fr>)
        {
            chomp $log;

            eval
            {
                &log_process($dbh,$log);
            };

            if($@)
            {
                &write_debug_log("Runtime Error in <log_process> $log, $@");
                last;
            }
        }
        close $fd_fr;
    }
    $dbh->disconnect();
}

sub log_process
{
    my($dbh,$log) = @_;

    print $log,"\n";
    my @unit_temp = split  /\|\|/,$log;
    my $log_msg = join("||",@unit_temp[7..((scalar @unit_temp)-1)]);
    my($log_host,$log_facility,$log_priority,$log_level,$log_tag,$log_datetime,$log_program) = @unit_temp[0..6];

    my($save,$forward,$ip,$warnmail,$warnmsg,$desc,$device_type) = &find_policy($log_host,$log_facility,$log_priority,$log_level,$log_tag,$log_datetime,$log_program,$log_msg);
    if($save==2 || $save==3)
    {
        &write_syslog($log_host,$log);
    }

    if($warnmail==1 || $warnmsg==1)
    {
        my $t = threads->create(\&t_warning_process,$warnmail,$warnmsg,$desc,$log_host,$log_facility,$log_priority,$log_level,$log_tag,$log_datetime,$log_program,$log_msg);
        $t->detach();
    }

    if($save==1 || $save==3)
    {
        if($log_program eq "sshd")
        {
            &ssh_login_process($dbh,$log,$log_host,$log_facility,$log_priority,$log_level,$log_tag,$log_datetime,$log_program,$log_msg);
            return;
        }
        else
        {
            unless(defined $device_type)
            {
                &write_debug_log("Log Error: cannot find 'device_type' in policy table for $log_host");
                return;
            }

            my($result,$policyid,$name,$type,$level) = &find_rule($device_type,$log_msg);
            &save_mysql($dbh,$result,$policyid,$name,$type,$level,$log_host,$log_facility,$log_priority,$log_level,$log_tag,$log_datetime,$log_program,$log_msg);
        }
    }
}

sub ssh_login_process
{
    my($dbh,$log,$log_host,$log_facility,$log_priority,$log_level,$log_tag,$log_datetime,$log_program,$log_msg) = @_; 
    print $log,"\n";
    my $pid = undef;
    if($log_msg =~ /sshd\s*\[(\d+)\]/)
    {
        $pid = $1;
    }

    unless(defined $pid)
    {
        &write_debug_log("Log Error: cannot find pid in ssh login log, $log");
        return;
    }

    if($log_msg =~ /accept/i)
    {
        &ssh_login_accept_process($dbh,$log,$log_host,$log_level,$log_msg,$log_datetime,$pid);
        return;
    }
    elsif($log_msg =~ /failed password/i)
    {
        &ssh_login_fail_process($dbh,$log,$log_host,$log_level,$log_msg,$log_datetime,$pid);
        return;
    }
    elsif($log_msg =~ /\bdisconnect\b/i)
    {
        &ssh_login_disconnect_process($dbh,$log,$log_host,$log_level,$log_msg,$log_datetime,$pid);
        return;
    }
    elsif($log_msg =~ /Connection\s*closed\s*by/i)
    {
        return;
    }
    elsif($log_msg =~ /pam_unix/i)
    {
        if($log_msg =~ /opened/i)
        {
            my $uid = undef;
            if($log_msg =~ /.*uid\s*=(\d+)/i)
            {
                $uid = $1;
            }

            unless(defined $uid)
            {
                &write_debug_log("Log Error: cannot find uid in ssh login pam_unix log, $log");
                return;
            }

            my $sqr_select = $dbh->prepare("select max(id) from log_login where pid=$pid and host='$log_host' and uid is null");
            $sqr_select->execute();
            my $ref_select = $sqr_select->fetchrow_hashref();
            my $id = $ref_select->{"max(id)"};
            $sqr_select->finish();

            unless(defined $id)
            {
                &write_debug_log("Log Error: cannot find ssh accept login for pam_unix, $log");
                return;
            }

            my $sqr_update = $dbh->prepare("update log_login set uid=$uid where id=$id");
            $sqr_update->execute();
            $sqr_update->finish();
        }
        elsif($log_msg =~ /closed/i)
        {
            my $sqr_select = $dbh->prepare("select max(id) from log_login where pid=$pid and host='$log_host' endtime is null and pre_endtime is null");
            $sqr_select->execute();
            my $ref_select = $sqr_select->fetchrow_hashref();
            my $id = $ref_select->{"max(id)"};
            $sqr_select->finish();

            unless(defined $id)
            {
                &write_debug_log("Log Error: cannot find ssh accept log for pam_unix, $log");
                return;
            }

            my $sqr_update = $dbh->prepare("update log_login set endtime=now(),pre_endtime='$log_datetime' where id=$id");
            $sqr_update->execute();
            $sqr_update->finish();
        }
        return;
    }

    &write_debug_log("Log Error: ssh log mismatch in <ssh_login_process>, $log");
}

sub ssh_login_accept_process
{
    my($dbh,$log,$log_host,$log_level,$log_msg,$log_datetime,$pid) = @_;
    my $srcip = undef;
    my $port = undef;
    my $user = undef;
    my $mod = undef;

    if($log_msg =~ /password/i)
    {
        $mod = 1;
    }
    elsif($log_msg =~ /publickey/i)
    {
        $mod = 2;
    }

    if($log_msg =~ /for\s*(.*)\sfrom\s*(\S+)\s*port\s*(\d+).*$/i)
    {   
        $user = $1;
        $srcip = $2;
        $port = $3;
    }

    unless(defined $user && defined $srcip && defined $port && defined $mod)
    {
        &write_debug_log("Log Error: ssh login accept log mismatch, $log");
        return;
    }

    my $level_num = &get_level_num($log_level);
    my $sqr_insert = $dbh->prepare("insert into log_login (host,pre_level,starttime,pre_starttime,login_mod,login_detail,port,pid,srchost,active,user,msg,logserver) values ('$log_host',$level_num,now(),'$log_datetime',1,$mod,$port,$pid,'$srcip',1,'$user','$log','$log_server')");
    $sqr_insert->execute();
    $sqr_insert->finish();
}

sub ssh_login_fail_process
{
    my($dbh,$log,$log_host,$log_level,$log_msg,$log_datetime,$pid) = @_;
    my $srcip = undef;
    my $port = undef;
    my $user = undef;
    my $mod = 1;        # for password

    if($log_msg =~ /for\s*(.*)\sfrom\s*(\S+)\s*port\s*(\d+).*$/i)
    {   
        $user = $1;
        $srcip = $2;
        $port = $3;
    }

    unless(defined $user && defined $srcip && defined $port && defined $mod)
    {
        &write_debug_log("Log Error: ssh login fail log mismatch, $log");
        return;
    }

    my $level_num = &get_level_num($log_level);
    my $sqr_insert = $dbh->prepare("insert into log_login (host,pre_level,starttime,endtime,pre_starttime,pre_endtime,login_mod,login_detail,port,pid,srchost,active,user,msg,logserver) values ('$log_host',$level_num,now(),now(),'$log_datetime','$log_datetime',1,$mod,$port,$pid,'$srcip',0,'$user','$log','$log_server')");
    $sqr_insert->execute();
    $sqr_insert->finish();
}

sub ssh_login_disconnect_process
{
    my($dbh,$log,$log_host,$log_level,$log_msg,$log_datetime,$pid) = @_;
    my $srcip = undef;
    my $port = undef;
    my $mod = 1;        # for password

    if($log_msg =~ /from\s*(.*):\s*(\d+)/i)
    {
        $srcip = $1;
        $port = $2;
    }

    unless(defined $srcip && defined $port)
    {
        &write_debug_log("Log Error: ssh login disconnect log mismatch, $log");
        return;
    }

    my $level_num = &get_level_num($log_level);
    my $sqr_insert = $dbh->prepare("insert into log_login (host,pre_level,starttime,endtime,pre_starttime,pre_endtime,login_mod,login_detail,port,pid,srchost,active,msg,logserver) values ('$log_host',$level_num,now(),now(),'$log_datetime','$log_datetime',1,$mod,$port,$pid,'$srcip',-1,'$log','$log_server')");
    $sqr_insert->execute();
    $sqr_insert->finish();
}

sub find_policy
{
    my($log_host,$log_facility,$log_priority,$log_level,$log_tag,$log_datetime,$log_program,$log_msg) = @_;
    my($save,$forward,$ip,$warnmail,$warnmsg,$desc,$device_type) = (2,0,undef,0,0,"",undef);

    unless(exists $ref_policy->{$log_host})
    {
        return ($save,$forward,$ip,$warnmail,$warnmsg,$desc,$device_type);
    }

    $g_policy->down();
    foreach my $ref(@{$ref_policy->{$log_host}})
    {
        if( ($ref->[0] eq "facility" && ($ref->[1] eq "*" || $log_facility eq $ref->[1])) ||
                ($ref->[0] eq "level" && ($ref->[1] eq "*" || $log_level eq $ref->[1])) ||
                ($ref->[0] eq "program" && ($ref->[1] eq "*" || $log_program eq $ref->[1])) ||
                ($ref->[0] eq "msg" && ($ref->[1] eq "*" || $log_msg =~ /$ref->[1]/i)))
        {
            $save = $ref->[2];
            $forward = $ref->[3];
            $ip = $ref->[4];
            $warnmail = $ref->[5];
            $warnmsg = $ref->[6];
            $desc = $ref->[7];
            $device_type = $ref->[8];
            last;
        }
    }
    $g_policy->up();
    return ($save,$forward,$ip,$warnmail,$warnmsg,$desc,$device_type);
}

sub find_rule
{
    my($device_type,$log_msg) = @_;
    my($result,$policyid,$name,$type,$level) = (0,undef,undef,undef);

    unless(exists $ref_rule->{$device_type})
    {
        return ($result,$policyid,$name,$type,$level);
    }

    $g_rule->down();
    foreach my $ref(@{$ref_rule->{$device_type}})
    {
        my $code = $ref->[0];
        if($log_msg =~ /$code/i)
        {
            $result = 1;
            $policyid = $ref->[1];
            $name = $ref->[2];
            $type = $ref->[3];
            $level = $ref->[4];
            last;
        }
    }
    $g_rule->up();
    return ($result,$policyid,$name,$type,$level);
}

sub t_load_policy
{
    &write_debug_log("t_load_policy start");

    while(1)
    {
        sleep $load_policy_interval;

        eval
        {
            &load_policy();
        };

        if($@)
        {
            &write_debug_log($debug_file, "Runtime Error in <load_policy> $@");
            exit 1;
        }
    }
}

sub t_load_rule
{
    &write_debug_log("t_load_rule start");

    while(1)
    {
        sleep $load_rule_interval;

        eval
        {
            &load_rule();
        };

        if($@)
        {
            &write_debug_log($debug_file, "Runtime Error in <load_rule> $@");
            exit 1;
        }
    }
}

sub t_warning_process
{
    my($warnmail,$warnmsg,$desc,$log_host,$log_facility,$log_priority,$log_level,$log_tag,$log_datetime,$log_program,$log_msg) = @_;
    &write_debug_log("t_warning_process start");

    my($mysql_user,$mysql_passwd) = &get_local_mysql_config();
    my $dbh=DBI->connect("DBI:mysql:database=audit_sec;host=$mysql_log_host;mysql_connect_timeout=5",$mysql_user,$mysql_passwd,{RaiseError=>1});
    my $utf8 = $dbh->prepare("set names utf8");
    $utf8->execute();
    $utf8->finish();

    my $time_now_utc = time;
    my($sec,$min,$hour,$mday,$mon,$year) = (localtime $time_now_utc)[0..5];
    ($sec,$min,$hour,$mday,$mon,$year) = (sprintf("%02d", $sec),sprintf("%02d", $min),sprintf("%02d", $hour),sprintf("%02d", $mday),sprintf("%02d", $mon+1),$year+1900);
    my $time_now_str = "$year-$mon-$mday $hour:$min:$sec";

    eval
    {
        &warning_process($dbh,$time_now_str,$warnmail,$warnmsg,$desc,$log_host,$log_facility,$log_priority,$log_level,$log_tag,$log_datetime,$log_program,$log_msg,$log_server);
    };

    if($@)
    {
        &write_debug_log($debug_file, "Runtime Error in <warning_process>, $warnmail,$warnmsg,$desc,$log_msg, $@");
    }

    $dbh->disconnect();
}

sub t_poll_warning_hash
{
    &write_debug_log("t_poll_warning_hash start");

    while(1)
    {
        sleep $warning_hash_interval;

        eval
        {
            &poll_warning_hash();
        };

        if($@)
        {
            &write_debug_log("Runtime Error in <poll_warning_hash> $@");
            exit 1;
        }
    }
}

sub save_mysql
{
    my($dbh,$result,$policyid,$name,$type,$level,$log_host,$log_facility,$log_priority,$log_level,$log_tag,$log_datetime,$log_program,$log_msg) = @_;
    $log_msg =~ s/'/\\'/g;
    my $col = "host";
    my $val = "'$log_host'";

    if(defined $policyid)
    {
        $col .= ",policyid";
        $val .= ",$policyid";
    }

    if(defined $name)
    {
        $col .= ",logname";
        $val .= ",'$name'";
    }

    if(defined $type)
    {
        $col .= ",logtype";
        $val .= ",$type";
    }

    if(defined $level)
    {
        $col .= ",level";
        $val .= ",$level";
    }

    my $level_num = &get_level_num($log_level);
    $col .= ",pre_level,starttime,pre_starttime,facility,priority,tag,program,msg,logserver,logaction";
    $val .= ",$level_num,now(),'$log_datetime','$log_facility','$log_priority','$log_tag','$log_program','$log_msg','$log_server',$result";

    my $sqr_insert = $dbh->prepare("insert into log_logs ($col) values ($val)");
    $sqr_insert->execute();
    $sqr_insert->finish();
}

sub load_policy
{
    my($mysql_user,$mysql_passwd) = &get_local_mysql_config();
    my $dbh=DBI->connect("DBI:mysql:database=audit_sec;host=localhost;mysql_connect_timeout=5",$mysql_user,$mysql_passwd,{RaiseError=>1});
    my $utf8 = $dbh->prepare("set names utf8");
    $utf8->execute();
    $utf8->finish();

    my %tmp_policy;
    my $sqr_select=$dbh->prepare("select s.device_ip,lt.device_type,r.name,r.content,r.desc,l.action,l.forward,l.save,l.ip,l.warnmsg,l.warnmail from log_resourcegrouppolicy l left join (select a.serverid,b.id from log_resourcegroup a left join log_resourcegroup b on a.groupname=b.groupname where a.serverid!=0 and b.serverid=0) t on l.resourcegroupid=t.id left join (select c.name,c.content,c.desc,d.id from log_policy c left join log_policygroup d on c.policyid=d.id ) r on r.id=l.policyid left join servers s on t.serverid=s.id left join login_template lt on s.device_type=lt.id where l.enable=1 order by `order` asc"); 
    $sqr_select->execute();
    while(my $ref_select = $sqr_select->fetchrow_hashref())
    {
        my $device_ip = $ref_select->{"device_ip"};
        my $device_type = $ref_select->{"device_type"};
        my $name = $ref_select->{"name"};
        my $content = $ref_select->{"content"};
        my $desc = $ref_select->{"desc"};
        my $action = $ref_select->{"action"};
        my $forward = $ref_select->{"forward"};
        my $save = $ref_select->{"save"};
        my $ip = $ref_select->{"ip"};
        my $warnmsg = $ref_select->{"warnmsg"};
        my $warnmail = $ref_select->{"warnmail"};

        unless(exists $tmp_policy{$device_ip})
        {
            my @tmp_arr;
            $tmp_policy{$device_ip} = \@tmp_arr;
        }

        my @tmp = ($content,$name,$save,$forward,$ip,$warnmail,$warnmsg,$desc,$device_type);
        push @{$tmp_policy{$device_ip}}, \@tmp;

    }
    $sqr_select->finish();

    $g_policy->down();
    $ref_policy = shared_clone(\%tmp_policy);
    $g_policy->up();

    $dbh->disconnect();
}

sub load_rule
{
    my($mysql_user,$mysql_passwd) = &get_local_mysql_config();
    my $dbh=DBI->connect("DBI:mysql:database=audit_sec;host=localhost;mysql_connect_timeout=5",$mysql_user,$mysql_passwd,{RaiseError=>1});
    my $utf8 = $dbh->prepare("set names utf8");
    $utf8->execute();
    $utf8->finish();

    my %tmp_rule;
    my $sqr_select=$dbh->prepare("select b.name,b.type,b.id,c.company,d.device_type,action,a.name rulename,a.code,a.desc,a.level from log_rule a left join log_rulename b on a.rulename_id=b.id left join log_company c on b.company=c.id left join login_template d on b.type=d.id where b.name is not null"); 
    $sqr_select->execute();
    while(my $ref_select = $sqr_select->fetchrow_hashref())
    {
        my $name = $ref_select->{"name"};
        my $type = $ref_select->{"type"};
        my $policyid = $ref_select->{"id"};
        my $company = $ref_select->{"company"};
        my $device_type = $ref_select->{"device_type"};
        my $action= $ref_select->{"action"};
        my $rulename = $ref_select->{"rulename"};
        my $code = $ref_select->{"code"};
        my $desc = $ref_select->{"desc"};
        my $level = $ref_select->{"level"};

        unless(exists $tmp_rule{$device_type})
        {
            my @tmp_arr;
            $tmp_rule{$device_type} = \@tmp_arr;
        }

        my @tmp = ($code,$policyid,$name,$type,$level);
        push @{$tmp_rule{$device_type}}, \@tmp;

    }
    $sqr_select->finish();

    $g_rule->down();
    $ref_rule = shared_clone(\%tmp_rule);
    $g_rule->up();

    $dbh->disconnect();
}

sub warning_process
{
    my($dbh,$time_now_str,$warnmail,$warnmsg,$desc,$log_host,$log_facility,$log_priority,$log_level,$log_tag,$log_datetime,$log_program,$log_msg) = @_;
    my $mail_status = -1;
    my $sms_status = -1;
    my $time_now = time;

    my($mailserver,$mailfrom,$mailpwd) = &load_mail_info($dbh);

    if($warnmail == 0)
    {
        $mail_status = 0;
    }
    else
    {
        $g_mail_msg->down();
        if(exists $mail_msg{$log_msg} && $mail_msg{$log_msg}>$time_now-$send_interval)
        {
            $mail_status = 3;
        }
        else
        {
            $mail_msg{$log_msg} = $time_now;
        }
        $g_mail_msg->up();
    }

    if($warnmsg == 0)
    {
        $sms_status = 0;
    }
    else
    {
        $g_sms_msg->down();
        if(exists $sms_msg{$log_msg} && $sms_msg{$log_msg}>$time_now-$send_interval)
        {
            $sms_status = 3;
        }
        else
        {
            $sms_msg{$log_msg} = $time_now;
        }
        $g_sms_msg->up();
    }

    if($mail_status == -1)
    {
        my $sqr_select = $dbh->prepare("select email from member where uid IN(select memberid from snmp_alert_user a left join snmp_alert b on a.snmp_alert_id=b.seq where (b.groupid=(select groupid from servers where device_ip='$log_host') or b.groupid=0) and b.enable=1) and email != ''");
        $sqr_select->execute();
        while(my $ref_select = $sqr_select->fetchrow_hashref())
        {
            my $email = $ref_select->{"email"};
            if(defined $email)
            {
                my $warning_msg;
                if(defined $desc)
                {
                    $warning_msg = "SYSLOG告警服务器:$log_host 说明:$desc 消息:$log_msg\n";
                }
                else
                {
                    $warning_msg = "SYSLOG告警服务器:$log_host $log_msg\n";
                }

                my $subject = "日志告警,$time_now_str\n";

                my $status = &send_mail($email,$subject,$warning_msg,$mailserver,$mailfrom,$mailpwd);
                if($status == 2)
                {
                    $mail_status = 2;
                }
            }
        }
        $sqr_select->finish();

        if($mail_status != 2)
        {
            $mail_status = 1;
        }
    }

    if($sms_status == -1)
    {
        my $sqr_select = $dbh->prepare("select mobilenum from member where uid IN(select memberid from snmp_alert_user a left join snmp_alert b on a.snmp_alert_id=b.seq where (b.groupid=(select groupid from servers where device_ip='$log_host') or b.groupid=0) and b.enable=1) and mobilenum != ''");
        $sqr_select->execute();
        while(my $ref_select = $sqr_select->fetchrow_hashref())
        {
            my $mobilenum = $ref_select->{"mobilenum"};
            if(defined $mobilenum)
            {
                my $warning_msg;
                if(defined $desc)
                {
                    $warning_msg = "SYSLOG告警服务器:$log_host 说明:$desc 消息:$log_msg\n";
                }
                else
                {
                    $warning_msg = "SYSLOG告警服务器:$log_host $log_msg\n";
                }

                my $status = &send_msg($mobilenum,$warning_msg);
                if($status == 2)
                {
                    $sms_status = 2;
                }
            }
        }
        $sqr_select->finish();

        if($sms_status != 2)
        {
            $sms_status = 1;
        }
    }

    my $sqr_insert = $dbh->prepare("insert into log_logs_warning(datetime,host,facility,priority,level,tag,program,msg,logserver,mail_status,sms_status) values('$log_datetime','$log_host','$log_facility','$log_priority','$log_level','$log_tag','$log_program','$log_msg','$log_server',$mail_status,$sms_status)");
    $sqr_insert->execute();
    $sqr_insert->finish();
}

sub poll_warning_hash
{
    my $time_now = time;

    $g_mail_msg->down();
    foreach my $msg(keys %mail_msg)
    {
        if($mail_msg{$msg} <= $time_now-$send_interval)
        {
            delete $mail_msg{$msg};
        }
    }
    $g_mail_msg->up();

    $g_sms_msg->down();
    foreach my $msg(keys %sms_msg)
    {
        if($sms_msg{$msg} <= $time_now-$send_interval)
        {
            delete $sms_msg{$msg};
        }
    }
    $g_sms_msg->up();
}

sub read_conf
{
    open(my $fd_fr, "<$conf_path");

    while(my $line=<$fd_fr>)
    {
        chomp $line;
        if($line =~ /^\s*#/)
        {
            next;
        }

        if($line =~ /^\s*logserver=\s*([^\s\#]*)/i)
        {
            $log_server = $1;
        }
        elsif($line =~ /^\s*fifo=\s*([^\s\#]*)/i)
        {
            $fifo = $1;
        }
        elsif($line =~ /^\s*log_path=\s*([^\s\#]*)/i)
        {
            $log_path = $1;
            $log_path =~ s/\/$//;
        }
        elsif($line =~ /^\s*debug_file=\s*([^\s\#]*)/i)
        {
            $debug_file = $1;
        }
        elsif($line =~ /^\s*mysql_log_host=\s*([^\s\#]*)/i)
        {
            $mysql_log_host = $1;
        }
        elsif($line =~ /^\s*send_interval=\s*([^\s\#]*)/i)
        {
            $send_interval = $1;
            if($send_interval =~ /\d+/)
            {
                $send_interval *= 60;
            }
            else
            {
                $send_interval = 30 * 60;
            }
        }
        elsif($line =~ /^\s*load_policy_interval=\s*([^\s\#]*)/i)
        {
            $load_policy_interval = $1;
            unless($load_policy_interval =~ /\d+/)
            {
                $load_policy_interval = 300;
            }
        }
        elsif($line =~ /^\s*load_rule_interval=\s*([^\s\#]*)/i)
        {
            $load_rule_interval = $1;
            unless($load_rule_interval =~ /\d+/)
            {
                $load_rule_interval = 300;
            }
        }
        elsif($line =~ /^\s*warning_hash_interval=\s*([^\s\#]*)/i)
        {
            $warning_hash_interval = $1;
            unless($warning_hash_interval =~ /\d+/)
            {
                $warning_hash_interval = 300;
            }
        }
    }

    close $fd_fr;
}

sub load_mail_info
{
    my($dbh) = @_;

    my $mail = $dbh->prepare("select mailserver,account,password from alarm");
    $mail->execute();
    my $ref_mail = $mail->fetchrow_hashref();
    my $mailserver = $ref_mail->{"mailserver"};
    my $mailfrom = $ref_mail->{"account"};
    my $mailpwd = $ref_mail->{"password"};
    $mail->finish();

    return ($mailserver,$mailfrom,$mailpwd);
}

sub get_level_num
{
    my($log_level) = @_;
    if($log_level =~ /emerg/i || $log_level =~ /panic/i)
    {
        return 0;
    }
    elsif($log_level =~ /alert/i)
    {
        return 1;
    }
    elsif($log_level =~ /crit/i)
    {
        return 2;
    }
    elsif($log_level =~ /err/i || $log_level =~ /error/i)
    {
        return 3;
    }
    elsif($log_level =~ /warning/i || $log_level =~ /warn/i)
    {
        return 4;
    }
    elsif($log_level =~ /notice/i)
    {
        return 5;
    }
    elsif($log_level =~ /info/i)
    {
        return 6;
    }
    elsif($log_level =~ /debug/i)
    {
        return 7;
    }
    else
    {
        return -1;
    }
}

sub write_syslog
{
    my($host,$log) = @_;

    my $time_now_utc = time;
    my ($mday,$mon,$year) = (localtime $time_now_utc)[3..5];
    ($mday,$mon,$year) = (sprintf("%02d", $mday),sprintf("%02d", $mon+1),$year+1900);
    my $date_now_str = "$year-$mon-$mday";

    my $dir = "$log_path/$date_now_str";
    unless(-e $dir)
    {
        mkdir $dir,0755;
    }

    open(my $fd_fw,">>$log_path/$date_now_str/$host.log");
    print $fd_fw $log,"\n";
    close $fd_fw;
}

sub write_debug_log
{
    my($info) = @_;

    my $time_now_utc = time;
    my($sec,$min,$hour,$mday,$mon,$year) = (localtime $time_now_utc)[0..5];
    ($sec,$min,$hour,$mday,$mon,$year) = (sprintf("%02d", $sec),sprintf("%02d", $min),sprintf("%02d", $hour),sprintf("%02d", $mday),sprintf("%02d", $mon+1),$year+1900);
    my $time_now_str = "$year-$mon-$mday $hour:$min:$sec";

    open(my $fd_fw,">>$debug_file");
    flock($fd_fw, LOCK_EX);
    seek($fd_fw,0,2);
    print $fd_fw "$time_now_str\t$info\n";
    flock($fd_fw, LOCK_UN);
    close $fd_fw;
}

sub send_mail
{
    my($mailto,$subject,$msg,$mailserver,$mailfrom,$mailpwd) = @_;

#   print "$mailto,$msg\n";
    my $sender = new Mail::Sender;
    $subject = encode("gb2312", decode("utf8", $subject));           #freesvr 专用;
    $msg = encode("gb2312", decode("utf8", $msg));              #freesvr 专用;

    if ($sender->MailMsg({
                smtp => $mailserver,
                from => $mailfrom,
                to => $mailto,
                subject => $subject,
                msg => $msg,
                auth => 'LOGIN',
                authid => $mailfrom,
                authpwd => $mailpwd,
                })<0){
        return 2;
    }
    else
    {
        return 1;
    }
}

sub send_msg
{
    my ($mobile_tel,$msg) = @_;
    my $sp_no = "955589903";
    my $mobile_type = "1";
    $msg =  encode("gb2312", decode("utf8", $msg));
    $msg = uri_escape($msg);

    my $url = "http://192.168.4.71:8080/smsServer/service.action?branch_no=10&password=010&depart_no=10001&message_type=1&batch_no=4324&priority=1&sp_no=$sp_no&mobile_type=$mobile_type&mobile_tel=$mobile_tel&message=$msg";

    $url = URI::URL->new($url);

    if(system("wget -t 1 -T 3 '$url' -O - 1>/dev/null 2>&1") == 0)
    {
        return 1;
    }
    else
    {
        return 2;
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
