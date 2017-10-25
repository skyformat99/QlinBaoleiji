<?php /* Smarty version 3.1.27, created on 2017-06-25 09:18:38
         compiled from "/opt/freesvr/web/htdocs/freesvr/audit/template/admin/adminlog_list.tpl" */ ?>
<?php
/*%%SmartyHeaderCode:1992973019594f0f6e63c101_74322396%%*/
if(!defined('SMARTY_DIR')) exit('no direct access allowed');
$_valid = $_smarty_tpl->decodeProperties(array (
  'file_dependency' => 
  array (
    'b6127e9198ccb132583f848013a66291dfb424ee' => 
    array (
      0 => '/opt/freesvr/web/htdocs/freesvr/audit/template/admin/adminlog_list.tpl',
      1 => 1474793217,
      2 => 'file',
    ),
  ),
  'nocache_hash' => '1992973019594f0f6e63c101_74322396',
  'variables' => 
  array (
    'language' => 0,
    'template_root' => 0,
    '_config' => 0,
    'f_rangeStart' => 0,
    'f_rangeEnd' => 0,
    'orderby2' => 0,
    'allmember' => 0,
    'total' => 0,
    'page_list' => 0,
    'curr_page' => 0,
    'total_page' => 0,
    'items_per_page' => 0,
  ),
  'has_nocache_code' => false,
  'version' => '3.1.27',
  'unifunc' => 'content_594f0f6e736dd3_34950729',
),false);
/*/%%SmartyHeaderCode%%*/
if ($_valid && !is_callable('content_594f0f6e736dd3_34950729')) {
function content_594f0f6e736dd3_34950729 ($_smarty_tpl) {

$_smarty_tpl->properties['nocache_hash'] = '1992973019594f0f6e63c101_74322396';
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
/cssjs/jscal2.css" />
<link type="text/css" rel="stylesheet" href="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/cssjs/border-radius.css" />
<?php echo '<script'; ?>
 src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/cssjs/jscal2.js"><?php echo '</script'; ?>
>
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
		var gid=0;
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
		<?php }?>
		document.search.action = "admin.php?controller=admin_log&action=adminlog";
		document.search.action += "&luser="+document.search.luser.value;
		document.search.action += "&lgroup="+gid;
		document.search.action += "&operation="+document.search.operation.value;
		document.search.action += "&operation="+document.search.operation.value;
		document.search.action += "&administrator="+document.search.administrator.value;
		document.search.action += "&resource_user="+document.search.resource_user.value;
		document.search.action += "&resource="+document.search.resource.value;
		document.search.action += "&start="+document.search.start.value;
		document.search.action += "&end="+document.search.end.value;
		document.search.submit();
		//alert(document.search.action);
		//return false;
		return true;
	}
<?php echo '</script'; ?>
>
<?php echo '<script'; ?>
 type="text/javascript">
<?php if ($_smarty_tpl->tpl_vars['_config']->value['LDAP']) {?>

<?php }?>
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
 
	<li class="me_a"><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an1.jpg" align="absmiddle"/><a href="admin.php?controller=admin_log&action=adminlog">系统操作</a><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an3.jpg" align="absmiddle"/></li>
	<li class="me_b"><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an11.jpg" align="absmiddle"/><a href="admin.php?controller=admin_log&action=downuploaded">批量导入</a><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an33.jpg" align="absmiddle"/></li>
</ul>
</div></td></tr>

	<table width="100%" border="0" cellspacing="0" cellpadding="0">
	  
	  
	  <tr>
		<td class="" >
		<table bordercolor="white" cellspacing="1" cellpadding="5" border="0" width="100%" >
			<tr><td>
			<form name ='search' action='admin.php?controller=admin_log&action=adminlog' method=post>
			<?php echo $_smarty_tpl->tpl_vars['language']->value['WebUser'];
echo $_smarty_tpl->tpl_vars['language']->value['User'];?>
：<input type="text" class="wbk" name="luser">&nbsp;&nbsp;<?php echo $_smarty_tpl->getSubTemplate ("select_sgroup_ajax.tpl", $_smarty_tpl->cache_id, $_smarty_tpl->compile_id, 0, $_smarty_tpl->cache_lifetime, array(), 0);
?>

			<?php echo $_smarty_tpl->tpl_vars['language']->value['Operate'];?>
：<input type="text" class="wbk" name="operation">
			<?php echo $_smarty_tpl->tpl_vars['language']->value['Administrator'];?>
：<input type="text" class="wbk" name="administrator">&nbsp;&nbsp;
			资源：<input type="text" class="wbk" name="resource">&nbsp;&nbsp;
			资源用户：<input type="text" class="wbk" name="resource_user">&nbsp;&nbsp;
			<?php echo $_smarty_tpl->tpl_vars['language']->value['Starttime'];?>
