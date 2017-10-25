<?php /* Smarty version 3.1.27, created on 2017-07-03 00:07:51
         compiled from "/opt/freesvr/web/htdocs/freesvr/audit/template/admin/loadbalance_edit.tpl" */ ?>
<?php
/*%%SmartyHeaderCode:77240003359591a577d56c4_02801889%%*/
if(!defined('SMARTY_DIR')) exit('no direct access allowed');
$_valid = $_smarty_tpl->decodeProperties(array (
  'file_dependency' => 
  array (
    'a6a3bef43d80bea24180417bc50945ec07837b6f' => 
    array (
      0 => '/opt/freesvr/web/htdocs/freesvr/audit/template/admin/loadbalance_edit.tpl',
      1 => 1499011630,
      2 => 'file',
    ),
  ),
  'nocache_hash' => '77240003359591a577d56c4_02801889',
  'variables' => 
  array (
    'title' => 0,
    'template_root' => 0,
    'trnumber' => 0,
    'p' => 0,
  ),
  'has_nocache_code' => false,
  'version' => '3.1.27',
  'unifunc' => 'content_59591a57838264_37298941',
),false);
/*/%%SmartyHeaderCode%%*/
if ($_valid && !is_callable('content_59591a57838264_37298941')) {
function content_59591a57838264_37298941 ($_smarty_tpl) {

$_smarty_tpl->properties['nocache_hash'] = '77240003359591a577d56c4_02801889';
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
 <SCRIPT language=javascript src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/selectdate.js"></SCRIPT>
 <SCRIPT type=text/javascript>
var siteUrl = "<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/date";
</SCRIPT>
<body>


	<table width="100%" border="0" cellspacing="0" cellpadding="0" >
<tr><td valign="middle" class="hui_bj"><div class="menu">
<ul>

	<li class="me_b"><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an11.jpg" align="absmiddle"/><a href="admin.php?controller=admin_config&action=config_ssh">认证配置</a><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an33.jpg" align="absmiddle"/></li>
	<li class="me_b"><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an11.jpg" align="absmiddle"/><a href="admin.php?controller=admin_config&action=certs">证书配置</a><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an33.jpg" align="absmiddle"/></li>
    <li class="me_b"><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an11.jpg" align="absmiddle"/><a href="admin.php?controller=admin_config&action=config_ftp">系统参数</a><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an33.jpg" align="absmiddle"/></li>
    <li class="me_b"><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an11.jpg" align="absmiddle"/><a href="admin.php?controller=admin_config&action=login_times">密码策略</a><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an33.jpg" align="absmiddle"/></li>
	<li class="me_b"><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an11.jpg" align="absmiddle"/><a href="admin.php?controller=admin_config&action=syslog_mail_alarm">告警配置</a><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an33.jpg" align="absmiddle"/></li>
	<li class="me_b"><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an11.jpg" align="absmiddle"/><a href="admin.php?controller=admin_config&action=status_warning">告警参数</a><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an33.jpg" align="absmiddle"/></li>
	<li class="me_a"><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an1.jpg" align="absmiddle"/><a href="admin.php?controller=admin_config&action=loadbalance">负载均衡</a><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an3.jpg" align="absmiddle"/></li>
</ul><span class="back_img"><A href="admin.php?controller=admin_config&action=loadbalance&back=1"><IMG src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/back1.png" 
      width="80" height="30" border="0"></A></span>
</div></td></tr>
<table width="100%" border="0" cellspacing="0" cellpadding="0"  class="BBtable">
<form name="f1" method=post action="admin.php?controller=admin_config&action=loadbalance">
          <tr><th colspan="3" class="list_bg"></th></tr>
	<?php $_smarty_tpl->tpl_vars["trnumber"] = new Smarty_Variable(0, null, 0);?>
					<tr <?php if ($_smarty_tpl->tpl_vars['trnumber']->value%2 == 0) {?>bgcolor="f7f7f7"<?php }?>>
		<td width="33%" align=right>IP</td>
		<td width="67%"><input type="text" name="ip" value="<?php echo $_smarty_tpl->tpl_vars['p']->value['ip'];?>
" /></td>
	</tr>
	
		<?php $_smarty_tpl->tpl_vars["trnumber"] = new Smarty_Variable($_smarty_tpl->tpl_vars['trnumber']->value+1, null, 0);?>
					<tr <?php if ($_smarty_tpl->tpl_vars['trnumber']->value%2 == 0) {?>bgcolor="f7f7f7"<?php }?>>
		<td width="33%" align=right>主机名</td>
		<td width="67%"><input type="text"  name="hostname" value="<?php echo $_smarty_tpl->tpl_vars['p']->value['hostname'];?>
" /></td>
	  </tr>
		 	 
	<?php $_smarty_tpl->tpl_vars["trnumber"] = new Smarty_Variable($_smarty_tpl->tpl_vars['trnumber']->value+1, null, 0);?>
					<tr <?php if ($_smarty_tpl->tpl_vars['trnumber']->value%2 == 0) {?>bgcolor="f7f7f7"<?php }?>>
					<td  align="center" colspan=2><input type="hidden" name="ac" value="<?php if ($_smarty_tpl->tpl_vars['p']->value['sid']) {?>modify<?php } else { ?>new<?php }?>" />
<input type="hidden" name="id" value="<?php echo $_smarty_tpl->tpl_vars['p']->value['sid'];?>
" />
<input type=submit  value="保存修改" class="an_02">

	</td>
  </tr></form>
</table>
</body>
<iframe name="hide" height="0" frameborder="0" scrolling="no"></iframe>
</html>



<?php }
}
?>