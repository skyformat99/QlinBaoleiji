<?php /* Smarty version 3.1.27, created on 2017-06-19 21:57:32
         compiled from "/opt/freesvr/web/htdocs/freesvr/audit/template/admin/dev_edit.tpl" */ ?>
<?php
/*%%SmartyHeaderCode:7586066425947d84ce56255_00521301%%*/
if(!defined('SMARTY_DIR')) exit('no direct access allowed');
$_valid = $_smarty_tpl->decodeProperties(array (
  'file_dependency' => 
  array (
    '8a844f984193ed1ddead662bce0aa1873b86723e' => 
    array (
      0 => '/opt/freesvr/web/htdocs/freesvr/audit/template/admin/dev_edit.tpl',
      1 => 1497880646,
      2 => 'file',
    ),
  ),
  'nocache_hash' => '7586066425947d84ce56255_00521301',
  'variables' => 
  array (
    'title' => 0,
    'template_root' => 0,
    'from' => 0,
    'id' => 0,
    'gid' => 0,
    'appconfigedit' => 0,
    'appconfig1' => 0,
    'trnumber' => 0,
    'hostname' => 0,
    'alltype' => 0,
    'type_id' => 0,
    'IP' => 0,
    'ipv6' => 0,
    'superpassword' => 0,
    'method' => 0,
    'freq' => 0,
    'sshport' => 0,
    'telnetport' => 0,
    'ftpport' => 0,
    'rdpport' => 0,
    'vncport' => 0,
    'x11port' => 0,
    'transport' => 0,
    'asset_name' => 0,
    'asset_specification' => 0,
    'asset_department' => 0,
    'asset_location' => 0,
    'asset_company' => 0,
    'asset_start' => 0,
    'asset_usedtime' => 0,
    'asset_warrantdate' => 0,
    'asset_status' => 0,
    'monitor' => 0,
    'tab' => 0,
    '_config' => 0,
    'changelevelstr' => 0,
  ),
  'has_nocache_code' => false,
  'version' => '3.1.27',
  'unifunc' => 'content_5947d84d07c2f4_62856346',
),false);
/*/%%SmartyHeaderCode%%*/
if ($_valid && !is_callable('content_5947d84d07c2f4_62856346')) {
function content_5947d84d07c2f4_62856346 ($_smarty_tpl) {

$_smarty_tpl->properties['nocache_hash'] = '7586066425947d84ce56255_00521301';
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
 src="./template/admin/cssjs/global.functions.js"><?php echo '</script'; ?>
>
<?php echo '<script'; ?>
 src="./template/admin/cssjs/jscal2.js"><?php echo '</script'; ?>
>
<?php echo '<script'; ?>
 src="./template/admin/cssjs/cn.js"><?php echo '</script'; ?>
>
<?php echo '<script'; ?>
 src="./template/admin/cssjs/global.functions.js"><?php echo '</script'; ?>
>
<link type="text/css" rel="stylesheet" href="./template/admin/cssjs/jscal2.css" />
<?php echo '<script'; ?>
 type="text/javascript" src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/cssjs/_ajaxdtree.js"><?php echo '</script'; ?>
>
<link href="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/cssjs/dtree.css" rel="stylesheet" type="text/css" />
</head>

<body>
<?php echo '<script'; ?>
>



function change_option(number,index){
 for (var i = 0; i <= number; i++) {
      document.getElementById('current' + i).className = '';
      document.getElementById('content' + i).style.display = 'none';
 }
  document.getElementById('current' + index).className = 'current';
  document.getElementById('content' + index).style.display = 'block';
  if(index==1 || index==2 || index==3){
	document.getElementById('finalsubmit').style.display = 'block';
  }else{
	document.getElementById('finalsubmit').style.display = 'none';
  }
  return false;
}
<?php echo '</script'; ?>
>
<td width="84%" align="left" valign="top"><table width="100%" border="0" cellspacing="0" cellpadding="0"><tr><td valign="middle" class="hui_bj"><div class="menu">
<ul>
<?php if ($_SESSION['ADMIN_LEVEL'] == 10) {?>
<li class="me_a"><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an1.jpg" align="absmiddle"/><a href="admin.php?controller=admin_index&action=main">密码查看</a><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an3.jpg" align="absmiddle"/></li>
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
<?php } elseif ($_SESSION['ADMIN_LEVEL'] == 10 || $_SESSION['ADMIN_LEVEL'] == 101) {?>
<li class="me_a"><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an1.jpg" align="absmiddle"/><a href="admin.php?controller=admin_index&action=main">密码查看</a><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an3.jpg" align="absmiddle"/></li>
<?php } else { ?>
	<li class="me_b"><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an11.jpg" align="absmiddle"/><a href="admin.php?controller=admin_member">用户管理</a><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an33.jpg" align="absmiddle"/></li>
	<?php if ($_smarty_tpl->tpl_vars['from']->value == 'dir') {?>
	<li class="me_b"><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an11.jpg" align="absmiddle"/><a href="admin.php?controller=admin_pro&action=dev_index">设备管理</a><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an33.jpg" align="absmiddle"/></li>
	<?php } else { ?>
	<li class="me_a"><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an1.jpg" align="absmiddle"/><a href="admin.php?controller=admin_pro&action=dev_index">设备管理</a><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an3.jpg" align="absmiddle"/></li>
	<?php }?>
	<?php if ($_smarty_tpl->tpl_vars['from']->value == 'dir') {?>
	<li class="me_a"><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an1.jpg" align="absmiddle"/><a href="admin.php?controller=admin_pro&action=dev_group">目录管理</a><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an3.jpg" align="absmiddle"/></li>
	<?php } else { ?>
	<li class="me_b"><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an11.jpg" align="absmiddle"/><a href="admin.php?controller=admin_pro&action=dev_group">目录管理</a><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an33.jpg" align="absmiddle"/></li>
	<?php }?>
	<li class="me_b"><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an11.jpg" align="absmiddle"/><a href="admin.php?controller=admin_member&action=workdept">用户属性</a><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an33.jpg" align="absmiddle"/></li>
	<li class="me_b"><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an11.jpg" align="absmiddle"/><a href="admin.php?controller=admin_pro&action=systemtype">系统类型</a><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an33.jpg" align="absmiddle"/></li>
	<li class="me_b"><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an11.jpg" align="absmiddle"/><a href="admin.php?controller=admin_pro&action=sshkey">SSH公私钥</a><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an33.jpg" align="absmiddle"/></li>
	<li class="me_b"><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an11.jpg" align="absmiddle"/><a href="admin.php?controller=admin_member&action=radiususer">RADIUS用户</a><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an33.jpg" align="absmiddle"/></li>
	<li class="me_b"><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an11.jpg" align="absmiddle"/><a href="admin.php?controller=admin_pro&action=passwordkey">密码密钥</a><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an33.jpg" align="absmiddle"/></li>
	<?php if ($_SESSION['ADMIN_LEVEL'] == 1) {?>
    <li class="me_b"><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an11.jpg" align="absmiddle"/><a href="admin.php?controller=admin_member&action=online">在线用户</a><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an33.jpg" align="absmiddle"/></li>
	<?php }?>
<?php }?>
</ul><span class="back_img"><A href="admin.php?controller=<?php if ($_SESSION['ADMIN_LEVEL'] == 10 || $_SESSION['ADMIN_LEVEL'] == 101) {?>admin_index&action=main<?php } else {
if ($_GET['appconfigedit']) {?>admin_pro&action=dev_edit&id=<?php echo $_smarty_tpl->tpl_vars['id']->value;?>
&gid=<?php echo $_smarty_tpl->tpl_vars['gid']->value;?>
&apptable=1<?php } else { ?>admin_pro&action=dev_index&gid=<?php echo $_smarty_tpl->tpl_vars['gid']->value;
}
}?>&back=1"><IMG src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/back1.png" 
      width="80" height="30" border="0"></A></span>
</div></td></tr>

   
</table>
<table width="100%" border="0" cellspacing="0" cellpadding="0">

  <tr>
	<td class="">

        <table width="100%" border="0" cellspacing="0" cellpadding="0">
          <tr>
            <td align="center"><form name="f1" method=post OnSubmit='return check()' action="admin.php?controller=admin_pro&action=dev_save&id=<?php echo $_smarty_tpl->tpl_vars['id']->value;?>
&appconfigedit=<?php echo $_smarty_tpl->tpl_vars['appconfigedit']->value;?>
&appconfigid=<?php echo $_smarty_tpl->tpl_vars['appconfig1']->value['seq'];?>
&gid=<?php echo $_smarty_tpl->tpl_vars['gid']->value;?>
">
		<input type="password" name="hiddenpassword" id="hiddenpassword" style="display:none"/>	 <DIV style="WIDTH:100%" id=navbar>
 <?php if (!$_smarty_tpl->tpl_vars['appconfigedit']->value) {?>
				 <div id="content1" class="content">
				   <div class="contentMain">
	<table border=0 width=100% cellpadding=5 cellspacing=1 bgcolor="#FFFFFF" valign=top class="BBtable">
	<TR>
      <TD height="27" colspan="4" class="tb_t_bg">基本信息</TD>
    </TR>
	<?php $_smarty_tpl->tpl_vars["trnumber"] = new Smarty_Variable(0, null, 0);?>
	<tr <?php if ($_smarty_tpl->tpl_vars['trnumber']->value%2 == 0) {?>bgcolor="f7f7f7"<?php }?>>
		<td width="15%" align=right>
		主机名		
		</td>
		<td width="35%">
		<input type=text name="hostname" size=35 value="<?php echo $_smarty_tpl->tpl_vars['hostname']->value;?>
" >
	  </td>
	  <td width="15%" align=right>
			系统类型  </td>
		<td width="35%"><select  class="wbk"  name="type_id">
		<?php if (isset($_smarty_tpl->tpl_vars['smarty']->value['section']['g'])) unset($_smarty_tpl->tpl_vars['smarty']->value['section']['g']);
$_smarty_tpl->tpl_vars['smarty']->value['section']['g']['name'] = 'g';
$_smarty_tpl->tpl_vars['smarty']->value['section']['g']['loop'] = is_array($_loop=$_smarty_tpl->tpl_vars['alltype']->value) ? count($_loop) : max(0, (int) $_loop); unset($_loop);
$_smarty_tpl->tpl_vars['smarty']->value['section']['g']['show'] = true;
$_smarty_tpl->tpl_vars['smarty']->value['section']['g']['max'] = $_smarty_tpl->tpl_vars['smarty']->value['section']['g']['loop'];
$_smarty_tpl->tpl_vars['smarty']->value['section']['g']['step'] = 1;
$_smarty_tpl->tpl_vars['smarty']->value['section']['g']['start'] = $_smarty_tpl->tpl_vars['smarty']->value['section']['g']['step'] > 0 ? 0 : $_smarty_tpl->tpl_vars['smarty']->value['section']['g']['loop']-1;
if ($_smarty_tpl->tpl_vars['smarty']->value['section']['g']['show']) {
    $_smarty_tpl->tpl_vars['smarty']->value['section']['g']['total'] = $_smarty_tpl->tpl_vars['smarty']->value['section']['g']['loop'];
    if ($_smarty_tpl->tpl_vars['smarty']->value['section']['g']['total'] == 0)
        $_smarty_tpl->tpl_vars['smarty']->value['section']['g']['show'] = false;
} else
    $_smarty_tpl->tpl_vars['smarty']->value['section']['g']['total'] = 0;
if ($_smarty_tpl->tpl_vars['smarty']->value['section']['g']['show']):

            for ($_smarty_tpl->tpl_vars['smarty']->value['section']['g']['index'] = $_smarty_tpl->tpl_vars['smarty']->value['section']['g']['start'], $_smarty_tpl->tpl_vars['smarty']->value['section']['g']['iteration'] = 1;
                 $_smarty_tpl->tpl_vars['smarty']->value['section']['g']['iteration'] <= $_smarty_tpl->tpl_vars['smarty']->value['section']['g']['total'];
                 $_smarty_tpl->tpl_vars['smarty']->value['section']['g']['index'] += $_smarty_tpl->tpl_vars['smarty']->value['section']['g']['step'], $_smarty_tpl->tpl_vars['smarty']->value['section']['g']['iteration']++):
$_smarty_tpl->tpl_vars['smarty']->value['section']['g']['rownum'] = $_smarty_tpl->tpl_vars['smarty']->value['section']['g']['iteration'];
$_smarty_tpl->tpl_vars['smarty']->value['section']['g']['index_prev'] = $_smarty_tpl->tpl_vars['smarty']->value['section']['g']['index'] - $_smarty_tpl->tpl_vars['smarty']->value['section']['g']['step'];
$_smarty_tpl->tpl_vars['smarty']->value['section']['g']['index_next'] = $_smarty_tpl->tpl_vars['smarty']->value['section']['g']['index'] + $_smarty_tpl->tpl_vars['smarty']->value['section']['g']['step'];
$_smarty_tpl->tpl_vars['smarty']->value['section']['g']['first']      = ($_smarty_tpl->tpl_vars['smarty']->value['section']['g']['iteration'] == 1);
$_smarty_tpl->tpl_vars['smarty']->value['section']['g']['last']       = ($_smarty_tpl->tpl_vars['smarty']->value['section']['g']['iteration'] == $_smarty_tpl->tpl_vars['smarty']->value['section']['g']['total']);
?>
			<OPTION VALUE="<?php echo $_smarty_tpl->tpl_vars['alltype']->value[$_smarty_tpl->getVariable('smarty')->value['section']['g']['index']]['id'];?>
" <?php if ($_smarty_tpl->tpl_vars['alltype']->value[$_smarty_tpl->getVariable('smarty')->value['section']['g']['index']]['id'] == $_smarty_tpl->tpl_vars['type_id']->value) {?>selected<?php }?>><?php echo $_smarty_tpl->tpl_vars['alltype']->value[$_smarty_tpl->getVariable('smarty')->value['section']['g']['index']]['device_type'];?>
</option>
		<?php endfor; endif; ?>
		</select>
	  </td>
	</tr>
	<?php $_smarty_tpl->tpl_vars["trnumber"] = new Smarty_Variable($_smarty_tpl->tpl_vars['trnumber']->value+1, null, 0);?>
	<tr <?php if ($_smarty_tpl->tpl_vars['trnumber']->value%2 == 0) {?>bgcolor="f7f7f7"<?php }?>>
		<td width="15%" align=right>
		IPv4地址
		</td>
		<td width="35%">
		<input type=text name="IP" size=35 value="<?php echo $_smarty_tpl->tpl_vars['IP']->value;?>
" <?php if ($_smarty_tpl->tpl_vars['id']->value) {?>readonly<?php }?>>
	  </td>
	  <td width="15%" align=right>
			IPv6 </td>
		<td width="35%"><input type=text name="ipv6" size=35 value="<?php echo $_smarty_tpl->tpl_vars['ipv6']->value;?>
" >
	  </td>
	</tr>
	<?php $_smarty_tpl->tpl_vars["trnumber"] = new Smarty_Variable($_smarty_tpl->tpl_vars['trnumber']->value+1, null, 0);?>
	<tr <?php if ($_smarty_tpl->tpl_vars['trnumber']->value%2 == 0) {?>bgcolor="f7f7f7"<?php }?>>
		
	  <td width="15%" align=right>
		设备组
		</td>
		<td width="35%" colspan="3">
		<?php echo $_smarty_tpl->getSubTemplate ("select_sgroup_ajax.tpl", $_smarty_tpl->cache_id, $_smarty_tpl->compile_id, 0, $_smarty_tpl->cache_lifetime, array(), 0);
?>
 
			
		</td>
	</tr>

	<?php $_smarty_tpl->tpl_vars["trnumber"] = new Smarty_Variable($_smarty_tpl->tpl_vars['trnumber']->value+1, null, 0);?>
	<tr <?php if ($_smarty_tpl->tpl_vars['trnumber']->value%2 == 0) {?>bgcolor="f7f7f7"<?php }?>>
		<td width="15%" align=right>
		超级管理员口令:	
		</td>
		<td width="35%">
				<input type="password" size=35 name="superpassword" value="<?php echo $_smarty_tpl->tpl_vars['superpassword']->value;?>
"/>
	  </td>
	  <td width="15%" align=right>
		再输一次口令:	
		</td>
		<td width="35%">
				<input type="password" size=35 name="superpassword2" value="<?php echo $_smarty_tpl->tpl_vars['superpassword']->value;?>
"/>
	  </td>

	</tr>
	
	<?php $_smarty_tpl->tpl_vars["trnumber"] = new Smarty_Variable($_smarty_tpl->tpl_vars['trnumber']->value+1, null, 0);?>
	<tr <?php if ($_smarty_tpl->tpl_vars['trnumber']->value%2 == 0) {?>bgcolor="f7f7f7"<?php }?>>
		<td width="15%" align=right>
		修改方式	
		</td>
		<td width="35%">
		<input type='radio' name="stra_type" value='mon' <?php if ($_smarty_tpl->tpl_vars['method']->value == 'mon' || $_smarty_tpl->tpl_vars['method']->value == '') {?>checked<?php }?>>
		按月
		<input type='radio' name="stra_type" value='week' <?php if ($_smarty_tpl->tpl_vars['method']->value == 'week') {?>checked<?php }?>>
		每周
		<input type='radio' name="stra_type" value='custom'<?php if ($_smarty_tpl->tpl_vars['method']->value == 'user') {?>checked<?php }?>>
		自定义
	  </td>
	  <td width="15%" align=right>
		频率
		</td>
		<td width="35%">
		<input type=text name="freq" size=35 value="<?php if ($_smarty_tpl->tpl_vars['freq']->value) {
echo $_smarty_tpl->tpl_vars['freq']->value;
} else { ?>1<?php }?>" >**
		</td>
	</tr>
	<?php $_smarty_tpl->tpl_vars["trnumber"] = new Smarty_Variable($_smarty_tpl->tpl_vars['trnumber']->value+1, null, 0);?>
	<tr <?php if ($_smarty_tpl->tpl_vars['trnumber']->value%2 == 0) {?>bgcolor="f7f7f7"<?php }?>>
		<td colspan='4'>
		**频率的说明：如果修改方式选择每周，这里填写周几（1—7）,如果是按月，填写几号（1—31）,如果是自定义，这里是几日更新一次（大于0的整数）
		</td>
	</tr>
	
<?php if ($_SESSION['ADMIN_LEVEL'] == 1 || $_SESSION['ADMIN_LEVEL'] == 3 || $_SESSION['ADMIN_LEVEL'] == 21 || $_SESSION['ADMIN_LEVEL'] == 101) {?>
	
	<?php $_smarty_tpl->tpl_vars["trnumber"] = new Smarty_Variable($_smarty_tpl->tpl_vars['trnumber']->value+1, null, 0);?>
	<tr <?php if ($_smarty_tpl->tpl_vars['trnumber']->value%2 == 0) {?>bgcolor="f7f7f7"<?php }?>>
		<td width="15%" align=right>
		SSH默认端口	
		</td>
		<td width="35%">
		<input type=text name="sshport" size=35 value="<?php if ($_smarty_tpl->tpl_vars['id']->value) {
echo $_smarty_tpl->tpl_vars['sshport']->value;
} else { ?>22<?php }?>" >
	  </td>
	  <td width="15%" align=right>
		TELNET默认端口	
		</td>
		<td width="35%">
		<input type=text name="telnetport" size=35 value="<?php if ($_smarty_tpl->tpl_vars['id']->value) {
echo $_smarty_tpl->tpl_vars['telnetport']->value;
} else { ?>23<?php }?>" >
	  </td>
	</tr>
	<?php $_smarty_tpl->tpl_vars["trnumber"] = new Smarty_Variable($_smarty_tpl->tpl_vars['trnumber']->value+1, null, 0);?>
	<tr <?php if ($_smarty_tpl->tpl_vars['trnumber']->value%2 == 0) {?>bgcolor="f7f7f7"<?php }?>>
		<td width="15%" align=right>
		FTP默认端口
		</td>
		<td width="35%">
		<input type=text name="ftpport" size=35 value="<?php if ($_smarty_tpl->tpl_vars['id']->value) {
