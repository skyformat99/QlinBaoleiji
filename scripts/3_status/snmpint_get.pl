#!/usr/bin/perl
use warnings;
use strict;
use DBI;
use DBD::mysql;
use RRDs;
use Crypt::CBC;
use MIME::Base64;
use POSIX qw/ceil floor/;

our $debug = 1;
our $max_process_num = 5;           
our $exist_process = 0;  
our @device_info_ips;

our %device_snmpkey;
our %cache_val;
our %cur_val;
our %result_val;
our %port_map;
our %thold_info;
our %rrd_flag;
our %rrd_file;
our %warning_info;

our $time_now_utc = time;
my($min,$hour,$mday,$mon,$year) = (localtime $time_now_utc)[1..5];
($min,$hour,$mday,$mon,$year) = (sprintf("%02d", $min),sprintf("%02d", $hour),sprintf("%02d", $mday),sprintf("%02d", $mon + 1),$year+1900);
our $time_now_str = "$year$mon$mday$hour$min"."00";

our($mysql_user,$mysql_passwd) = &get_local_mysql_config();
my $dbh=DBI->connect("DBI:mysql:database=audit_sec;host=localhost;mysql_connect_timeout=5",$mysql_user,$mysql_passwd,{RaiseError=>1});
            
my $utf8 = $dbh->prepare("set names utf8");
$utf8->execute();
$utf8->finish();

my $sqr_select = $dbh->prepare("select device_ip from snmp_interface group by device_ip");
$sqr_select->execute();
while(my $ref_select = $sqr_select->fetchrow_hashref())
{
	my $device_ip = $ref_select->{"device_ip"};
    &create_device_info($dbh,$device_ip);
	unless(exists $device_snmpkey{$device_ip})
	{
		my $sqr_select_key = $dbh->prepare("select snmpkey from servers where snmpnet=1 and device_ip='$device_ip'");
		$sqr_select_key->execute();
		my $ref_select_key = $sqr_select_key->fetchrow_hashref();
		my $snmp_key = $ref_select_key->{"snmpkey"};
		$sqr_select_key->finish();
		unless(defined $snmp_key)
		{
            &err_process($dbh,$device_ip,"$device_ip 没有 snmpkey");
			next;
		}

		$device_snmpkey{$device_ip} = $snmp_key;
	}
}
$sqr_select->finish();
$dbh->disconnect;

if(scalar keys %device_snmpkey == 0){exit 0;}
@device_info_ips = keys %device_snmpkey;
if($max_process_num > scalar @device_info_ips){$max_process_num = scalar @device_info_ips;}

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
                `rm -fr /tmp/port_status`;
                my $dbh=DBI->connect("DBI:mysql:database=audit_sec;host=localhost;mysql_connect_timeout=5",$mysql_user,$mysql_passwd,{RaiseError=>1});

                my $utf8 = $dbh->prepare("set names utf8");
                $utf8->execute();
                $utf8->finish();

                &set_nan_val($dbh);
                defined(my $pid = fork) or die "cannot fork:$!";
                unless($pid){
#                exec "/home/wuxiaolong/3_status/snmpint_warning.pl";
                }
                exit;
            }
        }
    }
}

sub fork_process
{
	my $device_ip = shift @device_info_ips;
	unless(defined $device_ip){return;}
	my $pid = fork();
	if (!defined($pid))
	{
		print "Error in fork: $!";
		exit 1;
	}

	if ($pid == 0)
	{
		my @temp_ips = keys %device_snmpkey;
		foreach my $key(@temp_ips)
		{
			if($device_ip ne $key)
			{
				delete $device_snmpkey{$key};
			}
		}

		my $dbh=DBI->connect("DBI:mysql:database=audit_sec;host=localhost;mysql_connect_timeout=5",$mysql_user,$mysql_passwd,{RaiseError=>1});

		my $utf8 = $dbh->prepare("set names utf8");
		$utf8->execute();
		$utf8->finish();

		&create_cache_val($dbh,$device_ip);
		&create_cur_val($dbh,$device_ip,$device_snmpkey{$device_ip});

        $dbh->disconnect;
        $dbh=DBI->connect("DBI:mysql:database=audit_sec;host=localhost;mysql_connect_timeout=5",$mysql_user,$mysql_passwd,{RaiseError=>1});
        $utf8 = $dbh->prepare("set names utf8");
		$utf8->execute();
		$utf8->finish();

        &result_process($dbh,$device_ip);
        $dbh->disconnect;
		exit 0;
	}

	++$exist_process;
}

