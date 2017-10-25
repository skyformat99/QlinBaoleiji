#!/usr/bin/perl
use strict;
use warnings;

use DBI;
use DBD::mysql;
use Mail::Sender;
use Encode;
use URI::Escape;
use URI::URL;
use Crypt::CBC;
use MIME::Base64;

our $time_now_utc = time;
my($min,$hour,$mday,$mon,$year) = (localtime $time_now_utc)[1..5];
($min,$hour,$mday,$mon,$year) = (sprintf("%02d", $min),sprintf("%02d", $hour),sprintf("%02d", $mday),sprintf("%02d", $mon + 1),$year+1900);
our $time_now_str = "$year$mon$mday$hour$min"."00";
our $time_now_subject = "$year-$mon-$mday $hour:$min";

our($mysql_user,$mysql_passwd) = &get_local_mysql_config();
our $dbh=DBI->connect("DBI:mysql:database=audit_sec;host=localhost;mysql_connect_timeout=3600",$mysql_user,$mysql_passwd,{RaiseError=>1});
our $utf8 = $dbh->prepare("set names utf8");
$utf8->execute();
$utf8->finish();

&mail_alarm_process($dbh);
&sms_alarm_process($dbh);

sub mail_alarm_process
{
    my($dbh) = @_;

    my %device_errlog;
    my %email_errlog;
    my %device_status;
    my %interface_err_info;
    my %interface_err_value;
    my %interface_map;

    my $last_datetime = undef;

    my $mail = $dbh->prepare("select mailserver,account,password from alarm");
    $mail->execute();
    my $ref_mail = $mail->fetchrow_hashref();
    my $mailserver = $ref_mail->{"mailserver"};
    my $mailfrom = $ref_mail->{"account"};
    my $mailpwd = $ref_mail->{"password"};
    $mail->finish();

    my $sqr_select = $dbh->prepare("select id,device_ip,datetime,port_index,port_describe,type,cur_val,context from snmp_interface_warning_log where mail_status = -1 order by datetime desc");
    $sqr_select->execute();
    while(my $ref_select = $sqr_select->fetchrow_hashref())
    {
        my $id = $ref_select->{"id"};
        my $device_ip = $ref_select->{"device_ip"};
        my $datetime = $ref_select->{"datetime"};
        my $port_index = $ref_select->{"port_index"};
        my $port_describe = $ref_select->{"port_describe"};
        my $type = $ref_select->{"type"};
        my $value = $ref_select->{"cur_val"};
        my $context = $ref_select->{"context"};

        if(defined $last_datetime && $last_datetime ne $datetime)
        {
            &result_process(\%device_errlog,\%interface_err_info,\%interface_err_value,\%interface_map,$last_datetime);
        }

        $last_datetime = $datetime;

        unless(exists $device_status{$device_ip})
        {
            my @id;
            my @tmp = (\@id,1);
            $device_status{$device_ip} = \@tmp;
        }

        push @{$device_status{$device_ip}->[0]},$id;

        unless(exists $interface_map{$device_ip})
        {
            my %tmp;
            $interface_map{$device_ip} = \%tmp;
        }

        unless(exists $interface_map{$device_ip}->{$port_index})
        {
            $interface_map{$device_ip}->{$port_index} = $port_describe;
        }

        unless(exists $interface_err_info{$device_ip})
        {   
            my %tmp;
            $interface_err_info{$device_ip} = \%tmp;
        }

        unless(exists $interface_err_info{$device_ip}->{$port_index})
        {
            my @tmp = (undef,undef,undef,undef,undef,undef,undef);
            $interface_err_info{$device_ip}->{$port_index} = \@tmp;
        }

        unless(exists $interface_err_value{$device_ip})
        {   
            my %tmp;
            $interface_err_value{$device_ip} = \%tmp;
        }

        unless(exists $interface_err_value{$device_ip}->{$port_index})
        {
            my @tmp = (undef,undef,undef,undef,undef,undef,undef);
            $interface_err_value{$device_ip}->{$port_index} = \@tmp;
        }

        if($type eq "cur_status")
        {
            $interface_err_info{$device_ip}->{$port_index}->[0] = $context;
            $interface_err_value{$device_ip}->{$port_index}->[0] = $value;
        }

        if($type eq "traffic_in")
        {
            $interface_err_info{$device_ip}->{$port_index}->[1] = $context;
            $interface_err_value{$device_ip}->{$port_index}->[1] = $value;
        }

        if($type eq "traffic_out")
        {
            $interface_err_info{$device_ip}->{$port_index}->[2] = $context;
            $interface_err_value{$device_ip}->{$port_index}->[2] = $value;
        }

        if($type eq "packet_in")
        {
            $interface_err_info{$device_ip}->{$port_index}->[3] = $context;
            $interface_err_value{$device_ip}->{$port_index}->[3] = $value;
        }

        if($type eq "packet_out")
        {
            $interface_err_info{$device_ip}->{$port_index}->[4] = $context;
            $interface_err_value{$device_ip}->{$port_index}->[4] = $value;
        }

        if($type eq "err_packet_in")
        {
            $interface_err_info{$device_ip}->{$port_index}->[5] = $context;
            $interface_err_value{$device_ip}->{$port_index}->[5] = $value;
        }

        if($type eq "err_packet_out")
        {
            $interface_err_info{$device_ip}->{$port_index}->[6] = $context;
            $interface_err_value{$device_ip}->{$port_index}->[6] = $value;
        }
    }
    $sqr_select->finish();

    &result_process(\%device_errlog,\%interface_err_info,\%interface_err_value,\%interface_map,$last_datetime);

    foreach my $device_ip(keys %device_errlog)
    {
        my $is_exist = 0;
        $sqr_select = $dbh->prepare("select email from member where uid IN(select memberid from snmp_alert_user a left join snmp_alert b on a.snmp_alert_id=b.seq where (b.groupid=(select groupid from servers where device_ip='$device_ip') or b.groupid=0) and b.enable=1) and email != ''");
        $sqr_select->execute();
        while(my $ref_select = $sqr_select->fetchrow_hashref())
        {
            my $email = $ref_select->{"email"};
#            my $email = 'wxl890206@126.com';
            unless(defined $email)
            {
                next;
            }

            $is_exist = 1;

            unless(exists $email_errlog{$email})
            {
                my @tmp_device = ($device_ip);
                my @tmp_arr = (\@tmp_device,undef);

                $email_errlog{$email} = \@tmp_arr;
                $email_errlog{$email}->[1] = $device_errlog{$device_ip};
            }
            else
            {
                push @{$email_errlog{$email}->[0]}, $device_ip;
                $email_errlog{$email}->[1] .= $device_errlog{$device_ip};
            }

            $email_errlog{$email}->[1] .= "\n";
        }
        $sqr_select->finish();

        if($is_exist == 0)
        {
            $device_status{$device_ip}->[1] = 2;
        }
    }

    foreach my $mailto(keys %email_errlog)
    {
        my $subject = "主机应用告警 $time_now_subject";

        my $status = &send_mail($mailto,$subject,$email_errlog{$mailto}->[1],$mailserver,$mailfrom,$mailpwd);

        if($status == 2)
        {
            foreach my $device_ip(@{$email_errlog{$mailto}->[0]})
            {
                $device_status{$device_ip}->[1] = $status;
            }
        }
    }

    foreach my $device_ip(keys %device_status)
    {
        my $status = $device_status{$device_ip}->[1];
        my %update_cache;

        foreach my $id(@{$device_status{$device_ip}->[0]})
        {
            my $sqr_update = $dbh->prepare("update snmp_interface_warning_log set mail_status = $status where id = $id");
            $sqr_update->execute();
            $sqr_update->finish();

            if($status == 1)
            {
                my $sqr_select_port = $dbh->prepare("select device_ip,port_index from snmp_interface_warning_log where id = $id");
                $sqr_select_port->execute();
                my $ref_select_port = $sqr_select_port->fetchrow_hashref();
                my $tmp_device_ip = $ref_select_port->{"device_ip"};
                my $tmp_port_index = $ref_select_port->{"port_index"};
                $sqr_select_port->finish();

                unless(defined $update_cache{$tmp_device_ip})
                {
                    my %tmp;
                    $update_cache{$tmp_device_ip} = \%tmp;
                }

                if(defined $update_cache{$tmp_device_ip}->{$tmp_port_index})
                {
                    next;
                }

                $update_cache{$tmp_device_ip}->{$tmp_port_index} = 1;

                my $sqr_select_id = $dbh->prepare("select id from snmp_interface where device_ip = '$tmp_device_ip' and port_index = '$tmp_port_index'");
                $sqr_select_id->execute();
                my $ref_select_id = $sqr_select_id->fetchrow_hashref();
                my $id = $ref_select_id->{"id"};
                $sqr_select_id->finish();

                if(defined $id)
                {
                    $sqr_update = $dbh->prepare("update snmp_interface set mail_last_sendtime = '$time_now_str' where id = $id");
                    $sqr_update->execute();
                    $sqr_update->finish();
                }
            }
        }
    }
}

