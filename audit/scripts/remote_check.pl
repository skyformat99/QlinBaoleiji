#!/usr/bin/perl
use warnings;
use strict;
use DBI;
use DBD::mysql;
use File::Basename;
use Expect;
use File::HomeDir;
use Crypt::CBC;
use MIME::Base64;

our $output_dir = "/tmp";
$output_dir =~ s/\/$//;

unless(-d $output_dir)
{
    `mkdir -p $output_dir`;
}

our $time_now_utc = time;
my($min,$hour,$mday,$mon,$year) = (localtime $time_now_utc)[1..5];
($min,$hour,$mday,$mon,$year) = (sprintf("%02d", $min),sprintf("%02d", $hour),sprintf("%02d", $mday),sprintf("%02d", $mon + 1),$year+1900);
our $time_now_str = "$year$mon$mday$hour$min"."00";

our $max_process_num = 2;
our $exist_process = 0;
our %device_info;
our %cmd_info;
our @device_arr;

#our($mysql_user,$mysql_passwd) = &get_local_mysql_config();
my $dbh=DBI->connect("DBI:mysql:database=audit_sec;host=localhost;mysql_connect_timeout=5","root","",{RaiseError=>1});
my $utf8 = $dbh->prepare("set names utf8");
$utf8->execute();
$utf8->finish();

my %id_hash;
my $sqr_select = $dbh->prepare("select b.id script_id,c.id detail_id,d.id device_id,d.device_ip,d.username,udf_decrypt(cur_password) passwd,d.port,d.login_method,b.su,b.scriptpath,c.line_number,c.action,c.regex,c.low_value,c.high_value from autorun_index_devices a left join autorun_index b on a.autorun_id=b.id left join devices d on a.devicesid=d.id left join autorun_detail_config c on b.id=c.autorun_index_id where b.lastruntime is not null and (unix_timestamp(now())-unix_timestamp(b.lastruntime)>b.period*60)");
$sqr_select->execute();
while(my $ref = $sqr_select->fetchrow_hashref())
{
    my $script_id = $ref->{"script_id"};
    my $detail_id = $ref->{"detail_id"};
    my $device_id = $ref->{"device_id"};
    my $device_ip = $ref->{"device_ip"};
    my $username = $ref->{"username"};
    my $passwd = $ref->{"passwd"};
    my $port = $ref->{"port"};
    my $login_method = $ref->{"login_method"};
    my $su = $ref->{"su"};
    my $scriptpath = $ref->{"scriptpath"};
    my $line_number = $ref->{"line_number"};
    my $action = $ref->{"action"};
    my $regex = $ref->{"regex"};
    my $low_value = $ref->{"low_value"};
    my $high_value = $ref->{"high_value"};

    unless(defined $device_ip)
    {
        next;
    }

    unless(-e $scriptpath)
    {
        print "scriptpath is not exists\n";
        next;
    }

    my @cmds;
    my $num = 1;

    unless(defined $id_hash{$script_id})
    {
        $id_hash{$script_id} = 1;
    }

    open(my $fd_fr, "<$scriptpath");
    while(my $line = <$fd_fr>)
    {
        chomp $line;
        if(!defined $line_number)
        {
            push @cmds, $line;
        }
        elsif($num == $line_number)
        {
            push @cmds, $line;
            last;
        }
        ++$num;
    }
    close $fd_fr;

    my @true_cmds;
    foreach my $cmd(@cmds)
    {
        unless($cmd =~ /^\s*$/ || $cmd =~ /^\#/)
        {
            push @true_cmds, $cmd;
        }
    }

    unless(exists $device_info{$device_id})
    {
        my @login_info = ($device_ip,$username,$passwd,$port,$login_method);
        $device_info{$device_id} = \@login_info;
    }

    unless(exists $cmd_info{$device_id})
    {
        my @infos;
        $cmd_info{$device_id} = \@infos;
    }

    foreach my $cmd(@true_cmds)
    {
        my @tmp = ($script_id,$detail_id,$su,$scriptpath,$cmd,$action,$regex,$low_value,$high_value);
        push @{$cmd_info{$device_id}}, \@tmp;
    }
}
$sqr_select->finish();

if(scalar keys %id_hash != 0)
{
    my $sqr_update = $dbh->prepare("update autorun_index set lastruntime=now() where id in (".join(",",keys %id_hash) .")");
    $sqr_update->execute();
    $sqr_update->finish();
}
$dbh->disconnect();

if(scalar keys %device_info == 0) {exit;}
@device_arr = keys %device_info;
if($max_process_num > scalar @device_arr){$max_process_num = scalar @device_arr;}

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
                exit;
            }
        }
    }
}

