#!/usr/bin/perl
use warnings;
use strict;
use File::Basename;
use File::Copy;
use Expect; 

my($cert_name, $password) = @ARGV;
my $user_name;

unless(defined $cert_name && defined $password)
{
    print "usage 'ca.pl cert_name password'\n";
    exit 1;
}

unless(defined $cert_name && $cert_name =~ /@/)
{
    print "参数1错误, 需要 @ 符号\n";
    exit 1;
}

$user_name = (split /@/,$cert_name)[0];

my $dir = "/opt/freesvr/web/CA";

chdir $dir;

my $line = `grep Issuer /opt/freesvr/web/CA/user.crt`;
my ($radNum) = $line=~/Baolei(\d+)/;
if(!defined($radNum))
{
	$radNum='';
}


if(system("openssl req -new -sha256 -days 36500 -key user.key -out $user_name.csr -subj \"/C=CN/ST=Baolei$radNum/L=Baolei$radNum/O=Baolei$radNum/OU=Baolei$radNum/CN=$cert_name\" 1>/dev/null 2>&1") != 0)
{
	print "err in 'openssl req', return value not 0\n";
	exit 1;
}

if(-e "demoCA")
{
    `rm -rf demoCA/`;
}

mkdir "demoCA";
chdir "./demoCA";
mkdir "newcerts";

open(my $fd_fw,">index.txt");
close $fd_fw;

open($fd_fw,">serial");
print $fd_fw int(rand(1000000));
#print $fd_fw "01";
close $fd_fw;

chdir "..";

if(system("openssl ca -md sha256  -startdate 130825000000Z -days 36500 -in $user_name.csr -out $user_name.crt -cert ca.crt -keyfile ca.key -batch 1>/dev/null 2>&1") != 0)
{
    print "err in 'openssl ca', return value not 0\n";
    exit 1;
}

if(system("openssl pkcs12 -export -clcerts -in $user_name.crt -inkey user.key -out $user_name.pfx -passout pass:$password") != 0)
{
    print "err in 'openssl pkcs12', return value not 0\n";
    exit 1;
}

if(-e "./$user_name.pfx")
{
    print "证书生成成功\n";
    exit 0;
}
else
{
    print "证书生成失败, $user_name.pfx 不存在\n";
    exit 1;
}
