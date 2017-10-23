<?php /* Smarty version 3.1.27, created on 2017-06-26 17:34:05
         compiled from "/opt/freesvr/web/htdocs/freesvr/audit/template/admin/createrdpfile.tpl" */ ?>
<?php
/*%%SmartyHeaderCode:6732907885950d50d87e761_01737304%%*/
if(!defined('SMARTY_DIR')) exit('no direct access allowed');
$_valid = $_smarty_tpl->decodeProperties(array (
  'file_dependency' => 
  array (
    'e18a142c274c49314225724004cdce64d03f2368' => 
    array (
      0 => '/opt/freesvr/web/htdocs/freesvr/audit/template/admin/createrdpfile.tpl',
      1 => 1474793221,
      2 => 'file',
    ),
  ),
  'nocache_hash' => '6732907885950d50d87e761_01737304',
  'variables' => 
  array (
    'site_title' => 0,
    'template_root' => 0,
    'language' => 0,
    'eth0' => 0,
    'm_bydomain' => 0,
    'r_bydomain' => 0,
    's_bydomain' => 0,
    'x_bydomain' => 0,
  ),
  'has_nocache_code' => false,
  'version' => '3.1.27',
  'unifunc' => 'content_5950d50d8c6205_62111448',
),false);
/*/%%SmartyHeaderCode%%*/
if ($_valid && !is_callable('content_5950d50d8c6205_62111448')) {
function content_5950d50d8c6205_62111448 ($_smarty_tpl) {

$_smarty_tpl->properties['nocache_hash'] = '6732907885950d50d87e761_01737304';
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


<table width="100%" border="0" cellspacing="0" cellpadding="0"><tr><td valign="middle" class="hui_bj"><div class="menu">
<ul>

    <li class="me_a"><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an1.jpg" align="absmiddle"/><a href="admin.php?controller=admin_index&action=createrdpfile">列表导出</a><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an3.jpg" align="absmiddle"/></li>
</ul>
</div></td></tr>
  <tr>
	<td class=""><table bordercolor="white" cellspacing="1" cellpadding="5" border="0" width="100%" class="BBtable">
		
			<form name="backup" enctype="multipart/form-data" action="admin.php?controller=admin_index&action=createrdpfile&tool=mremote" method="post">	
			<tr>
			<td>mRemote</td>
			<td>堡垒机IP:<input name="baoleijiip" id="" value="<?php echo $_smarty_tpl->tpl_vars['eth0']->value;?>
" type="text" width=50 />&nbsp;&nbsp;&nbsp;&nbsp;端口:<input name="port" id="" value="3389" type="text" width=50 />&nbsp;&nbsp;&nbsp;&nbsp;域名连接:<input type="checkbox" name="m_bydomain" id="m_bydomain" <?php if ($_smarty_tpl->tpl_vars['m_bydomain']->value) {?>checked<?php }?> value="1"  />&nbsp;&nbsp;&nbsp;&nbsp;<input name="submit" type="submit" class="an_02" value="列表下载" /></td>
			</tr>
			</form>

			<form name="backup" enctype="multipart/form-data" action="admin.php?controller=admin_index&action=createrdpfile&tool=rdcman" method="post">	
			<tr>
			<td>RDCMAN</td>
			<td>堡垒机IP:<input name="baoleijiip" id="" value="<?php echo $_smarty_tpl->tpl_vars['eth0']->value;?>
" type="text" width=50 />&nbsp;&nbsp;&nbsp;&nbsp;端口:<input name="port" id="" value="3389" type="text" width=50 />&nbsp;&nbsp;&nbsp;&nbsp;域名连接:<input type="checkbox" name="r_bydomain" id="r_bydomain" <?php if ($_smarty_tpl->tpl_vars['r_bydomain']->value) {?>checked<?php }?> value="1"  />&nbsp;&nbsp;&nbsp;&nbsp;<input name="submit" type="submit" class="an_02" value="列表下载" /></td>
			</tr>
			</form>

			<form name="backup" enctype="multipart/form-data" action="admin.php?controller=admin_index&action=createrdpfile&tool=securecrt" method="post" target="hide">	
			<tr>
			<td>SecureCRT</td>
			<td>堡垒机IP:<input name="baoleijiip" id="" value="<?php echo $_smarty_tpl->tpl_vars['eth0']->value;?>
" type="text" width=50 />&nbsp;&nbsp;&nbsp;&nbsp;端口:<input name="port" id="" value="22" type="text" width=50 />&nbsp;&nbsp;&nbsp;&nbsp;默认:<select name="template" ><option value="">无</option><option value="6">SecureCRT6</option><option value="6">SecureCRT7</option></select>模版:<input name="crttemplate" id="" type="file" width=50 />&nbsp;&nbsp;<br />终端类型:<select name="term" ><option value="ANSI">ANSI</option><option value="Linux">Linux</option><option value="VT100">VT100</option><option value="Xterm">Xterm</option></select>字符集:<select name="charset" ><option value="Default">Default</option><option value="UTF-8">UTF-8</option></select>配色方案:<select name="colorscheme" ><option value="Monochrome">Monochrome</option><option value="Traditional">Traditional</option><option value="Windows">Windows</option></select>&nbsp;&nbsp;域名连接:<input type="checkbox" name="s_bydomain" id="s_bydomain" <?php if ($_smarty_tpl->tpl_vars['s_bydomain']->value) {?>checked<?php }?> value="1"  />&nbsp;&nbsp;&nbsp;&nbsp;<input name="submit" type="submit"  class="an_02" value="列表下载" /></td>
			</tr>
			</form>
			<form name="backup" enctype="multipart/form-data" action="admin.php?controller=admin_index&action=createrdpfile&tool=xshell" method="post" target="hide">	
			<tr>
			<td>Xshell</td>
			<td>堡垒机IP:<input name="baoleijiip" id="" value="<?php echo $_smarty_tpl->tpl_vars['eth0']->value;?>
" type="text" width=50 />&nbsp;&nbsp;&nbsp;&nbsp;端口:<input name="port" id="" value="22" type="text" width=50 />&nbsp;&nbsp;&nbsp;&nbsp;默认:<select name="template" ><option value="">无</option><option value="3">XShell3</option><option value="4">XShell4</option></select>模版:<input name="xshelltemplate" id="" type="file" width=50 />&nbsp;&nbsp;&nbsp;&nbsp;域名连接:<input type="checkbox" name="x_bydomain" id="x_bydomain" <?php if ($_smarty_tpl->tpl_vars['x_bydomain']->value) {?>checked<?php }?> value="1"  />&nbsp;&nbsp;&nbsp;&nbsp;<input name="submit" type="submit" class="an_02" value="列表下载" /></td>
			</tr>
			</form>
		</table>
	</td>
  </tr>
</table>
<iframe name="hide" height="0" frameborder="0" scrolling="no" id="hide"></iframe>
</body>
</html>


<?php }
}
?>