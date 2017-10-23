#!/usr/bin/perl
use warnings;
use strict;
use DBI;
use DBD::mysql;
use File::HomeDir;
use Expect;
use Fcntl;
use Crypt::CBC;
use MIME::Base64;

our $fd_lock;
our $lock_file = "/tmp/.usergroup_lock";
sysopen($fd_lock, $lock_file, O_RDWR|O_CREAT|O_EXCL) or die "another instance running";

$SIG{ALRM}=sub{ die "alarm timeout\n" };
alarm 600;

our $time_now_utc = time;
my($min,$hour,$mday,$mon,$year) = (localtime $time_now_utc)[1..5];
($min,$hour,$mday,$mon,$year) = (sprintf("%02d", $min),sprintf("%02d", $hour),sprintf("%02d", $mday),sprintf("%02d", $mon + 1),$year+1900);
our $time_now_str = "$year$mon$mday$hour$min"."00";
our $date_today = "$year-$mon-$mday";

our($mysql_user,$mysql_passwd) = &get_local_mysql_config();
our $dbh=DBI->connect("DBI:mysql:database=audit_sec;host=localhost;mysql_connect_timeout=5",$mysql_user,$mysql_passwd,{RaiseError=>1});
our $utf8 = $dbh->prepare("set names utf8");
$utf8->execute();
$utf8->finish();

our $device_id = $ARGV[0];
unless(defined $device_id)
{
    &log_process(undef, "need a device_id");
    exit 1;
}

my($device_ip,$username,$passwd,$port,$version,$superpasswd) = &get_ssh_info();
my($login_flag,$exp) = &ssh_login($device_ip,$version,$username,$passwd,$port);
if($login_flag != 1)
{
    exit 1;
}

if(defined $superpasswd)
{
    if(&su_process($exp,$superpasswd) != 0)
    {
        &log_process($device_ip, "su passwd failed");
        exit 1;
    }
    print "$device_ip su success\n";
}

our %last_user;
our %cur_user;

our %last_group;
our %cur_group;

our %last_user_group;
our %cur_user_group;

my $action = $ARGV[1];

unless(defined $action)
{
    &log_process($device_ip, "need a action, e.g. userlist, useradd ..");
    exit 1;
}

