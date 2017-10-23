<?php /* Smarty version 3.1.27, created on 2017-08-08 09:48:05
         compiled from "/opt/freesvr/web/htdocs/freesvr/audit/template/admin/passdown.tpl" */ ?>
<?php
/*%%SmartyHeaderCode:212805649559891855be4536_37400247%%*/
if(!defined('SMARTY_DIR')) exit('no direct access allowed');
$_valid = $_smarty_tpl->decodeProperties(array (
  'file_dependency' => 
  array (
    'fd3d6cb0514702c2a0149fe89062baeefeaba59f' => 
    array (
      0 => '/opt/freesvr/web/htdocs/freesvr/audit/template/admin/passdown.tpl',
      1 => 1474793220,
      2 => 'file',
    ),
  ),
  'nocache_hash' => '212805649559891855be4536_37400247',
  'variables' => 
  array (
    'title' => 0,
    'template_root' => 0,
    'language' => 0,
    'files' => 0,
    'total' => 0,
    'page_list' => 0,
    'curr_page' => 0,
    'total_page' => 0,
    'items_per_page' => 0,
  ),
  'has_nocache_code' => false,
  'version' => '3.1.27',
  'unifunc' => 'content_59891855c60c12_08984241',
),false);
/*/%%SmartyHeaderCode%%*/
if ($_valid && !is_callable('content_59891855c60c12_08984241')) {
function content_59891855c60c12_08984241 ($_smarty_tpl) {

$_smarty_tpl->properties['nocache_hash'] = '212805649559891855be4536_37400247';
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


	<table width="100%" border="0" cellspacing="0" cellpadding="0">
	 <tr><td valign="middle" class="hui_bj"><div class="menu">
<ul>
	<li class="me_b"><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an11.jpg" align="absmiddle"/><a href="admin.php?controller=admin_index&action=main">密码查看</a><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an33.jpg" align="absmiddle"/></li>
	<li class="me_b"><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an11.jpg" align="absmiddle"/><a href="admin.php?controller=admin_pro&action=passwordedit">修改密码</a><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an33.jpg" align="absmiddle"/></li>
	<li class="me_b"><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an11.jpg" align="absmiddle"/><a href="admin.php?controller=admin_pro&action=password_cron">定时任务</a><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an33.jpg" align="absmiddle"/></li>
	<li class="me_b"><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an11.jpg" align="absmiddle"/><a href="admin.php?controller=admin_backup&action=backup_setting_forpassword">自动备份</a><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an33.jpg" align="absmiddle"/></li>

	<li class="me_a"><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an1.jpg" align="absmiddle"/><a href="admin.php?controller=admin_index&action=passdown">密码文件下载</a><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an3.jpg" align="absmiddle"/></li>
	<li class="me_b"><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an11.jpg" align="absmiddle"/><a href="admin.php?controller=admin_pro&action=passwordcheck">密码校验</a><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an33.jpg" align="absmiddle"/></li>
</ul>
</div></td></tr>
  <tr>
	<td class=""><TABLE border=0 cellSpacing=1 cellPadding=5 
                                width="100%" bgColor=#ffffff valign="top" class="BBtable">
                <TBODY>
                  <TR>
					<th class="list_bg">选</td>
					<th class="list_bg" ><?php echo $_smarty_tpl->tpl_vars['language']->value['Password'];
echo $_smarty_tpl->tpl_vars['language']->value['File'];?>
</TD>
					<th class="list_bg" >产生<?php echo $_smarty_tpl->tpl_vars['language']->value['day'];?>
期</TD>
					<th class="list_bg" >大小</TD>
					<th class="list_bg" ><?php echo $_smarty_tpl->tpl_vars['language']->value['Operate'];?>
</TD>
                  </TR>

            </tr>
			<form name="member_list" action="admin.php?controller=admin_index&action=deletepassfile" method="post">
			<?php if (isset($_smarty_tpl->tpl_vars['smarty']->value['section']['f'])) unset($_smarty_tpl->tpl_vars['smarty']->value['section']['f']);
$_smarty_tpl->tpl_vars['smarty']->value['section']['f']['name'] = 'f';
$_smarty_tpl->tpl_vars['smarty']->value['section']['f']['loop'] = is_array($_loop=$_smarty_tpl->tpl_vars['files']->value) ? count($_loop) : max(0, (int) $_loop); unset($_loop);
$_smarty_tpl->tpl_vars['smarty']->value['section']['f']['show'] = true;
$_smarty_tpl->tpl_vars['smarty']->value['section']['f']['max'] = $_smarty_tpl->tpl_vars['smarty']->value['section']['f']['loop'];
$_smarty_tpl->tpl_vars['smarty']->value['section']['f']['step'] = 1;
$_smarty_tpl->tpl_vars['smarty']->value['section']['f']['start'] = $_smarty_tpl->tpl_vars['smarty']->value['section']['f']['step'] > 0 ? 0 : $_smarty_tpl->tpl_vars['smarty']->value['section']['f']['loop']-1;
if ($_smarty_tpl->tpl_vars['smarty']->value['section']['f']['show']) {
    $_smarty_tpl->tpl_vars['smarty']->value['section']['f']['total'] = $_smarty_tpl->tpl_vars['smarty']->value['section']['f']['loop'];
    if ($_smarty_tpl->tpl_vars['smarty']->value['section']['f']['total'] == 0)
        $_smarty_tpl->tpl_vars['smarty']->value['section']['f']['show'] = false;
} else
    $_smarty_tpl->tpl_vars['smarty']->value['section']['f']['total'] = 0;
if ($_smarty_tpl->tpl_vars['smarty']->value['section']['f']['show']):

            for ($_smarty_tpl->tpl_vars['smarty']->value['section']['f']['index'] = $_smarty_tpl->tpl_vars['smarty']->value['section']['f']['start'], $_smarty_tpl->tpl_vars['smarty']->value['section']['f']['iteration'] = 1;
                 $_smarty_tpl->tpl_vars['smarty']->value['section']['f']['iteration'] <= $_smarty_tpl->tpl_vars['smarty']->value['section']['f']['total'];
                 $_smarty_tpl->tpl_vars['smarty']->value['section']['f']['index'] += $_smarty_tpl->tpl_vars['smarty']->value['section']['f']['step'], $_smarty_tpl->tpl_vars['smarty']->value['section']['f']['iteration']++):
$_smarty_tpl->tpl_vars['smarty']->value['section']['f']['rownum'] = $_smarty_tpl->tpl_vars['smarty']->value['section']['f']['iteration'];
$_smarty_tpl->tpl_vars['smarty']->value['section']['f']['index_prev'] = $_smarty_tpl->tpl_vars['smarty']->value['section']['f']['index'] - $_smarty_tpl->tpl_vars['smarty']->value['section']['f']['step'];
$_smarty_tpl->tpl_vars['smarty']->value['section']['f']['index_next'] = $_smarty_tpl->tpl_vars['smarty']->value['section']['f']['index'] + $_smarty_tpl->tpl_vars['smarty']->value['section']['f']['step'];
$_smarty_tpl->tpl_vars['smarty']->value['section']['f']['first']      = ($_smarty_tpl->tpl_vars['smarty']->value['section']['f']['iteration'] == 1);
$_smarty_tpl->tpl_vars['smarty']->value['section']['f']['last']       = ($_smarty_tpl->tpl_vars['smarty']->value['section']['f']['iteration'] == $_smarty_tpl->tpl_vars['smarty']->value['section']['f']['total']);
?>
			<tr  <?php if ($_smarty_tpl->getVariable('smarty')->value['section']['t']['index']%2 == 0) {?>bgcolor="f7f7f7"<?php }?>>
				<td><input type="checkbox" name="chk_member[]" value="<?php echo $_smarty_tpl->tpl_vars['files']->value[$_smarty_tpl->getVariable('smarty')->value['section']['f']['index']]['name'];?>
"></td>
				 <td> <?php echo $_smarty_tpl->tpl_vars['files']->value[$_smarty_tpl->getVariable('smarty')->value['section']['f']['index']]['name'];?>
</td>
				<td><?php echo $_smarty_tpl->tpl_vars['files']->value[$_smarty_tpl->getVariable('smarty')->value['section']['f']['index']]['time'];?>
 </td>
				<td><?php echo $_smarty_tpl->tpl_vars['files']->value[$_smarty_tpl->getVariable('smarty')->value['section']['f']['index']]['size'];?>
</td>
				<td>									
				<img src='<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/edit_ico.gif' width=16 height='16' hspace='5' border='0' align='absmiddle'><a href='admin.php?controller=admin_index&action=dopassdown&name=<?php echo $_smarty_tpl->tpl_vars['files']->value[$_smarty_tpl->getVariable('smarty')->value['section']['f']['index']]['name'];?>
'><?php echo $_smarty_tpl->tpl_vars['language']->value['Download'];?>
</a> |
				&nbsp;<img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/scico.gif" width="16" height="16" align="absmiddle"><a href="admin.php?controller=admin_index&action=deletepassfile&filename=<?php echo $_smarty_tpl->tpl_vars['files']->value[$_smarty_tpl->getVariable('smarty')->value['section']['f']['index']]['name'];?>
"><?php echo $_smarty_tpl->tpl_vars['language']->value['Delete'];?>
</a>
				</td> 
			</tr>
			<?php endfor; endif; ?>
			<tr>
			<td colspan="2" align="left"><input name="select_all" type="checkbox" onClick="javascript:for(var i=0;i<this.form.elements.length;i++){var e=document.member_list.elements[i];if(e.name=='chk_member[]')e.checked=document.member_list.select_all.checked;}" value="checkbox">&nbsp;&nbsp;<input type="submit"  value="删除文件" onClick="my_confirm('确定要删除所选文件?');if(chk_form()) document.member_list.action='admin.php?controller=admin_index&action=deletepassfile'; else return false;" class="an_02"></td><td colspan="6" align="right">
					<?php echo $_smarty_tpl->tpl_vars['language']->value['all'];
echo $_smarty_tpl->tpl_vars['total']->value;
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
<input name="pagenum" type="text" size="2" onKeyPress="if(event.keyCode==13) window.location='admin.php?controller=admin_index&action=passdown&page='+this.value;"><?php echo $_smarty_tpl->tpl_vars['language']->value['page'];?>

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