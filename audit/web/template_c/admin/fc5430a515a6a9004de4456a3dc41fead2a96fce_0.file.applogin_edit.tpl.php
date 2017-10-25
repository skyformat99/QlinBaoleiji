<?php /* Smarty version 3.1.27, created on 2017-06-27 05:38:05
         compiled from "/opt/freesvr/web/htdocs/freesvr/audit/template/admin/applogin_edit.tpl" */ ?>
<?php
/*%%SmartyHeaderCode:11981163859517ebdb83155_97528792%%*/
if(!defined('SMARTY_DIR')) exit('no direct access allowed');
$_valid = $_smarty_tpl->decodeProperties(array (
  'file_dependency' => 
  array (
    'fc5430a515a6a9004de4456a3dc41fead2a96fce' => 
    array (
      0 => '/opt/freesvr/web/htdocs/freesvr/audit/template/admin/applogin_edit.tpl',
      1 => 1474793220,
      2 => 'file',
    ),
  ),
  'nocache_hash' => '11981163859517ebdb83155_97528792',
  'variables' => 
  array (
    'title' => 0,
    'template_root' => 0,
    'from' => 0,
    'fromapp' => 0,
    'appserverip' => 0,
    'appdeviceid' => 0,
    'trnumber' => 0,
    'p' => 0,
  ),
  'has_nocache_code' => false,
  'version' => '3.1.27',
  'unifunc' => 'content_59517ebdc57250_48300522',
),false);
/*/%%SmartyHeaderCode%%*/
if ($_valid && !is_callable('content_59517ebdc57250_48300522')) {
function content_59517ebdc57250_48300522 ($_smarty_tpl) {

$_smarty_tpl->properties['nocache_hash'] = '11981163859517ebdb83155_97528792';
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
</head>
<body>


	<table width="100%" border="0" cellspacing="0" cellpadding="0">
<tr><td valign="middle" class="hui_bj"><div class="menu">
<ul>
	<?php if ($_GET['device_ip'] == '') {?>
	<li class="me_a"><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an1.jpg" align="absmiddle"/><a href="admin.php?controller=admin_config&action=appserver_list">应用发布</a><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an3.jpg" align="absmiddle"/></li>
	<?php if ($_SESSION['ADMIN_LEVEL'] != 3) {?>
	<li class="me_b"><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an11.jpg" align="absmiddle"/><a href="admin.php?controller=admin_config&action=appprogram_list">应用程序</a><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an33.jpg" align="absmiddle"/></li>
	<li class="me_b"><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an11.jpg" align="absmiddle"/><a href="admin.php?controller=admin_config&action=appicon_list">应用图标</a><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an33.jpg" align="absmiddle"/></li>
	<?php }?>
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
</ul><span class="back_img"><A href="admin.php?controller=<?php if ($_smarty_tpl->tpl_vars['fromapp']->value == 'search') {?>admin_pro&action=app_priority_search<?php } else { ?>admin_config&action=apppub_list&ip=<?php echo $_smarty_tpl->tpl_vars['appserverip']->value;?>
&device_ip=<?php echo $_GET['device_ip'];
}?>&back=1"><IMG src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/back1.png" 
      width="80" height="30" border="0"></A></span>
</div></td></tr>
  <tr>
	<td class=""><table width="100%" border="0" cellspacing="0" cellpadding="0" >
	
          <tr>
            <td align="center">
    <form name="f1" method=post action="admin.php?controller=admin_app&action=applogin_save&ip=<?php echo $_smarty_tpl->tpl_vars['appserverip']->value;?>
&appdeviceid=<?php echo $_smarty_tpl->tpl_vars['appdeviceid']->value;?>
&device_ip=<?php echo $_GET['device_ip'];?>
">
	<table border=0 width=100% cellpadding=5 cellspacing=0 bgcolor="#FFFFFF" valign=top class="BBtable">
	<tr><th colspan="3" class="list_bg"></th></tr>
		
	<?php $_smarty_tpl->tpl_vars["trnumber"] = new Smarty_Variable(0, null, 0);?>
					<tr <?php if ($_smarty_tpl->tpl_vars['trnumber']->value%2 == 0) {?>bgcolor="f7f7f7"<?php }?>>
		<td width="33%" align=right>登录页面标题</td>
		<td width="67%"><input type="text" name="title" value="<?php echo $_smarty_tpl->tpl_vars['p']->value['title'];?>
" /></td>
	</tr>
	<?php $_smarty_tpl->tpl_vars["trnumber"] = new Smarty_Variable($_smarty_tpl->tpl_vars['trnumber']->value+1, null, 0);?>
					<tr <?php if ($_smarty_tpl->tpl_vars['trnumber']->value%2 == 0) {?>bgcolor="f7f7f7"<?php }?>>
		<td width="33%" align=right>预登录标识</td>
		<td width="67%">
			标签类别:
			<select name="cTagname">
			<option value="button" <?php if ($_smarty_tpl->tpl_vars['p']->value['cTagname'] == 'button') {?>selected<?php }?>>button</option>
			<option value="input" <?php if ($_smarty_tpl->tpl_vars['p']->value['cTagname'] == 'input') {?>selected<?php }?>>input</option>
			<option value="select" <?php if ($_smarty_tpl->tpl_vars['p']->value['cTagname'] == 'select') {?>selected<?php }?>>select</option>
			</select>
			
			标签识别:
			<select name="cTagAttributeType">
			<option value="1" <?php if ($_smarty_tpl->tpl_vars['p']->value['cTagAttributeType'] == 1) {?>selected<?php }?>>id</option>
			<option value="2" <?php if ($_smarty_tpl->tpl_vars['p']->value['cTagAttributeType'] == 2) {?>selected<?php }?>>name</option>
			<option value="3" <?php if ($_smarty_tpl->tpl_vars['p']->value['cTagAttributeType'] == 3) {?>selected<?php }?>>class</option>
			</select>		
			<input type="text" name="cTagAttributeValue" value="<?php echo $_smarty_tpl->tpl_vars['p']->value['cTagAttributeValue'];?>
" />
		</td>
	</tr>

	<?php $_smarty_tpl->tpl_vars["trnumber"] = new Smarty_Variable($_smarty_tpl->tpl_vars['trnumber']->value+1, null, 0);?>
					<tr <?php if ($_smarty_tpl->tpl_vars['trnumber']->value%2 == 0) {?>bgcolor="f7f7f7"<?php }?>>
		<td width="33%" align=right>用户标识</td>
		<td width="67%">
			标签类别:
			<select name="uTagname">
			<option value="button" <?php if ($_smarty_tpl->tpl_vars['p']->value['uTagname'] == 'button') {?>selected<?php }?>>button</option>
			<option value="input" <?php if ($_smarty_tpl->tpl_vars['p']->value['uTagname'] == 'input') {?>selected<?php }?>>input</option>
			<option value="select" <?php if ($_smarty_tpl->tpl_vars['p']->value['uTagname'] == 'select') {?>selected<?php }?>>select</option>
			</select>
			
			标签识别:
			<select name="uTagAttributeType">
			<option value="1" <?php if ($_smarty_tpl->tpl_vars['p']->value['uTagAttributeType'] == 1) {?>selected<?php }?>>id</option>
			<option value="2" <?php if ($_smarty_tpl->tpl_vars['p']->value['uTagAttributeType'] == 2) {?>selected<?php }?>>name</option>
			<option value="3" <?php if ($_smarty_tpl->tpl_vars['p']->value['uTagAttributeType'] == 3) {?>selected<?php }?>>class</option>
			</select>		
			<input type="text" name="uTagAttributeValue" value="<?php echo $_smarty_tpl->tpl_vars['p']->value['uTagAttributeValue'];?>
" />
		</td>
	</tr>
	
		<?php $_smarty_tpl->tpl_vars["trnumber"] = new Smarty_Variable($_smarty_tpl->tpl_vars['trnumber']->value+1, null, 0);?>
					<tr <?php if ($_smarty_tpl->tpl_vars['trnumber']->value%2 == 0) {?>bgcolor="f7f7f7"<?php }?>>
		<td width="33%" align=right>密码标识</td>
		<td width="67%">
			标签类别:
			<select name="pTagname">
			<option value="button" <?php if ($_smarty_tpl->tpl_vars['p']->value['pTagname'] == 'button') {?>selected<?php }?>>button</option>
			<option value="input" <?php if ($_smarty_tpl->tpl_vars['p']->value['pTagname'] == 'input') {?>selected<?php }?>>input</option>
			<option value="select" <?php if ($_smarty_tpl->tpl_vars['p']->value['pTagname'] == 'select') {?>selected<?php }?>>select</option>
			</select>
			
			标签识别:
			<select name="pTagAttributeType">
			<option value="1" <?php if ($_smarty_tpl->tpl_vars['p']->value['pTagAttributeType'] == 1) {?>selected<?php }?>>id</option>
			<option value="2" <?php if ($_smarty_tpl->tpl_vars['p']->value['pTagAttributeType'] == 2) {?>selected<?php }?>>name</option>
			<option value="3" <?php if ($_smarty_tpl->tpl_vars['p']->value['pTagAttributeType'] == 3) {?>selected<?php }?>>class</option>
			</select>		
			<input type="text" name="pTagAttributeValue" value="<?php echo $_smarty_tpl->tpl_vars['p']->value['pTagAttributeValue'];?>
" />
		</td>
	  </tr>
	 
	<?php $_smarty_tpl->tpl_vars["trnumber"] = new Smarty_Variable($_smarty_tpl->tpl_vars['trnumber']->value+1, null, 0);?>
					<tr <?php if ($_smarty_tpl->tpl_vars['trnumber']->value%2 == 0) {?>bgcolor="f7f7f7"<?php }?>>
					<td></td><td><input type="hidden" name="ac" value="new" />
<input type="hidden" name="id" value="<?php echo $_smarty_tpl->tpl_vars['p']->value['uid'];?>
" />
<input type=submit  value="保存修改" class="an_02"></td></tr>
	</table>
</form>
	</td>
  </tr>
</table>
</body>

<iframe name="hide" height="0" frameborder="0" scrolling="no"></iframe>
</html><?php }
}
?>