sub fork_process
{
    my $device_id = shift @device_arr;
    unless(defined $device_id){return;}
    my $pid = fork();
    if (!defined($pid))
    {
        print "Error in fork: $!";
        exit 1;
    }

    if ($pid == 0)
    {
        my $dbh=DBI->connect("DBI:mysql:database=audit_sec;host=localhost;mysql_connect_timeout=5","root","",{RaiseError=>1});
        my $utf8 = $dbh->prepare("set names utf8");
        $utf8->execute();
        $utf8->finish();

        my($device_ip,$username,$passwd,$port,$login_method) = @{$device_info{$device_id}};

        my $exp = Expect->new;
        $exp->log_stdout(0);
        $exp->debug(0);

        my $login_flag = 0;
        if($login_method == 5)
        {
            $login_flag = &telnet_process($exp,$device_ip,$username,$passwd,$port);
        }
        elsif($login_method == 3 || $login_method == 25)
        {
            my $version = "";
            if($login_method == 25)
            {
                $version = "-1";
            }
            ($login_flag,$exp) = &ssh_process($exp,$device_ip,$version,$username,$passwd,$port);
        }

        my %script_cache;
        if($login_flag == 1)
        {
            foreach my $ref(@{$cmd_info{$device_id}})
            {
                my $script_id = $ref->[0];
                my $scriptpath = $ref->[3];
                my $cmd = $ref->[4];
                my $action = $ref->[5];
                unless(-e "$output_dir/${device_ip}_$device_id")
                {
                    mkdir "$output_dir/${device_ip}_$device_id", 0755;
                }

                my $output_file = basename $scriptpath;
                $output_file .= "_$script_id";
                $output_file .= "_$time_now_str";

                $output_file = "$output_dir/${device_ip}_$device_id/$output_file";

                unless(exists $script_cache{$script_id})
                {
                    my $sqr_insert = $dbh->prepare("insert into autorun_result(datetime,device_id,autorun_index_id,result,output_file) values ('$time_now_str',$device_id,$script_id,1,'$output_file')");
                    $sqr_insert->execute();
                    $sqr_insert->finish();

                    $script_cache{$script_id} = 1;
                }

                my $result = &remote_check_process($dbh,$exp,$output_file,$device_id,$device_ip,@{$ref});
                if(defined $ref->[5])
                {
                    my $sqr_select = $dbh->prepare("select id from autorun_result where device_id=$device_id and autorun_index_id=$script_id and datetime='$time_now_str'");
                    $sqr_select->execute();
                    my $ref_select = $sqr_select->fetchrow_hashref();
                    my $autorun_result_id = $ref_select->{"id"};
                    $sqr_select->finish();

                    my $sqr_insert = $dbh->prepare("insert into autorun_result_detail(datetime,autorun_result_id,cmd,action,result) values ('$time_now_str',$autorun_result_id,'$cmd','$action','$result')");
                    $sqr_insert->execute();
                    $sqr_insert->finish();
                }
            }
        }

        $dbh->disconnect();
        exit 0;
    }
    ++$exist_process;
}

sub remote_check_process
{
    my($dbh,$exp,$output_file,$device_id,$device_ip,$script_id,$detail_id,$su,$scriptpath,$cmd,$action,$regex,$low_value,$high_value) = @_;

    my $result = "FAIL";
    open(my $fd_fw, ">>$output_file");
    print $fd_fw "============$cmd============\n";

    my @output = &get_output($exp,$cmd);

    foreach my $line(@output)
    {
        print $line,"\n";
        print $fd_fw "$line\n";

        if(defined $action && $action eq 'c' && $line =~ /$regex/i)
        {
            $result = "OK";
            last;
        }

        if(defined $action && $action eq 'd' && $line =~ /$regex/i)
        {
            $result = $1;
            last;
        }
    }
    close $fd_fw;

    unless(defined $action)
    {
        $result = "";
    }

    print "result: $result\n";
    return $result;
}

