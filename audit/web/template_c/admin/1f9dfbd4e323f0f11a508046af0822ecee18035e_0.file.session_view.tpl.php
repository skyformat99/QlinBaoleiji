<?php /* Smarty version 3.1.27, created on 2017-07-11 09:42:47
         compiled from "/opt/freesvr/web/htdocs/freesvr/audit/template/admin/session_view.tpl" */ ?>
<?php
/*%%SmartyHeaderCode:72961909559642d17e31307_78344851%%*/
if(!defined('SMARTY_DIR')) exit('no direct access allowed');
$_valid = $_smarty_tpl->decodeProperties(array (
  'file_dependency' => 
  array (
    '1f9dfbd4e323f0f11a508046af0822ecee18035e' => 
    array (
      0 => '/opt/freesvr/web/htdocs/freesvr/audit/template/admin/session_view.tpl',
      1 => 1499420335,
      2 => 'file',
    ),
  ),
  'nocache_hash' => '72961909559642d17e31307_78344851',
  'variables' => 
  array (
    'language' => 0,
    'template_root' => 0,
    'backupdb_id' => 0,
    'subsession' => 0,
    'action' => 0,
    'jumpsession' => 0,
    'sid' => 0,
    'allcommand' => 0,
    'command_num' => 0,
    'page_list' => 0,
    'curr_page' => 0,
    'total_page' => 0,
    'items_per_page' => 0,
    'curr_url' => 0,
    'table_list' => 0,
    'now_table_name' => 0,
    'member' => 0,
  ),
  'has_nocache_code' => false,
  'version' => '3.1.27',
  'unifunc' => 'content_59642d17f29a48_57427403',
),false);
/*/%%SmartyHeaderCode%%*/
if ($_valid && !is_callable('content_59642d17f29a48_57427403')) {
function content_59642d17f29a48_57427403 ($_smarty_tpl) {

$_smarty_tpl->properties['nocache_hash'] = '72961909559642d17e31307_78344851';
?>
<!doctype html public "-//w3c//dtd html 4.0 transitional//en">
<html>
<head>
<title><?php echo $_smarty_tpl->tpl_vars['language']->value['SessionsList'];?>
</title>
<meta name="generator" content="editplus">
<meta name="author" content="nuttycoder">
<link href="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/all_purpose_style.css" rel="stylesheet" type="text/css" />
<?php echo '<script'; ?>
 type="text/javascript" src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/cssjs/jquery-1.10.2.min.js"><?php echo '</script'; ?>
>
<?php echo '<script'; ?>
 type="text/javascript" src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/cssjs/launchprogram.js"><?php echo '</script'; ?>
>
</head>

<body>

<td width="84%" align="left" valign="top"><table width="100%" border="0" cellspacing="0" cellpadding="0"><tr><td valign="middle" class="hui_bj"><div class="menu">
<ul>
    <li class="me_a"><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an1.jpg" align="absmiddle"/><a href="admin.php?controller=admin_session&backupdb_id=<?php echo $_smarty_tpl->tpl_vars['backupdb_id']->value;?>
">Telnet/SSH</a><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an3.jpg" align="absmiddle"/></li>
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
	<?php if ($_smarty_tpl->tpl_vars['backupdb_id']->value) {?>
<li class="me_b"><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an11.jpg" align="absmiddle"/><a href="admin.php?controller=admin_apppub&backupdb_id=<?php echo $_smarty_tpl->tpl_vars['backupdb_id']->value;?>
">应用发布</a><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an33.jpg" align="absmiddle"/></li>
<?php }?>
	<li class="me_b"><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an11.jpg" align="absmiddle"/><a href="admin.php?controller=admin_x11&backupdb_id=<?php echo $_smarty_tpl->tpl_vars['backupdb_id']->value;?>
">X11</a><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an33.jpg" align="absmiddle"/></li> 
<li class="me_b"><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an11.jpg" align="absmiddle"/><a href="admin.php?controller=admin_workflow&action=workflow_approve">流程审批</a><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an33.jpg" align="absmiddle"/></li> 
</ul><span class="back_img"><A href="admin.php?controller=admin_session<?php if (!$_smarty_tpl->tpl_vars['subsession']->value) {?>&action=<?php echo $_smarty_tpl->tpl_vars['action']->value;
}
if ($_smarty_tpl->tpl_vars['jumpsession']->value) {?>&subsession=1<?php }?>&sid=<?php echo $_smarty_tpl->tpl_vars['sid']->value;?>
&back=1"><IMG src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/back1.png" 
      width="80" height="30" border="0"></A></span>
</div></td></tr>
	<table width="100%" border="0" cellspacing="0" cellpadding="5">
 
   <tr class="main_content">
    <td>
<select  class="wbk"  id="app_act" style="display:none"><option value="applet" <?php if ($_SESSION['ADMIN_DEFAULT_CONTROL'] == 'applet') {?>selected<?php }?>>applet</option><option value="activeX" <?php if ($_SESSION['ADMIN_DEFAULT_CONTROL'] == 'activeX') {?>selected<?php }?>>activeX</option></select>
					
			</td><td align="right"></td>
  </tr>
  <tr>
	<td colspan="2" class="">
		<table bordercolor="white" cellspacing="1" cellpadding="5" border="0" width="100%"  class="BBtable">
			<tr>
				<th class="list_bg"  width="20%"><?php echo $_smarty_tpl->tpl_vars['language']->value['ExcuteTime'];?>
</th>
				<th class="list_bg"  width="40%"><?php echo $_smarty_tpl->tpl_vars['language']->value['Command'];?>
</th>
				<th class="list_bg"  width="30%"><?php echo $_smarty_tpl->tpl_vars['language']->value['Operate'];?>
</th>
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
			<tr <?php if ($_smarty_tpl->tpl_vars['allcommand']->value[$_smarty_tpl->getVariable('smarty')->value['section']['t']['index']]['dangerlevel'] == 2) {?>bgcolor="red"<?php } elseif ($_smarty_tpl->tpl_vars['allcommand']->value[$_smarty_tpl->getVariable('smarty')->value['section']['t']['index']]['dangerlevel'] == 3) {?>bgcolor="yellow"<?php } elseif ($_smarty_tpl->tpl_vars['allcommand']->value[$_smarty_tpl->getVariable('smarty')->value['section']['t']['index']]['dangerlevel'] == 4) {?>bgcolor="#0373BF"<?php } elseif ($_smarty_tpl->tpl_vars['allcommand']->value[$_smarty_tpl->getVariable('smarty')->value['section']['t']['index']]['dangerlevel'] == 1) {?>bgcolor="orange"<?php } elseif ($_smarty_tpl->getVariable('smarty')->value['section']['t']['index']%2 == 0) {?>bgcolor="f7f7f7"<?php }?> onmouseover="changeStyle(this,'o');" onmouseout="changeStyle(this,'<?php if ($_smarty_tpl->tpl_vars['allcommand']->value[$_smarty_tpl->getVariable('smarty')->value['section']['t']['index']]['dangerlevel'] == 2) {?>red<?php } elseif ($_smarty_tpl->tpl_vars['allcommand']->value[$_smarty_tpl->getVariable('smarty')->value['section']['t']['index']]['dangerlevel'] == 3) {?>yellow<?php } elseif ($_smarty_tpl->tpl_vars['allcommand']->value[$_smarty_tpl->getVariable('smarty')->value['section']['t']['index']]['dangerlevel'] == 4) {?>#0373BF<?php } elseif ($_smarty_tpl->tpl_vars['allcommand']->value[$_smarty_tpl->getVariable('smarty')->value['section']['t']['index']]['dangerlevel'] == 1) {?>orange<?php } elseif ($_smarty_tpl->getVariable('smarty')->value['section']['t']['index']%2 == 0) {?>f7f7f7<?php }?>');">
				<td><?php echo $_smarty_tpl->tpl_vars['allcommand']->value[$_smarty_tpl->getVariable('smarty')->value['section']['t']['index']]['at'];?>
</ td>
				<td style="word-break:break-all"><?php echo $_smarty_tpl->tpl_vars['allcommand']->value[$_smarty_tpl->getVariable('smarty')->value['section']['t']['index']]['cmd'];?>
</td>
				<td><?php if (!$_smarty_tpl->tpl_vars['backupdb_id']->value) {?>
				<?php if ($_SESSION['ADMIN_LEVEL'] == 3 || $_SESSION['ADMIN_LEVEL'] == 10) {?><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/down.gif" width="16" height="16" align="absmiddle"><a href="#" onclick=window.open("admin.php?controller=admin_session&action=download&sid=<?php echo $_smarty_tpl->tpl_vars['allcommand']->value[$_smarty_tpl->getVariable('smarty')->value['section']['t']['index']]['sid'];?>
&start_page=1")><?php echo $_smarty_tpl->tpl_vars['language']->value['Download'];?>
</a>  &nbsp;|<?php }?> <img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/cmd.png" width="16" height="16" align="absmiddle"><a id="p_<?php echo $_smarty_tpl->tpl_vars['allcommand']->value[$_smarty_tpl->getVariable('smarty')->value['section']['t']['index']]['cid'];?>
" onclick="return go('admin.php?controller=admin_session&action=replay&cid=<?php echo $_smarty_tpl->tpl_vars['allcommand']->value[$_smarty_tpl->getVariable('smarty')->value['section']['t']['index']]['cid'];?>
&sid=<?php echo $_smarty_tpl->tpl_vars['allcommand']->value[$_smarty_tpl->getVariable('smarty')->value['section']['t']['index']]['sid'];?>
&tool=putty.Putty','p_<?php echo $_smarty_tpl->tpl_vars['allcommand']->value[$_smarty_tpl->getVariable('smarty')->value['section']['t']['index']]['cid'];?>
')" href="#" target="hide" >putty</a>   &nbsp;| <img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/application_osx.png" width="16" height="16" align="absmiddle"><a  id="c_<?php echo $_smarty_tpl->tpl_vars['allcommand']->value[$_smarty_tpl->getVariable('smarty')->value['section']['t']['index']]['cid'];?>
" onclick="return go('admin.php?controller=admin_session&action=replay&cid=<?php echo $_smarty_tpl->tpl_vars['allcommand']->value[$_smarty_tpl->getVariable('smarty')->value['section']['t']['index']]['cid'];?>
&sid=<?php echo $_smarty_tpl->tpl_vars['allcommand']->value[$_smarty_tpl->getVariable('smarty')->value['section']['t']['index']]['sid'];?>
&tool=securecrt.SecureCRT','c_<?php echo $_smarty_tpl->tpl_vars['allcommand']->value[$_smarty_tpl->getVariable('smarty')->value['section']['t']['index']]['cid'];?>
');" href="#" target="hide" >CRT</a>
				<?php }?>
				</td>
			</tr>
			<?php endfor; endif; ?>
			<tr>
				<td colspan="12" align="right">
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
<input name="pagenum" type="text" class="wbk" size="2" onKeyPress="if(event.keyCode==13) window.location='admin.php?controller=admin_session&action=view&sid=<?php echo $_smarty_tpl->tpl_vars['sid']->value;?>
&backupdb_id=<?php echo $_smarty_tpl->tpl_vars['backupdb_id']->value;?>
&page='+this.value;"><?php echo $_smarty_tpl->tpl_vars['language']->value['page'];?>
    导出：<a href="<?php echo $_smarty_tpl->tpl_vars['curr_url']->value;?>
&derive=1" target="hide"><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/excel.png" border=0></a>  <a href="<?php echo $_smarty_tpl->tpl_vars['curr_url']->value;?>
&derive=2" ><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/html.png" border=0></a>
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


</body>
<?php echo '<script'; ?>
 language="javascript">
function changeStyle(obj,c)
{
	if(c!='o'){
		obj.style.backgroundColor=c;
	}else{
		obj.style.backgroundColor="#FFCC80";
	}
}

function go(url,iid){
	var app_act = document.getElementById('app_act').options[document.getElementById('app_act').options.selectedIndex].value;
	var hid = document.getElementById('hide');
	url=url+'&app_act='+app_act;
	//alert(hid.src);
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
<iframe id="hide" name="hide" height="0"  frameborder="0" scrolling="no"></iframe>
<input style="width:0;height:0;display:none" id="protocol" value="" />
</html>


<?php }
}
?>