echo $_smarty_tpl->tpl_vars['ftpport']->value;
} else { ?>21<?php }?>" >
	  </td>
	  <td width="15%" align=right>
		RDP默认端口
		</td>
		<td width="35%">
		<input type=text name="rdpport" size=35 value="<?php if ($_smarty_tpl->tpl_vars['id']->value) {
echo $_smarty_tpl->tpl_vars['rdpport']->value;
} else { ?>3389<?php }?>" >
	  </td>
	</tr>
	<?php $_smarty_tpl->tpl_vars["trnumber"] = new Smarty_Variable($_smarty_tpl->tpl_vars['trnumber']->value+1, null, 0);?>
	<tr <?php if ($_smarty_tpl->tpl_vars['trnumber']->value%2 == 0) {?>bgcolor="f7f7f7"<?php }?>>
		<td width="15%" align=right>
		VNC默认端口	
		</td>
		<td width="35%">
		<input type=text name="vncport" size=35 value="<?php if ($_smarty_tpl->tpl_vars['id']->value) {
echo $_smarty_tpl->tpl_vars['vncport']->value;
} else { ?>5900<?php }?>" >
	  </td>
	  <td width="15%" align=right>
		X11默认端口	
		</td>
		<td width="35%">
		<input type=text name="x11port" size=35 value="<?php if ($_smarty_tpl->tpl_vars['id']->value) {
