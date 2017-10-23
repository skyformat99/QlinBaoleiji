<?php /* Smarty version 3.1.27, created on 2017-06-26 12:13:40
         compiled from "/opt/freesvr/web/htdocs/freesvr/audit/template/admin/apppriority.tpl" */ ?>
<?php
/*%%SmartyHeaderCode:13557847595089f4857f07_05075191%%*/
if(!defined('SMARTY_DIR')) exit('no direct access allowed');
$_valid = $_smarty_tpl->decodeProperties(array (
  'file_dependency' => 
  array (
    'dbf4339e2089939291dcb243e28f73d146310cfe' => 
    array (
      0 => '/opt/freesvr/web/htdocs/freesvr/audit/template/admin/apppriority.tpl',
      1 => 1474793216,
      2 => 'file',
    ),
  ),
  'nocache_hash' => '13557847595089f4857f07_05075191',
  'variables' => 
  array (
    'title' => 0,
    'template_root' => 0,
    'type' => 0,
    'orderby2' => 0,
    'language' => 0,
    'alldev' => 0,
    'total' => 0,
    'page_list' => 0,
    'curr_page' => 0,
    'total_page' => 0,
    'items_per_page' => 0,
    'curr_url' => 0,
    'admin_level' => 0,
  ),
  'has_nocache_code' => false,
  'version' => '3.1.27',
  'unifunc' => 'content_595089f48fded3_26686935',
),false);
/*/%%SmartyHeaderCode%%*/
if ($_valid && !is_callable('content_595089f48fded3_26686935')) {
function content_595089f48fded3_26686935 ($_smarty_tpl) {

$_smarty_tpl->properties['nocache_hash'] = '13557847595089f4857f07_05075191';
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
/images/an11.jpg" align="absmiddle"/><a href="admin.php?controller=admin_reports&action=systempriority_search">系统权限</a><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an33.jpg" align="absmiddle"/></li>
	<li class="me_a"><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an1.jpg" align="absmiddle"/><a href="admin.php?controller=admin_reports&action=apppriority_search">应用权限</a><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an3.jpg" align="absmiddle"/></li>
   <li class="me_b"><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an11.jpg" align="absmiddle"/><a href="admin.php?controller=admin_reports&action=systemaccount">系统账号</a><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an33.jpg" align="absmiddle"/></li>
	<li class="me_b"><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an11.jpg" align="absmiddle"/><a href="admin.php?controller=admin_reports&action=appaccount">应用账号</a><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an33.jpg" align="absmiddle"/></li>
	<?php if ($_SESSION['ADMIN_LEVEL'] == 1 || $_SESSION['ADMIN_LEVEL'] == 2) {?>
	<li class="me_b"><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an11.jpg" align="absmiddle"/><a href="admin.php?controller=admin_reports&action=admin_log">变更报表</a><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an33.jpg" align="absmiddle"/></li>
	<?php }?>
</ul>
</div></td></tr>
	
  <tr>
	<td class="">
<TABLE border=0 cellSpacing=1 cellPadding=5 width="100%" bgColor=#ffffff valign="top" class="BBtable">
                <TBODY>
				
                  <TR>
                    <th class="list_bg" >序号</th>
					<?php if ($_smarty_tpl->tpl_vars['type']->value == 'luser') {?>
                    <th class="list_bg"  width="12%"><a href="admin.php?controller=admin_reports&action=apppriority&orderby1=webuser&orderby2=<?php echo $_smarty_tpl->tpl_vars['orderby2']->value;?>
" >运维用户</a></th>    
					<th class="list_bg"  width="12%"><a href="admin.php?controller=admin_reports&action=apppriority&orderby1=webrealname&orderby2=<?php echo $_smarty_tpl->tpl_vars['orderby2']->value;?>
" >别名</a></th> 
					<?php } elseif ($_smarty_tpl->tpl_vars['type']->value == 'lgroup') {?>
					<th class="list_bg"  width="12%"><a href="admin.php?controller=admin_reports&action=apppriority&orderby1=gname&orderby2=<?php echo $_smarty_tpl->tpl_vars['orderby2']->value;?>
" ><?php echo $_smarty_tpl->tpl_vars['language']->value['UserGroup'];?>
</a></th><?php }?>
					<?php if ($_smarty_tpl->tpl_vars['type']->value == 'luser') {?><th class="list_bg" >运维组</th><?php }?>
					<th class="list_bg" ><a href="admin.php?controller=admin_reports&action=apppriority&orderby1=device_ip&orderby2=<?php echo $_smarty_tpl->tpl_vars['orderby2']->value;?>
" >设备IP</a></th>
					<th class="list_bg" ><a href="admin.php?controller=admin_reports&action=apppriority&orderby1=appserverip&orderby2=<?php echo $_smarty_tpl->tpl_vars['orderby2']->value;?>
" >应用发布IP</a></th>
					<th class="list_bg" ><a href="admin.php?controller=admin_reports&action=apppriority&orderby1=appname&orderby2=<?php echo $_smarty_tpl->tpl_vars['orderby2']->value;?>
" >应用名称</a></th> 
                    <th class="list_bg"  width="12%"><a href="admin.php?controller=admin_reports&action=apppriority&orderby1=username&orderby2=<?php echo $_smarty_tpl->tpl_vars['orderby2']->value;?>
" >应用用户名</a></th>  
					<th class="list_bg"  width="9%"><a href="admin.php?controller=admin_reports&action=apppriority&orderby1=change_password&orderby2=<?php echo $_smarty_tpl->tpl_vars['orderby2']->value;?>
" >自动修改密码</a></th>
					<th class="list_bg"  width="6%"><a href="admin.php?controller=admin_reports&action=apppriority&orderby1=enable&orderby2=<?php echo $_smarty_tpl->tpl_vars['orderby2']->value;?>
" >激活</a></th>
                  </TR>

            </tr>
			<form name="member_list" action="admin.php?controller=admin_config&action=appdevice_delete" method="post">
			<?php if (isset($_smarty_tpl->tpl_vars['smarty']->value['section']['t'])) unset($_smarty_tpl->tpl_vars['smarty']->value['section']['t']);
$_smarty_tpl->tpl_vars['smarty']->value['section']['t']['name'] = 't';
$_smarty_tpl->tpl_vars['smarty']->value['section']['t']['loop'] = is_array($_loop=$_smarty_tpl->tpl_vars['alldev']->value) ? count($_loop) : max(0, (int) $_loop); unset($_loop);
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
			<tr <?php if ($_smarty_tpl->tpl_vars['alldev']->value[$_smarty_tpl->getVariable('smarty')->value['section']['t']['index']]['ct'] > 0) {?>bgcolor="red" <?php } elseif ($_smarty_tpl->getVariable('smarty')->value['section']['t']['index']%2 == 0) {?>bgcolor="f7f7f7"<?php }?>>
				<td><?php echo $_smarty_tpl->getVariable('smarty')->value['section']['t']['index']+1;?>
</td>
				<?php if ($_smarty_tpl->tpl_vars['type']->value == 'luser') {?>
				<td><?php echo $_smarty_tpl->tpl_vars['alldev']->value[$_smarty_tpl->getVariable('smarty')->value['section']['t']['index']]['webuser'];?>
</td>				
				<td><?php echo $_smarty_tpl->tpl_vars['alldev']->value[$_smarty_tpl->getVariable('smarty')->value['section']['t']['index']]['webrealname'];?>
</td>
				<?php } elseif ($_smarty_tpl->tpl_vars['type']->value == 'lgroup') {?><td><?php echo $_smarty_tpl->tpl_vars['alldev']->value[$_smarty_tpl->getVariable('smarty')->value['section']['t']['index']]['gname'];?>
</td><?php }?>
				<?php if ($_smarty_tpl->tpl_vars['type']->value == 'luser') {?><td><?php echo $_smarty_tpl->tpl_vars['alldev']->value[$_smarty_tpl->getVariable('smarty')->value['section']['t']['index']]['usergroup'];?>
</td><?php }?>
				<td><?php echo $_smarty_tpl->tpl_vars['alldev']->value[$_smarty_tpl->getVariable('smarty')->value['section']['t']['index']]['device_ip'];?>
</td>
				<td><?php echo $_smarty_tpl->tpl_vars['alldev']->value[$_smarty_tpl->getVariable('smarty')->value['section']['t']['index']]['appserverip'];?>
</td>
				<td><?php echo $_smarty_tpl->tpl_vars['alldev']->value[$_smarty_tpl->getVariable('smarty')->value['section']['t']['index']]['appname'];?>
</td>
				<td><?php echo $_smarty_tpl->tpl_vars['alldev']->value[$_smarty_tpl->getVariable('smarty')->value['section']['t']['index']]['username'];?>
</td>
				<td><?php if ($_smarty_tpl->tpl_vars['alldev']->value[$_smarty_tpl->getVariable('smarty')->value['section']['t']['index']]['change_password']) {?>是<?php } else { ?>否<?php }?></td>
				<td><?php if ($_smarty_tpl->tpl_vars['alldev']->value[$_smarty_tpl->getVariable('smarty')->value['section']['t']['index']]['enable']) {?>是<?php } else { ?>否<?php }?></td>
				
			</tr>
			<?php endfor; endif; ?>
			
                <tr>
				<td colspan="2"></td>
	           <td  colspan="8" align="right">
		   			<?php echo $_smarty_tpl->tpl_vars['language']->value['all'];
echo $_smarty_tpl->tpl_vars['total']->value;
echo $_smarty_tpl->tpl_vars['language']->value['Recorder'];?>
  <?php echo $_smarty_tpl->tpl_vars['page_list']->value;?>
  <?php echo $_smarty_tpl->tpl_vars['language']->value['Page'];?>
：<?php echo $_smarty_tpl->tpl_vars['curr_page']->value;?>
/<?php echo $_smarty_tpl->tpl_vars['total_page']->value;
echo $_smarty_tpl->tpl_vars['language']->value['page'];?>
  <?php echo $_smarty_tpl->tpl_vars['items_per_page']->value;
echo $_smarty_tpl->tpl_vars['language']->value['Recorder'];?>
/<?php echo $_smarty_tpl->tpl_vars['language']->value['page'];?>
  <?php echo $_smarty_tpl->tpl_vars['language']->value['Goto'];?>
<input name="pagenum" type="text" class="wbk" size="2" onKeyPress="if(event.keyCode==13) window.location='admin.php?controller=admin_pro&action=dev_index&page='+this.value;"><?php echo $_smarty_tpl->tpl_vars['language']->value['page'];?>
</a>   导出：<a href="<?php echo $_smarty_tpl->tpl_vars['curr_url']->value;?>
&derive=1" target="hide"><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/excel.png" border=0></a>  <a href="<?php echo $_smarty_tpl->tpl_vars['curr_url']->value;?>
&derive=2" ><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/html.png" border=0></a> <a href="<?php echo $_smarty_tpl->tpl_vars['curr_url']->value;?>
&derive=3" ><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/word.png" border=0></a>  <a href="<?php echo $_smarty_tpl->tpl_vars['curr_url']->value;?>
&derive=4" ><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/pdf.png" border=0></a> <?php if ($_smarty_tpl->tpl_vars['admin_level']->value == 1) {?><a href="<?php echo $_smarty_tpl->tpl_vars['curr_url']->value;?>
&delete=1"></a><?php }?>
		   </td>
		</tr>
		 </form>
		</TBODY>
              </TABLE>
	</td>
  </tr>
</table>

<?php echo '<script'; ?>
 language="javascript">

function my_confirm(str){
	if(!confirm(str + "？"))
	{
		window.event.returnValue = false;
	}
}

<?php echo '</script'; ?>
>
</body>
<iframe name="hide" height="0" frameborder="0" scrolling="no"></iframe>
</html>


<?php }
}
?>