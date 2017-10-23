<?php /* Smarty version 3.1.27, created on 2017-07-10 08:23:46
         compiled from "/opt/freesvr/web/htdocs/freesvr/audit/template/admin/weektime.tpl" */ ?>
<?php
/*%%SmartyHeaderCode:5118225775962c912807ad7_05184998%%*/
if(!defined('SMARTY_DIR')) exit('no direct access allowed');
$_valid = $_smarty_tpl->decodeProperties(array (
  'file_dependency' => 
  array (
    'a6060648dc4dbfd1e10a44b15fc8178f944c9718' => 
    array (
      0 => '/opt/freesvr/web/htdocs/freesvr/audit/template/admin/weektime.tpl',
      1 => 1474793223,
      2 => 'file',
    ),
  ),
  'nocache_hash' => '5118225775962c912807ad7_05184998',
  'variables' => 
  array (
    'title' => 0,
    'template_root' => 0,
    'orderby2' => 0,
    'weektime' => 0,
    'total' => 0,
    'page_list' => 0,
    'curr_page' => 0,
    'total_page' => 0,
    'items_per_page' => 0,
  ),
  'has_nocache_code' => false,
  'version' => '3.1.27',
  'unifunc' => 'content_5962c9128bbda2_55186453',
),false);
/*/%%SmartyHeaderCode%%*/
if ($_valid && !is_callable('content_5962c9128bbda2_55186453')) {
function content_5962c9128bbda2_55186453 ($_smarty_tpl) {

$_smarty_tpl->properties['nocache_hash'] = '5118225775962c912807ad7_05184998';
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
<?php if ($_SESSION['ADMIN_LEVEL'] != 3 && $_SESSION['ADMIN_LEVEL'] != 21 && $_SESSION['ADMIN_LEVEL'] != 101) {?>
	<li class="me_b"><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an11.jpg" align="absmiddle"/><a href="admin.php?controller=admin_config&action=default_policy">默认策略</a><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an33.jpg" align="absmiddle"/></li>
	<?php }?>
    <li class="me_b"><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an11.jpg" align="absmiddle"/><a href="admin.php?controller=admin_pro&action=sourceip">来源IP组</a><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an33.jpg" align="absmiddle"/></li>
    <li class="me_a"><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an1.jpg" align="absmiddle"/><a href="admin.php?controller=admin_member&action=weektime">周组策略</a><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an3.jpg" align="absmiddle"/></li>
	<li class="me_b"><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an11.jpg" align="absmiddle"/><a href="admin.php?controller=admin_forbidden&action=forbidden_groups_list">命令权限</a><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an33.jpg" align="absmiddle"/></li>
	<?php if ($_SESSION['ADMIN_LEVEL'] != 3 && $_SESSION['ADMIN_LEVEL'] != 21 && $_SESSION['ADMIN_LEVEL'] != 101) {?>
	<li class="me_b"><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an11.jpg" align="absmiddle"/><a href="admin.php?controller=admin_config&action=autochange_pwd">自动改密</a><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an33.jpg" align="absmiddle"/></li>
	<li class="me_b"><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an11.jpg" align="absmiddle"/><a href="admin.php?controller=admin_forbidden&action=cmdgroup_list">命令组</a><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an33.jpg" align="absmiddle"/></li>
	<?php }?>
	<?php if ($_SESSION['ADMIN_LEVEL'] != 3 && $_SESSION['ADMIN_LEVEL'] != 21 && $_SESSION['ADMIN_LEVEL'] != 101) {?>
	<li class="me_b"><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an11.jpg" align="absmiddle"/><a href="admin.php?controller=admin_ipacl">授权策略</a><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an33.jpg" align="absmiddle"/></li>
	<?php }?>
	<li class="me_b"><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an11.jpg" align="absmiddle"/><a href="admin.php?controller=admin_workflow&action=workflow_contant">申请描述</a><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an33.jpg" align="absmiddle"/></li>
	<?php if ($_SESSION['LICENSE_KEY_NETMANAGER'] && $_SESSION['CACTI_CONFIG_ON']) {?>
	<li class="me_b"><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an11.jpg" align="absmiddle"/><a href="admin.php?controller=admin_index&action=documentlist">文档上传</a><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an33.jpg" align="absmiddle"/></li>
	<?php }?>
</ul>
</div></td></tr>
	
 
  <tr>
	<td class="">
	<table width="100%" border="0" cellspacing="0" cellpadding="0" class="BBtable">
                <TBODY>
				   
                  <TR>
                    <th class="list_bg" ><a href="admin.php?controller=admin_member&action=weektime&orderby1=policyname&orderby2=<?php echo $_smarty_tpl->tpl_vars['orderby2']->value;?>
" >策略名</a></TD>
                    <th class="list_bg" ><a href="admin.php?controller=admin_member&action=weektime&orderby1=start_time1&orderby2=<?php echo $_smarty_tpl->tpl_vars['orderby2']->value;?>
" >星期一</a></TD>
                    <th class="list_bg" ><a href="admin.php?controller=admin_member&action=weektime&orderby1=start_time2&orderby2=<?php echo $_smarty_tpl->tpl_vars['orderby2']->value;?>
" >星期二</a></TD>
                    <th class="list_bg" ><a href="admin.php?controller=admin_member&action=weektime&orderby1=start_time3&orderby2=<?php echo $_smarty_tpl->tpl_vars['orderby2']->value;?>
" >星期三</a></TD>
                    <th class="list_bg" ><a href="admin.php?controller=admin_member&action=weektime&orderby1=start_time4&orderby2=<?php echo $_smarty_tpl->tpl_vars['orderby2']->value;?>
" >星期四</a></TD>
                    <th class="list_bg" ><a href="admin.php?controller=admin_member&action=weektime&orderby1=start_time5&orderby2=<?php echo $_smarty_tpl->tpl_vars['orderby2']->value;?>
" >星期五</a></TD>
                    <th class="list_bg" ><a href="admin.php?controller=admin_member&action=weektime&orderby1=start_time6&orderby2=<?php echo $_smarty_tpl->tpl_vars['orderby2']->value;?>
" >星期六</a></TD>
                    <th class="list_bg" ><a href="admin.php?controller=admin_member&action=weektime&orderby1=start_time7&orderby2=<?php echo $_smarty_tpl->tpl_vars['orderby2']->value;?>
" >星期日</a></TD>
					<th class="list_bg" >操作</TD>
                  </TR>

            </tr>
			<?php if (isset($_smarty_tpl->tpl_vars['smarty']->value['section']['t'])) unset($_smarty_tpl->tpl_vars['smarty']->value['section']['t']);
$_smarty_tpl->tpl_vars['smarty']->value['section']['t']['name'] = 't';
$_smarty_tpl->tpl_vars['smarty']->value['section']['t']['loop'] = is_array($_loop=$_smarty_tpl->tpl_vars['weektime']->value) ? count($_loop) : max(0, (int) $_loop); unset($_loop);
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
				<td ><?php echo $_smarty_tpl->tpl_vars['weektime']->value[$_smarty_tpl->getVariable('smarty')->value['section']['t']['index']]['policyname'];?>
</td>
				<td ><?php echo $_smarty_tpl->tpl_vars['weektime']->value[$_smarty_tpl->getVariable('smarty')->value['section']['t']['index']]['start_time1'];?>
-<?php echo $_smarty_tpl->tpl_vars['weektime']->value[$_smarty_tpl->getVariable('smarty')->value['section']['t']['index']]['end_time1'];?>
</td>
				<td ><?php echo $_smarty_tpl->tpl_vars['weektime']->value[$_smarty_tpl->getVariable('smarty')->value['section']['t']['index']]['start_time2'];?>
-<?php echo $_smarty_tpl->tpl_vars['weektime']->value[$_smarty_tpl->getVariable('smarty')->value['section']['t']['index']]['end_time2'];?>
</td>
				<td ><?php echo $_smarty_tpl->tpl_vars['weektime']->value[$_smarty_tpl->getVariable('smarty')->value['section']['t']['index']]['start_time3'];?>
-<?php echo $_smarty_tpl->tpl_vars['weektime']->value[$_smarty_tpl->getVariable('smarty')->value['section']['t']['index']]['end_time3'];?>
</td>
				<td ><?php echo $_smarty_tpl->tpl_vars['weektime']->value[$_smarty_tpl->getVariable('smarty')->value['section']['t']['index']]['start_time4'];?>
-<?php echo $_smarty_tpl->tpl_vars['weektime']->value[$_smarty_tpl->getVariable('smarty')->value['section']['t']['index']]['end_time4'];?>
</td>
				<td ><?php echo $_smarty_tpl->tpl_vars['weektime']->value[$_smarty_tpl->getVariable('smarty')->value['section']['t']['index']]['start_time5'];?>
-<?php echo $_smarty_tpl->tpl_vars['weektime']->value[$_smarty_tpl->getVariable('smarty')->value['section']['t']['index']]['end_time5'];?>
</td>
				<td ><?php echo $_smarty_tpl->tpl_vars['weektime']->value[$_smarty_tpl->getVariable('smarty')->value['section']['t']['index']]['start_time6'];?>
-<?php echo $_smarty_tpl->tpl_vars['weektime']->value[$_smarty_tpl->getVariable('smarty')->value['section']['t']['index']]['end_time6'];?>
</td>
				<td ><?php echo $_smarty_tpl->tpl_vars['weektime']->value[$_smarty_tpl->getVariable('smarty')->value['section']['t']['index']]['start_time7'];?>
-<?php echo $_smarty_tpl->tpl_vars['weektime']->value[$_smarty_tpl->getVariable('smarty')->value['section']['t']['index']]['end_time7'];?>
</td>		
				<td >
				<img src='<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/edit_ico.gif' width=16 height='16' hspace='5' border='0' align='absmiddle'><a href="admin.php?controller=admin_member&action=weektime_edit&sid=<?php echo $_smarty_tpl->tpl_vars['weektime']->value[$_smarty_tpl->getVariable('smarty')->value['section']['t']['index']]['sid'];?>
" >修改</a>
				| <img src='<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/delete_ico.gif' width=16 height='16' hspace='5' border='0' align='absmiddle'><a href="#" onClick="if(!confirm('您确定要删除？')) {return false;} else { location.href='admin.php?controller=admin_member&action=delete_weektime&sid=<?php echo $_smarty_tpl->tpl_vars['weektime']->value[$_smarty_tpl->getVariable('smarty')->value['section']['t']['index']]['sid'];?>
';}">删除</a>
				</td> 
			</tr>
			<?php endfor; endif; ?>
	           <tr>
						<td colspan="2" align="left">
							<input type="button"  value=" 增加 " onclick="javascript:document.location='admin.php?controller=admin_member&action=weektime_edit';" class="an_02">
						</td>
						<td  colspan="7" align="right">
		   			共<?php echo $_smarty_tpl->tpl_vars['total']->value;?>
个记录  <?php echo $_smarty_tpl->tpl_vars['page_list']->value;?>
  页次：<?php echo $_smarty_tpl->tpl_vars['curr_page']->value;?>
/<?php echo $_smarty_tpl->tpl_vars['total_page']->value;?>
页  <?php echo $_smarty_tpl->tpl_vars['items_per_page']->value;?>
个记录/页  转到第<input name="pagenum" type="text" class="wbk" size="2" onKeyPress="if(event.keyCode==13) window.location='admin.php?controller=admin_pro&action=dev_group_index&page='+this.value;">页
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