if($action eq "userlist")
{
    &load_user_group();
    &userlist($exp,$device_ip);
    &insert_diff();
}
elsif($action eq "useradd")
{
    my $user = $ARGV[2];
    my $passwd = $ARGV[3];
    &load_user_group();
    &userlist($exp,$device_ip);
    &insert_diff();

    &clear_status();

    my $mark = &get_user_mark($user);
    if($mark==1)
    {
        my $cmd = "useradd $user;echo \"get status: \$?\"";
        my($status,$ref_line) = &get_output($exp,$cmd,"status");
        if($status != 0)
        {
            &log_process($device_ip,"$device_ip add new user $user fail");
            exit 1;
        }
        print "add new user $user success\n";

        if(defined $passwd)
        {
            $cmd = "echo $passwd | passwd $user --stdin;echo \"get status: \$?\"";
            ($status,$ref_line) = &get_output($exp,$cmd,"status");
            if($status != 0)
            {
                &log_process($device_ip,"$device_ip set new user $user passwd fail");
                exit 1;
            }
        }
        print "set new user passwd for $user success\n";

        &load_user_group();
        &userlist($exp,$device_ip);
        &insert_diff();
    }
}
elsif($action eq "passwdchange")
{
    my $user = $ARGV[2];
    my $passwd = $ARGV[3];
    &load_user_group();
    &userlist($exp,$device_ip);
    &insert_diff();

    &clear_status();

    my $mark = &get_user_mark($user);
    if($mark==1)
    {
        &log_process($device_ip,"$device_ip $user doesn't exist");
        exit 1;
    }

    unless(defined $passwd)
    {
        $passwd = "";
    }

    my $cmd = "echo '$passwd' | passwd $user --stdin;echo \"get status: \$?\"";
    my($status,$ref_line) = &get_output($exp,$cmd,"status");
    if($status != 0)
    {
        &log_process($device_ip,"$device_ip set $user passwd fail");
        exit 1;
    }

    print "set user passwd for $user success\n";

    &load_user_group();
    &userlist($exp,$device_ip);
    &insert_diff();
}
elsif($action eq "userdel")
{
    my $user = $ARGV[2];
    &load_user_group();
	&userlist($exp,$device_ip);
    &insert_diff();

    &clear_status();

    my $mark = &get_user_mark($user);
    if($mark!=1)
    {
        my $cmd = "userdel -r $user;echo \"get status: \$?\"";
        my($status,$ref_line) = &get_output($exp,$cmd,"status");
        if($status != 0)
        {
            &log_process($device_ip,"$device_ip del user $user fail");
            exit 1;
        }
        print "del user $user success\n";

        &load_user_group();
        &userlist($exp,$device_ip);
        &insert_diff();
    }
}
elsif($action eq "userlock")
{
    my $user = $ARGV[2];
    &load_user_group();
	&userlist($exp,$device_ip);
    &insert_diff();

    &clear_status();

    my $mark = &get_user_mark($user);
    if($mark!=1 && $mark!=3)
    {
        my $cmd = "passwd -l $user;echo \"get status: \$?\"";
        my($status,$ref_line) = &get_output($exp,$cmd,"status");
        if($status != 0)
        {
            &log_process($device_ip,"$device_ip lock user $user fail");
            exit 1;
        }
        print "lock user $user success\n";

        &load_user_group();
        &userlist($exp,$device_ip);
        &insert_diff();
    }
}
elsif($action eq "userunlock")
{
    my $user = $ARGV[2];
    &load_user_group();
	&userlist($exp,$device_ip);
    &insert_diff();

    &clear_status();

    my $mark = &get_user_mark($user);
    if($mark==3)
    {
        my $cmd = "passwd -u $user;echo \"get status: \$?\"";
        my($status,$ref_line) = &get_output($exp,$cmd,"status");
        if($status != 0)
        {
            &log_process($device_ip,"$device_ip unlock user $user fail");
            exit 1;
        }
        print "unlock user $user success\n";

        &load_user_group();
        &userlist($exp,$device_ip);
        &insert_diff();
    }
}
elsif($action eq "groupadd")
{
    my $group = $ARGV[2];
    &load_user_group();
	&userlist($exp,$device_ip);
    &insert_diff();

    &clear_status();

    my $mark = &get_group_mark($group);
    if($mark==1)
    {
        my $cmd = "groupadd $group;echo \"get status: \$?\"";
        my($status,$ref_line) = &get_output($exp,$cmd,"status");
        if($status != 0)
        {
            &log_process($device_ip,"$device_ip add new group $group fail");
            exit 1;
        }
        print "add new group $group success\n";

        &load_user_group();
        &userlist($exp,$device_ip);
        &insert_diff();
    }
}
elsif($action eq "groupdel")
{
    my $group = $ARGV[2];
    &load_user_group();
	&userlist($exp,$device_ip);
    &insert_diff();

    &clear_status();

    my $mark = &get_group_mark($group);
    if($mark!=1)
    {
        my $sqr_select = $dbh->prepare("select r.account_userid uid from account_group as g left join account_usergroup as r on g.id=r.account_groupid where g.device_id=$device_id and g.groupname='$group' and g.mark=0");
        $sqr_select->execute();
        my $ref = $sqr_select->fetchrow_hashref();
        my $uid = $ref->{"uid"};
        $sqr_select->finish();

        if(defined $uid)
        {
            &log_process($device_ip,"$device_ip $group has at least 1 user");
            exit 1;
        }

        my $cmd = "groupdel $group;echo \"get status: \$?\"";
        my($status,$ref_line) = &get_output($exp,$cmd,"status");
        if($status != 0)
        {
            &log_process($device_ip,"$device_ip del group $group fail");
            exit 1;
        }
        print "del group $group success\n";

        &load_user_group();
        &userlist($exp,$device_ip);
        &insert_diff();
    }
}
elsif($action eq "addusergroup")
{
    &load_user_group();
	&userlist($exp,$device_ip);
    &insert_diff();
    &clear_status();

    &filter_relation();
    my($ref_new_relation,$ref_del_ids) = &get_new_relation();
    
    foreach my $user(keys %{$ref_new_relation})
    {
        my $groups = join(",", keys %{$ref_new_relation->{$user}});
        my $cmd = "usermod -a -G $groups $user;echo \"get status: \$?\"";
#        print $cmd,"\n";
        my($status,$ref_line) = &get_output($exp,$cmd,"status");
        if($status != 0)
        {
            &log_process($device_ip,"$device_ip user add to group for $user fail");
            exit 1;
        }
    }
    print "all user process success\n";

    foreach my $id(@{$ref_del_ids})
    {
        my $sqr_delete = $dbh->prepare("delete from account_usergroup where id=$id");
        $sqr_delete->execute();
        $sqr_delete->finish();
    }

    &load_user_group();
    &userlist($exp,$device_ip);
    &insert_diff();
}

