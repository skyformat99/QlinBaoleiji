<?php
if(!defined('CAN_RUN')) {
	exit('Access Denied');
}

class c_admin_interface extends c_base {
	function process_postdata(){
		$r = json_decode(urldecode($_POST['data']), true);
		if(!is_array($r)){
			$_result['result']=0;
			$_result['msg']='json格式解析错误';
			$_result['data']=array();
			echo json_encode($_result);
			return false;
		}
		return $r;
	}

	function groupAdd(){
		global $_CONFIG;
		if(($data=$this->process_postdata())===false){
			return ;
		}
		$_POST = $data;
		$_GET['id']=$data['id'];
		require_once(ROOT ."./controller/c_admin_pro.class.php");	
		$newpro = new c_admin_pro();
		$sgroupset = new sgroup_set();
		$newpro->init($this->smarty, $this->config);
		ob_start();
		$id = $newpro->dev_group_save(true);
		$result = ob_get_clean();
		$r = preg_match("/<script language='javascript'>alert\(['\"](.*?)['\"]\);/", $result, $matches);
		if(strpos($matches[1], '成功')!==false){
			$_result['result']=1;
			$_result['msg']='操作成功';
			$_result['data']=$sgroupset->select_all('id="'.$id.'"');
		}else{
			$_result['result']=0;
			$_result['msg']=$matches[1];
			$_result['data']=array();
		}
		echo json_encode($_result);
	}

	function groupDel(){
		global $_CONFIG;
		if(($data=$this->process_postdata())===false){
			return ;
		}
		$_POST = $data;
		
		require_once(ROOT ."./controller/c_admin_pro.class.php");	
		$newpro = new c_admin_pro();
		$sgroupset = new sgroup_set();
		$newpro->init($this->smarty, $this->config);
		ob_start();
		for($i=0; $i<count($data['id']); $i++){
			$_GET['id']=$data['id'][$i];
			$newpro->dev_group_del();
		}
		
		$result = ob_get_clean();
		$r = preg_match("/<script language='javascript'>alert\(['\"](.*?)['\"]\);/", $result, $matches);
		if(strpos($matches[1], '成功')!==false){
			$_result['result']=1;
			$_result['msg']='操作成功';
		}else{
			$_result['result']=0;
			$_result['msg']=$matches[1];
		}
		echo json_encode($_result);
	}

	function groupList(){
		global $_CONFIG;
		if(($data=$this->process_postdata())===false){
			return ;
		}
		$_GET = $data;
		$_GET['derive']=0;
		$this->config['site']['items_per_page']=$_GET['items_per_page'];
		require_once(ROOT ."./controller/c_admin_pro.class.php");	
		$newpro = new c_admin_pro();
		$sgroupset = new sgroup_set();
		$newpro->init($this->smarty, $this->config);
		ob_start();
		$datas=$newpro->dev_group(true);
		$result = ob_get_clean();
		$r = preg_match("/<script language='javascript'>alert\(['\"](.*?)['\"]\);/", $result, $matches);
		if($r==0){
			$_result['result']=1;
			$_result['msg']='操作成功';
			$_result['data']=$datas;
		}else{
			$_result['result']=0;
			$_result['msg']=$matches[1];
			$_result['data']=array();
		}
		echo json_encode($_result);
	}

	function radiususerAdd(){
		global $_CONFIG;
		if(($data=$this->process_postdata())===false){
			return ;
		}
		$_SESSION['RADIUSUSERLIST']=true;
		$_POST = $data;
		$_POST['password1']=$data['password'];
		$_POST['password2']=$data['password'];
		$_GET['uid']=$data['uid'];
		require_once(ROOT ."./controller/c_admin_member.class.php");	
		$newmember = new c_admin_member();
		$memberset = new member_set();
		$newmember->init($this->smarty, $this->config);
		ob_start();
		$id=$newmember->save(true);
		$result = ob_get_clean();
		$r = preg_match("/<script language='javascript'>alert\(['\"](.*?)['\"]\);/", $result, $matches);
		if(strpos($matches[1], '成功')!==false){
			$_result['result']=1;
			$_result['msg']='操作成功';
			$_result['data']=$memberset->base_select('select *,NULL password from member where uid="'.$id.'"');
		}else{
			$_result['result']=0;
			$_result['msg']=$matches[1];
			$_result['data']=array();
		}
		echo json_encode($_result);
	}

	function radiususerDel(){
		global $_CONFIG;		
		if(($data=$this->process_postdata())===false){
			return ;
		}
		$_SESSION['RADIUSUSERLIST']=true;
		$_POST['chk_member']=$data['uid'];
		require_once(ROOT ."./controller/c_admin_member.class.php");	
		$newmember = new c_admin_member();
		$memberset = new member_set();
		$newmember->init($this->smarty, $this->config);
		ob_start();
		$newmember->delete_all();
		$result = ob_get_clean();
		$r = preg_match("/<script language='javascript'>alert\(['\"](.*?)['\"]\);/", $result, $matches);
		if(strpos($matches[1], '成功')!==false){
			$_result['result']=1;
			$_result['msg']='操作成功';
			$_result['data']=array();
		}else{
			$_result['result']=0;
			$_result['msg']=$matches[1];
			$_result['data']=array();
		}
		echo json_encode($_result);
	}

	function radiususerList(){
		global $_CONFIG;		
		if(($data=$this->process_postdata())===false){
			return ;
		}
		$_SESSION['RADIUSUSERLIST']=true;
		$_GET=$data;
		$_GET['derive']=0;
		$this->config['site']['items_per_page']=$_GET['items_per_page'];

		require_once(ROOT ."./controller/c_admin_member.class.php");	
		$newmember = new c_admin_member();
		$newmember->init($this->smarty, $this->config);
		ob_start();
		$datas=$newmember->index(true,true );
		$result = ob_get_clean();
		$r = preg_match("/<script language='javascript'>alert\(['\"](.*?)['\"]\);/", $result, $matches);

		if($r==0){
			$_result['result']=1;
			$_result['msg']='操作成功';
			$_result['data']=$datas;
		}else{
			$_result['result']=0;
			$_result['msg']=$matches[1];
			$_result['data']=array();
		}

		echo json_encode($_result);
	}

	function userAdd(){
		global $_CONFIG;
		if(($data=$this->process_postdata())===false){
			return ;
		}
		$_SESSION['RADIUSUSERLIST']=false;
		$_POST = $data;
		$_POST['password1']=$data['password'];
		$_POST['password2']=$data['password'];
		$_GET['uid']=$data['uid'];
		require_once(ROOT ."./controller/c_admin_member.class.php");	
		$newmember = new c_admin_member();
		$memberset = new member_set();
		$newmember->init($this->smarty, $this->config);
		ob_start();
		$id=$newmember->save(true);
		$result = ob_get_clean();
		$r = preg_match("/<script language='javascript'>alert\(['\"](.*?)['\"]\);/", $result, $matches);
		if(strpos($matches[1], '成功')!==false){
			$_result['result']=1;
			$_result['msg']='操作成功';
			$_result['data']=$memberset->base_select('select *,NULL password from member where uid="'.$id.'"');
		}else{
			$_result['result']=0;
			$_result['msg']=$matches[1];
			$_result['data']=array();
		}
		echo json_encode($_result);
	}

	function userDel(){
		global $_CONFIG;		
		if(($data=$this->process_postdata())===false){
			return ;
		}
		$_SESSION['RADIUSUSERLIST']=false;
		$_POST['chk_member']=$data['uid'];
		require_once(ROOT ."./controller/c_admin_member.class.php");	
		$newmember = new c_admin_member();
		$memberset = new member_set();
		$newmember->init($this->smarty, $this->config);
		ob_start();
		$newmember->delete_all();
		$result = ob_get_clean();
		$r = preg_match("/<script language='javascript'>alert\(['\"](.*?)['\"]\);/", $result, $matches);
		if(strpos($matches[1], '成功')!==false){
			$_result['result']=1;
			$_result['msg']='操作成功';
			$_result['data']=array();
		}else{
			$_result['result']=0;
			$_result['msg']=$matches[1];
			$_result['data']=array();
		}
		echo json_encode($_result);
	}

	function userList(){
		global $_CONFIG;		
		if(($data=$this->process_postdata())===false){
			return ;
		}
		$_SESSION['RADIUSUSERLIST']=false;
		$_GET=$data;
		$_GET['derive']=0;
		$this->config['site']['items_per_page']=$_GET['items_per_page'];
		require_once(ROOT ."./controller/c_admin_member.class.php");	
		$newmember = new c_admin_member();
		$memberset = new member_set();
		$newmember->init($this->smarty, $this->config);
		ob_start();
		$datas=$newmember->index(false,true );
		$result = ob_get_clean();
		$r = preg_match("/<script language='javascript'>alert\(['\"](.*?)['\"]\);/", $result, $matches);
		if($r==0){
			$_result['result']=1;
			$_result['msg']='操作成功';
			$_result['data']=$datas;
		}else{
			$_result['result']=0;
			$_result['msg']=$matches[1];
			$_result['data']=array();
		}
		echo json_encode($_result);
	}

