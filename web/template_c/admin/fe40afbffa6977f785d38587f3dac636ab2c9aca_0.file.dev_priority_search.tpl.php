<?php /* Smarty version 3.1.27, created on 2017-05-19 13:15:13
         compiled from "/opt/freesvr/web/htdocs/freesvr/audit/template/admin/dev_priority_search.tpl" */ ?>
<?php
/*%%SmartyHeaderCode:541036779591e7f615499e1_64896467%%*/
if(!defined('SMARTY_DIR')) exit('no direct access allowed');
$_valid = $_smarty_tpl->decodeProperties(array (
  'file_dependency' => 
  array (
    'fe40afbffa6977f785d38587f3dac636ab2c9aca' => 
    array (
      0 => '/opt/freesvr/web/htdocs/freesvr/audit/template/admin/dev_priority_search.tpl',
      1 => 1493279530,
      2 => 'file',
    ),
  ),
  'nocache_hash' => '541036779591e7f615499e1_64896467',
  'variables' => 
  array (
    'title' => 0,
    'template_root' => 0,
    'language' => 0,
    'type' => 0,
    'orderby2' => 0,
    'alldev' => 0,
    'serverid' => 0,
    'gid' => 0,
    'total' => 0,
    'page_list' => 0,
    'curr_page' => 0,
    'total_page' => 0,
    'items_per_page' => 0,
    'curr_url' => 0,
  ),
  'has_nocache_code' => false,
  'version' => '3.1.27',
  'unifunc' => 'content_591e7f61617249_72563870',
),false);
/*/%%SmartyHeaderCode%%*/
if ($_valid && !is_callable('content_591e7f61617249_72563870')) {
function content_591e7f61617249_72563870 ($_smarty_tpl) {

$_smarty_tpl->properties['nocache_hash'] = '541036779591e7f615499e1_64896467';
?>
<html>
<head>
<title><?php echo $_smarty_tpl->tpl_vars['title']->value;?>
</title>
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
/images/an11.jpg" align="absmiddle"/><a href="admin.php?controller=admin_pro&action=resource_group">系统用户组</a><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an33.jpg" align="absmiddle"/></li>
	<li class="me_b"><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an11.jpg" align="absmiddle"/><a href="admin.php?controller=admin_app&action=app_group">应用用户组</a><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an33.jpg" align="absmiddle"/></li>
	<li class="me_a"><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an1.jpg" align="absmiddle"/><a href="admin.php?controller=admin_pro&action=dev_priority_search">系统权限</a><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an3.jpg" align="absmiddle"/></li>
    <li class="me_b"><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an11.jpg" align="absmiddle"/><a href="admin.php?controller=admin_pro&action=app_priority_search">应用权限</a><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an33.jpg" align="absmiddle"/></li>
</ul>
</div></td></tr>
	
 
   <tr>
    <td class="main_content">
<form name ='f1' action='admin.php?controller=admin_pro&action=dev_priority_search&type=luser' method=post>
					<?php echo $_smarty_tpl->tpl_vars['language']->value['4AUsername'];
echo $_smarty_tpl->tpl_vars['language']->value['User'];?>
<input type="text" class="wbk" name="user">
					<?php echo $_smarty_tpl->tpl_vars['language']->value['device'];?>
IP<input type="text" class="wbk" name="ip">
					<?php echo $_smarty_tpl->tpl_vars['language']->value['System'];
echo $_smarty_tpl->tpl_vars['language']->value['User'];?>
<input type="text" class="wbk" name="s_user">
					<input type="button" height="35" align="middle" onClick="return search();" value=" 确定 " border="0" class="bnnew2"/>
					</form>
</td>
  </tr>
  <tr>
	<td class="">
<table width="100%" border="0" cellspacing="0" cellpadding="0" class="BBtable">
<?php echo '<script'; ?>
 type="text/javascript">
function search(){
	var form = document.f1;
	form.action += "&ip="+form.elements.ip.value+"&s_user="+form.elements.s_user.value+"&user="+form.elements.user.value
	form.submit();
	return true;
}
function search2(){
	var form = document.f2;
	form.action += "&ip="+form.elements.ip.value+"&s_user="+form.elements.s_user.value+"&group="+form.elements.group.value;
	form.submit();
	return true;
}
<?php echo '</script'; ?>
>
                <TBODY>
				
                  <TR>
                    <th class="list_bg" ><?php if ($_smarty_tpl->tpl_vars['type']->value == 'luser') {?><a href="admin.php?controller=admin_pro&action=dev_priority_search&orderby1=username&orderby2=<?php echo $_smarty_tpl->tpl_vars['orderby2']->value;?>
" >运维账号</a><?php } elseif ($_smarty_tpl->tpl_vars['type']->value == 'lgroup') {?><a href="admin.php?controller=admin_pro&action=dev_group&orderby1=gname&orderby2=<?php echo $_smarty_tpl->tpl_vars['orderby2']->value;?>
" ><?php echo $_smarty_tpl->tpl_vars['language']->value['UserGroup'];
}?></a></TD>
                    <th class="list_bg" ><a href="admin.php?controller=admin_pro&action=dev_priority_search&orderby1=realname&orderby2=<?php echo $_smarty_tpl->tpl_vars['orderby2']->value;?>
" >真实姓名</a></TD>
                    <th class="list_bg" ><a href="admin.php?controller=admin_pro&action=dev_priority_search&orderby1=device_ip&orderby2=<?php echo $_smarty_tpl->tpl_vars['orderby2']->value;?>
" >设备目录</a></TD>
                    <th class="list_bg" ><a href="admin.php?controller=admin_pro&action=dev_priority_search&orderby1=device_ip&orderby2=<?php echo $_smarty_tpl->tpl_vars['orderby2']->value;?>
" ><?php echo $_smarty_tpl->tpl_vars['language']->value['device'];?>
IP</a></TD>
                    <th class="list_bg" ><a href="admin.php?controller=admin_pro&action=dev_priority_search&orderby1=device_ip&orderby2=<?php echo $_smarty_tpl->tpl_vars['orderby2']->value;?>
" >主机名</a></TD>
                    <th class="list_bg" ><a href="admin.php?controller=admin_pro&action=dev_priority_search&orderby1=username&orderby2=<?php echo $_smarty_tpl->tpl_vars['orderby2']->value;?>
" ><?php echo $_smarty_tpl->tpl_vars['language']->value['System'];
echo $_smarty_tpl->tpl_vars['language']->value['User'];?>
</a></TD>
					<th class="list_bg" >协议</TD>
                    <th class="list_bg" ><a href="admin.php?controller=admin_pro&action=dev_priority_search&orderby1=forbidden_commands_groups&orderby2=<?php echo $_smarty_tpl->tpl_vars['orderby2']->value;?>
" >黑白名单</a></TD>
					<th class="list_bg" ><a href="admin.php?controller=admin_pro&action=dev_priority_search&orderby1=weektime&orderby2=<?php echo $_smarty_tpl->tpl_vars['orderby2']->value;?>
" ><?php echo $_smarty_tpl->tpl_vars['language']->value['WeekTimepolicy'];?>
</a></TD>
					<th class="list_bg" ><a href="admin.php?controller=admin_pro&action=dev_priority_search&orderby1=loginlock&orderby2=<?php echo $_smarty_tpl->tpl_vars['orderby2']->value;?>
" >账号锁定</a></TD>
					<?php if ($_smarty_tpl->tpl_vars['type']->value == 'user') {?><th class="list_bg" ><a href="admin.php?controller=admin_pro&action=dev_priority_search&orderby1=lastdate&orderby2=<?php echo $_smarty_tpl->tpl_vars['orderby2']->value;?>
" ><?php echo $_smarty_tpl->tpl_vars['language']->value['Logintime'];?>
</a></TD><?php }?>
					<th class="list_bg" ><?php echo $_smarty_tpl->tpl_vars['language']->value['Operate'];?>
</TD>
                  </TR>

            </tr>
			<form name="member_list" action="admin.php?controller=admin_pro&action=devpass_del&ip=<?php echo $_smarty_tpl->tpl_vars['alldev']->value[0]['device_ip'];?>
&serverid=<?php echo $_smarty_tpl->tpl_vars['serverid']->value;?>
&gid=<?php echo $_smarty_tpl->tpl_vars['gid']->value;?>
" method="post">
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
				<td><?php if ($_smarty_tpl->tpl_vars['type']->value == 'luser') {
echo $_smarty_tpl->tpl_vars['alldev']->value[$_smarty_tpl->getVariable('smarty')->value['section']['t']['index']]['webuser'];
} elseif ($_smarty_tpl->tpl_vars['type']->value == 'lgroup') {
echo $_smarty_tpl->tpl_vars['alldev']->value[$_smarty_tpl->getVariable('smarty')->value['section']['t']['index']]['gname'];
}?></td>
				<td><?php echo $_smarty_tpl->tpl_vars['alldev']->value[$_smarty_tpl->getVariable('smarty')->value['section']['t']['index']]['webrealname'];?>
</td>
				<td><?php echo $_smarty_tpl->tpl_vars['alldev']->value[$_smarty_tpl->getVariable('smarty')->value['section']['t']['index']]['groupname'];?>
</td>
				<td><?php echo $_smarty_tpl->tpl_vars['alldev']->value[$_smarty_tpl->getVariable('smarty')->value['section']['t']['index']]['device_ip'];?>
</td>
				<td><?php echo $_smarty_tpl->tpl_vars['alldev']->value[$_smarty_tpl->getVariable('smarty')->value['section']['t']['index']]['hostname'];?>
</td>
				<td><?php echo $_smarty_tpl->tpl_vars['alldev']->value[$_smarty_tpl->getVariable('smarty')->value['section']['t']['index']]['username'];?>
</td>
				<td><?php echo $_smarty_tpl->tpl_vars['alldev']->value[$_smarty_tpl->getVariable('smarty')->value['section']['t']['index']]['login_method'];?>
</td>
				<td><?php echo $_smarty_tpl->tpl_vars['alldev']->value[$_smarty_tpl->getVariable('smarty')->value['section']['t']['index']]['forbidden_commands_groups'];?>
</td>
				<td><?php echo $_smarty_tpl->tpl_vars['alldev']->value[$_smarty_tpl->getVariable('smarty')->value['section']['t']['index']]['policyname'];?>
</td>
				<td><?php if ($_smarty_tpl->tpl_vars['alldev']->value[$_smarty_tpl->getVariable('smarty')->value['section']['t']['index']]['loginlock']) {?>是<?php } else { ?>否<?php }?></td>
				<?php if ($_smarty_tpl->tpl_vars['type']->value == 'user') {?><td><?php echo $_smarty_tpl->tpl_vars['alldev']->value[$_smarty_tpl->getVariable('smarty')->value['section']['t']['index']]['lastdate'];?>
</td><?php }?>
				<td style="TEXT-ALIGN: left;"><img src='<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/edit_ico.gif' width=16 height='16' hspace='5' border='0' align='absmiddle'><a href="<?php if ($_smarty_tpl->tpl_vars['alldev']->value[$_smarty_tpl->getVariable('smarty')->value['section']['t']['index']]['orderby'] == '1' || $_smarty_tpl->tpl_vars['alldev']->value[$_smarty_tpl->getVariable('smarty')->value['section']['t']['index']]['orderby'] == '3') {?>admin.php?controller=admin_pro&action=pass_edit&id=<?php echo $_smarty_tpl->tpl_vars['alldev']->value[$_smarty_tpl->getVariable('smarty')->value['section']['t']['index']]['devicesid'];?>
&ip=<?php echo $_smarty_tpl->tpl_vars['alldev']->value[$_smarty_tpl->getVariable('smarty')->value['section']['t']['index']]['device_ip'];
} elseif ($_smarty_tpl->tpl_vars['alldev']->value[$_smarty_tpl->getVariable('smarty')->value['section']['t']['index']]['orderby'] == '2' || $_smarty_tpl->tpl_vars['alldev']->value[$_smarty_tpl->getVariable('smarty')->value['section']['t']['index']]['orderby'] == '4') {?>admin.php?controller=admin_pro&action=resourcegroup_bind&id=<?php echo $_smarty_tpl->tpl_vars['alldev']->value[$_smarty_tpl->getVariable('smarty')->value['section']['t']['index']]['resourceid'];
}?>&fromdevpriority=1"><?php echo $_smarty_tpl->tpl_vars['language']->value['Edit'];?>
</a></td>
				
			</tr>
			<?php endfor; endif; ?>
			
                <tr>
				
	           <td  colspan="12" align="right">
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
<input name="pagenum" type="text" class="wbk" size="2" onKeyPress="if(event.keyCode==13) {window.location='<?php echo $_smarty_tpl->tpl_vars['curr_url']->value;?>
&page='+this.value;return false;}"><?php echo $_smarty_tpl->tpl_vars['language']->value['page'];?>
   导出：<a href="<?php echo $_smarty_tpl->tpl_vars['curr_url']->value;?>
&derive=1" target="hide"><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/excel.png" border=0></a>  <a href="<?php echo $_smarty_tpl->tpl_vars['curr_url']->value;?>
&derive=2"  target="hide"><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/html.png" border=0></a>  <a href="<?php echo $_smarty_tpl->tpl_vars['curr_url']->value;?>
&derive=3" ><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/word.png" border=0></a>
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