sub sms_alarm_process
{
    my($dbh) = @_;

    my %device_errlog;
    my %mobile_errlog;
    my %device_status;
    my %interface_err_info;
    my %interface_err_value;
    my %interface_map;

    my $last_datetime = undef;

    my $sqr_select = $dbh->prepare("select id,device_ip,datetime,port_index,port_describe,type,cur_val,context from snmp_interface_warning_log where mail_status = -1 order by datetime desc");
    $sqr_select->execute();
    while(my $ref_select = $sqr_select->fetchrow_hashref())
    {
        my $id = $ref_select->{"id"};
        my $device_ip = $ref_select->{"device_ip"};
        my $datetime = $ref_select->{"datetime"};
        my $port_index = $ref_select->{"port_index"};
        my $port_describe = $ref_select->{"port_describe"};
        my $type = $ref_select->{"type"};
        my $value = $ref_select->{"cur_val"};
        my $context = $ref_select->{"context"};

        if(defined $last_datetime && $last_datetime ne $datetime)
        {
            &result_process(\%device_errlog,\%interface_err_info,\%interface_err_value,\%interface_map,$last_datetime);
        }

        $last_datetime = $datetime;

        unless(exists $device_status{$device_ip})
        {
            my @id;
            my @tmp = (\@id,1);
            $device_status{$device_ip} = \@tmp;
        }

        push @{$device_status{$device_ip}->[0]},$id;

        unless(exists $interface_map{$device_ip})
        {
            my %tmp;
            $interface_map{$device_ip} = \%tmp;
        }

        unless(exists $interface_map{$device_ip}->{$port_index})
        {
            $interface_map{$device_ip}->{$port_index} = $port_describe;
        }

        unless(exists $interface_err_info{$device_ip})
        {   
            my %tmp;
            $interface_err_info{$device_ip} = \%tmp;
        }

        unless(exists $interface_err_info{$device_ip}->{$port_index})
        {
            my @tmp = (undef,undef,undef,undef,undef,undef,undef);
            $interface_err_info{$device_ip}->{$port_index} = \@tmp;
        }

        unless(exists $interface_err_value{$device_ip})
        {   
            my %tmp;
            $interface_err_value{$device_ip} = \%tmp;
        }

        unless(exists $interface_err_value{$device_ip}->{$port_index})
        {
            my @tmp = (undef,undef,undef,undef,undef,undef,undef);
            $interface_err_value{$device_ip}->{$port_index} = \@tmp;
        }

        if($type eq "cur_status")
        {
            $interface_err_info{$device_ip}->{$port_index}->[0] = $context;
            $interface_err_value{$device_ip}->{$port_index}->[0] = $value;
        }

        if($type eq "traffic_in")
        {
            $interface_err_info{$device_ip}->{$port_index}->[1] = $context;
            $interface_err_value{$device_ip}->{$port_index}->[1] = $value;
        }

        if($type eq "traffic_out")
        {
            $interface_err_info{$device_ip}->{$port_index}->[2] = $context;
            $interface_err_value{$device_ip}->{$port_index}->[2] = $value;
        }

        if($type eq "packet_in")
        {
            $interface_err_info{$device_ip}->{$port_index}->[3] = $context;
            $interface_err_value{$device_ip}->{$port_index}->[3] = $value;
        }

        if($type eq "packet_out")
        {
            $interface_err_info{$device_ip}->{$port_index}->[4] = $context;
            $interface_err_value{$device_ip}->{$port_index}->[4] = $value;
        }

        if($type eq "err_packet_in")
        {
            $interface_err_info{$device_ip}->{$port_index}->[5] = $context;
            $interface_err_value{$device_ip}->{$port_index}->[5] = $value;
        }

        if($type eq "err_packet_out")
        {
            $interface_err_info{$device_ip}->{$port_index}->[6] = $context;
            $interface_err_value{$device_ip}->{$port_index}->[6] = $value;
        }
    }
    $sqr_select->finish();

    &result_process(\%device_errlog,\%interface_err_info,\%interface_err_value,\%interface_map,$last_datetime);

    foreach my $device_ip(keys %device_errlog)
    {
        my $is_exist = 0;
        $sqr_select = $dbh->prepare("select mobilenum from member where uid IN(select memberid from snmp_alert_user a left join snmp_alert b on a.snmp_alert_id=b.seq where (b.groupid=(select groupid from servers where device_ip='$device_ip') or b.groupid=0) and b.enable=1) and mobilenum != ''");
        $sqr_select->execute();
        while(my $ref_select = $sqr_select->fetchrow_hashref())
        {
            my $mobilenum = $ref_select->{"mobilenum"};
            unless(defined $mobilenum)
            {
                next;
            }

            $is_exist = 1;

            unless(exists $mobile_errlog{$mobilenum})
            {
                my @tmp_device = ($device_ip);
                my @tmp_arr = (\@tmp_device,undef);

                $mobile_errlog{$mobilenum} = \@tmp_arr;
                $mobile_errlog{$mobilenum}->[1] = $device_errlog{$device_ip};
            }
            else
            {
                push @{$mobile_errlog{$mobilenum}->[0]}, $device_ip;
                $mobile_errlog{$mobilenum}->[1] .= $device_errlog{$device_ip};
            }

            $mobile_errlog{$mobilenum}->[1] .= "\n";
        }
        $sqr_select->finish();

        if($is_exist == 0)
        {
            $device_status{$device_ip}->[1] = 2;
        }
    }

    foreach my $mobile(keys %mobile_errlog)
    {
        my $status = &send_msg($mobile,$mobile_errlog{$mobile}->[1]);

        if($status == 2)
        {
            foreach my $device_ip(@{$mobile_errlog{$mobile}->[0]})
            {
                $device_status{$device_ip}->[1] = $status;
            }
        }
    }

    foreach my $device_ip(keys %device_status)
    {
        my $status = $device_status{$device_ip}->[1];
        my %update_cache;

        foreach my $id(@{$device_status{$device_ip}->[0]})
        {
            my $sqr_update = $dbh->prepare("update snmp_interface_warning_log set sms_status = $status where id = $id");
            $sqr_update->execute();
            $sqr_update->finish();

            if($status == 1)
            {
                my $sqr_select_port = $dbh->prepare("select device_ip,port_index from snmp_interface_warning_log where id = $id");
                $sqr_select_port->execute();
                my $ref_select_port = $sqr_select_port->fetchrow_hashref();
                my $tmp_device_ip = $ref_select_port->{"device_ip"};
                my $tmp_port_index = $ref_select_port->{"port_index"};
                $sqr_select_port->finish();

                unless(defined $update_cache{$tmp_device_ip})
                {
                    my %tmp;
                    $update_cache{$tmp_device_ip} = \%tmp;
                }

                if(defined $update_cache{$tmp_device_ip}->{$tmp_port_index})
                {
                    next;
                }

                $update_cache{$tmp_device_ip}->{$tmp_port_index} = 1;

                my $sqr_select_id = $dbh->prepare("select id from snmp_interface where device_ip = '$tmp_device_ip' and port_index = '$tmp_port_index'");
                $sqr_select_id->execute();
                my $ref_select_id = $sqr_select_id->fetchrow_hashref();
                my $id = $ref_select_id->{"id"};
                $sqr_select_id->finish();

                if(defined $id)
                {
                    $sqr_update = $dbh->prepare("update snmp_interface set sms_last_sendtime = '$time_now_str' where id = $id");
                    $sqr_update->execute();
                    $sqr_update->finish();
                }
            }
        }
    }
}

