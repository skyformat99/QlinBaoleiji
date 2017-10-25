<?php /* Smarty version 3.1.27, created on 2017-06-25 06:44:55
         compiled from "/opt/freesvr/web/htdocs/freesvr/audit/template/admin/notice.tpl" */ ?>
<?php
/*%%SmartyHeaderCode:1525543935594eeb6711f370_31303624%%*/
if(!defined('SMARTY_DIR')) exit('no direct access allowed');
$_valid = $_smarty_tpl->decodeProperties(array (
  'file_dependency' => 
  array (
    'c80a7094e7c5afebbcfbf42791bcf40d323e660e' => 
    array (
      0 => '/opt/freesvr/web/htdocs/freesvr/audit/template/admin/notice.tpl',
      1 => 1496889844,
      2 => 'file',
    ),
  ),
  'nocache_hash' => '1525543935594eeb6711f370_31303624',
  'variables' => 
  array (
    'title' => 0,
    'template_root' => 0,
    'language' => 0,
    'notices' => 0,
    'total' => 0,
    'page_list' => 0,
    'curr_page' => 0,
    'total_page' => 0,
    'items_per_page' => 0,
    'serverid' => 0,
  ),
  'has_nocache_code' => false,
  'version' => '3.1.27',
  'unifunc' => 'content_594eeb671c80b3_87022505',
),false);
/*/%%SmartyHeaderCode%%*/
if ($_valid && !is_callable('content_594eeb671c80b3_87022505')) {
function content_594eeb671c80b3_87022505 ($_smarty_tpl) {
if (!is_callable('smarty_modifier_truncate_cn')) require_once '/opt/freesvr/web/htdocs/freesvr/audit/smarty/plugins/modifier.truncate_cn.php';

$_smarty_tpl->properties['nocache_hash'] = '1525543935594eeb6711f370_31303624';
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

	function batchloginlock(){
		document.member_list.action = "admin.php?controller=admin_pro&action=devbatchloginlock";
		document.member_list.submit();
		return true;
	}
<?php echo '</script'; ?>
>
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

<body>


	<table width="100%" border="0" cellspacing="0" cellpadding="0">
  <tr><td valign="middle" class="hui_bj"><div class="menu">
<ul>
<li class="me_b"><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an11.jpg" align="absmiddle"/><a href="admin.php?controller=admin_eth&action=serverstatus">服务状态</a><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an33.jpg" align="absmiddle"/></li>
	<li class="me_b"><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an11.jpg" align="absmiddle"/><a href="admin.php?controller=admin_status&action=latest">系统状态</a><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an33.jpg" align="absmiddle"/></li>
	<li class="me_b"><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an11.jpg" align="absmiddle"/><a href="admin.php?controller=admin_config&action=ha">双机配置</a><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an33.jpg" align="absmiddle"/></li>
	<li class="me_b"><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an11.jpg" align="absmiddle"/><a href="admin.php?controller=admin_backup">配置备份</a><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an33.jpg" align="absmiddle"/></li>
	<li class="me_b"><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an11.jpg" align="absmiddle"/><a href="admin.php?controller=admin_backup&action=backup_setting">数据同步</a><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an33.jpg" align="absmiddle"/></li>
	<li class="me_b"><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an11.jpg" align="absmiddle"/><a href="admin.php?controller=admin_backup&action=upgrade">软件升级</a><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an33.jpg" align="absmiddle"/></li>
	<li class="me_b"><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an11.jpg" align="absmiddle"/><a href="admin.php?controller=admin_backup&action=cronjob">定时任务</a><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an33.jpg" align="absmiddle"/></li>
	<li class="me_b"><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an11.jpg" align="absmiddle"/><a href="admin.php?controller=admin_index&action=changelogo">图标上传</a><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an33.jpg" align="absmiddle"/></li>
	<li class="me_a"><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an1.jpg" align="absmiddle"/><a href="admin.php?controller=admin_config&action=notice">系统通知</a><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an3.jpg" align="absmiddle"/></li>
</ul>
</div></td></tr>
  <tr>
	<td class=""><table width="100%" border="0" cellspacing="0" cellpadding="0"  class="BBtable">
                <TBODY>
		   		  <form name="member_list" action="admin.php?controller=admin_config&action=notice_del" method="post" >
		   
                  <TR>
                  <th class="list_bg"  width="1%"><?php echo $_smarty_tpl->tpl_vars['language']->value['select'];?>
</th>
                    <th class="list_bg" width="20%">广播内容</TD>
                    <th class="list_bg" width="6%">是否关闭</TD>
                    <th class="list_bg" width="10%">过期时间</TD>
                    <th class="list_bg"width="9%">是否全部用户</TD>
					<th class="list_bg" width="20%">广播组</TD>
                    <th class="list_bg" width="20%">广播用户</TD>
					<th class="list_bg" width="15%"><?php echo $_smarty_tpl->tpl_vars['language']->value['Operate'];?>
</TD>
                  </TR>

            </tr>
			<?php if (isset($_smarty_tpl->tpl_vars['smarty']->value['section']['t'])) unset($_smarty_tpl->tpl_vars['smarty']->value['section']['t']);
$_smarty_tpl->tpl_vars['smarty']->value['section']['t']['name'] = 't';
$_smarty_tpl->tpl_vars['smarty']->value['section']['t']['loop'] = is_array($_loop=$_smarty_tpl->tpl_vars['notices']->value) ? count($_loop) : max(0, (int) $_loop); unset($_loop);
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
			<tr>
			<td><input type="checkbox" name="chk_member[]" value="<?php echo $_smarty_tpl->tpl_vars['notices']->value[$_smarty_tpl->getVariable('smarty')->value['section']['t']['index']]['id'];?>
"></td>
				<td title="<?php echo $_smarty_tpl->tpl_vars['notices']->value[$_smarty_tpl->getVariable('smarty')->value['section']['t']['index']]['content'];?>
"><?php echo smarty_modifier_truncate_cn($_smarty_tpl->tpl_vars['notices']->value[$_smarty_tpl->getVariable('smarty')->value['section']['t']['index']]['content'],"20","...");?>
</td>
				<td><?php if ($_smarty_tpl->tpl_vars['notices']->value[$_smarty_tpl->getVariable('smarty')->value['section']['t']['index']]['enable']) {?>是<?php } else { ?>否<?php }?></td>
				<td><?php echo $_smarty_tpl->tpl_vars['notices']->value[$_smarty_tpl->getVariable('smarty')->value['section']['t']['index']]['expiretime'];?>
</td>
				<td><?php if ($_smarty_tpl->tpl_vars['notices']->value[$_smarty_tpl->getVariable('smarty')->value['section']['t']['index']]['all']) {?>是<?php } else { ?>否<?php }?></td>		
				<td title="<?php echo $_smarty_tpl->tpl_vars['notices']->value[$_smarty_tpl->getVariable('smarty')->value['section']['t']['index']]['gname'];?>
"><?php if ($_smarty_tpl->tpl_vars['notices']->value[$_smarty_tpl->getVariable('smarty')->value['section']['t']['index']]['all']) {?>所有组<?php } else {
echo smarty_modifier_truncate_cn($_smarty_tpl->tpl_vars['notices']->value[$_smarty_tpl->getVariable('smarty')->value['section']['t']['index']]['gname'],"20","...");
}?></td>	
				<td title="<?php echo $_smarty_tpl->tpl_vars['notices']->value[$_smarty_tpl->getVariable('smarty')->value['section']['t']['index']]['uname'];?>
"><?php if ($_smarty_tpl->tpl_vars['notices']->value[$_smarty_tpl->getVariable('smarty')->value['section']['t']['index']]['all']) {?>所有用户<?php } else {
echo smarty_modifier_truncate_cn($_smarty_tpl->tpl_vars['notices']->value[$_smarty_tpl->getVariable('smarty')->value['section']['t']['index']]['uname'],"20","...");
}?></td>
				<td>
				<?php if ($_SESSION['ADMIN_LEVEL'] == 1 || $_SESSION['ADMIN_LEVEL'] == 3 || $_SESSION['ADMIN_LEVEL'] == 4) {?>
				<img src='<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/edit_ico.gif' width=16 height='16' hspace='5' border='0' align='absmiddle'><a href='admin.php?controller=admin_config&action=notice_edit&id=<?php echo $_smarty_tpl->tpl_vars['notices']->value[$_smarty_tpl->getVariable('smarty')->value['section']['t']['index']]['id'];?>
'><?php echo $_smarty_tpl->tpl_vars['language']->value['Edit'];?>
</a>

				<img src='<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/delete_ico.gif' width=16 height='16' hspace='5' border='0' align='absmiddle'><a href="#" onClick="if(!confirm('<?php echo $_smarty_tpl->tpl_vars['language']->value['Delete_sure_'];?>
？')) {return false;} else { location.href='admin.php?controller=admin_config&action=notice_del&id=<?php echo $_smarty_tpl->tpl_vars['notices']->value[$_smarty_tpl->getVariable('smarty')->value['section']['t']['index']]['id'];?>
';}"><?php echo $_smarty_tpl->tpl_vars['language']->value['Delete'];?>
</a>
				<?php }?>
				</td> 
			</tr>
			<?php endfor; endif; ?>
			<tr>
	           <td  colspan="5" align="left">
				<input name="select_all" type="checkbox" onclick="javascript:for(var i=0;i<this.form.elements.length;i++){var e=this.form.elements[i];if(e.name=='chk_member[]')e.checked=this.form.select_all.checked;}" value="checkbox">&nbsp;&nbsp;<input type="submit"  value="删除" onclick="return my_confirm('确定删除');" class="an_02">
		   &nbsp;<input type="button"  value="添加" onClick="location.href='admin.php?controller=admin_config&action=notice_edit'"  class="an_06">&nbsp;&nbsp;
		   </td><td colspan="5">
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
<input name="pagenum" type="text" class="wbk" size="2" onKeyPress="if(event.keyCode==13) window.location='admin.php?controller=admin_pro&action=dev_index&serverid=<?php echo $_smarty_tpl->tpl_vars['serverid']->value;?>
&page='+this.value;"><?php echo $_smarty_tpl->tpl_vars['language']->value['page'];?>

		   </td>
		</tr>
		</form>
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