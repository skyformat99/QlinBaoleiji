<?php /* Smarty version 3.1.27, created on 2017-06-26 12:10:39
         compiled from "/opt/freesvr/web/htdocs/freesvr/audit/template/admin/workflow_approve.tpl" */ ?>
<?php
/*%%SmartyHeaderCode:11654867755950893f0f2268_14034529%%*/
if(!defined('SMARTY_DIR')) exit('no direct access allowed');
$_valid = $_smarty_tpl->decodeProperties(array (
  'file_dependency' => 
  array (
    '71d21b8d5938415047d07ba6d59e8852ad172852' => 
    array (
      0 => '/opt/freesvr/web/htdocs/freesvr/audit/template/admin/workflow_approve.tpl',
      1 => 1485177677,
      2 => 'file',
    ),
  ),
  'nocache_hash' => '11654867755950893f0f2268_14034529',
  'variables' => 
  array (
    'title' => 0,
    'template_root' => 0,
    'members' => 0,
    'gid' => 0,
    'backupdb_id' => 0,
    'orderby2' => 0,
    's' => 0,
    'total' => 0,
    'page_list' => 0,
    'curr_page' => 0,
    'total_page' => 0,
    'items_per_page' => 0,
  ),
  'has_nocache_code' => false,
  'version' => '3.1.27',
  'unifunc' => 'content_5950893f263621_73770099',
),false);
/*/%%SmartyHeaderCode%%*/
if ($_valid && !is_callable('content_5950893f263621_73770099')) {
function content_5950893f263621_73770099 ($_smarty_tpl) {
if (!is_callable('smarty_modifier_truncate_cn')) require_once '/opt/freesvr/web/htdocs/freesvr/audit/smarty/plugins/modifier.truncate_cn.php';

$_smarty_tpl->properties['nocache_hash'] = '11654867755950893f0f2268_14034529';
?>
<!doctype html public "-//w3c//dtd html 4.0 transitional//en">
<html>
<head>
<title><?php echo $_smarty_tpl->tpl_vars['title']->value;?>
</title>
<meta name="generator" content="editplus">
<meta name="author" content="nuttycoder">
<link href="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/all_purpose_style.css" rel="stylesheet" type="text/css" />
<?php echo '<script'; ?>
 type="text/javascript" src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/cssjs/jquery-1.10.2.min.js"><?php echo '</script'; ?>
>

<?php echo '<script'; ?>
 src="./template/admin/cssjs/jscal2.js"><?php echo '</script'; ?>
>
<?php echo '<script'; ?>
 src="./template/admin/cssjs/cn.js"><?php echo '</script'; ?>
>
<link type="text/css" rel="stylesheet" href="./template/admin/cssjs/jscal2.css" />
<link type="text/css" rel="stylesheet" href="./template/admin/cssjs/border-radius.css" />
<?php echo '<script'; ?>
 type="text/javascript">
var isIe=(document.all)?true:false;
function closeWindow()
{
	if(document.getElementById('back')!=null)
	{
		document.getElementById('back').parentNode.removeChild(document.getElementById('back'));
	}
	if(document.getElementById('mesWindow')!=null)
	{
		document.getElementById('mesWindow').parentNode.removeChild(document.getElementById('mesWindow'));
	}
	document.getElementById('fade').style.display='none';
}

function showImg(wTitle, c, width)
{
	closeWindow();
	//var pos = mousePosition(ev);
	var wWidth=400;
	var wHeight=240;
	var bWidth=parseInt(w=window.innerWidth|| document.documentElement.clientWidth|| document.body.clientWidth);

	var bHeight=parseInt(window.innerHeight|| document.documentElement.clientHeight|| document.body.clientHeight)+20;
	bHeight=700+20;
	var back=document.createElement("div");
	back.id="back";
	var styleStr="top:0px;left:0px;position:absolute;width:"+bWidth+"px;height:"+bHeight+"px;z-index:1002;";
	//styleStr+=(isIe)?"filter:alpha(opacity=0);":"opacity:0;";
	back.style.cssText=styleStr;
	document.body.appendChild(back);
	var mesW=document.createElement("div");
	mesW.id="mesWindow";
	mesW.className="mesWindow";
	mesW.innerHTML='<div id="light" class="white_content" style="height:240px;width:'+width+'px"><table width="100%" border="0" cellspacing="0" cellpadding="0"><tr><td bgcolor="#eeeeee" align="right" height="25"><a href="javascript:void(0)" onclick="closeWindow()">关闭</a></td></tr></table>'+c+"</div>";
	//styleStr="left:"+(((pos.x-wWidth)>0)?(pos.x-wWidth):pos.x)+"px;top:"+(pos.y)+"px;position:absolute;width:"+wWidth+"px;";//鼠标点击位置
	//styleStr="left:"+(bWidth-wWidth)/2+"px;top:"+(bHeight-wHeight)/2+"px;position:absolute;width:"+wWidth+"px;";//屏幕中间
	mesW.style.cssText=styleStr;
	document.body.appendChild(mesW);
	//window.parent.document.getElementById("frame_content").height=pos.y+1000;
	//window.parent.parent.document.getElementById("main").height=bHeight+1000;	
	
	document.getElementById('fade').style.display='block'
	return false;
}
function loadurl(url,width){
	$.get(url, {Action:"get",Name:"lulu","1":Math.round(new Date().getTime()/1000)}, function (data, textStatus){
		this; // 在这里this指向的是Ajax请求的选项配置信息，请参考下图
		//alert(data);
		showImg('',data,width);
	});
}

var AllMembers = new Array();
var i=0;
<?php if (isset($_smarty_tpl->tpl_vars['smarty']->value['section']['kk'])) unset($_smarty_tpl->tpl_vars['smarty']->value['section']['kk']);
$_smarty_tpl->tpl_vars['smarty']->value['section']['kk']['name'] = 'kk';
$_smarty_tpl->tpl_vars['smarty']->value['section']['kk']['loop'] = is_array($_loop=$_smarty_tpl->tpl_vars['members']->value) ? count($_loop) : max(0, (int) $_loop); unset($_loop);
$_smarty_tpl->tpl_vars['smarty']->value['section']['kk']['show'] = true;
$_smarty_tpl->tpl_vars['smarty']->value['section']['kk']['max'] = $_smarty_tpl->tpl_vars['smarty']->value['section']['kk']['loop'];
$_smarty_tpl->tpl_vars['smarty']->value['section']['kk']['step'] = 1;
$_smarty_tpl->tpl_vars['smarty']->value['section']['kk']['start'] = $_smarty_tpl->tpl_vars['smarty']->value['section']['kk']['step'] > 0 ? 0 : $_smarty_tpl->tpl_vars['smarty']->value['section']['kk']['loop']-1;
if ($_smarty_tpl->tpl_vars['smarty']->value['section']['kk']['show']) {
    $_smarty_tpl->tpl_vars['smarty']->value['section']['kk']['total'] = $_smarty_tpl->tpl_vars['smarty']->value['section']['kk']['loop'];
    if ($_smarty_tpl->tpl_vars['smarty']->value['section']['kk']['total'] == 0)
        $_smarty_tpl->tpl_vars['smarty']->value['section']['kk']['show'] = false;
} else
    $_smarty_tpl->tpl_vars['smarty']->value['section']['kk']['total'] = 0;
if ($_smarty_tpl->tpl_vars['smarty']->value['section']['kk']['show']):

            for ($_smarty_tpl->tpl_vars['smarty']->value['section']['kk']['index'] = $_smarty_tpl->tpl_vars['smarty']->value['section']['kk']['start'], $_smarty_tpl->tpl_vars['smarty']->value['section']['kk']['iteration'] = 1;
                 $_smarty_tpl->tpl_vars['smarty']->value['section']['kk']['iteration'] <= $_smarty_tpl->tpl_vars['smarty']->value['section']['kk']['total'];
                 $_smarty_tpl->tpl_vars['smarty']->value['section']['kk']['index'] += $_smarty_tpl->tpl_vars['smarty']->value['section']['kk']['step'], $_smarty_tpl->tpl_vars['smarty']->value['section']['kk']['iteration']++):
$_smarty_tpl->tpl_vars['smarty']->value['section']['kk']['rownum'] = $_smarty_tpl->tpl_vars['smarty']->value['section']['kk']['iteration'];
$_smarty_tpl->tpl_vars['smarty']->value['section']['kk']['index_prev'] = $_smarty_tpl->tpl_vars['smarty']->value['section']['kk']['index'] - $_smarty_tpl->tpl_vars['smarty']->value['section']['kk']['step'];
$_smarty_tpl->tpl_vars['smarty']->value['section']['kk']['index_next'] = $_smarty_tpl->tpl_vars['smarty']->value['section']['kk']['index'] + $_smarty_tpl->tpl_vars['smarty']->value['section']['kk']['step'];
$_smarty_tpl->tpl_vars['smarty']->value['section']['kk']['first']      = ($_smarty_tpl->tpl_vars['smarty']->value['section']['kk']['iteration'] == 1);
$_smarty_tpl->tpl_vars['smarty']->value['section']['kk']['last']       = ($_smarty_tpl->tpl_vars['smarty']->value['section']['kk']['iteration'] == $_smarty_tpl->tpl_vars['smarty']->value['section']['kk']['total']);
?>
AllMembers[i++]={uid:<?php echo $_smarty_tpl->tpl_vars['members']->value[$_smarty_tpl->getVariable('smarty')->value['section']['kk']['index']]['uid'];?>
, username:'<?php echo $_smarty_tpl->tpl_vars['members']->value[$_smarty_tpl->getVariable('smarty')->value['section']['kk']['index']]['username'];?>
'};
<?php endfor; endif; ?>
function filter(){
	var filterStr = document.getElementById('filtertext').value;
	var username = document.getElementById('username');
	username.options.length=1;
	for(var i=0; i<AllMembers.length;i++){
		if(filterStr.length==0 || AllMembers[i]['username'].indexOf(filterStr) >= 0){
			username.options[username.options.length++] = new Option(AllMembers[i]['username'],AllMembers[i]['uid']);
		}
	}
}

var cansub = true;
function check_userpriority(devicesid, uid){
	cansub = false;
	$.get('admin.php?controller=admin_workflow&action=check_userpriority&uid='+uid+'&devicesid='+devicesid, {Action:"get",Name:"lulu","1":Math.round(new Date().getTime()/1000)}, function (data, textStatus){
		this; // 在这里this指向的是Ajax请求的选项配置信息，请参考下图
		//alert(data);
		if(data==1){
			cansub = true;
		}
	});
}

function cansubmit(){
	if(cansub==false&&confirm('该用户没有权限,是否要继续并为该用户添加权限？')){
		return true;
	}
	return cansub;
}
function changeStyle(obj,c)
{
	if(c!='o'){
		obj.style.backgroundColor=c;
	}else{
		obj.style.backgroundColor="#FFCC80";
	}
}
<?php echo '</script'; ?>
>
</head>

<body>
<div id="fade" class="black_overlay"></div> 
<style type="text/css">
a {
    color: #003499;
    text-decoration: none;
} 
a:hover {
    color: #000000;
    text-decoration: underline;
}
</style>
<td width="84%" align="left" valign="top"><table width="100%" border="0" cellspacing="0" cellpadding="0"><tr><td valign="middle" class="hui_bj"><div class="menu">
<ul>
<?php if ($_SESSION['ADMIN_LEVEL'] == 0) {?>
<li class=<?php if ($_GET['logintype']) {?>"me_b"<?php } else { ?>"me_a"<?php }?>><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an1<?php if ($_GET['logintype']) {?>1<?php }?>.jpg" align="absmiddle"/><a href="admin.php?controller=admin_index&action=main&gid=<?php echo $_smarty_tpl->tpl_vars['gid']->value;?>
&all=1">设备列表</a><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an3<?php if ($_GET['logintype']) {?>3<?php }?>.jpg" align="absmiddle"/></li>
<li class=<?php if ($_GET['logintype'] != '_apppub' && $_GET['logintype'] != 'apppub') {?>"me_b"<?php } else { ?>"me_a"<?php }?>><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an1<?php if ($_GET['logintype'] != '_apppub' && $_GET['logintype'] != 'apppub') {?>1<?php }?>.jpg" align="absmiddle"/><a href="admin.php?controller=admin_index&action=main&logintype=_apppub&gid=<?php echo $_smarty_tpl->tpl_vars['gid']->value;?>
">应用列表</a><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an3<?php if ($_GET['logintype'] != '_apppub' && $_GET['logintype'] != 'apppub') {?>3<?php }?>.jpg" align="absmiddle"/></li>
<li class=<?php if ($_GET['logintype'] != 'ssh') {?>"me_b"<?php } else { ?>"me_a"<?php }?>><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an1<?php if ($_GET['logintype'] != 'ssh') {?>1<?php }?>.jpg" align="absmiddle"/><a href="admin.php?controller=admin_index&action=main&logintype=ssh&gid=<?php echo $_smarty_tpl->tpl_vars['gid']->value;?>
">SSH设备</a><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an3<?php if ($_GET['logintype'] != 'ssh') {?>3<?php }?>.jpg" align="absmiddle"/></li>
<li class=<?php if ($_GET['logintype'] != 'telnet') {?>"me_b"<?php } else { ?>"me_a"<?php }?>><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an1<?php if ($_GET['logintype'] != 'telnet') {?>1<?php }?>.jpg" align="absmiddle"/><a href="admin.php?controller=admin_index&action=main&logintype=telnet&gid=<?php echo $_smarty_tpl->tpl_vars['gid']->value;?>
">TELNET设备</a><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an3<?php if ($_GET['logintype'] != 'telnet') {?>3<?php }?>.jpg" align="absmiddle"/></li>
<li class=<?php if ($_GET['logintype'] != 'rdp') {?>"me_b"<?php } else { ?>"me_a"<?php }?>><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an1<?php if ($_GET['logintype'] != 'rdp') {?>1<?php }?>.jpg" align="absmiddle"/><a href="admin.php?controller=admin_index&action=main&logintype=rdp&gid=<?php echo $_smarty_tpl->tpl_vars['gid']->value;?>
">RDP设备</a><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an3<?php if ($_GET['logintype'] != 'rdp') {?>3<?php }?>.jpg" align="absmiddle"/></li>
<li class=<?php if ($_GET['logintype'] != 'vnc') {?>"me_b"<?php } else { ?>"me_a"<?php }?>><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an1<?php if ($_GET['logintype'] != 'vnc') {?>1<?php }?>.jpg" align="absmiddle"/><a href="admin.php?controller=admin_index&action=main&logintype=vnc&gid=<?php echo $_smarty_tpl->tpl_vars['gid']->value;?>
">VNC设备</a><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an3<?php if ($_GET['logintype'] != 'vnc') {?>3<?php }?>.jpg" align="absmiddle"/></li>
<li class=<?php if ($_GET['logintype'] != 'ftp') {?>"me_b"<?php } else { ?>"me_a"<?php }?>><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an1<?php if ($_GET['logintype'] != 'ftp') {?>1<?php }?>.jpg" align="absmiddle"/><a href="admin.php?controller=admin_index&action=main&logintype=ftp&gid=<?php echo $_smarty_tpl->tpl_vars['gid']->value;?>
">FTP设备</a><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an3<?php if ($_GET['logintype'] != 'ftp') {?>3<?php }?>.jpg" align="absmiddle"/></li>
<li class=<?php if ($_GET['logintype'] != 'x11') {?>"me_b"<?php } else { ?>"me_a"<?php }?>><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an1<?php if ($_GET['logintype'] != 'x11') {?>1<?php }?>.jpg" align="absmiddle"/><a href="admin.php?controller=admin_index&action=main&logintype=x11">X11设备</a><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an3<?php if ($_GET['logintype'] != 'x11') {?>3<?php }?>.jpg" align="absmiddle"/></li>

<li class=me_b><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an11.jpg" align="absmiddle"/><a href="admin.php?controller=admin_workflow&action=workflow">运维流程</a><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an33.jpg" align="absmiddle"/></li>

<?php } elseif ($_SESSION['ADMIN_LEVEL'] == 10 || $_SESSION['ADMIN_LEVEL'] == 101) {?>
<li class="me_a"><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an1.jpg" align="absmiddle"/><a href="admin.php?controller=admin_index&action=main">密码查看</a><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an3.jpg" align="absmiddle"/></li>
<?php if ($_SESSION['ADMIN_LEVEL'] == 10) {?>
<li class="me_b"><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an11.jpg" align="absmiddle"/><a href="admin.php?controller=admin_pro&action=passwordedit">修改密码</a><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an33.jpg" align="absmiddle"/></li>

<li class="me_b"><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an11.jpg" align="absmiddle"/><a href="admin.php?controller=admin_pro&action=password_cron">定时任务</a><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an33.jpg" align="absmiddle"/></li>
<li class="me_b"><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an11.jpg" align="absmiddle"/><a href="admin.php?controller=admin_backup&action=backup_setting_forpassword">自动备份</a><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an33.jpg" align="absmiddle"/></li>
<li class="me_b"><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an11.jpg" align="absmiddle"/><a href="admin.php?controller=admin_index&action=passdown">密码文件下载</a><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an33.jpg" align="absmiddle"/></li>
<li class="me_b"><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an11.jpg" align="absmiddle"/><a href="admin.php?controller=admin_pro&action=passwordcheck">密码校验</a><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an33.jpg" align="absmiddle"/></li>

<?php }?>
<?php } else { ?>
<li class="me_b"><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an11.jpg" align="absmiddle"/><a href="admin.php?controller=admin_session&backupdb_id=<?php echo $_smarty_tpl->tpl_vars['backupdb_id']->value;?>
">Telnet/SSH</a><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an33.jpg" align="absmiddle"/></li>
<li class="me_b"><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an11.jpg" align="absmiddle"/><a href="admin.php?controller=admin_sftp&backupdb_id=<?php echo $_smarty_tpl->tpl_vars['backupdb_id']->value;?>
">SFTP</a><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an33.jpg" align="absmiddle"/></li> 
<li class="me_b"><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an11.jpg" align="absmiddle"/><a href="admin.php?controller=admin_scp&backupdb_id=<?php echo $_smarty_tpl->tpl_vars['backupdb_id']->value;?>
">SCP</a><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an33.jpg" align="absmiddle"/></li> 
<li class="me_b"><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an11.jpg" align="absmiddle"/><a href="admin.php?controller=admin_ftp&backupdb_id=<?php echo $_smarty_tpl->tpl_vars['backupdb_id']->value;?>
">FTP</a><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an33.jpg" align="absmiddle"/></li> 
<li class="me_b"><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an11.jpg" align="absmiddle"/><a href="admin.php?controller=admin_rdp&backupdb_id=<?php echo $_smarty_tpl->tpl_vars['backupdb_id']->value;?>
">RDP</a><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an33.jpg" align="absmiddle"/></li> 
<li class="me_b"><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an11.jpg" align="absmiddle"/><a href="admin.php?controller=admin_vnc&backupdb_id=<?php echo $_smarty_tpl->tpl_vars['backupdb_id']->value;?>
">VNC</a><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an33.jpg" align="absmiddle"/></li>
<?php if ($_smarty_tpl->tpl_vars['backupdb_id']->value) {?>
<li class="me_b"><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an11.jpg" align="absmiddle"/><a href="admin.php?controller=admin_apppub&backupdb_id=<?php echo $_smarty_tpl->tpl_vars['backupdb_id']->value;?>
">应用发布</a><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an33.jpg" align="absmiddle"/></li>
<?php }?>
<li class="me_b"><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an11.jpg" align="absmiddle"/><a href="admin.php?controller=admin_x11&backupdb_id=<?php echo $_smarty_tpl->tpl_vars['backupdb_id']->value;?>
">X11</a><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an33.jpg" align="absmiddle"/></li> 
<li class="me_a"><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an1.jpg" align="absmiddle"/><a href="admin.php?controller=admin_workflow&action=workflow_approve">流程审批</a><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an3.jpg" align="absmiddle"/></li> 
<?php }?>
</ul>
</div></td></tr>

	
 
  <tr>
	<td class="">
	<table width="100%" border="0" cellspacing="0" cellpadding="0" class="BBtable">
	<form name="ip_list" action="admin.php?controller=admin_workflow&action=workflow_delete" method="post">
                <TBODY>
                  <TR>
			
                    <th class="list_bg" width="5%"><a href="admin.php?controller=admin_workflow&action=workflow_approve&orderby1=groupname&orderby2=<?php echo $_smarty_tpl->tpl_vars['orderby2']->value;?>
" >选</a></TD>
                    <th class="list_bg"  width="8%"><a href="admin.php?controller=admin_workflow&action=workflow_approve&orderby1=username&orderby2=<?php echo $_smarty_tpl->tpl_vars['orderby2']->value;?>
" >申请人</a></TD>
                    <th class="list_bg"  width="13%"><a href="admin.php?controller=admin_workflow&action=workflow_approve&orderby1=dateline&orderby2=<?php echo $_smarty_tpl->tpl_vars['orderby2']->value;?>
" >申请时间</a></TD>
                    <th class="list_bg"  width="6%"><a href="admin.php?controller=admin_workflow&action=workflow_approve&orderby1=device_ip&orderby2=<?php echo $_smarty_tpl->tpl_vars['orderby2']->value;?>
" >设备IP</a></TD>
                    <th class="list_bg"  width="6%"><a href="admin.php?controller=admin_workflow&action=workflow_approve&orderby1=username&orderby2=<?php echo $_smarty_tpl->tpl_vars['orderby2']->value;?>
" >用户名</a></TD>
                    <th class="list_bg"  width="8%"><a href="admin.php?controller=admin_workflow&action=workflow_approve&orderby1=login_method&orderby2=<?php echo $_smarty_tpl->tpl_vars['orderby2']->value;?>
" >登录方式</a></TD>
                    <th class="list_bg"  width="10%"><a href="admin.php?controller=admin_workflow&action=workflow_approve&orderby1=name&orderby2=<?php echo $_smarty_tpl->tpl_vars['orderby2']->value;?>
" >操作内容</a></TD>
					<th class="list_bg"  width="13%"><a href="admin.php?controller=admin_workflow&action=workflow_approve&orderby1=dateline&orderby2=<?php echo $_smarty_tpl->tpl_vars['orderby2']->value;?>
" >申请时间</a></TD>
                    <th class="list_bg"  width="10%"><a href="admin.php?controller=admin_workflow&action=workflow_approve&orderby1=desc&orderby2=<?php echo $_smarty_tpl->tpl_vars['orderby2']->value;?>
" >描述</a></TD>
                    <th class="list_bg"  width="6%"><a href="admin.php?controller=admin_workflow&action=workflow_approve&orderby1=status&orderby2=<?php echo $_smarty_tpl->tpl_vars['orderby2']->value;?>
" >流程状态</a></TD>
					<th class="list_bg" >操作</TD>
                  </TR>

            </tr>
			<?php if (isset($_smarty_tpl->tpl_vars['smarty']->value['section']['t'])) unset($_smarty_tpl->tpl_vars['smarty']->value['section']['t']);
$_smarty_tpl->tpl_vars['smarty']->value['section']['t']['name'] = 't';
$_smarty_tpl->tpl_vars['smarty']->value['section']['t']['loop'] = is_array($_loop=$_smarty_tpl->tpl_vars['s']->value) ? count($_loop) : max(0, (int) $_loop); unset($_loop);
$_smarty_tpl->tpl_vars['smarty']->value['section']['t']['show'] = true;
$_smarty_tpl->tpl_vars['smarty']->value['section']['t']['max'] = $_smarty_tpl->tpl_vars['smarty']->value['section']['t']['loop'];
$_smarty_tpl->tpl_vars['smarty']->value['section']['t']['step'] = 1;
$_smarty_tpl->tpl_vars['smarty']->value['section']['t']['start'] = $_smarty_tpl->tpl_vars['smarty']->value['section']['t']['step'] > 0 ? 0 : $_smarty_tpl->tpl_vars['smarty']->value['section']['t']['loop']-1;
if ($_smarty_tpl->tpl_vars['smarty']->value['section']['t']['show']) {
    $_smarty_tpl->tpl_vars['smarty']->value['section']['t']['total'] = $_smarty_tpl->tpl_vars['smarty']->value['section']['t']['loop'];
    if ($_smarty_tpl->tpl_vars['smarty']->value['section']['t']['total'] == 0)
        $_smarty_tpl->tpl_vars['smarty']->value['section']['t']['show'] = false;
} else
    $_smarty_tpl->tpl_vars['smarty']->value['section']['t']['total'] = 0;
if ($_smarty_tpl->tpl_vars['smarty']->value['section']['t']['show']):

            for ($_smarty_tpl->tpl_vars['smarty']->value['section']['t']['index'] = $_smarty_tpl->tpl_vars['smarty']->value['section']['t']['start'], $_smarty_tpl->tpl_vars['smarty']->value['section']['t']['iteration'] = 1;
                 $_smarty_tpl->tpl_vars['smarty']->value['section']['t']['iteration'] <= $_smarty_tpl->tpl_vars['smarty']->value['section']['t']['total'];
                 $_smarty_tpl->tpl_vars['smarty']->value['section']['t']['index'] += $_smarty_tpl->tpl_vars['smarty']->value['section']['t']['step'], $_smarty_tpl->tpl_vars['smarty']->value['section']['t']['iteration']++):
$_smarty_tpl->tpl_vars['smarty']->value['section']['t']['rownum'] = $_smarty_tpl->tpl_vars['smarty']->value['section']['t']['iteration'];
$_smarty_tpl->tpl_vars['smarty']->value['section']['t']['index_prev'] = $_smarty_tpl->tpl_vars['smarty']->value['section']['t']['index'] - $_smarty_tpl->tpl_vars['smarty']->value['section']['t']['step'];
$_smarty_tpl->tpl_vars['smarty']->value['section']['t']['index_next'] = $_smarty_tpl->tpl_vars['smarty']->value['section']['t']['index'] + $_smarty_tpl->tpl_vars['smarty']->value['section']['t']['step'];
$_smarty_tpl->tpl_vars['smarty']->value['section']['t']['first']      = ($_smarty_tpl->tpl_vars['smarty']->value['section']['t']['iteration'] == 1);
$_smarty_tpl->tpl_vars['smarty']->value['section']['t']['last']       = ($_smarty_tpl->tpl_vars['smarty']->value['section']['t']['iteration'] == $_smarty_tpl->tpl_vars['smarty']->value['section']['t']['total']);
?>
			<tr  <?php if ($_smarty_tpl->getVariable('smarty')->value['section']['t']['index']%2 == 0) {?>bgcolor="f7f7f7"<?php }?> onmouseover="changeStyle(this,'o');" onmouseout="changeStyle(this,'<?php if ($_smarty_tpl->getVariable('smarty')->value['section']['t']['index']%2 == 0) {?>f7f7f7<?php }?>');">
				<td width="5%"><?php echo $_smarty_tpl->getVariable('smarty')->value['section']['t']['index']+1;?>
</td>
				<td> <?php echo $_smarty_tpl->tpl_vars['s']->value[$_smarty_tpl->getVariable('smarty')->value['section']['t']['index']]['muname'];?>
</td>
				<td> <?php echo $_smarty_tpl->tpl_vars['s']->value[$_smarty_tpl->getVariable('smarty')->value['section']['t']['index']]['dateline'];?>
</td>
				<td> <?php echo $_smarty_tpl->tpl_vars['s']->value[$_smarty_tpl->getVariable('smarty')->value['section']['t']['index']]['device_ip'];?>
</td>
				<td> <?php echo $_smarty_tpl->tpl_vars['s']->value[$_smarty_tpl->getVariable('smarty')->value['section']['t']['index']]['username'];?>
</td>
				<td> <?php echo $_smarty_tpl->tpl_vars['s']->value[$_smarty_tpl->getVariable('smarty')->value['section']['t']['index']]['login_method'];?>
</td>
				<td> <?php echo $_smarty_tpl->tpl_vars['s']->value[$_smarty_tpl->getVariable('smarty')->value['section']['t']['index']]['name'];?>
</td>
				<td> <?php echo $_smarty_tpl->tpl_vars['s']->value[$_smarty_tpl->getVariable('smarty')->value['section']['t']['index']]['deadline'];?>
</td>
				<td>  <span title="<?php echo $_smarty_tpl->tpl_vars['s']->value[$_smarty_tpl->getVariable('smarty')->value['section']['t']['index']]['desc'];?>
"><?php echo smarty_modifier_truncate_cn($_smarty_tpl->tpl_vars['s']->value[$_smarty_tpl->getVariable('smarty')->value['section']['t']['index']]['desc'],"20","...");?>
</span></td>
				<td> <a href='#' onclick='loadurl("admin.php?controller=admin_workflow&action=show_workflow_log&wid=<?php echo $_smarty_tpl->tpl_vars['s']->value[$_smarty_tpl->getVariable('smarty')->value['section']['t']['index']]['sid'];?>
", 600);return false;'><?php if (!$_smarty_tpl->tpl_vars['s']->value[$_smarty_tpl->getVariable('smarty')->value['section']['t']['index']]['status']) {?>未审批<?php } elseif ($_smarty_tpl->tpl_vars['s']->value[$_smarty_tpl->getVariable('smarty')->value['section']['t']['index']]['status'] == 1) {?>关单<?php } elseif ($_smarty_tpl->tpl_vars['s']->value[$_smarty_tpl->getVariable('smarty')->value['section']['t']['index']]['status'] == 2) {?>驳回<?php } elseif ($_smarty_tpl->tpl_vars['s']->value[$_smarty_tpl->getVariable('smarty')->value['section']['t']['index']]['status'] == 3) {?>审批中<?php } elseif ($_smarty_tpl->tpl_vars['s']->value[$_smarty_tpl->getVariable('smarty')->value['section']['t']['index']]['status'] == 4) {?>审批完成<?php }?></a></td>
				<td style="TEXT-ALIGN: left;">
				<img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/list_ico1.gif" width="16" height="16" align="absmiddle">
				<?php if ($_smarty_tpl->tpl_vars['s']->value[$_smarty_tpl->getVariable('smarty')->value['section']['t']['index']]['approved'] == 1) {?>已同意 <?php if ($_smarty_tpl->tpl_vars['s']->value[$_smarty_tpl->getVariable('smarty')->value['section']['t']['index']]['apply_status_reject'] == 1) {?><a href="#" onclick="loadurl('admin.php?controller=admin_workflow&action=approvedesc&wid=<?php echo $_smarty_tpl->tpl_vars['s']->value[$_smarty_tpl->getVariable('smarty')->value['section']['t']['index']]['sid'];?>
&status=2');">驳回批准</a><?php }?>
				<?php } elseif ($_smarty_tpl->tpl_vars['s']->value[$_smarty_tpl->getVariable('smarty')->value['section']['t']['index']]['approved'] == 2) {?>驳回
				<?php } elseif ($_smarty_tpl->tpl_vars['s']->value[$_smarty_tpl->getVariable('smarty')->value['section']['t']['index']]['apply_status_priority']) {?><a href="#" onclick="loadurl('admin.php?controller=admin_workflow&action=approvedesc&wid=<?php echo $_smarty_tpl->tpl_vars['s']->value[$_smarty_tpl->getVariable('smarty')->value['section']['t']['index']]['sid'];?>
&status=1');">批准</a>  <a href="#" onclick="loadurl('admin.php?controller=admin_workflow&action=approvedesc&wid=<?php echo $_smarty_tpl->tpl_vars['s']->value[$_smarty_tpl->getVariable('smarty')->value['section']['t']['index']]['sid'];?>
&status=2');">驳回</a><?php }?>
				 
				</td> 
			</tr>
			<?php endfor; endif; ?>
	          <tr>
	           <td  colspan="3" align="left">&nbsp;&nbsp;&nbsp;&nbsp; 
				  
		   		</td>
				<td  colspan="5" align="right">
		   			共<?php echo $_smarty_tpl->tpl_vars['total']->value;?>
个记录  <?php echo $_smarty_tpl->tpl_vars['page_list']->value;?>
  页次：<?php echo $_smarty_tpl->tpl_vars['curr_page']->value;?>
/<?php echo $_smarty_tpl->tpl_vars['total_page']->value;?>
页  <?php echo $_smarty_tpl->tpl_vars['items_per_page']->value;?>
个记录/页  转到第<input name="pagenum" type="text" class="wbk" size="2" onKeyPress="if(event.keyCode==13) window.location='admin.php?controller=admin_workflow&action=dev_group_index&page='+this.value;">页
		   </td>
		   		</tr>
	           
		</TBODY>
              </TABLE></form>	</td>
  </tr>
</table>

<?php echo '<script'; ?>
 language="javascript">

function my_confirm(str){
	if(!confirm(str + "？"))
	{
		window.event.returnValue = false;
	}
}

<?php echo '</script'; ?>
>
</body>
<iframe name="hide" height="0" frameborder="0" scrolling="no"></iframe>
</html>


<?php }
}
?>