	function serverAdd(){
		global $_CONFIG;
		if(($data=$this->process_postdata())===false){
			return ;
		}
		$_POST = $data;
		$_POST['IP']=$_POST['ip'];
		$_GET['id']=$data['id'];
		require_once(ROOT ."./controller/c_admin_pro.class.php");	
		$newpro = new c_admin_pro();
		$serverset = new server_set();
		$newpro->init($this->smarty, $this->config);
		ob_start();
		$newpro->dev_save(true);
		$result = ob_get_clean();
		$r = preg_match("/<script language='javascript'>alert\(['\"](.*?)['\"]\);/", $result, $matches);
		if(strpos($matches[1], '成功')!==false){
			$_result['result']=1;
			$_result['msg']='操作成功';
			$_result['data']=$serverset->base_select('SELECT *,NULL superpassword FROM '.$serverset->get_table_name().' WHERE device_ip="'.$_POST['ip'].'"');
		}else{
			$_result['result']=0;
			$_result['msg']=$matches[1];
			$_result['data']=array();
		}
		echo json_encode($_result);
	}

	function serverDel(){
		global $_CONFIG;
		if(($data=$this->process_postdata())===false){
			return ;
		}
		$_POST = $data;
		$_POST['chk_member']=$data['id'];
		
		require_once(ROOT ."./controller/c_admin_pro.class.php");	
		$newpro = new c_admin_pro();
		$serverset = new server_set();
		$newpro->init($this->smarty, $this->config);
		ob_start();
		$newpro->dev_del(true);
		$result = ob_get_clean();
		$r = preg_match("/<script language='javascript'>alert\(['\"](.*?)['\"]\);/", $result, $matches);
		if(strpos($matches[1], '成功')!==false){

			$_result['result']=1;
			$_result['msg']='操作成功';
			$_result['data']=array();
		}else{
			$_result['result']=0;
			$_result['msg']=$matches[1];
			$_result['data']=array();
		}
		echo json_encode($_result);
	}

	function serverList(){
		global $_CONFIG;
		if(($data=$this->process_postdata())===false){
			return ;
		}
		$_GET = $data;
		$_GET['derive']=0;
		$this->config['site']['items_per_page']=$_GET['items_per_page'];
		require_once(ROOT ."./controller/c_admin_pro.class.php");	
		$newpro = new c_admin_pro();
		$serverset = new server_set();
		$newpro->init($this->smarty, $this->config);
		ob_start();
		$datas = $newpro->dev_index(true);
		$result = ob_get_clean();
		$r = preg_match("/<script language='javascript'>alert\(['\"](.*?)['\"]\);/", $result, $matches);
		if($r==0){
			$_result['result']=1;
			$_result['msg']='操作成功';
			$_result['data']=$datas;
		}else{
			$_result['result']=0;
			$_result['msg']=$matches[1];
			$_result['data']=array();
		}
		echo json_encode($_result);
	}

	function deviceAdd(){
		global $_CONFIG;
		if(($data=$this->process_postdata())===false){
			return ;
		}
		$_POST = $data;
		$_POST['sessionluser']='PASSEDIT_LUSER';
		$_POST['sessionlgroup']='PASSEDIT_LGROUP';
		$_POST['password_confirm']=$_POST['password'];
		$_GET['ip']=$_POST['ip'];
		$_GET['id']=$data['id'];
		$server = $this->server_set->select_all("device_ip='".$_GET['ip']."'");
		$_GET['serverid']=$server[0]['id'];
		require_once(ROOT ."./controller/c_admin_pro.class.php");
		unset($_SESSION['PASSEDIT_LUSER']);
		unset($_SESSION['PASSEDIT_LGROUP']);
		if($data['id']){
			//$this->luser_set->delete_all("devicesid=".$data['id']);
			//$this->lgroup_set->delete_all("devicesid=".$data['id']);
		}
		$i=0;
		if($_POST['users'])
		foreach($_POST['users'] AS $k=>$v){
			if($data['id']){
				$_v = $this->luser_set->select_all("devicesid=".$data['id']." AND memberid=".$k);
				$v['id']=$_v[0]['id'];
			}
			$v['memberid']=$k;
			if($_POST['useforbiddenid']){
				$finfo = $this->forbiddengps_set->select_by_id($v['forbidden_commands_groups']);
				$v['forbidden_commands_groups']=$finfo ? $finfo['gname']:'';
			}
			$_SESSION['PASSEDIT_LUSER'][]=$v;
			$_POST['Check'.$i++]=$k;
		}
		$i=0;
		if($_POST['groups'])
		foreach($_POST['groups'] AS $k=>$v){
			if($data['id']){
				$_v = $this->lgroup_set->select_all("devicesid=".$data['id']." AND groupid=".$k);
				$v['id']=$_v[0]['id'];
			}

			if($_POST['useforbiddenid']){
				$finfo = $this->forbiddengps_set->select_by_id($v['forbidden_commands_groups']);
				$v['forbidden_commands_groups']=$finfo ? $finfo['gname']:'';
			}
			$v['groupid']=$k;
			$_SESSION['PASSEDIT_LGROUP'][]=$v;
			$_POST['Group'.$i++]=$k;
		}//var_dump(isset($_SESSION['PASSEDIT_LGROUP'][0]['forbidden_commands_groups']));
		$newpro = new c_admin_pro();
		$deviceset = new devpass_set();
		$newpro->init($this->smarty, $this->config);
		ob_start();
		$id = $newpro->pass_save(true);
		$result = ob_get_clean();
		$r = preg_match("/<script language='javascript'>alert\(['\"](.*?)['\"]\);/", $result, $matches);
		if(strpos($matches[1], '成功')!==false){
			$_result['result']=1;
			$_result['msg']='操作成功';
			$_result['data']=$deviceset->base_select('select *,NULL cur_password,NULL old_password,NULL new_password from '.$deviceset->get_table_name().' where id="'.$id.'"');
		}else{
			$_result['result']=0;
			$_result['msg']=$matches[1];
			$_result['data']=array();
		}
		echo json_encode($_result);
	}

	function deviceDel(){
		global $_CONFIG;
		if(($data=$this->process_postdata())===false){
			return ;
		}
		$_POST = $data;
		$_GET['id']=$data['id'];
		
		require_once(ROOT ."./controller/c_admin_pro.class.php");	
		$newpro = new c_admin_pro();
		$serverset = new server_set();
		$newpro->init($this->smarty, $this->config);
		ob_start();
		$newpro->pass_del();
		$result = ob_get_clean();
		$r = preg_match("/<script language='javascript'>alert\(['\"](.*?)['\"]\);/", $result, $matches);
		if(strpos($matches[1], '成功')!==false){
			$_result['result']=1;
			$_result['msg']='操作成功';
			$_result['data']=array();
		}else{
			$_result['result']=0;
			$_result['msg']=$matches[1];
			$_result['data']=array();
		}
		echo json_encode($_result);
	}

	function deviceList(){
		global $_CONFIG;
		if(($data=$this->process_postdata())===false){
			return ;
		}
		$_GET = $data;
		$_GET['derive']=0;
		$this->config['site']['items_per_page']=$_GET['items_per_page'];
		require_once(ROOT ."./controller/c_admin_pro.class.php");	
		$newpro = new c_admin_pro();
		$serverset = new server_set();
		$newpro->init($this->smarty, $this->config);
		ob_start();
		$datas=$newpro->devpass_index(true);
		$result = ob_get_clean();
		$r = preg_match("/<script language='javascript'>alert\(['\"](.*?)['\"]\);/", $result, $matches);
		if($r==0){
			$_result['result']=1;
			$_result['msg']='操作成功';
			$_result['data']=$datas;
		}else{
			$_result['result']=0;
			$_result['msg']=$matches[1];
			$_result['data']=array();
		}
		echo json_encode($_result);
	}

