<?php /* Smarty version 3.1.27, created on 2017-06-27 09:28:49
         compiled from "/opt/freesvr/web/htdocs/freesvr/audit/template/admin/cmdlistreport.tpl" */ ?>
<?php
/*%%SmartyHeaderCode:6014996095951b4d18c4892_62175003%%*/
if(!defined('SMARTY_DIR')) exit('no direct access allowed');
$_valid = $_smarty_tpl->decodeProperties(array (
  'file_dependency' => 
  array (
    'af36ab54f4ec8f7d63add76423bfd6b428c8e826' => 
    array (
      0 => '/opt/freesvr/web/htdocs/freesvr/audit/template/admin/cmdlistreport.tpl',
      1 => 1491355204,
      2 => 'file',
    ),
  ),
  'nocache_hash' => '6014996095951b4d18c4892_62175003',
  'variables' => 
  array (
    'language' => 0,
    'template_root' => 0,
    'curr_url' => 0,
    'f_rangeStart' => 0,
    'f_rangeEnd' => 0,
    'gid' => 0,
    'orderby2' => 0,
    'allcommand' => 0,
    'command_num' => 0,
    'page_list' => 0,
    'curr_page' => 0,
    'total_page' => 0,
    'items_per_page' => 0,
    'now_table_name' => 0,
    'admin_level' => 0,
  ),
  'has_nocache_code' => false,
  'version' => '3.1.27',
  'unifunc' => 'content_5951b4d1979862_67159064',
),false);
/*/%%SmartyHeaderCode%%*/
if ($_valid && !is_callable('content_5951b4d1979862_67159064')) {
function content_5951b4d1979862_67159064 ($_smarty_tpl) {
if (!is_callable('smarty_modifier_date_format')) require_once '/opt/freesvr/web/htdocs/freesvr/audit/smarty/plugins/modifier.date_format.php';

$_smarty_tpl->properties['nocache_hash'] = '6014996095951b4d18c4892_62175003';
?>
<!doctype html public "-//w3c//dtd html 4.0 transitional//en">
<html>
<head>
<title><?php echo $_smarty_tpl->tpl_vars['language']->value['Black'];
echo $_smarty_tpl->tpl_vars['language']->value['group'];
echo $_smarty_tpl->tpl_vars['language']->value['List'];?>
</title>
<meta name="generator" content="editplus">
<meta name="author" content="nuttycoder">
<link href="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/all_purpose_style.css" rel="stylesheet" type="text/css" />
<link type="text/css" rel="stylesheet" href="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/cssjs/border-radius.css" />
<link type="text/css" rel="stylesheet" href="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/cssjs/jscal2.css" />
<?php echo '<script'; ?>
 src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/cssjs/jscal2.js"><?php echo '</script'; ?>
>
<?php echo '<script'; ?>
 src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/cssjs/cn.js"><?php echo '</script'; ?>
>
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
<?php echo '<script'; ?>
 type="text/javascript">
function searchit(){
	document.search.action = "admin.php?controller=admin_reports&action=cmdlistreport";
	document.search.action += "&username="+document.search.username.value;
	document.search.action += "&ip="+document.search.ip.value;
	document.search.action += "&start="+document.search.f_rangeStart.value;
	document.search.action += "&end="+document.search.f_rangeEnd.value;
	//alert(document.search.action);
	//return false;
	return true;
}
<!--
function openwin() {
window.open ("admin.php?controller=admin_reports&action=cmdlistreport_users", "newwindow", "height=400, width=800, toolbar=no, menubar=no, scrollbars=auto, resizable=yes, location=no, status=no")
}
function openwin2() {
window.open ("admin.php?controller=admin_reports&action=cmdlistreport_ips", "newwindow1", "height=400, width=800, toolbar=no, menubar=no, scrollbars=auto, resizable=yes, location=no, status=no")
}
function openwin3() {
window.open ("admin.php?controller=admin_reports&action=cmdlistreport_cmds", "newwindow2", "height=400, width=800, toolbar=no, menubar=no, scrollbars=auto, resizable=yes, location=no, status=no")
}
//-->
<?php echo '</script'; ?>
>
<body>



	<table width="100%" border="0" cellspacing="0" cellpadding="0">
 <tr><td valign="middle" class="hui_bj"><div class="menu">
<ul>
	<li class="me_b"><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an11.jpg" align="absmiddle"/><a href="admin.php?controller=admin_reports&action=commandreport">命令总计</a><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an33.jpg" align="absmiddle"/></li>
	<li class="me_b"><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an11.jpg" align="absmiddle"/><a href="admin.php?controller=admin_reports&action=cmdcachereport">命令统计</a><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an33.jpg" align="absmiddle"/></li>
	<li class="me_a"><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an1.jpg" align="absmiddle"/><a href="admin.php?controller=admin_reports&action=cmdlistreport">命令列表</a><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an3.jpg" align="absmiddle"/></li>
	<li class="me_b"><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an11.jpg" align="absmiddle"/><a href="admin.php?controller=admin_reports&action=appreport&number=2">应用报表</a><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an33.jpg" align="absmiddle"/></li>
	<li class="me_b"><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an11.jpg" align="absmiddle"/><a href="admin.php?controller=admin_reports&action=sftpreport&number=3">SFTP<?php echo $_smarty_tpl->tpl_vars['language']->value['Command'];
echo $_smarty_tpl->tpl_vars['language']->value['report'];?>
</a><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an33.jpg" align="absmiddle"/></li>	
	<li class="me_b"><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an11.jpg" align="absmiddle"/><a href="admin.php?controller=admin_reports&action=ftpreport&number=6">FTP<?php echo $_smarty_tpl->tpl_vars['language']->value['Command'];
echo $_smarty_tpl->tpl_vars['language']->value['report'];?>
</a><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an33.jpg" align="absmiddle"/></li>
</ul>
</div></td></tr>
 <tr>
    <td class="main_content">
<form action="<?php echo $_smarty_tpl->tpl_vars['curr_url']->value;?>
" method="post" name="search" >
运维用户：<input type="text" class="wbk" name="username" />
	 &nbsp;&nbsp;<INPUT height="35" align="middle" class="wbk" onclick="openwin()"  type="button" border="0" value="选择">&nbsp;&nbsp;
设备：<input type="text" class="wbk" size="8" name="ip" />
		&nbsp;&nbsp;<INPUT height="35" align="middle" class="wbk" onclick="openwin2()"  type="button" border="0" value="选择">&nbsp;&nbsp;
      <INPUT height="35" align="middle" class="wbk" onclick="openwin3()"  type="button" border="0" value="命令列表">&nbsp;&nbsp;
<?php echo $_smarty_tpl->tpl_vars['language']->value['Starttime'];?>
：<input type="text" class="wbk"  name="f_rangeStart" size="16" id="f_rangeStart" value="<?php echo smarty_modifier_date_format($_smarty_tpl->tpl_vars['f_rangeStart']->value,'%Y-%m-%d');?>
" />
 <input type="button" onclick="changetype('timetype3')" id="f_rangeStart_trigger" name="f_rangeStart_trigger" value="<?php echo $_smarty_tpl->tpl_vars['language']->value['Edittime'];?>
"  class="wbk">


 <?php echo $_smarty_tpl->tpl_vars['language']->value['Endtime'];?>
：
<input  type="text" class="wbk" name="f_rangeEnd" size="16" id="f_rangeEnd"  value="<?php echo smarty_modifier_date_format($_smarty_tpl->tpl_vars['f_rangeEnd']->value,'%Y-%m-%d');?>
" />
 <input type="button" onclick="changetype('timetype3')" id="f_rangeEnd_trigger" name="f_rangeEnd_trigger" value="<?php echo $_smarty_tpl->tpl_vars['language']->value['Edittime'];?>
"  class="wbk">
 &nbsp;&nbsp;<input type="submit" height="35" align="middle" onClick="return searchit();" border="0" value=" 确定 " class="bnnew2"/>
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
</form> 
	  </td>
  </tr>
  <tr>
  <tr>
	<td class=""><table bordercolor="white" cellspacing="1" cellpadding="5" border="0" width="100%" class="BBtable">
	<form name="ip_list" action="admin.php?controller=admin_reports&action=del_cmdlistreport" method="post">
			<tr>
				<th class="list_bg"  width="10%"><a href="admin.php?controller=admin_reports&action=cmdlistreport&orderby1=luser&gid=<?php echo $_smarty_tpl->tpl_vars['gid']->value;?>
&orderby2=<?php echo $_smarty_tpl->tpl_vars['orderby2']->value;?>
" >运维用户</a></th>
				<th class="list_bg"  width="10%"><a href="admin.php?controller=admin_reports&action=cmdlistreport&orderby1=addr&gid=<?php echo $_smarty_tpl->tpl_vars['gid']->value;?>
&orderby2=<?php echo $_smarty_tpl->tpl_vars['orderby2']->value;?>
" >设备IP</a></th>
				<th class="list_bg"  width="10%"><a href="admin.php?controller=admin_reports&action=cmdlistreport&orderby1=at&gid=<?php echo $_smarty_tpl->tpl_vars['gid']->value;?>
&orderby2=<?php echo $_smarty_tpl->tpl_vars['orderby2']->value;?>
" >执行时间</a></th>
				<th class="list_bg"  width=""><a href="admin.php?controller=admin_reports&action=cmdlistreport&orderby1=cmd&gid=<?php echo $_smarty_tpl->tpl_vars['gid']->value;?>
&orderby2=<?php echo $_smarty_tpl->tpl_vars['orderby2']->value;?>
" >命令</a></th>
				<th class="list_bg"  width="10%"><a href="admin.php?controller=admin_reports&action=cmdlistreport&orderby1=dangerlevel&gid=<?php echo $_smarty_tpl->tpl_vars['gid']->value;?>
&orderby2=<?php echo $_smarty_tpl->tpl_vars['orderby2']->value;?>
" >级别</a></th>			
			</tr>
			<?php if (isset($_smarty_tpl->tpl_vars['smarty']->value['section']['t'])) unset($_smarty_tpl->tpl_vars['smarty']->value['section']['t']);
$_smarty_tpl->tpl_vars['smarty']->value['section']['t']['name'] = 't';
$_smarty_tpl->tpl_vars['smarty']->value['section']['t']['loop'] = is_array($_loop=$_smarty_tpl->tpl_vars['allcommand']->value) ? count($_loop) : max(0, (int) $_loop); unset($_loop);
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
				<td><?php echo $_smarty_tpl->tpl_vars['allcommand']->value[$_smarty_tpl->getVariable('smarty')->value['section']['t']['index']]['luser'];?>
</td>
				<td><?php echo $_smarty_tpl->tpl_vars['allcommand']->value[$_smarty_tpl->getVariable('smarty')->value['section']['t']['index']]['addr'];?>
</td>				
				<td><?php echo $_smarty_tpl->tpl_vars['allcommand']->value[$_smarty_tpl->getVariable('smarty')->value['section']['t']['index']]['at'];?>
</td>				
				<td><?php echo $_smarty_tpl->tpl_vars['allcommand']->value[$_smarty_tpl->getVariable('smarty')->value['section']['t']['index']]['cmd'];?>
</td>				
				<td><?php if (!$_smarty_tpl->tpl_vars['allcommand']->value[$_smarty_tpl->getVariable('smarty')->value['section']['t']['index']]['dangerlevel']) {?>正常<?php } elseif ($_smarty_tpl->tpl_vars['allcommand']->value[$_smarty_tpl->getVariable('smarty')->value['section']['t']['index']]['dangerlevel'] == 1) {?>危险<?php } elseif ($_smarty_tpl->tpl_vars['allcommand']->value[$_smarty_tpl->getVariable('smarty')->value['section']['t']['index']]['dangerlevel'] == 2) {?>严重<?php } elseif ($_smarty_tpl->tpl_vars['allcommand']->value[$_smarty_tpl->getVariable('smarty')->value['section']['t']['index']]['dangerlevel'] == 3) {?>警告<?php } elseif ($_smarty_tpl->tpl_vars['allcommand']->value[$_smarty_tpl->getVariable('smarty')->value['section']['t']['index']]['dangerlevel'] == 4) {?>复核<?php }?></td>
			</tr>
			<?php endfor; endif; ?>
			
			
			<tr>
			<td align="left" colspan="1">

			<input type="hidden" name="add" value="new" >
			</td>
				<td colspan="6" align="right">
					<?php echo $_smarty_tpl->tpl_vars['language']->value['all'];
echo $_smarty_tpl->tpl_vars['command_num']->value;
echo $_smarty_tpl->tpl_vars['language']->value['Command'];?>
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
<input name="pagenum" type="text" size="2" onKeyPress="if(event.keyCode==13) window.location='admin.php?controller=admin_reports&action=cmdlistreport&page='+this.value;"><?php echo $_smarty_tpl->tpl_vars['language']->value['page'];?>
<!--当前数据表: <?php echo $_smarty_tpl->tpl_vars['now_table_name']->value;?>
-->   导出：<a href="<?php echo $_smarty_tpl->tpl_vars['curr_url']->value;?>
&derive=1" target="hide"><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/excel.png" border=0></a>  <a href="<?php echo $_smarty_tpl->tpl_vars['curr_url']->value;?>
&derive=2" target="hide"><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/html.png" border=0></a>  <a href="<?php echo $_smarty_tpl->tpl_vars['curr_url']->value;?>
&derive=3" target="hide"><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/word.png" border=0></a>  <a href="<?php echo $_smarty_tpl->tpl_vars['curr_url']->value;?>
&derive=4" target="hide"><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/pdf.png" border=0></a> <?php if ($_smarty_tpl->tpl_vars['admin_level']->value == 1) {?><a href="<?php echo $_smarty_tpl->tpl_vars['curr_url']->value;?>
&delete=1" target="hide"></a><?php }?>
				</td>
			</tr>
			</form>
		</table>
	</td>
  </tr>
</table>


</body>
<iframe name="hide" height="0" frameborder="0" scrolling="no"></iframe>
</html>


<?php }
}
?>