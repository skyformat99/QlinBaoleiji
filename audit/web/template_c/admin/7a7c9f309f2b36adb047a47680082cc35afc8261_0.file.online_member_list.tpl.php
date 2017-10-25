<?php /* Smarty version 3.1.27, created on 2017-05-31 08:06:37
         compiled from "/opt/freesvr/web/htdocs/freesvr/audit/template/admin/online_member_list.tpl" */ ?>
<?php
/*%%SmartyHeaderCode:1073148750592e090d205207_97278539%%*/
if(!defined('SMARTY_DIR')) exit('no direct access allowed');
$_valid = $_smarty_tpl->decodeProperties(array (
  'file_dependency' => 
  array (
    '7a7c9f309f2b36adb047a47680082cc35afc8261' => 
    array (
      0 => '/opt/freesvr/web/htdocs/freesvr/audit/template/admin/online_member_list.tpl',
      1 => 1474793220,
      2 => 'file',
    ),
  ),
  'nocache_hash' => '1073148750592e090d205207_97278539',
  'variables' => 
  array (
    'language' => 0,
    'template_root' => 0,
    'online_users' => 0,
    'current_session_id' => 0,
  ),
  'has_nocache_code' => false,
  'version' => '3.1.27',
  'unifunc' => 'content_592e090d2a5605_22537696',
),false);
/*/%%SmartyHeaderCode%%*/
if ($_valid && !is_callable('content_592e090d2a5605_22537696')) {
function content_592e090d2a5605_22537696 ($_smarty_tpl) {

$_smarty_tpl->properties['nocache_hash'] = '1073148750592e090d205207_97278539';
?>
<!doctype html public "-//w3c//dtd html 4.0 transitional//en">
<html>
<head>
<title><?php echo $_smarty_tpl->tpl_vars['language']->value['Master'];
echo $_smarty_tpl->tpl_vars['language']->value['page'];?>
面</title>
<meta name="generator" content="editplus">
<meta name="author" content="nuttycoder">
<link href="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/all_purpose_style.css" rel="stylesheet" type="text/css" />
<?php echo '<script'; ?>
>
	function my_confirm(str){
		if(!confirm("确认要" + str + "？"))
		{
			window.event.returnValue = false;
		}
	}
	function chk_form(){
		for(var i = 0; i < document.member_list.elements.length;i++){
			var e = document.member_list.elements[i];
			if(e.name == 'chk_member[]' && e.checked == true)
				return true;
		}
		alert("您没有<?php echo $_smarty_tpl->tpl_vars['language']->value['select'];?>
任何<?php echo $_smarty_tpl->tpl_vars['language']->value['User'];?>
！");
		return false;
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
	<li class="me_b"><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an11.jpg" align="absmiddle"/><a href="admin.php?controller=admin_pro&action=passwordkey">密码密钥</a><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an33.jpg" align="absmiddle"/></li>
	<?php if ($_SESSION['ADMIN_LEVEL'] == 1) {?>
    <li class="me_a"><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an1.jpg" align="absmiddle"/><a href="admin.php?controller=admin_member&action=online">在线用户</a><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an3.jpg" align="absmiddle"/></li>
	<?php }?>
</ul>
</div></td></tr>

	  <tr><td>
	<form name="member_list" action="admin.php?controller=admin_member&action=offline" method="post">
				<table bordercolor="white" cellspacing="0" cellpadding="5" border="0" width="100%" class="BBtable">
					<tr>
						<th class="list_bg"  width="3%" class="list_bg"><?php echo $_smarty_tpl->tpl_vars['language']->value['select'];?>
</th>
						<th class="list_bg"  width="9%" class="list_bg">用户名</th>
						<th class="list_bg"  width="9%" class="list_bg">用户等级</th>
						<th class="list_bg"  width="9%" class="list_bg">登录时间</th>
						<th class="list_bg"  width="9%" class="list_bg">最近活动时间</th>
						<th class="list_bg"  width="6%" class="list_bg">IP</th>
						<th class="list_bg"  width="24%" class="list_bg"><?php echo $_smarty_tpl->tpl_vars['language']->value['Operate'];
echo $_smarty_tpl->tpl_vars['language']->value['Link'];?>
</th>
					</tr>
					<?php if (isset($_smarty_tpl->tpl_vars['smarty']->value['section']['t'])) unset($_smarty_tpl->tpl_vars['smarty']->value['section']['t']);
$_smarty_tpl->tpl_vars['smarty']->value['section']['t']['name'] = 't';
$_smarty_tpl->tpl_vars['smarty']->value['section']['t']['loop'] = is_array($_loop=$_smarty_tpl->tpl_vars['online_users']->value) ? count($_loop) : max(0, (int) $_loop); unset($_loop);
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
					<tr <?php if ($_smarty_tpl->getVariable('smarty')->value['section']['t']['index']%2 == 0) {?>bgcolor="f7f7f7"<?php }?>>
						<td><?php if ($_smarty_tpl->tpl_vars['online_users']->value[$_smarty_tpl->getVariable('smarty')->value['section']['t']['index']]['ssid'] != $_smarty_tpl->tpl_vars['current_session_id']->value) {?><input type="checkbox" name="chk_member[]" value="<?php echo $_smarty_tpl->tpl_vars['online_users']->value[$_smarty_tpl->getVariable('smarty')->value['section']['t']['index']]['ssid'];?>
"><?php }?></td>
						<td><?php echo $_smarty_tpl->tpl_vars['online_users']->value[$_smarty_tpl->getVariable('smarty')->value['section']['t']['index']]['username'];?>
</td>
						<td><?php if ($_smarty_tpl->tpl_vars['online_users']->value[$_smarty_tpl->getVariable('smarty')->value['section']['t']['index']]['level'] == 1) {?>管理员<?php } elseif ($_smarty_tpl->tpl_vars['online_users']->value[$_smarty_tpl->getVariable('smarty')->value['section']['t']['index']]['level'] == 2) {?>审计员<?php } elseif ($_smarty_tpl->tpl_vars['online_users']->value[$_smarty_tpl->getVariable('smarty')->value['section']['t']['index']]['level'] == 21) {?>部门审计员<?php } elseif ($_smarty_tpl->tpl_vars['online_users']->value[$_smarty_tpl->getVariable('smarty')->value['section']['t']['index']]['level'] == 3) {?>部门管理员<?php } elseif ($_smarty_tpl->tpl_vars['online_users']->value[$_smarty_tpl->getVariable('smarty')->value['section']['t']['index']]['level'] == 10) {?>密码管理员<?php } elseif ($_smarty_tpl->tpl_vars['online_users']->value[$_smarty_tpl->getVariable('smarty')->value['section']['t']['index']]['level'] == 101) {?>部门密码管理员<?php } elseif ($_smarty_tpl->tpl_vars['online_users']->value[$_smarty_tpl->getVariable('smarty')->value['section']['t']['index']]['level'] == 0) {?>运维用户<?php }?></td>
						<td><?php echo $_smarty_tpl->tpl_vars['online_users']->value[$_smarty_tpl->getVariable('smarty')->value['section']['t']['index']]['logindate'];?>
</td>
						<td><?php echo $_smarty_tpl->tpl_vars['online_users']->value[$_smarty_tpl->getVariable('smarty')->value['section']['t']['index']]['lastactime'];?>
</td>
						<td><?php echo $_smarty_tpl->tpl_vars['online_users']->value[$_smarty_tpl->getVariable('smarty')->value['section']['t']['index']]['ip'];?>
</td>
						<td align="center">
						<?php if ($_SESSION['ADMIN_LEVEL'] == 1) {?>
						<?php if ($_smarty_tpl->tpl_vars['online_users']->value[$_smarty_tpl->getVariable('smarty')->value['section']['t']['index']]['ssid'] != $_smarty_tpl->tpl_vars['current_session_id']->value) {?><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/disconnect.png" width="16" height="16" align="absmiddle"><a href="admin.php?controller=admin_member&action=offline&ssid=<?php echo $_smarty_tpl->tpl_vars['online_users']->value[$_smarty_tpl->getVariable('smarty')->value['section']['t']['index']]['ssid'];?>
" >断开</a><?php }
}?>
						</td>
					</tr>
					<?php endfor; endif; ?>
					<tr>
						<td colspan="8" align="left">
							<input name="select_all" type="checkbox" onclick="javascript:for(var i=0;i<this.form.elements.length;i++){var e=this.form.elements[i];if(e.name=='chk_member[]')e.checked=this.form.select_all.checked;}" value="checkbox"><?php echo $_smarty_tpl->tpl_vars['language']->value['select'];
echo $_smarty_tpl->tpl_vars['language']->value['this'];
echo $_smarty_tpl->tpl_vars['language']->value['page'];
echo $_smarty_tpl->tpl_vars['language']->value['displayed'];?>
的<?php echo $_smarty_tpl->tpl_vars['language']->value['All'];
echo $_smarty_tpl->tpl_vars['language']->value['User'];?>
&nbsp;&nbsp;<input type="submit"  value=" 断开选定的用户" onclick="my_confirm('确定要断开用户?');if(chk_form()) document.member_list.action='admin.php?controller=admin_member&action=offline_all'; else return false;" class="an_06">
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