echo $_smarty_tpl->tpl_vars['x11port']->value;
} else { ?>3389<?php }?>" >
	  </td>
	</tr>
<?php } else { ?>
<input type="hidden" name="transport" value="<?php echo $_smarty_tpl->tpl_vars['transport']->value;?>
" >
<input type="hidden" name="sshport" value="<?php if ($_smarty_tpl->tpl_vars['id']->value) {
echo $_smarty_tpl->tpl_vars['sshport']->value;
} else { ?>22<?php }?>" >
<input type="hidden" name="telnetport" value="<?php if ($_smarty_tpl->tpl_vars['id']->value) {
echo $_smarty_tpl->tpl_vars['telnetport']->value;
} else { ?>23<?php }?>" >
<input type="hidden" name="ftpport" value="<?php if ($_smarty_tpl->tpl_vars['id']->value) {
echo $_smarty_tpl->tpl_vars['ftpport']->value;
} else { ?>21<?php }?>" >
<input type="hidden" name="rdpport" value="<?php if ($_smarty_tpl->tpl_vars['id']->value) {
echo $_smarty_tpl->tpl_vars['rdpport']->value;
} else { ?>3389<?php }?>" >
<input type="hidden" name="vncport" value="<?php if ($_smarty_tpl->tpl_vars['id']->value) {
echo $_smarty_tpl->tpl_vars['vncport']->value;
} else { ?>3389<?php }?>" >
<input type="hidden" name="x11port" value="<?php if ($_smarty_tpl->tpl_vars['id']->value) {
echo $_smarty_tpl->tpl_vars['x11port']->value;
} else { ?>3389<?php }?>" >
	<?php }?>
	</table> </div>
				 </div>
				 <div id="content2" class="content" >
				   <div class="contentMain">
				   <table border=0 width=100% cellpadding=5 cellspacing=1 bgcolor="#FFFFFF" valign=top class="BBtable">
				   <TR>
      <TD height="27" colspan="4" class="tb_t_bg">扩展信息</TD>
    </TR>
	<?php $_smarty_tpl->tpl_vars["trnumber"] = new Smarty_Variable($_smarty_tpl->tpl_vars['trnumber']->value+1, null, 0);?>
	<tr <?php if ($_smarty_tpl->tpl_vars['trnumber']->value%2 == 0) {?>bgcolor="f7f7f7"<?php }?>>
		<td width="15%" align=right>
		固定资产名称	
		</td>
		<td width="35%">
		<input type=text name="asset_name" size=35 value="<?php echo $_smarty_tpl->tpl_vars['asset_name']->value;?>
