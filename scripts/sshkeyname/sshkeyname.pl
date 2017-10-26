#!/usr/bin/perl
use warnings;
use strict;
use DBI;
use DBD::mysql;
use Crypt::CBC;
use MIME::Base64;

#ssh -o PreferredAuthentications=publickey -i /home/wuxiaolong/aa sshkey1@172.16.210.151 -p 2288
#ssh -o PreferredAuthentications=publickey -i /opt/freesvr/audit/sshgw-audit/keys/pvt/25.pvt sshkey1@172.16.210.151 -p 2288
#ssh-keyscan -p 2288 -t rsa 172.16.210.151

our($mysql_user,$mysql_passwd) = &get_local_mysql_config();
our $dbh=DBI->connect("DBI:mysql:database=audit_sec;host=localhost;mysql_connect_timeout=5",$mysql_user,$mysql_passwd,{RaiseError=>1});
our $utf8 = $dbh->prepare("set names utf8");
$utf8->execute();
$utf8->finish();

my $sqr_select = $dbh->prepare("select sshpublickey,sshprivatekey,globalip,md5sum from sshkeyname");
$sqr_select->execute();
while(my $ref_select = $sqr_select->fetchrow_hashref())
{
    my $sshpublickey = $ref_select->{"sshpublickey"};
    my $sshprivatekey = $ref_select->{"sshprivatekey"};
    my $globalip = $ref_select->{"globalip"};
    my $md5sum = $ref_select->{"md5sum"};

    print "Processing $sshprivatekey ...\n";
    unless(-e $sshprivatekey) 
    {
        print "$sshprivatekey doesn't exists\n";
        next;
    }

    my $md5 = (split /\s+/, `md5sum $sshprivatekey 2>/dev/null`)[0];
    unless(defined $md5) 
    {
        $md5 = "";
    }

    if($md5 eq $md5sum) 
    {
        print "MD5 doesn't change for $sshprivatekey\n";
        next;
    }

    &get_remote_file($globalip, $sshpublickey, $sshprivatekey);
}
$sqr_select->finish();

sub get_remote_file 
{
    my($globalip, $sshpublickey, $sshprivatekey) = @_;
    &generate_known_host($globalip);
    my $cmdpub = "scp -o HostKeyAlgorithms=ssh-rsa -P 2288 root\@$globalip:$sshpublickey $sshpublickey";
    my $cmdpvt = "scp -o HostKeyAlgorithms=ssh-rsa -P 2288 root\@$globalip:$sshprivatekey $sshprivatekey";

    system($cmdpub);
    if(system($cmdpvt) != 0) 
    {
        print "scp pvt key file $sshprivatekey error\n";
    }
}

sub generate_known_host
{
    my($host) = @_;

    my $output = `ssh-keyscan -p 2288 -t rsa $host 2>/dev/null`;
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
        print "regenerate known_hosts for $host\n";
        open(my $fd_fw, ">$file");
        foreach my $line(@cache)
        {
            print $fd_fw $line,"\n";
        }
        close $fd_fw;
    }
}

sub get_local_mysql_config
{
    my $tmp_mysql_user = "root";
    my $tmp_mysql_passwd = "";
    unless(-e "/opt/freesvr/audit/etc/perl.cnf")
    {
        return ($tmp_mysql_user, $tmp_mysql_passwd);
    }

    open(my $fd_fr, "</opt/freesvr/audit/etc/perl.cnf");
    while(my $line = <$fd_fr>)
    {
        $line =~ s/\s//g;
        my($name, $val) = split /:/, $line;
        if($name eq "mysql_user")
        {
            $tmp_mysql_user = $val;
        }
        elsif($name eq "mysql_passwd")
        {
            $tmp_mysql_passwd = $val;
        }
    }

    my $cipher = Crypt::CBC->new( -key => 'freesvr', -cipher => 'Blowfish', -iv => 'freesvr1', -header => 'none');
    $tmp_mysql_passwd = decode_base64($tmp_mysql_passwd);
    $tmp_mysql_passwd  = $cipher->decrypt($tmp_mysql_passwd);
    close $fd_fr;
    return ($tmp_mysql_user, $tmp_mysql_passwd);
}