$exp->close();
$dbh->disconnect();
close $fd_lock;
unlink $lock_file;

sub get_ssh_info
{
    my $sqr_select = $dbh->prepare("select device_ip,username,udf_decrypt(cur_password) passwd,port,device_type,login_method,su_password from devices where id=$device_id");
    $sqr_select->execute();
    my $ref = $sqr_select->fetchrow_hashref();
    my $device_ip = $ref->{"device_ip"};
    my $username = $ref->{"username"};
    my $passwd = $ref->{"passwd"};
    my $port = $ref->{"port"};
    my $device_type = $ref->{"device_type"};
    my $login_method = $ref->{"login_method"};
    my $su_password = $ref->{"su_password"};
    my $version = "";

    unless($device_type == 2)
    {
        &log_process($device_ip,"$device_ip not a linux server");
        exit 1;
    }

    if($login_method == 3)
    {
    }
    elsif($login_method == 25)
    {
        $version = "-1";
    }
    else
    {
        &log_process($device_ip,"$device_ip cannot login by ssh");
        exit 1;
    }

    $sqr_select->finish();

    my $superpasswd = undef;
    if($su_password == 1)
    {
        $sqr_select = $dbh->prepare("select udf_decrypt(superpassword) superpasswd from servers where device_ip='$device_ip'");
        $sqr_select->execute();
        $ref = $sqr_select->fetchrow_hashref();
        $superpasswd = $ref->{"superpasswd"};
        $sqr_select->finish();
    }

    return ($device_ip,$username,$passwd,$port,$version,$superpasswd);
}

sub ssh_login
{
    my($device_ip,$version,$username,$passwd,$port) = @_;

    my $exp;
    my $count = 0;
    my $flag = 1;

    while($count < 10 && $flag == 1)
    {
        $exp = Expect->new;
        $exp->log_stdout(0);
        $exp->debug(0);

        ++$count;

        print "ssh $version -o GSSAPIAuthentication=no -l $username $device_ip -p $port\n";
        $exp->spawn("ssh $version -o GSSAPIAuthentication=no -l $username $device_ip -p $port");

        my @results = $exp->expect(20,
            [
            qr/~\]/i,
            sub {
            $flag = 0;
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
            qr/continue connecting.*yes\/no.*/i,
            sub {
            my $self = shift ;
            $self->send_slow(0.1,"yes\n");
            exp_continue;
            }
            ],

            [
			qr/Host key verification failed/i,
			sub
			{
			$flag = &rsa_err_process($username,$device_ip);
			}
			],
		);

		if($flag == 0)
		{
			&log_process($device_ip,"$device_ip ssh login success");
			return (1,$exp);
		}
		elsif($flag != 1)
		{
			&log_process($device_ip,"$device_ip ssh login fail");
			return (0,undef);
		}
	}

	&log_process($device_ip,"$device_ip ssh login fail");
	return (0,undef);
}

