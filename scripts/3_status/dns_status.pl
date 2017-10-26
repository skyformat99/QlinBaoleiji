#!/usr/bin/perl
use warnings;
use strict;
use DBI;
use DBD::mysql;
use RRDs;
use Crypt::CBC;
use MIME::Base64;
use POSIX qw/ceil floor/;

our $dns_name1 = "www.sohu.com";
our $dns_name2 = "www.sina.com";
our @test_ips;

our $debug = 1;
our $max_process_num = 2;
our $exist_process = 0;

our $time_now_utc = time;
our($min,$hour,$mday,$mon,$year) = (localtime $time_now_utc)[1..5];
($min,$hour,$mday,$mon,$year) = (sprintf("%02d", $min),sprintf("%02d", $hour),sprintf("%02d", $mday),sprintf("%02d", $mon + 1),$year+1900);
our $time_now_str = "$year$mon$mday$hour$min"."00";

our($mysql_user,$mysql_passwd) = &get_local_mysql_config();
my $dbh=DBI->connect("DBI:mysql:database=audit_sec;host=localhost;mysql_connect_timeout=5",$mysql_user,$mysql_passwd,{RaiseError=>1});
my $utf8 = $dbh->prepare("set names utf8");
$utf8->execute();
$utf8->finish();

my $sqr_select = $dbh->prepare("select device_ip from app_config where app_name='dns' group by device_ip");
$sqr_select->execute();
while(my $ref_select = $sqr_select->fetchrow_hashref())
{
    my $device_ip = $ref_select->{"device_ip"};
    unless(defined $device_ip && ($device_ip =~ /(\d{1,3}\.){3}\d{1,3}/ || $device_ip eq "localhost"))
    {
        next;
    }

    push @test_ips, $device_ip;
}

if(scalar @test_ips == 0)
{
    &set_nan_val($dbh);
    defined(my $pid = fork) or die "cannot fork:$!";
    unless($pid){
        exec "/home/wuxiaolong/3_status/dns_warning.pl";
    }

    exit 0;
}
$dbh->disconnect;

if($max_process_num > scalar @test_ips)
{
    $max_process_num = scalar @test_ips;
}

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

                &set_nan_val($dbh);
                defined(my $pid = fork) or die "cannot fork:$!";
                unless($pid){
                    exec "/home/wuxiaolong/3_status/dns_warning.pl";
                }
                $dbh->disconnect;
                exit;
            }
        }
    }
}

sub fork_process
{
    my $device_ip = shift @test_ips;
    unless(defined $device_ip){return;}
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

        my $ref_delayvalue = &get_delay_value($device_ip);
        &insert_into_status($dbh,$device_ip,$ref_delayvalue);
        &update_rrd($dbh,$device_ip,1,$ref_delayvalue->{1});
        &update_rrd($dbh,$device_ip,2,$ref_delayvalue->{2});
        &warning_func($dbh,$device_ip,1,$ref_delayvalue->{1});
        &warning_func($dbh,$device_ip,2,$ref_delayvalue->{2});

        $dbh->disconnect;
        exit 0;
    }
    ++$exist_process;
}

sub get_delay_value
{
    my($device_ip) = @_;
    my $delayvalue1;
    my $delayvalue2;

    my $result = `dig \@$device_ip $dns_name1 $dns_name2 | grep  'Query time:'`;
    foreach my $line(split /\n/,$result)
    {
        if($line =~ /Query\s*time:\s*(\d+)\s*msec/)
        {
            unless(defined $delayvalue1)
            {
                $delayvalue1 = $1;
            }
            else
            {
                $delayvalue2 = $1;
            }
        }
    }

    my $ref_delayvalue = {
        1 => $delayvalue1,
        2 => $delayvalue2,
    };

    return $ref_delayvalue;
}

