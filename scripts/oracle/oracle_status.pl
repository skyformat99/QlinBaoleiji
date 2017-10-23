#!/usr/bin/perl
use warnings;
use strict;
use DBI;
use DBD::mysql;
use RRDs;
use File::Basename;
use Crypt::CBC;
use MIME::Base64;
use POSIX qw/ceil floor/;

our($mysql_user,$mysql_passwd) = &get_local_mysql_config();
our $rac_ip_map = {
    'RAC3' => 
    {
        'oracle_ip' => '103.30.149.78',

        'tablespace' => 
        {
            'SYSAUX' => 1,
            'SYSTEM' => 1,
            'TS_EADT' => 1,
            'TS_ESB' => 1,
            'UNDOTBS1' => 1,
            'UNDOTBS2' => 1,
            'USERS' => 1,
        },

        'diskgroup' =>
        {
            'DATA' => 1,
            'FAST' => 1,
            'OCR' => 1,
        },

        'disk' => 
        {
            'OCR_0001' => 1,
            'FAST_0000' => 1,
            'OCR_0000' => 1,
            'FAST_0001' => 1,
            'DATA_0000' => 1,
            'DATA_0005' => 1,
            'DATA_0006' => 1,
            'DATA_0001' => 1,
            'DATA_0007' => 1,
            'DATA_0004' => 1,
            'DATA_0002' => 1,
            'DATA_0003' => 1,
        },
    },
};

our $rrd_interval=1800;
our $path = "/home/wuxiaolong/oracle/oracle_result";
$path =~ s/\/$//;
our $debug = 1;
our $max_process_num = 2;
our $exist_process = 0;
our @files;

our $time_now_utc = time;
our($min,$hour,$mday,$mon,$year) = (localtime $time_now_utc)[1..5];
($min,$hour,$mday,$mon,$year) = (sprintf("%02d", $min),sprintf("%02d", $hour),sprintf("%02d", $mday),sprintf("%02d", $mon + 1),$year+1900);
our $time_now_str = "$year$mon$mday$hour$min"."00";

my $dir;
opendir $dir,$path;
while(my $file = readdir $dir)
{
    if($file =~ /^\./)
    {
        next;
    }

    my $db_name = $file;
    unless(exists $rac_ip_map->{$db_name})
    {
        next;
    }

    push @files,"$path/$file";
}
close $dir;

if(scalar @files == 0) 
{
    my $dbh=DBI->connect("DBI:mysql:database=audit_sec;host=localhost;mysql_connect_timeout=5",$mysql_user,$mysql_passwd,{RaiseError=>1});
    my $utf8 = $dbh->prepare("set names utf8");
    $utf8->execute();
    $utf8->finish();

    foreach my $db_name(keys %{$rac_ip_map})
    {
        &set_nan_val($dbh,$db_name,$rac_ip_map);
    }

    &update_nan_val($dbh);

    defined(my $pid = fork) or die "cannot fork:$!";
    unless($pid){
        exec "/home/wuxiaolong/oracle/oracle_warning.pl";
    }
    exit;
}

if($max_process_num > scalar @files){$max_process_num = scalar @files;}
while(1)
{   
    if($exist_process < $max_process_num)
    {   
        &fork_process();
    }
    else
    {
        while(wait())
        {
            --$exist_process;
            &fork_process();
            if($exist_process == 0)
            {
                my $dbh=DBI->connect("DBI:mysql:database=audit_sec;host=localhost;mysql_connect_timeout=5",$mysql_user,$mysql_passwd,{RaiseError=>1});
                my $utf8 = $dbh->prepare("set names utf8");
                $utf8->execute();
                $utf8->finish();

                foreach my $db_name(keys %{$rac_ip_map})
                {
                    &set_nan_val($dbh,$db_name,$rac_ip_map);
                }

                &update_nan_val($dbh);

                defined(my $pid = fork) or die "cannot fork:$!";
                unless($pid){
                    exec "/home/wuxiaolong/oracle/oracle_warning.pl";
                }
                exit;
            }
        }
    }
}

sub fork_process
{
    my $file = shift @files;
    unless(defined $file){return;}
    my $pid = fork();
    if (!defined($pid))
    {
        print "Error in fork: $!";
        exit 1;
    }

    if ($pid == 0)
    {
        my $dbh=DBI->connect("DBI:mysql:database=audit_sec;host=localhost;mysql_connect_timeout=5",$mysql_user,$mysql_passwd,{RaiseError=>1});
        my $utf8 = $dbh->prepare("set names utf8");
        $utf8->execute();
        $utf8->finish();

        my $db_name = basename $file;
        &oracle_process($dbh,$file,$db_name,$rac_ip_map->{$db_name}->{"oracle_ip"});
        unlink $file;
        exit 0;
    }
    ++$exist_process;
}

