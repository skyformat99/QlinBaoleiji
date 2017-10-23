<?php /* Smarty version 3.1.27, created on 2017-05-31 08:06:36
         compiled from "/opt/freesvr/web/htdocs/freesvr/audit/template/admin/passwordkey_list.tpl" */ ?>
<?php
/*%%SmartyHeaderCode:622668741592e090c6d3b01_15475945%%*/
if(!defined('SMARTY_DIR')) exit('no direct access allowed');
$_valid = $_smarty_tpl->decodeProperties(array (
  'file_dependency' => 
  array (
    '2b573a784a4d8574cac52adea6b92731864082f7' => 
    array (
      0 => '/opt/freesvr/web/htdocs/freesvr/audit/template/admin/passwordkey_list.tpl',
      1 => 1474793221,
      2 => 'file',
    ),
  ),
  'nocache_hash' => '622668741592e090c6d3b01_15475945',
  'variables' => 
  array (
    'language' => 0,
    'template_root' => 0,
    'allsession' => 0,
    'session_num' => 0,
    'page_list' => 0,
    'curr_page' => 0,
    'total_page' => 0,
    'items_per_page' => 0,
    'curr_url' => 0,
    'now_table_name' => 0,
  ),
  'has_nocache_code' => false,
  'version' => '3.1.27',
  'unifunc' => 'content_592e090c75c281_43712113',
),false);
/*/%%SmartyHeaderCode%%*/
if ($_valid && !is_callable('content_592e090c75c281_43712113')) {
function content_592e090c75c281_43712113 ($_smarty_tpl) {

$_smarty_tpl->properties['nocache_hash'] = '622668741592e090c6d3b01_15475945';
?>
<!doctype html public "-//w3c//dtd html 4.0 transitional//en">
<html>
<head>
<title><?php echo $_smarty_tpl->tpl_vars['language']->value['PasswordKey'];?>
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
	<li class="me_b"><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an11.jpg" align="absmiddle"/><a href="admin.php?controller=admin_member">用户管理</a><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an33.jpg" align="absmiddle"/></li>
	<li class="me_b"><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an11.jpg" align="absmiddle"/><a href="admin.php?controller=admin_pro&action=dev_index">设备管理</a><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an33.jpg" align="absmiddle"/></li>
	<li class="me_b"><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an11.jpg" align="absmiddle"/><a href="admin.php?controller=admin_pro&action=dev_group">目录管理</a><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an33.jpg" align="absmiddle"/></li>
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
	<li class="me_a"><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an1.jpg" align="absmiddle"/><a href="admin.php?controller=admin_pro&action=passwordkey">密码密钥</a><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an3.jpg" align="absmiddle"/></li>
	<?php if ($_SESSION['ADMIN_LEVEL'] == 1) {?>
    <li class="me_b"><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an11.jpg" align="absmiddle"/><a href="admin.php?controller=admin_member&action=online">在线用户</a><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an33.jpg" align="absmiddle"/></li>
	<?php }?>
</ul>
</div></td></tr>
  <tr>
	<td class="">
		<table bordercolor="white" cellspacing="1" cellpadding="5" border="0" width="100%"  class="BBtable">
		<form name="member_list" action="admin.php?controller=admin_pro&action=deletepasswordkey" method="post">
					<tr>
						<th class="list_bg" bgcolor="d9ecfa" width="2%">选</td>
						<th class="list_bg"  bgcolor="d9ecfa" width="15%"><?php echo $_smarty_tpl->tpl_vars['language']->value['Createdate'];?>
</th>	
						<th class="list_bg"  bgcolor="d9ecfa" width="7%">密码邮件</th>
						<th class="list_bg"  bgcolor="d9ecfa" width="7%">密钥邮件</th>
						<th class="list_bg"  bgcolor="d9ecfa" width="60%">密钥文件</th>
						<th class="list_bg"  bgcolor="d9ecfa" width="7%">操作</th>
					</tr>
					<?php if (isset($_smarty_tpl->tpl_vars['smarty']->value['section']['t'])) unset($_smarty_tpl->tpl_vars['smarty']->value['section']['t']);
$_smarty_tpl->tpl_vars['smarty']->value['section']['t']['name'] = 't';
$_smarty_tpl->tpl_vars['smarty']->value['section']['t']['loop'] = is_array($_loop=$_smarty_tpl->tpl_vars['allsession']->value) ? count($_loop) : max(0, (int) $_loop); unset($_loop);
$_smarty_tpl->tpl_vars['smarty']->value['section']['t']['show'] = true;
$_smarty_tpl->tpl_vars['smarty']->value['section']['t']['max'] = $_smarty_tpl->tpl_vars['smarty']->value['section']['t']['loop'];
$_smarty_tpl->tpl_vars['smarty']->value['section']['t']['step'] = 1;
$_smarty_tpl->tpl_vars['smarty']->value['section']['t']['start'] = $_smarty_tpl->tpl_vars['smarty']->value['section']['t']['step'] > 0 ? 0 : $_smarty_tpl->tpl_vars['smarty']->value['section']['t']['loop']-1;
if ($_smarty_tpl->tpl_vars['smarty']->value['section']['t']['show']) {
    $_smarty_tpl->tpl_vars['smarty']->value['section']['t']['total'] = $_smarty_tpl->tpl_vars['smarty']->value['section']['t']['loop'];
    if ($_smarty_tpl->tpl_vars['smarty']->value['section']['t']['total'] == 0)
        $_smarty_tpl->tpl_vars['smarty']->value['section']['t']['show'] = false;
} else
    $_smarty_tpl->tpl_vars['smarty']->value['section']['t']['total'] = 0;
if ($_smarty_tpl->tpl_vars['smarty']->value['section']['t']['show']):

            for ($_smarty_tpl->tpl_vars['smarty']->value['section']['t']['index'] = $_smarty_tpl->tpl_vars['smarty']->value['section']['t']['start'], $_smarty_tpl->tpl_vars['smarty']->value['section']['t']['iteration'] = 1;
                 $_smarty_tpl->tpl_vars['smarty']->value['section']['t']['iteration'] <= $_smarty_tpl->tpl_vars['smarty']->value['section']['t']['total'];
                 $_smarty_tpl->tpl_vars['smarty']->value['section']['t']['index'] += $_smarty_tpl->tpl_vars['smarty']->value['section']['t']['step'], $_smarty_tpl->tpl_vars['smarty']->value['section']['t']['iteration']++):
$_smarty_tpl->tpl_vars['smarty']->value['section']['t']['rownum'] = $_smarty_tpl->tpl_vars['smarty']->value['section']['t']['iteration'];
$_smarty_tpl->tpl_vars['smarty']->value['section']['t']['index_prev'] = $_smarty_tpl->tpl_vars['smarty']->value['section']['t']['index'] - $_smarty_tpl->tpl_vars['smarty']->value['section']['t']['step'];
$_smarty_tpl->tpl_vars['smarty']->value['section']['t']['index_next'] = $_smarty_tpl->tpl_vars['smarty']->value['section']['t']['index'] + $_smarty_tpl->tpl_vars['smarty']->value['section']['t']['step'];
$_smarty_tpl->tpl_vars['smarty']->value['section']['t']['first']      = ($_smarty_tpl->tpl_vars['smarty']->value['section']['t']['iteration'] == 1);
$_smarty_tpl->tpl_vars['smarty']->value['section']['t']['last']       = ($_smarty_tpl->tpl_vars['smarty']->value['section']['t']['iteration'] == $_smarty_tpl->tpl_vars['smarty']->value['section']['t']['total']);
?>
					<tr <?php if ($_smarty_tpl->tpl_vars['allsession']->value[$_smarty_tpl->getVariable('smarty')->value['section']['t']['index']]['dangerous'] > 1) {?>bgcolor="red"<?php } elseif ($_smarty_tpl->tpl_vars['allsession']->value[$_smarty_tpl->getVariable('smarty')->value['section']['t']['index']]['dangerous'] > 0) {?>bgcolor="yellow" <?php } elseif ($_smarty_tpl->getVariable('smarty')->value['section']['t']['index']%2 == 0) {?>bgcolor="f7f7f7"<?php }?>>
						<td><input type="checkbox" name="chk_member[]" value="<?php echo $_smarty_tpl->tpl_vars['allsession']->value[$_smarty_tpl->getVariable('smarty')->value['section']['t']['index']]['id'];?>
"></td>
						<td><?php echo $_smarty_tpl->tpl_vars['allsession']->value[$_smarty_tpl->getVariable('smarty')->value['section']['t']['index']]['key_date'];?>
</td>
						<td><?php if ($_smarty_tpl->tpl_vars['allsession']->value[$_smarty_tpl->getVariable('smarty')->value['section']['t']['index']]['key_email']) {?>成功<?php } else { ?>失败<?php }?></td>
						<td><?php if ($_smarty_tpl->tpl_vars['allsession']->value[$_smarty_tpl->getVariable('smarty')->value['section']['t']['index']]['zip_email']) {?>成功<?php } else { ?>失败<?php }?></td>
						<td><?php echo $_smarty_tpl->tpl_vars['allsession']->value[$_smarty_tpl->getVariable('smarty')->value['section']['t']['index']]['zip_file'];?>
</td>
						<td>&nbsp;
						<img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/ckico.gif" width="16" height="16" align="absmiddle"><a href="#" onclick="window.open ('admin.php?controller=admin_pro&action=showpasswordkey&id=<?php echo $_smarty_tpl->tpl_vars['allsession']->value[$_smarty_tpl->getVariable('smarty')->value['section']['t']['index']]['id'];?>
', 'newwindow', 'height=150, width=400, top=0, left=0, toolbar=no, menubar=no, scrollbars=no, resizable=yes,location=no, status=no');return false;">查看</a>
						</td>
					</tr>
						
					<?php endfor; endif; ?>
					<tr><td colspan="3" align="left"><input name="select_all" type="checkbox" onClick="javascript:for(var i=0;i<this.form.elements.length;i++){var e=document.member_list.elements[i];if(e.name=='chk_member[]')e.checked=document.member_list.select_all.checked;}" value="checkbox">&nbsp;&nbsp;<input type="submit"  value="删除选中" onClick="my_confirm('确定要删除所选密码密钥?');if(chk_form()) document.member_list.action='admin.php?controller=admin_pro&action=deletepasswordkey'; else return false;" class="an_02">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<input type="button"  value="添加" onClick="javascript:document.location='admin.php?controller=admin_pro&action=passwordkey_edit';" class="an_02"></td>
						<td colspan="4" align="right">
							<?php echo $_smarty_tpl->tpl_vars['language']->value['all'];
echo $_smarty_tpl->tpl_vars['session_num']->value;
echo $_smarty_tpl->tpl_vars['language']->value['Session'];?>
  <?php echo $_smarty_tpl->tpl_vars['page_list']->value;?>
  <?php echo $_smarty_tpl->tpl_vars['language']->value['Page'];?>
：<?php echo $_smarty_tpl->tpl_vars['curr_page']->value;?>
/<?php echo $_smarty_tpl->tpl_vars['total_page']->value;
echo $_smarty_tpl->tpl_vars['language']->value['page'];?>
  <?php echo $_smarty_tpl->tpl_vars['items_per_page']->value;
echo $_smarty_tpl->tpl_vars['language']->value['item'];
echo $_smarty_tpl->tpl_vars['language']->value['Log'];?>
/<?php echo $_smarty_tpl->tpl_vars['language']->value['page'];?>
  <?php echo $_smarty_tpl->tpl_vars['language']->value['Goto'];?>
<input name="pagenum" type="text" class="wbk" size="2" onKeyPress="if(event.keyCode==13) {window.location='<?php echo $_smarty_tpl->tpl_vars['curr_url']->value;?>
&page='+this.value;return false;}"><?php echo $_smarty_tpl->tpl_vars['language']->value['page'];?>
 <!--当前数据表: <?php echo $_smarty_tpl->tpl_vars['now_table_name']->value;?>
--> 
						
						</td>
					</tr>
				</table>
	</td>
  </tr>
</table>
<iframe name="hide" height="0" frameborder="0" scrolling="no"></iframe>
</body>
</html>


<?php }
}
?>