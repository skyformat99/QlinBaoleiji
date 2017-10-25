#!/usr/bin/perl
use strict;
use warnings;

use RRDs;
use DBI;
use DBD::mysql;

use Crypt::CBC;
use MIME::Base64;

our($mysql_user,$mysql_passwd) = &get_local_mysql_config();
our $dbh=DBI->connect("DBI:mysql:database=cacti;host=localhost;mysql_connect_timeout=5",$mysql_user,$mysql_passwd,{RaiseError=>1});

our($sec,$min,$hour,$mday,$mon,$year) = (localtime)[0..5];
($sec,$min,$hour,$mday,$mon,$year) = (sprintf("%02d", $sec),sprintf("%02d", $min),sprintf("%02d", $hour),sprintf("%02d", $mday),sprintf("%02d", $mon + 1),$year+1900);
our $mysql_time=int($year.$mon.$mday.$hour.$min."00");
our $utc_time = time;

our $time;
my $arg = "now";
if($arg eq "now")
{
	my $clear = $dbh->prepare("truncate ratelastlist");
	$clear->execute();
	$time = 300;
}elsif($arg eq "hour"){
	$time = 3600;
}elsif($arg eq "day"){
	$time = 86400;
}elsif($arg eq "week"){
	$time = 604800;
}elsif($arg eq "month"){
	$time = 2592000;
}elsif($arg eq "year"){
	$time = 31536000;
}

=pod
if($ARGV[0] eq "now")
{
	my $clear = $dbh->prepare("truncate ratelastlist");
	$clear->execute();
	$time = 300;
}elsif($ARGV[0] eq "hour"){
	$time = 3600;
}elsif($ARGV[0] eq "day"){
	$time = 86400;
}elsif($ARGV[0] eq "week"){
	$time = 604800;
}elsif($ARGV[0] eq "month"){
	$time = 2592000;
}elsif($ARGV[0] eq "year"){
	$time = 31536000;
}
=cut

if($time == 300)
{
	my @send_info;
	my $thold;

	my $mail_switch = $dbh->prepare("select sms_warning,mail_warning from ossim.alert_mailsms");
	$mail_switch->execute();
	my $ref_mail = $mail_switch->fetchrow_hashref();
	my $sms_warning = $ref_mail->{"sms_warning"};
	my $mail_warning = $ref_mail->{"mail_warning"}; 
	$mail_switch->finish();            

	my $sqr_rrdid = $dbh->prepare("select id, ip, name, type, formula, thold_hi, thold_low,mail_alert,sms_alert,time_interval,last_sendtime,graph_template_id from list_host");
	$sqr_rrdid->execute();

	while(my $ref_rrdid = $sqr_rrdid->fetchrow_hashref())
	{
		my $rrd_id = $ref_rrdid->{"id"};
		my $formula = $ref_rrdid->{"formula"};
		my $ip = $ref_rrdid->{"ip"};
		my $type = $ref_rrdid->{"type"};
		my $thold_hi = $ref_rrdid->{"thold_hi"};
		my $thold_low = $ref_rrdid->{"thold_low"};
		my $name = $ref_rrdid->{"name"};
		my $mail_alert = $ref_rrdid->{"mail_alert"};
		my $sms_alert = $ref_rrdid->{"sms_alert"};
		my $time_interval = $ref_rrdid->{"time_interval"};
		my $last_sendtime = $ref_rrdid->{"last_sendtime"};
		my $graph_template_id = $ref_rrdid->{"graph_template_id"};

		my @result = &rrd_value($rrd_id,$formula);
		&mysql_write($rrd_id,@result);

		my $last_value =  $result[0];

		if($last_value > $thold_hi || $last_value < $thold_low)
		{
			if($last_value > $thold_hi){$thold = $thold_hi;}
			else{$thold = $thold_low;}
			if($mail_warning == 0){$mail_alert = 0;}
			if($sms_warning == 0){$sms_alert = 0;}

			if( ($mail_alert !=0 || $sms_alert !=0 ) && (int(($utc_time - $last_sendtime)/60) > $time_interval) )
			{
				my $temp = join "\t",($last_value,$type,$rrd_id,$ip,$name,$mail_alert,$sms_alert,$graph_template_id,$thold);
				push @send_info,$temp;
			}
			else
			{
				&warn_msg($last_value,$type,$rrd_id,$ip,$name,$mail_alert,$sms_alert,$time_interval,$last_sendtime,$thold);
			}
		}
	}

	defined(my $pid = fork) or die "cannot fork:$!";
	unless($pid){
		exec "/home/wuxiaolong/fork2/warning.pl",@send_info;
	}
}
else
{
	my $sqr_rrdid = $dbh->prepare("select id, formula from list_host");
	$sqr_rrdid->execute();
	while(my $ref_rrdid = $sqr_rrdid->fetchrow_hashref())
	{
		my $rrd_id = $ref_rrdid->{"id"};
#		print $rrd_id,"\n";
		my $formula = $ref_rrdid->{"formula"};

		my @result = &rrd_value($rrd_id,$formula);
		&mysql_write($rrd_id,@result);
	}
}