" >
	  </td>
	  <td width="15%" align=right>
		规格型号	
		</td>
		<td width="35%">
		<input type=text name="asset_specification" size=35 value="<?php echo $_smarty_tpl->tpl_vars['asset_specification']->value;?>
" >
	  </td>
	</tr>
	<?php $_smarty_tpl->tpl_vars["trnumber"] = new Smarty_Variable($_smarty_tpl->tpl_vars['trnumber']->value+1, null, 0);?>
	<tr <?php if ($_smarty_tpl->tpl_vars['trnumber']->value%2 == 0) {?>bgcolor="f7f7f7"<?php }?>>
		<td width="15%" align=right>
		部门名称	
		</td>
		<td width="35%">
		<input type=text name="asset_department" size=35 value="<?php echo $_smarty_tpl->tpl_vars['asset_department']->value;?>
" >
	  </td>
	  <td width="15%" align=right>
		存放地点	
		</td>
		<td width="35%">
		<input type=text name="asset_location" size=35 value="<?php echo $_smarty_tpl->tpl_vars['asset_location']->value;?>
" >
	  </td>
	</tr>
	<?php $_smarty_tpl->tpl_vars["trnumber"] = new Smarty_Variable($_smarty_tpl->tpl_vars['trnumber']->value+1, null, 0);?>
	<tr <?php if ($_smarty_tpl->tpl_vars['trnumber']->value%2 == 0) {?>bgcolor="f7f7f7"<?php }?>>
		<td width="15%" align=right>
		支持厂商	
		</td>
		<td width="35%">
		<input type=text name="asset_company" size=35 value="<?php echo $_smarty_tpl->tpl_vars['asset_company']->value;?>
