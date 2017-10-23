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

$exp->expect(120,[
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
$cmd = "free | grep -i 'mem'";
$exp->send("$cmd\n");
$exp->expect(2, undef);

my $result = $exp->before();
my @context = split /\n/,$result;

foreach my $line(@context)
{
	if($line =~ /^mem/i)
	{
#		print $line,"\n";
		my($total,$used,$buffers,$cache) = (split /\s+/,$line)[1,2,5,6];
		my $memory = floor(($used-$buffers-$cache)/$total*100);
		print "mem:$memory\n";
	}
}