sub rrd_value
{
	my($rrd_id,$formula) = @_;
	if($formula =~ m/([\+ \- \* \/ \( \)])/x)     #not one var in the formula
	{
#		print $formula,"\t";

		my $formula_copy = $formula;
		my @values;

		$formula_copy =~ s/[\+ \- \* \/ \( \)]+/ /gx;
		$formula_copy =~ s/^\s+//;
		my @formula_var = split /\s+/, $formula_copy;

		foreach my $var(@formula_var)
		{
			if($var =~ /\D+/)
			{
				my $temp_value = &one_var($rrd_id,$var,$time,0);
				if($temp_value == -2)
				{
					return (-2,-2,-2);
				}
				else
				{
					push  @values,$temp_value;
				}
			}
		}

		my $value_num = scalar(@{$values[0]})-1;
		my @base_val;

		foreach my $i(0..$value_num)
		{
			my $formula_value = $formula;

			$formula_value =~ s/[^\d \+ \- \* \/ \( \)]*\d+[^\d \+ \- \* \/ \( \)]+/qqqq/gx;
			$formula_value =~ s/[^\d \+ \- \* \/ \( \)]+\d+[^\d \+ \- \* \/ \( \)]*/qqqq/gx;

			my $var_num = scalar(@values)-1;
			foreach my $j(0..$var_num)
			{
				if(defined $values[$j][$i])
				{
					$formula_value =~ s/[^\+ \- \* \/ \( \) \d \.]+/$values[$j][$i]/x;
				}
				else
				{
					last;
				}
			}

			if(!($formula_value =~ m/[a-zA-Z]+/))
			{
				push @base_val ,eval($formula_value);
			}
		}
#		print "@base_val","\n";

		my $average;
		my $max;
		my $min;
		my $count = 0;

		if(scalar(@base_val) == 0)
		{
			$average = $max = $min = -1;
		}
		else
		{
			foreach(@base_val)
			{

				if($count == 0)
				{
					++$count;
					$average = $max = $min = $_;
				}
				else
				{
					++$count;
					$average += $_;
					if($_ > $max)
					{
						$max = $_;
					}
					if($_ < $min)
					{
						$min = $_;
					}
				}
			}
			$average /= $count;
		}
#		print $average,"\t",$max,"\t",$min,"\n";
		return($average,$max,$min);
	}
	else
	{
		my @result = &one_var($rrd_id,$formula,$time,1);
#			print "@result\n";
		my $average = shift @result;
		if($average == -2)
		{
			return (-2,-2,-2);
		}
		my $max = shift @result;
		my $min = shift @result;

		return($average,$max,$min);
	}
}