sub oracle_process
{
    my($dbh,$file,$db_name,$oracle_ip) = @_;
    open(my $fd_fr,"<$file");

    my @cache;
    my $count = 1;
    foreach my $line(<$fd_fr>)
    {
        chomp $line;
        if($line =~ /^#+$/)
        {
            if($count == 2)
            {
                &tablespace_process($dbh,$db_name,$oracle_ip,@cache);
                @cache = ();
            }
            elsif($count == 3 || $count == 4)
            {
                @cache = ();
            }
            elsif($count == 5)
            {
                &diskgroup_process($dbh,$db_name,$oracle_ip,@cache);
                @cache = ();
            }
            elsif($count == 6)
            {
                &disk_process($dbh,$db_name,$oracle_ip,@cache);
                @cache = ();
            }

            ++$count;
            next;
        }
        push @cache, $line;
    }
}

sub tablespace_process
{
    my($dbh,$db_name,$oracle_ip,@cache) = @_;
    my %tablespace_hash;
    foreach my $line(@cache)
    {
        if($line =~ /tablespace_name=(.*),file_id=(\d+),file_name=(.*),filesize=(\d+).*$/i)
        {
            unless(defined $rac_ip_map->{$db_name}->{"tablespace"}->{$1})
            {
                next;
            }

            unless(exists $tablespace_hash{$1})
            {
                my @tmp = ($2,$3,$4);
                $tablespace_hash{$1} = \@tmp;
            }
            else
            {
                next;
            }
        }
        elsif($line =~ /tablespace_name=(.*),free_space=(\d+)/i)
        {
            if(defined $tablespace_hash{$1})
            {
                push @{$tablespace_hash{$1}},$2;
            }
        }
    }

    foreach my $tablespace_name(keys %tablespace_hash)
    {
        my $file_id = $tablespace_hash{$tablespace_name}->[0];
        my $file_name = $tablespace_hash{$tablespace_name}->[1];
        my $file_size = $tablespace_hash{$tablespace_name}->[2];
        my $free_size = $tablespace_hash{$tablespace_name}->[3];

        my $sqr_select = $dbh->prepare("select count(*) from oracle_tablespace where oracle_ip='$oracle_ip' and tablespace_name='$tablespace_name'");
        $sqr_select->execute();
        my $ref_select = $sqr_select->fetchrow_hashref();
        my $tablespace_num = $ref_select->{"count(*)"};
        $sqr_select->finish();

        if($tablespace_num == 0)
        {
            my $sqr_insert = $dbh->prepare("insert into oracle_tablespace(oracle_ip,datetime,tablespace_name,file_id,file_name,file_size,free_size) values('$oracle_ip','$time_now_str','$tablespace_name',$file_id,'$file_name',$file_size,$free_size)");
            $sqr_insert->execute();
            $sqr_insert->finish();
        }
        else
        {
            my $sqr_update = $dbh->prepare("update oracle_tablespace set file_id=$file_id,file_name='$file_name',file_size=$file_size,free_size=$free_size,datetime='$time_now_str' where oracle_ip='$oracle_ip' and tablespace_name='$tablespace_name'");
            $sqr_update->execute();
            $sqr_update->finish();
        }

        $sqr_select = $dbh->prepare("select id from oracle_tablespace where oracle_ip='$oracle_ip' and tablespace_name='$tablespace_name'");
        $sqr_select->execute();
        $ref_select = $sqr_select->fetchrow_hashref();
        my $id = $ref_select->{"id"};
        $sqr_select->finish();

        &update_rrd($dbh,$oracle_ip,$free_size,"oracle_tablespace",$tablespace_name,"oracle_tablespace",$id);
        &warning_func($dbh,$oracle_ip,$free_size,$tablespace_name,"oracle_tablespace",$id);
    }
}

sub diskgroup_process
{
    my($dbh,$db_name,$oracle_ip,@cache) = @_;
    my %diskgroup_hash;
    foreach my $line(@cache)
    {
        if($line =~ /group_number=(\d+),name=(.*),TOTAL_MB=(\d+),FREE_MB=(\d+).*$/i)
        {
            unless(defined $rac_ip_map->{$db_name}->{"diskgroup"}->{$2})
            {
                next;
            }

            unless(exists $diskgroup_hash{$2})
            {
                my @tmp = ($1,$3,$4);
                $diskgroup_hash{$2} = \@tmp;
            }
            else
            {
                next;
            }
        }
    }

    foreach my $diskgroup_name(keys %diskgroup_hash)
    {
        my $diskgroup_id = $diskgroup_hash{$diskgroup_name}->[0];
        my $total_size = $diskgroup_hash{$diskgroup_name}->[1];
        my $free_size = $diskgroup_hash{$diskgroup_name}->[2];

        my $sqr_select = $dbh->prepare("select count(*) from oracle_diskgroup where oracle_ip='$oracle_ip' and diskgroup_name='$diskgroup_name'");
        $sqr_select->execute();
        my $ref_select = $sqr_select->fetchrow_hashref();
        my $diskgroup_num = $ref_select->{"count(*)"};
        $sqr_select->finish();

        if($diskgroup_num == 0)
        {
            my $sqr_insert = $dbh->prepare("insert into oracle_diskgroup(oracle_ip,datetime,diskgroup_id,diskgroup_name,total_size,free_size) values('$oracle_ip','$time_now_str',$diskgroup_id,'$diskgroup_name',$total_size,$free_size)");
            $sqr_insert->execute();
            $sqr_insert->finish();
        }
        else
        {
            my $sqr_update = $dbh->prepare("update oracle_diskgroup set diskgroup_id=$diskgroup_id,total_size=$total_size,free_size=$free_size,datetime='$time_now_str' where oracle_ip='$oracle_ip' and diskgroup_name='$diskgroup_name'");
            $sqr_update->execute();
            $sqr_update->finish();
        }

        $sqr_select = $dbh->prepare("select id from oracle_diskgroup where oracle_ip='$oracle_ip' and diskgroup_name='$diskgroup_name'");
        $sqr_select->execute();
        $ref_select = $sqr_select->fetchrow_hashref();
        my $id = $ref_select->{"id"};
        $sqr_select->finish();

        &update_rrd($dbh,$oracle_ip,$free_size,"oracle_diskgroup",$diskgroup_name,"oracle_diskgroup",$id);
        &warning_func($dbh,$oracle_ip,$free_size,$diskgroup_name,"oracle_diskgroup",$id);
    }
}

sub disk_process
{
    my($dbh,$db_name,$oracle_ip,@cache) = @_;
    my %disk_hash;
    foreach my $line(@cache)
    {
        if($line =~ /name=(.*),path=(.*),total_mb=(\d+),free_mb=(\d+).*$/i)
        {
            unless(defined $rac_ip_map->{$db_name}->{"disk"}->{$1})
            {
                next;
            }

            unless(exists $disk_hash{$1})
            {
                my @tmp = ($2,$3,$4);
                $disk_hash{$1} = \@tmp;
            }
            else
            {
                next;
            }
        }
    }

    foreach my $disk_name(keys %disk_hash)
    {
        my $disk_path = $disk_hash{$disk_name}->[0];
        my $total_size = $disk_hash{$disk_name}->[1];
        my $free_size = $disk_hash{$disk_name}->[2];

        my $sqr_select = $dbh->prepare("select count(*) from oracle_disk where oracle_ip='$oracle_ip' and disk_name='$disk_name'");
        $sqr_select->execute();
        my $ref_select = $sqr_select->fetchrow_hashref();
        my $disk_num = $ref_select->{"count(*)"};
        $sqr_select->finish();

        if($disk_num == 0)
        {
            my $sqr_insert = $dbh->prepare("insert into oracle_disk(oracle_ip,datetime,disk_name,disk_path,total_size,free_size) values('$oracle_ip','$time_now_str','$disk_name','$disk_path',$total_size,$free_size)");
            $sqr_insert->execute();
            $sqr_insert->finish();
        }
        else
        {
            my $sqr_update = $dbh->prepare("update oracle_disk set disk_path='$disk_path',total_size=$total_size,free_size=$free_size,datetime='$time_now_str' where oracle_ip='$oracle_ip' and disk_name='$disk_name'");
            $sqr_update->execute();
            $sqr_update->finish();
        }

        $sqr_select = $dbh->prepare("select id from oracle_disk where oracle_ip='$oracle_ip' and disk_name='$disk_name' and disk_path='$disk_path'");
        $sqr_select->execute();
        $ref_select = $sqr_select->fetchrow_hashref();
        my $id = $ref_select->{"id"};
        $sqr_select->finish();

        &update_rrd($dbh,$oracle_ip,$free_size,"oracle_disk",$disk_name,"oracle_disk",$id);
        &warning_func($dbh,$oracle_ip,$free_size,$disk_name,"oracle_disk",$id);
    }
}

sub update_rrd
{
    my($dbh,$oracle_ip,$free_size,$subdir,$oracle_file,$table,$id) = @_;
    if(!defined $free_size || $free_size < 0)
    {
        $free_size = 'U';
    }

    my $sqr_select = $dbh->prepare("select rrdfile from $table where id=$id");
    $sqr_select->execute();
    my $ref_select = $sqr_select->fetchrow_hashref();
    my $rrdfile = $ref_select->{"rrdfile"};
    $sqr_select->finish();

    my $start_time = time;
    $start_time = (floor($start_time/1800))*1800;

    my $dir = "/opt/freesvr/nm/$oracle_ip";
    if(! -e $dir)
    {           
        mkdir $dir,0755;
    }

    $dir = "$dir/$subdir";
    if(! -e $dir)
    {           
        mkdir $dir,0755;
    }

    my $file = $dir."/$oracle_file.rrd";
    unless(defined $rrdfile && $rrdfile eq $file)
    {
        my $sqr_update = $dbh->prepare("update $table set rrdfile='$file' where id=$id");
        $sqr_update->execute();
        $sqr_update->finish();

        if(defined $rrdfile && -e $rrdfile)
        {
            unlink $rrdfile;
        }
    }

    if(! -e $file)
    {
        my $create_time = $start_time - 1800;
        RRDs::create($file,
                '--start', "$create_time",
                '--step', '1800',
                'DS:val:GAUGE:3600:U:U',
                'RRA:AVERAGE:0.5:1:48',
                'RRA:AVERAGE:0.5:48:65',
                'RRA:AVERAGE:0.5:366:55',
                'RRA:MAX:0.5:1:48',
                'RRA:MAX:0.5:48:65',
                'RRA:MAX:0.5:366:55',
                'RRA:MIN:0.5:1:48',
                'RRA:MIN:0.5:48:65',
                'RRA:MIN:0.5:366:55',
                );
    }

    RRDs::update(
            $file,
            '-t', 'val',
            '--', join(':', "$start_time", "$free_size"),
            );
}

sub warning_func
{
    my($dbh,$oracle_ip,$free_size,$key_name,$table,$id) = @_;
    my $mail_alarm_status = -1;
    my $sms_alarm_status = -1;
    my $mail_out_interval = 0;              #邮件 是否超过时间间隔;
    my $sms_out_interval = 0;               #短信 是否超过时间间隔;

    my $sqr_select = $dbh->prepare("select mail_alarm,sms_alarm,highvalue,lowvalue,unix_timestamp(mail_last_sendtime),unix_timestamp(sms_last_sendtime),send_interval from $table where id=$id");
    $sqr_select->execute();
    my $ref_select = $sqr_select->fetchrow_hashref();
    my $mail_alarm = $ref_select->{"mail_alarm"};
    my $sms_alarm = $ref_select->{"sms_alarm"};
    my $highvalue = $ref_select->{"highvalue"};
    my $lowvalue = $ref_select->{"lowvalue"};
    my $mail_last_sendtime = $ref_select->{"unix_timestamp(mail_last_sendtime)"};
    my $sms_last_sendtime = $ref_select->{"unix_timestamp(sms_last_sendtime)"};
    my $send_interval = $ref_select->{"send_interval"};
    $sqr_select->finish();

    unless(defined $mail_alarm)
    {
        $mail_alarm = 0;
    }

    unless(defined $mail_last_sendtime)
    {
        $mail_out_interval = 1;
    }
    elsif(($time_now_utc - $mail_last_sendtime) > ($send_interval * 60))
    {
        $mail_out_interval = 1;
    }

    if($mail_alarm == 1)
    {
        if($mail_out_interval == 1)
        {
            $mail_alarm_status = -1;
        }
        else
        {
            $mail_alarm_status = 3;
        }
    }
    elsif($mail_alarm == 0)
    {
        $mail_alarm_status = 0;
    }

    unless(defined $sms_alarm)
    {
        $sms_alarm = 0;
    }

    unless(defined $sms_last_sendtime)
    {
        $sms_out_interval = 1;
    }
    elsif(($time_now_utc - $sms_last_sendtime) > ($send_interval * 60))
    {
        $sms_out_interval = 1;
    }

    if($sms_alarm == 1)
    {
        if($sms_out_interval == 1)
        {
            $sms_alarm_status = -1;
        }
        else
        {
            $sms_alarm_status = 3;
        }
    }
    elsif($sms_alarm == 0)
    {
        $sms_alarm_status = 0;
    }

    if($free_size < 0)
    {
        my $sqr_insert = $dbh->prepare("insert into oracle_warning_log(oracle_ip,datetime,table_name,table_id,mail_status,sms_status,key_name,cur_val,context) values ('$oracle_ip','$time_now_str','$table',$id,$mail_alarm_status,$sms_alarm_status,'$key_name',$free_size,'无法得到值')");
        $sqr_insert->execute();
        $sqr_insert->finish();
    }
    elsif(defined $highvalue && defined $lowvalue && ($free_size > $highvalue || $free_size < $lowvalue))
    {
        my $thold;

        my $tmp_context = "";
        if($free_size > $highvalue)
        {
            $thold = $highvalue;
            $tmp_context = "大于最大值 $highvalue";
        }
        else
        {
            $thold = $lowvalue;
            $tmp_context = "小于最小值 $lowvalue";
        }

        $free_size = floor($free_size*100)/100;

        my $sqr_insert = $dbh->prepare("insert into oracle_warning_log(oracle_ip,datetime,table_name,table_id,mail_status,sms_status,key_name,cur_val,thold,context) values ('$oracle_ip','$time_now_str','$table',$id,$mail_alarm_status,$sms_alarm_status,'$key_name',$free_size,$thold,'当前值 $free_size $tmp_context')");
        $sqr_insert->execute();
        $sqr_insert->finish();
    }
}

sub set_nan_val
{
    my($dbh,$db_name,$rac_ip_map) = @_;
    my $oracle_ip = $rac_ip_map->{$db_name}->{"oracle_ip"};

    foreach my $tablespace_name(keys %{$rac_ip_map->{$db_name}->{"tablespace"}})
    {
        my $sqr_select = $dbh->prepare("select count(*) from oracle_tablespace where oracle_ip='$oracle_ip' and tablespace_name='$tablespace_name'");
        $sqr_select->execute();
        my $ref_select = $sqr_select->fetchrow_hashref();
        my $tablespace_num = $ref_select->{"count(*)"};
        $sqr_select->finish();

        if($tablespace_num == 0)
        {
            my $sqr_insert = $dbh->prepare("insert into oracle_tablespace(oracle_ip,datetime,tablespace_name,free_size) values('$oracle_ip','$time_now_str','$tablespace_name',-1)");
            $sqr_insert->execute();
            $sqr_insert->finish();

            $sqr_select = $dbh->prepare("select id from oracle_tablespace where oracle_ip='$oracle_ip' and tablespace_name='$tablespace_name'");
            $sqr_select->execute();
            $ref_select = $sqr_select->fetchrow_hashref();
            my $id = $ref_select->{"id"};
            $sqr_select->finish();

            &update_rrd($dbh,$oracle_ip,-1,"oracle_tablespace",$tablespace_name,"oracle_tablespace",$id);
            &warning_func($dbh,$oracle_ip,-1,$tablespace_name,"oracle_tablespace",$id);
        }
    }

    foreach my $diskgroup_name(keys %{$rac_ip_map->{$db_name}->{"diskgroup"}})
    {
        my $sqr_select = $dbh->prepare("select count(*) from oracle_diskgroup where oracle_ip='$oracle_ip' and diskgroup_name='$diskgroup_name'");
        $sqr_select->execute();
        my $ref_select = $sqr_select->fetchrow_hashref();
        my $diskgroup_num = $ref_select->{"count(*)"};
        $sqr_select->finish();

        if($diskgroup_num == 0)
        {
            my $sqr_insert = $dbh->prepare("insert into oracle_diskgroup(oracle_ip,datetime,diskgroup_name,free_size) values('$oracle_ip','$time_now_str','$diskgroup_name',-1)");
            $sqr_insert->execute();
            $sqr_insert->finish();

            $sqr_select = $dbh->prepare("select id from oracle_diskgroup where oracle_ip='$oracle_ip' and diskgroup_name='$diskgroup_name'");
            $sqr_select->execute();
            $ref_select = $sqr_select->fetchrow_hashref();
            my $id = $ref_select->{"id"};
            $sqr_select->finish();

            &update_rrd($dbh,$oracle_ip,-1,"oracle_diskgroup",$diskgroup_name,"oracle_diskgroup",$id);
            &warning_func($dbh,$oracle_ip,-1,$diskgroup_name,"oracle_diskgroup",$id);
        }
    }

    foreach my $disk_name(keys %{$rac_ip_map->{$db_name}->{"disk"}})
    {
        my $sqr_select = $dbh->prepare("select count(*) from oracle_disk where oracle_ip='$oracle_ip' and disk_name='$disk_name'");
        $sqr_select->execute();
        my $ref_select = $sqr_select->fetchrow_hashref();
        my $disk_num = $ref_select->{"count(*)"};
        $sqr_select->finish();

        if($disk_num == 0)
        {
            my $sqr_insert = $dbh->prepare("insert into oracle_disk(oracle_ip,datetime,disk_name,free_size) values('$oracle_ip','$time_now_str','$disk_name',-1)");
            $sqr_insert->execute();
            $sqr_insert->finish();

            $sqr_select = $dbh->prepare("select id from oracle_disk where oracle_ip='$oracle_ip' and disk_name='$disk_name'");
            $sqr_select->execute();
            $ref_select = $sqr_select->fetchrow_hashref();
            my $id = $ref_select->{"id"};
            $sqr_select->finish();

            &update_rrd($dbh,$oracle_ip,-1,"oracle_disk",$disk_name,"oracle_disk",$id);
            &warning_func($dbh,$oracle_ip,-1,$disk_name,"oracle_disk",$id);
        }
    }
}

sub update_nan_val
{
    my($dbh) = @_;

    my $sqr_select = $dbh->prepare("select id,oracle_ip,tablespace_name from oracle_tablespace where datetime<'$time_now_str'");
    $sqr_select->execute();
    while(my $ref_select = $sqr_select->fetchrow_hashref())
    {
        my $id = $ref_select->{"id"};
        my $oracle_ip = $ref_select->{"oracle_ip"};
        my $tablespace_name = $ref_select->{"tablespace_name"};

        my $sqr_update = $dbh->prepare("update oracle_tablespace set free_size=-1,datetime='$time_now_str' where id=$id");
        $sqr_update->execute();
        $sqr_update->finish();

        &update_rrd($dbh,$oracle_ip,-1,"oracle_tablespace",$tablespace_name,"oracle_tablespace",$id);
        &warning_func($dbh,$oracle_ip,-1,$tablespace_name,"oracle_tablespace",$id);
    }
    $sqr_select->finish();

    $sqr_select = $dbh->prepare("select id,oracle_ip,diskgroup_name from oracle_diskgroup where datetime<'$time_now_str'");
    $sqr_select->execute();
    while(my $ref_select = $sqr_select->fetchrow_hashref())
    {
        my $id = $ref_select->{"id"};
        my $oracle_ip = $ref_select->{"oracle_ip"};
        my $diskgroup_name = $ref_select->{"diskgroup_name"};

        my $sqr_update = $dbh->prepare("update oracle_diskgroup set free_size=-1,datetime='$time_now_str' where id=$id");
        $sqr_update->execute();
        $sqr_update->finish();

        &update_rrd($dbh,$oracle_ip,-1,"oracle_diskgroup",$diskgroup_name,"oracle_diskgroup",$id);
        &warning_func($dbh,$oracle_ip,-1,$diskgroup_name,"oracle_diskgroup",$id);
    }
    $sqr_select->finish();

    $sqr_select = $dbh->prepare("select id,oracle_ip,disk_name from oracle_disk where datetime<'$time_now_str'");
    $sqr_select->execute();
    while(my $ref_select = $sqr_select->fetchrow_hashref())
    {
        my $id = $ref_select->{"id"};
        my $oracle_ip = $ref_select->{"oracle_ip"};
        my $disk_name = $ref_select->{"disk_name"};

        my $sqr_update = $dbh->prepare("update oracle_disk set free_size=-1,datetime='$time_now_str' where id=$id");
        $sqr_update->execute();
        $sqr_update->finish();

        &update_rrd($dbh,$oracle_ip,-1,"oracle_disk",$disk_name,"oracle_disk",$id);
        &warning_func($dbh,$oracle_ip,-1,$disk_name,"oracle_disk",$id);
    }
    $sqr_select->finish();
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
