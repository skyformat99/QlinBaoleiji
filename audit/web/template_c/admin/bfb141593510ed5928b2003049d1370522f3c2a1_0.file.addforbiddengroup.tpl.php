<?php /* Smarty version 3.1.27, created on 2017-05-22 19:40:09
         compiled from "/opt/freesvr/web/htdocs/freesvr/audit/template/admin/addforbiddengroup.tpl" */ ?>
<?php
/*%%SmartyHeaderCode:5218793025922ce19470576_70655998%%*/
if(!defined('SMARTY_DIR')) exit('no direct access allowed');
$_valid = $_smarty_tpl->decodeProperties(array (
  'file_dependency' => 
  array (
    'bfb141593510ed5928b2003049d1370522f3c2a1' => 
    array (
      0 => '/opt/freesvr/web/htdocs/freesvr/audit/template/admin/addforbiddengroup.tpl',
      1 => 1483270010,
      2 => 'file',
    ),
  ),
  'nocache_hash' => '5218793025922ce19470576_70655998',
  'variables' => 
  array (
    'title' => 0,
    'template_root' => 0,
    'forbiddengps' => 0,
    'member' => 0,
  ),
  'has_nocache_code' => false,
  'version' => '3.1.27',
  'unifunc' => 'content_5922ce194fc702_27592576',
),false);
/*/%%SmartyHeaderCode%%*/
if ($_valid && !is_callable('content_5922ce194fc702_27592576')) {
function content_5922ce194fc702_27592576 ($_smarty_tpl) {

$_smarty_tpl->properties['nocache_hash'] = '5218793025922ce19470576_70655998';
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
<?php if ($_SESSION['ADMIN_LEVEL'] != 3 && $_SESSION['ADMIN_LEVEL'] != 21 && $_SESSION['ADMIN_LEVEL'] != 101) {?>
	<li class="me_b"><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an11.jpg" align="absmiddle"/><a href="admin.php?controller=admin_config&action=default_policy">默认策略</a><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an33.jpg" align="absmiddle"/></li>
	<?php }?>
    <li class="me_b"><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an11.jpg" align="absmiddle"/><a href="admin.php?controller=admin_pro&action=sourceip">来源IP组</a><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an33.jpg" align="absmiddle"/></li>
    <li class="me_b"><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an11.jpg" align="absmiddle"/><a href="admin.php?controller=admin_member&action=weektime">周组策略</a><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an33.jpg" align="absmiddle"/></li>
	<li class="me_a"><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an1.jpg" align="absmiddle"/><a href="admin.php?controller=admin_forbidden&action=forbidden_groups_list">命令权限</a><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an3.jpg" align="absmiddle"/></li>
	<?php if ($_SESSION['ADMIN_LEVEL'] != 3 && $_SESSION['ADMIN_LEVEL'] != 21 && $_SESSION['ADMIN_LEVEL'] != 101) {?>
	<li class="me_b"><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an11.jpg" align="absmiddle"/><a href="admin.php?controller=admin_config&action=autochange_pwd">自动改密</a><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an33.jpg" align="absmiddle"/></li>
	<li class="me_b"><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an11.jpg" align="absmiddle"/><a href="admin.php?controller=admin_forbidden&action=cmdgroup_list">命令组</a><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an33.jpg" align="absmiddle"/></li>
	<?php }?>
	<?php if ($_SESSION['ADMIN_LEVEL'] != 3 && $_SESSION['ADMIN_LEVEL'] != 21 && $_SESSION['ADMIN_LEVEL'] != 101) {?>
	<li class="me_b"><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an11.jpg" align="absmiddle"/><a href="admin.php?controller=admin_ipacl">授权策略</a><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an33.jpg" align="absmiddle"/></li>
	<?php }?>
	<li class="me_b"><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an11.jpg" align="absmiddle"/><a href="admin.php?controller=admin_workflow&action=workflow_contant">申请描述</a><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an33.jpg" align="absmiddle"/></li>
	<?php if ($_SESSION['LICENSE_KEY_NETMANAGER'] && $_SESSION['CACTI_CONFIG_ON']) {?>
	<li class="me_b"><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an11.jpg" align="absmiddle"/><a href="admin.php?controller=admin_index&action=documentlist">文档上传</a><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an33.jpg" align="absmiddle"/></li>
	<?php }?>
</ul><span class="back_img"><A href="admin.php?controller=admin_forbidden&action=forbidden_groups_list&back=1"><IMG src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/back1.png" 
      width="80" height="30" border="0"></A></span>
</div></td></tr>
  <tr>
	<td class="">

        <table width="100%" border="0" cellspacing="0" cellpadding="0"  class="BBtable">
         <form name="f1" method=post OnSubmit='return check()' action="admin.php?controller=admin_forbidden&action=forbiddengps_save&id=<?php echo $_smarty_tpl->tpl_vars['forbiddengps']->value['gid'];?>
">
		 <tr><th colspan="3" class="list_bg"></th></tr>
	<tr bgcolor="f7f7f7">
		<td width="33%" align=right>
		命令组:
		</td>
		<td width="67%">
		<input type = text name="gname" value="<?php echo $_smarty_tpl->tpl_vars['forbiddengps']->value['gname'];?>
">
	  </td>
	</tr>
	<tr bgcolor="f7f7f7">
		<td width="33%" align=right>
		类型:
		</td>
		<td width="67%">
		<select  class="wbk"  name="black_or_white">
		<option value="1" <?php if ($_smarty_tpl->tpl_vars['forbiddengps']->value['black_or_white']) {?>selected<?php }?>>白名单</option>
		<option value="0" <?php if (!$_smarty_tpl->tpl_vars['forbiddengps']->value['black_or_white']) {?>selected<?php }?>>黑名单</option>
		</select>
	  </td>
	</tr>
	<tr bgcolor="f7f7f7">
		<td width="33%" align=right>
		授权用户:
		</td>
		<td width="67%">
		<select class="wbk"  name="adminuser">
		<option value="0" >无</option>
		<?php if (isset($_smarty_tpl->tpl_vars['smarty']->value['section']['m'])) unset($_smarty_tpl->tpl_vars['smarty']->value['section']['m']);
$_smarty_tpl->tpl_vars['smarty']->value['section']['m']['name'] = 'm';
$_smarty_tpl->tpl_vars['smarty']->value['section']['m']['loop'] = is_array($_loop=$_smarty_tpl->tpl_vars['member']->value) ? count($_loop) : max(0, (int) $_loop); unset($_loop);
$_smarty_tpl->tpl_vars['smarty']->value['section']['m']['show'] = true;
$_smarty_tpl->tpl_vars['smarty']->value['section']['m']['max'] = $_smarty_tpl->tpl_vars['smarty']->value['section']['m']['loop'];
$_smarty_tpl->tpl_vars['smarty']->value['section']['m']['step'] = 1;
$_smarty_tpl->tpl_vars['smarty']->value['section']['m']['start'] = $_smarty_tpl->tpl_vars['smarty']->value['section']['m']['step'] > 0 ? 0 : $_smarty_tpl->tpl_vars['smarty']->value['section']['m']['loop']-1;
if ($_smarty_tpl->tpl_vars['smarty']->value['section']['m']['show']) {
    $_smarty_tpl->tpl_vars['smarty']->value['section']['m']['total'] = $_smarty_tpl->tpl_vars['smarty']->value['section']['m']['loop'];
    if ($_smarty_tpl->tpl_vars['smarty']->value['section']['m']['total'] == 0)
        $_smarty_tpl->tpl_vars['smarty']->value['section']['m']['show'] = false;
} else
    $_smarty_tpl->tpl_vars['smarty']->value['section']['m']['total'] = 0;
if ($_smarty_tpl->tpl_vars['smarty']->value['section']['m']['show']):

            for ($_smarty_tpl->tpl_vars['smarty']->value['section']['m']['index'] = $_smarty_tpl->tpl_vars['smarty']->value['section']['m']['start'], $_smarty_tpl->tpl_vars['smarty']->value['section']['m']['iteration'] = 1;
                 $_smarty_tpl->tpl_vars['smarty']->value['section']['m']['iteration'] <= $_smarty_tpl->tpl_vars['smarty']->value['section']['m']['total'];
                 $_smarty_tpl->tpl_vars['smarty']->value['section']['m']['index'] += $_smarty_tpl->tpl_vars['smarty']->value['section']['m']['step'], $_smarty_tpl->tpl_vars['smarty']->value['section']['m']['iteration']++):
$_smarty_tpl->tpl_vars['smarty']->value['section']['m']['rownum'] = $_smarty_tpl->tpl_vars['smarty']->value['section']['m']['iteration'];
$_smarty_tpl->tpl_vars['smarty']->value['section']['m']['index_prev'] = $_smarty_tpl->tpl_vars['smarty']->value['section']['m']['index'] - $_smarty_tpl->tpl_vars['smarty']->value['section']['m']['step'];
$_smarty_tpl->tpl_vars['smarty']->value['section']['m']['index_next'] = $_smarty_tpl->tpl_vars['smarty']->value['section']['m']['index'] + $_smarty_tpl->tpl_vars['smarty']->value['section']['m']['step'];
$_smarty_tpl->tpl_vars['smarty']->value['section']['m']['first']      = ($_smarty_tpl->tpl_vars['smarty']->value['section']['m']['iteration'] == 1);
$_smarty_tpl->tpl_vars['smarty']->value['section']['m']['last']       = ($_smarty_tpl->tpl_vars['smarty']->value['section']['m']['iteration'] == $_smarty_tpl->tpl_vars['smarty']->value['section']['m']['total']);
?>
		<option value="<?php echo $_smarty_tpl->tpl_vars['member']->value[$_smarty_tpl->getVariable('smarty')->value['section']['m']['index']]['uid'];?>
" <?php if ($_smarty_tpl->tpl_vars['forbiddengps']->value['adminuser'] == $_smarty_tpl->tpl_vars['member']->value[$_smarty_tpl->getVariable('smarty')->value['section']['m']['index']]['uid']) {?>selected<?php }?>><?php echo $_smarty_tpl->tpl_vars['member']->value[$_smarty_tpl->getVariable('smarty')->value['section']['m']['index']]['username'];
echo $_smarty_tpl->tpl_vars['member']->value[$_smarty_tpl->getVariable('smarty')->value['section']['m']['index']]['realname'];?>
</option>
		<?php endfor; endif; ?>
		</select>
	  </td>
	</tr>
	<tr bgcolor="f7f7f7">
		<td width="33%" align=right valign="top">
		描述
		</td>
		<td width="67%">
		<textarea cols="30" rows="10"  name="description"><?php echo $_smarty_tpl->tpl_vars['forbiddengps']->value['desc'];?>
</textarea>
	  </td>
	</tr>
	<tr>
		
		<td align="center" colspan=2><input type="submit"  value=" 提交 " class="an_06">
<input type="hidden" name="add" value="new" />

	</td>
  </tr></form>
</table>

<?php echo '<script'; ?>
 language="javascript">

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

document.getElementById("telnet").selected = true;


<?php echo '</script'; ?>
>
</body>
<iframe name="hide" height="0" frameborder="0" scrolling="no"></iframe>
</html>


<?php }
}
?>