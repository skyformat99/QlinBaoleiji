#!/usr/bin/perl
use warnings;
use strict;
use File::Basename;
use File::Copy;

our %config;

open(my $fd_fr,"<./heartbeat_config");
foreach my $line(<$fd_fr>)
{
	chomp $line;

	my($name,$val) = split /\s+/,$line;
	if($name eq "local")
	{
		unless(exists $config{"local"})
		{
			my @tmp = (undef,undef);
			$config{"local"} = \@tmp;
		}

		$config{"local"}->[0] = $val;
	}
	elsif($name eq "remote")
	{
		unless(exists $config{"remote"})
		{
			my @tmp = (undef,undef);
			$config{"remote"} = \@tmp;
		}

		$config{"remote"}->[0] = $val;
	}
	elsif($name eq "remotename")
	{
		unless(exists $config{"remote"})
		{
			my @tmp = (undef,undef);
			$config{"remote"} = \@tmp;
		}

		$config{"remote"}->[1] = $val;
	}
	elsif($name eq "vrrp")
	{
		unless(exists $config{"vrrp"})
		{
			my @tmp = (undef,undef);
			$config{"vrrp"} = \@tmp;
		}

		$config{"vrrp"}->[0] = $val;
	}
	elsif($name eq "vrrpmask")
	{
		unless(exists $config{"vrrp"})
		{
			my @tmp = (undef,undef);
			$config{"vrrp"} = \@tmp;
		}

		$config{"vrrp"}->[1] = $val;
	}
	elsif($name eq "pinghost")
	{
		unless(exists $config{"pinghost"})
		{
			$config{"pinghost"} = $val;
		}
	}
	elsif($name eq "force")
	{
		unless(exists $config{"force"})
		{
			$config{"force"} = $val;
		}
	}
}

my $result = `uname -n`;
chomp $result;
$config{"local"}->[1] = $result;

unless(exists $config{"local"})
{
	print "local info is not exist\n";
}
unless(exists $config{"remote"})
{
	print "remote info is not exist\n";
}
unless(exists $config{"vrrp"})
{
	print "vrrp info is not exist\n";
}
unless(exists $config{"pinghost"})
{
	print "pinghost info is not exist\n";
}
unless(exists $config{"force"})
{
	print "force info is not exist\n";
}

foreach my $key(keys %config)
{
	if($key eq "local" || $key eq "remote" || $key eq "vrrp")
	{
		unless(defined $config{$key}->[0] && defined $config{$key}->[1])
		{
			print "$key info is not exist\n";
		}
	}
	else
	{
		unless(defined $config{$key})
		{
			print "$key info is not exist\n";
		}
	}
}

&backup_file("/etc/hosts");
&hosts_process("/etc/hosts",$config{"local"}->[0],$config{"local"}->[1]);
&hosts_process("/etc/hosts",$config{"remote"}->[0],$config{"remote"}->[1]);

&backup_file("/etc/ha.d/ha.cf");
&hacf_process("/etc/ha.d/ha.cf",$config{"pinghost"},$config{"local"}->[1],$config{"remote"}->[1]);

&backup_file("/etc/ha.d/haresources");
&haresources_process("/etc/ha.d/haresources",$config{"local"}->[1],$config{"vrrp"}->[0],$config{"vrrp"}->[1]);

if($config{"force"} == 1)
{
	if(-e "/var/lib/heartbeat/crm/")
	{
		my $result = `rm -rf /var/lib/heartbeat/crm/cib.xml*`;
	}
	else
	{
		my $result = `mkdir -p /var/lib/heartbeat/crm/`;
	}

	my $result = `/usr/lib64/heartbeat/haresources2cib.py --stout -c /etc/ha.d/ha.cf /etc/ha.d/haresources `;
	&cib_process("/var/lib/heartbeat/crm/cib.xml");
}

sub backup_file
{
	my($file) = @_;

	unless(-e $file)
	{
		return;
	}

	my $dir = dirname $file;
	my $file_name = basename $file;
	my $backup_name = $file_name.".backup";

	unless(-e "$dir/$backup_name")
	{    
		copy($file,"$dir/$backup_name");
	}                   
}

