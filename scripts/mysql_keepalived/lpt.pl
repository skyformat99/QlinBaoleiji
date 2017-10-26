#!/usr/bin/perl
use warnings;
use strict;
use DBI;
use DBD::mysql;
use File::Basename;
use File::Copy;

our($peer_ip) = @ARGV;
our $mycnf_path = "/opt/freesvr/1/etc";
$mycnf_path =~ s/\/$//;

&iptables_process($peer_ip);
&mysql_process();

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
        exit 1;
    }
}

sub mysql_process
{
    copy("$mycnf_path/my_slave.cnf","/etc/my.cnf") or die "copy master my.cnf failed: $!";
    my $cmd = "/etc/init.d/mysqld restart 1>/dev/null 2>&1";
    if(system($cmd) != 0)
    {
        print "mysql 重启失败\n";
        exit 1;
    }
}
