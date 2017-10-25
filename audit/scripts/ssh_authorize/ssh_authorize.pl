#!/usr/bin/perl
use warnings;
use strict;
use DBI;
use DBD::mysql;
use Expect;
use Getopt::Long;
use File::Copy;
use File::Basename;
use Mail::Sender;
use Encode;
use Digest::MD5 qw(md5_base64);
use String::MkPasswd qw(mkpasswd);
use Crypt::CBC;
use MIME::Base64;

our($mysql_user,$mysql_passwd) = &get_local_mysql_config();
our $mode = 3;
our $is_force = 0;
our $group_name = undef;
our $server_name = undef;
our $user_name = undef;
our $passwd = undef;

our $time_now_utc = time;
my($min,$hour,$mday,$mon,$year) = (localtime $time_now_utc)[1..5];
($min,$hour,$mday,$mon,$year) = (sprintf("%02d", $min),sprintf("%02d", $hour),sprintf("%02d", $mday),sprintf("%02d", $mon + 1),$year+1900);
our $time_now_str = "$year$mon$mday$hour$min"."00";

our %ssh_key_info;
GetOptions(
    "m=i"   =>  \$mode,
    "g=s"   =>  \$group_name,
    "s=s"   =>  \$server_name,
    "u=s"   =>  \$user_name,
    "p=s"   =>  \$passwd,
    "f"     =>  \$is_force,
    );

if($mode!=1 && $mode!=2 && $mode!=3)
{
    print "use -m to indicate mode: \n";
    print "1 only change pub/pvt keys\n";
    print "2 only change password\n";
    print "3 change password and pub/pvt keys\n";
    exit 1;
}

&log_process("INFO","===============Program Start==================");

our $dbh=DBI->connect("DBI:mysql:database=audit_sec;host=localhost;mysql_connect_timeout=5",$mysql_user,$mysql_passwd,{RaiseError=>1});
our $utf8 = $dbh->prepare("set names utf8");
$utf8->execute();
$utf8->finish();

&load_db_info();
&handle_condition();
if(scalar keys %ssh_key_info == 0)
{
    exit 0;
}
if($mode == 1 || $mode == 3)
{
    &init_env();
    &pub_key_process();
}

if($mode == 2 || $mode == 3)
{
    unless(-e "/opt/freesvr/audit/sshgw-audit/keys/backups/backup_$time_now_str")
    {
        `mkdir -p /opt/freesvr/audit/sshgw-audit/keys/backups/backup_$time_now_str`;
    }
    &change_passwd();
}

&store_result();
&package();
&mail_process();

$dbh->disconnect();

