<?php /* Smarty version 3.1.27, created on 2017-06-25 06:44:22
         compiled from "/opt/freesvr/web/htdocs/freesvr/audit/template/admin/backup_setting.tpl" */ ?>
<?php
/*%%SmartyHeaderCode:138879120594eeb46e242f0_93710680%%*/
if(!defined('SMARTY_DIR')) exit('no direct access allowed');
$_valid = $_smarty_tpl->decodeProperties(array (
  'file_dependency' => 
  array (
    '93ab3b18ec5fb6469df3406f1ae6359abf56b7b9' => 
    array (
      0 => '/opt/freesvr/web/htdocs/freesvr/audit/template/admin/backup_setting.tpl',
      1 => 1496889845,
      2 => 'file',
    ),
  ),
  'nocache_hash' => '138879120594eeb46e242f0_93710680',
  'variables' => 
  array (
    'title' => 0,
    'template_root' => 0,
    'session_flag' => 0,
    'ip' => 0,
    'orderby2' => 0,
    'alldev' => 0,
    'language' => 0,
    'total' => 0,
    'page_list' => 0,
    'curr_page' => 0,
    'total_page' => 0,
    'items_per_page' => 0,
    'curr_url' => 0,
  ),
  'has_nocache_code' => false,
  'version' => '3.1.27',
  'unifunc' => 'content_594eeb46eb4225_90920362',
),false);
/*/%%SmartyHeaderCode%%*/
if ($_valid && !is_callable('content_594eeb46eb4225_90920362')) {
function content_594eeb46eb4225_90920362 ($_smarty_tpl) {

$_smarty_tpl->properties['nocache_hash'] = '138879120594eeb46e242f0_93710680';
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
<?php echo '<script'; ?>
>
function searchit(){
	document.f1.action = "admin.php?controller=admin_backup&action=backup_setting";
	document.f1.action += "&ip="+document.f1.ip.value;
	document.f1.action += "&session_flag="+document.f1.session_flag.value;
	return true;
}
<?php echo '</script'; ?>
>
<td width="84%" align="left" valign="top"><table width="100%" border="0" cellspacing="0" cellpadding="0"><tr><td valign="middle" class="hui_bj"><div class="menu">
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
	<li class="me_a"><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an1.jpg" align="absmiddle"/><a href="admin.php?controller=admin_backup&action=backup_setting">数据同步</a><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an3.jpg" align="absmiddle"/></li>
	<li class="me_b"><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an11.jpg" align="absmiddle"/><a href="admin.php?controller=admin_backup&action=upgrade">软件升级</a><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an33.jpg" align="absmiddle"/></li>
	<li class="me_b"><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an11.jpg" align="absmiddle"/><a href="admin.php?controller=admin_backup&action=cronjob">定时任务</a><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an33.jpg" align="absmiddle"/></li>
	<li class="me_b"><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an11.jpg" align="absmiddle"/><a href="admin.php?controller=admin_index&action=changelogo">图标上传</a><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an33.jpg" align="absmiddle"/></li>
	<li class="me_b"><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an11.jpg" align="absmiddle"/><a href="admin.php?controller=admin_config&action=notice">系统通知</a><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an33.jpg" align="absmiddle"/></li>
</ul>
</div></td></tr>

  <tr>
	<td class="" colspan = "7"><table width="100%" border="0" cellspacing="0" cellpadding="0"  class="main_content">

                <TBODY>
				 <TR>
                    <TD >
					<form name ='f1' action='admin.php?controller=admin_backup&action=backup_setting' method=post>
					类型<select  class="wbk"  name="session_flag">
						<option value="" >请选择</option>
						<option value="0" <?php if ($_smarty_tpl->tpl_vars['session_flag']->value == '0') {?>selected<?php }?>>审计日志</option>
						<option value="100" <?php if ($_smarty_tpl->tpl_vars['session_flag']->value == '100') {?>selected<?php }?>>资产权限</option>
						<option value="1" <?php if ($_smarty_tpl->tpl_vars['session_flag']->value == '1') {?>selected<?php }?>>主从数据</option>
						<option value="2" <?php if ($_smarty_tpl->tpl_vars['session_flag']->value == '2') {?>selected<?php }?>>密码文件</option>
					</select>&nbsp;&nbsp;
					IP<input type="text" class="wbk" name="ip" value="<?php echo $_smarty_tpl->tpl_vars['ip']->value;?>
">
					&nbsp;&nbsp;<input  type="submit" value="高级搜索" onclick="return searchit();" class="bnnew2">
					</form>
					</TD>
                  </TR>
				  </table></td></tr>
                  <TR><td>
				  <table bordercolor="white" cellspacing="0" cellpadding="5" border="0" width="100%" class="BBtable">
				  <tr>
				  <th class="list_bg" >&nbsp;</th>
                    <th class="list_bg" ><a href = "admin.php?controller=admin_backup&action=backup_setting&orderby1=desc&orderby2=<?php echo $_smarty_tpl->tpl_vars['orderby2']->value;?>
">描述</a></th>
                    <th class="list_bg" ><a href = "admin.php?controller=admin_backup&action=backup_setting&orderby1=session_flag&orderby2=<?php echo $_smarty_tpl->tpl_vars['orderby2']->value;?>
">同步类型</a></th>
                    <th class="list_bg" ><a href = "admin.php?controller=admin_backup&action=backup_setting&orderby1=ip&orderby2=<?php echo $_smarty_tpl->tpl_vars['orderby2']->value;?>
">同步地址</a></th>
                    <th class="list_bg" ><a href = "admin.php?controller=admin_backup&action=backup_setting&orderby1=port&orderby2=<?php echo $_smarty_tpl->tpl_vars['orderby2']->value;?>
">同步端口</a></th>
                    <th class="list_bg" ><a href = "admin.php?controller=admin_backup&action=backup_setting&orderby1=protocol&orderby2=<?php echo $_smarty_tpl->tpl_vars['orderby2']->value;?>
">同步协议</a></th>
					<th class="list_bg" >操作</TD>
                  </TR>

            </tr>
			<form name="member_list" action="admin.php?controller=admin_backup&action=backup_setting_del" method="post">
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
			<tr  <?php if ($_smarty_tpl->getVariable('smarty')->value['section']['t']['index']%2 == 0) {?>bgcolor="f7f7f7"<?php }?>>
				<td><input type="checkbox" name="chk_member[]" value="<?php echo $_smarty_tpl->tpl_vars['alldev']->value[$_smarty_tpl->getVariable('smarty')->value['section']['t']['index']]['seq'];?>
"></td>
				<td><?php echo $_smarty_tpl->tpl_vars['alldev']->value[$_smarty_tpl->getVariable('smarty')->value['section']['t']['index']]['desc'];?>
</td>
				<td><?php if ($_smarty_tpl->tpl_vars['alldev']->value[$_smarty_tpl->getVariable('smarty')->value['section']['t']['index']]['session_flag'] == '100') {?>资产权限<?php } elseif ($_smarty_tpl->tpl_vars['alldev']->value[$_smarty_tpl->getVariable('smarty')->value['section']['t']['index']]['session_flag'] == '1') {?>主从数据<?php } elseif ($_smarty_tpl->tpl_vars['alldev']->value[$_smarty_tpl->getVariable('smarty')->value['section']['t']['index']]['session_flag'] == '2') {?>密码文件<?php } else { ?>审计日志<?php }?> </td>
				<td><?php echo $_smarty_tpl->tpl_vars['alldev']->value[$_smarty_tpl->getVariable('smarty')->value['section']['t']['index']]['ip'];?>
</td>
				<td><span  title="<?php echo $_smarty_tpl->tpl_vars['alldev']->value[$_smarty_tpl->getVariable('smarty')->value['section']['t']['index']]['port'];?>
" ><?php echo $_smarty_tpl->tpl_vars['alldev']->value[$_smarty_tpl->getVariable('smarty')->value['section']['t']['index']]['port'];?>
</span></td>
				<td><?php echo $_smarty_tpl->tpl_vars['alldev']->value[$_smarty_tpl->getVariable('smarty')->value['section']['t']['index']]['protocol'];?>
</td>
				<td>				
					<img src='<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/edit_ico.gif' width=16 height='16' hspace='5' border='0' align='absmiddle'><a href='admin.php?controller=admin_backup&action=backup_setting_edit&id=<?php echo $_smarty_tpl->tpl_vars['alldev']->value[$_smarty_tpl->getVariable('smarty')->value['section']['t']['index']]['seq'];?>
'>修改</a>
					 | <img src='<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/delete_ico.gif' width=16 height='16' hspace='5' border='0' align='absmiddle'><a href="#" onClick="if(!confirm('您确定要删除？')) {return false;} else { location.href='admin.php?controller=admin_backup&action=backup_setting_del&id=<?php echo $_smarty_tpl->tpl_vars['alldev']->value[$_smarty_tpl->getVariable('smarty')->value['section']['t']['index']]['seq'];?>
';}">删除</a>
				</td> 
			</tr>
			<?php endfor; endif; ?>
			
                <tr>
	           <td  colspan="3" align="left">
				<input name="select_all" type="checkbox" onClick="javascript:for(var i=0;i<this.form.elements.length;i++){var e=this.form.elements[i];if(e.name=='chk_member[]')e.checked=this.form.select_all.checked;}" value="checkbox">&nbsp;&nbsp;<input type="submit"  value="删除" onClick="my_confirm('确定删除所选?');if(chk_form()) document.member_list.action='admin.php?controller=admin_member&action=delete_all'; else return false;" class="an_02">&nbsp;&nbsp;<input type="button"  value="<?php echo $_smarty_tpl->tpl_vars['language']->value['Add'];?>
" onClick="javascript:document.location='admin.php?controller=admin_backup&action=backup_setting_edit';" class="an_02">&nbsp;&nbsp;
		   </td>

		    <td  colspan="4" align="right">
		   			&nbsp&nbsp;&nbsp;共<?php echo $_smarty_tpl->tpl_vars['total']->value;?>
个记录  <?php echo $_smarty_tpl->tpl_vars['page_list']->value;?>
  页次：<?php echo $_smarty_tpl->tpl_vars['curr_page']->value;?>
/<?php echo $_smarty_tpl->tpl_vars['total_page']->value;?>
页  <?php echo $_smarty_tpl->tpl_vars['items_per_page']->value;?>
个记录/页  转到第<input name="pagenum" type="text" class="wbk" size="2" onKeyPress="if(event.keyCode==13) window.location='admin.php?controller=admin_backup&action=backup_setting&page='+this.value;">页&nbsp;&nbsp;&nbsp;<?php if ($_SESSION['ADMIN_LEVEL'] == 3) {?>  导出：<a href="<?php echo $_smarty_tpl->tpl_vars['curr_url']->value;?>
&derive=1" target="hide"><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/excel.png" border=0></a><?php }?>
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