	function resourceAdd(){
		global $_CONFIG;
		if(($data=$this->process_postdata())===false){
			return ;
		}
		$_POST = $data;
		$_POST['sessionluser']='RESOURCEGROUP_USER';
		$_POST['sessionlgroup']='RESOURCEGROUP_GROUP';
		$_POST['gname'] = $data['groupname'];
		$_GET['id']=$data['id'];
		unset($_SESSION['RESOURCEGROUP_USER']);
		unset($_SESSION['RESOURCEGROUP_GROUP']);
		if($data['id']){
			//$this->luser_resourcegrp_set->delete_all("resourceid=".$data['id']);
			//$this->lgroup_resourcegrp_set->delete_all("resourceid=".$data['id']);
		}
		$i=0;
		if($_POST['users'])
		foreach($_POST['users'] AS $k=>$v){
			if($data['id']){
				$_v = $this->luser_resourcegrp_set->select_all("resourceid=".$data['id']." AND memberid=".$k);
				$v['id']=$_v[0]['id'];
			}
			$v['memberid']=$k;
			$_SESSION['RESOURCEGROUP_USER'][]=$v;
			
			$_POST['Check'.$i++]=$k;
		}
		$i=0;
		if($_POST['groups'])
		foreach($_POST['groups'] AS $k=>$v){
			if($data['id']){
				$_v = $this->lgroup_resourcegrp_set->select_all("resourceid=".$data['id']." AND groupid=".$k);
				$v['id']=$_v[0]['id'];
			}
			$v['groupid']=$k;
			$_SESSION['RESOURCEGROUP_GROUP'][]=$v;
			$_POST['Group'.$i++]=$k;
		}
		
		require_once(ROOT ."./controller/c_admin_pro.class.php");	
		$newpro = new c_admin_pro();
		$resgroupset = new resgroup_set();
		$newpro->init($this->smarty, $this->config);
		$_POST['secend'] = $_POST['devices'];
		for($i=0; $i<count($data['bindgroup']); $i++){
			$_POST['secend'][]='groupid_'.$data['bindgroup'][$i];
		}
		ob_start();
		$id = $newpro->resource_group_save(true);
		$result = ob_get_clean();
		$r = preg_match("/<script language='javascript'>alert\(['\"](.*?)['\"]\);/", $result, $matches);
		if(strpos($matches[1], '成功')!==false){
			$_result['result']=1;
			$_result['msg']='操作成功';
			$_result['data']=$resgroupset->select_all('id="'.$id.'"');
		}else{
			$_result['result']=0;
			$_result['msg']=$matches[1];
			$_result['data']=array();
		}
		echo json_encode($_result);
	}

	function resourceDel(){
		global $_CONFIG;
		if(($data=$this->process_postdata())===false){
			return ;
		}
		$_POST = $data;
		
		require_once(ROOT ."./controller/c_admin_pro.class.php");	
		$newpro = new c_admin_pro();
		$resgroupset = new resgroup_set();
		$newpro->init($this->smarty, $this->config);
		ob_start();
		for($i=0; $i<count($data['id']);$i++){
			$resgroup = $resgroupset->select_by_id($data['id'][$i]);
			$_GET['gname'] = $resgroup['groupname'];
			$newpro->resource_group_del();
		}
		$result = ob_get_clean();
		$r = preg_match("/<script language='javascript'>alert\(['\"](.*?)['\"]\);/", $result, $matches);
		if(strpos($matches[1], '成功')!==false){
			$_result['result']=1;
			$_result['msg']='操作成功';
			$_result['data']=array();
		}else{
			$_result['result']=0;
			$_result['msg']=$matches[1];
			$_result['data']=array();
		}
		echo json_encode($_result);
	}

	function resourceList(){
		global $_CONFIG;
		if(($data=$this->process_postdata())===false){
			return ;
		}
		$_GET = $data;
		$_GET['derive']=0;
		$this->config['site']['items_per_page']=$_GET['items_per_page'];
		require_once(ROOT ."./controller/c_admin_pro.class.php");	
		$newpro = new c_admin_pro();
		$resgroupset = new resgroup_set();
		$newpro->init($this->smarty, $this->config);
		ob_start();
		$datas=$newpro->resource_group(true);
		$result = ob_get_clean();
		$r = preg_match("/<script language='javascript'>alert\(['\"](.*?)['\"]\);/", $result, $matches);
		if($r==0){
			$_result['result']=1;
			$_result['msg']='操作成功';
			$_result['data']=$datas;
		}else{
			$_result['result']=0;
			$_result['msg']=$matches[1];
			$_result['data']=array();
		}
		echo json_encode($_result);
	}
	
	function keyList(){
		global $_CONFIG;
		if(($data=$this->process_postdata())===false){
			return ;
		}
		$_GET = $data;
		$_POST['keyid']=$data['keyid'];
		$_POST['username']=$data['username'];
		$_GET['derive']=0;
		$this->config['site']['items_per_page']=$_GET['items_per_page'];
		require_once(ROOT ."./controller/c_admin_member.class.php");	
		$newmember = new c_admin_member();
		$newmember->init($this->smarty, $this->config);
		ob_start();
		$datas=$newmember->keys_index(true);
		$result = ob_get_clean();
		$r = preg_match("/<script language='javascript'>alert\(['\"](.*?)['\"]\);/", $result, $matches);

		if($r==0){
			$_result['result']=1;
			$_result['msg']='操作成功';
			$_result['data']=$datas;
		}else{
			$_result['result']=0;
			$_result['msg']=$matches[1];
			$_result['data']=array();
		}
		echo json_encode($_result);
	}

	function keyBind(){
		global $_CONFIG;
		if(($data=$this->process_postdata())===false){
			return ;
		}
		$usbkeyset = new usbkey_set();
		$memberset = new member_set();
		$user = $memberset->select_by_id($data['uid']);
		$key = $usbkeyset->select_all($data['keyid']);
		if($data['bind']){
			if(empty($user)){
				$_result['result']=0;
				$_result['msg']='用户不存在';
				$_result['data']=array();
			}elseif(empty($key)){
				$_result['result']=0;
				$_result['msg']='KEY不存在';
				$_result['data']=array();
			}else{
				$memberset->query("UPDATE member set usbkey='".$key[0]['keyid']."',usbkeystatus=11 where uid=".$data['uid']);
				$_result['result']=1;
				$_result['msg']='操作成功';
				$_result['data']=array();
			}
		}else{
			if(empty($user)){
				$_result['result']=0;
				$_result['msg']='用户不存在';
				$_result['data']=array();
			}else{
				$memberset->query("UPDATE member set usbkey='',usbkeystatus=0 where uid=".$data['uid']);
				$_result['result']=1;
				$_result['msg']='操作成功';
				$_result['data']=array();
			}
		}
		echo json_encode($_result);
	}
	
	function getQrcode(){
		global $_CONFIG;
		$memberset = new member_set();
		$user = $memberset->select_by_id($_GET['uid']);
		header('Location:include/phpqrcode/qrcodeimage.php?data='.$user['usbkey'].'&level=H&size=7');
	}

	function getQrcodeBase64(){
		global $_CONFIG;
		if(($data=$this->process_postdata())===false){
			return ;
		}
		$memberset = new member_set();
		$user = $memberset->select_by_id($data['uid']);
		$_REQUEST['data']=$user['usbkey'];
		$_REQUEST['level']='H';
		$_REQUEST['size']=7;
		ob_start();
		require_once 'include/phpqrcode/qrcodeimage.php';
		$data = ob_get_clean();
		echo base64_encode($data);
	}
	
	function ValidateKey(){
		global $_CONFIG;
		if(($data=$this->process_postdata())===false){
			return ;
		}
		$minfo = $this->member_set->select_by_id($data['uid']);
		if($minfo['usbkey']&&$minfo['usbkeystatus']==11){
			$old_radius = $this->radius_set->select_all("UserName = '".$minfo['username']."'");
			$new_radius = new radius();
			$new_radius->set_data("id",$old_radius[0]['id']);
			$new_radius->set_data("Value",crypt($this->member_set->udf_decrypt($minfo['password']),"\$1\$qY9g/6K4"));
			$this->radius_set->edit($new_radius);
			$_tmp = $this->member_set->base_select("select rad_getpasswd('".$minfo['username']."','".$this->member_set->udf_decrypt($minfo['password']).$data['qrcode']."','','127.0.0.1') AS p");
			if(crypt($this->member_set->udf_decrypt($minfo['password']).$data['qrcode'],"\$1\$qY9g/6K4")!=$_tmp[0]['p']){	
				$_result['result']=0;
				$_result['msg']='动态口令输入错误,系统时间为:'.date('Y年m月d日 H时i分');
				$_result['data']=array();
			}else{
				$newmember = new member();
				$newmember->set_data("usbkeystatus", 0);
				$newmember->set_data("smspassword", 0);
				$newmember->set_data("uid", $data['uid']);
				$this->member_set->edit($newmember);
				$_result['result']=1;
				$_result['msg']='操作成功';
				$_result['data']=array();
				
			}
		}else{
			$_result['result']=0;
			$_result['msg']='用户不需验证';
			$_result['data']=array();
		}
		echo json_encode($_result);
	}

	function forbiddenAdd(){
		global $_CONFIG;
		if(($data=$this->process_postdata())===false){
			return ;
		}
		$_POST = $data;
		$_POST['add']='new';
		$_POST['gname']=$data['groupname'];
		$_GET['id']=$data['id'];
		require_once(ROOT ."./controller/c_admin_forbidden.class.php");	
		$newpro = new c_admin_forbidden();
		$newpro->init($this->smarty, $this->config);
		ob_start();
		$id = $newpro->forbiddengps_save(true);
		$result = ob_get_clean();
		$r = preg_match("/<script language='javascript'>alert\(['\"](.*?)['\"]\);/", $result, $matches);
		if(strpos($matches[1], '成功')!==false){
			$_result['result']=1;
			$_result['msg']='操作成功';
			$_result['data']=$this->forbiddengps_set->select_all('gid="'.$id.'"');
		}else{
			$_result['result']=0;
			$_result['msg']=$matches[1];
			$_result['data']=array();
		}
		echo json_encode($_result);
	}
	
