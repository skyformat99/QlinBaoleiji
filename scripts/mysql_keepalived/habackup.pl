#!/usr/bin/perl
use warnings;
use strict;
use File::Basename;
use File::Copy;
use Expect;

our($peer_ip) = @ARGV;
our $slave_ip;

foreach my $line(`/sbin/ifconfig eth0`)
{
	chomp $line;
	if($line =~ /inet addr\s*:\s*(\S+)/)
	{
		$slave_ip = $1;
	}
}

&ssh_knownhost($peer_ip);

&restart_mysql();
&restart_keepalive();

&file_modify_process("/etc/xrdp/global.cfg","global-server",$slave_ip);
&file_modify_process("/opt/freesvr/audit/sshgw-audit/etc/freesvr-ssh-proxy_config","AuditAddress",$slave_ip);
&file_modify_process("/opt/freesvr/audit/etc/global.cfg","global-server",$slave_ip);
&file_modify_process("/opt/freesvr/audit/ftp-audit/etc/freesvr-ftp-audit.conf","AuditAddress",$slave_ip);
&file_modify_process("/home/wuxiaolong/5_backup/backup_session.pl","our\\s+\\\$localIp",$slave_ip);
&iptables_process($peer_ip);

&cron_modify_process("/home/wuxiaolong/5_backup/backup_session.pl");

&restart_program();

print "success\n";

sub ssh_knownhost
{
    my $cmd = "ssh -l root $peer_ip -p 2288";

    my $user = "root";
    my $ip = $peer_ip;


    my $count = 0;  
    my $flag = 1;   

    while($count < 10 && $flag == 1)
    {               
        ++$count;   
        my $rsa_flag = 0;

        my $exp = Expect->new;
        $exp->log_stdout(0);
        $exp->spawn($cmd);
        $exp->debug(0);

        my @results = $exp->expect(20,
                [
                qr/~\]/i,
                sub {
                $flag = 0; 
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
                    my $tmp = &rsa_err_process($user,$ip);
                    if($tmp == 0)
                    {
                        $rsa_flag = 1;
                    }
                    else
                    {
                        $rsa_flag = 2;
                    }
                }
        ],
            );

        if($rsa_flag == 1)
        {
            $flag = 1;
        }
        elsif($rsa_flag == 2)
        {
            $flag = 2;
        }
        elsif($rsa_flag == 0 && $flag != 0)
        {
            $flag = 3;
        }

        if($flag != 1 && $flag != 2)
        {
            if(defined $results[1])
            {
                print "$cmd exec error\n";
                print "fail\n";
                exit 1;
            }
        }

        $exp->close();
    }

    if($count >= 10)
    {
        print "rsa err and fail to fix\n";
        print "fail\n";
        exit 1;
    }
}

sub restart_mysql
{
    my $cmd = "/etc/init.d/mysqld stop 1>/dev/null 2>&1";
    system($cmd);

    my $file = "/opt/freesvr/sql/var/localhost-relay-bin.index";
    my $dir = dirname $file;

    unless(-e $dir)
    {
        $cmd = "mkdir -p $dir";
        system($cmd);
    }

    foreach my $file(glob "/opt/freesvr/sql/var/localhost-relay-bin.*")
    {
        unlink $file;
    }

    open(my $fd_fw,">$file");
    close $fd_fw;

    my $user = getpwnam "mysql";
    my $group = getgrnam "mysql";
    chown $user,$group,$file;

    $cmd = "/etc/init.d/mysqld start 1>/dev/null 2>&1";
    if(system($cmd) != 0)
    {
        print "mysql 启动失败\n";
        print "fail\n";
        exit 1;
    }
}

sub file_modify_process
{
    my($file,$attr,$ip) = @_;
    my $dir = dirname $file;
    my $file_name = basename $file;
    my $backup_name = $file_name.".backup";

    unless(-e "$dir/$backup_name")
    {
        copy($file,"$dir/$backup_name");
    }

    open(my $fd_fr,"<$file");

    my @file_context;
    my $flag = 0;
    foreach my $line(<$fd_fr>)
    {   
        chomp $line;
        if($line =~ /^$attr/i)
        {   
            $line =~ s/(\d{1,3}\.){3}\d{1,3}/$ip/;
        }

        push @file_context,$line;
    }

    close $fd_fr;

    open(my $fd_fw,">$file");
    foreach my $line(@file_context)
    {   
        print $fd_fw $line,"\n";
    }

    close $fd_fw;
}