sub load_user_group
{
    my $sqr_select = $dbh->prepare("select username,mark from account_user where device_id=$device_id");
    $sqr_select->execute();
    while(my $ref = $sqr_select->fetchrow_hashref())
    {
        my $user = $ref->{"username"};
        my $mark = $ref->{"mark"};

        unless(exists $last_user{$user})
        {
            $last_user{$user} = $mark;
        }
    }
    $sqr_select->finish();

    $sqr_select = $dbh->prepare("select groupname,mark from account_group where device_id=$device_id");
    $sqr_select->execute();
    while(my $ref = $sqr_select->fetchrow_hashref())
    {
        my $group = $ref->{"groupname"};
        my $mark = $ref->{"mark"};

        unless(exists $last_group{$group})
        {
            $last_group{$group} = $mark;
        }
    }
    $sqr_select->finish();

    $sqr_select = $dbh->prepare("select u.username,g.groupname,r.id from account_usergroup as r left join account_user as u on r.account_userid=u.id left join account_group as g on r.account_groupid=g.id where r.action=1 and u.device_id=$device_id and g.device_id=$device_id");
    $sqr_select->execute();
    while(my $ref = $sqr_select->fetchrow_hashref())
    {
        my $id = $ref->{"id"};
        my $user = $ref->{"username"};
        my $group = $ref->{"groupname"};

        unless(defined $user && defined $group)
        {
            my $sqr_delete = $dbh->prepare("delete from account_usergroup where id=$id");
            $sqr_delete->execute();
            $sqr_delete->finish();
        }
        else
        {
            unless(exists $last_user_group{$user})
            {
                my %tmp;
                $last_user_group{$user} = \%tmp;
            }
            $last_user_group{$user}->{$group}=1;
        }
    }
    $sqr_select->finish();
}

sub userlist
{
	my($exp,$device_ip) = @_;

    my %cur_id_users;

	my $cmd = "cat /etc/passwd;echo \"get passwd: \$?\"";
    my($status,$ref_line) = &get_output($exp,$cmd,"passwd");
    if($status != 0)
    {
        &log_process($device_ip,"$device_ip get user info fail");
        exit 1;
    }

    foreach my $line(@{$ref_line})
    {
        my($user,$gid) = (split /:/,$line)[0,3];
        unless(exists $cur_id_users{$gid})
        {
            my @tmp;
            $cur_id_users{$gid} = \@tmp;
        }

        push @{$cur_id_users{$gid}}, $user;

        unless(exists $cur_user{$user})
        {
            $cur_user{$user} = 0;
        }

        unless(exists $cur_user_group{$user})
        {
            my %tmp;
            $cur_user_group{$user} = \%tmp;
        }
    }

    $cmd = "cat /etc/shadow;echo \"get shadow: \$?\"";
    ($status,$ref_line) = &get_output($exp,$cmd,"shadow");
    if($status != 0)
    {
        &log_process($device_ip,"$device_ip get user shadow fail");
        exit 1;
    }

    foreach my $line(@{$ref_line})
    {
        my($user,$passwd) = (split /:/,$line)[0,1];
        if(exists $cur_user{$user} && $passwd =~ /^!/)
        {
            $cur_user{$user} = 3;
        }
    }

    $cmd = "cat /etc/group;echo \"get groups: \$?\"";
    ($status,$ref_line) = &get_output($exp,$cmd,"groups");
    if($status != 0)
    {
        &log_process($device_ip,"$device_ip get group info fail");
        exit 1;
    }

    foreach my $line(@{$ref_line})
    {
        my($group,$gid,$users) = (split /:/,$line)[0,2,3];
        $users =~ s/\s*$//;
        $users =~ s/^\s*//;

        unless(exists $cur_group{$group})
        {
            $cur_group{$group}=0;
        }

        my @allusers = split /,/, $users;
        if(exists $cur_id_users{$gid})
        {
            foreach my $user(@{$cur_id_users{$gid}})
            {
                push @allusers, $user;
            }
        }

        foreach my $user(@allusers)
        {
            if(exists $cur_user_group{$user})
            {
                $cur_user_group{$user}->{$group}=1;
            }
        }
    }
}