sub insert_into_status
{
    my($dbh,$device_ip,$ref_delayvalue) = @_;

    my $sqr_select = $dbh->prepare("select count(*) from dns_status where device_ip='$device_ip'");
    $sqr_select->execute();
    my $ref_select = $sqr_select->fetchrow_hashref();
    my $device_num = $ref_select->{"count(*)"};
    $sqr_select->finish();

    if($device_num != 0 && $device_num != 2)
    {
        $sqr_select = $dbh->prepare("select rrdfile from dns_status where device_ip='$device_ip'");
        $sqr_select->execute();
        while($ref_select = $sqr_select->fetchrow_hashref())
        {
            my $rrdfile = $ref_select->{"rrdfile"};
            if(-e $rrdfile)
            {
                unlink $rrdfile;
            }
        }
        $sqr_select->finish();

        my $sqr_delete = $dbh->prepare("delete from dns_status where device_ip='$device_ip'");
        $sqr_delete->execute();
        $sqr_delete->finish();
        $device_num = 0;
    }

    if($device_num == 0)
    {
        foreach my $type(keys %{$ref_delayvalue})
        {
            my $sqr_insert = $dbh->prepare("insert into dns_status(device_ip,type) values('$device_ip',$type)");
            $sqr_insert->execute();
            $sqr_insert->finish();

            $sqr_select = $dbh->prepare("select enable from dns_status where device_ip='$device_ip' and type=$type");
            $sqr_select->execute();
            $ref_select = $sqr_select->fetchrow_hashref();
            my $enable = $ref_select->{"enable"};
            $sqr_select->finish();

            if($enable != 1) 
            {
                if($debug == 1)
                {
                    my $sqr_update = $dbh->prepare("update dns_status set enable=1 where device_ip='$device_ip' and type=$type");
                    $sqr_update->execute();
                    $sqr_update->finish();

                    $sqr_update = $dbh->prepare("update dns_status set delayvalue=$ref_delayvalue->{$type},datetime='$time_now_str' where device_ip='$device_ip' and type=$type");
                    $sqr_update->execute();
                    $sqr_update->finish();
                }
            }
            else
            {
                my $sqr_update = $dbh->prepare("update dns_status set delayvalue=$ref_delayvalue->{$type},datetime='$time_now_str' where device_ip='$device_ip' and type=$type");
                $sqr_update->execute();
                $sqr_update->finish();
            }
        }
    }
    else
    {
        foreach my $type(keys %{$ref_delayvalue})
        {
            $sqr_select = $dbh->prepare("select enable from dns_status where device_ip='$device_ip' and type=$type");
            $sqr_select->execute();
            $ref_select = $sqr_select->fetchrow_hashref();
            my $enable = $ref_select->{"enable"};
            $sqr_select->finish();
            
            if($enable == 1) 
            {
                my $sqr_update = $dbh->prepare("update dns_status set delayvalue=$ref_delayvalue->{$type},datetime='$time_now_str' where device_ip='$device_ip' and type=$type");
                $sqr_update->execute();
                $sqr_update->finish();
            }
            else
            {
                my $sqr_update = $dbh->prepare("update dns_status set delayvalue=null,datetime=null where device_ip='$device_ip' and type=$type");
                $sqr_update->execute();
                $sqr_update->finish();
            }
        }
    }
}

sub update_rrd
{
    my($dbh,$device_ip,$type,$val) = @_;
    if(!defined $val || $val < 0)
    {
        $val = 'U';
    }

    my $sqr_select = $dbh->prepare("select enable,rrdfile from dns_status where device_ip='$device_ip' and type=$type");
    $sqr_select->execute();
    my $ref_select = $sqr_select->fetchrow_hashref();
    my $enable = $ref_select->{"enable"};
    my $rrdfile = $ref_select->{"rrdfile"};
    $sqr_select->finish();

    my $start_time = time;
    $start_time = (floor($start_time/300))*300;

    my $dir = "/opt/freesvr/nm/$device_ip";
    if(! -e $dir)
    {
        mkdir $dir,0755;
    }

    $dir = "$dir/dns_status";
    if(! -e $dir)
    {
        mkdir $dir,0755;
    }

    my $file = $dir."/${device_ip}_$type.rrd";

    unless(defined $enable && $enable == 1)
    {
        unless(defined $rrdfile && -e $rrdfile && $rrdfile eq $file)
        {
            if(defined $rrdfile && -e $rrdfile)
            {
                unlink $rrdfile;
                my $sqr_update = $dbh->prepare("update dns_status set rrdfile=null where device_ip='$device_ip' and type=$type");
                $sqr_update->execute();
                $sqr_update->finish();
                return;
            }
        }
    }

    if(! -e $file)
    {
        my $create_time = $start_time - 300;
        RRDs::create($file,
                '--start', "$create_time",
                '--step', '300',
                'DS:val:GAUGE:600:U:U',
                'RRA:AVERAGE:0.5:1:576',
                'RRA:AVERAGE:0.5:12:192',
                'RRA:AVERAGE:0.5:288:65',
                'RRA:AVERAGE:0.5:2016:55',
                'RRA:MAX:0.5:1:576',
                'RRA:MAX:0.5:12:192',
                'RRA:MAX:0.5:288:65',
                'RRA:MAX:0.5:2016:55',
                'RRA:MIN:0.5:1:576',
                'RRA:MIN:0.5:12:192',
                'RRA:MIN:0.5:288:65',
                'RRA:MIN:0.5:2016:55',
                );
    }

    unless(defined $rrdfile && $rrdfile eq $file)
    {
        my $sqr_update = $dbh->prepare("update dns_status set rrdfile='$file' where device_ip='$device_ip' and type=$type");
        $sqr_update->execute();
        $sqr_update->finish();

        if(defined $rrdfile && -e $rrdfile)
        {
            unlink $rrdfile;
        }
    }

    RRDs::update(
            $file,
            '-t', 'val',
            '--', join(':', "$start_time", "$val"),
            );
}