sub result_process
{
    my($ref_device_errlog,$ref_interface_err_info,$ref_interface_err_value,$ref_interface_map,$last_datetime) = @_;
    foreach my $device_ip(keys %{$ref_interface_err_info})
    {
        unless(exists $ref_device_errlog->{$device_ip})
        {
            $ref_device_errlog->{$device_ip} = "$device_ip 接口信息告警:\n";
        }

        $ref_device_errlog->{$device_ip} .= "时间: $last_datetime\n";

        my @statusvalue;
        my $statusInfo;

        my @trafficinvalue;
        my $trafficinInfo;

        my @trafficoutvalue;
        my $trafficoutInfo;

        my @packetinvalue;
        my $packetinInfo;

        my @packetoutvalue;
        my $packetoutInfo;

        my @errpacketinvalue;
        my $errpacketinInfo;

        my @errpacketoutvalue;
        my $errpacketoutInfo;

        foreach my $port_index(keys %{$ref_interface_err_value->{$device_ip}})
        {
            my $port_describe = $ref_interface_map->{$device_ip}->{$port_index};

            if(defined $ref_interface_err_value->{$device_ip}->{$port_index}->[0])
            {
                if($ref_interface_err_value->{$device_ip}->{$port_index}->[0] =~ /-\d+/) 
                {
                    push @statusvalue,$port_describe;
                }
                else
                {
                    $statusInfo .= "$port_describe,$ref_interface_err_info->{$device_ip}->{$port_index}->[0]\n";
                }
            }

            if(defined $ref_interface_err_value->{$device_ip}->{$port_index}->[1])
            {
                if($ref_interface_err_value->{$device_ip}->{$port_index}->[1] < 0)
                {
                    push @trafficinvalue,$port_describe;
                }
                else
                {
                    $trafficinInfo .= "$port_describe,$ref_interface_err_info->{$device_ip}->{$port_index}->[1]\n";
                }
            }

            if(defined $ref_interface_err_value->{$device_ip}->{$port_index}->[2])
            {
                if($ref_interface_err_value->{$device_ip}->{$port_index}->[2] < 0)
                {
                    push @trafficoutvalue,$port_describe;
                }
                else
                {
                    $trafficoutInfo .= "$port_describe,$ref_interface_err_info->{$device_ip}->{$port_index}->[2]\n";
                }
            }

            if(defined $ref_interface_err_value->{$device_ip}->{$port_index}->[3])
            {
                if($ref_interface_err_value->{$device_ip}->{$port_index}->[3] < 0)
                {
                    push @packetinvalue,$port_describe;
                }
                else
                {
                    $packetinInfo .= "$port_describe,$ref_interface_err_info->{$device_ip}->{$port_index}->[3]\n";
                }
            }

            if(defined $ref_interface_err_value->{$device_ip}->{$port_index}->[4])
            {
                if($ref_interface_err_value->{$device_ip}->{$port_index}->[4] < 0)
                {
                    push @packetoutvalue,$port_describe;
                }
                else
                {
                    $packetoutInfo .= "$port_describe,$ref_interface_err_info->{$device_ip}->{$port_index}->[4]\n";
                }
            }

            if(defined $ref_interface_err_value->{$device_ip}->{$port_index}->[5])
            {
                if($ref_interface_err_value->{$device_ip}->{$port_index}->[5] < 0)
                {
                    push @errpacketinvalue,$port_describe;
                }
                else
                {
                    $errpacketinInfo .= "$port_describe,$ref_interface_err_info->{$device_ip}->{$port_index}->[5]\n";
                }
            }

            if(defined $ref_interface_err_value->{$device_ip}->{$port_index}->[6])
            {
                if($ref_interface_err_value->{$device_ip}->{$port_index}->[6] < 0)
                {
                    push @errpacketoutvalue,$port_describe;
                }
                else
                {
                    $errpacketoutInfo .= "$port_describe,$ref_interface_err_info->{$device_ip}->{$port_index}->[6]\n";
                }
            }
        }

        if(defined $statusInfo || scalar @statusvalue != 0)
        {
            $ref_device_errlog->{$device_ip} .= "状态告警\n";
            if(defined $statusInfo)
            {
                $ref_device_errlog->{$device_ip} .= $statusInfo;
            }

            if(scalar @statusvalue != 0)
            {
                $ref_device_errlog->{$device_ip} .= join(",",@statusvalue);
                $ref_device_errlog->{$device_ip} .= " 没有取到值\n";
            }
        }

        if(defined $trafficinInfo || scalar @trafficinvalue != 0)
        {
            $ref_device_errlog->{$device_ip} .= "入向流量告警\n";
            if(defined $trafficinInfo)
            {
                $ref_device_errlog->{$device_ip} .= $trafficinInfo;
            }

            if(scalar @trafficinvalue != 0)
            {
                $ref_device_errlog->{$device_ip} .= join(",",@trafficinvalue);
                $ref_device_errlog->{$device_ip} .= " 没有取到值\n";
            }
        }

        if(defined $trafficoutInfo || scalar @trafficoutvalue != 0)
        {
            $ref_device_errlog->{$device_ip} .= "出向流量告警\n";
            if(defined $trafficoutInfo)
            {
                $ref_device_errlog->{$device_ip} .= $trafficoutInfo;
            }

            if(scalar @trafficoutvalue != 0)
            {
                $ref_device_errlog->{$device_ip} .= join(",",@trafficoutvalue);
                $ref_device_errlog->{$device_ip} .= " 没有取到值\n";
            }
        }

        if(defined $packetinInfo || scalar @packetinvalue != 0)
        {
            $ref_device_errlog->{$device_ip} .= "入向包速率告警\n";
            if(defined $packetinInfo)
            {
                $ref_device_errlog->{$device_ip} .= $packetinInfo;
            }

            if(scalar @packetinvalue != 0)
            {
                $ref_device_errlog->{$device_ip} .= join(",",@packetinvalue);
                $ref_device_errlog->{$device_ip} .= " 没有取到值\n";
            }
        }

        if(defined $packetoutInfo || scalar @packetoutvalue != 0)
        {
            $ref_device_errlog->{$device_ip} .= "出向包速率告警\n";
            if(defined $packetoutInfo)
            {
                $ref_device_errlog->{$device_ip} .= $packetoutInfo;
            }

            if(scalar @packetoutvalue != 0)
            {
                $ref_device_errlog->{$device_ip} .= join(",",@packetoutvalue);
                $ref_device_errlog->{$device_ip} .= " 没有取到值\n";
            }
        }

        if(defined $errpacketinInfo || scalar @errpacketinvalue != 0)
        {
            $ref_device_errlog->{$device_ip} .= "入向错包速率告警\n";
            if(defined $errpacketinInfo)
            {
                $ref_device_errlog->{$device_ip} .= $errpacketinInfo;
            }

            if(scalar @errpacketinvalue != 0)
            {
                $ref_device_errlog->{$device_ip} .= join(",",@errpacketinvalue);
                $ref_device_errlog->{$device_ip} .= " 没有取到值\n";
            }
        }

        if(defined $errpacketoutInfo || scalar @errpacketoutvalue != 0)
        {
            $ref_device_errlog->{$device_ip} .= "出向错包速率告警\n";
            if(defined $errpacketinInfo)
            {
                $ref_device_errlog->{$device_ip} .= $errpacketinInfo;
            }

            if(scalar @errpacketinvalue != 0)
            {
                $ref_device_errlog->{$device_ip} .= join(",",@errpacketinvalue);
                $ref_device_errlog->{$device_ip} .= " 没有取到值\n";
            }
        }
    }

    foreach my $device_ip(keys %{$ref_interface_err_info})
    {
        delete $ref_interface_err_info->{$device_ip};
        delete $ref_interface_err_value->{$device_ip};
        delete $ref_interface_map->{$device_ip};
    }
}

sub send_mail
{       
    my($mailto,$subject,$msg,$mailserver,$mailfrom,$mailpwd) = @_;

    my $sender = new Mail::Sender;
#   $subject = encode_mimewords($subject,'Charset','UTF-8');
    $subject =  encode("gb2312", decode("utf8", $subject));           #freesvr 专用;
#   $msg = encode_mimewords($msg,'Charset','gb2312');
    $msg =  encode("gb2312", decode("utf8", $msg));              #freesvr 专用;

    if ($sender->MailMsg({
                smtp => $mailserver,
                from => $mailfrom,
                to => $mailto,
                subject => $subject,
                msg => $msg,
                auth => 'LOGIN', 
                authid => $mailfrom,
                authpwd => $mailpwd,
#               encoding => 'gb2312',
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