sub create_device_info
{
	my ($dbh,$device_ip) = @_;

	my $sqr_select_index = $dbh->prepare("select port_index,port_describe,normal_status,traffic_in_highvalue,traffic_in_lowvalue,traffic_out_highvalue,traffic_out_lowvalue,packet_in_highvalue,packet_in_lowvalue,packet_out_highvalue,packet_out_lowvalue,err_packet_in_highvalue,err_packet_in_lowvalue,err_packet_out_highvalue,err_packet_out_lowvalue,traffic_RRD,traffic_rrdfile,packet_RRD,packet_rrdfile,err_packet_RRD,err_packet_rrdfile,mail_alarm,sms_alarm,unix_timestamp(mail_last_sendtime),unix_timestamp(sms_last_sendtime),send_interval from snmp_interface where device_ip='$device_ip' and enable=1");
	$sqr_select_index->execute();
	while(my $ref_select_index = $sqr_select_index->fetchrow_hashref())
	{
		my $port_index = $ref_select_index->{"port_index"};
		my $normal_status = $ref_select_index->{"normal_status"};
        my $port_describe = $ref_select_index->{"port_describe"};
		my $traffic_in_highvalue = $ref_select_index->{"traffic_in_highvalue"};
		my $traffic_in_lowvalue = $ref_select_index->{"traffic_in_lowvalue"};
		my $traffic_out_highvalue = $ref_select_index->{"traffic_out_highvalue"};
		my $traffic_out_lowvalue = $ref_select_index->{"traffic_out_lowvalue"};
		my $packet_in_highvalue = $ref_select_index->{"packet_in_highvalue"};
		my $packet_in_lowvalue = $ref_select_index->{"packet_in_lowvalue"};
		my $packet_out_highvalue = $ref_select_index->{"packet_out_highvalue"};
		my $packet_out_lowvalue = $ref_select_index->{"packet_out_lowvalue"};
		my $err_packet_in_highvalue = $ref_select_index->{"err_packet_in_highvalue"};
		my $err_packet_in_lowvalue = $ref_select_index->{"err_packet_in_lowvalue"};
		my $err_packet_out_highvalue = $ref_select_index->{"err_packet_out_highvalue"};
		my $err_packet_out_lowvalue = $ref_select_index->{"err_packet_out_lowvalue"};
		my $traffic_RRD_flag = $ref_select_index->{"traffic_RRD"};
		my $traffic_RRD_file = $ref_select_index->{"traffic_rrdfile"};
		my $packet_RRD_flag = $ref_select_index->{"packet_RRD"};
        my $packet_RRD_file = $ref_select_index->{"packet_rrdfile"};
		my $err_packet_RRD_flag = $ref_select_index->{"err_packet_RRD"};
		my $err_packet_RRD_file = $ref_select_index->{"err_packet_rrdfile"};
        my $mail_alarm = $ref_select_index->{"mail_alarm"};
        my $sms_alarm = $ref_select_index->{"sms_alarm"};
        my $mail_last_sendtime = $ref_select_index->{"unix_timestamp(mail_last_sendtime)"};
        my $sms_last_sendtime = $ref_select_index->{"unix_timestamp(sms_last_sendtime)"};
        my $send_interval = $ref_select_index->{"send_interval"};

		my @traffic_in_thold = ($traffic_in_highvalue,$traffic_in_lowvalue);
		my @traffic_out_thold = ($traffic_out_highvalue,$traffic_out_lowvalue);
		my @packet_in_thold = ($packet_in_highvalue,$packet_in_lowvalue);
		my @packet_out_thold = ($packet_out_highvalue,$packet_out_lowvalue);
		my @err_packet_in_thold = ($err_packet_in_highvalue,$err_packet_in_lowvalue);
		my @err_packet_out_thold = ($err_packet_out_highvalue,$err_packet_out_lowvalue);

        unless(exists $port_map{$device_ip})
        {
            my %tmp;
            $port_map{$device_ip} = \%tmp;
        }

        unless(exists $port_map{$device_ip}->{$port_index})
        {
            $port_map{$device_ip}->{$port_index} = $port_describe;
        }

        unless(exists $thold_info{$device_ip})
        {
            my %tmp;
            $thold_info{$device_ip} = \%tmp;
        }

        unless(exists $thold_info{$device_ip}->{$port_index})
        {
            my @info = ($normal_status,\@traffic_in_thold,\@traffic_out_thold,\@packet_in_thold,\@packet_out_thold,\@err_packet_in_thold,\@err_packet_out_thold);
            $thold_info{$device_ip}->{$port_index} = \@info;
        }

        unless(exists $rrd_flag{$device_ip})
        {
            my %tmp;
            $rrd_flag{$device_ip} = \%tmp;
        }

        unless(exists $rrd_flag{$device_ip}->{$port_index})
        {
            my @info = ($traffic_RRD_flag,$packet_RRD_flag,$err_packet_RRD_flag);
            $rrd_flag{$device_ip}->{$port_index} = \@info;
        }

        unless(exists $rrd_file{$device_ip})
        {
            my %tmp;
            $rrd_file{$device_ip} = \%tmp;
        }

        unless(exists $rrd_file{$device_ip}->{$port_index})
        {
            my @info = ($traffic_RRD_file,$packet_RRD_file,$err_packet_RRD_file);
            $rrd_file{$device_ip}->{$port_index} = \@info;
        }

        my $mail_alarm_status = -1;
        my $sms_alarm_status = -1;
        my $mail_out_interval = 0;              #邮件 是否超过时间间隔;
        my $sms_out_interval = 0;               #短信 是否超过时间间隔;

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

        unless(exists $warning_info{$device_ip})
        {
            my %tmp;
            $warning_info{$device_ip} = \%tmp;
        }

        unless(exists $warning_info{$device_ip}->{$port_index})
        {
            my @info = ($mail_alarm_status,$sms_alarm_status);
            $warning_info{$device_ip}->{$port_index} = \@info;
        }
	}
	$sqr_select_index->finish();
}