sub mysql_write
{
	my($rrd_id,$average,$max,$min) = @_;

	if($time == 300)
	{
		my $sqr_insert = $dbh->prepare("insert into ratelastlist (value,list_host_id,time) values ($average,$rrd_id,$mysql_time)");
		$sqr_insert->execute();
		$sqr_insert->finish();
	}elsif($time == 3600){
		my $sqr_insert = $dbh->prepare("insert into ratehourlist (value,valuemax,valuemin,list_host_id,time) values ($average,$max,$min,$rrd_id,$mysql_time)");
		$sqr_insert->execute();
		$sqr_insert->finish();
	}elsif($time == 86400){
		my $sqr_insert = $dbh->prepare("insert into ratedaylist (value,valuemax,valuemin,list_host_id,time) values ($average,$max,$min,$rrd_id,$mysql_time)");
		$sqr_insert->execute();
		$sqr_insert->finish();
	}elsif($time == 604800){
		my $sqr_insert = $dbh->prepare("insert into rateweeklist (value,valuemax,valuemin,list_host_id,time) values ($average,$max,$min,$rrd_id,$mysql_time)");
		$sqr_insert->execute();
		$sqr_insert->finish();
	}elsif($time == 2592000){
		my $sqr_insert = $dbh->prepare("insert into ratemonthlist (value,valuemax,valuemin,list_host_id,time) values ($average,$max,$min,$rrd_id,$mysql_time)");
		$sqr_insert->execute();
		$sqr_insert->finish();
	}elsif($time == 31536000){
		my $sqr_insert = $dbh->prepare("insert into rateyearlist (value,valuemax,valuemin,list_host_id,time) values ($average,$max,$min,$rrd_id,$mysql_time)");
		$sqr_insert->execute();
		$sqr_insert->finish();
	}
}

sub warn_msg
{
    my($average,$type,$rrd_id,$ip,$name,$mail_alert,$sms_alert,$time_interval,$last_sendtime,$thold) = @_;

    my $mail_flag;
    my $sms_flag;

    if($mail_alert == 0)
    {
        $mail_flag = 0;
    }elsif( int(($utc_time - $last_sendtime)/60) <= $time_interval ){
        $mail_flag = 3;
    }

    if($sms_alert == 0)
    {
        $sms_flag = 0;
    }elsif( int(($utc_time - $last_sendtime)/60) <= $time_interval ){
        $sms_flag = 3;
    }

	my $sqr_insert = $dbh->prepare("insert into listdata_log (ip,last_value,name,time,thold,mail,sms) values ('$ip',$average,'$name',$mysql_time,$thold,$mail_flag,$sms_flag)");
	$sqr_insert->execute();
	$sqr_insert->finish();
}

sub one_var
{
	my($rrd_id, $formula,$time,$flag) = @_;

	my $sqr_rrdfile = $dbh->prepare("select rrdfile from list_rrd where id = $rrd_id and dsname = \"$formula\"");
	$sqr_rrdfile->execute();
	my $ref_rrdfile = $sqr_rrdfile->fetchrow_hashref();
	my $rrd_file = $ref_rrdfile->{"rrdfile"};
	my $end_time = `date +%s`;
	$end_time = int($end_time);
	my ($start,$step,$ds_names,$data) = RRDs::fetch($rrd_file, "AVERAGE", "-s", "$end_time-$time", "-e", "$end_time");
	my $count = 0;
	if(!(defined $ds_names))
	{
		return -2;
	}
	if(scalar(@$ds_names) !=1)
	{
		$count = -1;
		$count = &dsname_pos($ds_names,$formula,$count);
	}

	if($flag == 1)
	{
		return &calculate($data,$count);
	}
	else
	{
		return &calculate_arr($data,$count);
	}
}

sub calculate_arr
{
	my($data,$count) = @_;
	my @valres;
	foreach my $line(@$data)
	{
		foreach my $val($$line[$count])
		{
			push @valres,$val;
		}
	}
	pop @valres;
	return \@valres;
}

sub dsname_pos
{
	my($ds_names,$formula,$count) = @_;
	foreach my $name(@$ds_names)
	{
		++$count;
		if($name eq $formula)
		{
			return $count;
		}
	}

}

sub calculate
{
	my($data,$count) = @_;
	my $sum=0;
	my $max;
	my $min;
	my $num=0;
	my $average;
	foreach my $line(@$data)
	{
		foreach my $val($$line[$count])
		{
			if(defined($val))
			{
				++$num;
				$sum += $val;
				if($num == 1)
				{
					$max = $val;
					$min = $val;
				}
				else 
				{
					if($val > $max)
					{
						$max = $val;
					}
					if($val < $min)
					{
						$min = $val;
					}
				}
			}
		}
	}
	if($num != 0)
	{
		$average = $sum / $num;
	}
	else
	{
		$average = $max = $min = -1;
	}
	return ($average,$max,$min);
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