sub pub_key_process
{
    &log_process("INFO","------------Change authorized keys process-------------");
    my @success_device_id;
    my @fail_device_id;

    `cp -r /opt/freesvr/audit/sshgw-audit/keys/authorized_keys/ /opt/freesvr/audit/sshgw-audit/keys/backups/backup_$time_now_str/authorized_keys_old`;
    foreach my $sshkeyname(keys %ssh_key_info)
    {
        my $success_flag = 0;
        my $sshprivatekey = $ssh_key_info{$sshkeyname}->[0];
        my $sshpublickey = $ssh_key_info{$sshkeyname}->[1];

        &log_process("INFO","copy old key pair to /opt/freesvr/audit/sshgw-audit/keys/pvt_old/ & /opt/freesvr/audit/sshgw-audit/keys/pub_old/");
        copy($sshprivatekey, ("/opt/freesvr/audit/sshgw-audit/keys/pvt_old/". basename $sshprivatekey));
        copy($sshpublickey, ("/opt/freesvr/audit/sshgw-audit/keys/pub_old/". basename $sshpublickey));
        &log_process("INFO","finish copy old key pair to /opt/freesvr/audit/sshgw-audit/keys/pvt_old/ & /opt/freesvr/audit/sshgw-audit/keys/pub_old/");

        &log_process("INFO","generate new pub/pvt key for $sshpublickey");
        if(&generate_keys(basename $sshprivatekey))
        {
            foreach my $ref(@{$ssh_key_info{$sshkeyname}->[2]})
            {
                push @fail_device_id, $ref->[0];
            }
            next;
        }

        &log_process("INFO","copy new key pair to /opt/freesvr/audit/sshgw-audit/keys/pvt_new/ & /opt/freesvr/audit/sshgw-audit/keys/pub_new/");
        copy(("/tmp/". basename $sshprivatekey), ("/opt/freesvr/audit/sshgw-audit/keys/pvt_new/". basename $sshprivatekey));
        copy(("/tmp/". basename $sshprivatekey. ".pub"), ("/opt/freesvr/audit/sshgw-audit/keys/pub_new/". basename $sshpublickey));
        if((chmod 0400, ("/opt/freesvr/audit/sshgw-audit/keys/pvt_new/". basename $sshprivatekey),("/opt/freesvr/audit/sshgw-audit/keys/pub_new/". basename $sshpublickey)) != 2)
        {
            &log_process("ERROR","change mode for new key pair error in /opt/freesvr/audit/sshgw-audit/keys/pub_new/". basename $sshpublickey);
            foreach my $ref(@{$ssh_key_info{$sshkeyname}->[2]})
            {
                push @fail_device_id, $ref->[0];
            }
            next;
        }
        &log_process("INFO","finish copy new key pair to /opt/freesvr/audit/sshgw-audit/keys/pvt_new/ & /opt/freesvr/audit/sshgw-audit/keys/pub_new/");
        unlink "/tmp/". basename $sshprivatekey;
        unlink "/tmp/". basename $sshprivatekey. ".pub";

        my $pubkey = &get_pub_key("/opt/freesvr/audit/sshgw-audit/keys/pub_new/". basename $sshpublickey);
        foreach my $ref(@{$ssh_key_info{$sshkeyname}->[2]})
        {
            my $device_id = $ref->[0];
            my $device_ip = $ref->[1];
            my $user = $ref->[2];
            my $port = $ref->[3];

            if(system("/home/wuxiaolong/ssh_authorize/ssh_test.pl -h $device_ip -p $port -i $sshprivatekey -u $user")!=0)
            {
                &log_process("ERROR","cannot ssh to $device_ip by $user with pvt key $sshprivatekey\n");
                push @fail_device_id, $device_id;
                next;
            }

            &log_process("INFO","modify authorized_key for $user\@$device_ip");
            unless(-e "/opt/freesvr/audit/sshgw-audit/keys/authorized_keys/${device_ip}_${user}")
            {
                &log_process("ERROR","authorized_keys for ${device_ip}_${user} not exists");
                push @fail_device_id, $device_id;
                next;
            }

            &modify_authorized_key($device_id,$pubkey,"/opt/freesvr/audit/sshgw-audit/keys/authorized_keys/${device_ip}_${user}");
            &log_process("INFO","finish modify authorized_key for $device_ip");

            &log_process("INFO","scp authorized_key to $user\@$device_ip");
            if(&scp_to_remote($device_ip,$user,$port,$sshprivatekey,"/opt/freesvr/audit/sshgw-audit/keys/authorized_keys/${device_ip}_${user}") !=0)
            {
                &log_process("ERROR","scp authorized_key to $user\@$device_ip failed");
                push @fail_device_id, $device_id;
                next;
            }
            &log_process("INFO","finish scp authorized_key to $user\@$device_ip");

            $success_flag = 1;
            $ref->[4] = 1;
            push @success_device_id, $device_id;
        }

        &log_process("INFO","copy new key pair to $sshprivatekey & $sshpublickey");
        copy(("/opt/freesvr/audit/sshgw-audit/keys/pvt_new/". basename $sshprivatekey), $sshprivatekey);
        copy(("/opt/freesvr/audit/sshgw-audit/keys/pub_new/". basename $sshpublickey), $sshpublickey);
        &log_process("INFO","finish copy new key pair to $sshprivatekey & $sshpublickey");
    }

    &log_process("INFO","backup pub/pvt keys and authorized_keys");
    `cp -r /opt/freesvr/audit/sshgw-audit/keys/authorized_keys/ /opt/freesvr/audit/sshgw-audit/keys/backups/backup_$time_now_str/authorized_keys_new`;
    `cp -r /opt/freesvr/audit/sshgw-audit/keys/pvt_new/ /opt/freesvr/audit/sshgw-audit/keys/backups/backup_$time_now_str`;
    `cp -r /opt/freesvr/audit/sshgw-audit/keys/pub_new/ /opt/freesvr/audit/sshgw-audit/keys/backups/backup_$time_now_str`;
    `cp -r /opt/freesvr/audit/sshgw-audit/keys/pvt_old/ /opt/freesvr/audit/sshgw-audit/keys/backups/backup_$time_now_str`;
    `cp -r /opt/freesvr/audit/sshgw-audit/keys/pub_old/ /opt/freesvr/audit/sshgw-audit/keys/backups/backup_$time_now_str`;
    &log_process("INFO","all pub/pvt change finish");
    &log_process("INFO","======success id(s): ".join(",",@success_device_id)."======");
    &log_process("INFO","======failed id(s): ".join(",",@fail_device_id)."======");
}

