<?php /* Smarty version 3.1.27, created on 2017-08-08 09:48:04
         compiled from "/opt/freesvr/web/htdocs/freesvr/audit/template/admin/passwordcheck.tpl" */ ?>
<?php
/*%%SmartyHeaderCode:78041285459891854198211_08557358%%*/
if(!defined('SMARTY_DIR')) exit('no direct access allowed');
$_valid = $_smarty_tpl->decodeProperties(array (
  'file_dependency' => 
  array (
    'cc59352510bcb9233e37f68c5c66552ae6663772' => 
    array (
      0 => '/opt/freesvr/web/htdocs/freesvr/audit/template/admin/passwordcheck.tpl',
      1 => 1474793216,
      2 => 'file',
    ),
  ),
  'nocache_hash' => '78041285459891854198211_08557358',
  'variables' => 
  array (
    'title' => 0,
    'template_root' => 0,
    'language' => 0,
    'orderby2' => 0,
    'alllog' => 0,
    'total' => 0,
    'page_list' => 0,
    'curr_page' => 0,
    'total_page' => 0,
    'items_per_page' => 0,
  ),
  'has_nocache_code' => false,
  'version' => '3.1.27',
  'unifunc' => 'content_598918542214c7_23818498',
),false);
/*/%%SmartyHeaderCode%%*/
if ($_valid && !is_callable('content_598918542214c7_23818498')) {
function content_598918542214c7_23818498 ($_smarty_tpl) {

$_smarty_tpl->properties['nocache_hash'] = '78041285459891854198211_08557358';
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
 type="text/javascript">
function searchit(){
	document.f1.submit();	
	return true;
}
<?php echo '</script'; ?>
>
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

	<li class="me_b"><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an11.jpg" align="absmiddle"/><a href="admin.php?controller=admin_index&action=passdown">密码文件下载</a><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an33.jpg" align="absmiddle"/></li>
	<li class="me_a"><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an1.jpg" align="absmiddle"/><a href="admin.php?controller=admin_pro&action=passwordcheck">密码校验</a><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an3.jpg" align="absmiddle"/></li>
</ul>
</div></td></tr>
   <TR>
                    <TD colspan = "7">
					<form name ='f1' action='admin.php?controller=admin_pro&action=passwordcheck' method=post>
					IP<input type="text" class="wbk" name="ip">
					<?php echo $_smarty_tpl->tpl_vars['language']->value['LocalUsername'];?>
<input type="text" class="wbk" name="username">
					检验结果：<select  class="wbk"  name="passwordtry" ><option value=""><?php echo $_smarty_tpl->tpl_vars['language']->value['Pleaseselect'];?>
</option><option value="0">登录<?php echo $_smarty_tpl->tpl_vars['language']->value['Secuess'];?>
</option><option value="1"><?php echo $_smarty_tpl->tpl_vars['language']->value['passwordincorrect'];?>
</option><option value="2"><?php echo $_smarty_tpl->tpl_vars['language']->value['cannotjoin'];?>
</option></select>
					&nbsp;&nbsp;<input type="submit" height="35" align="middle" onClick="return searchit();" border="0" value=" 确定 " class="bnnew2"/>
					</form>
					</TD>
                  </TR>
  <tr>
  
	<td class=""><table width="100%" border="0" cellspacing="0" cellpadding="0" class="BBtable">
                <TBODY>
                  <TR>
                    <th class="list_bg" ><a href="admin.php?controller=admin_pro&action=passwordcheck&orderby1=device_ip&orderby2=<?php echo $_smarty_tpl->tpl_vars['orderby2']->value;?>
" ><?php echo $_smarty_tpl->tpl_vars['language']->value['IPAddress'];?>
</a></TD>
                    <th class="list_bg" ><a href="admin.php?controller=admin_pro&action=passwordcheck&orderby1=login_method&orderby2=<?php echo $_smarty_tpl->tpl_vars['orderby2']->value;?>
" ><?php echo $_smarty_tpl->tpl_vars['language']->value['Loginmode'];?>
</a></TD>
                    <th class="list_bg" ><a href="admin.php?controller=admin_pro&action=passwordcheck&orderby1=username&orderby2=<?php echo $_smarty_tpl->tpl_vars['orderby2']->value;?>
" ><?php echo $_smarty_tpl->tpl_vars['language']->value['LocalUsername'];?>
</a></TD>
                    <th class="list_bg" ><a href="admin.php?controller=admin_pro&action=passwordcheck&orderby1=passwordtry&orderby2=<?php echo $_smarty_tpl->tpl_vars['orderby2']->value;?>
" >检验结果</a></TD>
                  </TR>

            </tr>
			<?php if (isset($_smarty_tpl->tpl_vars['smarty']->value['section']['t'])) unset($_smarty_tpl->tpl_vars['smarty']->value['section']['t']);
$_smarty_tpl->tpl_vars['smarty']->value['section']['t']['name'] = 't';
$_smarty_tpl->tpl_vars['smarty']->value['section']['t']['loop'] = is_array($_loop=$_smarty_tpl->tpl_vars['alllog']->value) ? count($_loop) : max(0, (int) $_loop); unset($_loop);
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
 <td> <?php echo $_smarty_tpl->tpl_vars['alllog']->value[$_smarty_tpl->getVariable('smarty')->value['section']['t']['index']]['device_ip'];?>
</td>
				<td><?php echo $_smarty_tpl->tpl_vars['alllog']->value[$_smarty_tpl->getVariable('smarty')->value['section']['t']['index']]['login_method'];?>
</td>
				<td><?php echo $_smarty_tpl->tpl_vars['alllog']->value[$_smarty_tpl->getVariable('smarty')->value['section']['t']['index']]['username'];?>
</td>
				<td><?php echo $_smarty_tpl->tpl_vars['alllog']->value[$_smarty_tpl->getVariable('smarty')->value['section']['t']['index']]['passwordtry'];?>
</td>
			</tr>
			<?php endfor; endif; ?>

                <tr>
	           <td  colspan="5" align="right">
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
<input name="pagenum" type="text" class="wbk" size="2" onKeyPress="if(event.keyCode==13) window.location='admin.php?controller=admin_pro&action=logs_index&page='+this.value;"><?php echo $_smarty_tpl->tpl_vars['language']->value['page'];?>

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