：<input type="text" class="wbk"  name="f_rangeStart" size="13" id="f_rangeStart" value="<?php echo $_smarty_tpl->tpl_vars['f_rangeStart']->value;?>
" />
 <input type="button" id="f_rangeStart_trigger" name="f_rangeStart_trigger" value="<?php echo $_smarty_tpl->tpl_vars['language']->value['Edittime'];?>
"  class="wbk">
 <?php echo $_smarty_tpl->tpl_vars['language']->value['Endtime'];?>
：
<input  type="text" class="wbk" name="f_rangeEnd" size="13" id="f_rangeEnd"  value="<?php echo $_smarty_tpl->tpl_vars['f_rangeEnd']->value;?>
" />
 <input type="button" id="f_rangeEnd_trigger" name="f_rangeEnd_trigger" value="<?php echo $_smarty_tpl->tpl_vars['language']->value['Edittime'];?>
"  class="wbk">&nbsp;&nbsp;
 <input type="submit" height="35" align="middle" onClick="return searchit();" border="0" value=" 确定 " class="bnnew2"/>
			</form>
			</td></tr>
	<tr>
		<td>	
			<table bordercolor="white" cellspacing="1" cellpadding="5" border="0" width="100%"  class="BBtable">
					<tr>
						<th class="list_bg"  width="5%"><?php echo $_smarty_tpl->tpl_vars['language']->value['select'];?>
</th>
						<th class="list_bg"  width="10%"><a href="admin.php?controller=admin_log&action=adminlog&orderby1=administrator&orderby2=<?php echo $_smarty_tpl->tpl_vars['orderby2']->value;?>
" ><?php echo $_smarty_tpl->tpl_vars['language']->value['Administrator'];?>
</a></th>
						<th class="list_bg"  width="15%"><a href="admin.php?controller=admin_log&action=adminlog&orderby1=action&orderby2=<?php echo $_smarty_tpl->tpl_vars['orderby2']->value;?>
" ><?php echo $_smarty_tpl->tpl_vars['language']->value['Operate'];?>
</a></th>
						<th class="list_bg"  width="50%"><a href="admin.php?controller=admin_log&action=admin_log&orderby1=resource&orderby2=<?php echo $_smarty_tpl->tpl_vars['orderby2']->value;?>
" >操作对象</a></th>
						<th class="list_bg"  width="5%"><a href="admin.php?controller=admin_log&action=admin_log&orderby1=result&orderby2=<?php echo $_smarty_tpl->tpl_vars['orderby2']->value;?>
" >结果</a></th>
						<th class="list_bg"  ><a href="admin.php?controller=admin_log&action=adminlog&orderby1=optime&orderby2=<?php echo $_smarty_tpl->tpl_vars['orderby2']->value;?>
" ><?php echo $_smarty_tpl->tpl_vars['language']->value['OperateTime'];?>
</a></th>
					</tr>
					<form name="member_list" action="admin.php?controller=admin_log&action=delete_adminlog" method="post">
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
						<td><input type="checkbox" name="chk_member[]" value="<?php echo $_smarty_tpl->tpl_vars['allmember']->value[$_smarty_tpl->getVariable('smarty')->value['section']['t']['index']]['id'];?>
"></td>
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
						<td colspan="3" align="left">
							<input name="select_all" type="checkbox" onclick="javascript:for(var i=0;i<this.form.elements.length;i++){var e=this.form.elements[i];if(e.name=='chk_member[]')e.checked=this.form.select_all.checked;}" value="checkbox"><?php echo $_smarty_tpl->tpl_vars['language']->value['select'];
echo $_smarty_tpl->tpl_vars['language']->value['this'];
echo $_smarty_tpl->tpl_vars['language']->value['page'];
echo $_smarty_tpl->tpl_vars['language']->value['displayed'];?>
的<?php echo $_smarty_tpl->tpl_vars['language']->value['All'];?>
&nbsp;&nbsp;<input type="submit"  value="批量删除所选记录" onclick="my_confirm('批量删除所选记录');if(chk_form()) document.member_list.action='admin.php?controller=admin_log&action=delete_adminlog'; else return false;" class="an_06">
						</td>
						<td colspan="4" align="right">
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

						</td>
					</tr>
					
					</form>
					
				</table>
			  </td>
			</tr>
		  </table>
		</td>
	  </tr>
	</table>
	
  <?php echo '<script'; ?>
 type="text/javascript">
var cal = Calendar.setup({
    onSelect: function(cal) { cal.hide() },
    showTime: true
});
cal.manageFields("f_rangeStart_trigger", "f_rangeStart", "%Y-%m-%d %H:%M:%S");
cal.manageFields("f_rangeEnd_trigger", "f_rangeEnd", "%Y-%m-%d %H:%M:%S");
//checkall('serverlist');
<?php echo '</script'; ?>
>
</body>
</html>


<?php }
}
?>