sub warning_func
{
    my($dbh,$device_ip,$type,$value) = @_;
    my $domain = $dns_name1;
    if($type == 2){$domain = $dns_name2;}

    my $status;
    my $mail_alarm_status = -1;
    my $sms_alarm_status = -1;
    my $mail_out_interval = 0;              #邮件 是否超过时间间隔;
    my $sms_out_interval = 0;               #短信 是否超过时间间隔;

    my $sqr_select = $dbh->prepare("select enable,mail_alarm,sms_alarm,highvalue,lowvalue,unix_timestamp(mail_last_sendtime),unix_timestamp(sms_last_sendtime),send_interval from dns_status where device_ip='$device_ip' and type=$type");
    $sqr_select->execute();
    my $ref_select = $sqr_select->fetchrow_hashref();
    my $enable = $ref_select->{"enable"};
    my $mail_alarm = $ref_select->{"mail_alarm"};
    my $sms_alarm = $ref_select->{"sms_alarm"};
    my $highvalue = $ref_select->{"highvalue"};
    my $lowvalue = $ref_select->{"lowvalue"};
    my $mail_last_sendtime = $ref_select->{"unix_timestamp(mail_last_sendtime)"};
    my $sms_last_sendtime = $ref_select->{"unix_timestamp(sms_last_sendtime)"};
    my $send_interval = $ref_select->{"send_interval"};
    $sqr_select->finish();

    unless(defined $enable && $enable == 1)
    {
        return 0;
    }

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

    if($value < 0)
    {
        $status = 0;
        my $sqr_insert = $dbh->prepare("insert into dns_warning_log (device_ip,type,datetime,mail_status,sms_status,cur_val,context) values ('$device_ip',$type,'$time_now_str',$mail_alarm_status,$sms_alarm_status,$value,'$domain 无法得到dns延时')");
        $sqr_insert->execute();
        $sqr_insert->finish();
    }
    elsif(defined $highvalue && defined $lowvalue && ($value > $highvalue || $value < $lowvalue))
    {
        $status = 2;
        my $thold;

        my $tmp_context = "";
        if($value > $highvalue)
        {
            $thold = $highvalue;
            $tmp_context = "大于最大值 $highvalue";
        }
        else
        {
            $thold = $lowvalue;
            $tmp_context = "小于最小值 $lowvalue";
        }

        $value = floor($value*100)/100;

        my $sqr_insert = $dbh->prepare("insert into dns_warning_log (device_ip,type,datetime,mail_status,sms_status,cur_val,thold,context) values ('$device_ip',$type,'$time_now_str',$mail_alarm_status,$sms_alarm_status,$value,$thold,'$domain dns延时超值 当前值 $value $tmp_context')");
        $sqr_insert->execute();
        $sqr_insert->finish();
    }
    else
    {
        $status = 1;
    }

    return $status;
}

sub set_nan_val
{
    my($dbh) = @_;

    my @set_ips;
    my $sqr_select = $dbh->prepare("select device_ip from dns_status where enable=1 group by device_ip having count(device_ip)!=2");
    $sqr_select->execute();
    while(my $ref_select = $sqr_select->fetchrow_hashref())
    {
        my $device_ip = $ref_select->{"device_ip"};
        push @set_ips, $device_ip;
    }
    $sqr_select->finish();

    $sqr_select = $dbh->prepare("select device_ip from app_config where app_name='dns' and device_ip not in(select device_ip from dns_status group by device_ip) group by device_ip");
    $sqr_select->execute();
    while(my $ref_select = $sqr_select->fetchrow_hashref())
    {
        my $device_ip = $ref_select->{"device_ip"};
        push @set_ips, $device_ip;
    }
    $sqr_select->finish();

    foreach my $device_ip(@set_ips)
    {
        my $ref_delayvalue = {
            1 => -1,
            2 => -1,
        };
        &insert_into_status($dbh,$device_ip,$ref_delayvalue);
        &update_rrd($dbh,$device_ip,1,$ref_delayvalue->{1});
        &update_rrd($dbh,$device_ip,2,$ref_delayvalue->{2});
        &warning_func($dbh,$device_ip,1,$ref_delayvalue->{1});
        &warning_func($dbh,$device_ip,2,$ref_delayvalue->{2});
    }

    $sqr_select = $dbh->prepare("select device_ip,type from dns_status where enable=1 and datetime<'$time_now_str'");
    $sqr_select->execute();
    while(my $ref_select = $sqr_select->fetchrow_hashref())
    {
        my $device_ip = $ref_select->{"device_ip"};
        my $type = $ref_select->{"type"};

        my $sqr_update = $dbh->prepare("update dns_status set delayvalue=-1,datetime='$time_now_str' where device_ip='$device_ip' and type=$type");
        $sqr_update->execute();
        $sqr_update->finish();

        &update_rrd($dbh,$device_ip,$type,-1);
        &warning_func($dbh,$device_ip,$type,-1);
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