sub iptables_process 
{
    my($peer_ip) = @_;
    my $file = "/etc/sysconfig/iptables";

    my $dir = dirname $file;
    my $file_name = basename $file;
    my $backup_name = $file_name.".backup";

    unless(-e "$dir/$backup_name")
    {   
        copy($file,"$dir/$backup_name");
    }   

    open(my $fd_fr,"<$file");
    my @file_context;
    my $flag = 0;
    foreach my $line(<$fd_fr>)
    {
        chomp $line; 
        if($line =~ /^-A\s*RH-Firewall/i)
        {
            if($flag == 0)
            {
                $flag = 1;
            } 

            if($line =~ /-s\s*$peer_ip/i)
            {
                $flag = 2;
            }
        }

        if($line =~ /^-A\s*RH-Firewall.*REJECT/i && $flag == 1)
        {
            $flag = 3;
            push @file_context,"-A RH-Firewall-1-INPUT -s $peer_ip -j ACCEPT";
        }

        push @file_context,$line;
    }
    close $fd_fr;

    open(my $fd_fw,">$file");
    foreach my $line(@file_context)
    {
        print $fd_fw $line,"\n";
    }

    close $fd_fw;
    if(system("service iptables restart 1>/dev/null 2>&1") != 0)
    {
        print "iptables restart 失败\n";
        print "fail\n";
        exit 1;
    }
}

sub cron_modify_process
{
    my($file) = @_;

    if(-e "/var/spool/cron/root")
    {
        open(my $fd_fr,"</var/spool/cron/root");
        my @file_context;
        my $flag = 0;
        foreach my $line(<$fd_fr>)
        {
            chomp $line;
            if($line =~ /$file/i)
            {
                $flag = 1;
                $line = "*/10 * * * * $file";
            }

            push @file_context,$line;
        }

        if($flag == 0)
        {
            push @file_context,"*/10 * * * * $file";
        }

        close $fd_fr;

        open(my $fd_fw,">/var/spool/cron/root");
        foreach my $line(@file_context)
        {
            print $fd_fw $line,"\n";
        }

        close $fd_fw;
    }
    else
    {
        open(my $fd_fw,">/var/spool/cron/root");
        print $fd_fw "*/10 * * * * $file\n";
        close $fd_fw;
    }
}

sub restart_program
{
    my %service_hash;
    open(my $fd_fr,"</opt/freesvr/audit/etc/process.ini");

    foreach my $line(<$fd_fr>)
    {
        chomp $line;
        $line =~ s/^\[//;
        $line =~ s/\]$//;
        my ($name,$cmd) = split /=/,$line;

        unless($name eq "ftp-audit" || $name eq "Freesvr_RDP" || $name eq "ssh-audit")
        {
            next;
        }

        unless(exists $service_hash{$name})
        {
            my @temp_arr;
            push @temp_arr,$cmd;
            if($name eq "ftp-audit") {push @temp_arr,21;}
            elsif($name eq "Freesvr_RDP") {push @temp_arr,3389;}
            elsif($name eq "ssh-audit") {push @temp_arr,22;}

            $service_hash{$name} = \@temp_arr;
        }
    }

    foreach my $process_name(keys %service_hash)
    {
        my $val = $service_hash{$process_name};

        &stop_process($process_name,$val->[0],$val->[1]);
        sleep 1;
        my $status = &start_process($process_name,$val->[0],$val->[1]);
        if($status == 0)
        {
            print "$process_name 启动失败\n";
            print "fail\n";
            exit 1;
        }
    }
}

sub restart_keepalive
{
    while(1)
    {
        my $result = `ps -ef | grep keepalived | grep -v -E "vim|grep|perl"`;
        if($result ne "")
        {
            my @result_arr = split /\n/,$result;
            foreach my $line(@result_arr)
            {
                my $pid = (split /\s+/,$line)[1];
                unless($pid =~ /\d+/) {next;}
                kill 9,$pid;
            }
            next;
        }
        else
        {
            last;
        }
    }

    if(system("/usr/local/sbin/keepalived") != 0)
    {
        print "keepalived 启动失败\n";
        print "fail\n";
        exit 1;
    }
}

sub stop_process
{   
    my($name,$cmd,$port) = @_;
    my $result = `/usr/sbin/lsof -n -i:$port`;
    if($result ne "")
    {
        my %pid_arr;
        my @result_arr = split /\n/,$result;
        foreach my $line(@result_arr)
        {
            my $pid = (split /\s+/,$line)[1];
            unless($pid =~ /\d+/) {next;}
            unless(exists $pid_arr{$pid})
            {
                $pid_arr{$pid} = 1;
            }
        }

        foreach my $pid(keys %pid_arr)
        {
            kill 9,$pid;
        }
    }
}

sub start_process
{
    my($name,$cmd,$port) = @_;

    my $delete_file;
    if($name eq "Freesvr_RDP")
    {   
        $delete_file = "/var/run/freesvr_rdp[proxy].pid";
    }

    if(defined $delete_file)
    {   
        unlink $delete_file;
    }

    my $result = `/usr/sbin/lsof -n -i:$port`;
    if($result eq "")
    {   
        if(system("$cmd 1>/dev/null 2>&1") == 0)
        {
            return 1;
        }
        else
        {
            return 0;
        }
    }
}

sub rsa_err_process
{
    my($user,$ip) = @_;
    my $home = File::HomeDir->users_home($user);
    unless(defined $home)
    {   
        print "cant find home dir for user $user\n";
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