sub create_cache_val
{
	my ($dbh,$device_ip) = @_;
	my $sqr_select_index = $dbh->prepare("select port_index,unix_timestamp(datetime),traffic_in,traffic_out,packet_in,packet_out,err_packet_in,err_packet_out from snmp_interface_cache where device_ip = '$device_ip'");
	$sqr_select_index->execute();
	while(my $ref_select_index = $sqr_select_index->fetchrow_hashref())
	{
		my $port_index = $ref_select_index->{"port_index"};
		my $last_time = $ref_select_index->{"unix_timestamp(datetime)"};
		my $traffic_in = $ref_select_index->{"traffic_in"};
		my $traffic_out = $ref_select_index->{"traffic_out"};
		my $packet_in = $ref_select_index->{"packet_in"};
		my $packet_out = $ref_select_index->{"packet_out"};
		my $err_packet_in = $ref_select_index->{"err_packet_in"};
		my $err_packet_out = $ref_select_index->{"err_packet_out"};

        unless(exists $port_map{$device_ip}->{$port_index})
        {
            next;
        }

		my @last_port_val = ($last_time,$traffic_in,$traffic_out,$packet_in,$packet_out,$err_packet_in,$err_packet_out);

		unless(exists $cache_val{$device_ip})
		{
			my %tmp;
			$cache_val{$device_ip} = \%tmp;
		}

		unless(exists $cache_val{$device_ip}->{$port_index})
		{
			$cache_val{$device_ip}->{$port_index} = \@last_port_val;
		}
	}
	$sqr_select_index->finish();
}

