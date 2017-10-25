<?php /* Smarty version 3.1.27, created on 2017-08-11 15:43:28
         compiled from "/opt/freesvr/web/htdocs/freesvr/audit/template/admin/loadbalance.tpl" */ ?>
<?php
/*%%SmartyHeaderCode:682392862598d6020d4b2a1_15716104%%*/
if(!defined('SMARTY_DIR')) exit('no direct access allowed');
$_valid = $_smarty_tpl->decodeProperties(array (
  'file_dependency' => 
  array (
    'abc7916a520c50488d549a5c2e11c6f5491f4185' => 
    array (
      0 => '/opt/freesvr/web/htdocs/freesvr/audit/template/admin/loadbalance.tpl',
      1 => 1499420329,
      2 => 'file',
    ),
  ),
  'nocache_hash' => '682392862598d6020d4b2a1_15716104',
  'variables' => 
  array (
    'template_root' => 0,
    'orderby2' => 0,
    'lb' => 0,
    'command_num' => 0,
    'page_list' => 0,
    'curr_page' => 0,
    'total_page' => 0,
    'items_per_page' => 0,
  ),
  'has_nocache_code' => false,
  'version' => '3.1.27',
  'unifunc' => 'content_598d6020dbdb43_00890820',
),false);
/*/%%SmartyHeaderCode%%*/
if ($_valid && !is_callable('content_598d6020dbdb43_00890820')) {
function content_598d6020dbdb43_00890820 ($_smarty_tpl) {

$_smarty_tpl->properties['nocache_hash'] = '682392862598d6020d4b2a1_15716104';
?>
<!doctype html public "-//w3c//dtd html 4.0 transitional//en">
<html>
<head>
<title>主页面</title>
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
</ul>
</div></td></tr>
  <tr>
	<td class="">
		<table bordercolor="white" cellspacing="1" cellpadding="5" border="0" width="100%"  class="BBtable">
<form name="f1" method=post OnSubmit='return check()' action="admin.php?controller=admin_config&action=loadbalance">
	
<tr>
				<th class="list_bg"  width="3%">选择</th>
				<th class="list_bg"  width="20%"><a href="admin.php?controller=admin_config&action=loadbalance&orderby1=ip&orderby2=<?php echo $_smarty_tpl->tpl_vars['orderby2']->value;?>
" >IP</a></th>
				<th class="list_bg"  width="20%"><a href="admin.php?controller=admin_config&action=loadbalance&orderby1=hostname&orderby2=<?php echo $_smarty_tpl->tpl_vars['orderby2']->value;?>
" >主机名</a></th>
				<th class="list_bg"  width="15%">操作</th>
			</tr>
			
			
			<?php if (isset($_smarty_tpl->tpl_vars['smarty']->value['section']['t'])) unset($_smarty_tpl->tpl_vars['smarty']->value['section']['t']);
$_smarty_tpl->tpl_vars['smarty']->value['section']['t']['name'] = 't';
$_smarty_tpl->tpl_vars['smarty']->value['section']['t']['loop'] = is_array($_loop=$_smarty_tpl->tpl_vars['lb']->value) ? count($_loop) : max(0, (int) $_loop); unset($_loop);
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
				<td><input type="checkbox" name="chk_sid[]" value="<?php echo $_smarty_tpl->tpl_vars['lb']->value[$_smarty_tpl->getVariable('smarty')->value['section']['t']['index']]['sid'];?>
"></td>
				<td><?php echo $_smarty_tpl->tpl_vars['lb']->value[$_smarty_tpl->getVariable('smarty')->value['section']['t']['index']]['ip'];?>
</td>
				<td><?php echo $_smarty_tpl->tpl_vars['lb']->value[$_smarty_tpl->getVariable('smarty')->value['section']['t']['index']]['hostname'];?>
</td>
				<td>
				<img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/edit_ico.gif" width="16" height="16" align="absmiddle"><a href="admin.php?controller=admin_config&action=loadbalance_edit&id=<?php echo $_smarty_tpl->tpl_vars['lb']->value[$_smarty_tpl->getVariable('smarty')->value['section']['t']['index']]['sid'];?>
">编辑</a>
				 | <img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/scico.gif" width="16" height="16" align="absmiddle"><a href="admin.php?controller=admin_config&action=loadbalance&delete=<?php echo $_smarty_tpl->tpl_vars['lb']->value[$_smarty_tpl->getVariable('smarty')->value['section']['t']['index']]['sid'];?>
">删除</a>
				</td>
			</tr>
			<?php endfor; endif; ?>
			
			<tr>
				<td colspan="2" align="left">
					<input name="select_all" type="checkbox" onclick="javascript:for(var i=0;i < this.form.elements.length;i++){var e=this.form.elements[i];if(e.name=='chk_sid[]')e.checked=this.form.select_all.checked;}" value="checkbox">选中本页显示的所有项目&nbsp;&nbsp;<input type="submit" name="delete"  value="删除选中" onclick="return confirm('删除所选IP');" class="an_02">&nbsp;&nbsp;&nbsp;&nbsp;<input type="button" onclick="window.location='admin.php?controller=admin_config&action=loadbalance_edit'"  name="add" value="添加" class="an_02">
						
				</td><input type="hidden" name="ac" value="delete" />
			</form>
			<form name="f1" method=post OnSubmit='return check()' action="admin.php?controller=admin_config&action=loadbalance">

				<td colspan="2" align="right">
					共<?php echo $_smarty_tpl->tpl_vars['command_num']->value;?>
执行命令  <?php echo $_smarty_tpl->tpl_vars['page_list']->value;?>
  页次：<?php echo $_smarty_tpl->tpl_vars['curr_page']->value;?>
/<?php echo $_smarty_tpl->tpl_vars['total_page']->value;?>
页  <?php echo $_smarty_tpl->tpl_vars['items_per_page']->value;?>
条日志/页  转到第<input name="pagenum" type="text" class="wbk" size="2" onKeyPress="if(event.keyCode==13) window.location='admin.php?controller=admin_config&action=loadbalance&page='+this.value;">页
				
				</td>
				</form>
			
			</tr>
			
			

		</table>
	</td>
  </tr>
</table>

</body>
</html>



<?php }
}
?>