sub change_passwd
{
    &log_process("INFO","------------Change password process-------------");
    my $sqr_select = $dbh->prepare("select * from password_policy");
    $sqr_select->execute();
    my $ref_select = $sqr_select->fetchrow_hashref();
    my $minlen = $ref_select->{"minlen"};
    my $minalpha = $ref_select->{"minalpha"};
    my $minother = $ref_select->{"minother"};
    my $mindiff = $ref_select->{"mindiff"};
    my $maxrepeats = $ref_select->{"maxrepeats"};
    my $histexpire = $ref_select->{"histexpire"};
    my $histsize = $ref_select->{"histsize"};
    $sqr_select->finish();

    open(my $fd_fw, ">/opt/freesvr/audit/sshgw-audit/keys/backups/backup_$time_now_str/passwd_info.csv");
    print $fd_fw "device_ip,username,cur_password,new_password,old_password\n";

    my @success_device_id;
    my @fail_device_id;

    foreach my $sshkeyname(keys %ssh_key_info)
    {
        foreach my $ref(@{$ssh_key_info{$sshkeyname}->[2]})
        {
            my $device_id = $ref->[0];
            my $device_ip = $ref->[1];
            my $username = $ref->[2];
            my $port = $ref->[3];
            my $new_password_r;

            &log_process("INFO","begin to change passwd for $username\@$device_ip");
            my $passwd_sql = "
                select 
                ifnull(old_password,'') old_password, ifnull(udf_decrypt(old_password),'') old_password_r, ifnull(cur_password,'') cur_password, ifnull(udf_decrypt(cur_password),'') cur_password_r 
                from devices where id=$device_id";
            $sqr_select = $dbh->prepare("$passwd_sql");
            $sqr_select->execute();
            $ref_select = $sqr_select->fetchrow_hashref();
            my $old_password = $ref_select->{"old_password"};
            my $old_password_r = $ref_select->{"old_password_r"};
            my $cur_password = $ref_select->{"cur_password"};
            my $cur_password_r = $ref_select->{"cur_password_r"};
            $sqr_select->finish();

            my $autosu_sql = "
                select username,autosu,b.sshpublickey,b.sshprivatekey from devices as d
                join sshkey as a on a.devicesid=d.id
                join sshkeyname b on a.sshkeyname=b.id
                where device_ip='$device_ip' and master_user=1";
            $sqr_select = $dbh->prepare("$autosu_sql");
            $sqr_select->execute();
            $ref_select = $sqr_select->fetchrow_hashref();
            my $login_user = $ref_select->{"username"};
            my $autosu = $ref_select->{"autosu"};
            my $sshprivatekey = $ref_select->{"sshprivatekey"};
            $sqr_select->finish();

            my $superpasswd = undef;
            if($autosu == 1)
            {
                $sqr_select = $dbh->prepare("select udf_decrypt(superpassword) superpasswd from servers where device_ip='$device_ip'");
                $sqr_select->execute();
                $ref_select = $sqr_select->fetchrow_hashref();
                $superpasswd = $ref_select->{"superpasswd"};
                $sqr_select->finish();
            }

            if($autosu == 1 && !defined $superpasswd)
            {
                &log_process("ERROR","$device_ip cannot find su passwd");
                print $fd_fw "$device_ip,$username,$cur_password,,$old_password\n";
                push @fail_device_id, $device_id;
                next;
            }

            if(defined $passwd)
            {
                if(&check_passwd($passwd,$cur_password_r,$maxrepeats,$mindiff)!=0)
                {
                    &log_process("ERROR","device_id $device_id, passwd $passwd don't satisfy password policy with passwd: $cur_password_r");
                    print $fd_fw "$device_ip,$username,$cur_password,,$old_password\n";
                    push @fail_device_id, $device_id;
                    next;
                }
                elsif(&passwd_lookback($device_id,$cur_password_r,$histexpire,$histsize)!=0)
                {
                    &log_process("ERROR","device_id $device_id, passwd $passwd same with old passwd");
                    print $fd_fw "$device_ip,$username,$cur_password,,$old_password\n";
                    push @fail_device_id, $device_id;
                    next;
                }
                $new_password_r = $passwd;
            }
            else
            {
                $new_password_r = &random_passwd($cur_password_r,$minlen,$minalpha,$minother,$maxrepeats,$mindiff);
            }

            my $new_password = &get_crypt_passwd($new_password_r);
            my $sqr_update = $dbh->prepare("update devices set new_password=udf_encrypt('$new_password_r') where id=$device_id");
            $sqr_update->execute();
            $sqr_update->finish();

            &generate_known_host($device_ip,$port);
            my $exp = &ssh_login($device_ip,$login_user,$port,$sshprivatekey);
            unless(defined $exp)
            {
                &log_process("ERROR","login $username\@$device_ip:$port failed");
                print $fd_fw "$device_ip,$username,$cur_password,$new_password,$old_password\n";
                push @fail_device_id, $device_id;
                next;
            }
            &log_process("INFO","login $username\@$device_ip:$port success");

            if($autosu == 1)
            {
                if(&su_process($exp,$superpasswd) != 0)
                {
                    &log_process("ERROR","su to root failed on $device_ip");
                    print $fd_fw "$device_ip,$username,$cur_password,$new_password,$old_password\n";
                    push @fail_device_id, $device_id;
                    next;
                }
                &log_process("INFO","su to root succcess on $device_ip");
            }

            my $cmd = "echo '$new_password_r' | passwd $username --stdin;echo \"get status: \$?\"";
            my $status = &get_output($exp,$cmd,"status");
            if($status != 0)
            {
                &log_process("ERROR","$device_ip set $username passwd fail");
                print $fd_fw "$device_ip,$username,$cur_password,$new_password,$old_password\n";
                push @fail_device_id, $device_id;
                next;
            }
            &log_process("INFO","$device_ip set $username passwd succcess");

            push @success_device_id, $device_id;
            $ref->[5] = 1;
            &log_process("INFO","$device_ip set $username passwd success, new passwd: $new_password");

            $old_password = $cur_password;
            $old_password_r = $cur_password_r;
            $cur_password = $new_password;
            $cur_password_r = $new_password_r;

            print $fd_fw "$device_ip,$username,$cur_password,$new_password,$old_password\n";

            $sqr_update = $dbh->prepare("update devices set cur_password=udf_encrypt('$cur_password_r'),old_password=udf_encrypt('$old_password_r') where id=$device_id");
            $sqr_update->execute();
            $sqr_update->finish();

            if(defined $passwd)
            {
                my $hash = md5_base64 $passwd;
                my $sqr_insert = $dbh->prepare("insert into passwordlog(uid,password,time) values($device_id,'$hash',$time_now_utc)");
                $sqr_insert->execute();
                $sqr_insert->finish();
            }
            $exp->close();
        }
    }

    close $fd_fw;
    &log_process("INFO","all password change finish");
    &log_process("INFO","======success id(s): ".join(",",@success_device_id)."======");
    &log_process("INFO","======failed id(s): ".join(",",@fail_device_id)."======");
}