" >
	  </td>
	  <td width="15%" align=right>
		开始使用日期	
		</td>
		<td width="35%">
		<input type=text name="asset_start" id="asset_start" size=35 value="<?php echo $_smarty_tpl->tpl_vars['asset_start']->value;?>
" >&nbsp;&nbsp;<input type="button"  id="f_rangeStart_trigger" name="f_rangeStart_trigger" value="选择时间" class="wbk"> 

	  </td>
	</tr>	
	<?php $_smarty_tpl->tpl_vars["trnumber"] = new Smarty_Variable($_smarty_tpl->tpl_vars['trnumber']->value+1, null, 0);?>
	<tr <?php if ($_smarty_tpl->tpl_vars['trnumber']->value%2 == 0) {?>bgcolor="f7f7f7"<?php }?>>
		<td width="15%" align=right>
		使用年限	
		</td>
		<td width="35%">
		<input type=text name="asset_usedtime" size=35 value="<?php echo $_smarty_tpl->tpl_vars['asset_usedtime']->value;?>
" >
	  </td>
	  <td width="15%" align=right>
		保修日期	
		</td>
		<td width="35%">
		<input type=text name="asset_warrantdate" id="asset_warrantdate" size=35 value="<?php echo $_smarty_tpl->tpl_vars['asset_warrantdate']->value;?>
