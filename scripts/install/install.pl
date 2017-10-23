#!/usr/bin/perl
use warnings;
use strict;
use File::Basename;
use File::Copy;
use Expect;

our $debug = 1;
our $version = 5;

my @config_files = (
		"/etc/sysctl.conf",
		"/etc/selinux/config",
		"/etc/sysconfig/network-scripts/ifcfg-eth0",
		);

foreach my $file(@config_files)
{
	&config_process($file);
}
&passwd_process();
&inittab_process();

&install_MailSend("/opt/freesvr/1/modules/perlmod/Mail-Sender-0.8.16");
&install_Inline("/opt/freesvr/1/modules/perlmod/Inline-0.50");

&network_process();
&grub_process();

sub install_MailSend
{
    my($install) = @_;
	unless(-e $install)
	{
		print "$install 不存在\n";
		return;
	}
    chdir $install;

    if($debug == 1)
    {
        print "安装 $install\n";
    }

    if($debug == 1)
    {
        print "make clean\n";
    }
    my $status = system("make clean 1>/dev/null 2>&1");

    if($debug == 1)
    {
        print "perl Makefile.PL\n";
    }
    $status = system("perl Makefile.PL 1>/dev/null 2>&1");

    if($status != 0)
    {
        print "指令 perl Makefile.PL 出错\n";
        return;
    }

    my $cmd = "make";
    if($debug == 1)
    {
        print "make\n";
    }

    my $exp = Expect->new;
    $exp->log_stdout(0);
    $exp->spawn($cmd);
    $exp->debug(0);
    my @results = $exp->expect(10,[
            qr/Mail::Sender.*y\/N/i,
            sub {
            my $self = shift ;

            $self->send_slow(0.1,"N\n");
            }
            ],
            );

    if(defined $results[1])
    {
        my $errno;
        if($results[1] =~ /(\d+).*:.*/i)
        {
            $errno = $1;
        }
        else
        {
            print "make 其他错误退出\n";
            return;
        }

        if($errno == 1)
        {
            print "make 命令超时\n";
            return;
        }
    }

    sleep(2);
	$exp->soft_close();

    if($debug == 1)
    {
        print "make install\n";
    }
    $status = system("make install 1>/dev/null 2>&1");
    if($status != 0)
    {
        print "指令 make install 出错\n";
        return;
    }
}

sub install_Inline
{
    my($install) = @_;
	unless(-e $install)
	{
		print "$install 不存在\n";
		return;
	}
    chdir $install;

    if($debug == 1)
    {
        print "安装 $install\n";
    }

    if($debug == 1)
    {
        print "make clean\n";
    }
    my $status = system("make clean 1>/dev/null 2>&1");

    if($debug == 1)
    {
        print "perl Makefile.PL\n";
    }

    my $cmd = "perl Makefile.PL";

    my $exp = Expect->new;
    $exp->log_stdout(0);
    $exp->spawn($cmd);
    $exp->debug(0);

    my @results = $exp->expect(10,[
            qr/install\s*Inline.*y/i,
            sub {
            my $self = shift ;

            $self->send_slow(0.1,"y\n");
            }
            ],
            );

    if(defined $results[1])
    {
        my $errno;
        if($results[1] =~ /(\d+).*:.*/i)
        {
            $errno = $1;
        }
        else
        {
            print "perl Makefile.PL 其他错误退出\n";
            return;
        }

        if($errno == 1)
        {
            print "perl Makefile.PL 命令超时\n";
            return;
        }
    }

    sleep(2);
	$exp->soft_close();

    if($debug == 1)
    {
        print "make\n";
    }
    $status = system("make 1>/dev/null 2>&1");
    if($status != 0)
    {
        print "指令 make 出错\n";
        return;
    }

    if($debug == 1)
    {
        print "make install\n";
    }
    $status = system("make install 1>/dev/null 2>&1");
    if($status != 0)
    {
        print "指令 make install 出错\n";
        return;
    }
}

