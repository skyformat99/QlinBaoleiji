<?php /* Smarty version 3.1.27, created on 2017-06-26 12:13:44
         compiled from "/opt/freesvr/web/htdocs/freesvr/audit/template/admin/adminlog_report.tpl" */ ?>
<?php
/*%%SmartyHeaderCode:2072993092595089f82ebca9_91494923%%*/
if(!defined('SMARTY_DIR')) exit('no direct access allowed');
$_valid = $_smarty_tpl->decodeProperties(array (
  'file_dependency' => 
  array (
    'a7be444338d3da082e1eb76b09ab3d99eac83bd3' => 
    array (
      0 => '/opt/freesvr/web/htdocs/freesvr/audit/template/admin/adminlog_report.tpl',
      1 => 1474793220,
      2 => 'file',
    ),
  ),
  'nocache_hash' => '2072993092595089f82ebca9_91494923',
  'variables' => 
  array (
    'language' => 0,
    'template_root' => 0,
    'f_rangeStart' => 0,
    'f_rangeEnd' => 0,
    'orderby2' => 0,
    'allmember' => 0,
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
  'unifunc' => 'content_595089f83ecc09_69689439',
),false);
/*/%%SmartyHeaderCode%%*/
if ($_valid && !is_callable('content_595089f83ecc09_69689439')) {
function content_595089f83ecc09_69689439 ($_smarty_tpl) {
if (!is_callable('smarty_modifier_date_format')) require_once '/opt/freesvr/web/htdocs/freesvr/audit/smarty/plugins/modifier.date_format.php';

$_smarty_tpl->properties['nocache_hash'] = '2072993092595089f82ebca9_91494923';
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
	function searchit(){
		document.search.action = "admin.php?controller=admin_reports&action=admin_log";
		document.search.action += "&f_rangeStart="+document.search.f_rangeStart.value;
		document.search.action += "&f_rangeEnd="+document.search.f_rangeEnd.value;
		document.search.action += "&administrator="+document.search.administrator.value;
		document.search.action += "&luser="+document.search.luser.value;
		document.search.action += "&resource_user="+document.search.resource_user.value;
		document.search.action += "&actions="+document.search.actions.value;
		document.search.action += "&resource="+document.search.resource.value;
		document.search.submit();
		//alert(document.search.action);
		//return false;
		return true;
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
/images/an11.jpg" align="absmiddle"/><a href="admin.php?controller=admin_reports&action=systempriority_search">系统权限</a><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an33.jpg" align="absmiddle"/></li>
	<li class="me_b"><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an11.jpg" align="absmiddle"/><a href="admin.php?controller=admin_reports&action=apppriority_search">应用权限</a><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an33.jpg" align="absmiddle"/></li>
   <li class="me_b"><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an11.jpg" align="absmiddle"/><a href="admin.php?controller=admin_reports&action=systemaccount">系统账号</a><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an33.jpg" align="absmiddle"/></li>
	<li class="me_b"><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an11.jpg" align="absmiddle"/><a href="admin.php?controller=admin_reports&action=appaccount">应用账号</a><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an33.jpg" align="absmiddle"/></li>
	<?php if ($_SESSION['ADMIN_LEVEL'] == 1 || $_SESSION['ADMIN_LEVEL'] == 2) {?>
	<li class="me_a"><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an1.jpg" align="absmiddle"/><a href="admin.php?controller=admin_reports&action=admin_log">变更报表</a><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an3.jpg" align="absmiddle"/></li>
	<?php }?>
</ul>
</div></td></tr>
			<tr><td class="main_content" >
			<form name ='search' action='admin.php?controller=admin_log&action=adminlog' method=post>
管理员:<input  type="text" class="wbk" name="administrator" size="13" id="administrator"   />&nbsp;&nbsp;
运维用户:<input  type="text" class="wbk" name="luser" size="13" id="luser"   />&nbsp;&nbsp;
资源用户:<input  type="text" class="wbk" name="resource_user" size="13" id="resource_user"   />&nbsp;&nbsp;
操作:<select name="actions" id="actions"  >
<option value=""></option>
<option value="add">增加</option>
<option value="del">删除</option>
<option value="edit">编辑</option>
</select>
&nbsp;&nbsp;
资源:<input  type="text" class="wbk" name="resource" size="13" id="resource"   />&nbsp;&nbsp;
<?php echo $_smarty_tpl->tpl_vars['language']->value['Starttime'];?>
：<input type="text" class="wbk"  name="f_rangeStart" size="13" id="f_rangeStart" value="<?php echo smarty_modifier_date_format($_smarty_tpl->tpl_vars['f_rangeStart']->value,'%Y-%m-%d');?>
" />
 <input type="button" onclick="changetype('timetype3')" id="f_rangeStart_trigger" name="f_rangeStart_trigger" value="<?php echo $_smarty_tpl->tpl_vars['language']->value['Edittime'];?>
"  class="wbk">


 <?php echo $_smarty_tpl->tpl_vars['language']->value['Endtime'];?>
：
<input  type="text" class="wbk" name="f_rangeEnd" size="13" id="f_rangeEnd"  value="<?php echo smarty_modifier_date_format($_smarty_tpl->tpl_vars['f_rangeEnd']->value,'%Y-%m-%d');?>
" />
 <input type="button" onclick="changetype('timetype3')" id="f_rangeEnd_trigger" name="f_rangeEnd_trigger" value="<?php echo $_smarty_tpl->tpl_vars['language']->value['Edittime'];?>
"  class="wbk">
 &nbsp;&nbsp;<input type="submit" height="35" align="middle" onClick="return searchit();" border="0" value=" 确定 " class="bnnew2"/>
  <?php echo '<script'; ?>
 type="text/javascript">
var cal = Calendar.setup({
    onSelect: function(cal) { cal.hide() },
    showTime: false
});
cal.manageFields("f_rangeStart_trigger", "f_rangeStart", "%Y-%m-%d");
cal.manageFields("f_rangeEnd_trigger", "f_rangeEnd", "%Y-%m-%d");
<?php echo '</script'; ?>
>
			</form>
			</td></tr>
	<tr>
		<td>	
			<table bordercolor="white" cellspacing="1" cellpadding="5" border="0" width="100%"  class="BBtable">
					<tr>
						<th class="list_bg"  width="8%">序号</th>
						<th class="list_bg"  width="10%"><a href="admin.php?controller=admin_reports&action=admin_log&orderby1=administrator&orderby2=<?php echo $_smarty_tpl->tpl_vars['orderby2']->value;?>
" ><?php echo $_smarty_tpl->tpl_vars['language']->value['Administrator'];?>
</a></th>
						<th class="list_bg"  width="15%"><a href="admin.php?controller=admin_reports&action=admin_log&orderby1=action&orderby2=<?php echo $_smarty_tpl->tpl_vars['orderby2']->value;?>
" ><?php echo $_smarty_tpl->tpl_vars['language']->value['Operate'];?>
</a></th>
						<th class="list_bg"  width="50%"><a href="admin.php?controller=admin_reports&action=admin_log&orderby1=resource&orderby2=<?php echo $_smarty_tpl->tpl_vars['orderby2']->value;?>
" >操作对象</a></th>
						<th class="list_bg"  width="5%"><a href="admin.php?controller=admin_reports&action=admin_log&orderby1=result&orderby2=<?php echo $_smarty_tpl->tpl_vars['orderby2']->value;?>
" >结果</a></th>
						<th class="list_bg"  ><a href="admin.php?controller=admin_log&action=adminlog&orderby1=optime&orderby2=<?php echo $_smarty_tpl->tpl_vars['orderby2']->value;?>
" ><?php echo $_smarty_tpl->tpl_vars['language']->value['OperateTime'];?>
</a></th>
					</tr>
					<form name="member_list" action="admin.php?controller=admin_reports&action=admin_log" method="post">
					<?php if (isset($_smarty_tpl->tpl_vars['smarty']->value['section']['t'])) unset($_smarty_tpl->tpl_vars['smarty']->value['section']['t']);
$_smarty_tpl->tpl_vars['smarty']->value['section']['t']['name'] = 't';
$_smarty_tpl->tpl_vars['smarty']->value['section']['t']['loop'] = is_array($_loop=$_smarty_tpl->tpl_vars['allmember']->value) ? count($_loop) : max(0, (int) $_loop); unset($_loop);
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
						<td><?php echo $_smarty_tpl->getVariable('smarty')->value['section']['t']['index']+1;?>
</td>
						<td><?php echo $_smarty_tpl->tpl_vars['allmember']->value[$_smarty_tpl->getVariable('smarty')->value['section']['t']['index']]['administrator'];?>
</td>
						<td><?php echo $_smarty_tpl->tpl_vars['allmember']->value[$_smarty_tpl->getVariable('smarty')->value['section']['t']['index']]['action'];?>
</td>
						<td><?php if ($_smarty_tpl->tpl_vars['allmember']->value[$_smarty_tpl->getVariable('smarty')->value['section']['t']['index']]['type'] == 1) {?>系统用户组：<?php echo $_smarty_tpl->tpl_vars['allmember']->value[$_smarty_tpl->getVariable('smarty')->value['section']['t']['index']]['resource'];?>
,运维用户:<?php echo $_smarty_tpl->tpl_vars['allmember']->value[$_smarty_tpl->getVariable('smarty')->value['section']['t']['index']]['luser'];?>

							<?php } elseif ($_smarty_tpl->tpl_vars['allmember']->value[$_smarty_tpl->getVariable('smarty')->value['section']['t']['index']]['type'] == 2) {?>系统用户组：<?php echo $_smarty_tpl->tpl_vars['allmember']->value[$_smarty_tpl->getVariable('smarty')->value['section']['t']['index']]['resource'];?>
,资源组:<?php echo $_smarty_tpl->tpl_vars['allmember']->value[$_smarty_tpl->getVariable('smarty')->value['section']['t']['index']]['lgroup'];?>

							<?php } elseif ($_smarty_tpl->tpl_vars['allmember']->value[$_smarty_tpl->getVariable('smarty')->value['section']['t']['index']]['type'] == 3) {?>应用用户组：<?php echo $_smarty_tpl->tpl_vars['allmember']->value[$_smarty_tpl->getVariable('smarty')->value['section']['t']['index']]['resource'];?>
,运维用户:<?php echo $_smarty_tpl->tpl_vars['allmember']->value[$_smarty_tpl->getVariable('smarty')->value['section']['t']['index']]['luser'];?>

							<?php } elseif ($_smarty_tpl->tpl_vars['allmember']->value[$_smarty_tpl->getVariable('smarty')->value['section']['t']['index']]['type'] == 4) {?>应用用户组：<?php echo $_smarty_tpl->tpl_vars['allmember']->value[$_smarty_tpl->getVariable('smarty')->value['section']['t']['index']]['resource'];?>
,资源组:<?php echo $_smarty_tpl->tpl_vars['allmember']->value[$_smarty_tpl->getVariable('smarty')->value['section']['t']['index']]['lgroup'];?>

							<?php } elseif ($_smarty_tpl->tpl_vars['allmember']->value[$_smarty_tpl->getVariable('smarty')->value['section']['t']['index']]['type'] == 5) {?>设备：<?php echo $_smarty_tpl->tpl_vars['allmember']->value[$_smarty_tpl->getVariable('smarty')->value['section']['t']['index']]['resource'];?>
，设备用户：<?php echo $_smarty_tpl->tpl_vars['allmember']->value[$_smarty_tpl->getVariable('smarty')->value['section']['t']['index']]['resource_user'];?>
,运维用户:<?php echo $_smarty_tpl->tpl_vars['allmember']->value[$_smarty_tpl->getVariable('smarty')->value['section']['t']['index']]['luser'];?>

							<?php } elseif ($_smarty_tpl->tpl_vars['allmember']->value[$_smarty_tpl->getVariable('smarty')->value['section']['t']['index']]['type'] == 6) {?>设备：<?php echo $_smarty_tpl->tpl_vars['allmember']->value[$_smarty_tpl->getVariable('smarty')->value['section']['t']['index']]['resource'];?>
，设备用户：<?php echo $_smarty_tpl->tpl_vars['allmember']->value[$_smarty_tpl->getVariable('smarty')->value['section']['t']['index']]['resource_user'];?>
,资源组:<?php echo $_smarty_tpl->tpl_vars['allmember']->value[$_smarty_tpl->getVariable('smarty')->value['section']['t']['index']]['lgroup'];?>

							<?php } elseif ($_smarty_tpl->tpl_vars['allmember']->value[$_smarty_tpl->getVariable('smarty')->value['section']['t']['index']]['type'] == 7) {?>应用名称：<?php echo $_smarty_tpl->tpl_vars['allmember']->value[$_smarty_tpl->getVariable('smarty')->value['section']['t']['index']]['resource'];?>
,运维用户:<?php echo $_smarty_tpl->tpl_vars['allmember']->value[$_smarty_tpl->getVariable('smarty')->value['section']['t']['index']]['luser'];?>

							<?php } elseif ($_smarty_tpl->tpl_vars['allmember']->value[$_smarty_tpl->getVariable('smarty')->value['section']['t']['index']]['type'] == 8) {?>应用名称：<?php echo $_smarty_tpl->tpl_vars['allmember']->value[$_smarty_tpl->getVariable('smarty')->value['section']['t']['index']]['resource'];?>
,资源组:<?php echo $_smarty_tpl->tpl_vars['allmember']->value[$_smarty_tpl->getVariable('smarty')->value['section']['t']['index']]['lgroup'];?>

							<?php } elseif ($_smarty_tpl->tpl_vars['allmember']->value[$_smarty_tpl->getVariable('smarty')->value['section']['t']['index']]['type'] == 11) {?>运维用户:<?php echo $_smarty_tpl->tpl_vars['allmember']->value[$_smarty_tpl->getVariable('smarty')->value['section']['t']['index']]['luser'];?>

							<?php } elseif ($_smarty_tpl->tpl_vars['allmember']->value[$_smarty_tpl->getVariable('smarty')->value['section']['t']['index']]['type'] == 12) {?>资源组:<?php echo $_smarty_tpl->tpl_vars['allmember']->value[$_smarty_tpl->getVariable('smarty')->value['section']['t']['index']]['lgroup'];?>

							<?php } elseif ($_smarty_tpl->tpl_vars['allmember']->value[$_smarty_tpl->getVariable('smarty')->value['section']['t']['index']]['type'] == 13) {?>设备：<?php echo $_smarty_tpl->tpl_vars['allmember']->value[$_smarty_tpl->getVariable('smarty')->value['section']['t']['index']]['resource'];?>
，设备用户：<?php echo $_smarty_tpl->tpl_vars['allmember']->value[$_smarty_tpl->getVariable('smarty')->value['section']['t']['index']]['resource_user'];?>

							<?php } elseif ($_smarty_tpl->tpl_vars['allmember']->value[$_smarty_tpl->getVariable('smarty')->value['section']['t']['index']]['type'] == 14) {?>设备：<?php echo $_smarty_tpl->tpl_vars['allmember']->value[$_smarty_tpl->getVariable('smarty')->value['section']['t']['index']]['resource'];?>

							<?php } elseif ($_smarty_tpl->tpl_vars['allmember']->value[$_smarty_tpl->getVariable('smarty')->value['section']['t']['index']]['type'] == 15) {?>日志类型:<?php echo $_smarty_tpl->tpl_vars['allmember']->value[$_smarty_tpl->getVariable('smarty')->value['section']['t']['index']]['resource'];?>

							
							<?php }?>
						</td>
						<td><?php echo $_smarty_tpl->tpl_vars['allmember']->value[$_smarty_tpl->getVariable('smarty')->value['section']['t']['index']]['result'];?>
</td>
						<td><?php echo $_smarty_tpl->tpl_vars['allmember']->value[$_smarty_tpl->getVariable('smarty')->value['section']['t']['index']]['optime'];?>
</td>
					</tr>
					<?php endfor; endif; ?>
					<tr>
						<td colspan="9" align="right">
							<?php echo $_smarty_tpl->tpl_vars['language']->value['all'];
echo $_smarty_tpl->tpl_vars['total']->value;?>
个<?php echo $_smarty_tpl->tpl_vars['language']->value['User'];?>
  <?php echo $_smarty_tpl->tpl_vars['page_list']->value;?>
  <?php echo $_smarty_tpl->tpl_vars['language']->value['Page'];?>
：<?php echo $_smarty_tpl->tpl_vars['curr_page']->value;?>
/<?php echo $_smarty_tpl->tpl_vars['total_page']->value;
echo $_smarty_tpl->tpl_vars['language']->value['page'];?>
  <?php echo $_smarty_tpl->tpl_vars['items_per_page']->value;?>
个<?php echo $_smarty_tpl->tpl_vars['language']->value['User'];?>
/<?php echo $_smarty_tpl->tpl_vars['language']->value['page'];?>
  <?php echo $_smarty_tpl->tpl_vars['language']->value['Goto'];?>
<input name="pagenum" type="text" class="wbk" size="2" onKeyPress="if(event.keyCode==13) window.location='admin.php?controller=admin_member&page='+this.value;"><?php echo $_smarty_tpl->tpl_vars['language']->value['page'];?>
  导出：<a href="<?php echo $_smarty_tpl->tpl_vars['curr_url']->value;?>
&derive=1" target="hide"><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/excel.png" border=0></a>  <a href="<?php echo $_smarty_tpl->tpl_vars['curr_url']->value;?>
&derive=2" ><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/html.png" border=0></a>  <a href="<?php echo $_smarty_tpl->tpl_vars['curr_url']->value;?>
&derive=3" ><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/word.png" border=0></a> <a href="<?php echo $_smarty_tpl->tpl_vars['curr_url']->value;?>
&derive=4" ><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/pdf.png" border=0></a> <?php if ($_smarty_tpl->tpl_vars['admin_level']->value == 1) {?><a href="<?php echo $_smarty_tpl->tpl_vars['curr_url']->value;?>
&delete=1"></a><?php }?>
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