	function forbiddenDel(){
		global $_CONFIG;
		if(($data=$this->process_postdata())===false){
			return ;
		}
		$_POST = $data;
		$_GET['gid']=$data['gid'];
		
		require_once(ROOT ."./controller/c_admin_forbidden.class.php");	
		$newpro = new c_admin_forbidden();
		$newpro->init($this->smarty, $this->config);
		ob_start();
		$newpro->del_forbiddengps(true);
		$result = ob_get_clean();
		$r = preg_match("/<script language='javascript'>alert\(['\"](.*?)['\"]\);/", $result, $matches);
		if(strpos($matches[1], '成功')!==false){
			$_result['result']=1;
			$_result['msg']='操作成功';
			$_result['data']=array();
		}else{
			$_result['result']=0;
			$_result['msg']=$matches[1];
			$_result['data']=array();
		}
		echo json_encode($_result);
	}
	
	function forbiddenList(){
		global $_CONFIG;
		if(($data=$this->process_postdata())===false){
			return ;
		}
		$_GET = $data;
		$_GET['derive']=0;
		$this->config['site']['items_per_page']=$_GET['items_per_page'];
		require_once(ROOT ."./controller/c_admin_forbidden.class.php");	
		$newpro = new c_admin_forbidden();
		$newpro->init($this->smarty, $this->config);
		ob_start();
		$datas=$newpro->forbidden_groups_list(true);
		$result = ob_get_clean();
		$r = preg_match("/<script language='javascript'>alert\(['\"](.*?)['\"]\);/", $result, $matches);
		if($r==0){
			$_result['result']=1;
			$_result['msg']='操作成功';
			$_result['data']=$datas;
		}else{
			$_result['result']=0;
			$_result['msg']=$matches[1];
			$_result['data']=array();
		}
		echo json_encode($_result);
	}
	
	function forbiddenCmdAdd(){
		global $_CONFIG;
		if(($data=$this->process_postdata())===false){
			return ;
		}
		$_POST = $data;
		$_POST['add']='new';
		$_GET['cid']=$data['cid'];
		for($i=0; $i<count($data['cmd']); $i++){
			if(empty($data['cmd'][$i])) continue;
			$_POST['cmd_'.$i]=$data['cmd'][$i];
		}
		for($i=0; $i<count($data['level']); $i++){
			if(empty($data['level'][$i])) continue;
			$_POST['level_'.$i]=$data['level'][$i];
		}
		require_once(ROOT ."./controller/c_admin_forbidden.class.php");	
		$newpro = new c_admin_forbidden();
		$newpro->init($this->smarty, $this->config);
		ob_start();
		$id = $newpro->forbiddengps_cmd_save();
		$result = ob_get_clean();
		$r = preg_match("/<script language='javascript'>alert\(['\"](.*?)['\"]\);/", $result, $matches);
		if(strpos($matches[1], '成功')!==false){
			$_result['result']=1;
			$_result['msg']='操作成功';
			$_result['data']=$this->forbiddengpscommand_set->select_all('cid IN('.implode(',',$id).')');
		}else{
			$_result['result']=0;
			$_result['msg']=$matches[1];
			$_result['data']=array();
		}
		echo json_encode($_result);
	}
	
	function forbiddenCmdDel(){
		global $_CONFIG;
		if(($data=$this->process_postdata())===false){
			return ;
		}
		$_POST = $data;
        for($i=0; $i<count($data['cid']); $i++){
            if(empty($data['cid'][$i])) continue;
            $_POST['chk_gid'][]=$data['cid'][$i];
        }
		require_once(ROOT ."./controller/c_admin_forbidden.class.php");	
		$newpro = new c_admin_forbidden();
		$newpro->init($this->smarty, $this->config);
		ob_start();
		$newpro->del_forbiddengps_cmd();
		$result = ob_get_clean();
		$r = preg_match("/<script language='javascript'>alert\(['\"](.*?)['\"]\);/", $result, $matches);
		if(strpos($matches[1], '成功')!==false){
			$_result['result']=1;
			$_result['msg']='操作成功';
			$_result['data']=array();
		}else{
			$_result['result']=0;
			$_result['msg']=$matches[1];
			$_result['data']=array();
		}
		echo json_encode($_result);
	}
	
	function forbiddenCmdList(){
		global $_CONFIG;
		if(($data=$this->process_postdata())===false){
			return ;
		}
		$_GET = $data;
		$_GET['derive']=0;
		$this->config['site']['items_per_page']=$_GET['items_per_page'];
		require_once(ROOT ."./controller/c_admin_forbidden.class.php");	
		$newpro = new c_admin_forbidden();
		$newpro->init($this->smarty, $this->config);
		ob_start();
		$datas=$newpro->forbiddengps_cmd(true);
		$result = ob_get_clean();
		$r = preg_match("/<script language='javascript'>alert\(['\"](.*?)['\"]\);/", $result, $matches);
		if($r==0){
			$_result['result']=1;
			$_result['msg']='操作成功';
			$_result['data']=$datas;
		}else{
			$_result['result']=0;
			$_result['msg']=$matches[1];
			$_result['data']=array();
		}
		echo json_encode($_result);
	}
	
	
	
	function sessionList(){
		global $_CONFIG;
		if(($data=$this->process_postdata())===false){
			return ;
		}
		$_GET = $data;
		$this->config['site']['items_per_page']=$_GET['items_per_page'];
		$_GET['f_rangeStart']=$_GET['start'];
		$_GET['f_rangeEnd']=$_GET['end'];
		$_GET['start1']=$_GET['start'];
		$_GET['start2']=$_GET['end'];	
		$_GET['addr']=($_GET['ip'] ? explode(',',$_GET['ip']) : '');	
		$_GET['svraddr']=($_GET['ip'] ? explode(',',$_GET['ip']) : '');
		$type = $_GET['type'];
		unset($_GET['start']);
		unset($_GET['end']);
		unset($_GET['type']);
		switch($type){
			case 'ssh':
				$_GET['luser']=$_GET['user'];
				unset($_GET['user']);
				require_once(ROOT ."./controller/c_admin_session.class.php");	
				$newpro = new c_admin_session();
				$newpro->init($this->smarty, $this->config);
				$datas=$newpro->index(NULL,true);

			break;
			case 'telnet':
				require_once(ROOT ."./controller/c_admin_session.class.php");	
				$newpro = new c_admin_session();
				$newpro->init($this->smarty, $this->config);
				$datas=$newpro->index(NULL,true);
				
			break;
			case 'commands':
				require_once(ROOT ."./controller/c_admin_session.class.php");	
				$newpro = new c_admin_session();
				$newpro->init($this->smarty, $this->config);
				$datas=$newpro->view(true);
			break;
			case 'scp':
				require_once(ROOT ."./controller/c_admin_scp.class.php");	
				$newpro = new c_admin_scp();
				$newpro->init($this->smarty, $this->config);
				$datas=$newpro->index(NULL,true);
			break;
			case 'sftp':
				require_once(ROOT ."./controller/c_admin_sftp.class.php");	
				$newpro = new c_admin_sftp();
				$newpro->init($this->smarty, $this->config);
				$datas=$newpro->index(NULL,true);
			break;
			case 'sftpcommands':
				require_once(ROOT ."./controller/c_admin_sftp.class.php");	
				$newpro = new c_admin_sftp();
				$newpro->init($this->smarty, $this->config);
				$datas=$newpro->view(true);
			break;
			case 'ftp':
				$_GET['d_addr']=$_GET['svraddr'];
				unset($_GET['svraddr']);
				require_once(ROOT ."./controller/c_admin_ftp.class.php");	
				$newpro = new c_admin_ftp();
				$newpro->init($this->smarty, $this->config);
				$datas=$newpro->index(NULL,true);
			break;
			case 'ftpcommands':
				require_once(ROOT ."./controller/c_admin_ftp.class.php");	
				$newpro = new c_admin_ftp();
				$newpro->init($this->smarty, $this->config);
				$datas=$newpro->view(true);
			break;
			case 'as400':
				require_once(ROOT ."./controller/c_admin_as400.class.php");	
				$newpro = new c_admin_as400();
				$newpro->init($this->smarty, $this->config);
				$datas=$newpro->index(NULL,true);
			break;
			case 'rdp':
				$_GET['luser']=$_GET['user'];
				unset($_GET['user']);
				require_once(ROOT ."./controller/c_admin_rdp.class.php");	
				$newpro = new c_admin_rdp();
				$newpro->init($this->smarty, $this->config);
				$datas=$newpro->index(NULL,true);
			break;
			case 'vnc':
				$_GET['luser']=$_GET['user'];
				unset($_GET['user']);
				require_once(ROOT ."./controller/c_admin_vnc.class.php");	
				$newpro = new c_admin_vnc();
				$newpro->init($this->smarty, $this->config);
				$datas=$newpro->index(NULL,true);
			break;
			case 'x11':
				require_once(ROOT ."./controller/c_admin_x11.class.php");	
				$newpro = new c_admin_x11();
				$newpro->init($this->smarty, $this->config);
				$datas=$newpro->index(NULL,true);
			break;
			case 'apppub':
				require_once(ROOT ."./controller/c_admin_apppub.class.php");	
				$newpro = new c_admin_apppub();
				$newpro->init($this->smarty, $this->config);
				$datas=$newpro->index(NULL,true);
			break;
			case 'mysqlcommands':
				require_once(ROOT ."./controller/c_admin_apppub.class.php");	
				$newpro = new c_admin_apppub();
				$newpro->init($this->smarty, $this->config);
				$datas=$newpro->sqlview(true);
			break;
			case 'rdpmouse':
				require_once(ROOT ."./controller/c_admin_rdp.class.php");	
				$newpro = new c_admin_rdp();
				$newpro->init($this->smarty, $this->config);
				$datas=$newpro->rdpmouse(true);
			break;
			case 'clipboard':
				require_once(ROOT ."./controller/c_admin_rdp.class.php");	
				$newpro = new c_admin_rdp();
				$newpro->init($this->smarty, $this->config);
				$datas=$newpro->clipboard(true);
				ob_get_clean();
				$_result['result']=1;
				$_result['msg']='操作成功';
				$_result['data']=$datas;
				echo json_encode($_result);	
				return ;
			break;
			case 'inputview':
				require_once(ROOT ."./controller/c_admin_rdp.class.php");	
				$newpro = new c_admin_rdp();
				$newpro->init($this->smarty, $this->config);
				$datas=$newpro->inputview(true);
				ob_get_clean();
				$_result['result']=1;
				$_result['msg']='操作成功';
				$_result['data']=$datas;
				echo json_encode($_result);	
				return ;
			break;
			
		}
		
		ob_get_clean();
		$_result['result']=1;
		$_result['msg']='操作成功';
		$_result['data']=$datas['datas'];
		$_result['rows']=$datas['total'];
		echo json_encode($_result);
	}
	