sub hosts_process
{
	my($file,$host_ip,$host_name) = @_;
	my @file_context;

	open(my $fd_fr,"<$file");
	foreach my $line(<$fd_fr>)
	{
		chomp $line;

		unless($line =~ /^\#/ || $line =~ /^\s*$/)
		{
			my($ip,$name) = split /\s+/,$line;
			if($ip eq "$host_ip" && $name eq "$host_name")
			{
				close $fd_fr;
				return;
			}
		}
			
		push @file_context,$line;
	}
	close $fd_fr;

	my $line = "$host_ip\t$host_name";
	push @file_context,$line;

	open(my $fd_fw,">$file");
	foreach my $line(@file_context)
	{
		print $fd_fw $line,"\n";
	}
	close $fd_fw;
}

sub hacf_process
{
	my($file,$ping_host,$local_name,$remote_name) = @_;
	my @file_context;
	my $node_count = 1;

	open(my $fd_fr,"<$file");
	foreach my $line(<$fd_fr>)
	{
		chomp $line;

		if($line =~ /^ucast/i)
		{
			my @tmp = split /\s+/,$line;
			$tmp[2] = $ping_host;
			$line = join(" ",@tmp);
		}
		elsif($line =~ /^node/i)
		{
			my @tmp = split /\s+/,$line;
			if($node_count == 1)
			{
				$tmp[1] = $local_name;
			}
			elsif($node_count == 2)
			{
				$tmp[1] = $remote_name;
			}

			$line = join(" ",@tmp);
			++$node_count;
		}
		elsif($line =~ /^ping/i)
		{
			my @tmp = split /\s+/,$line;
			$tmp[1] = $ping_host;
			$line = join(" ",@tmp);
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

sub haresources_process
{
	my($file,$local_name,$vrrp_ip,$vrrp_mask) = @_;
	my @file_context;

	open(my $fd_fr,"<$file");
	foreach my $line(<$fd_fr>)
	{
		chomp $line;
		push @file_context,$line;
	}
	close $fd_fr;

	my $line = pop @file_context;
	my @tmp1 = split /\s+/,$line;
	$tmp1[0] = $local_name;

	my @tmp2 = split /\//,$tmp1[1];
	$tmp2[0] = $vrrp_ip;
	$tmp2[1] = $vrrp_mask;

	$tmp1[1] = join("/",@tmp2);
	$line = join(" ",@tmp1);

	push @file_context,$line;

	open(my $fd_fw,">$file");
	foreach my $line(@file_context)
	{
		print $fd_fw $line,"\n";
	}
	close $fd_fw;
}

sub cib_process
{
	my($file) = @_;
	my @file_context;
	my $count = 1;
	my $blank1;
	my $blank2;

	open(my $fd_fr,"<$file");
	foreach my $line(<$fd_fr>)
	{
		chomp $line;

		if($count == 9)
		{
			$line =~ s/value="0"/value="100"/;
		}
		elsif($count == 10)
		{
			$line =~ s/value="0"/value="-100"/;
		}
		elsif($count == 52)
		{
			$line =~ /(\s*).*/;
			$blank1 = $1;
		}
		elsif($count == 53)
		{
			$line =~ /(\s*).*/;
			$blank2 = $1;
		}
		elsif($count == 55)
		{
			my $tmp = "$blank1".'<rule id="rsc_location_group_1:connected:rule" score="-INFINITY" boolean_op="or">';
			push @file_context,$tmp;

			$tmp = "$blank2".'<expression id="rsc_location_group_1:connected:expr:undefined" attribute="pingd" operation="not_defined"/>';
			push @file_context,$tmp;
			
			$tmp = "$blank2".'<expression id="rsc_location_group_1:connected:expr:zero" attribute="pingd" operation="lte" value="0"/>';
			push @file_context,$tmp;

			$tmp = "$blank1".'</rule>';
			push @file_context,$tmp;
		}

		push @file_context,$line;
		++$count;
	}
	close $fd_fr;

	$file_context[37] =~ /value="(\d+)"/;
	my $tmp_mask = $1;

	$file_context[38] =~ /value="(.*)"/;
	my $tmp_nic = $1;

	$file_context[37] =~ s/value="\d+"/value="$tmp_nic"/;
	$file_context[38] =~ s/value=".*"/value="$tmp_mask"/;

	open(my $fd_fw,">$file");
	foreach my $line(@file_context)
	{
		print $fd_fw $line,"\n";
	}
	close $fd_fw;
}