sub config_process
{
    my($file) = @_;
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
        if($line =~ /net\.ipv4\.ip_forward\s*=\s*0/i)
        {
            $flag = 1;
            $line =~ s/0/1/;
        }

        if($line =~ /SELINUX\s*=\s*enforcing/i)
        {
            $flag = 1;
            $line =~ s/enforcing/disabled/;
        }

        if($line =~ /NETWORK\s*=\s*.*/i || $line =~ /BROADCAST\s*=\s*.*/i)
        {
            $flag = 1;
            next;
        }

        push @file_context,$line;
    }

    close $fd_fr;

    if($flag == 1)
    {
        open(my $fd_fw,">$file");
        foreach my $line(@file_context)
        {
            print $fd_fw $line,"\n";
        }

		close $fd_fw;
    }
}

sub network_process
{
	my $if_file;
	if($version == 5)
	{
#		$if_file = "../network/ifcfg-eth0";
		$if_file = "/etc/sysconfig/network-scripts/ifcfg-eth0";
	}
	elsif($version == 6)
	{
#		$if_file = "../network/ifcfg-Auto_eth0";
		$if_file = "/etc/sysconfig/network-scripts/ifcfg-Auto_eth0";
	}

#	my $network_file = "../network/network";
	my $network_file = "/etc/sysconfig/network";
	my $gateway_line = "";
	my @file_context;

	open(my $fd_fr,"<$network_file");
	foreach my $line(<$fd_fr>)
	{
		chomp $line;
		if($line =~ /GATEWAY/i)
		{
			$gateway_line = $line;
			next;
		}
		push @file_context,$line;
	}
	close $fd_fr;

	open(my $fd_fw,">$network_file");
	foreach my $line(@file_context)
	{
		print $fd_fw $line,"\n";
	}
	close $fd_fw;

	my $flag = 0;
	@file_context = ();
	open($fd_fr,"<$if_file");
	foreach my $line(<$fd_fr>)
	{
		chomp $line;
		if($line =~ /BROADCAST/i || $line =~ /NETWORK/i)
		{
			next;
		}
		if($line =~ /^GATEWAY/i)
		{
			$flag = 1;
		}
		push @file_context,$line;
	}

	if($flag == 0 && $gateway_line ne "")
	{
		push @file_context,$gateway_line;
	}
	close $fd_fr;

	open($fd_fw,">$if_file");
	foreach my $line(@file_context)
	{
		print $fd_fw $line,"\n";
	}
	close $fd_fw;
}

sub passwd_process
{
    my $file = "/etc/passwd";
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
        if($line =~ /^monitor/i)
        {
            my @passwd_context = split /:/,$line;
            unless($passwd_context[2] == 0 && $passwd_context[3] == 0)
            {
                $flag = 1;
                $passwd_context[2] = 0;
                $passwd_context[3] = 0;
                $line = join(":",@passwd_context);
            }
        }

        push @file_context,$line;
    }

    if($flag == 1)
    {
        open(my $fd_fw,">$file");
        foreach my $line(@file_context)
        {
            print $fd_fw $line,"\n";
        }
        close $fd_fw;
    }
}

sub inittab_process
{
    my $file = "/etc/inittab";
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
        if(!($line =~ /^#/) && $line =~ /initdefault/i)
        {
            my @initdef_context = split /:/,$line;
            unless($initdef_context[1] == 3)
            {
                my $end_char = "";
                if($line =~ /:$/)
                {
                    $end_char = ":";
                }

                $flag = 1;
                $initdef_context[1] = 3;
                $line = join(":",@initdef_context);
                $line .= $end_char;
            }
        }

        push @file_context,$line;
    }

    if($flag == 1)
    {
        open(my $fd_fw,">$file");
        foreach my $line(@file_context)
        {
            print $fd_fw $line,"\n";
        }
        close $fd_fw;
    }
}

sub grub_process
{
    my $file = "/etc/grub.conf";
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
        if(!($line =~ /^#/) && $line =~ /^default\s*=/i)
        {
            unless((split /=/,$line)[1] == 0)
            {
                $flag = 1;
                $line =~ s/=.*/=0/;
            }
        }

        push @file_context,$line;
    }

    close $fd_fr;

    if($flag == 1)
    {
        open(my $fd_fw,">$file");
        foreach my $line(@file_context)
        {
            print $fd_fw $line,"\n";
        }

        close $fd_fw;
    }
}