sub store_result
{
    foreach my $sshkeyname(keys %ssh_key_info)
    {
        foreach my $ref(@{$ssh_key_info{$sshkeyname}->[2]})
        {
            my $device_id = $ref->[0];
            my $device_ip = $ref->[1];
            my $username = $ref->[2];

            my $pubkey_result = "No";
            if($ref->[4] == 1)
            {
                $pubkey_result = "Yes";
            }

            my $passwd_result = "No";
            if($ref->[5] == 1)
            {
                $passwd_result = "Yes";
            }

            if($mode == 1 || $mode == 3)
            {
                my $sqr_insert = $dbh->prepare("insert into `log`(time,device_ip,username,update_success_flag,password) values('$time_now_str','$device_ip','$username','$pubkey_result','0')");
                $sqr_insert->execute();
                $sqr_insert->finish();
            }

            if($mode == 2 || $mode == 3)
            {
                my $sqr_insert = $dbh->prepare("insert into `log`(time,device_ip,username,update_success_flag,password) values('$time_now_str','$device_ip','$username','$passwd_result','1')");
                $sqr_insert->execute();
                $sqr_insert->finish();
            }

            my $result = 0;
            if($mode == 1 && $ref->[4] == 1)
            {
                $result = 1;
            }
            elsif($mode == 2 && $ref->[5] == 1)
            {
                $result = 1;
            }
            elsif($ref->[4] == 1 && $ref->[5] == 1)
            {
                $result = 1;
            }

            if($result == 1)
            {
                my $sqr_update = $dbh->prepare("update devices set last_update_time='$time_now_str' where id=$device_id");
                $sqr_update->execute();
                $sqr_update->finish();
            }
        }
    }
}

sub package
{
    &log_process("INFO","start compress files");
    my $cur_path = $ENV{'PWD'};
    chdir "/opt/freesvr/audit/sshgw-audit/keys/backups/";

    my $sqr_select = $dbh->prepare("select udf_decrypt(password) zip_passwd from password_crypt order by id desc limit 1");
    $sqr_select->execute();
    my $ref_select = $sqr_select->fetchrow_hashref();
    my $zip_passwd = $ref_select->{"zip_passwd"};
    $sqr_select->finish();

    my $zip_cmd = "zip -qr -P $zip_passwd ./backup_$time_now_str.zip ./backup_$time_now_str";
    print $zip_cmd,"\n";
    system($zip_cmd);
    `rm -fr /opt/freesvr/audit/sshgw-audit/keys/backups/backup_$time_now_str`;
    chdir $cur_path;
    &log_process("INFO","finish compress files");
}

sub mail_process
{
    &log_process("INFO","sending email...");
    my $mail = $dbh->prepare("select mailserver,account,password from alarm");
    $mail->execute();
    my $ref_mail = $mail->fetchrow_hashref();
    my $mailserver = $ref_mail->{"mailserver"};
    my $mailfrom = $ref_mail->{"account"};
    my $mailpwd = $ref_mail->{"password"};
    $mail->finish();

    my @mail_to;
    my $sqr_select = $dbh->prepare("select email from member where username='password'");
    $sqr_select->execute();
    while(my $ref_select = $sqr_select->fetchrow_hashref())
    {
        my $email = $ref_select->{"email"};
        unless(defined $email && !($email =~ /^\s+$/))
        {
            next;
        }
        push @mail_to, $email;
    }
    $sqr_select->finish();

    my $subject = "密码文件备份 $time_now_str";
    my $msg = "密码文件备份 $time_now_str";
    my $status = &send_mail(join(",", @mail_to),$subject,$msg,"/opt/freesvr/audit/sshgw-audit/keys/backups/backup_$time_now_str.zip",$mailserver,$mailfrom,$mailpwd);
    if($status == 1)
    {
        &log_process("INFO","send email success");
    }
    else
    {
        &log_process("INFO","send email fail");
    }
}