	function sessionOnline(){
		global $_CONFIG;
		if(($data=$this->process_postdata())===false){
			return ;
		}
		$_GET = $data;
		$this->config['site']['items_per_page']=$_GET['items_per_page'];
		ob_start();
		$_GET['f_rangeStart']=$_GET['start'];
		$_GET['f_rangeEnd']=$_GET['end'];
		$_GET['start1']=$_GET['start'];
		$_GET['start2']=$_GET['end'];	
		$_GET['addr']=($_GET['ip'] ? explode(',',$_GET['ip']) : '');	
		$_GET['svraddr']=($_GET['ip'] ? explode(',',$_GET['ip']) : '');	
		unset($_GET['start']);
		unset($_GET['end']);
		unset($_GET['type']);
		switch($data['type']){
			case 'ssh':
				require_once(ROOT ."./controller/c_admin_session.class.php");
				$newpro = new c_admin_session();
				$newpro->init($this->smarty, $this->config);
				$datas=$newpro->gateway_running_list(1);
			break;
			case 'telnet':
				require_once(ROOT ."./controller/c_admin_session.class.php");
				$newpro = new c_admin_session();
				$newpro->init($this->smarty, $this->config);
				$datas=$newpro->gateway_running_telnet(1);
			break;
			case 'rdp':
				require_once(ROOT ."./controller/c_admin_rdprun.class.php");
				$newpro = new c_admin_rdprun();
				$newpro->init($this->smarty, $this->config);
				$datas=$newpro->index(NULL,true);
			break;
			case 'vnc':
				require_once(ROOT ."./controller/c_admin_vncrun.class.php");
				$newpro = new c_admin_vncrun();
				$newpro->init($this->smarty, $this->config);
				$datas=$newpro->index(NULL,true);
			break;
			case 'apppub':
				require_once(ROOT ."./controller/c_admin_apppubrun.class.php");
				$newpro = new c_admin_apppubrun();
				$newpro->init($this->smarty, $this->config);
				$datas=$newpro->index(NULL,true);
			break;
		}
		
		ob_get_clean();
		$_result['result']=1;
		$_result['msg']='操作成功';
		$_result['data']=$datas['datas'];
		$_result['rows']=$datas['total'];
		echo json_encode($_result);
	}
	
	function sessionCut(){
		global $_CONFIG;
		if(($data=$this->process_postdata())===false){
			return ;
		}
		$_GET = $data;
		ob_start();
		switch($data['type']){
			case 'ssh':
				require_once(ROOT ."./controller/c_admin_session.class.php");	
				$newpro = new c_admin_session();
				$newpro->init($this->smarty, $this->config);
				$datas=$newpro->cut_running();
			break;
			case 'telnet':
				require_once(ROOT ."./controller/c_admin_session.class.php");	
				$newpro = new c_admin_session();
				$newpro->init($this->smarty, $this->config);
				$datas=$newpro->cut_running();
			break;
			case 'rdp':
				require_once(ROOT ."./controller/c_admin_rdprun.class.php");	
				$newpro = new c_admin_rdprun();
				$newpro->init($this->smarty, $this->config);
				$datas=$newpro->cutoff();
			break;
			case 'vnc':
				require_once(ROOT ."./controller/c_admin_vncrun.class.php");	
				$newpro = new c_admin_vncrun();
				$newpro->init($this->smarty, $this->config);
				$datas=$newpro->cutoff();
			break;
			case 'apppub':
			break;
		}
		
		$result=ob_get_clean();
		$r = preg_match("/<script language='javascript'>alert\(['\"](.*?)['\"]\);/", $result, $matches);
		if(strpos($matches[1], '成功')!==false){
			$_result['result']=1;
			$_result['msg']='操作成功';
			$_result['data']=array();
		}else{
			$_result['result']=0;
			$_result['msg']='操作失败';
			$_result['data']=array();
		}
		echo json_encode($_result);
	}
	
	function devLogin(){
		global $_CONFIG;
		if(($data=$this->process_postdata())===false){
			return ;
		}
		$_GET = $data;
		
		require_once(ROOT ."./controller/c_admin_pro.class.php");	
		$newpro = new c_admin_pro();
		$newpro->init($this->smarty, $this->config);
		if($data['vncport']){
			$_SESSION['EDITVNCPORTDEVICESIDS'][]=$data['id'];
			$newdev = new devpass();
			$newdev->set_data('port', $data['vncport']);
			$newdev->set_data("id", $data['id']);
			$this->devpass_set->edit($newdev);
		}
		ob_start();
		$newpro->dev_login();
		$result = ob_get_clean();
		$r = preg_match("/<script language='javascript'>alert\(['\"](.*?)['\"]\);/", $result, $matches);
		if(strpos($result, '目标设备以下用户已经登录')!==false){
			$_result['result']=-1;
			$_result['msg']='已经存在登录用户';
			$_result['data']=array();
		}elseif(!$r){
			$_result['result']=1;
			$_result['msg']='操作成功';
			$_result['data']=array('address'=>$result);
		}else{
			$_result['result']=0;
			$_result['msg']=$matches[1];
			$_result['data']=array();
		}
		echo json_encode($_result);
	}

	function ipaclAdd(){
		global $_CONFIG;
		if(($data=$this->process_postdata())===false){
			return ;
		}
		$_POST = $data;
		$_GET['sid']=$data['sid'];
		require_once(ROOT ."./controller/c_admin_ipacl.class.php");	
		$newpro = new c_admin_ipacl();
		$newpro->init($this->smarty, $this->config);
		ob_start();
		$id = $newpro->save();
		$result = ob_get_clean();
		$r = preg_match("/<script language='javascript'>alert\(['\"](.*?)['\"]\);/", $result, $matches);
		if(strpos($matches[1], '成功')!==false){
			$_result['result']=1;
			$_result['msg']='操作成功';
			$_result['data']=$this->restrictacl_set->select_by_id($id);
		}else{
			$_result['result']=0;
			$_result['msg']=$matches[1];
			$_result['data']=array();
		}
		echo json_encode($_result);
	}
	
	function ipaclDel(){
		global $_CONFIG;
		if(($data=$this->process_postdata())===false){
			return ;
		}
		$_POST = $data;
        $_GET['id']=$data['sid'];
		require_once(ROOT ."./controller/c_admin_ipacl.class.php");	
		$newpro = new c_admin_ipacl();
		$newpro->init($this->smarty, $this->config);
		ob_start();
		$newpro->delete();
		$result = ob_get_clean();
		$r = preg_match("/<script language='javascript'>alert\(['\"](.*?)['\"]\);/", $result, $matches);
		if(strpos($matches[1], '成功')!==false){
			$_result['result']=1;
			$_result['msg']='操作成功';
			$_result['data']=array();
		}else{
			$_result['result']=0;
			$_result['msg']=$matches[1];
			$_result['data']=array();
		}
		echo json_encode($_result);
	}
	
