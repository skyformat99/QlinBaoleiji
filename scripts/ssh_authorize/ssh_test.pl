#!/usr/bin/perl
use warnings;
use strict;
use Getopt::Long;
use Expect;

#ssh -o PreferredAuthentications=publickey -i /home/wuxiaolong/aa sshkey1@172.16.210.151 -p 2288
#ssh -o PreferredAuthentications=publickey -i /opt/freesvr/audit/sshgw-audit/keys/pvt/25.pvt sshkey1@172.16.210.151 -p 2288
#ssh-keyscan -p 2288 -t rsa 172.16.210.151

our $host = undef;
our $port = undef;
our $user = undef;
our $pvt_key = undef;

GetOptions("h=s"=>\$host,"u=s"=>\$user,"i=s"=>\$pvt_key,"p=i"=>\$port);

unless(defined $host && defined $user && defined $port)
{
    print "usage: ./ssh_test.pl -h <host_name> -u <username> -i <pvt key file path> -p <port>\n";
    exit 1;
}

&generate_known_host();
my $status = &test_ssh_connection();
exit $status;

sub generate_known_host
{
    my $output = `ssh-keyscan -p $port -t rsa $host 2>/dev/null`;
    my $type;
    my $pubkey;
    my $cur_line = undef;
    foreach my $line(split /\n/,$output)
    {
        chomp $line;
        if($line =~ /^$host/)
        {
            ($type,$pubkey) = (split /\s+/, $line)[1,2];
            $cur_line = $line;
            last;
        }
    }
    unless(defined $cur_line)
    {
        return;
    }

    my $change = 1;
    my @cache;
    push @cache, $cur_line;
    my $file = (glob "~/.ssh/known_hosts")[0];
    if(-e $file)
    {
        open(my $fd_fr, "<$file");
        while(my $line = <$fd_fr>)
        {
            chomp $line;
            if($line =~ /^$host/)
            {
                my($tmp_type,$tmp_pubkey) = (split /\s+/, $line)[1,2];
                if($tmp_type eq $type && $tmp_pubkey eq $pubkey)
                {
                    $change = 0;
                }
            }
            else
            {
                push @cache, $line;
            }
        }
        close $fd_fr;
    }

    if($change==1)
    {
        print "regenerate known_hosts\n";
        open(my $fd_fw, ">$file");
        foreach my $line(@cache)
        {
            print $fd_fw $line,"\n";
        }
        close $fd_fw;
    }
}

sub test_ssh_connection
{
    my $cmd = "ssh -o PreferredAuthentications=publickey -i $pvt_key $user\@$host -p $port";
    print $cmd,"\n";

    my $flag = 0;
    my $exp = Expect->new;
    $exp->log_stdout(0);
    $exp->debug(0);

    $exp->spawn("$cmd");

    my @results = $exp->expect(100,
        [
        qr/Last\s+login:/i,
        sub {
        }
        ],
    );

    if(defined $results[1])
    {
        $flag = 1;
    }
    $exp->close();

    if($flag == 1)
    {
        print "cannot ssh to $host by $user with pvt key $pvt_key\n";
    }
    else
    {
        print "ssh to $user\@$host successful\n";
    }
    return $flag;
}
