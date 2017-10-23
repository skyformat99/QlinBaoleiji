#!/usr/bin/perl
use warnings;
use strict;

if(&check_process("keepalived") == 0)
{
    exit 0;
}

if(&check_process("ssh-audit")==0 || &check_process("ftp-audit")==0 || &check_process("Freesvr_RDP")==0 || &check_process("freesvr-authd")==0)
{
    `killall -9 keepalived`;
}

sub check_process
{
	my($name) = @_;
    my $result = `ps -ef | grep $name | grep -v -E "grep|kill_keepalived"`;
    if($result ne "") {return 1;}
    else {return 0;}
}

