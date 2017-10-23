<?php /* Smarty version 3.1.27, created on 2017-06-14 21:02:57
         compiled from "/opt/freesvr/web/htdocs/freesvr/audit/template/admin/appicon_list.tpl" */ ?>
<?php
/*%%SmartyHeaderCode:154232560659413401ce6a26_83698647%%*/
if(!defined('SMARTY_DIR')) exit('no direct access allowed');
$_valid = $_smarty_tpl->decodeProperties(array (
  'file_dependency' => 
  array (
    '9abadc0f6f7be30b0786617ad44fd24fb546d240' => 
    array (
      0 => '/opt/freesvr/web/htdocs/freesvr/audit/template/admin/appicon_list.tpl',
      1 => 1474793222,
      2 => 'file',
    ),
  ),
  'nocache_hash' => '154232560659413401ce6a26_83698647',
  'variables' => 
  array (
    'language' => 0,
    'template_root' => 0,
    'appserverip' => 0,
    'orderby2' => 0,
    'appicon' => 0,
    'command_num' => 0,
    'page_list' => 0,
    'curr_page' => 0,
    'total_page' => 0,
    'items_per_page' => 0,
  ),
  'has_nocache_code' => false,
  'version' => '3.1.27',
  'unifunc' => 'content_59413401d635f5_53309406',
),false);
/*/%%SmartyHeaderCode%%*/
if ($_valid && !is_callable('content_59413401d635f5_53309406')) {
function content_59413401d635f5_53309406 ($_smarty_tpl) {

$_smarty_tpl->properties['nocache_hash'] = '154232560659413401ce6a26_83698647';
?>
<!doctype html public "-//w3c//dtd html 4.0 transitional//en">
<html>
<head>
<title><?php echo $_smarty_tpl->tpl_vars['language']->value['SessionsList'];?>
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
<?php echo '<script'; ?>
>
function chk_form(){
return true;
}
<?php echo '</script'; ?>
>
<body>


	<table width="100%" border="0" cellspacing="0" cellpadding="0">
<tr><td valign="middle" class="hui_bj"><div class="menu">
<ul>
   <li class="me_b"><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an11.jpg" align="absmiddle"/><a href="admin.php?controller=admin_config&action=appserver_list">应用发布</a><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an33.jpg" align="absmiddle"/></li>
	<?php if ($_SESSION['ADMIN_LEVEL'] != 3) {?>
	<li class="me_b"><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an11.jpg" align="absmiddle"/><a href="admin.php?controller=admin_config&action=appprogram_list">应用程序</a><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an33.jpg" align="absmiddle"/></li>
	<li class="me_a"><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an1.jpg" align="absmiddle"/><a href="admin.php?controller=admin_config&action=appicon_list">应用图标</a><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an3.jpg" align="absmiddle"/></li>
	<?php }?>
</ul>
</div></td></tr>

  <tr>
	<td class="">
		<table bordercolor="white" cellspacing="1" cellpadding="5" border="0" width="100%"  class="BBtable">
			<tr>
				<th class="list_bg"  width="5%">#</th>
				<th class="list_bg"  width="12%"><a href="admin.php?controller=admin_config&action=appicon_list&ip=<?php echo $_smarty_tpl->tpl_vars['appserverip']->value;?>
&orderby1=name&orderby2=<?php echo $_smarty_tpl->tpl_vars['orderby2']->value;?>
" >应用名称</a></th>
				<th class="list_bg"  width="40%"><a href="admin.php?controller=admin_config&action=appicon_list&ip=<?php echo $_smarty_tpl->tpl_vars['appserverip']->value;?>
&orderby1=name&orderby2=<?php echo $_smarty_tpl->tpl_vars['orderby2']->value;?>
" >图标路径</a></th>
				<th class="list_bg"  width="15%"><?php echo $_smarty_tpl->tpl_vars['language']->value['Operate'];?>
</th>
			</tr>
			<form action='#' method='post' name='member_list' >
			<?php if (isset($_smarty_tpl->tpl_vars['smarty']->value['section']['t'])) unset($_smarty_tpl->tpl_vars['smarty']->value['section']['t']);
$_smarty_tpl->tpl_vars['smarty']->value['section']['t']['name'] = 't';
$_smarty_tpl->tpl_vars['smarty']->value['section']['t']['loop'] = is_array($_loop=$_smarty_tpl->tpl_vars['appicon']->value) ? count($_loop) : max(0, (int) $_loop); unset($_loop);
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
				<td><input type="checkbox" name="chk_member[]" value="<?php echo $_smarty_tpl->tpl_vars['appicon']->value[$_smarty_tpl->getVariable('smarty')->value['section']['t']['index']]['id'];?>
"></td>
				<td><?php echo $_smarty_tpl->tpl_vars['appicon']->value[$_smarty_tpl->getVariable('smarty')->value['section']['t']['index']]['name'];?>
</td>
				<td><?php echo $_smarty_tpl->tpl_vars['appicon']->value[$_smarty_tpl->getVariable('smarty')->value['section']['t']['index']]['path'];?>
</ td>
				<td>
				
			<img src='./template/admin/images/left_dot1.gif' width=16 height='16' hspace='5' border='0' align='absmiddle'><a href='admin.php?controller=admin_config&action=appicon_edit&id=<?php echo $_smarty_tpl->tpl_vars['appicon']->value[$_smarty_tpl->getVariable('smarty')->value['section']['t']['index']]['id'];?>
&appserverip=<?php echo $_smarty_tpl->tpl_vars['appicon']->value[$_smarty_tpl->getVariable('smarty')->value['section']['t']['index']]['appserverip'];?>
'><?php echo $_smarty_tpl->tpl_vars['language']->value['Edit'];?>
</a>	
				&nbsp;|&nbsp;<img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/scico.gif" width="16" height="16" align="absmiddle"><a onclick="if(confirm('确定<?php echo $_smarty_tpl->tpl_vars['language']->value['Delete'];?>
吗?')) return true;else return false;" href="admin.php?controller=admin_config&action=appicon_delete&id=<?php echo $_smarty_tpl->tpl_vars['appicon']->value[$_smarty_tpl->getVariable('smarty')->value['section']['t']['index']]['id'];?>
"><?php echo $_smarty_tpl->tpl_vars['language']->value['Delete'];?>
</a></td>
			</tr>
			<?php endfor; endif; ?>
			<tr>
						<td colspan="9" align="left">
							<input name="select_all" type="checkbox" onclick="javascript:for(var i=0;i<this.form.elements.length;i++){var e=this.form.elements[i];if(e.name=='chk_member[]')e.checked=this.form.select_all.checked;}" value="checkbox"><?php echo $_smarty_tpl->tpl_vars['language']->value['select'];
echo $_smarty_tpl->tpl_vars['language']->value['this'];
echo $_smarty_tpl->tpl_vars['language']->value['page'];
echo $_smarty_tpl->tpl_vars['language']->value['displayed'];?>
的<?php echo $_smarty_tpl->tpl_vars['language']->value['All'];
echo $_smarty_tpl->tpl_vars['language']->value['User'];?>
&nbsp;&nbsp;<input type="submit"  value="删除选中" onclick="if(confirm('确定要删除?')) document.member_list.action='admin.php?controller=admin_config&action=appicon_delete&appserverip=<?php echo $_smarty_tpl->tpl_vars['appserverip']->value;?>
';else return false;" class="an_02">&nbsp;&nbsp;&nbsp;&nbsp;<input type="button" onclick="location.href='admin.php?controller=admin_config&action=appicon_edit&appserverip=<?php echo $_smarty_tpl->tpl_vars['appserverip']->value;?>
'"  value="<?php echo $_smarty_tpl->tpl_vars['language']->value['Add'];?>
" class="an_02">
						</td>
					</tr>
			<tr>
				<td colspan="6" align="right">
					<?php echo $_smarty_tpl->tpl_vars['language']->value['all'];
echo $_smarty_tpl->tpl_vars['command_num']->value;?>
图标  <?php echo $_smarty_tpl->tpl_vars['page_list']->value;?>
  <?php echo $_smarty_tpl->tpl_vars['language']->value['Page'];?>
：<?php echo $_smarty_tpl->tpl_vars['curr_page']->value;?>
/<?php echo $_smarty_tpl->tpl_vars['total_page']->value;
echo $_smarty_tpl->tpl_vars['language']->value['page'];?>
  <?php echo $_smarty_tpl->tpl_vars['items_per_page']->value;
echo $_smarty_tpl->tpl_vars['language']->value['item'];
echo $_smarty_tpl->tpl_vars['language']->value['Log'];?>
/<?php echo $_smarty_tpl->tpl_vars['language']->value['page'];?>
  <?php echo $_smarty_tpl->tpl_vars['language']->value['Goto'];?>
<input name="pagenum" type="text" class="wbk" size="2" onKeyPress="if(event.keyCode==13) window.location='admin.php?controller=admin_config&action=appicon_list&page='+this.value;"><?php echo $_smarty_tpl->tpl_vars['language']->value['page'];?>

				</td>
			</tr>
			</form>
		</table>
	</td>
  </tr>
</table>

<?php echo '<script'; ?>
 type="text/javascript">
window.parent.menu.document.getElementById('devtree').style.display='none';
window.parent.menu.document.getElementById('ldaptree').style.display='none';
<?php echo '</script'; ?>
>
</body>
<iframe name="hide" height="0" frameborder="0" scrolling="no"></iframe>
</html>


<?php }
}
?>