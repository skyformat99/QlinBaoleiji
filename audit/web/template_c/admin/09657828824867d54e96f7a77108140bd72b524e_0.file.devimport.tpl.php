<?php /* Smarty version 3.1.27, created on 2017-06-29 14:53:50
         compiled from "/opt/freesvr/web/htdocs/freesvr/audit/template/admin/devimport.tpl" */ ?>
<?php
/*%%SmartyHeaderCode:1630817085954a3fe5d2621_49444658%%*/
if(!defined('SMARTY_DIR')) exit('no direct access allowed');
$_valid = $_smarty_tpl->decodeProperties(array (
  'file_dependency' => 
  array (
    '09657828824867d54e96f7a77108140bd72b524e' => 
    array (
      0 => '/opt/freesvr/web/htdocs/freesvr/audit/template/admin/devimport.tpl',
      1 => 1474793220,
      2 => 'file',
    ),
  ),
  'nocache_hash' => '1630817085954a3fe5d2621_49444658',
  'variables' => 
  array (
    'site_title' => 0,
    'template_root' => 0,
    'language' => 0,
    'from' => 0,
    'gid' => 0,
  ),
  'has_nocache_code' => false,
  'version' => '3.1.27',
  'unifunc' => 'content_5954a3fe64b998_30112448',
),false);
/*/%%SmartyHeaderCode%%*/
if ($_valid && !is_callable('content_5954a3fe64b998_30112448')) {
function content_5954a3fe64b998_30112448 ($_smarty_tpl) {

$_smarty_tpl->properties['nocache_hash'] = '1630817085954a3fe5d2621_49444658';
?>
<!doctype html public "-//w3c//dtd html 4.0 transitional//en">
<html>
<head>
<title><?php echo $_smarty_tpl->tpl_vars['site_title']->value;?>
</title>
<meta name="generator" content="editplus">
<meta name="author" content="nuttycoder">
<link href="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/all_purpose_style.css" rel="stylesheet" type="text/css" />
<?php echo '<script'; ?>
>
function resto()
{
 if(document.getElementById('filesql').value=='' ){
   alert("<?php echo $_smarty_tpl->tpl_vars['language']->value['UploadFile'];?>
");
   return false;
  }
  return true;
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
<?php if ($_SESSION['ADMIN_LEVEL'] == 10 || $_SESSION['ADMIN_LEVEL'] == 101) {?>
<li class="me_b"><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an11.jpg" align="absmiddle"/><a href="admin.php?controller=admin_index&action=main">密码查看</a><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an33.jpg" align="absmiddle"/></li>
<li class="me_b"><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an11.jpg" align="absmiddle"/><a href="admin.php?controller=admin_pro&action=passwordedit">修改密码</a><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an33.jpg" align="absmiddle"/></li>
<?php if ($_SESSION['ADMIN_LEVEL'] == 10) {?>
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
</ul><span class="back_img"><A href="admin.php?controller=admin_pro&action=dev_index&gid=<?php echo $_smarty_tpl->tpl_vars['gid']->value;?>
&back=1"><IMG src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/back1.png" 
      width="80" height="30" border="0"></A></span>
</div></td></tr>
  <tr>
	<td class=""><table width="100%" border="0" cellspacing="0" cellpadding="0" >
	
            <tr>
              <td align="center">
              <form action="admin.php?controller=admin_pro&action=dodevimport" method="post" enctype="multipart/form-data" >
              <TABLE border=0 cellSpacing=0 cellPadding=5 
                                width="100%" bgColor=#ffffff valign="top"  class="BBtable">
                <TBODY>		
				<tr><th colspan="2" class="list_bg">&nbsp;导入设备用户</th></tr>
		<tr >
			<td width="10%" height="16" align="center" ><b>文件</b></td>
			<td align="left" width="30%">
			加密<input type="checkbox" name="encrypt" checked value="1" >&nbsp;&nbsp;<input type="file" name="devfile" />&nbsp;&nbsp;
			</td>
		</tr>	
		<tr >
			<td width="10%" height="16" align="center" ></td>
			<td align="left" width="30%">
			<input type="submit" name="submit" value="提交" class="an_02" />
			</td>
		</tr>		
		
		</TBODY>
              </TABLE>
              </form>
              </td>

        </table>
	</td>
  </tr>
</table>
</body>
</html>


<?php }
}
?>