sub telnet_process
{
    my($exp,$device_ip,$username,$passwd,$port) = @_;

	my $login_flag = 0;
	$exp->spawn("telnet $device_ip $port");
	my @results = $exp->expect(30,
			[
			qr/Username:/i,
			sub {
			my $self = shift ;
			$self->send_slow(0.1,"$username\n");
			exp_continue;
			}
			],

			[
			qr/Password:/i,
			sub {
			my $self = shift ;
			$self->send_slow(0.1,"$passwd\n");
			exp_continue;
			}
			],

			[
			qr/~\]/i,
			sub {
				&log_process($device_ip,"$device_ip telnet login success");
				$login_flag = 1;
			}
			],
				);

			if($login_flag == 1)
			{
				return 1;
			}

			if(defined $results[1])
			{
				&log_process($device_ip,"'telnet $device_ip' exec error $results[1]");
			}

			return 0;
}

sub ssh_process
{
	my($exp,$device_ip,$version,$username,$passwd,$port) = @_;

	my $count = 0;
	my $flag = 1;

	while($count < 5 && $flag == 1)
    {
        ++$count;

        if($count > 1)
        {
            $exp->hard_close();
            $exp = Expect->new;
            $exp->log_stdout(0);
            $exp->debug(0);
        }

        $exp->spawn("ssh $version -l $username $device_ip -p $port");

        my @results = $exp->expect(20,
                [
				qr/~\]/i,
                sub {
                $flag = 0;
                }
                ],

                [
                qr/password:/i,
                sub {
                my $self = shift ;
                $self->send_slow(0.1,"$passwd\n");
                exp_continue;
                }
                ],

                [
                qr/continue connecting.*yes\/no.*/i,
                sub {
                my $self = shift ;
                $self->send_slow(0.1,"yes\n");
                exp_continue;
                }
                ],

                    [
                        qr/Host key verification failed/i,
                    sub
                    {
                        $flag = &rsa_err_process($username,$device_ip);
                    }
                ],
                    );

                if($flag == 0)
                {
                    &log_process($device_ip,"$device_ip ssh login success");
                    return (1,$exp);
                }
                elsif($flag != 1)
                {
                    &log_process($device_ip,"$device_ip ssh login fail");
                    return (0,$exp);
                }
    }

    &log_process($device_ip,"$device_ip ssh login fail, loop 5 times");
    return (0,$exp);
}

sub get_output
{
	my($exp,$cmd) = @_;

	$exp->before();
	$exp->clear_accum();

	my @output;
	$exp->send("$cmd\n");

	my $nextline = undef;
	while(1)
	{
		$exp->expect(1, undef);
		my $tmp_str = $exp->before();
		my @tmp_lines = split /\n/,$tmp_str;

		if(defined $nextline && $nextline =~ /~\]/i)
		{
			last;
		}

		if(scalar @tmp_lines == 0)
		{
			next;
		}

		if(defined $nextline)
		{
			$tmp_lines[0] = $nextline.$tmp_lines[0];
			$nextline = undef;
		}

		unless($tmp_str =~ /\n$/)
		{
			$nextline = $tmp_lines[-1];
			pop @tmp_lines;
		}

		foreach my $line(@tmp_lines)
		{
			print $line,"\n";
            push @output, $line;
		}
		$exp->clear_accum();

		if(defined $nextline && $nextline =~ /~\]/i)
		{
			last;
		}
	}

	return @output;
}

sub log_process
{
	my($device_ip,$msg) = @_;
	print "$msg\n";
}

sub rsa_err_process
{
	my($user,$ip) = @_;
	my $home = File::HomeDir->users_home($user);
	unless(defined $home)
	{
		print "cant find home dir for user $user\n";
		return 2;
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

	return 1;
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