" >&nbsp;&nbsp;<input type="button"  id="f_rangeEnd_trigger" name="f_rangeEnd_trigger" value="选择时间" class="wbk"> 
	  </td>
	</tr>
	<?php $_smarty_tpl->tpl_vars["trnumber"] = new Smarty_Variable($_smarty_tpl->tpl_vars['trnumber']->value+1, null, 0);?>
	<tr <?php if ($_smarty_tpl->tpl_vars['trnumber']->value%2 == 0) {?>bgcolor="f7f7f7"<?php }?>>
		<td width="15%" align=right>
		使用状况	
		</td>
		<td width="35%">
		<input type=text name="asset_status" size=35 value="<?php echo $_smarty_tpl->tpl_vars['asset_status']->value;?>
" >
	  </td>
	  <td width="15%" align=right>
		</td>
		<td width="35%">
	  </td>
	</tr>
</table>
 </div>
</div>
<?php }?>

 <?php if (!$_smarty_tpl->tpl_vars['appconfigedit']->value) {?>
	<tr id="finalsubmit"><td align="center"><?php if ($_smarty_tpl->tpl_vars['id']->value && $_smarty_tpl->tpl_vars['monitor']->value == 1) {
if (!$_smarty_tpl->tpl_vars['appconfigedit']->value) {?><input type=button <?php if (!$_smarty_tpl->tpl_vars['id']->value) {?>readonly<?php }?> onclick="admin.php?controller=admin_pro&action=server_detect&ip=<?php echo $_smarty_tpl->tpl_vars['IP']->value;?>
"  value="硬件检测" class="an_02"><?php }
}?>&nbsp;&nbsp;&nbsp;&nbsp;<input type=submit  value="保存修改" class="an_02" onclick="save();return true;"></td></tr></table>

</form>
<?php }?>
	</td>
  </tr>
</table>
  <?php echo '<script'; ?>
 type="text/javascript">
var cal = Calendar.setup({
    onSelect: function(cal) { cal.hide() },
    showTime: true,
	popupDirection: 'up'
});
cal.manageFields("f_rangeStart_trigger", "asset_start", "%Y-%m-%d %H:%M:%S");
cal.manageFields("f_rangeEnd_trigger", "asset_warrantdate", "%Y-%m-%d %H:%M:%S");


<?php echo '</script'; ?>
>
<?php echo '<script'; ?>
 language="javascript">
function save(){
}
function my_confirm(str){
	if(!confirm(str + "？"))
	{
		window.event.returnValue = false;
	}
}

function changeport() {
	if(document.getElementById("ssh").selected==true)  {
		f1.port.value = 22;
	}
	if(document.getElementById("telnet").selected==true)  {
		f1.port.value = 23;
	}
}

<?php if ($_SESSION['ADMIN_LEVEL'] == 3 && $_SESSION['ADMIN_MSERVERGROUP']) {?>
var ug = document.getElementById('servergroup');
for(var i=0; i<ug.options.length; i++){
	if(ug.options[i].value==<?php echo $_SESSION['ADMIN_MSERVERGROUP'];?>
){
		ug.selectedIndex=i;
		ug.onchange = function(){ug.selectedIndex=i;}
		break;
	}
}
<?php }?>

<?php echo '</script'; ?>
>
<?php echo '<script'; ?>
>

function opentable(id){
	if(document.getElementById(id).style.display=='none'){
		document.getElementById(id+"_img").src='template/admin/cssjs/img/nolines_minus.gif'
		document.getElementById(id).style.display=''
	}else{
		document.getElementById(id+"_img").src='template/admin/cssjs/img/nolines_plus.gif'
		document.getElementById(id).style.display='none'
	}
    window.parent.reinitIframe();
}
<?php if ($_GET['accounttable']) {?>
opentable('accounttable');
<?php }?>
<?php if ($_GET['apptable']) {?>
opentable('apptable');
<?php }?>


//change_option(<?php if ($_SESSION['CACTI_CONFIG_ON']) {?>4<?php } else { ?>2<?php }?>,<?php echo $_smarty_tpl->tpl_vars['tab']->value;?>
);
<?php if ($_smarty_tpl->tpl_vars['_config']->value['LDAP']) {?>
<?php echo $_smarty_tpl->tpl_vars['changelevelstr']->value;?>

<?php }?>

<?php echo '</script'; ?>
>
</body>
<iframe name="hide" height="0" frameborder="0" scrolling="no"></iframe>
</html>



<?php }
}
?>