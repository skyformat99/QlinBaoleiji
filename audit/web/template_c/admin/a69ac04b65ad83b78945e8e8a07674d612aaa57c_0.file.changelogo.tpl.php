<?php /* Smarty version 3.1.27, created on 2017-06-15 09:45:38
         compiled from "/opt/freesvr/web/htdocs/freesvr/audit/template/admin/changelogo.tpl" */ ?>
<?php
/*%%SmartyHeaderCode:16101493415941e6c2585391_41162154%%*/
if(!defined('SMARTY_DIR')) exit('no direct access allowed');
$_valid = $_smarty_tpl->decodeProperties(array (
  'file_dependency' => 
  array (
    'a69ac04b65ad83b78945e8e8a07674d612aaa57c' => 
    array (
      0 => '/opt/freesvr/web/htdocs/freesvr/audit/template/admin/changelogo.tpl',
      1 => 1496889844,
      2 => 'file',
    ),
  ),
  'nocache_hash' => '16101493415941e6c2585391_41162154',
  'variables' => 
  array (
    'site_title' => 0,
    'template_root' => 0,
    'language' => 0,
  ),
  'has_nocache_code' => false,
  'version' => '3.1.27',
  'unifunc' => 'content_5941e6c25cad75_71951836',
),false);
/*/%%SmartyHeaderCode%%*/
if ($_valid && !is_callable('content_5941e6c25cad75_71951836')) {
function content_5941e6c25cad75_71951836 ($_smarty_tpl) {

$_smarty_tpl->properties['nocache_hash'] = '16101493415941e6c2585391_41162154';
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

	<table width="100%" border="0" cellspacing="0" cellpadding="0">
<tr><td valign="middle" class="hui_bj"><div class="menu">
<ul>
	<li class="me_b"><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an11.jpg" align="absmiddle"/><a href="admin.php?controller=admin_eth&action=serverstatus">服务状态</a><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an33.jpg" align="absmiddle"/></li>
	<li class="me_b"><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an11.jpg" align="absmiddle"/><a href="admin.php?controller=admin_status&action=latest">系统状态</a><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an33.jpg" align="absmiddle"/></li>
	<li class="me_b"><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an11.jpg" align="absmiddle"/><a href="admin.php?controller=admin_config&action=ha">双机配置</a><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an33.jpg" align="absmiddle"/></li>
	<li class="me_b"><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an11.jpg" align="absmiddle"/><a href="admin.php?controller=admin_backup">配置备份</a><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an33.jpg" align="absmiddle"/></li>
	<li class="me_b"><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an11.jpg" align="absmiddle"/><a href="admin.php?controller=admin_backup&action=backup_setting">数据同步</a><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an33.jpg" align="absmiddle"/></li>
	<li class="me_b"><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an11.jpg" align="absmiddle"/><a href="admin.php?controller=admin_backup&action=upgrade">软件升级</a><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an33.jpg" align="absmiddle"/></li>
	<li class="me_b"><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an11.jpg" align="absmiddle"/><a href="admin.php?controller=admin_backup&action=cronjob">定时任务</a><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an33.jpg" align="absmiddle"/></li>
	<li class="me_a"><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an1.jpg" align="absmiddle"/><a href="admin.php?controller=admin_index&action=changelogo">图标上传</a><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an3.jpg" align="absmiddle"/></li>
	<li class="me_b"><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an11.jpg" align="absmiddle"/><a href="admin.php?controller=admin_config&action=notice">系统通知</a><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an33.jpg" align="absmiddle"/></li>
</ul>
</div></td></tr>
  <tr>
	<td class=""><table width="100%" border="0" cellspacing="0" cellpadding="0"  class="BBtable">
              <form action="admin.php?controller=admin_index&action=changelogo" method="post" enctype="multipart/form-data" >
			  <tr><th colspan="3" class="list_bg">logo替换</th></tr>
		<tr >
			<td width="10%" height="16" align="center" ><b>上传登录页面logo:</b></td>
			<td align="left" width="30%">
			<img src="logo/logo1.jpg" ><br /><br />
			<input type="file" name="login_logo" />
			</td>
		</tr>	
		<tr >
			<td width="10%" height="16" align="center" ><b>上传内页顶部logo:</b></td>
			<td align="left" width="30%">
			<img src="logo/02.jpg" ><br /><br />
			<input type="file" name="top_logo" />
			</td>
		</tr>	
		<tr >
			<td width="10%" height="16" align="center" ><b>安卓动态口令扫描码图片:</b></td>
			<td align="left" width="30%">
			<img src="logo/android.jpg" ><br /><br />
			<input type="file" name="android" />
			</td>
		</tr>	
		<tr >
			<td width="10%" height="16" align="center" ><b>苹果动态口令扫描码图片:</b></td>
			<td align="left" width="30%">
			<img src="logo/ios.jpg" ><br /><br />
			<input type="file" name="ios" />
			</td>
		</tr>	
		<tr >
			<td  align="center" colspan=2>
			<input type="submit" name="submit"  value="提交" class="an_02">
			</td>
		</tr>		
		
	</form>

        </table>
	</td>
  </tr> 
</table>
</body>
</html>


<?php }
}
?>