sub scp_to_remote
{
    my($device_ip,$user,$port,$sshprivatekey,$authorized_key) = @_;
    my $cmd = "scp -i $sshprivatekey -P $port $authorized_key $user\@$device_ip:~/.ssh/authorized_keys";
    &log_process("INFO","scp authorized_key by $cmd");
    if(system($cmd) != 0)
    {
        &log_process("ERROR","scp authorized_key for $device_ip, user: $user error");
        return 1;
    }
    return 0;
}

sub modify_authorized_key
{
    my($device_id,$pubkey,$authorized_key) = @_;

    my @cache;
    open(my $fd_fr, "<$authorized_key");
    while(my $line = <$fd_fr>)
    {
        chomp $line;
        if((split /\s+/,$line)[2] eq $device_id)
        {
            $line = "$pubkey $device_id";
        }
        push @cache,$line;
    }
    close $fd_fr;

    open(my $fd_fw, ">$authorized_key");
    foreach my $line(@cache)
    {
        print $fd_fw $line,"\n";
    }
    close $fd_fw;
}

sub get_pub_key
{
    my($pub_key_file) = @_;
    my $pubkey = "";
    open(my $fd_fr, "<$pub_key_file");
    while(my $line = <$fd_fr>)
    {
        chomp $line;
        $pubkey = $line;
    }
    close $fd_fr;
    return $pubkey;
}

sub generate_keys
{
    my($key_file) = @_;

    if(system("ssh-keygen -t rsa -N \"\" -C \"\" -f /tmp/$key_file") != 0)
    {
        &log_process("ERROR","ssh-keygen error for $key_file");
        foreach my $file(glob "/tmp/$key_file"."*")
        {
            unlink $file;
        }
        return 1;
    }
    &log_process("INFO","generate ssh key in /tmp/$key_file");
    return 0;
}

sub init_env
{
    if($mode == 1 || $mode == 3)
    {
        `rm -fr /opt/freesvr/audit/sshgw-audit/keys/pvt_old`;
        `cp -r /opt/freesvr/audit/sshgw-audit/keys/pvt /opt/freesvr/audit/sshgw-audit/keys/pvt_old`;

        `rm -fr /opt/freesvr/audit/sshgw-audit/keys/pvt_new`;
        `cp -r /opt/freesvr/audit/sshgw-audit/keys/pvt /opt/freesvr/audit/sshgw-audit/keys/pvt_new`;

        `rm -fr /opt/freesvr/audit/sshgw-audit/keys/pub_old`;
        `cp -r /opt/freesvr/audit/sshgw-audit/keys/pub /opt/freesvr/audit/sshgw-audit/keys/pub_old`;

        `rm -fr /opt/freesvr/audit/sshgw-audit/keys/pub_new`;
        `cp -r /opt/freesvr/audit/sshgw-audit/keys/pub /opt/freesvr/audit/sshgw-audit/keys/pub_new`;
    }
=pod
    unless(-e "/opt/freesvr/audit/sshgw-audit/keys/pvt_old")
    {
        `cp -r /opt/freesvr/audit/sshgw-audit/keys/pvt /opt/freesvr/audit/sshgw-audit/keys/pvt_old`;
    }

    unless(-e "/opt/freesvr/audit/sshgw-audit/keys/pvt_new")
    {
        `cp -r /opt/freesvr/audit/sshgw-audit/keys/pvt /opt/freesvr/audit/sshgw-audit/keys/pvt_new`;
    }

    unless(-e "/opt/freesvr/audit/sshgw-audit/keys/pub_old")
    {
        `cp -r /opt/freesvr/audit/sshgw-audit/keys/pub /opt/freesvr/audit/sshgw-audit/keys/pub_old`;
    }

    unless(-e "/opt/freesvr/audit/sshgw-audit/keys/pub_new")
    {
        `cp -r /opt/freesvr/audit/sshgw-audit/keys/pub /opt/freesvr/audit/sshgw-audit/keys/pub_new`;
    }
=cut

    unless(-e "/opt/freesvr/audit/sshgw-audit/keys/backups")
    {
        `mkdir -p /opt/freesvr/audit/sshgw-audit/keys/backups`;
    }

    unless(-e "/opt/freesvr/audit/sshgw-audit/keys/backups/backup_$time_now_str")
    {
        `mkdir -p /opt/freesvr/audit/sshgw-audit/keys/backups/backup_$time_now_str`;
    }


    unless(-e "/opt/freesvr/audit/sshgw-audit/keys/authorized_keys")
    {
        &log_process("ERROR","authorized_keys for authorized_keys not exists");
        exit 1;
    }
}

