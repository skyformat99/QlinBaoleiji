<?php /* Smarty version 3.1.27, created on 2017-08-08 09:55:51
         compiled from "/opt/freesvr/web/htdocs/freesvr/audit/template/admin/checkpass.tpl" */ ?>
<?php
/*%%SmartyHeaderCode:88994332759891a27a6ab92_01495496%%*/
if(!defined('SMARTY_DIR')) exit('no direct access allowed');
$_valid = $_smarty_tpl->decodeProperties(array (
  'file_dependency' => 
  array (
    '01ca675e63683bb92d1d0278633e64622de17bc0' => 
    array (
      0 => '/opt/freesvr/web/htdocs/freesvr/audit/template/admin/checkpass.tpl',
      1 => 1474793222,
      2 => 'file',
    ),
  ),
  'nocache_hash' => '88994332759891a27a6ab92_01495496',
  'variables' => 
  array (
    'title' => 0,
    'template_root' => 0,
    'id' => 0,
    'language' => 0,
  ),
  'has_nocache_code' => false,
  'version' => '3.1.27',
  'unifunc' => 'content_59891a27abee81_32916549',
),false);
/*/%%SmartyHeaderCode%%*/
if ($_valid && !is_callable('content_59891a27abee81_32916549')) {
function content_59891a27abee81_32916549 ($_smarty_tpl) {

$_smarty_tpl->properties['nocache_hash'] = '88994332759891a27a6ab92_01495496';
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
</head>

<body>



	<table width="100%" border="0" cellspacing="0" cellpadding="0">
  <tr><td valign="middle" class="hui_bj"><div class="menu">
<ul>

<?php if ($_SESSION['ADMIN_LEVEL'] == 10 || $_SESSION['ADMIN_LEVEL'] == 101) {?>
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
<?php }?>
<?php if ($_SESSION['ADMIN_LEVEL'] != 10 && $_SESSION['ADMIN_LEVEL'] != 101) {?>
    <li class="me_b"><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an11.jpg" align="absmiddle"/><a href="admin.php?controller=admin_pro&action=dev_group">设备目录</a><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an33.jpg" align="absmiddle"/></li>
	<?php }?>
</ul>
</div></td></tr>
  <tr>
	<td class="">

        <table width="100%" border="0" cellspacing="0" cellpadding="0">
          <tr>
            <td align="center"><form name="f1" method=post OnSubmit='return check()' action="admin.php?controller=admin_pro&action=dev_viewpass&id=<?php echo $_smarty_tpl->tpl_vars['id']->value;?>
">
	<table border=0 width=100% cellpadding=5 cellspacing=1 bgcolor="#FFFFFF" valign=top>
	<tr bgcolor="f7f7f7">
		<td width="33%" align=right>
		<?php echo $_smarty_tpl->tpl_vars['language']->value['Administrator'];?>
ID	
		</td>
		<td width="67%">
		<input type=text name="username" value="admin" readonly size=35>
	  </td>
	</tr>
		<tr bgcolor="f7f7f7">
		<td width="33%" align=right>
		<?php echo $_smarty_tpl->tpl_vars['language']->value['Password'];?>
	
		</td>
		<td width="67%">
		<input type="password" name="password" size=35>
	  </td>
	</tr>
	<tr><td></td><td><input type=submit  value="<?php echo $_smarty_tpl->tpl_vars['language']->value['View'];?>
" class="an_02"></td></tr></table>

</form>
	</td>
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