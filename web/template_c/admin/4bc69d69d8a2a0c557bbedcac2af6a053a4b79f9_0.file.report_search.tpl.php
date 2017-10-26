<?php /* Smarty version 3.1.27, created on 2017-05-26 07:41:35
         compiled from "/opt/freesvr/web/htdocs/freesvr/audit/template/admin/report_search.tpl" */ ?>
<?php
/*%%SmartyHeaderCode:117922874659276baf9a90c2_06324874%%*/
if(!defined('SMARTY_DIR')) exit('no direct access allowed');
$_valid = $_smarty_tpl->decodeProperties(array (
  'file_dependency' => 
  array (
    '4bc69d69d8a2a0c557bbedcac2af6a053a4b79f9' => 
    array (
      0 => '/opt/freesvr/web/htdocs/freesvr/audit/template/admin/report_search.tpl',
      1 => 1474793220,
      2 => 'file',
    ),
  ),
  'nocache_hash' => '117922874659276baf9a90c2_06324874',
  'variables' => 
  array (
    'language' => 0,
    'template_root' => 0,
    'alluser' => 0,
    'allserver' => 0,
    'trnumber' => 0,
    'years' => 0,
    'f_rangeStart' => 0,
    '_config' => 0,
    'changelevelstr' => 0,
    'schangelevelstr' => 0,
  ),
  'has_nocache_code' => false,
  'version' => '3.1.27',
  'unifunc' => 'content_59276bafa80193_82742178',
),false);
/*/%%SmartyHeaderCode%%*/
if ($_valid && !is_callable('content_59276bafa80193_82742178')) {
function content_59276bafa80193_82742178 ($_smarty_tpl) {
if (!is_callable('smarty_modifier_date_format')) require_once '/opt/freesvr/web/htdocs/freesvr/audit/smarty/plugins/modifier.date_format.php';

$_smarty_tpl->properties['nocache_hash'] = '117922874659276baf9a90c2_06324874';
?>
<!doctype html public "-//w3c//dtd html 4.0 transitional//en">
<html>
<head>
<title><?php echo $_smarty_tpl->tpl_vars['language']->value['LogList'];?>
</title>
<meta name="generator" content="editplus">
<meta name="author" content="nuttycoder">
<link href="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/all_purpose_style.css" rel="stylesheet" type="text/css" />
<?php echo '<script'; ?>
 src="./template/admin/cssjs/global.functions.js"><?php echo '</script'; ?>
>
<?php echo '<script'; ?>
 type="text/javascript" src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/cssjs/jquery-1.10.2.min.js"><?php echo '</script'; ?>
>
<?php echo '<script'; ?>
 type="text/javascript" src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/cssjs/_ajaxdtree.js"><?php echo '</script'; ?>
>
<link href="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/cssjs/dtree.css" rel="stylesheet" type="text/css" />
<link type="text/css" rel="stylesheet" href="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/cssjs/border-radius.css" />
<link type="text/css" rel="stylesheet" href="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/cssjs/jscal2.css" />
<?php echo '<script'; ?>
 src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/cssjs/jscal2.js"><?php echo '</script'; ?>
>
<?php echo '<script'; ?>
 src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/cssjs/cn.js"><?php echo '</script'; ?>
>
<?php echo '<script'; ?>
>
function setScroll(){
	window.parent.scrollTo(0,0);
}

function changelevel(val){
	var ldapid2 = document.getElementById('rtype2');
	ldapid2.options.length = 0;
	switch(val){
		case '1':
			ldapid2.options[ldapid2.options.length] = new Option('变更报表', 'admin_log_statistic');
		break;
		case '2':
			ldapid2.options[ldapid2.options.length] = new Option('登录统计报表', 'login_statistic');
			ldapid2.options[ldapid2.options.length] = new Option('授权明细', 'loginacct_statistic');
			ldapid2.options[ldapid2.options.length] = new Option('登录尝试', 'loginfailed_statistic');
			ldapid2.options[ldapid2.options.length] = new Option('系统登录报表', 'devlogin_statistic');
			ldapid2.options[ldapid2.options.length] = new Option('应用登录报表', 'applogin_statistic');
			ldapid2.options[ldapid2.options.length] = new Option('审批报表', 'loginapproved_statistic');
		break;
		case '3':
			ldapid2.options[ldapid2.options.length] = new Option('命令总计', 'command_statistic');
			ldapid2.options[ldapid2.options.length] = new Option('命令统计', 'cmdcache_statistic');
			ldapid2.options[ldapid2.options.length] = new Option('命令列表', 'cmdlist_statistic');
			ldapid2.options[ldapid2.options.length] = new Option('应用报表', 'app_statistic');
			ldapid2.options[ldapid2.options.length] = new Option('SFTP命令报表', 'sftpcmd_statistic');
			ldapid2.options[ldapid2.options.length] = new Option('FTP命令报表', 'ftpcmd_statistic');
		break;
		case '4':
			ldapid2.options[ldapid2.options.length] = new Option('告警统计', 'dangercmd_statistic');
			ldapid2.options[ldapid2.options.length] = new Option('告警操作', 'dangercmdlist_statistic');
		break;
	}
}

function changetype(val){
	var inputs = document.getElementsByTagName('input');
	for(var i=0; i<inputs.length; i++){
		if(inputs[i].type=='radio' && inputs[i].value==val){
			inputs[i].checked = true;
		}
	}
}

var foundparent = false;
var servergroup = new Array();
var usergroup = new Array();
var alluser = new Array();
var allserver = new Array();
var i=0;
<?php if (isset($_smarty_tpl->tpl_vars['smarty']->value['section']['au'])) unset($_smarty_tpl->tpl_vars['smarty']->value['section']['au']);
$_smarty_tpl->tpl_vars['smarty']->value['section']['au']['name'] = 'au';
$_smarty_tpl->tpl_vars['smarty']->value['section']['au']['loop'] = is_array($_loop=$_smarty_tpl->tpl_vars['alluser']->value) ? count($_loop) : max(0, (int) $_loop); unset($_loop);
$_smarty_tpl->tpl_vars['smarty']->value['section']['au']['show'] = true;
$_smarty_tpl->tpl_vars['smarty']->value['section']['au']['max'] = $_smarty_tpl->tpl_vars['smarty']->value['section']['au']['loop'];
$_smarty_tpl->tpl_vars['smarty']->value['section']['au']['step'] = 1;
$_smarty_tpl->tpl_vars['smarty']->value['section']['au']['start'] = $_smarty_tpl->tpl_vars['smarty']->value['section']['au']['step'] > 0 ? 0 : $_smarty_tpl->tpl_vars['smarty']->value['section']['au']['loop']-1;
if ($_smarty_tpl->tpl_vars['smarty']->value['section']['au']['show']) {
    $_smarty_tpl->tpl_vars['smarty']->value['section']['au']['total'] = $_smarty_tpl->tpl_vars['smarty']->value['section']['au']['loop'];
    if ($_smarty_tpl->tpl_vars['smarty']->value['section']['au']['total'] == 0)
        $_smarty_tpl->tpl_vars['smarty']->value['section']['au']['show'] = false;
} else
    $_smarty_tpl->tpl_vars['smarty']->value['section']['au']['total'] = 0;
if ($_smarty_tpl->tpl_vars['smarty']->value['section']['au']['show']):

            for ($_smarty_tpl->tpl_vars['smarty']->value['section']['au']['index'] = $_smarty_tpl->tpl_vars['smarty']->value['section']['au']['start'], $_smarty_tpl->tpl_vars['smarty']->value['section']['au']['iteration'] = 1;
                 $_smarty_tpl->tpl_vars['smarty']->value['section']['au']['iteration'] <= $_smarty_tpl->tpl_vars['smarty']->value['section']['au']['total'];
                 $_smarty_tpl->tpl_vars['smarty']->value['section']['au']['index'] += $_smarty_tpl->tpl_vars['smarty']->value['section']['au']['step'], $_smarty_tpl->tpl_vars['smarty']->value['section']['au']['iteration']++):
$_smarty_tpl->tpl_vars['smarty']->value['section']['au']['rownum'] = $_smarty_tpl->tpl_vars['smarty']->value['section']['au']['iteration'];
$_smarty_tpl->tpl_vars['smarty']->value['section']['au']['index_prev'] = $_smarty_tpl->tpl_vars['smarty']->value['section']['au']['index'] - $_smarty_tpl->tpl_vars['smarty']->value['section']['au']['step'];
$_smarty_tpl->tpl_vars['smarty']->value['section']['au']['index_next'] = $_smarty_tpl->tpl_vars['smarty']->value['section']['au']['index'] + $_smarty_tpl->tpl_vars['smarty']->value['section']['au']['step'];
$_smarty_tpl->tpl_vars['smarty']->value['section']['au']['first']      = ($_smarty_tpl->tpl_vars['smarty']->value['section']['au']['iteration'] == 1);
$_smarty_tpl->tpl_vars['smarty']->value['section']['au']['last']       = ($_smarty_tpl->tpl_vars['smarty']->value['section']['au']['iteration'] == $_smarty_tpl->tpl_vars['smarty']->value['section']['au']['total']);
?>
alluser[i++]={uid:<?php echo $_smarty_tpl->tpl_vars['alluser']->value[$_smarty_tpl->getVariable('smarty')->value['section']['au']['index']]['uid'];?>
,username:'<?php echo $_smarty_tpl->tpl_vars['alluser']->value[$_smarty_tpl->getVariable('smarty')->value['section']['au']['index']]['username'];?>
',realname:'<?php echo $_smarty_tpl->tpl_vars['alluser']->value[$_smarty_tpl->getVariable('smarty')->value['section']['au']['index']]['realname'];?>
',groupid:<?php echo $_smarty_tpl->tpl_vars['alluser']->value[$_smarty_tpl->getVariable('smarty')->value['section']['au']['index']]['groupid'];?>
,level:<?php echo $_smarty_tpl->tpl_vars['alluser']->value[$_smarty_tpl->getVariable('smarty')->value['section']['au']['index']]['level'];?>
};
<?php endfor; endif; ?>
var i=0;
<?php if (isset($_smarty_tpl->tpl_vars['smarty']->value['section']['as'])) unset($_smarty_tpl->tpl_vars['smarty']->value['section']['as']);
$_smarty_tpl->tpl_vars['smarty']->value['section']['as']['name'] = 'as';
$_smarty_tpl->tpl_vars['smarty']->value['section']['as']['loop'] = is_array($_loop=$_smarty_tpl->tpl_vars['allserver']->value) ? count($_loop) : max(0, (int) $_loop); unset($_loop);
$_smarty_tpl->tpl_vars['smarty']->value['section']['as']['show'] = true;
$_smarty_tpl->tpl_vars['smarty']->value['section']['as']['max'] = $_smarty_tpl->tpl_vars['smarty']->value['section']['as']['loop'];
$_smarty_tpl->tpl_vars['smarty']->value['section']['as']['step'] = 1;
$_smarty_tpl->tpl_vars['smarty']->value['section']['as']['start'] = $_smarty_tpl->tpl_vars['smarty']->value['section']['as']['step'] > 0 ? 0 : $_smarty_tpl->tpl_vars['smarty']->value['section']['as']['loop']-1;
if ($_smarty_tpl->tpl_vars['smarty']->value['section']['as']['show']) {
    $_smarty_tpl->tpl_vars['smarty']->value['section']['as']['total'] = $_smarty_tpl->tpl_vars['smarty']->value['section']['as']['loop'];
    if ($_smarty_tpl->tpl_vars['smarty']->value['section']['as']['total'] == 0)
        $_smarty_tpl->tpl_vars['smarty']->value['section']['as']['show'] = false;
} else
    $_smarty_tpl->tpl_vars['smarty']->value['section']['as']['total'] = 0;
if ($_smarty_tpl->tpl_vars['smarty']->value['section']['as']['show']):

            for ($_smarty_tpl->tpl_vars['smarty']->value['section']['as']['index'] = $_smarty_tpl->tpl_vars['smarty']->value['section']['as']['start'], $_smarty_tpl->tpl_vars['smarty']->value['section']['as']['iteration'] = 1;
                 $_smarty_tpl->tpl_vars['smarty']->value['section']['as']['iteration'] <= $_smarty_tpl->tpl_vars['smarty']->value['section']['as']['total'];
                 $_smarty_tpl->tpl_vars['smarty']->value['section']['as']['index'] += $_smarty_tpl->tpl_vars['smarty']->value['section']['as']['step'], $_smarty_tpl->tpl_vars['smarty']->value['section']['as']['iteration']++):
$_smarty_tpl->tpl_vars['smarty']->value['section']['as']['rownum'] = $_smarty_tpl->tpl_vars['smarty']->value['section']['as']['iteration'];
$_smarty_tpl->tpl_vars['smarty']->value['section']['as']['index_prev'] = $_smarty_tpl->tpl_vars['smarty']->value['section']['as']['index'] - $_smarty_tpl->tpl_vars['smarty']->value['section']['as']['step'];
$_smarty_tpl->tpl_vars['smarty']->value['section']['as']['index_next'] = $_smarty_tpl->tpl_vars['smarty']->value['section']['as']['index'] + $_smarty_tpl->tpl_vars['smarty']->value['section']['as']['step'];
$_smarty_tpl->tpl_vars['smarty']->value['section']['as']['first']      = ($_smarty_tpl->tpl_vars['smarty']->value['section']['as']['iteration'] == 1);
$_smarty_tpl->tpl_vars['smarty']->value['section']['as']['last']       = ($_smarty_tpl->tpl_vars['smarty']->value['section']['as']['iteration'] == $_smarty_tpl->tpl_vars['smarty']->value['section']['as']['total']);
?>
allserver[i++]={hostname:'<?php echo $_smarty_tpl->tpl_vars['allserver']->value[$_smarty_tpl->getVariable('smarty')->value['section']['as']['index']]['hostname'];?>
',device_ip:'<?php echo $_smarty_tpl->tpl_vars['allserver']->value[$_smarty_tpl->getVariable('smarty')->value['section']['as']['index']]['device_ip'];?>
',groupid:<?php echo $_smarty_tpl->tpl_vars['allserver']->value[$_smarty_tpl->getVariable('smarty')->value['section']['as']['index']]['groupid'];?>
};
<?php endfor; endif; ?>

function change_usergroup(val){
	var user = document.getElementById('username');
	user.options.length=0;
	user.options[user.options.length]=new Option('全部', 0);
	for(var i=0; i< alluser.length; i++){
		if(alluser[i].groupid==val){
			user.options[user.options.length] = new Option(alluser[i].username+'('+alluser[i].realname+')', alluser[i].username);
		}
	}
}

function change_servergroup(val){
	var user = document.getElementById('server');
	user.options.length=0;
	user.options[user.options.length]=new Option('全部', 0);
	for(var i=0; i< alluser.length; i++){
		if(alluser[i].groupid==val){
			user.options[user.options.length] = new Option(allserver[i].device_ip+'('+allserver[i].hostname+')', allserver[i].device_ip);
		}
	}
}
<?php echo '</script'; ?>
>
</head>

<body>
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
    <li class="me_a"><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an1.jpg" align="absmiddle"/><a href="admin.php?controller=admin_reports&action=report_search">定期报表</a><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an3.jpg" align="absmiddle"/></li>
	<li class="me_b"><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an11.jpg" align="absmiddle"/><a href="admin.php?controller=admin_reports&action=report_search_diy">自定义报表</a><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an33.jpg" align="absmiddle"/></li>
</ul>
</div></td></tr>  
  <tr>
	<td class="">
<form method="get" name="session_search" action="admin.php?controller=admin_reports&action=doreport_search" >
<input type="hidden" name="controller" value="admin_reports" />
<input type="hidden" name="action" value="doreport_search" />
				<table bordercolor="white" cellspacing="0" cellpadding="0" border="0" width="100%"  class="BBtable">
				 <tr>
    <th class="list_bg" colspan="2"> </th>
  </tr>
					<?php $_smarty_tpl->tpl_vars["trnumber"] = new Smarty_Variable(0, null, 0);?>		
					<tr  <?php if ($_smarty_tpl->tpl_vars['trnumber']->value++%2 == 0) {?>bgcolor="f7f7f7"<?php }?>>
						<td class="td_line" width="20%" align="right">报表类型：</td>
						<td class="td_line" width="80%">
						<select width="30"  class="wbk"  name="rtype1" id="rtype1" onchange="changelevel(this.value)" style="width:100px">
							<OPTION VALUE="1">权限报表</option>	
							<OPTION VALUE="2">登录报表</option>
							<OPTION VALUE="3">操作报表</option>
							<OPTION VALUE="4">告警报表</option>
						</select>
						&nbsp;&nbsp;<select width="30" class="wbk"  name="type" id="rtype2" style="width:100px">
						</select>
						</td>
					</tr>
					<tr  <?php if ($_smarty_tpl->tpl_vars['trnumber']->value++%2 == 0) {?>bgcolor="f7f7f7"<?php }?>>
						<td class="td_line" width="20%" rowspan="3" align="right" >时间选择：</td>
						<td class="td_line" width="80%">
							按月：<input name="dateinterval" type="radio" class="wbk" checked onclick="changetype('month')" value="month">
							&nbsp;&nbsp;年:<select width="30" class="wbk" onclick="changetype('month')"  name="myear" style="width:100px">
							<?php if (isset($_smarty_tpl->tpl_vars['smarty']->value['section']['my'])) unset($_smarty_tpl->tpl_vars['smarty']->value['section']['my']);
$_smarty_tpl->tpl_vars['smarty']->value['section']['my']['name'] = 'my';
$_smarty_tpl->tpl_vars['smarty']->value['section']['my']['loop'] = is_array($_loop=$_smarty_tpl->tpl_vars['years']->value) ? count($_loop) : max(0, (int) $_loop); unset($_loop);
$_smarty_tpl->tpl_vars['smarty']->value['section']['my']['show'] = true;
$_smarty_tpl->tpl_vars['smarty']->value['section']['my']['max'] = $_smarty_tpl->tpl_vars['smarty']->value['section']['my']['loop'];
$_smarty_tpl->tpl_vars['smarty']->value['section']['my']['step'] = 1;
$_smarty_tpl->tpl_vars['smarty']->value['section']['my']['start'] = $_smarty_tpl->tpl_vars['smarty']->value['section']['my']['step'] > 0 ? 0 : $_smarty_tpl->tpl_vars['smarty']->value['section']['my']['loop']-1;
if ($_smarty_tpl->tpl_vars['smarty']->value['section']['my']['show']) {
    $_smarty_tpl->tpl_vars['smarty']->value['section']['my']['total'] = $_smarty_tpl->tpl_vars['smarty']->value['section']['my']['loop'];
    if ($_smarty_tpl->tpl_vars['smarty']->value['section']['my']['total'] == 0)
        $_smarty_tpl->tpl_vars['smarty']->value['section']['my']['show'] = false;
} else
    $_smarty_tpl->tpl_vars['smarty']->value['section']['my']['total'] = 0;
if ($_smarty_tpl->tpl_vars['smarty']->value['section']['my']['show']):

            for ($_smarty_tpl->tpl_vars['smarty']->value['section']['my']['index'] = $_smarty_tpl->tpl_vars['smarty']->value['section']['my']['start'], $_smarty_tpl->tpl_vars['smarty']->value['section']['my']['iteration'] = 1;
                 $_smarty_tpl->tpl_vars['smarty']->value['section']['my']['iteration'] <= $_smarty_tpl->tpl_vars['smarty']->value['section']['my']['total'];
                 $_smarty_tpl->tpl_vars['smarty']->value['section']['my']['index'] += $_smarty_tpl->tpl_vars['smarty']->value['section']['my']['step'], $_smarty_tpl->tpl_vars['smarty']->value['section']['my']['iteration']++):
$_smarty_tpl->tpl_vars['smarty']->value['section']['my']['rownum'] = $_smarty_tpl->tpl_vars['smarty']->value['section']['my']['iteration'];
$_smarty_tpl->tpl_vars['smarty']->value['section']['my']['index_prev'] = $_smarty_tpl->tpl_vars['smarty']->value['section']['my']['index'] - $_smarty_tpl->tpl_vars['smarty']->value['section']['my']['step'];
$_smarty_tpl->tpl_vars['smarty']->value['section']['my']['index_next'] = $_smarty_tpl->tpl_vars['smarty']->value['section']['my']['index'] + $_smarty_tpl->tpl_vars['smarty']->value['section']['my']['step'];
$_smarty_tpl->tpl_vars['smarty']->value['section']['my']['first']      = ($_smarty_tpl->tpl_vars['smarty']->value['section']['my']['iteration'] == 1);
$_smarty_tpl->tpl_vars['smarty']->value['section']['my']['last']       = ($_smarty_tpl->tpl_vars['smarty']->value['section']['my']['iteration'] == $_smarty_tpl->tpl_vars['smarty']->value['section']['my']['total']);
?>
							<option value=<?php echo $_smarty_tpl->tpl_vars['years']->value[$_smarty_tpl->getVariable('smarty')->value['section']['my']['index']];?>
><?php echo $_smarty_tpl->tpl_vars['years']->value[$_smarty_tpl->getVariable('smarty')->value['section']['my']['index']];?>
</option>
							<?php endfor; endif; ?>
							</select>
							&nbsp;&nbsp;月:<select width="30" class="wbk" onclick="changetype('month')"  name="mmonth" style="width:100px">
							<?php if (isset($_smarty_tpl->tpl_vars['smarty']->value['section']['mm'])) unset($_smarty_tpl->tpl_vars['smarty']->value['section']['mm']);
$_smarty_tpl->tpl_vars['smarty']->value['section']['mm']['name'] = 'mm';
$_smarty_tpl->tpl_vars['smarty']->value['section']['mm']['loop'] = is_array($_loop=12) ? count($_loop) : max(0, (int) $_loop); unset($_loop);
$_smarty_tpl->tpl_vars['smarty']->value['section']['mm']['show'] = true;
$_smarty_tpl->tpl_vars['smarty']->value['section']['mm']['max'] = $_smarty_tpl->tpl_vars['smarty']->value['section']['mm']['loop'];
$_smarty_tpl->tpl_vars['smarty']->value['section']['mm']['step'] = 1;
$_smarty_tpl->tpl_vars['smarty']->value['section']['mm']['start'] = $_smarty_tpl->tpl_vars['smarty']->value['section']['mm']['step'] > 0 ? 0 : $_smarty_tpl->tpl_vars['smarty']->value['section']['mm']['loop']-1;
if ($_smarty_tpl->tpl_vars['smarty']->value['section']['mm']['show']) {
    $_smarty_tpl->tpl_vars['smarty']->value['section']['mm']['total'] = $_smarty_tpl->tpl_vars['smarty']->value['section']['mm']['loop'];
    if ($_smarty_tpl->tpl_vars['smarty']->value['section']['mm']['total'] == 0)
        $_smarty_tpl->tpl_vars['smarty']->value['section']['mm']['show'] = false;
} else
    $_smarty_tpl->tpl_vars['smarty']->value['section']['mm']['total'] = 0;
if ($_smarty_tpl->tpl_vars['smarty']->value['section']['mm']['show']):

            for ($_smarty_tpl->tpl_vars['smarty']->value['section']['mm']['index'] = $_smarty_tpl->tpl_vars['smarty']->value['section']['mm']['start'], $_smarty_tpl->tpl_vars['smarty']->value['section']['mm']['iteration'] = 1;
                 $_smarty_tpl->tpl_vars['smarty']->value['section']['mm']['iteration'] <= $_smarty_tpl->tpl_vars['smarty']->value['section']['mm']['total'];
                 $_smarty_tpl->tpl_vars['smarty']->value['section']['mm']['index'] += $_smarty_tpl->tpl_vars['smarty']->value['section']['mm']['step'], $_smarty_tpl->tpl_vars['smarty']->value['section']['mm']['iteration']++):
$_smarty_tpl->tpl_vars['smarty']->value['section']['mm']['rownum'] = $_smarty_tpl->tpl_vars['smarty']->value['section']['mm']['iteration'];
$_smarty_tpl->tpl_vars['smarty']->value['section']['mm']['index_prev'] = $_smarty_tpl->tpl_vars['smarty']->value['section']['mm']['index'] - $_smarty_tpl->tpl_vars['smarty']->value['section']['mm']['step'];
$_smarty_tpl->tpl_vars['smarty']->value['section']['mm']['index_next'] = $_smarty_tpl->tpl_vars['smarty']->value['section']['mm']['index'] + $_smarty_tpl->tpl_vars['smarty']->value['section']['mm']['step'];
$_smarty_tpl->tpl_vars['smarty']->value['section']['mm']['first']      = ($_smarty_tpl->tpl_vars['smarty']->value['section']['mm']['iteration'] == 1);
$_smarty_tpl->tpl_vars['smarty']->value['section']['mm']['last']       = ($_smarty_tpl->tpl_vars['smarty']->value['section']['mm']['iteration'] == $_smarty_tpl->tpl_vars['smarty']->value['section']['mm']['total']);
?>
							<option value=<?php echo $_smarty_tpl->getVariable('smarty')->value['section']['mm']['index']+1;?>
><?php echo $_smarty_tpl->getVariable('smarty')->value['section']['mm']['index']+1;?>
</option>
							<?php endfor; endif; ?>
							</select>
						</td>
					</tr>
					<tr >					
						<td class="td_line" width="80%">
							按周：<input name="dateinterval" type="radio" class="wbk" value="week">
							&nbsp;&nbsp;年:<select width="30" class="wbk" onclick="changetype('week')"  name="wyear" style="width:100px">
							<?php if (isset($_smarty_tpl->tpl_vars['smarty']->value['section']['wy'])) unset($_smarty_tpl->tpl_vars['smarty']->value['section']['wy']);
$_smarty_tpl->tpl_vars['smarty']->value['section']['wy']['name'] = 'wy';
$_smarty_tpl->tpl_vars['smarty']->value['section']['wy']['loop'] = is_array($_loop=$_smarty_tpl->tpl_vars['years']->value) ? count($_loop) : max(0, (int) $_loop); unset($_loop);
$_smarty_tpl->tpl_vars['smarty']->value['section']['wy']['show'] = true;
$_smarty_tpl->tpl_vars['smarty']->value['section']['wy']['max'] = $_smarty_tpl->tpl_vars['smarty']->value['section']['wy']['loop'];
$_smarty_tpl->tpl_vars['smarty']->value['section']['wy']['step'] = 1;
$_smarty_tpl->tpl_vars['smarty']->value['section']['wy']['start'] = $_smarty_tpl->tpl_vars['smarty']->value['section']['wy']['step'] > 0 ? 0 : $_smarty_tpl->tpl_vars['smarty']->value['section']['wy']['loop']-1;
if ($_smarty_tpl->tpl_vars['smarty']->value['section']['wy']['show']) {
    $_smarty_tpl->tpl_vars['smarty']->value['section']['wy']['total'] = $_smarty_tpl->tpl_vars['smarty']->value['section']['wy']['loop'];
    if ($_smarty_tpl->tpl_vars['smarty']->value['section']['wy']['total'] == 0)
        $_smarty_tpl->tpl_vars['smarty']->value['section']['wy']['show'] = false;
} else
    $_smarty_tpl->tpl_vars['smarty']->value['section']['wy']['total'] = 0;
if ($_smarty_tpl->tpl_vars['smarty']->value['section']['wy']['show']):

            for ($_smarty_tpl->tpl_vars['smarty']->value['section']['wy']['index'] = $_smarty_tpl->tpl_vars['smarty']->value['section']['wy']['start'], $_smarty_tpl->tpl_vars['smarty']->value['section']['wy']['iteration'] = 1;
                 $_smarty_tpl->tpl_vars['smarty']->value['section']['wy']['iteration'] <= $_smarty_tpl->tpl_vars['smarty']->value['section']['wy']['total'];
                 $_smarty_tpl->tpl_vars['smarty']->value['section']['wy']['index'] += $_smarty_tpl->tpl_vars['smarty']->value['section']['wy']['step'], $_smarty_tpl->tpl_vars['smarty']->value['section']['wy']['iteration']++):
$_smarty_tpl->tpl_vars['smarty']->value['section']['wy']['rownum'] = $_smarty_tpl->tpl_vars['smarty']->value['section']['wy']['iteration'];
$_smarty_tpl->tpl_vars['smarty']->value['section']['wy']['index_prev'] = $_smarty_tpl->tpl_vars['smarty']->value['section']['wy']['index'] - $_smarty_tpl->tpl_vars['smarty']->value['section']['wy']['step'];
$_smarty_tpl->tpl_vars['smarty']->value['section']['wy']['index_next'] = $_smarty_tpl->tpl_vars['smarty']->value['section']['wy']['index'] + $_smarty_tpl->tpl_vars['smarty']->value['section']['wy']['step'];
$_smarty_tpl->tpl_vars['smarty']->value['section']['wy']['first']      = ($_smarty_tpl->tpl_vars['smarty']->value['section']['wy']['iteration'] == 1);
$_smarty_tpl->tpl_vars['smarty']->value['section']['wy']['last']       = ($_smarty_tpl->tpl_vars['smarty']->value['section']['wy']['iteration'] == $_smarty_tpl->tpl_vars['smarty']->value['section']['wy']['total']);
?>
							<option value=<?php echo $_smarty_tpl->tpl_vars['years']->value[$_smarty_tpl->getVariable('smarty')->value['section']['wy']['index']];?>
><?php echo $_smarty_tpl->tpl_vars['years']->value[$_smarty_tpl->getVariable('smarty')->value['section']['wy']['index']];?>
</option>
							<?php endfor; endif; ?>
							</select>
							&nbsp;&nbsp;月:<select width="30" class="wbk" onclick="changetype('week')"  name="wmonth" style="width:100px">
							<?php if (isset($_smarty_tpl->tpl_vars['smarty']->value['section']['wm'])) unset($_smarty_tpl->tpl_vars['smarty']->value['section']['wm']);
$_smarty_tpl->tpl_vars['smarty']->value['section']['wm']['name'] = 'wm';
$_smarty_tpl->tpl_vars['smarty']->value['section']['wm']['loop'] = is_array($_loop=12) ? count($_loop) : max(0, (int) $_loop); unset($_loop);
$_smarty_tpl->tpl_vars['smarty']->value['section']['wm']['show'] = true;
$_smarty_tpl->tpl_vars['smarty']->value['section']['wm']['max'] = $_smarty_tpl->tpl_vars['smarty']->value['section']['wm']['loop'];
$_smarty_tpl->tpl_vars['smarty']->value['section']['wm']['step'] = 1;
$_smarty_tpl->tpl_vars['smarty']->value['section']['wm']['start'] = $_smarty_tpl->tpl_vars['smarty']->value['section']['wm']['step'] > 0 ? 0 : $_smarty_tpl->tpl_vars['smarty']->value['section']['wm']['loop']-1;
if ($_smarty_tpl->tpl_vars['smarty']->value['section']['wm']['show']) {
    $_smarty_tpl->tpl_vars['smarty']->value['section']['wm']['total'] = $_smarty_tpl->tpl_vars['smarty']->value['section']['wm']['loop'];
    if ($_smarty_tpl->tpl_vars['smarty']->value['section']['wm']['total'] == 0)
        $_smarty_tpl->tpl_vars['smarty']->value['section']['wm']['show'] = false;
} else
    $_smarty_tpl->tpl_vars['smarty']->value['section']['wm']['total'] = 0;
if ($_smarty_tpl->tpl_vars['smarty']->value['section']['wm']['show']):

            for ($_smarty_tpl->tpl_vars['smarty']->value['section']['wm']['index'] = $_smarty_tpl->tpl_vars['smarty']->value['section']['wm']['start'], $_smarty_tpl->tpl_vars['smarty']->value['section']['wm']['iteration'] = 1;
                 $_smarty_tpl->tpl_vars['smarty']->value['section']['wm']['iteration'] <= $_smarty_tpl->tpl_vars['smarty']->value['section']['wm']['total'];
                 $_smarty_tpl->tpl_vars['smarty']->value['section']['wm']['index'] += $_smarty_tpl->tpl_vars['smarty']->value['section']['wm']['step'], $_smarty_tpl->tpl_vars['smarty']->value['section']['wm']['iteration']++):
$_smarty_tpl->tpl_vars['smarty']->value['section']['wm']['rownum'] = $_smarty_tpl->tpl_vars['smarty']->value['section']['wm']['iteration'];
$_smarty_tpl->tpl_vars['smarty']->value['section']['wm']['index_prev'] = $_smarty_tpl->tpl_vars['smarty']->value['section']['wm']['index'] - $_smarty_tpl->tpl_vars['smarty']->value['section']['wm']['step'];
$_smarty_tpl->tpl_vars['smarty']->value['section']['wm']['index_next'] = $_smarty_tpl->tpl_vars['smarty']->value['section']['wm']['index'] + $_smarty_tpl->tpl_vars['smarty']->value['section']['wm']['step'];
$_smarty_tpl->tpl_vars['smarty']->value['section']['wm']['first']      = ($_smarty_tpl->tpl_vars['smarty']->value['section']['wm']['iteration'] == 1);
$_smarty_tpl->tpl_vars['smarty']->value['section']['wm']['last']       = ($_smarty_tpl->tpl_vars['smarty']->value['section']['wm']['iteration'] == $_smarty_tpl->tpl_vars['smarty']->value['section']['wm']['total']);
?>
							<option value=<?php echo $_smarty_tpl->getVariable('smarty')->value['section']['wm']['index']+1;?>
><?php echo $_smarty_tpl->getVariable('smarty')->value['section']['wm']['index']+1;?>
</option>
							<?php endfor; endif; ?>
							</select>
							&nbsp;&nbsp;第:<select width="30" class="wbk" onclick="changetype('week')" name="wweek" style="width:100px">
							<?php if (isset($_smarty_tpl->tpl_vars['smarty']->value['section']['ww'])) unset($_smarty_tpl->tpl_vars['smarty']->value['section']['ww']);
$_smarty_tpl->tpl_vars['smarty']->value['section']['ww']['name'] = 'ww';
$_smarty_tpl->tpl_vars['smarty']->value['section']['ww']['loop'] = is_array($_loop=5) ? count($_loop) : max(0, (int) $_loop); unset($_loop);
$_smarty_tpl->tpl_vars['smarty']->value['section']['ww']['show'] = true;
$_smarty_tpl->tpl_vars['smarty']->value['section']['ww']['max'] = $_smarty_tpl->tpl_vars['smarty']->value['section']['ww']['loop'];
$_smarty_tpl->tpl_vars['smarty']->value['section']['ww']['step'] = 1;
$_smarty_tpl->tpl_vars['smarty']->value['section']['ww']['start'] = $_smarty_tpl->tpl_vars['smarty']->value['section']['ww']['step'] > 0 ? 0 : $_smarty_tpl->tpl_vars['smarty']->value['section']['ww']['loop']-1;
if ($_smarty_tpl->tpl_vars['smarty']->value['section']['ww']['show']) {
    $_smarty_tpl->tpl_vars['smarty']->value['section']['ww']['total'] = $_smarty_tpl->tpl_vars['smarty']->value['section']['ww']['loop'];
    if ($_smarty_tpl->tpl_vars['smarty']->value['section']['ww']['total'] == 0)
        $_smarty_tpl->tpl_vars['smarty']->value['section']['ww']['show'] = false;
} else
    $_smarty_tpl->tpl_vars['smarty']->value['section']['ww']['total'] = 0;
if ($_smarty_tpl->tpl_vars['smarty']->value['section']['ww']['show']):

            for ($_smarty_tpl->tpl_vars['smarty']->value['section']['ww']['index'] = $_smarty_tpl->tpl_vars['smarty']->value['section']['ww']['start'], $_smarty_tpl->tpl_vars['smarty']->value['section']['ww']['iteration'] = 1;
                 $_smarty_tpl->tpl_vars['smarty']->value['section']['ww']['iteration'] <= $_smarty_tpl->tpl_vars['smarty']->value['section']['ww']['total'];
                 $_smarty_tpl->tpl_vars['smarty']->value['section']['ww']['index'] += $_smarty_tpl->tpl_vars['smarty']->value['section']['ww']['step'], $_smarty_tpl->tpl_vars['smarty']->value['section']['ww']['iteration']++):
$_smarty_tpl->tpl_vars['smarty']->value['section']['ww']['rownum'] = $_smarty_tpl->tpl_vars['smarty']->value['section']['ww']['iteration'];
$_smarty_tpl->tpl_vars['smarty']->value['section']['ww']['index_prev'] = $_smarty_tpl->tpl_vars['smarty']->value['section']['ww']['index'] - $_smarty_tpl->tpl_vars['smarty']->value['section']['ww']['step'];
$_smarty_tpl->tpl_vars['smarty']->value['section']['ww']['index_next'] = $_smarty_tpl->tpl_vars['smarty']->value['section']['ww']['index'] + $_smarty_tpl->tpl_vars['smarty']->value['section']['ww']['step'];
$_smarty_tpl->tpl_vars['smarty']->value['section']['ww']['first']      = ($_smarty_tpl->tpl_vars['smarty']->value['section']['ww']['iteration'] == 1);
$_smarty_tpl->tpl_vars['smarty']->value['section']['ww']['last']       = ($_smarty_tpl->tpl_vars['smarty']->value['section']['ww']['iteration'] == $_smarty_tpl->tpl_vars['smarty']->value['section']['ww']['total']);
?>
							<option value=<?php echo $_smarty_tpl->getVariable('smarty')->value['section']['ww']['index']+1;?>
><?php echo $_smarty_tpl->getVariable('smarty')->value['section']['ww']['index']+1;?>
</option>
							<?php endfor; endif; ?>
							</select>周
						</td>
					</tr>
					<tr>					
						<td class="td_line" width="80%">
							按日：<input name="dateinterval" type="radio" class="wbk" value="day">
							&nbsp;&nbsp;<input type="text" class="wbk" onclick="changetype('day')" name="dday" size="16" id="f_rangeStart" value="<?php echo smarty_modifier_date_format($_smarty_tpl->tpl_vars['f_rangeStart']->value,'%Y-%m-%d');?>
" />
							<input type="button" onclick="changetype('day')" id="f_rangeStart_trigger" name="f_rangeStart_trigger" value="<?php echo $_smarty_tpl->tpl_vars['language']->value['Edittime'];?>
"  class="wbk">
						</td>
					</tr>
					<tr  <?php if ($_smarty_tpl->tpl_vars['trnumber']->value++%2 == 0) {?>bgcolor="f7f7f7"<?php }?>>
						<td class="td_line" width="20%" align="right">用户组/用户：</td>
						<td class="td_line" width="80%">
		<?php $_smarty_tpl->tpl_vars['select_group_id'] = new Smarty_Variable('groupid', null, 0);?>
		<?php $_smarty_tpl->tpl_vars['changegroup'] = new Smarty_Variable('change_usergroup(this.value)', null, 0);?>
		<?php echo $_smarty_tpl->getSubTemplate ("select_sgroup_ajax.tpl", $_smarty_tpl->cache_id, $_smarty_tpl->compile_id, 0, $_smarty_tpl->cache_lifetime, array(), 0);
?>
  
		&nbsp;&nbsp;用户:<select style="width:150px;" class="wbk"  name="username" id="username" >
                        <?php if ($_SESSION['ADMIN_LEVEL'] == 1) {?>
							<option value="" >无</option>
						<?php }?>
                     	<?php if (isset($_smarty_tpl->tpl_vars['smarty']->value['section']['u'])) unset($_smarty_tpl->tpl_vars['smarty']->value['section']['u']);
$_smarty_tpl->tpl_vars['smarty']->value['section']['u']['name'] = 'u';
$_smarty_tpl->tpl_vars['smarty']->value['section']['u']['loop'] = is_array($_loop=$_smarty_tpl->tpl_vars['alluser']->value) ? count($_loop) : max(0, (int) $_loop); unset($_loop);
$_smarty_tpl->tpl_vars['smarty']->value['section']['u']['show'] = true;
$_smarty_tpl->tpl_vars['smarty']->value['section']['u']['max'] = $_smarty_tpl->tpl_vars['smarty']->value['section']['u']['loop'];
$_smarty_tpl->tpl_vars['smarty']->value['section']['u']['step'] = 1;
$_smarty_tpl->tpl_vars['smarty']->value['section']['u']['start'] = $_smarty_tpl->tpl_vars['smarty']->value['section']['u']['step'] > 0 ? 0 : $_smarty_tpl->tpl_vars['smarty']->value['section']['u']['loop']-1;
if ($_smarty_tpl->tpl_vars['smarty']->value['section']['u']['show']) {
    $_smarty_tpl->tpl_vars['smarty']->value['section']['u']['total'] = $_smarty_tpl->tpl_vars['smarty']->value['section']['u']['loop'];
    if ($_smarty_tpl->tpl_vars['smarty']->value['section']['u']['total'] == 0)
        $_smarty_tpl->tpl_vars['smarty']->value['section']['u']['show'] = false;
} else
    $_smarty_tpl->tpl_vars['smarty']->value['section']['u']['total'] = 0;
if ($_smarty_tpl->tpl_vars['smarty']->value['section']['u']['show']):

            for ($_smarty_tpl->tpl_vars['smarty']->value['section']['u']['index'] = $_smarty_tpl->tpl_vars['smarty']->value['section']['u']['start'], $_smarty_tpl->tpl_vars['smarty']->value['section']['u']['iteration'] = 1;
                 $_smarty_tpl->tpl_vars['smarty']->value['section']['u']['iteration'] <= $_smarty_tpl->tpl_vars['smarty']->value['section']['u']['total'];
                 $_smarty_tpl->tpl_vars['smarty']->value['section']['u']['index'] += $_smarty_tpl->tpl_vars['smarty']->value['section']['u']['step'], $_smarty_tpl->tpl_vars['smarty']->value['section']['u']['iteration']++):
$_smarty_tpl->tpl_vars['smarty']->value['section']['u']['rownum'] = $_smarty_tpl->tpl_vars['smarty']->value['section']['u']['iteration'];
$_smarty_tpl->tpl_vars['smarty']->value['section']['u']['index_prev'] = $_smarty_tpl->tpl_vars['smarty']->value['section']['u']['index'] - $_smarty_tpl->tpl_vars['smarty']->value['section']['u']['step'];
$_smarty_tpl->tpl_vars['smarty']->value['section']['u']['index_next'] = $_smarty_tpl->tpl_vars['smarty']->value['section']['u']['index'] + $_smarty_tpl->tpl_vars['smarty']->value['section']['u']['step'];
$_smarty_tpl->tpl_vars['smarty']->value['section']['u']['first']      = ($_smarty_tpl->tpl_vars['smarty']->value['section']['u']['iteration'] == 1);
$_smarty_tpl->tpl_vars['smarty']->value['section']['u']['last']       = ($_smarty_tpl->tpl_vars['smarty']->value['section']['u']['iteration'] == $_smarty_tpl->tpl_vars['smarty']->value['section']['u']['total']);
?>
						<option value="<?php echo $_smarty_tpl->tpl_vars['alluser']->value[$_smarty_tpl->getVariable('smarty')->value['section']['u']['index']]['username'];?>
" ><?php echo $_smarty_tpl->tpl_vars['alluser']->value[$_smarty_tpl->getVariable('smarty')->value['section']['u']['index']]['username'];?>
</option>
						<?php endfor; endif; ?>
              </SELECT>   
						</td>
					</tr>
					<tr  <?php if ($_smarty_tpl->tpl_vars['trnumber']->value++%2 == 0) {?>bgcolor="f7f7f7"<?php }?>>
						<td class="td_line" width="20%" align="right">设备组/设备：</td>
						<td class="td_line" width="80%">
		<?php $_smarty_tpl->tpl_vars['select_group_id'] = new Smarty_Variable('sgroupid', null, 0);?>
		<?php $_smarty_tpl->tpl_vars['changegroup'] = new Smarty_Variable('change_servergroup(this.value)', null, 0);?>
		<?php echo $_smarty_tpl->getSubTemplate ("select_sgroup_ajax.tpl", $_smarty_tpl->cache_id, $_smarty_tpl->compile_id, 0, $_smarty_tpl->cache_lifetime, array(), 0);
?>
    
		&nbsp;&nbsp;设备:<select style="width:150px;" class="wbk"  name="server" id="server" >
                        <?php if ($_SESSION['ADMIN_LEVEL'] == 1) {?>
							<option value="" >无</option>
						<?php }?>
                     	<?php if (isset($_smarty_tpl->tpl_vars['smarty']->value['section']['s'])) unset($_smarty_tpl->tpl_vars['smarty']->value['section']['s']);
$_smarty_tpl->tpl_vars['smarty']->value['section']['s']['name'] = 's';
$_smarty_tpl->tpl_vars['smarty']->value['section']['s']['loop'] = is_array($_loop=$_smarty_tpl->tpl_vars['allserver']->value) ? count($_loop) : max(0, (int) $_loop); unset($_loop);
$_smarty_tpl->tpl_vars['smarty']->value['section']['s']['show'] = true;
$_smarty_tpl->tpl_vars['smarty']->value['section']['s']['max'] = $_smarty_tpl->tpl_vars['smarty']->value['section']['s']['loop'];
$_smarty_tpl->tpl_vars['smarty']->value['section']['s']['step'] = 1;
$_smarty_tpl->tpl_vars['smarty']->value['section']['s']['start'] = $_smarty_tpl->tpl_vars['smarty']->value['section']['s']['step'] > 0 ? 0 : $_smarty_tpl->tpl_vars['smarty']->value['section']['s']['loop']-1;
if ($_smarty_tpl->tpl_vars['smarty']->value['section']['s']['show']) {
    $_smarty_tpl->tpl_vars['smarty']->value['section']['s']['total'] = $_smarty_tpl->tpl_vars['smarty']->value['section']['s']['loop'];
    if ($_smarty_tpl->tpl_vars['smarty']->value['section']['s']['total'] == 0)
        $_smarty_tpl->tpl_vars['smarty']->value['section']['s']['show'] = false;
} else
    $_smarty_tpl->tpl_vars['smarty']->value['section']['s']['total'] = 0;
if ($_smarty_tpl->tpl_vars['smarty']->value['section']['s']['show']):

            for ($_smarty_tpl->tpl_vars['smarty']->value['section']['s']['index'] = $_smarty_tpl->tpl_vars['smarty']->value['section']['s']['start'], $_smarty_tpl->tpl_vars['smarty']->value['section']['s']['iteration'] = 1;
                 $_smarty_tpl->tpl_vars['smarty']->value['section']['s']['iteration'] <= $_smarty_tpl->tpl_vars['smarty']->value['section']['s']['total'];
                 $_smarty_tpl->tpl_vars['smarty']->value['section']['s']['index'] += $_smarty_tpl->tpl_vars['smarty']->value['section']['s']['step'], $_smarty_tpl->tpl_vars['smarty']->value['section']['s']['iteration']++):
$_smarty_tpl->tpl_vars['smarty']->value['section']['s']['rownum'] = $_smarty_tpl->tpl_vars['smarty']->value['section']['s']['iteration'];
$_smarty_tpl->tpl_vars['smarty']->value['section']['s']['index_prev'] = $_smarty_tpl->tpl_vars['smarty']->value['section']['s']['index'] - $_smarty_tpl->tpl_vars['smarty']->value['section']['s']['step'];
$_smarty_tpl->tpl_vars['smarty']->value['section']['s']['index_next'] = $_smarty_tpl->tpl_vars['smarty']->value['section']['s']['index'] + $_smarty_tpl->tpl_vars['smarty']->value['section']['s']['step'];
$_smarty_tpl->tpl_vars['smarty']->value['section']['s']['first']      = ($_smarty_tpl->tpl_vars['smarty']->value['section']['s']['iteration'] == 1);
$_smarty_tpl->tpl_vars['smarty']->value['section']['s']['last']       = ($_smarty_tpl->tpl_vars['smarty']->value['section']['s']['iteration'] == $_smarty_tpl->tpl_vars['smarty']->value['section']['s']['total']);
?>
						<option value="<?php echo $_smarty_tpl->tpl_vars['allserver']->value[$_smarty_tpl->getVariable('smarty')->value['section']['s']['index']]['device_ip'];?>
" ><?php echo $_smarty_tpl->tpl_vars['allserver']->value[$_smarty_tpl->getVariable('smarty')->value['section']['s']['index']]['device_ip'];?>
</option>
						<?php endfor; endif; ?>
              </SELECT> 
						</td>
					</tr>
					<tr bgcolor="f7f7f7">
						<td class="td_line" colspan="2" align="center"><input name="submit" type="submit" onclick="setScroll();"  value="<?php echo $_smarty_tpl->tpl_vars['language']->value['Search'];?>
" class="an_02">
					</tr>
				</table>
				
			</form>
	</td>
  </tr>
</table>

  <?php echo '<script'; ?>
 type="text/javascript">
  
<?php if ($_smarty_tpl->tpl_vars['_config']->value['LDAP']) {?>
<?php echo $_smarty_tpl->tpl_vars['changelevelstr']->value;?>

<?php echo $_smarty_tpl->tpl_vars['schangelevelstr']->value;?>

<?php }?>
var cal = Calendar.setup({
    onSelect: function(cal) { cal.hide() },
    showTime: false
});
cal.manageFields("f_rangeStart_trigger", "f_rangeStart", "%Y-%m-%d");
<?php echo '</script'; ?>
>
<?php echo '<script'; ?>
>
changelevel('1');
<?php echo '</script'; ?>
>

<?php }
}
?>