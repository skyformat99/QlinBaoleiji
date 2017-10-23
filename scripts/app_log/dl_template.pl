#!/usr/bin/perl
use warnings;
use strict; 
use Expect; 
use File::Basename;
use File::HomeDir;

our $des_ip = "172.16.210.116";
our $dst_file = "/home/wuxiaolong/template.pl";
our $template_file = "./template";
our $username = "root";
our $passwd = "OMaudit123";
our $port = 2288;

#my $cmd = "scp -P $port $username\@$des_ip:$dst_file $template_path/".basename($dst_file).";echo \"scp status:\$?\"";
my $cmd = "scp -P $port $username\@$des_ip:$dst_file $template_file;echo \"scp status:\$?\"";
print $cmd,"\n";

my $status = &scp_func($cmd,$des_ip,$username,$passwd);
if($status == 0)
{
    print "scp success\n";
}
else
{
    print "scp fail\n";
}

sub scp_func    
{               
    my($cmd,$device_ip,$username,$passwd) = @_;

    my $result = 1;
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

        my @results = $exp->expect(undef,
                [
                qr/scp\s*status:/i,
                sub {
                my $self = shift ;
                $result = (split /\n/,$self->after())[0];
                $result = (split /\s+/, $result)[0];
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
                    qr/password:/i,
                sub {
                    my $self = shift ;
                    $self->send_slow(0.1,"$passwd\n");
                    exp_continue;
                }
                ],

                    [
                        qr/Host key verification failed/i,
                    sub
                    {
                        my $tmp = &rsa_err_process($username,$device_ip);
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

                    [
                        qr/Permission denied/i,
                    sub
                    {
                        print "$device_ip ssh passwd error\n";
                        $flag = 3;
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
                elsif($rsa_flag == 0 && $flag != 0 && $flag != 3)
                {
                    $flag = 4;
                }

                if($flag == 4 && defined $results[1])
                {
                    print "$device_ip $cmd exec error\n";
                }

                $exp->close();
    }

    if($count >= 10)
    {
        print "$device_ip rsa err and fail to fix\n";
    }

    return $result;
}

sub rsa_err_process
{
    my($user,$ip) = @_;
    my $home = File::HomeDir->users_home($user);
    unless(defined $home)
    {
        print "$ip cant find home dir for user $user\n";
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