sub insert_diff
{
    foreach my $user(keys %cur_user)
    {
        my $cur_mark = $cur_user{$user};
        if(exists $last_user{$user})
        {
            my $last_mark = $last_user{$user};
            if($cur_mark != $last_mark)
            {
                if($cur_mark==0 && $last_mark==3)
                {
                    &insert_into_user($user,4,"update");
                }
                elsif(($cur_mark==0 && $last_mark==1) || $cur_mark==3)
                {
                    &insert_into_user($user,$cur_mark,"update");
                }
            }
            delete $last_user{$user};
        }
        else
        {
            &insert_into_user($user,$cur_mark,"insert");
        }
    }

    foreach my $user(keys %last_user)
    {
        if($last_user{$user} != 1)
        {
            &insert_into_user($user,1,"update");
        }
    }

    foreach my $group(keys %cur_group)
    {
        my $cur_mark = $cur_group{$group};
        if(exists $last_group{$group})
        {
            my $last_mark = $last_group{$group};
            if($cur_mark != $last_mark)
            {
                &insert_into_group($group,$cur_mark,"update");
            }
            delete $last_group{$group};
        }
        else
        {
            &insert_into_group($group,$cur_mark,"insert");
        }
    }

    foreach my $group(keys %last_group)
    {
        if($last_group{$group} != 1)
        {
            &insert_into_group($group,1,"update");
        }
    }

    foreach my $user(keys %cur_user_group)
    {
        if(exists $last_user_group{$user})
        {
            foreach my $group(keys %{$cur_user_group{$user}})
            {
                if(exists $last_user_group{$user}->{$group})
                {
                    delete $last_user_group{$user}->{$group}
                }
                else
                {
                    &update_usergroup($user,$group,"insert");
                }
            }

            foreach my $group(keys %{$last_user_group{$user}})
            {
                &update_usergroup($user,$group,"delete");
            }
            delete $last_user_group{$user};
        }
        else
        {
            foreach my $group(keys %{$cur_user_group{$user}})
            {
                &update_usergroup($user,$group,"insert");
            }
        }
    }

    foreach my $user(keys %last_user_group)
    {
        foreach my $group(keys %{$last_user_group{$user}})
        {
            &update_usergroup($user,$group,"delete");
        }
    }
}

sub filter_relation
{
    my %tmp_user_group;

    my $sqr_select = $dbh->prepare("select u.username,g.groupname,r.id from account_usergroup as r left join account_user as u on r.account_userid=u.id left join account_group as g on r.account_groupid=g.id where r.action=1 and u.device_id=$device_id and g.device_id=$device_id");
    $sqr_select->execute();
    while(my $ref = $sqr_select->fetchrow_hashref())
    {
        my $id = $ref->{"id"};
        my $user = $ref->{"username"};
        my $group = $ref->{"groupname"};

        unless(defined $user && defined $group)
        {
            my $sqr_delete = $dbh->prepare("delete from account_usergroup where id=$id");
            $sqr_delete->execute();
            $sqr_delete->finish();
        }
        else
        {
            unless(exists $tmp_user_group{$user})
            {
                my %tmp;
                $tmp_user_group{$user} = \%tmp;
            }
            $tmp_user_group{$user}->{$group}=1;
        }
    }
    $sqr_select->finish();

    $sqr_select = $dbh->prepare("select u.username,g.groupname,r.id,r.account_userid,r.account_groupid,u.mark umark,g.mark gmark from account_usergroup as r left join account_user as u on r.account_userid=u.id left join account_group as g on r.account_groupid=g.id where r.action=0 and u.device_id=$device_id and g.device_id=$device_id");
    $sqr_select->execute();
    while(my $ref = $sqr_select->fetchrow_hashref())
    {
        my $id = $ref->{"id"};
        my $uid = $ref->{"account_userid"};
        my $gid = $ref->{"account_groupid"};
        my $user = $ref->{"username"};
        my $group = $ref->{"groupname"};
        my $umark = $ref->{"umark"};
        my $gmark = $ref->{"gmark"};

        unless(defined $user && defined $group)
        {
            my $sqr_delete = $dbh->prepare("delete from account_usergroup where id=$id");
            $sqr_delete->execute();
            $sqr_delete->finish();
            &log_process($device_ip,"invaild userid $uid or groupid $gid");
        }
        elsif($umark==1 || $gmark==1)
        {
            my $sqr_delete = $dbh->prepare("delete from account_usergroup where id=$id");
            $sqr_delete->execute();
            $sqr_delete->finish();
            &log_process($device_ip,"deleted user $user or group $group");
        }
        elsif(exists $tmp_user_group{$user} && exists $tmp_user_group{$user}->{$group})
        {
            my $sqr_delete = $dbh->prepare("delete from account_usergroup where id=$id");
            $sqr_delete->execute();
            $sqr_delete->finish();
        }
    }
    $sqr_select->finish();
}