sub create_cur_val
{
	my ($dbh,$device_ip,$snmp_key) = @_;
    my $process_num = 0;
	my %snmp_argv = (
			'ifOperStatus' => 0,
			'ifHCInOctets' => 1,
			'ifHCOutOctets' => 2,
			'ifHCInUcastPkts' => 3,
			'ifHCOutUcastPkts' => 4,
			'ifInErrors' => 5,
			'ifOutErrors' => 6
			);

    unless(-e "/tmp/port_status")
    {   
        mkdir "/tmp/port_status",0755;
    }

    if(-e "/tmp/port_status/$device_ip")
    {
        `rm -fr /tmp/port_status/$device_ip`;
    }
    mkdir "/tmp/port_status/$device_ip",0755;

    foreach my $key(keys %snmp_argv)
    {
        my $pid = fork();
        unless(defined($pid))
        {
            redo;
        }

        if ($pid == 0)
        {
            my $dbh=DBI->connect("DBI:mysql:database=audit_sec;host=localhost;mysql_connect_timeout=5",$mysql_user,$mysql_passwd,{RaiseError=>1});

            my $utf8 = $dbh->prepare("set names utf8");
            $utf8->execute();
            $utf8->finish();

            if(system("snmpwalk -v 2c -c $snmp_key $device_ip $key 1>/tmp/port_status/$device_ip/$key") != 0)
            {
                &err_process($dbh,$device_ip,"无法获得主机 $device_ip 接口 $key 状态, snmpwalk 指令执行出错");
            }
            $dbh->disconnect;
            exit;
        }
        ++$process_num;
    }

    while(wait())
    {
        --$process_num;
        if($process_num == 0)
        {
            last;
        }
    }

	unless(exists $cur_val{$device_ip})
	{
        foreach my $key(keys %snmp_argv)
        {
            unless(-e "/tmp/port_status/$device_ip/$key")
            {
                next;
            }

            open(my $fd_fr, "</tmp/port_status/$device_ip/$key");
            foreach my $line(<$fd_fr>)
            {
                my $index;
                my $val;

                if($key eq "ifOperStatus" && $line =~ /ifOperStatus\D*(\d+).*INTEGER\s*:*\s*(.+)$/i)
                {
                    $index = $1;
                    $val = $2;
                    $val =~ s/\(.*\)//;
                }
                elsif($line =~ /$key\D*(\d+).*Counter\d+\s*:*\s*(\d+)$/i)
                {
                    $index = $1;
                    $val = $2;
                }

                unless(defined $index)
                {
                    next;
                }

                unless(exists $port_map{$device_ip}->{$index})
                {
                    next;
                }

                unless(exists $cur_val{$device_ip})
                {
                    my %tmp;
                    $cur_val{$device_ip} = \%tmp;
                }

                unless(exists $cur_val{$device_ip}->{$index})
                {
                    my @tmp = (undef,undef,undef,undef,undef,undef,undef);
                    $cur_val{$device_ip}->{$index} = \@tmp;
                }

                $cur_val{$device_ip}->{$index}->[$snmp_argv{$key}] = $val;
            }
            close $fd_fr;
        }
    }
}

sub result_process
{
	my($dbh,$device_ip) = @_;
    foreach my $port_index(keys %{$cur_val{$device_ip}})
    {
        my $port_describe = $port_map{$device_ip}->{$port_index};

        my $traffic_in = $cur_val{$device_ip}->{$port_index}->[1];

        my $traffic_out = $cur_val{$device_ip}->{$port_index}->[2];
        my $packet_in = $cur_val{$device_ip}->{$port_index}->[3];
        my $packet_out = $cur_val{$device_ip}->{$port_index}->[4];
        my $err_packet_in = $cur_val{$device_ip}->{$port_index}->[5];
        my $err_packet_out = $cur_val{$device_ip}->{$port_index}->[6];

        &insert_into_cache($dbh,$device_ip,$port_index,$traffic_in,$traffic_out,$packet_in,$packet_out,$err_packet_in,$err_packet_out);
        my $cur_status = $cur_val{$device_ip}->{$port_index}->[0];
        &no_cache_val_process($dbh,$device_ip,$port_index,$cur_status,'cur_status');

        my $last_time = $cache_val{$device_ip}->{$port_index}->[0];

        $traffic_in = &cache_val_process($dbh,$device_ip,$port_index,1,'traffic_in',$last_time);
        $traffic_out = &cache_val_process($dbh,$device_ip,$port_index,2,'traffic_out',$last_time);
        if($rrd_flag{$device_ip}->{$port_index}->[0] == 1)
        {
            &update_rrd($dbh,$device_ip,$port_index,'traffic',$traffic_in,'traffic_in',$traffic_out,'traffic_out');
        }

        $packet_in = &cache_val_process($dbh,$device_ip,$port_index,3,'packet_in',$last_time);
        $packet_out = &cache_val_process($dbh,$device_ip,$port_index,4,'packet_out',$last_time);
        if($rrd_flag{$device_ip}->{$port_index}->[1] == 1)
        {
            &update_rrd($dbh,$device_ip,$port_index,'packet',$packet_in,'packet_in',$packet_out,'packet_out');
        }

        $err_packet_in = &cache_val_process($dbh,$device_ip,$port_index,5,'err_packet_in',$last_time);
        $err_packet_out = &cache_val_process($dbh,$device_ip,$port_index,6,'err_packet_out',$last_time);
        if($rrd_flag{$device_ip}->{$port_index}->[2] == 1)
        {
            &update_rrd($dbh,$device_ip,$port_index,'err_packet',$err_packet_in,'err_packet_in',$err_packet_out,'err_packet_out');
        }
    }
}

