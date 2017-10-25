<?php /* Smarty version 3.1.27, created on 2017-07-21 11:19:37
         compiled from "/opt/freesvr/web/htdocs/freesvr/audit/template/admin/plsqlhistory.tpl" */ ?>
<?php
/*%%SmartyHeaderCode:2124546765597172c9177dd5_54905540%%*/
if(!defined('SMARTY_DIR')) exit('no direct access allowed');
$_valid = $_smarty_tpl->decodeProperties(array (
  'file_dependency' => 
  array (
    '7492d1beaa1a07fc44bd609f4929c33dcb1c70e1' => 
    array (
      0 => '/opt/freesvr/web/htdocs/freesvr/audit/template/admin/plsqlhistory.tpl',
      1 => 1483623678,
      2 => 'file',
    ),
  ),
  'nocache_hash' => '2124546765597172c9177dd5_54905540',
  'variables' => 
  array (
    'template_root' => 0,
    'backupdb_id' => 0,
    'orderby2' => 0,
    'allsession' => 0,
    'sid' => 0,
    'session_num' => 0,
    'page_list' => 0,
    'curr_page' => 0,
    'total_page' => 0,
    'items_per_page' => 0,
    'curr_url' => 0,
    'now_table_name' => 0,
    'table_list' => 0,
    'logindebug' => 0,
    'member' => 0,
  ),
  'has_nocache_code' => false,
  'version' => '3.1.27',
  'unifunc' => 'content_597172c9232427_86555117',
),false);
/*/%%SmartyHeaderCode%%*/
if ($_valid && !is_callable('content_597172c9232427_86555117')) {
function content_597172c9232427_86555117 ($_smarty_tpl) {

$_smarty_tpl->properties['nocache_hash'] = '2124546765597172c9177dd5_54905540';
?>
<!doctype html public "-//w3c//dtd html 4.0 transitional//en">
<html>
<head>
<title>会话列表</title>
<meta name="generator" content="editplus">
<meta name="author" content="nuttycoder">
<link href="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/all_purpose_style.css" rel="stylesheet" type="text/css" />
<?php echo '<script'; ?>
 type="text/javascript">
function searchit(){
	document.search.action = "admin.php?controller=admin_apppub&action=plsqlhistory&backupdb_id=<?php echo $_smarty_tpl->tpl_vars['backupdb_id']->value;?>
";
	document.search.action += "&username="+document.search.username.value;
	document.search.action += "&dbname="+document.search.dbname.value;
	document.search.action += "&start1="+document.search.f_rangeStart.value;
	document.search.action += "&start2="+document.search.f_rangeEnd.value;
	
	//alert(document.search.action);
	//return false;
	window.location = document.search.action;
	return true;
}
<?php echo '</script'; ?>
>
<link type="text/css" rel="stylesheet" href="./template/admin/cssjs/jscal2.css" />
<link type="text/css" rel="stylesheet" href="./template/admin/cssjs/border-radius.css" />
<?php echo '<script'; ?>
 src="./template/admin/cssjs/jscal2.js"><?php echo '</script'; ?>
>
<?php echo '<script'; ?>
 src="./template/admin/cssjs/cn.js"><?php echo '</script'; ?>
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
<td width="84%" align="left" valign="top"><table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#F1F1F1"><tr><td valign="middle" class="hui_bj"><div class="menu">
<ul>   
    
	<?php if ($_smarty_tpl->tpl_vars['backupdb_id']->value) {?>
	 <li class="me_b"><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an11.jpg" align="absmiddle"/><a href="admin.php?controller=admin_session&backupdb_id=<?php echo $_smarty_tpl->tpl_vars['backupdb_id']->value;?>
">Telnet/SSH</a><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an33.jpg" align="absmiddle"/></li>
    <li class="me_b"><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an11.jpg" align="absmiddle"/><a href="admin.php?controller=admin_sftp&backupdb_id=<?php echo $_smarty_tpl->tpl_vars['backupdb_id']->value;?>
">SFTP</a><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an33.jpg" align="absmiddle"/></li>
    <li class="me_b"><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an11.jpg" align="absmiddle"/><a href="admin.php?controller=admin_scp&backupdb_id=<?php echo $_smarty_tpl->tpl_vars['backupdb_id']->value;?>
">SCP</a><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an33.jpg" align="absmiddle"/></li> 
<li class="me_b"><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an11.jpg" align="absmiddle"/><a href="admin.php?controller=admin_ftp&backupdb_id=<?php echo $_smarty_tpl->tpl_vars['backupdb_id']->value;?>
">FTP</a><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an33.jpg" align="absmiddle"/></li>
	<li class="me_b"><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an11.jpg" align="absmiddle"/><a href="admin.php?controller=admin_rdp&backupdb_id=<?php echo $_smarty_tpl->tpl_vars['backupdb_id']->value;?>
">RDP</a><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an33.jpg" align="absmiddle"/></li>
    <li class="me_b"><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an11.jpg" align="absmiddle"/><a href="admin.php?controller=admin_vnc&backupdb_id=<?php echo $_smarty_tpl->tpl_vars['backupdb_id']->value;?>
">VNC</a><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an33.jpg" align="absmiddle"/></li>   
	<?php }?>
	<li class="me_a"><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an1.jpg" align="absmiddle"/><a href="admin.php?controller=admin_apppub&backupdb_id=<?php echo $_smarty_tpl->tpl_vars['backupdb_id']->value;?>
">应用发布</a><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an3.jpg" align="absmiddle"/></li>
</ul>
<span class="back_img"><A href="admin.php?controller=admin_apppub&back=1"><IMG src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/back1.png" 
      width="80" height="30" border="0"></A></span>
</div></td></tr>
   <tr>
     <td >
	<table width="100%" border="0" cellspacing="0" cellpadding="0" class="main_content"><form action="admin.php?controller=admin_apppub&backupdb_id=<?php echo $_smarty_tpl->tpl_vars['backupdb_id']->value;?>
" method="post" name="search" >
  <tr>
    <td></td>
    <td>
	用户名：<input type="text" class="wbk" name="username"  size="13" />
    实例名：<input type="text" class="wbk" name="dbname"  size="13" />
开始日期：<input type="text" class="wbk"  name="f_rangeStart" size="13" id="f_rangeStart" value=""/>
 <input type="button" onClick="changetype('timetype3')" id="f_rangeStart_trigger" name="f_rangeStart_trigger" value="选择时间" class="wbk">

 结束日期：
<input  type="text" class="wbk" name="f_rangeEnd" size="13" id="f_rangeEnd" value=""/>
 <input type="button" onClick="changetype('timetype3')" id="f_rangeEnd_trigger" name="f_rangeEnd_trigger" value="选择时间" class="wbk">
	 <select  class="wbk"  id="app_act" style="display:none"><option value="applet" <?php if ($_SESSION['ADMIN_DEFAULT_CONTROL'] == 'applet') {?>selected<?php }?>>applet</option><option value="activeX" <?php if ($_SESSION['ADMIN_DEFAULT_CONTROL'] == 'activeX') {?>selected<?php }?>>activeX</option></select>&nbsp;&nbsp;<input type="submit" height="35" align="middle" onClick="return searchit();" border="0" value=" 确定 " class="bnnew2"/>
 </td>
  </tr></form>
</table>  
					
  <?php echo '<script'; ?>
 type="text/javascript">
var cal = Calendar.setup({
    onSelect: function(cal) { cal.hide() },
    showTime: true
});
cal.manageFields("f_rangeStart_trigger", "f_rangeStart", "%Y-%m-%d %H:%M:%S");
cal.manageFields("f_rangeEnd_trigger", "f_rangeEnd", "%Y-%m-%d %H:%M:%S");


<?php echo '</script'; ?>
>
					</td>
  </tr>
  <tr><td><table bordercolor="white" cellspacing="0" cellpadding="5" border="0" width="100%" class="BBtable">
					<tr>
					<th class="list_bg"   width="6%"><a href="admin.php?controller=admin_apppub&orderby1=addr&orderby2=<?php echo $_smarty_tpl->tpl_vars['orderby2']->value;?>
&backupdb_id=<?php echo $_smarty_tpl->tpl_vars['backupdb_id']->value;?>
">执行时间</a></th>
						<th class="list_bg"   width="6%"><a href="admin.php?controller=admin_apppub&orderby1=cli_addr&orderby2=<?php echo $_smarty_tpl->tpl_vars['orderby2']->value;?>
&backupdb_id=<?php echo $_smarty_tpl->tpl_vars['backupdb_id']->value;?>
">用户名</a></th>
						<th class="list_bg"   width="7%"><a href="admin.php?controller=admin_apppub&orderby1=appname&orderby2=<?php echo $_smarty_tpl->tpl_vars['orderby2']->value;?>
&backupdb_id=<?php echo $_smarty_tpl->tpl_vars['backupdb_id']->value;?>
">数据库</a></th>
						<th class="list_bg"   width="10%"><a href="admin.php?controller=admin_apppub&orderby1=username&orderby2=<?php echo $_smarty_tpl->tpl_vars['orderby2']->value;?>
&backupdb_id=<?php echo $_smarty_tpl->tpl_vars['backupdb_id']->value;?>
">SQL语句</a></th>
						<th class="list_bg"   width="10%"><a href="admin.php?controller=admin_apppub&orderby1=realname&orderby2=<?php echo $_smarty_tpl->tpl_vars['orderby2']->value;?>
&backupdb_id=<?php echo $_smarty_tpl->tpl_vars['backupdb_id']->value;?>
">运维用户</a></th>
						<th class="list_bg"  width="10%">操作</th>
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
					<tr <?php if ($_smarty_tpl->tpl_vars['allsession']->value[$_smarty_tpl->getVariable('smarty')->value['section']['t']['index']]['dangerous'] > 5) {?>bgcolor="red"<?php } elseif ($_smarty_tpl->tpl_vars['allsession']->value[$_smarty_tpl->getVariable('smarty')->value['section']['t']['index']]['dangerous'] > 0) {?>bgcolor="yellow" <?php } elseif ($_smarty_tpl->getVariable('smarty')->value['section']['t']['index']%2 == 0) {?>bgcolor="f7f7f7"<?php }?>>
					<td><a href="admin.php?controller=admin_apppub&addr=<?php echo $_smarty_tpl->tpl_vars['allsession']->value[$_smarty_tpl->getVariable('smarty')->value['section']['t']['index']]['addr'];?>
&backupdb_id=<?php echo $_smarty_tpl->tpl_vars['backupdb_id']->value;?>
"><?php echo $_smarty_tpl->tpl_vars['allsession']->value[$_smarty_tpl->getVariable('smarty')->value['section']['t']['index']]['excutetime'];?>
</a></td>
						<td><a href="admin.php?controller=admin_apppub&cli_addr=<?php echo $_smarty_tpl->tpl_vars['allsession']->value[$_smarty_tpl->getVariable('smarty')->value['section']['t']['index']]['cli_addr'];?>
&backupdb_id=<?php echo $_smarty_tpl->tpl_vars['backupdb_id']->value;?>
"><?php echo $_smarty_tpl->tpl_vars['allsession']->value[$_smarty_tpl->getVariable('smarty')->value['section']['t']['index']]['username'];?>
</a></td>
						<td><a href="admin.php?controller=admin_apppub&appname=<?php echo $_smarty_tpl->tpl_vars['allsession']->value[$_smarty_tpl->getVariable('smarty')->value['section']['t']['index']]['appname'];?>
&backupdb_id=<?php echo $_smarty_tpl->tpl_vars['backupdb_id']->value;?>
"><?php echo $_smarty_tpl->tpl_vars['allsession']->value[$_smarty_tpl->getVariable('smarty')->value['section']['t']['index']]['dbname'];?>
</a></td>
						<td><a href="admin.php?controller=admin_apppub&serverip=<?php echo $_smarty_tpl->tpl_vars['allsession']->value[$_smarty_tpl->getVariable('smarty')->value['section']['t']['index']]['serverip'];?>
&backupdb_id=<?php echo $_smarty_tpl->tpl_vars['backupdb_id']->value;?>
"><?php echo $_smarty_tpl->tpl_vars['allsession']->value[$_smarty_tpl->getVariable('smarty')->value['section']['t']['index']]['sqltext'];?>
</a></td>
						<td><a href="admin.php?controller=admin_apppub&serverip=<?php echo $_smarty_tpl->tpl_vars['allsession']->value[$_smarty_tpl->getVariable('smarty')->value['section']['t']['index']]['serverip'];?>
&backupdb_id=<?php echo $_smarty_tpl->tpl_vars['backupdb_id']->value;?>
"><?php echo $_smarty_tpl->tpl_vars['allsession']->value[$_smarty_tpl->getVariable('smarty')->value['section']['t']['index']]['webuser'];?>
</a></td>
						<td><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/replay.gif" width="16" height="16" align="absmiddle">
					<a  id="p_<?php echo $_smarty_tpl->getVariable('smarty')->value['section']['t']['index']+1;?>
" onClick="return go('admin.php?controller=admin_rdp&mstsc=1&sid=<?php echo $_smarty_tpl->tpl_vars['sid']->value;?>
&rdptype=sql&replaystime=<?php echo $_smarty_tpl->tpl_vars['allsession']->value[$_smarty_tpl->getVariable('smarty')->value['section']['t']['index']]['uexcutetime'];?>
','p_<?php echo $_smarty_tpl->getVariable('smarty')->value['section']['t']['index']+1;?>
')" href="#" target="hide">回放</a></td>
					</tr>
					<?php endfor; endif; ?>
					<tr>
						<td colspan="12" align="right">
							共<?php echo $_smarty_tpl->tpl_vars['session_num']->value;?>
条会话  <?php echo $_smarty_tpl->tpl_vars['page_list']->value;?>
  页次：<?php echo $_smarty_tpl->tpl_vars['curr_page']->value;?>
/<?php echo $_smarty_tpl->tpl_vars['total_page']->value;?>
页  <?php echo $_smarty_tpl->tpl_vars['items_per_page']->value;?>
条日志/页  转到第<input name="pagenum" type="text" class="wbk" size="2" onKeyPress="if(event.keyCode==13) window.location='<?php echo $_smarty_tpl->tpl_vars['curr_url']->value;?>
&page='+this.value;">页 <!--当前数据表: <?php echo $_smarty_tpl->tpl_vars['now_table_name']->value;?>
--> 
						<!--
						<select  class="wbk"  name="table_name">
						<?php if (isset($_smarty_tpl->tpl_vars['smarty']->value['section']['t'])) unset($_smarty_tpl->tpl_vars['smarty']->value['section']['t']);
$_smarty_tpl->tpl_vars['smarty']->value['section']['t']['name'] = 't';
$_smarty_tpl->tpl_vars['smarty']->value['section']['t']['loop'] = is_array($_loop=$_smarty_tpl->tpl_vars['table_list']->value) ? count($_loop) : max(0, (int) $_loop); unset($_loop);
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
						<option value="<?php echo $_smarty_tpl->tpl_vars['table_list']->value[$_smarty_tpl->getVariable('smarty')->value['section']['t']['index']];?>
" <?php if ($_smarty_tpl->tpl_vars['table_list']->value[$_smarty_tpl->getVariable('smarty')->value['section']['t']['index']] == $_smarty_tpl->tpl_vars['now_table_name']->value) {?>selected<?php }?>><?php echo $_smarty_tpl->tpl_vars['table_list']->value[$_smarty_tpl->getVariable('smarty')->value['section']['t']['index']];?>
</option>
						<?php endfor; endif; ?>
						</select>
						-->
						</td>
					</tr>
				</table>
	</td>
  </tr>
</table>
<select  class="wbk"  id="app_act" style="display:none"><option value="applet" <?php if ($_SESSION['ADMIN_DEFAULT_CONTROL'] == 'applet') {?>selected<?php }?>>applet</option><option value="activeX" <?php if ($_SESSION['ADMIN_DEFAULT_CONTROL'] == 'activeX') {?>selected<?php }?>>activeX</option></select>
<?php echo '<script'; ?>
 language="javascript">
function go(url,iid){
	var app_act = document.getElementById('app_act').options[document.getElementById('app_act').options.selectedIndex].value;
	var hid = document.getElementById('hide');
	document.getElementById(iid).href=url+'&app_act='+app_act;
	//alert(hid.src);
	<?php if ($_smarty_tpl->tpl_vars['logindebug']->value) {?>
	window.open(document.getElementById(iid).href);
	<?php }?>
	return true;	
}
	<?php if ($_smarty_tpl->tpl_vars['member']->value['default_control'] == 0) {?>
	if(navigator.userAgent.indexOf("MSIE")>0) {
		document.getElementById('app_act').options.selectedIndex = 1;
	}
	<?php } elseif ($_smarty_tpl->tpl_vars['member']->value['default_control'] == 1) {?>
		document.getElementById('app_act').options.selectedIndex = 0;
	<?php } elseif ($_smarty_tpl->tpl_vars['member']->value['default_control'] == 2) {?>
		document.getElementById('app_act').options.selectedIndex = 1;
<?php }?>
<?php echo '</script'; ?>
>
<iframe name="hide" height="0" frameborder="0" scrolling="no"></iframe>
</body>
</html>



<?php }
}
?>