sub get_new_relation
{
    my %tmp_user_group;
    my @del_ids;

    my $sqr_select = $dbh->prepare("select u.username,g.groupname,r.id from account_usergroup as r left join account_user as u on r.account_userid=u.id left join account_group as g on r.account_groupid=g.id where r.action=0 and u.device_id=$device_id and g.device_id=$device_id");
    $sqr_select->execute();
    while(my $ref = $sqr_select->fetchrow_hashref())
    {
        my $id = $ref->{"id"};
        my $user = $ref->{"username"};
        my $group = $ref->{"groupname"};

        unless(defined $user && defined $group)
        {
            my $sqr_delete = $dbh->prepare("delete from account_usergroup where id=$id");
            $sqr_delete->execute();
            $sqr_delete->finish();
        }
        else
        {
            unless(exists $tmp_user_group{$user})
            {
                my %tmp;
                $tmp_user_group{$user} = \%tmp;
            }
            $tmp_user_group{$user}->{$group}=1;
            push @del_ids,$id;
        }
    }
    $sqr_select->finish();
    return (\%tmp_user_group,\@del_ids);
}

sub get_user_mark
{
    my($user) = @_;
    my $sqr_select = $dbh->prepare("select mark from account_user where device_id=$device_id and username='$user'");
    $sqr_select->execute();
    my $ref = $sqr_select->fetchrow_hashref();
    my $mark = $ref->{"mark"};
    $sqr_select->finish();

    if(defined $mark)
    {
        return $mark;
    }
    else
    {
        return 1;
    }
}

sub get_group_mark
{
    my($group) = @_;
    my $sqr_select = $dbh->prepare("select mark from account_group where device_id=$device_id and groupname='$group'");
    $sqr_select->execute();
    my $ref = $sqr_select->fetchrow_hashref();
    my $mark = $ref->{"mark"};
    $sqr_select->finish();

    if(defined $mark)
    {
        return $mark;
    }
    else
    {
        return 1;
    }
}

sub insert_into_user
{
    my($user,$mark,$action) = @_;

    if($action eq "update")
    {
        my $sqr_update = $dbh->prepare("update account_user set mark=$mark where device_id=$device_id and username='$user'");
        $sqr_update->execute();
        $sqr_update->finish();
    }
    elsif($action eq "insert")
    {
        my $sqr_insert = $dbh->prepare("insert into account_user(device_id,username,createtime,mark) values($device_id,'$user',now(),$mark)");
        $sqr_insert->execute();
        $sqr_insert->finish();
    }

    my $sqr_select = $dbh->prepare("select id from account_user where device_id=$device_id and username='$user'");
    $sqr_select->execute();
    my $ref = $sqr_select->fetchrow_hashref();
    my $uid = $ref->{"id"};
    $sqr_select->finish();

    my $sqr_insert = $dbh->prepare("insert into account_userlog(account_userid,action) values($uid,$mark)");
    $sqr_insert->execute();
    $sqr_insert->finish();
}

sub insert_into_group
{
    my($group,$mark,$action) = @_;

    if($action eq "update")
    {
        my $sqr_update = $dbh->prepare("update account_group set mark=$mark where device_id=$device_id and groupname='$group'");
        $sqr_update->execute();
        $sqr_update->finish();
    }
    elsif($action eq "insert")
    {
        my $sqr_insert = $dbh->prepare("insert into account_group(device_id,groupname,createtime,mark) values($device_id,'$group',now(),$mark)");
        $sqr_insert->execute();
        $sqr_insert->finish();
    }

    my $sqr_select = $dbh->prepare("select id from account_group where device_id=$device_id and groupname='$group'");
    $sqr_select->execute();
    my $ref = $sqr_select->fetchrow_hashref();
    my $gid = $ref->{"id"};
    $sqr_select->finish();

    my $sqr_insert = $dbh->prepare("insert into account_grouplog(account_groupid,action) values($gid,$mark)");
    $sqr_insert->execute();
    $sqr_insert->finish();
}