sub handle_condition
{
    my $load_modify_sql = undef;

    if(defined $group_name)
    {
        &log_process("INFO","change ssh authorize for group: $group_name");
        $load_modify_sql = "
            select 
            d.id,b.sshkeyname
            from sshkey a 
            left join sshkeyname b on a.sshkeyname=b.id 
            left join devices d on a.devicesid=d.id
            left join servers s on s.device_ip=d.device_ip
            left join servergroup sg on s.groupid=sg.id
            where b.id is not null and sg.groupname='$group_name'";
    }
    elsif(defined $server_name && !defined $user_name)
    {
        &log_process("INFO","change ssh authorize for server: $server_name");
        $load_modify_sql = "
            select 
            d.id,b.sshkeyname
            from sshkey a 
            left join sshkeyname b on a.sshkeyname=b.id 
            left join devices d on a.devicesid=d.id
            left join servers s on s.device_ip=d.device_ip
            where b.id is not null and s.device_ip='$server_name'";

    }
    elsif(defined $server_name && defined $user_name)
    {
        &log_process("INFO","change ssh authorize for $user_name\@$server_name");
        $load_modify_sql = "
            select 
            d.id,b.sshkeyname
            from sshkey a 
            left join sshkeyname b on a.sshkeyname=b.id 
            left join devices d on a.devicesid=d.id
            left join servers s on s.device_ip=d.device_ip
            where b.id is not null and s.device_ip='$server_name' and d.username='$user_name'";
    }

    if(defined $load_modify_sql)
    {
        my %condition_hash;
        my $sqr_select = $dbh->prepare($load_modify_sql);
        $sqr_select->execute();
        while(my $ref_select = $sqr_select->fetchrow_hashref())
        {
            my $device_id = $ref_select->{"id"};
            my $sshkeyname = $ref_select->{"sshkeyname"};
            unless(defined $sshkeyname)
            {
                $sshkeyname = "NULL";
            }

            unless(exists $condition_hash{$sshkeyname})
            {
                my %tmp;
                $condition_hash{$sshkeyname} = \%tmp;
            }
            $condition_hash{$sshkeyname}->{$device_id} = 1;
        }
        $sqr_select->finish();

        foreach my $key(keys %ssh_key_info)
        {
            unless(exists $condition_hash{$key})
            {
                delete $ssh_key_info{$key};
            }
        }

        if($mode==2)
        {
            foreach my $sshkeyname(keys %ssh_key_info)
            {
                my @cache;
                foreach my $ref(@{$ssh_key_info{$sshkeyname}->[2]})
                {
                    my $device_id = $ref->[0];
                    if(exists $condition_hash{$sshkeyname}->{$device_id})
                    {
                        push @cache,$ref;
                    }
                }
                $ssh_key_info{$sshkeyname}->[2] = \@cache;
            }
        }
        else
        {
            foreach my $key(keys %condition_hash)
            {
                my @ssh_device;
                my @cond_device = keys %{$condition_hash{$key}};

                if(exists $ssh_key_info{$key})
                {
                    foreach my $ref(@{$ssh_key_info{$key}->[2]})
                    {
                        push @ssh_device, $ref->[0];
                    }
                }
                @ssh_device = sort(@ssh_device);
                @cond_device = sort(@cond_device);

                my $str1 = join(",",@ssh_device);
                my $str2 = join(",",@cond_device);

                if($str1 ne $str2)
                {
                    &log_process("ERROR","condition devices conflict with ssh device in ssh key: $key, condition device $str2, ssh device $str1");
                    exit 1;
                }
            }
        }
    }

    my @result;
    foreach my $sshkeyname(keys %ssh_key_info)
    {
        foreach my $ref(@{$ssh_key_info{$sshkeyname}->[2]})
        {
            push @result, $ref->[0];
        }
    }

    &log_process("INFO","====== Process Device List ======");
    &log_process("INFO","Device id: ".join(",",@result));
}

sub load_db_info
{
    my %not_modify_key;
    my $load_modify_sql = "
        select 
        d.id,d.device_ip,d.username,d.port,d.automodify,unix_timestamp(d.last_update_time) last_update_time,s.month,s.week,s.user_define,b.sshkeyname,b.sshprivatekey,b.sshpublickey,udf_decrypt(b.keypassword) keypassword 
        from sshkey a 
        left join sshkeyname b on a.sshkeyname=b.id 
        left join devices d on a.devicesid=d.id
        left join servers s on s.device_ip=d.device_ip
        where b.id is not null order by sshprivatekey";

    my $sqr_select = $dbh->prepare($load_modify_sql);
    $sqr_select->execute();
    while(my $ref_select = $sqr_select->fetchrow_hashref())
    {
        my $device_id = $ref_select->{"id"};
        my $device_ip = $ref_select->{"device_ip"};
        my $username = $ref_select->{"username"};
        my $port = $ref_select->{"port"};
        my $automodify = $ref_select->{"automodify"};
        my $last_update_time = $ref_select->{"last_update_time"};
        my $month = $ref_select->{"month"};
        my $week = $ref_select->{"week"};
        my $user_define = $ref_select->{"user_define"};
        my $sshkeyname = $ref_select->{"sshkeyname"};
        my $sshprivatekey = $ref_select->{"sshprivatekey"};
        my $sshpublickey = $ref_select->{"sshpublickey"};
        my $keypassword = $ref_select->{"keypassword"};

        if($automodify == 0)
        {
            if($mode!=2)
            {
                if(exists $ssh_key_info{$sshkeyname})
                {
                    delete $ssh_key_info{$sshkeyname};
                }

                unless(exists $not_modify_key{$sshkeyname})
                {
                    $not_modify_key{$sshkeyname} = 1;
                }
            }
            next;
        }

        if(exists $not_modify_key{$sshkeyname})
        {
            next;
        }

        if($is_force)
        {
            unless(exists $ssh_key_info{$sshkeyname})
            {
                my @tmp;
                my @key_info = ($sshprivatekey,$sshpublickey,\@tmp);
                $ssh_key_info{$sshkeyname} = \@key_info;
            }
            my @user_info = ($device_id,$device_ip,$username,$port,0,0);
            push @{$ssh_key_info{$sshkeyname}->[2]}, \@user_info;
        }
        elsif(&check_modify($last_update_time,$month,$week,$user_define))
        {
            unless(exists $ssh_key_info{$sshkeyname})
            {
                my @tmp;
                my @key_info = ($sshprivatekey,$sshpublickey,\@tmp);
                $ssh_key_info{$sshkeyname} = \@key_info;
            }
            my @user_info = ($device_id,$device_ip,$username,$port,0,0);
            push @{$ssh_key_info{$sshkeyname}->[2]}, \@user_info;
        }
        else
        {
            if($mode!=2)
            {
                if(exists $ssh_key_info{$sshkeyname})
                {
                    delete $ssh_key_info{$sshkeyname};
                }

                unless(exists $not_modify_key{$sshkeyname})
                {
                    $not_modify_key{$sshkeyname} = 1;
                }
            }
        }
    }
    $sqr_select->finish();
}

