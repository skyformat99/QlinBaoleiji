#!/usr/bin/perl
use warnings;
use strict;
use Expect;
use POSIX qw/ceil floor/;

my($user,$des_ip,$port,$passwd) = @ARGV;
my $log_file = "/tmp/expect_log";

my $cmd = "ssh -l $user $des_ip -p $port";

my $exp = Expect->new;
$exp->log_stdout(0);
$exp->spawn($cmd);

$exp->expect(20,[
		qr/password/i,
		sub {
		my $self = shift ;
		$self->send_slow(0.1,"$passwd\n");
		}
		],
		[
		qr/yes/i,
		sub {
		my $self = shift ;
		$self->send_slow(0.1,"yes\n");
		exp_continue;
		}
		],
		);

$exp->before();
$cmd = "/usr/bin/top -b -n 2 | grep -E -i '^cpu'";
$exp->send("$cmd\n");
$exp->expect(5, undef);

my $result = $exp->before();
my @context = split /\n/,$result;

my $cpu_info;
foreach my $line(@context)
{   
	print $line,"\n";
	if($line =~ /(\d+\.\d+)%id/i)
	{
		$cpu_info = $line;
	}
}   

@context = ();
push @context,$cpu_info;

foreach my $line(@context)
{
	print "final $line\n";
	if($line =~ /(\d+\.\d+)%id/i)
	{
		my $cpu = $1;
		$cpu = 100 - $cpu;
		print "cpu:$cpu\n";
	}
}

