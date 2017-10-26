<?php /* Smarty version 3.1.27, created on 2017-10-10 13:54:06
         compiled from "/opt/freesvr/web/htdocs/freesvr/audit/template/admin/importlog.tpl" */ ?>
<?php
/*%%SmartyHeaderCode:140832544759dc607e495138_78044156%%*/
if(!defined('SMARTY_DIR')) exit('no direct access allowed');
$_valid = $_smarty_tpl->decodeProperties(array (
  'file_dependency' => 
  array (
    'c15b778f4736dc9a2f3af45cdf68af32fb181842' => 
    array (
      0 => '/opt/freesvr/web/htdocs/freesvr/audit/template/admin/importlog.tpl',
      1 => 1474793223,
      2 => 'file',
    ),
  ),
  'nocache_hash' => '140832544759dc607e495138_78044156',
  'variables' => 
  array (
    'title' => 0,
    'template_root' => 0,
    'orderby2' => 0,
    'importlog' => 0,
    'log_num' => 0,
    'page_list' => 0,
    'curr_page' => 0,
    'total_page' => 0,
    'items_per_page' => 0,
  ),
  'has_nocache_code' => false,
  'version' => '3.1.27',
  'unifunc' => 'content_59dc607e50bf91_20966529',
),false);
/*/%%SmartyHeaderCode%%*/
if ($_valid && !is_callable('content_59dc607e50bf91_20966529')) {
function content_59dc607e50bf91_20966529 ($_smarty_tpl) {

$_smarty_tpl->properties['nocache_hash'] = '140832544759dc607e495138_78044156';
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
<?php echo '<script'; ?>
 type="text/javascript" src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/cssjs/jquery-1.10.2.min.js"><?php echo '</script'; ?>
>
</head>
<?php echo '<script'; ?>
>
function searchit(){
	document.route.action+='&user='+document.getElementById('user').value;
	document.route.action+='&type='+document.getElementById('type').options[document.getElementById('type').options.selectedIndex].value;
	document.route.submit();
	return false;
}
<?php echo '</script'; ?>
>
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

	<table width="100%" border="0" cellspacing="0" cellpadding="0">
<tr><td valign="middle" class="hui_bj"><div class="menu">
<ul>

	<li class="me_b"><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an11.jpg" align="absmiddle"/><a href="admin.php?controller=admin_log&action=adminlog">系统操作</a><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an33.jpg" align="absmiddle"/></li>
	<li class="me_a"><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an1.jpg" align="absmiddle"/><a href="admin.php?controller=admin_log&action=downuploaded">批量导入</a><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an3.jpg" align="absmiddle"/></li>
</ul>
</div></td></tr>
  <tr>
		<form name='route' action='admin.php?controller=admin_log&action=downuploaded' method='post'>
			<td colspan="3" class="main_content">&nbsp;上传用户：<input type="text" class="wbk" size="20" name="user" id="user" value="" />&nbsp;&nbsp; 类型：
			<select name="type" id="type">
			<option value="">请选择</option>
			<option value="member">用户</option>
			<option value="apppub">应用发布</option>
			<option value="appprogram">应用程序</option>
			<option value="forbiddengps_cmd">命令权限</option>
			<option value="usbkey">动态令牌</option>
			<option value="devices">系统用户</option>
			<option value="resourcegroup">资源组</option>
			<option value="resourcegroup_priority">资源组权限</option>
			<option value="sshkey">公私钥</option>
			</select>
			&nbsp;&nbsp;&nbsp;&nbsp;<input type="submit" height="35" align="middle" onClick="return searchit();" border="0" value=" 确定 " class="bnnew2"/>&nbsp;&nbsp;</td>
			
			<input type="hidden" name="ac" value="new" />
		</form>
		</tr>
  <tr>
	<td class="">
	<table width="100%" border="0" cellspacing="0" cellpadding="0" class="BBtable">
                <TBODY>		
		<tr >
			<th class="list_bg" align="center" width="20%"><a href="admin.php?controller=admin_member&action=keys_index&orderby1=keyid&orderby2=<?php echo $_smarty_tpl->tpl_vars['orderby2']->value;?>
" >类型</a></td>
			<th class="list_bg" width="40%" align="center"><a href="admin.php?controller=admin_member&action=keys_index&orderby1=username&orderby2=<?php echo $_smarty_tpl->tpl_vars['orderby2']->value;?>
" >上传时间</a></td>
			<th class="list_bg" width="20%" align="center"><a href="admin.php?controller=admin_member&action=keys_index&orderby1=type&orderby2=<?php echo $_smarty_tpl->tpl_vars['orderby2']->value;?>
" >上传用户</a></td>
			<th class="list_bg" align="center"><b>操作</b></td>
		</tr>		
		<?php if (isset($_smarty_tpl->tpl_vars['smarty']->value['section']['t'])) unset($_smarty_tpl->tpl_vars['smarty']->value['section']['t']);
$_smarty_tpl->tpl_vars['smarty']->value['section']['t']['name'] = 't';
$_smarty_tpl->tpl_vars['smarty']->value['section']['t']['loop'] = is_array($_loop=$_smarty_tpl->tpl_vars['importlog']->value) ? count($_loop) : max(0, (int) $_loop); unset($_loop);
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
			<td ><?php if ($_smarty_tpl->tpl_vars['importlog']->value[$_smarty_tpl->getVariable('smarty')->value['section']['t']['index']]['type'] == 'member') {?>用户<?php } elseif ($_smarty_tpl->tpl_vars['importlog']->value[$_smarty_tpl->getVariable('smarty')->value['section']['t']['index']]['type'] == 'apppub') {?>应用发布<?php } elseif ($_smarty_tpl->tpl_vars['importlog']->value[$_smarty_tpl->getVariable('smarty')->value['section']['t']['index']]['type'] == 'appprogram') {?>应用程序<?php } elseif ($_smarty_tpl->tpl_vars['importlog']->value[$_smarty_tpl->getVariable('smarty')->value['section']['t']['index']]['type'] == 'forbiddengps_cmd') {?>命令权限<?php } elseif ($_smarty_tpl->tpl_vars['importlog']->value[$_smarty_tpl->getVariable('smarty')->value['section']['t']['index']]['type'] == 'usbkey') {?>动态令牌<?php } elseif ($_smarty_tpl->tpl_vars['importlog']->value[$_smarty_tpl->getVariable('smarty')->value['section']['t']['index']]['type'] == 'devices') {?>系统用户<?php } elseif ($_smarty_tpl->tpl_vars['importlog']->value[$_smarty_tpl->getVariable('smarty')->value['section']['t']['index']]['type'] == 'resourcegroup') {?>资源组<?php } elseif ($_smarty_tpl->tpl_vars['importlog']->value[$_smarty_tpl->getVariable('smarty')->value['section']['t']['index']]['type'] == 'resourcegroup_priority') {?>资源组权限<?php } elseif ($_smarty_tpl->tpl_vars['importlog']->value[$_smarty_tpl->getVariable('smarty')->value['section']['t']['index']]['type'] == 'sshkey') {?>公私钥<?php }?></td>
			<td ><?php echo $_smarty_tpl->tpl_vars['importlog']->value[$_smarty_tpl->getVariable('smarty')->value['section']['t']['index']]['uptime'];?>
</td>
			<td><?php echo $_smarty_tpl->tpl_vars['importlog']->value[$_smarty_tpl->getVariable('smarty')->value['section']['t']['index']]['user'];?>
</td>
			<td >			
			<img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/edit_ico.gif" width="16" height="16" align="absmiddle"><a href="admin.php?controller=admin_log&action=downloadfile&id=<?php echo $_smarty_tpl->tpl_vars['importlog']->value[$_smarty_tpl->getVariable('smarty')->value['section']['t']['index']]['id'];?>
">下载</a> 
			 | <img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/delete_ico.gif" width="16" height="16" hspace="5" border="0" align="absmiddle"><a href="#" onClick="if(!confirm('您确定要删除？')) {return false;} else { location.href='admin.php?controller=admin_log&action=downuploaded&delete=1&id=<?php echo $_smarty_tpl->tpl_vars['importlog']->value[$_smarty_tpl->getVariable('smarty')->value['section']['t']['index']]['id'];?>
';}">删除</a>
			
			</td>
		</tr>
		<?php endfor; endif; ?>
                <tr>
				<td colspan="1"></td>
	           <td  colspan="3" align="right">
		   			共<?php echo $_smarty_tpl->tpl_vars['log_num']->value;?>
个记录  <?php echo $_smarty_tpl->tpl_vars['page_list']->value;?>
  页次：<?php echo $_smarty_tpl->tpl_vars['curr_page']->value;?>
/<?php echo $_smarty_tpl->tpl_vars['total_page']->value;?>
页  <?php echo $_smarty_tpl->tpl_vars['items_per_page']->value;?>
个记录/页  转到第<input name="pagenum" type="text" class="wbk" size="2" onKeyPress="if(event.keyCode==13) window.location='admin.php?controller=admin_member&action=keys_index&page='+this.value;">页
		   </td>
		</tr>
		
		</TBODY>
              </TABLE>	</td>
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