	function ipaclList(){
		global $_CONFIG;
		if(($data=$this->process_postdata())===false){
			return ;
		}
		$_GET = $data;
		$_GET['derive']=0;
		$this->config['site']['items_per_page']=$_GET['items_per_page'];
		require_once(ROOT ."./controller/c_admin_ipacl.class.php");	
		$newpro = new c_admin_ipacl();
		$newpro->init($this->smarty, $this->config);
		ob_start();
		$datas=$newpro->index(true);
		$result = ob_get_clean();
		$r = preg_match("/<script language='javascript'>alert\(['\"](.*?)['\"]\);/", $result, $matches);
		if($r==0){
			$_result['result']=1;
			$_result['msg']='操作成功';
			$_result['data']=$datas;
		}else{
			$_result['result']=0;
			$_result['msg']=$matches[1];
			$_result['data']=array();
		}
		echo json_encode($_result);
	}

	function devMonitor(){
		global $_CONFIG;
		if(($data=$this->process_postdata())===false){
			return ;
		}
		$_GET = $data;
		$this->config['site']['items_per_page']=$_GET['items_per_page'];
		switch($data['ltype']){
			case 'ssh':
			case 'telnet':
				require_once(ROOT ."./controller/c_admin_session.class.php");	
				$newpro = new c_admin_session();
				$newpro->init($this->smarty, $this->config);
				ob_start();
				$newpro->monitor();
			break;
			case 'rdp':
				require_once(ROOT ."./controller/c_admin_rdprun.class.php");	
				$newpro = new c_admin_rdprun();
				$newpro->init($this->smarty, $this->config);
				ob_start();
				$newpro->index();
			break;
			case 'vnc':
				require_once(ROOT ."./controller/c_admin_rdprun.class.php");	
				$newpro = new c_admin_rdprun();
				$newpro->init($this->smarty, $this->config);
				ob_start();
				$newpro->index();
			break;
		}
		
		$result = ob_get_clean();
		$r = preg_match("/<script language='javascript'>alert\(['\"](.*?)['\"]\);/", $result, $matches);
		if(!$r){
			$_result['result']=1;
			$_result['msg']='操作成功';
			$_result['data']=array('address'=>$result);
		}else{
			$_result['result']=0;
			$_result['msg']=$matches[1];
			$_result['data']=array();
		}
		echo json_encode($_result);
	}

	function sessionReplay(){
		global $_CONFIG;
		if(($data=$this->process_postdata())===false){
			return ;
		}
		$_GET = $data;
		switch($data['ltype']){
			case 'ssh':
			case 'telnet':
				require_once(ROOT ."./controller/c_admin_session.class.php");	
				$newpro = new c_admin_session();
				$newpro->init($this->smarty, $this->config);
				ob_start();
				$newpro->replay();
			break;
			case 'rdp':
				require_once(ROOT ."./controller/c_admin_rdp.class.php");	
				$newpro = new c_admin_rdp();
				$newpro->init($this->smarty, $this->config);
				ob_start();
				$newpro->index();
			break;
			case 'vnc':
				require_once(ROOT ."./controller/c_admin_vnc.class.php");	
				$newpro = new c_admin_vnc();
				$newpro->init($this->smarty, $this->config);
				ob_start();
				$newpro->index();
			break;
			case 'app':
				require_once(ROOT ."./controller/c_admin_apppub.class.php");	
				$newpro = new c_admin_apppub();
				$newpro->init($this->smarty, $this->config);
				ob_start();
				$newpro->index();
			break;
		}
		
		$result = ob_get_clean();
		$r = preg_match("/<script language='javascript'>alert\(['\"](.*?)['\"]\);/", $result, $matches);
		if(!$r){
			$_result['result']=1;
			$_result['msg']='操作成功';
			$_result['data']=array('address'=>$result);
		}else{
			$_result['result']=0;
			$_result['msg']=$matches[1];
			$_result['data']=array();
		}
		echo json_encode($_result);
	}

	function sessionDownFile(){
		global $_CONFIG;
		if(($data=$this->process_postdata())===false){
			return ;
		}
		$_GET = $data;
		switch($data['ltype']){
			case 'ssh':
			case 'telnet':
				require_once(ROOT ."./controller/c_admin_session.class.php");	
				$newpro = new c_admin_session();
				$newpro->init($this->smarty, $this->config);
				$newpro->downloadfile(1);
			break;
			case 'rdp':
				require_once(ROOT ."./controller/c_admin_rdp.class.php");	
				$newpro = new c_admin_rdp();
				$newpro->init($this->smarty, $this->config);
				$newpro->downloadplayfile(1);
			case 'vnc':
				require_once(ROOT ."./controller/c_admin_rdp.class.php");	
				$newpro = new c_admin_rdp();
				$newpro->init($this->smarty, $this->config);
				$newpro->downloadplayfile(1);
			break;
		}
	}

	function sessionLogFile(){
		global $_CONFIG;
		if(($data=$this->process_postdata())===false){
			return ;
		}
		$_GET = $data;
		$_GET['page'] = $data['start_page'];
		ob_start();
		switch($data['ltype']){
			case 'ssh':
			case 'telnet':
				$_POST['search']=$data['search'];
				require_once(ROOT ."./controller/c_admin_session.class.php");	
				$newpro = new c_admin_session();
				$newpro->init($this->smarty, $this->config);
				$newpro->download(1);
			break;
		}
		$result = ob_get_clean();
		$r = preg_match("/<script language='javascript'>alert\(['\"](.*?)['\"]\);/", $result, $matches);
		if(!$r){
			$_result['result']=1;
			$_result['msg']='操作成功';
			$_result['data']=$result;
		}else{
			$_result['result']=0;
			$_result['msg']=$matches[1];
			$_result['data']=array();
		}
		echo json_encode($_result);
	}

	function reportList(){
		global $_CONFIG;
		if(($data=$this->process_postdata())===false){
			return ;
		}
		$_GET = $data;
		$this->config['site']['items_per_page']=$_GET['items_per_page'];
		$actions = $data['actions'];
		$_GET['f_rangeStart']=$_GET['start'];
		$_GET['f_rangeEnd']=$_GET['end'];
		$result = ob_get_clean();
		$r = preg_match("/<script language='javascript'>alert\(['\"](.*?)['\"]\);/", $result, $matches);
		require_once(ROOT ."./controller/c_admin_reports.class.php");	
		$newpro = new c_admin_reports();
		$newpro->init($this->smarty, $this->config);
		//$actions:loginacct,logintims,loginfailed,devloginreport,apploginreport,workflow_approve,commandreport,cmdcachereport,cmdlistreport,appreport,sftpreport,ftpreport,dangercmdreport,dangercmdlistreport,reportgraph
		$datas=$newpro->$actions(null,true);
		if(!$r){
			$_result['result']=1;
			$_result['msg']='操作成功';
			$_result['data']=$datas['datas'];
			$_result['rows']=$datas['total'];
		}else{
			$_result['result']=0;
			$_result['msg']=$matches[1];
			$_result['data']=array();
			$_result['rows']=0;
		}
		echo json_encode($_result);
	}

	function searchHtmlLog(){
		global $_CONFIG;
		if(($data=$this->process_postdata())===false){
			return ;
		}
		$_GET = $data;
		$this->config['site']['items_per_page']=$_GET['items_per_page'];
		$_GET['f_rangeStart']=$_GET['start'];
		$_GET['f_rangeEnd']=$_GET['end'];
		$_GET['start_date']=$_GET['start'];
		$_GET['end_date']=$_GET['end'];	
		$result = ob_get_clean();
		$r = preg_match("/<script language='javascript'>alert\(['\"](.*?)['\"]\);/", $result, $matches);
		require_once(ROOT ."./controller/c_admin_session.class.php");	
		$newpro = new c_admin_session();
		$newpro->init($this->smarty, $this->config);
		//$actions:loginacct,logintims,loginfailed,devloginreport,apploginreport,workflow_approve,commandreport,cmdcachereport,cmdlistreport,appreport,sftpreport,ftpreport,dangercmdreport,dangercmdlistreport,reportgraph
		$datas=$newpro->search_html_log(true);
		if(!$r){
			$_result['result']=1;
			$_result['msg']='操作成功';
			$_result['data']=$datas['datas'];
			$_result['rows']=$datas['total'];
		}else{
			$_result['result']=0;
			$_result['msg']=$matches[1];
			$_result['data']=array();
			$_result['rows']=0;
		}
		echo json_encode($_result);
	}

