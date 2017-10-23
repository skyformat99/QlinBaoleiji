#!/usr/bin/perl
use warnings;
use strict;
use File::Basename;
use File::Copy;
use Expect; 
use Cwd;

my($device_ip) = @ARGV;

my $dir = "/opt/freesvr/web/CA";
my $conf_dir = "/opt/freesvr/web/conf";

unless(-e $dir)
{
	print "$dir is not exist\n";
	exit(1);
}

my $status;
chdir $dir;

if(-e "demoCA")
{
	$status = `rm -rf demoCA/`;
}


$status = system("openssl genrsa -out server.key 4096 1>/dev/null 2>&1");
if($status != 0)
{
	print "err in 'openssl genrsa', return val not 0\n";
	exit(1);
}

my $line = `grep Issuer /opt/freesvr/web/CA/user.crt`;
my ($radNum) = $line=~/Baolei(\d+)/;
if(!defined($radNum))
{
	$radNum="";
}
chdir $dir;

$status = system("openssl req -new -sha256 -days 36500 -key /opt/freesvr/web/CA/server.key -out /opt/freesvr/web/CA/server.csr -subj /C=CN/ST=Baolei$radNum/L=Baolei$radNum/O=Baolei$radNum/OU=Baolei$radNum/CN=$device_ip  -config /etc/pki/tls/sec.cnf -extensions v3_req >/tmp/a 2>&1");
if($status != 0)
{
	print "err in 'openssl req server.csr ', return val not 0\n";
	exit(1);
}

mkdir "demoCA";
chdir "./demoCA";
mkdir "newcerts";

open(my $fd_fw,">index.txt");
close($fd_fw);

open($fd_fw,">serial");
print $fd_fw "01";
close($fd_fw);

chdir "..";

my $cmd = "openssl ca -md sha256 -startdate 120825000000Z -days 36500 -in /opt/freesvr/web/CA/server.csr -out /opt/freesvr/web/CA/server.crt -cert /opt/freesvr/web/CA/ca.crt -keyfile /opt/freesvr/web/CA/ca.key -config /etc/pki/tls/sec.cnf -extensions v3_req";

my $exp = Expect->new;
$exp->log_stdout(0);
$exp->spawn($cmd);
$exp->debug(0);

my @results = $exp->expect(10,[
		qr/Sign\s*the\s*certificate.*y/i,
		sub {
		my $self = shift ;

		$self->send_slow(0.1,"y\n");
		exp_continue;
		}
		],
		[
		qr/certified,\s*commit.*y/i,
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
		print "openssl ca 其他错误退出\n";
		return;
	}

	if($errno == 1)
	{
		print "openssl ca 命令超时\n";
		return;
	}
}

sleep(2);
$exp->soft_close();

my @files = (
		"$conf_dir/httpd.conf",
		"$conf_dir/extra/httpd-ssl.conf",
		);

foreach my $file(@files)
{
	&change_config($file);
}

sub change_config
{
	my($file) = @_;

	my $backup_name = (basename $file).".backup";
	my $backup_dir = dirname $file;

	unless(-e "$backup_dir/$backup_name")
	{
		copy($file,"$backup_dir/$backup_name");
	}

	open(my $fd_fr,"<$file");

	my @file_context;
	my $flag = 0;
	foreach my $line(<$fd_fr>)
	{
		chomp $line;
		if($line =~ /^ServerName/i)
		{
			$flag = 1;
			$line = "ServerName $device_ip";
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
