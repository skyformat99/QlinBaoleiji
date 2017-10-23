<?php /* Smarty version 3.1.27, created on 2017-06-01 22:46:08
         compiled from "/opt/freesvr/web/htdocs/freesvr/audit/template/admin/appserver_edit.tpl" */ ?>
<?php
/*%%SmartyHeaderCode:1887808388593028b0efd459_93752536%%*/
if(!defined('SMARTY_DIR')) exit('no direct access allowed');
$_valid = $_smarty_tpl->decodeProperties(array (
  'file_dependency' => 
  array (
    '9403501d41997fc42fdc8f8dcf73dac43cce67db' => 
    array (
      0 => '/opt/freesvr/web/htdocs/freesvr/audit/template/admin/appserver_edit.tpl',
      1 => 1496328323,
      2 => 'file',
    ),
  ),
  'nocache_hash' => '1887808388593028b0efd459_93752536',
  'variables' => 
  array (
    'title' => 0,
    'template_root' => 0,
    'trnumber' => 0,
    'p' => 0,
    'pserver' => 0,
    'language' => 0,
  ),
  'has_nocache_code' => false,
  'version' => '3.1.27',
  'unifunc' => 'content_593028b103b000_96229881',
),false);
/*/%%SmartyHeaderCode%%*/
if ($_valid && !is_callable('content_593028b103b000_96229881')) {
function content_593028b103b000_96229881 ($_smarty_tpl) {

$_smarty_tpl->properties['nocache_hash'] = '1887808388593028b0efd459_93752536';
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
 <SCRIPT language=javascript src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/selectdate.js"></SCRIPT>
 <SCRIPT type=text/javascript>
var siteUrl = "<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/date";
</SCRIPT>
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
<body>


	<table width="100%" border="0" cellspacing="0" cellpadding="0">
<tr><td valign="middle" class="hui_bj"><div class="menu">
<ul>
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
</ul><span class="back_img"><A href="admin.php?controller=admin_config&action=appserver_list&back=1"><IMG src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/back1.png" 
      width="80" height="30" border="0"></A></span>
</div></td></tr>
  <tr>
	<td class=""><table width="100%" border="0" cellspacing="0" cellpadding="0" >
          <tr>
            <td align="center">
    <form name="f1" method=post action="admin.php?controller=admin_config&action=appserver_save">
	<table border=0 width=100% cellpadding=5 cellspacing=1 bgcolor="#FFFFFF" valign=top class="BBtable">
	<tr><th colspan="3" class="list_bg"></th></tr>
	<?php $_smarty_tpl->tpl_vars["trnumber"] = new Smarty_Variable(0, null, 0);?>
					<tr <?php if ($_smarty_tpl->tpl_vars['trnumber']->value%2 == 0) {?>bgcolor="f7f7f7"<?php }?>>
		<td width="33%" align=right>发布服务器名称</td>
		<td width="67%"><input type="text" name="name" value="<?php echo $_smarty_tpl->tpl_vars['p']->value['name'];?>
" /></td>
	</tr>
	<?php $_smarty_tpl->tpl_vars["trnumber"] = new Smarty_Variable($_smarty_tpl->tpl_vars['trnumber']->value+1, null, 0);?>
	<tr <?php if ($_smarty_tpl->tpl_vars['trnumber']->value%2 == 0) {?>bgcolor="f7f7f7"<?php }?>>
		<td width="33%" align=right>发布服务器IP</td>
		<td width="67%">
		<select name='appserverip' >
		<?php if (isset($_smarty_tpl->tpl_vars['smarty']->value['section']['s'])) unset($_smarty_tpl->tpl_vars['smarty']->value['section']['s']);
$_smarty_tpl->tpl_vars['smarty']->value['section']['s']['name'] = 's';
$_smarty_tpl->tpl_vars['smarty']->value['section']['s']['loop'] = is_array($_loop=$_smarty_tpl->tpl_vars['pserver']->value) ? count($_loop) : max(0, (int) $_loop); unset($_loop);
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
		<option value="<?php echo $_smarty_tpl->tpl_vars['pserver']->value[$_smarty_tpl->getVariable('smarty')->value['section']['s']['index']]['device_ip'];?>
" <?php if ($_smarty_tpl->tpl_vars['p']->value['appserverip'] == $_smarty_tpl->tpl_vars['pserver']->value[$_smarty_tpl->getVariable('smarty')->value['section']['s']['index']]['device_ip']) {?>selected<?php }?>><?php echo $_smarty_tpl->tpl_vars['pserver']->value[$_smarty_tpl->getVariable('smarty')->value['section']['s']['index']]['device_ip'];?>
</option>
		<?php endfor; endif; ?>		
		</select>
		</td>
	  </tr>
	<?php $_smarty_tpl->tpl_vars["trnumber"] = new Smarty_Variable($_smarty_tpl->tpl_vars['trnumber']->value+1, null, 0);?>
	<tr <?php if ($_smarty_tpl->tpl_vars['trnumber']->value%2 == 0) {?>bgcolor="f7f7f7"<?php }?>>
		<td width="33%" align=right>外网NAT IP</td>
		<td width="67%"><input type="text" name="outsideip" value="<?php echo $_smarty_tpl->tpl_vars['p']->value['outsideip'];?>
" /></td>
	</tr>
	<?php $_smarty_tpl->tpl_vars["trnumber"] = new Smarty_Variable($_smarty_tpl->tpl_vars['trnumber']->value+1, null, 0);?>
	<tr <?php if ($_smarty_tpl->tpl_vars['trnumber']->value%2 == 0) {?>bgcolor="f7f7f7"<?php }?>>
		<td width="33%" align=right>服务器描述</td>
		<td width="67%"><textarea name="description" rows=10 cols=50><?php echo $_smarty_tpl->tpl_vars['p']->value['description'];?>
</textarea></td>
	</tr>
	<?php $_smarty_tpl->tpl_vars["trnumber"] = new Smarty_Variable($_smarty_tpl->tpl_vars['trnumber']->value+1, null, 0);?>
	<tr <?php if ($_smarty_tpl->tpl_vars['trnumber']->value%2 == 0) {?>bgcolor="f7f7f7"<?php }?>>
	<td></td><td><input type="hidden" name="ac" value="new" />
<input type="hidden" name="id" value="<?php echo $_smarty_tpl->tpl_vars['p']->value['id'];?>
" />
<input type=submit  value="<?php echo $_smarty_tpl->tpl_vars['language']->value['Save'];?>
" class="an_02"></td></tr>
	</table>
<br>


</form>
	</td>
  </tr>
</table>
</body>
<iframe name="hide" height="0" frameborder="0" scrolling="no"></iframe>
</html>


<?php }
}
?>