	function testPort(){
		global $_CONFIG;
		if(($data=$this->process_postdata())===false){
			return ;
		}
		$_GET = $data;
		$result = ob_get_clean();
		$r = preg_match("/<script language='javascript'>alert\(['\"](.*?)['\"]\);/", $result, $matches);
		require_once(ROOT ."./controller/c_admin_pro.class.php");	
		$newpro = new c_admin_pro();
		$newpro->init($this->smarty, $this->config);
		$datas=$newpro->test_port(true);
		if(!$r){
			$_result['result']=1;
			$_result['msg']='操作成功';
			$_result['data']=$datas;
		}else{
			$_result['result']=0;
			$_result['msg']=$matches[1];
			$_result['data']=array();
		}
		echo json_encode($_result);
	}

	function appIconAdd(){
		global $_CONFIG;
		if(($data=$this->process_postdata())===false){
			return ;
		}
		$_POST = $data;
		$_GET['id']=$data['id'];
		$file = ROOT.'upload/'.$data['imagename'];
		file_put_contents($file,base64_decode($_POST['imagedata']));
		$_POST['path'] = $data['imagename'];
		require_once(ROOT ."./controller/c_admin_config.class.php");	
		$newpro = new c_admin_config();
		$newpro->init($this->smarty, $this->config);
		ob_start();
		$id=$newpro->appicon_save(true);
		$result = ob_get_clean();
		$r = preg_match("/<script language='javascript'>alert\(['\"](.*?)['\"]\);/", $result, $matches);
		if(strpos($matches[1], '成功')!==false){
			$_result['result']=1;
			$_result['msg']='操作成功';
			$_result['data']=$this->appicon_set->select_by_id($id);
		}else{
			$_result['result']=0;
			$_result['msg']=$matches[1];
			$_result['data']=array();
		}
		echo json_encode($_result);
	}

	function appIconDel(){
		global $_CONFIG;
		if(($data=$this->process_postdata())===false){
			return ;
		}
		$_POST = $data;
		$_POST['chk_member']=$data['id'];
		require_once(ROOT ."./controller/c_admin_config.class.php");	
		$newpro = new c_admin_config();
		$newpro->init($this->smarty, $this->config);
		ob_start();
		$newpro->appicon_delete();
		$result = ob_get_clean();
		$r = preg_match("/<script language='javascript'>alert\(['\"](.*?)['\"]\);/", $result, $matches);
		if(strpos($matches[1], '成功')!==false){
			$_result['result']=1;
			$_result['msg']='操作成功';
			$_result['data']=array();
		}else{
			$_result['result']=0;
			$_result['msg']=$matches[1];
			$_result['data']=array();
		}
		echo json_encode($_result);
	}

	function appIconList(){
		global $_CONFIG;
		if(($data=$this->process_postdata())===false){
			return ;
		}
		$_GET = $data;
		$_GET['derive']=0;
		$this->config['site']['items_per_page']=$_GET['items_per_page'];
		require_once(ROOT ."./controller/c_admin_config.class.php");	
		$newpro = new c_admin_config();
		$newpro->init($this->smarty, $this->config);
		ob_start();
		$datas=$newpro->appicon_list(true);
		$result = ob_get_clean();
		$r = preg_match("/<script language='javascript'>alert\(['\"](.*?)['\"]\);/", $result, $matches);
		if($r==0){
			$_result['result']=1;
			$_result['msg']='操作成功';
			$_result['data']=$datas;
		}else{
			$_result['result']=0;
			$_result['msg']=$matches[1];
			$_result['data']=array();
		}
		echo json_encode($_result);
	}

	function appProgramAdd(){
		global $_CONFIG;
		if(($data=$this->process_postdata())===false){
			return ;
		}
		$_POST = $data;
		$_GET['id']=$data['id'];
		require_once(ROOT ."./controller/c_admin_config.class.php");	
		$newpro = new c_admin_config();
		$newpro->init($this->smarty, $this->config);
		ob_start();
		$id=$newpro->appprogram_save();
		var_dump($id);
		$result = ob_get_clean();
		$r = preg_match("/<script language='javascript'>alert\(['\"](.*?)['\"]\);/", $result, $matches);
		if(strpos($matches[1], '成功')!==false){
			$_result['result']=1;
			$_result['msg']='操作成功';
			$_result['data']=$this->appprogram_set->select_by_id($id);
		}else{
			$_result['result']=0;
			$_result['msg']=$matches[1];
			$_result['data']=array();
		}
		echo json_encode($_result);
	}

	function appProgramDel(){
		global $_CONFIG;
		if(($data=$this->process_postdata())===false){
			return ;
		}
		$_POST = $data;
		$_POST['chk_member']=$data['id'];
		require_once(ROOT ."./controller/c_admin_config.class.php");	
		$newpro = new c_admin_config();
		$newpro->init($this->smarty, $this->config);
		ob_start();
		$newpro->appprogram_delete();
		$result = ob_get_clean();
		$r = preg_match("/<script language='javascript'>alert\(['\"](.*?)['\"]\);/", $result, $matches);
		if(strpos($matches[1], '成功')!==false){
			$_result['result']=1;
			$_result['msg']='操作成功';
			$_result['data']=array();
		}else{
			$_result['result']=0;
			$_result['msg']=$matches[1];
			$_result['data']=array();
		}
		echo json_encode($_result);
	}

	function appProgramList(){
		global $_CONFIG;
		if(($data=$this->process_postdata())===false){
			return ;
		}
		$_GET = $data;
		$_GET['derive']=0;
		$this->config['site']['items_per_page']=$_GET['items_per_page'];
		require_once(ROOT ."./controller/c_admin_config.class.php");	
		$newpro = new c_admin_config();
		$newpro->init($this->smarty, $this->config);
		ob_start();
		$datas=$newpro->appprogram_list(true);
		$result = ob_get_clean();
		$r = preg_match("/<script language='javascript'>alert\(['\"](.*?)['\"]\);/", $result, $matches);
		if($r==0){
			$_result['result']=1;
			$_result['msg']='操作成功';
			$_result['data']=$datas;
		}else{
			$_result['result']=0;
			$_result['msg']=$matches[1];
			$_result['data']=array();
		}
		echo json_encode($_result);
	}

	function appServerIps(){
		$pserver = $this->devpass_set->base_select("SELECT distinct device_ip FROM ".$this->devpass_set->get_table_name()." WHERE login_method=26");
		$_result['result']=1;
		$_result['msg']='操作成功';
		$_result['data']=$pserver;
		echo json_encode($_result);
	}

	function appServerAdd(){
		global $_CONFIG;
		if(($data=$this->process_postdata())===false){
			return ;
		}
		$_POST = $data;
		$_GET['id']=$data['id'];
		require_once(ROOT ."./controller/c_admin_config.class.php");	
		$newpro = new c_admin_config();
		$newpro->init($this->smarty, $this->config);
		ob_start();
		$id=$newpro->appserver_save();
		$result = ob_get_clean();
		$r = preg_match("/<script language='javascript'>alert\(['\"](.*?)['\"]\);/", $result, $matches);
		if(strpos($matches[1], '成功')!==false){
			$_result['result']=1;
			$_result['msg']='操作成功';
			$_result['data']=$this->appserver_set->select_by_id($id);
		}else{
			$_result['result']=0;
			$_result['msg']=$matches[1];
			$_result['data']=array();
		}
		echo json_encode($_result);
	}

	function appServerDel(){
		global $_CONFIG;
		if(($data=$this->process_postdata())===false){
			return ;
		}
		$_GET['id']=$data['id'];
		require_once(ROOT ."./controller/c_admin_config.class.php");	
		$newpro = new c_admin_config();
		$newpro->init($this->smarty, $this->config);
		ob_start();
		$newpro->appserver_delete();
		$result = ob_get_clean();
		$r = preg_match("/<script language='javascript'>alert\(['\"](.*?)['\"]\);/", $result, $matches);
		if(strpos($matches[1], '成功')!==false){

			$_result['result']=1;
			$_result['msg']='操作成功';
			$_result['data']=array();
		}else{
			$_result['result']=0;
			$_result['msg']=$matches[1];
			$_result['data']=array();
		}
		echo json_encode($_result);
	}

	function appServerList(){
		global $_CONFIG;
		if(($data=$this->process_postdata())===false){
			return ;
		}
		$_GET = $data;
		$_GET['derive']=0;
		$this->config['site']['items_per_page']=$_GET['items_per_page'];
		require_once(ROOT ."./controller/c_admin_config.class.php");	
		$newpro = new c_admin_config();
		$newpro->init($this->smarty, $this->config);
		ob_start();
		$datas=$newpro->appserver_list(true);
		$result = ob_get_clean();
		$r = preg_match("/<script language='javascript'>alert\(['\"](.*?)['\"]\);/", $result, $matches);
		if($r==0){
			$_result['result']=1;
			$_result['msg']='操作成功';
			$_result['data']=$datas;
		}else{
			$_result['result']=0;
			$_result['msg']=$matches[1];
			$_result['data']=array();
		}
		echo json_encode($_result);
	}

