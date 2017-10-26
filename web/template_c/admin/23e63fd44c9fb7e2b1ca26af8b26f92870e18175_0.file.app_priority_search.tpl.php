<?php /* Smarty version 3.1.27, created on 2017-05-31 08:06:46
         compiled from "/opt/freesvr/web/htdocs/freesvr/audit/template/admin/app_priority_search.tpl" */ ?>
<?php
/*%%SmartyHeaderCode:614642971592e09169cf049_06914385%%*/
if(!defined('SMARTY_DIR')) exit('no direct access allowed');
$_valid = $_smarty_tpl->decodeProperties(array (
  'file_dependency' => 
  array (
    '23e63fd44c9fb7e2b1ca26af8b26f92870e18175' => 
    array (
      0 => '/opt/freesvr/web/htdocs/freesvr/audit/template/admin/app_priority_search.tpl',
      1 => 1474793220,
      2 => 'file',
    ),
  ),
  'nocache_hash' => '614642971592e09169cf049_06914385',
  'variables' => 
  array (
    'title' => 0,
    'template_root' => 0,
    'language' => 0,
    'type' => 0,
    'orderby2' => 0,
    'alldev' => 0,
    'total' => 0,
    'page_list' => 0,
    'curr_page' => 0,
    'total_page' => 0,
    'items_per_page' => 0,
    'curr_url' => 0,
  ),
  'has_nocache_code' => false,
  'version' => '3.1.27',
  'unifunc' => 'content_592e0916a78416_33206716',
),false);
/*/%%SmartyHeaderCode%%*/
if ($_valid && !is_callable('content_592e0916a78416_33206716')) {
function content_592e0916a78416_33206716 ($_smarty_tpl) {

$_smarty_tpl->properties['nocache_hash'] = '614642971592e09169cf049_06914385';
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
/images/an11.jpg" align="absmiddle"/><a href="admin.php?controller=admin_pro&action=resource_group">系统用户组</a><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an33.jpg" align="absmiddle"/></li>
	<li class="me_b"><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an11.jpg" align="absmiddle"/><a href="admin.php?controller=admin_app&action=app_group">应用用户组</a><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an33.jpg" align="absmiddle"/></li>
	<li class="me_b"><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an11.jpg" align="absmiddle"/><a href="admin.php?controller=admin_pro&action=dev_priority_search">系统权限</a><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an33.jpg" align="absmiddle"/></li>
    <li class="me_a"><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an1.jpg" align="absmiddle"/><a href="admin.php?controller=admin_pro&action=app_priority_search">应用权限</a><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an3.jpg" align="absmiddle"/></li>
</ul>
</div></td></tr>
	
  
   <tr>
    <td class="main_content">
<form name ='f1' action='admin.php?controller=admin_pro&action=app_priority_search&type=luser' method=post>
					<?php echo $_smarty_tpl->tpl_vars['language']->value['4AUsername'];
echo $_smarty_tpl->tpl_vars['language']->value['User'];?>
<input type="text" class="wbk" name="user">
					<?php echo $_smarty_tpl->tpl_vars['language']->value['device'];?>
IP<input type="text" class="wbk" name="device_ip">
					应用发布IP<input type="text" class="wbk" name="appserverip">
					应用名称<input type="text" class="wbk" name="appname">
					<?php echo $_smarty_tpl->tpl_vars['language']->value['System'];
echo $_smarty_tpl->tpl_vars['language']->value['User'];?>
<input type="text" class="wbk" name="s_user">&nbsp;&nbsp;<input type="button" height="35" align="middle" onClick="return search();" border="0" value=" 确定 " class="bnnew2"/>
					</form>
</td>
  </tr>
   
  <tr>
	<td class="">
<TABLE border=0 cellSpacing=1 cellPadding=5 width="100%" bgColor=#ffffff valign="top" class="BBtable">
<?php echo '<script'; ?>
 type="text/javascript">
function search(){
var form = document.f1;
form.action += "&device_ip="+form.device_ip.value+"&s_user="+form.s_user.value+"&user="+form.user.value+"&appserverip="+form.appserverip.value+"&appname="+form.appname.value
form.submit();
return true;

}
function search2(){
var form = document.f2;
form.action += "&device_ip="+form.device_ip.value+"&s_user="+form.s_user.value+"&group="+form.group.value+"&appserverip="+form.appserverip.value
form.submit();
return true;
}
<?php echo '</script'; ?>
>
                <TBODY>
				
                  <TR>
                    <th class="list_bg" >&nbsp;</th>
                    <th class="list_bg" ><?php if ($_smarty_tpl->tpl_vars['type']->value == 'luser') {?><a href="admin.php?controller=admin_pro&action=app_priority_search&orderby1=webuser&orderby2=<?php echo $_smarty_tpl->tpl_vars['orderby2']->value;?>
" >运维账号</a><?php } elseif ($_smarty_tpl->tpl_vars['type']->value == 'lgroup') {?><a href="admin.php?controller=admin_pro&action=dev_group&orderby1=gname&orderby2=<?php echo $_smarty_tpl->tpl_vars['orderby2']->value;?>
" ><?php echo $_smarty_tpl->tpl_vars['language']->value['UserGroup'];
}?></a></th>                    
					<th class="list_bg" ><a href="admin.php?controller=admin_pro&action=app_priority_search&orderby1=device_ip&orderby2=<?php echo $_smarty_tpl->tpl_vars['orderby2']->value;?>
" >设备IP</a></th>
					<th class="list_bg" ><a href="admin.php?controller=admin_pro&action=app_priority_search&orderby1=appserverip&orderby2=<?php echo $_smarty_tpl->tpl_vars['orderby2']->value;?>
" >应用发布IP</a></th>
					<th class="list_bg" ><a href="admin.php?controller=admin_pro&action=app_priority_search&orderby1=appname&orderby2=<?php echo $_smarty_tpl->tpl_vars['orderby2']->value;?>
" >应用名称</a></th> 
                    <th class="list_bg" ><a href="admin.php?controller=admin_pro&action=app_priority_search&orderby1=username&orderby2=<?php echo $_smarty_tpl->tpl_vars['orderby2']->value;?>
" >应用用户名</a></th>  
					<th class="list_bg" ><a href="admin.php?controller=admin_pro&action=app_priority_search&orderby1=change_password&orderby2=<?php echo $_smarty_tpl->tpl_vars['orderby2']->value;?>
" >自动修改密码</a></th>
					<th class="list_bg" ><a href="admin.php?controller=admin_pro&action=app_priority_search&orderby1=enable&orderby2=<?php echo $_smarty_tpl->tpl_vars['orderby2']->value;?>
" >激活</a></th>
					<th class="list_bg" ><?php echo $_smarty_tpl->tpl_vars['language']->value['Operate'];?>
</th>
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
				<td><input type="checkbox" name="chk_member[]" value="<?php echo $_smarty_tpl->tpl_vars['alldev']->value[$_smarty_tpl->getVariable('smarty')->value['section']['t']['index']]['id'];?>
" /></td>
				<td><?php if ($_smarty_tpl->tpl_vars['type']->value == 'luser') {
echo $_smarty_tpl->tpl_vars['alldev']->value[$_smarty_tpl->getVariable('smarty')->value['section']['t']['index']]['webuser'];
} elseif ($_smarty_tpl->tpl_vars['type']->value == 'lgroup') {
echo $_smarty_tpl->tpl_vars['alldev']->value[$_smarty_tpl->getVariable('smarty')->value['section']['t']['index']]['gname'];
}?></td>				
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
				<td style="TEXT-ALIGN: left;"><img src='<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/edit_ico.gif' width=16 height='16' hspace='5' border='0' align='absmiddle'><a href="admin.php?controller=<?php if ($_smarty_tpl->tpl_vars['alldev']->value[$_smarty_tpl->getVariable('smarty')->value['section']['t']['index']]['orderby'] == 1 || $_smarty_tpl->tpl_vars['alldev']->value[$_smarty_tpl->getVariable('smarty')->value['section']['t']['index']]['orderby'] == 3) {?>admin_config&action=apppub_edit&id=<?php echo $_smarty_tpl->tpl_vars['alldev']->value[$_smarty_tpl->getVariable('smarty')->value['section']['t']['index']]['apppubid'];?>
&appserverip=<?php echo $_smarty_tpl->tpl_vars['alldev']->value[$_smarty_tpl->getVariable('smarty')->value['section']['t']['index']]['appserverip'];
} elseif ($_smarty_tpl->tpl_vars['alldev']->value[$_smarty_tpl->getVariable('smarty')->value['section']['t']['index']]['orderby'] == 2 || $_smarty_tpl->tpl_vars['alldev']->value[$_smarty_tpl->getVariable('smarty')->value['section']['t']['index']]['orderby'] == 4) {?>admin_app&action=appresourcegroup_bind&id=<?php echo $_smarty_tpl->tpl_vars['alldev']->value[$_smarty_tpl->getVariable('smarty')->value['section']['t']['index']]['appresourceid'];
}?>&from=search"><?php echo $_smarty_tpl->tpl_vars['language']->value['Edit'];?>
</a></td>
				
			</tr>
			<?php endfor; endif; ?>
			
                <tr>
				<td colspan="2"><input name="select_all" type="checkbox" onClick="javascript:for(var i=0;i<this.form.elements.length;i++){var e=this.form.elements[i];if(e.name=='chk_member[]')e.checked=this.form.select_all.checked;}" value="checkbox"><?php echo $_smarty_tpl->tpl_vars['language']->value['select'];
echo $_smarty_tpl->tpl_vars['language']->value['this'];
echo $_smarty_tpl->tpl_vars['language']->value['page'];
echo $_smarty_tpl->tpl_vars['language']->value['displayed'];?>
的<?php echo $_smarty_tpl->tpl_vars['language']->value['All'];?>
&nbsp;&nbsp;<input type="submit"  value="<?php echo $_smarty_tpl->tpl_vars['language']->value['UsersDelete'];?>
" onClick="my_confirm('<?php echo $_smarty_tpl->tpl_vars['language']->value['DeleteUsers'];?>
');if(chk_form()) document.member_list.action='admin.php?controller=admin_config&action=appdevice_delete'; else return false;" class="an_06"></td>
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
<input name="pagenum" type="text" class="wbk" size="2" onKeyPress="if(event.keyCode==13) {window.location='<?php echo $_smarty_tpl->tpl_vars['curr_url']->value;?>
&page='+this.value;return false;}"><?php echo $_smarty_tpl->tpl_vars['language']->value['page'];?>

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