<?php /* Smarty version 3.1.27, created on 2017-07-30 09:49:51
         compiled from "/opt/freesvr/web/htdocs/freesvr/audit/template/admin/rdpsessionrun_list.tpl" */ ?>
<?php
/*%%SmartyHeaderCode:1619073120597d3b3f2e4247_05492003%%*/
if(!defined('SMARTY_DIR')) exit('no direct access allowed');
$_valid = $_smarty_tpl->decodeProperties(array (
  'file_dependency' => 
  array (
    '85f77f9c39a61c4f1bd065f172ad5f6cb1d634e8' => 
    array (
      0 => '/opt/freesvr/web/htdocs/freesvr/audit/template/admin/rdpsessionrun_list.tpl',
      1 => 1499420335,
      2 => 'file',
    ),
  ),
  'nocache_hash' => '1619073120597d3b3f2e4247_05492003',
  'variables' => 
  array (
    'template_root' => 0,
    '_config' => 0,
    'backupdb_id' => 0,
    'allsession' => 0,
    'curr_url' => 0,
    'admin_level' => 0,
    'session_num' => 0,
    'page_list' => 0,
    'curr_page' => 0,
    'total_page' => 0,
    'items_per_page' => 0,
    'now_table_name' => 0,
    'table_list' => 0,
    'member' => 0,
    'changelevelstr' => 0,
  ),
  'has_nocache_code' => false,
  'version' => '3.1.27',
  'unifunc' => 'content_597d3b3f3aabf5_08841816',
),false);
/*/%%SmartyHeaderCode%%*/
if ($_valid && !is_callable('content_597d3b3f3aabf5_08841816')) {
function content_597d3b3f3aabf5_08841816 ($_smarty_tpl) {

$_smarty_tpl->properties['nocache_hash'] = '1619073120597d3b3f2e4247_05492003';
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
 src="./template/admin/cssjs/jscal2.js"><?php echo '</script'; ?>
>
<?php echo '<script'; ?>
 src="./template/admin/cssjs/cn.js"><?php echo '</script'; ?>
>
<link type="text/css" rel="stylesheet" href="./template/admin/cssjs/jscal2.css" />
<link type="text/css" rel="stylesheet" href="./template/admin/cssjs/border-radius.css" />
<?php echo '<script'; ?>
 src="./template/admin/cssjs/global.functions.js"><?php echo '</script'; ?>
>
<?php echo '<script'; ?>
 type="text/javascript" src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/cssjs/jquery-1.10.2.min.js"><?php echo '</script'; ?>
>
<?php echo '<script'; ?>
 type="text/javascript" src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/cssjs/_ajaxdtree.js"><?php echo '</script'; ?>
>
<link href="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/cssjs/dtree.css" rel="stylesheet" type="text/css" />
<?php echo '<script'; ?>
 type="text/javascript" src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/cssjs/launchprogram.js"><?php echo '</script'; ?>
>

</head>
<?php echo '<script'; ?>
>
function searchit(){
	var url = "admin.php?controller=admin_rdprun";
	url += "&addr="+document.search.elements.ip.value;
	url += "&user="+document.search.elements.username.value;
	url += "&luser="+document.search.elements.luser.value;
	url += "&start1="+document.search.elements.f_rangeStart.value;
	<?php if ($_smarty_tpl->tpl_vars['_config']->value['LDAP']) {?>
	<?php if ($_smarty_tpl->tpl_vars['_config']->value['TREEMODE']) {?>
	var obj1=document.getElementById('groupiddh');	
	gid=obj1.value;
	<?php } else { ?>
	for(var i=1; true; i++){
		var obj=document.getElementById('groupid'+i);
		if(obj!=null&&obj.options.selectedIndex>-1){
			gid=obj.options[obj.options.selectedIndex].value;
			continue;
		}
		break;
	}
	<?php }?>
	url += "&groupid="+gid;
	<?php }?>
	document.search.action = url;
	document.search.submit();
	//alert(document.search.elements.action);
	//return false;
	return true;
}
function changeStyle(obj,c)
{
	if(c!='o'){
		obj.style.backgroundColor=c;
	}else{
		obj.style.backgroundColor="#FFCC80";
	}
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
<td width="84%" align="left" valign="top"><table width="100%" border="0" cellspacing="0" cellpadding="0"><tr><td valign="middle" class="hui_bj"><div class="menu">
<ul>
    <li class="me_b"><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an11.jpg" align="absmiddle"/><a href="admin.php?controller=admin_session&action=gateway_running_list">SSH 实时监控</a><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an33.jpg" align="absmiddle"/></li>
	<li class="me_b"><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an11.jpg" align="absmiddle"/><a href="admin.php?controller=admin_session&action=gateway_running_telnet">Telnet 实时监控</a><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an33.jpg" align="absmiddle"/></li>
    <li class="me_a"><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an1.jpg" align="absmiddle"/><a href="admin.php?controller=admin_rdprun">RDP实时监控</a><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an3.jpg" align="absmiddle"/></li>
	<li class="me_b"><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an11.jpg" align="absmiddle"/><a href="admin.php?controller=admin_vncrun">VNC实时监控</a><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an33.jpg" align="absmiddle"/></li>
</ul>
</div></td></tr>


   <tr>
    <td class="main_content"><form action="admin.php?controller=admin_session&backupdb_id=<?php echo $_smarty_tpl->tpl_vars['backupdb_id']->value;?>
" method="post" name="search" >
	
	<?php echo $_smarty_tpl->getSubTemplate ("select_sgroup_ajax.tpl", $_smarty_tpl->cache_id, $_smarty_tpl->compile_id, 0, $_smarty_tpl->cache_lifetime, array(), 0);
?>
          
&nbsp;         服务器地址：<input type="text" name="ip"  size="13" align="top" class="wbk"/>
&nbsp;堡垒机用户：<input type="text" name="luser" size="13" class="wbk"/>
&nbsp;系统用户：<input type="text" name="username" size="13" class="wbk"/>
&nbsp;开始日期：<input type="text"  name="f_rangeStart" size="13" id="f_rangeStart" value="" class="wbk"/> 
<input type="button" onClick="changetype('timetype3')" id="f_rangeStart_trigger" name="f_rangeStart_trigger" value="选择时间" class="wbk">
&nbsp;<select  class="wbk"  id="app_act" style="display:none"><option value="applet" <?php if ($_SESSION['ADMIN_DEFAULT_CONTROL'] == 'applet') {?>selected<?php }?>>applet</option><option value="activeX" <?php if ($_SESSION['ADMIN_DEFAULT_CONTROL'] == 'activeX') {?>selected<?php }?>>activeX</option></select>&nbsp;&nbsp;<input type="submit" height="35" align="middle" onClick="return searchit();" border="0" value=" 确定 " class="bnnew2"/>
 <?php echo '<script'; ?>
 type="text/javascript">
var cal = Calendar.setup({
    onSelect: function(cal) { cal.hide() },
    showTime: true
});
cal.manageFields("f_rangeStart_trigger", "f_rangeStart", "%Y-%m-%d %H:%M:%S");


<?php echo '</script'; ?>
></form></td>
  </tr>
  <tr><td><table bordercolor="white" cellspacing="0" cellpadding="5" border="0" width="100%" class="BBtable">
					<tr>
					<th class="list_bg"  width="10%">运维用户</th>
					<th class="list_bg"  width="10%">真实姓名</th>
				<th class="list_bg"  width="10%">系统用户</th>
				<th class="list_bg"  width="10%">来源地址</th>
				<th class="list_bg"  width="10%">目标地址</th>
				<th class="list_bg"  width="10%">开始时间</th>
						<th class="list_bg"   width="13%">操作</th>
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
					<tr <?php if ($_smarty_tpl->tpl_vars['allsession']->value[$_smarty_tpl->getVariable('smarty')->value['section']['t']['index']]['dangerous'] > 1) {?>bgcolor="red"<?php } elseif ($_smarty_tpl->tpl_vars['allsession']->value[$_smarty_tpl->getVariable('smarty')->value['section']['t']['index']]['dangerous'] > 0) {?>bgcolor="yellow" <?php } elseif ($_smarty_tpl->getVariable('smarty')->value['section']['t']['index']%2 == 0) {?>bgcolor="f7f7f7"<?php }?> onmouseover="changeStyle(this,'o');" onmouseout="changeStyle(this,'<?php if ($_smarty_tpl->tpl_vars['allsession']->value[$_smarty_tpl->getVariable('smarty')->value['section']['t']['index']]['dangerous'] > 1) {?>red<?php } elseif ($_smarty_tpl->tpl_vars['allsession']->value[$_smarty_tpl->getVariable('smarty')->value['section']['t']['index']]['dangerous'] > 0) {?>yellow<?php } elseif ($_smarty_tpl->getVariable('smarty')->value['section']['t']['index']%2 == 0) {?>f7f7f7<?php }?>');">

					<td><a href="admin.php?controller=admin_rdprun&user=<?php echo $_smarty_tpl->tpl_vars['allsession']->value[$_smarty_tpl->getVariable('smarty')->value['section']['t']['index']]['user'];?>
"><?php echo $_smarty_tpl->tpl_vars['allsession']->value[$_smarty_tpl->getVariable('smarty')->value['section']['t']['index']]['luser'];?>
</a></td>
					<td><a href="admin.php?controller=admin_rdprun&realname=<?php echo urlencode($_smarty_tpl->tpl_vars['allsession']->value[$_smarty_tpl->getVariable('smarty')->value['section']['t']['index']]['realname']);?>
"><?php echo $_smarty_tpl->tpl_vars['allsession']->value[$_smarty_tpl->getVariable('smarty')->value['section']['t']['index']]['realname'];?>
</a></td>
					<td><a href="admin.php?controller=admin_rdprun&luser=<?php echo $_smarty_tpl->tpl_vars['allsession']->value[$_smarty_tpl->getVariable('smarty')->value['section']['t']['index']]['luser'];?>
"><?php echo $_smarty_tpl->tpl_vars['allsession']->value[$_smarty_tpl->getVariable('smarty')->value['section']['t']['index']]['user'];?>
</a></td>
					<td><a href="admin.php?controller=admin_session&addr=<?php echo $_smarty_tpl->tpl_vars['allsession']->value[$_smarty_tpl->getVariable('smarty')->value['section']['t']['index']]['cli_addr'];?>
"><?php echo $_smarty_tpl->tpl_vars['allsession']->value[$_smarty_tpl->getVariable('smarty')->value['section']['t']['index']]['cli_addr'];?>
</a></td>
					
					<td><a href="admin.php?controller=admin_rdprun&addr=<?php echo $_smarty_tpl->tpl_vars['allsession']->value[$_smarty_tpl->getVariable('smarty')->value['section']['t']['index']]['addr'];?>
"><?php echo $_smarty_tpl->tpl_vars['allsession']->value[$_smarty_tpl->getVariable('smarty')->value['section']['t']['index']]['addr'];?>
</a></td>
					
					<td><?php echo $_smarty_tpl->tpl_vars['allsession']->value[$_smarty_tpl->getVariable('smarty')->value['section']['t']['index']]['start'];?>
</ td>
					<td style="TEXT-ALIGN: left;"><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/036.gif" width="16" height="16" align="absmiddle">
					<a  id="p_<?php echo $_smarty_tpl->tpl_vars['allsession']->value[$_smarty_tpl->getVariable('smarty')->value['section']['t']['index']]['sid'];?>
"  onclick="return go('<?php echo $_smarty_tpl->tpl_vars['curr_url']->value;?>
&mstsc=1&sid=<?php echo $_smarty_tpl->tpl_vars['allsession']->value[$_smarty_tpl->getVariable('smarty')->value['section']['t']['index']]['sid'];?>
','p_<?php echo $_smarty_tpl->tpl_vars['allsession']->value[$_smarty_tpl->getVariable('smarty')->value['section']['t']['index']]['sid'];?>
')" href="#" target="hide">监控</a>&nbsp;
					| <img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/disconnect.png" width="16" height="16" align="absmiddle">
					<a href="admin.php?controller=admin_rdprun&action=cutoff&sid=<?php echo $_smarty_tpl->tpl_vars['allsession']->value[$_smarty_tpl->getVariable('smarty')->value['section']['t']['index']]['sid'];?>
" >断开</a>

						
						<?php if ($_smarty_tpl->tpl_vars['admin_level']->value == 2) {?> | <img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/scico.gif" width="16" height="16" align="absmiddle"><a href="admin.php?controller=admin_rdprun&action=del_session&sid=<?php echo $_smarty_tpl->tpl_vars['allsession']->value[$_smarty_tpl->getVariable('smarty')->value['section']['t']['index']]['sid'];?>
">删除</a><?php }?></td>
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
<?php echo '<script'; ?>
 language="javascript">
function go(url,iid){
	var app_act = document.getElementById('app_act').options[document.getElementById('app_act').options.selectedIndex].value;
	var hid = document.getElementById('hide');
	url=url+'&app_act='+app_act;
	$.get(url, {Action:"get",Name:"lulu"}, function (data, textStatus){
		this; // 在这里this指向的是Ajax请求的选项配置信息，请参考下图
		if(data.substring(0,<?php if ($_SESSION['urlprotocol'] == 1) {?>11<?php } else { ?>10<?php }?>)=='<?php if ($_SESSION['urlprotocol'] == 1) {?>baoleiji<?php } else { ?>freesvr<?php }?>://'){
			launcher(data);
		}else{
			eval(data);
		}
	});
	return false;
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

<?php echo '<script'; ?>
>
<?php if ($_smarty_tpl->tpl_vars['_config']->value['LDAP']) {?>
<?php echo $_smarty_tpl->tpl_vars['changelevelstr']->value;?>

<?php }?>
<?php echo '</script'; ?>
>
<iframe id="hide" name="hide" height="0"  frameborder="0" scrolling="no"></iframe>
<input style="width:0;height:0;display:none" id="protocol" value="" />
</body>
</html>


<?php }
}
?>