sub update_usergroup
{
    my($user,$group,$action) = @_;

    my $sqr_select = $dbh->prepare("select id from account_user where device_id=$device_id and username='$user'");
    $sqr_select->execute();
    my $ref = $sqr_select->fetchrow_hashref();
    my $uid = $ref->{"id"};
    $sqr_select->finish();

    $sqr_select = $dbh->prepare("select id from account_group where device_id=$device_id and groupname='$group'");
    $sqr_select->execute();
    $ref = $sqr_select->fetchrow_hashref();
    my $gid = $ref->{"id"};
    $sqr_select->finish();

    if(defined $uid && defined $gid)
    {
        if($action eq "insert")
        {
            my $sqr_insert = $dbh->prepare("insert into account_usergroup(account_userid,account_groupid,action) values($uid,$gid,1)");
            $sqr_insert->execute();
            $sqr_insert->finish();
        }
        elsif($action eq "delete")
        {
            my $sqr_delete = $dbh->prepare("delete from account_usergroup where account_userid=$uid and account_groupid=$gid and action=1");
            $sqr_delete->execute();
            $sqr_delete->finish();
        }
    }
}

sub su_process
{
    my($exp,$superpasswd) = @_;
	my $cmd = "su";
    $exp->clear_accum();
    $exp->send("$cmd\n");

    my $flag=0;
    while(1)
    {
        $exp->expect(1, undef);
        my $str = $exp->before();
        if($flag==0 && $str =~ /.*/)
        {
            $exp->send("$superpasswd\n");
            $flag = 1;
        }
        elsif($flag==1 && $str=~/#/)
        {
            return 0;
        }
        $exp->clear_accum();
    }
}

sub clear_status
{
    %last_user=();
    %cur_user=();

    %last_group=();
    %cur_group=();

    %last_user_group=();
    %cur_user_group=();
}

sub get_output
{
    my($exp,$cmd,$exit_word) = @_;

    $exp->clear_accum();
    $exp->send("$cmd\n");

    my @lines;
    my $flag = 0;
    my $status = 0;
    my $lastline = "";
    while(1)
    {
        my @tmp;
        $exp->expect(1, undef);

        my $str = $exp->before();
        $lastline = &result_process($str,\@tmp,$lastline);

        foreach my $line(@tmp)
        {
#			print $line,"\n";
            if($line =~ /echo \"/)
            {
                next;
            }
            elsif($line =~ /get $exit_word: (\d+)/i)
            {
                $flag = 1;
                $status = $1;
                last;
            }
            else
            {
                push @lines, $line;
            }
        }
        $exp->clear_accum();

        if($flag == 1)
        {
            last;
        }
    }

    return ($status, \@lines);
}

sub result_process
{
    my($str,$ref,$lastline) = @_;

    @{$ref} = split /\n/,$str;

    if(scalar @{$ref} == 0)
    {
        return $lastline;
    }

    if($lastline ne "")
    {
        $ref->[0] = $lastline.$ref->[0];
        $lastline = "";
    }

    unless($str =~ /\n$/)
    {
        $lastline = $ref->[-1];
        pop @{$ref};
    }

    return $lastline;
}

sub log_process
{
    my($device_ip,$msg) = @_;
    print "$msg\n";
}

sub rsa_err_process
{
    my($user,$ip) = @_;
    my $home = File::HomeDir->users_home($user);
    unless(defined $home)
    {
        print "cant find home dir for user $user\n";
        return 2;
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

	return 1;
}

sub get_local_mysql_config
{
    my $tmp_mysql_user = "root";
    my $tmp_mysql_passwd = "";
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