sub insert_into_cache
{
    my($dbh,$device_ip,$port_index,$traffic_in,$traffic_out,$packet_in,$packet_out,$err_packet_in,$err_packet_out) = @_;

    unless(defined $traffic_in || defined $traffic_out || defined $packet_in 
            || defined $packet_out || defined $err_packet_in || defined $err_packet_out)
    {
        return;
    }

    my $cmd;

    my $sqr_select = $dbh->prepare("select count(*) from snmp_interface_cache where device_ip='$device_ip' and port_index=$port_index");
    $sqr_select->execute();
    my $ref_select = $sqr_select->fetchrow_hashref();
    my $num = $ref_select->{"count(*)"};
    $sqr_select->finish();

    if($num == 0)
    {
        my $insert_bef = "insert into snmp_interface_cache (device_ip,datetime,port_index";
        my $insert_aft = " values ('$device_ip','$time_now_str',$port_index";

        if(defined $traffic_in)
        {
            $insert_bef .= ",traffic_in";
            $insert_aft .= ",$traffic_in";
        }

        if(defined $traffic_out)
        {
            $insert_bef .= ",traffic_out";
            $insert_aft .= ",$traffic_out";
        }

        if(defined $packet_in)
        {
            $insert_bef .= ",packet_in";
            $insert_aft .= ",$packet_in";
        }

        if(defined $packet_out)
        {
            $insert_bef .= ",packet_out";
            $insert_aft .= ",$packet_out";
        }

        if(defined $err_packet_in)
        {
            $insert_bef .= ",err_packet_in";
            $insert_aft .= ",$err_packet_in";
        }

        if(defined $err_packet_out)
        {
            $insert_bef .= ",err_packet_out";
            $insert_aft .= ",$err_packet_out";
        }

        $insert_bef .= ")";
        $insert_aft .= ")";
        $cmd = "$insert_bef $insert_aft";
    }
    else
    {
        $cmd = "update snmp_interface_cache set datetime = '$time_now_str'";
        if(defined $traffic_in)
        {
            $cmd .= ",traffic_in=$traffic_in";
        }
        else
        {
            $cmd .= ",traffic_in=null";
        }

        if(defined $traffic_out)
        {
            $cmd .= ",traffic_out=$traffic_out";
        }
        else
        {
            $cmd .= ",traffic_out=null";
        }

        if(defined $packet_in)
        {
            $cmd .= ",packet_in=$packet_in";
        }
        else
        {
            $cmd .= ",packet_in=null";
        }

        if(defined $packet_out)
        {
            $cmd .= ",packet_out=$packet_out";
        }
        else
        {
            $cmd .= ",packet_out=null";
        }

        if(defined $err_packet_in)
        {
            $cmd .= ",err_packet_in=$err_packet_in";
        }
        else
        {
            $cmd .= ",err_packet_in=null";
        }

        if(defined $err_packet_out)
        {
            $cmd .= ",err_packet_out=$err_packet_out";
        }
        else
        {
            $cmd .= ",err_packet_out=null";
        }

        $cmd .= " where device_ip = '$device_ip' and port_index = $port_index";
    }

    my $sqr_update = $dbh->prepare("$cmd");
    $sqr_update->execute();
    $sqr_update->finish();
}

