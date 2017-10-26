#!/usr/bin/perl
use warnings;
use strict;
use Expect;
use File::Basename;
use File::HomeDir;

our($local_path,$des_filename) = @ARGV;
unless(defined $local_path)
{
    print "need local access log path\n";
    exit 1;
}

our $time_now_utc = time;
my($min,$hour,$mday,$mon,$year) = (localtime $time_now_utc)[1..5];
($min,$hour,$mday,$mon,$year) = (sprintf("%02d", $min),sprintf("%02d", $hour),sprintf("%02d", $mday),sprintf("%02d", $mon + 1),$year+1900);
our $time_now_str = "$year$mon$mday$hour$min"."00";
our $date_now_str = "$year$mon$mday";

our $template_file = "/home/wuxiaolong/app_log/template";
our $des_ip = "172.16.210.116";
our $src_ip = "103.30.149.78";
our $des_path = "/var/log/memapp/";
$des_path =~ s/\/$//g;
our $username = "root";
our $passwd = "OMaudit123";
our $port = 2288;
our @REs;

&init_REs();
&create_file();

#my $des_file = "$des_path/".basename($local_path).".$src_ip.$time_now_str";
my $des_file = "$des_path/$des_filename.$src_ip.$time_now_str";
my $cmd = "scp -P $port -r /tmp/RE_applog $username\@$des_ip:$des_file;echo \"scp status:\$?\"";
print $cmd,"\n";

my $status = &scp_func($cmd,$des_ip,$username,$passwd);
open(my $fd_fw,">>./appupload_log");
if($status == 0)
{       
    print "scp success\n";
    print $fd_fw "$time_now_str\tscp success\n";
}
else            
{               
    print "scp fail\n"; 
    print $fd_fw "$time_now_str\tscp fail\n";
#    exit 1;
}
&append_func();
unlink "/tmp/RE_applog";

sub init_REs
{
    open(my $fd_fr,"<$template_file");
    foreach my $line(<$fd_fr>)
    {
        chomp $line;
        push @REs,$line;
    }
    close $fd_fr;
}

sub create_file
{
    open(my $fd_fr,"<$local_path");
    open(my $fd_fw,">/tmp/RE_applog");
    foreach my $line(<$fd_fr>)
    {
        my $flag = 0;
        chomp $line;
        foreach my $RE(@REs)
        {
            if($line =~ /$RE/i)
            {
                $flag = 1;
                last;
            }
        }

        if($flag == 1)
        {
            print $fd_fw $line,"\n";
        }
    }

    close $fd_fw;
    close $fd_fr;
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

sub append_func
{
    my $date_log = dirname($local_path)."/".basename($local_path).".$date_now_str";
    open(my $fd_fw,">>$date_log");
    open(my $fd_fr,"<$local_path");

    foreach my $line(<$fd_fr>)
    {
        print $fd_fw $line;
    }

    close $fd_fr;
    close $fd_fw;

    open($fd_fw,">$local_path");
    close $fd_fw;
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
