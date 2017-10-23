<?php
error_reporting(1);
define('CAN_RUN',1);
require_once("include/global.func.php");
require_once("include/db_connect.inc.php");
require_once("include/config.inc.php");
global $_CONFIG;
$lines = file('/etc/xrdp/global.cfg');
for($i=0; $i<count($lines); $i++){
	$_linetmp = explode('=', $lines[$i]);
	if(trim($_linetmp[0]=='global-server')){
		$globalserver = trim($_linetmp[1]);
	}
}
if($cutoff||$_GET['cutoff']){
	if($stype=='ssh'||$_GET['stype']=='ssh'){
		$pid = get_request('pid', 0, 1);
		$b   = explode(".", $pid);
		if(is_numeric($b[1])){
			$rs = mysql_query("SELECT * FROM sessionsrun WHERE sid=".$b[1]);
			$session = mysql_fetch_array($rs);
			$sship = $session['baoleiip'];
		}
		if(!$_GET['fromauditmc']){
			$eth0 = explode(":", $_SERVER["HTTP_HOST"]);
			if($sship!=$eth0[0]){
				$opts = array(
					'http' => array(
						'method'=>"GET",
						'header'=>"Content-Type: text/html; charset=utf-8"
					)
				);
				$context = stream_context_create($opts); 
				$url = "http://".$sship."/sshrun.php?cutoff=1&stype=ssh&fromauditmc=1&pid=".$pid;
				echo file_get_contents($url, false, $context);
				return;
			}
		}
		if(is_numeric($b[0])){
			$cmd = 'sudo ' . $_CONFIG['RUNNING_CUTOFF'] . ' ' . $b[0];
			exec($cmd, $out, $return);
		}

		if ($return == 0) {
			echo("<script language='javascript'>alert('执行成功');history.go(-1);</script>");
			return;
		} else {
			echo("<script language='javascript'>alert('执行失败');history.go(-1);</script>");
			return;
		}
	}else{
		$sid = get_request('sid');//var_dump($sid);
		$rs = mysql_query("SELECT * FROM rdpsessions WHERE sid=".$sid);
		$session = mysql_fetch_array($rs);
		if($session['proxy_addr']!='127.0.0.1'&&$session['proxy_addr']!=$globalserver){
			echo("<script language='javascript'>alert('请到堡垒机'".$session['proxy_addr']."上断开);history.go(-1);</script>");
			return;
		}
		/*
		if(!$_GET['fromauditmc']){
			if($session['proxy_addr']!='127.0.0.1'){
				$opts = array(
					'http' => array(
						'method'=>"GET",
						'header'=>"Content-Type: text/html; charset=utf-8"
					)
				);
				$context = stream_context_create($opts);
				echo $url = "http://".$session['proxy_addr']."/sshrun.php?cutoff=1&stype=rdp&fromauditmc=1&sid=".$sid;
				echo file_get_contents($url, false, $context);
				return;
			}
		}
		*/
		//$cmd='sudo '.$_CONFIG['RDP_CUTOFF'].' localhost S'.$session['threadid'];
		$cmd = "sudo /bin/kill ".$session['threadid'];
		exec($cmd, $out, $return);
		$filesize = filesize($session['replayfile']);
		mysql_query("UPDATE rdpsessions SET rdp_runnig=0,filesize=".($filesize?$filesize:0).", end=NOW() WHERE sid=$sid");
		echo("<script language='javascript'>alert('执行成功');history.go(-1);</script>");
		return;
	}
}
if($sshrun||$_GET['sshrun']){
	exec(" ps -ef | grep ssh-audit", $output);
	$s = array();
	for($i=0; $i<count($output); $i++){
		$_s = preg_split("/[\s]+/", $output[$i]);
		if($_s[2]==1&&substr($_s[7],0,4)=='/opt'){
			$mainid= $_s[1];
		}else{
			$s[]=$_s;
		}
		
	}
	for($i=0; $i<count($s); $i++){
		if($s[$i][2]==$mainid){
			$sess[]=$s[$i][1];
		}
	}
	if($sess){
		$sids = mysql_query("SELECT MAX(sid) sid FROM sessions WHERE pid IN(".implode(',', $sess).") and type='ssh' GROUP BY pid");
		$sess=null;
		while($row=mysql_fetch_array($sids)){
			if($row['sid'])
			$sess[] = $row['sid'];
		}
	}
	if($_GET['fromauditmc']){
		if($sess){
			$rs = mysql_query("SELECT s.*,m.realname FROM sessions s LEFT JOIN member m ON s.luser=m.username WHERE sid IN(".implode(',', $sess).") and type='ssh'");
			while($row[]=mysql_fetch_array($rs, MYSQL_NUM));
			$a = serialize($row);
			echo $a;
		}
		//var_dump(unserialize($a));
		return;
	}
	mysql_query("delete from sessionsrun where type='ssh'");
	$eth0 = explode(":", $_SERVER["HTTP_HOST"]);
	if($sess)
	mysql_query("INSERT INTO sessionsrun SELECT s.*,m.realname,'".$eth0[0]."' FROM sessions s LEFT JOIN member m ON s.luser=m.username where sid IN(".implode(',', $sess).") and type='ssh'") or var_dump(mysql_error());
	$slaveip = mysql_query("show slave status");
	$slaveip = mysql_fetch_array($slaveip);//var_dump($slaveip);
	$slaveip = $slaveip['Master_Host'];
	//$ip='127.0.0.1';
	if($slaveip){
		$url = "http://".$slaveip."/sshrun.php?fromauditmc=1&sshrun=1";
		echo "\n";
		$opts = array(
			'http' => array(
				'method'=>"GET",
				'header'=>"Content-Type: text/html; charset=utf-8"
			)
		);
		$context = stream_context_create($opts);
		$content = file_get_contents($url, false, $context);
		$row = unserialize($content);
		if($row){
			$sql = "INSERT INTO sessionsrun VALUES ";
			for($i=0; $i<count($row); $i++){
				if(!$row[$i]) continue;//var_dump($row[$i]);
				$sql .= "(";
				for($j=0; $j<count($row[$i]); $j++){
					$sql .= "'".$row[$i][$j]."',";
				}
				$sql .= "'".$slaveip."'";
				$sql .= "),";
			}
			$sql = substr($sql, 0, strlen($sql)-1);
			echo $sql ;
			if(count($row)>0) mysql_query($sql) or var_dump(mysql_error());
		}
	}
}elseif($telnetrun||$_GET['telnetrun']){
	exec(" ps -ef | grep telnet", $output);
	$s = array();
	for($i=0; $i<count($output); $i++){
		$_s = preg_split("/[\s]+/", $output[$i]);
		$sess[]=$_s[1];
	}
	if($sess){
		$sids = mysql_query("SELECT MAX(sid) sid FROM sessions WHERE pid IN(".implode(',', $sess).") and type='telnet' GROUP BY pid");
		$sess=null;
		while($row=mysql_fetch_array($sids)){
			if($row['sid'])
			$sess[] = $row['sid'];
		}
	}
	if($_GET['fromauditmc']){
		if($sess){
			$rs = mysql_query("SELECT s.*,m.realname FROM sessions s LEFT JOIN member m ON s.luser=m.username WHERE sid IN(".implode(',', $sess).") and type='telnet'");
			while($row[]=mysql_fetch_array($rs, MYSQL_NUM));
			$a = serialize($row);
			echo $a;
		}
		//var_dump(unserialize($a));
		return;
	}
	mysql_query("delete from sessionsrun where type='telnet'");
	$eth0 = explode(":", $_SERVER["HTTP_HOST"]);
	if($sess)
	mysql_query("INSERT INTO sessionsrun SELECT s.*,m.realname,'".$eth0[0]."' FROM sessions s LEFT JOIN member m ON s.luser=m.username where sid IN(".implode(',', $sess).") and type='telnet'") or var_dump(mysql_error());
	$slaveip = mysql_query("show slave status");
	$slaveip = mysql_fetch_array($slaveip);//var_dump($slaveip);
	$slaveip = $slaveip['Master_Host'];
	//$ip='127.0.0.1';
	if($slaveip){
		$opts = array(
			'http' => array(
				'method'=>"GET",
				'header'=>"Content-Type: text/html; charset=utf-8"
			)
		);
		$context = stream_context_create($opts);
		$url = "http://".$slaveip."/sshrun.php?fromauditmc=1&telnetrun=1";
		echo "\n";
		$content = file_get_contents($url, false, $context);
		$row = unserialize($content);//var_dump($row);
		if($row){
			$sql = "INSERT INTO sessionsrun VALUES";
			for($i=0; $i<count($row); $i++){
				if(!$row[$i]) continue;//var_dump($row[$i]);
				$sql .= "(";
				for($j=0; $j<count($row[$i]); $j++){
					$sql .= "'".$row[$i][$j]."',";
				}
				$sql .= "'".$slaveip."'";
				$sql .= "),";
			}
			$sql = substr($sql, 0, strlen($sql)-1);
			echo $sql ;
			if(count($row)>0) mysql_query($sql) or var_dump(mysql_error());
		}
	}

}
?>