sub no_cache_val_process
{
    my($dbh,$device_ip,$port_index,$cur_val,$col_name) = @_;
    my $port_describe = $port_map{$device_ip}->{$port_index};
    my $thold = $thold_info{$device_ip}->{$port_index}->[0];
    my $mail_alarm_status = $warning_info{$device_ip}->{$port_index}->[0];
    my $sms_alarm_status = $warning_info{$device_ip}->{$port_index}->[1];
    &update_status($dbh,$device_ip,$port_index,$cur_val,$col_name);

    if(defined $cur_val)
    {
        if($cur_val ne $thold)
        {
            my $sqr_insert = $dbh->prepare("insert into snmp_interface_warning_log (device_ip,datetime,port_index,port_describe,type,cur_val,thold,context,mail_status,sms_status) values ('$device_ip','$time_now_str',$port_index,'$port_describe','cur_status','$cur_val','$thold','当前值 $cur_val 正常值 $thold',$mail_alarm_status,$sms_alarm_status)");
            $sqr_insert->execute();
            $sqr_insert->finish();
        }

        if($debug == 1)
        {
            print "$device_ip $port_describe (index:$port_index): $col_name\t$cur_val\n";
        }
    }
    else
    {
        my $sqr_insert = $dbh->prepare("insert into snmp_interface_warning_log (device_ip,datetime,port_index,port_describe,type,cur_val,context,mail_status,sms_status) values ('$device_ip','$time_now_str',$port_index,'$port_describe','cur_status','-100','无法取到值',$mail_alarm_status,$sms_alarm_status)");
        $sqr_insert->execute();
        $sqr_insert->finish();

        if($debug == 1)
        {
            print "$device_ip $port_describe (index:$port_index): $col_name\t无法取到值\n";
        }
    }
}

sub cache_val_process
{
    my($dbh,$device_ip,$port_index,$arr_index,$colname,$last_time) = @_;

    my $port_describe = $port_map{$device_ip}->{$port_index};
    my $value = $cur_val{$device_ip}->{$port_index}->[$arr_index];
    my $last_value = $cache_val{$device_ip}->{$port_index}->[$arr_index];
    my $highvalue = $thold_info{$device_ip}->{$port_index}->[$arr_index]->[0];
    my $lowvalue = $thold_info{$device_ip}->{$port_index}->[$arr_index]->[1];

    if(defined $value)
    {
        if(defined $last_value && $value >= $last_value)
        {
            $value = ($value - $last_value)/($time_now_utc - $last_time);
            $value = floor($value*100)/100;
            &update_status($dbh,$device_ip,$port_index,$value,$colname);
            &warning_func($dbh,$device_ip,$port_index,$colname,$value,$highvalue,$lowvalue);

            if($debug == 1)
            {
                print "$device_ip $port_describe (index:$port_index): $colname\t$value\n";
            }
        }
        else
        {
            $value = -100;
            &update_status($dbh,$device_ip,$port_index,-100,$colname);

            if($debug == 1)
            {
                print "$device_ip $port_describe (index:$port_index): $colname\t无缓存记录\n";
            }
        }
    }
    else
    {
        $value = -100;
        &update_status($dbh,$device_ip,$port_index,-100,$colname);
        &warning_func($dbh,$device_ip,$port_index,$colname,-100,$highvalue,$lowvalue);

        if($debug == 1)
        {
            print "$device_ip $port_describe (index:$port_index): $colname\t无法取到值\n";
        }

    }
    return $value;
}

sub update_status
{
    my($dbh,$device_ip,$port_index,$cur_val,$col_name) = @_;
    my $cmd = "update snmp_interface set datetime = '$time_now_str',";
    if(defined $cur_val)
    {
        if($cur_val =~ /^\d+$/)
        {
            $cmd .= " $col_name=$cur_val";
        }
        else
        {
            $cmd .= " $col_name='$cur_val'";
        }
    }
    else
    {
        $cmd .= " $col_name=null";
    }

    $cmd .= " where device_ip = '$device_ip' and port_index = $port_index";
    my $sqr_update = $dbh->prepare("$cmd");
    $sqr_update->execute();
    $sqr_update->finish();
}

