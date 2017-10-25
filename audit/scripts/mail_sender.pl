#!/usr/bin/perl
use strict;
use warnings;

use DBI;
use DBD::mysql;
use Encode;
use Getopt::Long;
use Crypt::CBC;
use Net::SMTP;
use Authen::SASL;
use MIME::Entity;
use MIME::Base64;
use File::Basename;

our $ids = "";
GetOptions(
    "i=s"   =>  \$ids,
);

our($mysql_user,$mysql_passwd) = &get_local_mysql_config();
our $dbh=DBI->connect("DBI:mysql:database=audit_sec;host=localhost;mysql_connect_timeout=5",$mysql_user,$mysql_passwd,{RaiseError=>1});
our $utf8 = $dbh->prepare("set names utf8");
$utf8->execute();
$utf8->finish();

our $mail = $dbh->prepare("select mailserver,sslmail,mailport,account,password from alarm");
$mail->execute();
our $ref_mail = $mail->fetchrow_hashref();
our $mailserver = $ref_mail->{"mailserver"};
our $ssl = $ref_mail->{"sslmail"} == 0 ? 0 : 1;
our $mailport = $ref_mail->{"mailport"};
our $mailfrom = $ref_mail->{"account"};
our $mailpwd = $ref_mail->{"password"};
$mail->finish();

for my $id(split /,/,$ids)
{
    my $sqr_select = $dbh->prepare("select mailto,subject,msg,file_path from mail_sender where id=$id");
    $sqr_select->execute();
    my $ref_select = $sqr_select->fetchrow_hashref();
    my $mailto = $ref_select->{"mailto"};
    my $subject = $ref_select->{"subject"};
    my $msg = $ref_select->{"msg"};
    my $file_path = $ref_select->{"file_path"};
    $sqr_select->finish();

    if(!(defined $file_path && -e $file_path)) {
        $file_path = undef;
    }

    my $status = 1;
    my $err_str = &send_mail($mailto,$subject,$msg,$file_path,$mailserver,$mailfrom,$mailpwd,$ssl,$mailport);
    if(length($err_str) == 0)
    {
        $status = 0;
    }

    my $sqr_update = $dbh->prepare("update mail_sender set status=$status, err_string='$err_str' where id=$id");
    $sqr_update->execute();
    $sqr_update->finish();
}

sub send_mail
{
    my($mailto,$subject,$msg,$file_path,$mailserver,$mailfrom,$mailpwd,$ssl,$mailport) = @_;
    if($ssl && ! defined $mailport) 
    {
        return "mail port is needed";
    }
    elsif(!$ssl && ! defined $mailport)
    {
        $mailport = 25;
    }
#    $mailport = 465;
#    print "port $mailport\n";

    my $smtp = Net::SMTP->new(
        $mailserver,
        Port    => $mailport,
        Debug   => 1,
        SSL     => $ssl,
        );

    unless(defined $smtp) 
    {
        return "Config error, cannot create smtp object";
    }

    my $sasl = Authen::SASL->new(
        mechanism => 'LOGIN',
        callback => {
        pass => $mailpwd,
        user => $mailfrom,
        }
    );

    unless($smtp->auth($sasl))
    {
        return $smtp->message();
    }
    $smtp->mail($mailfrom);

    $subject = encode("gb2312", decode("utf8", $subject));
    $subject = encode_base64($subject,'');
    $msg = encode("gb2312", decode("utf8", $msg));

    my $data = MIME::Entity->build(
        Type    =>'multipart/mixed',
        From    => $mailfrom,
        To      => $mailto,
        Subject => "=?gb2312?B?$subject?=",
    );

    $data->attach(
        Type => "text/plain",
        Charset => "gb2312",
        Data => $msg,
    );

    if (defined $file_path)
    {
        $data->attach(
            Type        => "application/octet-stream",
            Path        => $file_path,
            Filename    => basename $file_path,
        );
    }

    if($smtp->to(split /,/, $mailto))
    {
        $smtp->data();
        $smtp->datasend($data->as_string());
        $smtp->dataend();
        $smtp->quit;
        return "";
    }
    else 
    {
        $smtp->quit;
        return "Error: ".$smtp->message();
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