sub passwd_lookback
{
    my($device_id,$new_passwd,$histexpire,$histsize) = @_;
    my $hash = md5_base64 $new_passwd;
    my $interval = $histexpire * 3600 * 24;
    my $ret = 0;

    my $sqr_select = $dbh->prepare("select password from passwordlog where uid=$device_id and time>=($time_now_utc-$interval) order by id desc limit $histsize");
    $sqr_select->execute();
    while(my $ref_select = $sqr_select->fetchrow_hashref())
    {
        my $password = $ref_select->{"password"};
        if($hash eq $password)
        {
            $ret = 1;
            last;
        }
    }
    $sqr_select->finish();
    return $ret;
}

sub random_passwd
{
    my($old_passwd,$minlen,$minalpha,$minother,$maxrepeats,$mindiff) = @_;

    my $new_passwd = undef;
    my $check_ret = 1;
    while(!defined $new_passwd || $check_ret)
    {
        if($minother == 0) {$minother = 1;}

        $new_passwd = mkpasswd(
            -length     => $minlen,
            -minnum     => $minother-1,
            -minlower   => $minalpha,
            -minupper   => 0,
            -minspecial => 1,
        );
        if($new_passwd =~ /"/ || $new_passwd =~ /\\/ || $new_passwd =~ /\// || $new_passwd =~ /'/)
        {
            print $new_passwd,"\n";
            next;
        }
        $check_ret = &check_passwd($new_passwd,$old_passwd,$maxrepeats,$mindiff);
    }
    return $new_passwd;
}

sub check_passwd
{
    my($new_passwd,$old_passwd,$maxrepeats,$mindiff) = @_;

    my %new_hash;
    my %old_hash;
    my @chars = unpack("C*",$new_passwd);
    foreach my $char(@chars)
    {
        unless(exists $new_hash{$char})
        {
            $new_hash{$char} = 0;
        }
        ++$new_hash{$char};
    }

    my $max=0;
    foreach my $key(keys %new_hash)
    {
        if($max==0 || $new_hash{$key}>$max)
        {
            $max = $new_hash{$key};
        }
    }

    if($max >= $maxrepeats)
    {
        return 1;
    }

    @chars = unpack("C*",$old_passwd);
    foreach my $char(@chars)
    {
        unless(exists $old_hash{$char})
        {
            $old_hash{$char} = 0;
        }
        ++$old_hash{$char};
    }

    my $diff = 0;
    foreach my $key(keys %new_hash)
    {
        unless(exists $old_hash{$key})
        {
            ++$diff;
        }
    }

    if($diff < $mindiff)
    {
        return 1;
    }

    return 0;
}

sub check_modify
{
    my($last_update_time,$month,$week,$user_define) = @_;
    my $interval = $time_now_utc - $last_update_time;

    if(defined $month && $month!=0 && $interval>27*3600)
    {
        return 1;
    }

    if(defined $week && $week!=0 && $interval>7*3600)
    {
        return 1;
    }

    if(defined $user_define && $user_define!=0 && $interval>$user_define*3600)
    {
        return 1;
    }
    return 0;
}

sub get_crypt_passwd
{
    my($new_password_r) = @_;
    my $sqr_select = $dbh->prepare("select udf_encrypt('$new_password_r') new_password");
    $sqr_select->execute();
    my $ref_select = $sqr_select->fetchrow_hashref();
    my $new_password = $ref_select->{"new_password"};
    $sqr_select->finish();
    return $new_password;
}

sub log_process
{
    my($level, $log) = @_;
    my $log_utc = time;
    my($sec,$min,$hour,$mday,$mon,$year) = (localtime $log_utc)[0..5];
    ($sec,$min,$hour,$mday,$mon,$year) = (sprintf("%02d", $sec),sprintf("%02d", $min),sprintf("%02d", $hour),sprintf("%02d", $mday),sprintf("%02d", $mon + 1),$year+1900);
    my $log_time_str = "$year-$mon-$mday $hour:$min:$sec";

    print "[$level $log_time_str]: $log\n";
}

sub ssh_login
{
    my($device_ip,$username,$port,$pvt_key) = @_;

    my $exp = Expect->new;
    $exp->log_stdout(0);
    $exp->debug(0);

    &log_process("INFO","ssh -o GSSAPIAuthentication=no -o PreferredAuthentications=publickey -i $pvt_key $username\@$device_ip -p $port");
    $exp->spawn("ssh -o GSSAPIAuthentication=no -o PreferredAuthentications=publickey -i $pvt_key $username\@$device_ip -p $port");

    my @results = $exp->expect(40,
        [
        qr/Last\s+login:/i,
        sub {
        }
        ],
    );

    if(defined $results[1])
    {
        $exp = undef;
    }
    return $exp;
}

sub generate_known_host
{
    my($host,$port) = @_;
    my $output = `ssh-keyscan -p $port -t rsa $host 2>/dev/null`;
    my $type;
    my $pubkey;
    my $cur_line = undef;
    foreach my $line(split /\n/,$output)
    {
        chomp $line;
        if($line =~ /^$host/)
        {
            ($type,$pubkey) = (split /\s+/, $line)[1,2];
            $cur_line = $line;
            last;
        }
    }
    unless(defined $cur_line)
    {
        return;
    }

    my $change = 1;
    my @cache;
    push @cache, $cur_line;
    my $file = (glob "~/.ssh/known_hosts")[0];
    if(-e $file)
    {
        open(my $fd_fr, "<$file");
        while(my $line = <$fd_fr>)
        {
            chomp $line;
            if($line =~ /^$host/)
            {
                my($tmp_type,$tmp_pubkey) = (split /\s+/, $line)[1,2];
                if($tmp_type eq $type && $tmp_pubkey eq $pubkey)
                {
                    $change = 0;
                }
            }
            else
            {
                push @cache, $line;
            }
        }
        close $fd_fr;
    }

    if($change==1)
    {
        open(my $fd_fw, ">$file");
        foreach my $line(@cache)
        {
            print $fd_fw $line,"\n";
        }
        close $fd_fw;
    }
}

sub su_process
{
    my($exp,$superpasswd) = @_;
	my $cmd = "su";
    $exp->clear_accum();
    $exp->send("$cmd\n");
    my @results = $exp->expect(20,
        [
        qr/Password:/i,
        sub {
        my $self = shift ;
        $self->send_slow(0.1,"$superpasswd\n");
        }
        ],
    );

    if(defined $results[1])
    {
        return 1;
    }

    my $count = 100;
    my $flag=0;
    while(1)
    {
        if(--$count == 0)
        {
            last;
        }  

        $exp->expect(1, undef);
        my $str = $exp->before();
        unless($str =~ /\]\#\s*$/ || $str =~ /\]\$\s*$/)
        {
            next;
        }
        &log_process("INFO","su process log: $str");
        if($str=~/#/)
        {
            return 0;
        }
        elsif($str=~/$/)
        {
            return 1;
        }
    }
    return 1;
}

sub get_output
{
    my($exp,$cmd,$exit_word) = @_;

    $exp->clear_accum();
    $exp->send("$cmd\n");

    my $count = 100;
    my $flag = 0;
    my $status = 0;
    while(1)
    {
        if(--$count == 0)
        {
            return 1;
        }
        my @tmp;
        $exp->expect(2, undef);

        my $str = $exp->before();
        unless($str =~ /\]\#\s*$/ || $str =~ /\]\$\s*$/)
        {
            next;
        }

        &log_process("INFO","change passwd return log: $str");
        foreach my $line(split /\n/,$str)
        {
            if($line =~ /echo \"/)
            {
                next;
            }
            elsif($line =~ /get $exit_word: (\d+)/i)
            {
                $flag = 1;
                $status = $1;
                last;
            }
        }

        if($flag == 1)
        {
            last;
        }
    }

    return $status;
}

sub send_mail
{   
    my($mailto,$subject,$msg,$file_path,$mailserver,$mailfrom,$mailpwd) = @_;

    my $sender = new Mail::Sender;
    $subject =  encode("gb2312", decode("utf8", $subject));
    $msg =  encode("gb2312", decode("utf8", $msg));

    if ($sender->MailFile({
            smtp => $mailserver,
            from => $mailfrom,
            to => $mailto,
            subject => $subject,
            msg => $msg,
            auth => 'LOGIN',
            authid => $mailfrom,
            authpwd => $mailpwd,
            file => $file_path,
            b_charset => 'gb2312',
            })<0){
        return 2;
    }
    else
    {
        return 1;
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