sub update_rrd
{
	my($dbh,$device_ip,$port_index,$file_name,$val_in,$dsname_in,$val_out,$dsname_out) = @_;
#    my $port_describe = $port_map{$device_ip}->{$port_index};
#    $port_describe = (split /\//,$port_describe)[0];

    if(!defined $val_in || $val_in < 0)
    {       
        $val_in = 'U';
    }

    if(!defined $val_out || $val_out < 0)
    {       
        $val_out = 'U';
    }

    my $rrdfile;
    if($file_name eq "traffic")
    {
        $rrdfile = $rrd_file{$device_ip}->{$port_index}->[0];
    }
    elsif($file_name eq "packet")
    {
        $rrdfile = $rrd_file{$device_ip}->{$port_index}->[1];
    }
    elsif($file_name eq "err_packet")
    {
        $rrdfile = $rrd_file{$device_ip}->{$port_index}->[2];
    }

	my $start_time = time;
	$start_time = (floor($start_time/300))*300;

#	my $dir = "/opt/freesvr/nm/$device_ip/interface/${port_index}_$port_describe";
	my $dir = "/opt/freesvr/nm/$device_ip/interface/$port_index";
	unless(-e "/opt/freesvr/nm/$device_ip/")
	{
		mkdir "/opt/freesvr/nm/$device_ip/",0755;
	}

	unless(-e "/opt/freesvr/nm/$device_ip/interface")
	{
		mkdir "/opt/freesvr/nm/$device_ip/interface",0755;
	}

	unless(-e $dir)
	{
		mkdir $dir,0755;
	}

    unless(defined $rrdfile && $rrdfile eq "$dir/$file_name.rrd")
    {
        if(defined $rrdfile && -e $rrdfile)
        {
            unlink $rrdfile;
        }

        $rrdfile = "$dir/$file_name.rrd";

        my $cmd;

        if($file_name eq "traffic")
        {
            $cmd = "update snmp_interface set traffic_rrdfile='$rrdfile' where device_ip='$device_ip' and port_index=$port_index";
        }
        elsif($file_name eq "packet")
        {
            $cmd = "update snmp_interface set packet_rrdfile='$rrdfile' where device_ip='$device_ip' and port_index=$port_index";
        }
        elsif($file_name eq "err_packet")
        {
            $cmd = "update snmp_interface set err_packet_rrdfile='$rrdfile' where device_ip='$device_ip' and port_index=$port_index";
        }

        my $sqr_update = $dbh->prepare("$cmd");
        $sqr_update->execute();
        $sqr_update->finish();
    }

	unless(-e $rrdfile)
	{
		my $create_time = $start_time-300;
		RRDs::create($rrdfile,
				'--start', "$create_time",
				'--step', '300',        
				"DS:$dsname_in:GAUGE:600:U:U",
				"DS:$dsname_out:GAUGE:600:U:U",
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
    
	RRDs::update(
			$rrdfile,
			'--', join(':', "$start_time", "$val_in","$val_out"),
			);
}

sub warning_func
{
    my($dbh,$device_ip,$port_index,$type,$value,$highvalue,$lowvalue) = @_;

    my $port_describe = $port_map{$device_ip}->{$port_index};
    my $mail_alarm_status = $warning_info{$device_ip}->{$port_index}->[0];
    my $sms_alarm_status = $warning_info{$device_ip}->{$port_index}->[1];

    if($value < 0)
    {
        my $sqr_insert = $dbh->prepare("insert into snmp_interface_warning_log (device_ip,datetime,port_index,port_describe,type,cur_val,context,mail_status,sms_status) values ('$device_ip','$time_now_str',$port_index,'$port_describe','$type','-100','无法取到值',$mail_alarm_status,$sms_alarm_status)");
        $sqr_insert->execute();
        $sqr_insert->finish();
    }
    elsif(defined $highvalue && defined $lowvalue && ($value > $highvalue || $value < $lowvalue))
    {
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

        my $sqr_insert = $dbh->prepare("insert into snmp_interface_warning_log (device_ip,datetime,port_index,port_describe,type,cur_val,thold,context,mail_status,sms_status) values ('$device_ip','$time_now_str',$port_index,'$port_describe','$type','$value','$thold','当前值 $value $tmp_context',$mail_alarm_status,$sms_alarm_status)");
        $sqr_insert->execute();
        $sqr_insert->finish();
    }
}

sub err_process
{
    my($dbh,$device_ip,$context) = @_;
    if($debug == 1)
    {
        print "[errlog]: $device_ip $context\n";        
    }

    my $sqr_insert = $dbh->prepare("insert into snmp_interface_errlog (device_ip,datetime,context) values ('$device_ip','$time_now_str','$context')");
    $sqr_insert->execute();
    $sqr_insert->finish();
}

sub set_nan_val
{
    my($dbh) = @_;

    my $sqr_delete = $dbh->prepare("delete from snmp_interface_cache where datetime<'$time_now_str'");
    $sqr_delete->execute();
    $sqr_delete->finish();

    my $sqr_select = $dbh->prepare("select device_ip,port_index,port_describe from snmp_interface where datetime<'$time_now_str' and enable=1");
    $sqr_select->execute();
    while(my $ref_select = $sqr_select->fetchrow_hashref())
    {
        my $device_ip = $ref_select->{"device_ip"};
        my $port_index = $ref_select->{"port_index"};
        my $port_describe = $ref_select->{"port_describe"};
        my $mail_alarm_status = $warning_info{$device_ip}->{$port_index}->[0];
        my $sms_alarm_status = $warning_info{$device_ip}->{$port_index}->[1];

        &update_status($dbh,$device_ip,$port_index,undef,'cur_status');
        my $sqr_insert = $dbh->prepare("insert into snmp_interface_warning_log (device_ip,datetime,port_index,port_describe,type,cur_val,context,mail_status,sms_status) values ('$device_ip','$time_now_str',$port_index,'$port_describe','cur_status','-100','无法取到值',$mail_alarm_status,$sms_alarm_status)");
        $sqr_insert->execute();
        $sqr_insert->finish();

        &update_status($dbh,$device_ip,$port_index,-100,'traffic_in');
        &warning_func($dbh,$device_ip,$port_index,'traffic_in',-100,undef,undef);

        &update_status($dbh,$device_ip,$port_index,-100,'traffic_out');
        &warning_func($dbh,$device_ip,$port_index,'traffic_out',-100,undef,undef);

        if($rrd_flag{$device_ip}->{$port_index}->[0] == 1)
        {
            &update_rrd($dbh,$device_ip,$port_index,'traffic',-100,'traffic_in',-100,'traffic_out');
        }

        &update_status($dbh,$device_ip,$port_index,-100,'packet_in');
        &warning_func($dbh,$device_ip,$port_index,'packet_in',-100,undef,undef);

        &update_status($dbh,$device_ip,$port_index,-100,'packet_out');
        &warning_func($dbh,$device_ip,$port_index,'packet_out',-100,undef,undef);

        if($rrd_flag{$device_ip}->{$port_index}->[1] == 1)
        {
            &update_rrd($dbh,$device_ip,$port_index,'packet',-100,'packet_in',-100,'packet_out');
        }

        &update_status($dbh,$device_ip,$port_index,-100,'err_packet_in');
        &warning_func($dbh,$device_ip,$port_index,'err_packet_in',-100,undef,undef);

        &update_status($dbh,$device_ip,$port_index,-100,'err_packet_out');
        &warning_func($dbh,$device_ip,$port_index,'err_packet_out',-100,undef,undef);

        if($rrd_flag{$device_ip}->{$port_index}->[2] == 1)
        {
            &update_rrd($dbh,$device_ip,$port_index,'err_packet',-100,'err_packet_in',-100,'err_packet_out');
        }

        if($debug == 1)
        {
            print "$device_ip $port_describe (index:$port_index): 所有值无法取到\n";
        }
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