	function appPubAdd(){
		global $_CONFIG;
		if(($data=$this->process_postdata())===false){
			return ;
		}
		$_POST['sessionluser'] = 'APPPUBEDIT_LUSER';
		$_POST['sessionlgroup'] = 'APPPUBEDIT_LGROUP';
		$data['autologinflag']=$data['programid'];
		$data['repassword']=$data['password'];
		$_POST = $data;
		$_GET['id']=$data['id'];
		$_POST['member']=$data['users'];
		$_POST['group']=$data['groups'];
		require_once(ROOT ."./controller/c_admin_config.class.php");	
		$newpro = new c_admin_config();
		$newpro->init($this->smarty, $this->config);
		ob_start();
		$id=$newpro->apppub_save();
		$result = ob_get_clean();
		$r = preg_match("/<script language='javascript'>alert\(['\"](.*?)['\"]\);/", $result, $matches);
		if(strpos($matches[1], '成功')!==false){
			$apppubinfo = $this->apppub_set->select_by_id($id);
			$appdeviceinfo = $this->appdevice_set->select_all('apppubid='.$apppubinfo['id']);
			$appdeviceinfo = $appdeviceinfo[0];
			$appdeviceinfo['old_password']=$this->appdevice_set->udf_decrypt($appdeviceinfo['old_password']);
			$appdeviceinfo['cur_password']=$this->appdevice_set->udf_decrypt($appdeviceinfo['cur_password']);
			unset($appdeviceinfo['id']);
			unset($appdeviceinfo['desc']);

			$_result['result']=1;
			$_result['msg']='操作成功';
			$_result['data']=array_merge($apppubinfo, $appdeviceinfo);
		}else{
			$_result['result']=0;
			$_result['msg']=$matches[1];
			$_result['data']=array();
		}
		echo json_encode($_result);
	}

	function appPubDel(){
		global $_CONFIG;
		if(($data=$this->process_postdata())===false){
			return ;
		}
		$_POST = $data;
		$_POST['chk_member']=$data['id'];
		require_once(ROOT ."./controller/c_admin_config.class.php");	
		$newpro = new c_admin_config();
		$newpro->init($this->smarty, $this->config);
		ob_start();
		$newpro->apppub_delete();
		$result = ob_get_clean();
		$r = preg_match("/<script language='javascript'>alert\(['\"](.*?)['\"]\);/", $result, $matches);
		if(strpos($matches[1], '成功')!==false){
			$_result['result']=1;
			$_result['msg']='操作成功';
			$_result['data']=array();
		}else{
			$_result['result']=0;
			$_result['msg']=$matches[1];
			$_result['data']=array();
		}
		echo json_encode($_result);
	}

	function appPubList(){
		global $_CONFIG;
		if(($data=$this->process_postdata())===false){
			return ;
		}
		$_GET = $data;
		$_GET['derive']=0;
		$this->config['site']['items_per_page']=$_GET['items_per_page'];
		require_once(ROOT ."./controller/c_admin_config.class.php");	
		$newpro = new c_admin_config();
		$newpro->init($this->smarty, $this->config);
		ob_start();
		$datas=$newpro->apppub_list(true);
		$result = ob_get_clean();
		$r = preg_match("/<script language='javascript'>alert\(['\"](.*?)['\"]\);/", $result, $matches);
		if($r==0){
			$_result['result']=1;
			$_result['msg']='操作成功';
			$_result['data']=$datas;
		}else{
			$_result['result']=0;
			$_result['msg']=$matches[1];
			$_result['data']=array();
		}
		echo json_encode($_result);
	}

	function asyncAccount(){
		global $_CONFIG;
		if(($data=$this->process_postdata())===false){
			return ;
		}
		$_POST = $data;
		$_GET['ip']=$data['appserverip'];
		unset($data['appserverip']);
		require_once(ROOT ."./controller/c_admin_pro.class.php");	
		$newpro = new c_admin_pro();
		$newpro->init($this->smarty, $this->config);
		ob_start();
		$newpro->async_account();
		$result = ob_get_clean();
		if(strpos($result, '成功')!==false){
			$_result['result']=1;
			$_result['msg']=$result;
			$_result['data']=array();
		}else{
			$_result['result']=0;
			$_result['msg']=$result;
			$_result['data']=array();
		}
		echo json_encode($_result);
	}

	function asyncConfig(){
		global $_CONFIG;
		if(($data=$this->process_postdata())===false){
			return ;
		}
		$_POST = $data;
		$_GET['ip']=$data['appserverip'];
		unset($data['appserverip']);
		require_once(ROOT ."./controller/c_admin_pro.class.php");	
		$newpro = new c_admin_pro();
		$newpro->init($this->smarty, $this->config);
		ob_start();
		$newpro->async_config();
		$result = ob_get_clean();
		if(strpos($result, '成功')!==false){
			$_result['result']=1;
			$_result['msg']=$result;
			$_result['data']=array();
		}else{
			$_result['result']=0;
			$_result['msg']=$result;
			$_result['data']=array();
		}
		echo json_encode($_result);
	}

	function apploginSave(){
		global $_CONFIG;
		if(($data=$this->process_postdata())===false){
			return ;
		}
		$_POST = $data;
		$p = $this->applogin_set->select_all("appdeviceid=".$data['appdeviceid']);
		$_POST['id']=$p[0]['uid'];
		$_GET['appdeviceid']=$data['appdeviceid'];
		$_GET['ip']=$data['appserverip'];
		$_GET['device_ip']=$data['device_ip'];
		unset($data['id']);
		unset($data['appserverip']);
		unset($data['device_ip']);
		require_once(ROOT ."./controller/c_admin_app.class.php");	
		$newpro = new c_admin_app();
		$newpro->init($this->smarty, $this->config);
		ob_start();
		$id=$newpro->applogin_save();
		$result = ob_get_clean();
		$r = preg_match("/<script language='javascript'>alert\(['\"](.*?)['\"]\);/", $result, $matches);
		if(strpos($matches[1], '成功')!==false){
			$_result['result']=1;
			$_result['msg']='操作成功';
			$_result['data']=$this->applogin_set->select_by_id($id);
		}else{
			$_result['result']=0;
			$_result['msg']=$matches[1];
			$_result['data']=array();
		}
		echo json_encode($_result);
	}

	function appLogin(){
		global $_CONFIG;
		if(($data=$this->process_postdata())===false){
			return ;
		}
		$_POST = $data;
		$_GET['id']=$data['appdeviceid'];
		$_GET['appserverip']=$data['appserverip'];
		unset($data['appserverip']);
		require_once(ROOT ."./controller/c_admin_app.class.php");	
		$newpro = new c_admin_app();
		$newpro->init($this->smarty, $this->config);
		ob_start();
		$data=$newpro->applogin(true);
		$result = ob_get_clean();
		$r = preg_match("/<script language='javascript'>alert\(['\"](.*?)['\"]\);/", $result, $matches);
		if($r==0){
			$_result['result']=1;
			$_result['msg']='操作成功';
			$_result['data']=$data;
		}else{
			$_result['result']=0;
			$_result['msg']=$res;
			$_result['data']=array();
		}
		echo json_encode($_result);
	}

	function license(){
		global $_CONFIG;
		if(($data=$this->process_postdata())===false){
			return ;
		}
		$_GET = $data;
		$_GET['derive']=0;
		$this->config['site']['items_per_page']=$_GET['items_per_page'];
		require_once(ROOT ."./controller/c_admin_index.class.php");	
		$newpro = new c_admin_index();
		$newpro->init($this->smarty, $this->config);
		ob_start();
		$datas=$newpro->license(true);
		$result = ob_get_clean();
		$r = preg_match("/<script language='javascript'>alert\(['\"](.*?)['\"]\);/", $result, $matches);
		$_result['result']=1;
		$_result['msg']='操作成功';
		$_result['info']=$matches[1];
		$_result['data']=$datas;
		echo json_encode($_result);
	}

	function uploadLicense(){
		global $_CONFIG;
		if(($data=$this->process_postdata())===false){
			return ;
		}
		$data = json_decode($_POST['data'], true);
		if(file_put_contents('/opt/freesvr/audit/etc/licenses.key', $data['content'])){
			$_result['result']=1;
			$_result['msg']='操作成功';
			$_result['data']=array();	
		}else{
			$_result['result']=0;
			$_result['msg']='操作失败，请检查文件/opt/freesvr/audit/etc/licenses.key权限';
			$_result['data']=array();	
		}
		
		echo json_encode($_result);
	}



	function createLicense(){
		global $_CONFIG;
		if(($data=$this->process_postdata())===false){
			return ;
		}
		$_GET = $data;
		$_GET['derive']=0;
		$this->config['site']['items_per_page']=$_GET['items_per_page'];
		require_once(ROOT ."./controller/c_admin_index.class.php");	
		$newpro = new c_admin_index();
		$newpro->init($this->smarty, $this->config);
		ob_start();
		$datas=$newpro->create_license(true);
		$result = ob_get_clean();
		$_result['result']=1;
		$_result['msg']='操作成功';
		$_result['data']=$datas;
		echo json_encode($_result);
	}

	
}
?>
