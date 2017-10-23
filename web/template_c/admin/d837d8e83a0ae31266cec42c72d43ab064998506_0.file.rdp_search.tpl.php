<?php /* Smarty version 3.1.27, created on 2017-08-11 12:21:21
         compiled from "/opt/freesvr/web/htdocs/freesvr/audit/template/admin/rdp_search.tpl" */ ?>
<?php
/*%%SmartyHeaderCode:1135481470598d30c1872b81_79967876%%*/
if(!defined('SMARTY_DIR')) exit('no direct access allowed');
$_valid = $_smarty_tpl->decodeProperties(array (
  'file_dependency' => 
  array (
    'd837d8e83a0ae31266cec42c72d43ab064998506' => 
    array (
      0 => '/opt/freesvr/web/htdocs/freesvr/audit/template/admin/rdp_search.tpl',
      1 => 1483623678,
      2 => 'file',
    ),
  ),
  'nocache_hash' => '1135481470598d30c1872b81_79967876',
  'variables' => 
  array (
    'language' => 0,
    'template_root' => 0,
    'member' => 0,
    'table_list' => 0,
    'admin_level' => 0,
    'alldev' => 0,
  ),
  'has_nocache_code' => false,
  'version' => '3.1.27',
  'unifunc' => 'content_598d30c1915415_63102825',
),false);
/*/%%SmartyHeaderCode%%*/
if ($_valid && !is_callable('content_598d30c1915415_63102825')) {
function content_598d30c1915415_63102825 ($_smarty_tpl) {

$_smarty_tpl->properties['nocache_hash'] = '1135481470598d30c1872b81_79967876';
?>
<!doctype html public "-//w3c//dtd html 4.0 transitional//en">
<html>
<head>
<title><?php echo $_smarty_tpl->tpl_vars['language']->value['LogList'];?>
</title>
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
 src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/cssjs/cn.js"><?php echo '</script'; ?>
>
</head>
<?php echo '<script'; ?>
>
var member = new Array();
<?php if (isset($_smarty_tpl->tpl_vars['smarty']->value['section']['m'])) unset($_smarty_tpl->tpl_vars['smarty']->value['section']['m']);
$_smarty_tpl->tpl_vars['smarty']->value['section']['m']['name'] = 'm';
$_smarty_tpl->tpl_vars['smarty']->value['section']['m']['loop'] = is_array($_loop=$_smarty_tpl->tpl_vars['member']->value) ? count($_loop) : max(0, (int) $_loop); unset($_loop);
$_smarty_tpl->tpl_vars['smarty']->value['section']['m']['show'] = true;
$_smarty_tpl->tpl_vars['smarty']->value['section']['m']['max'] = $_smarty_tpl->tpl_vars['smarty']->value['section']['m']['loop'];
$_smarty_tpl->tpl_vars['smarty']->value['section']['m']['step'] = 1;
$_smarty_tpl->tpl_vars['smarty']->value['section']['m']['start'] = $_smarty_tpl->tpl_vars['smarty']->value['section']['m']['step'] > 0 ? 0 : $_smarty_tpl->tpl_vars['smarty']->value['section']['m']['loop']-1;
if ($_smarty_tpl->tpl_vars['smarty']->value['section']['m']['show']) {
    $_smarty_tpl->tpl_vars['smarty']->value['section']['m']['total'] = $_smarty_tpl->tpl_vars['smarty']->value['section']['m']['loop'];
    if ($_smarty_tpl->tpl_vars['smarty']->value['section']['m']['total'] == 0)
        $_smarty_tpl->tpl_vars['smarty']->value['section']['m']['show'] = false;
} else
    $_smarty_tpl->tpl_vars['smarty']->value['section']['m']['total'] = 0;
if ($_smarty_tpl->tpl_vars['smarty']->value['section']['m']['show']):

            for ($_smarty_tpl->tpl_vars['smarty']->value['section']['m']['index'] = $_smarty_tpl->tpl_vars['smarty']->value['section']['m']['start'], $_smarty_tpl->tpl_vars['smarty']->value['section']['m']['iteration'] = 1;
                 $_smarty_tpl->tpl_vars['smarty']->value['section']['m']['iteration'] <= $_smarty_tpl->tpl_vars['smarty']->value['section']['m']['total'];
                 $_smarty_tpl->tpl_vars['smarty']->value['section']['m']['index'] += $_smarty_tpl->tpl_vars['smarty']->value['section']['m']['step'], $_smarty_tpl->tpl_vars['smarty']->value['section']['m']['iteration']++):
$_smarty_tpl->tpl_vars['smarty']->value['section']['m']['rownum'] = $_smarty_tpl->tpl_vars['smarty']->value['section']['m']['iteration'];
$_smarty_tpl->tpl_vars['smarty']->value['section']['m']['index_prev'] = $_smarty_tpl->tpl_vars['smarty']->value['section']['m']['index'] - $_smarty_tpl->tpl_vars['smarty']->value['section']['m']['step'];
$_smarty_tpl->tpl_vars['smarty']->value['section']['m']['index_next'] = $_smarty_tpl->tpl_vars['smarty']->value['section']['m']['index'] + $_smarty_tpl->tpl_vars['smarty']->value['section']['m']['step'];
$_smarty_tpl->tpl_vars['smarty']->value['section']['m']['first']      = ($_smarty_tpl->tpl_vars['smarty']->value['section']['m']['iteration'] == 1);
$_smarty_tpl->tpl_vars['smarty']->value['section']['m']['last']       = ($_smarty_tpl->tpl_vars['smarty']->value['section']['m']['iteration'] == $_smarty_tpl->tpl_vars['smarty']->value['section']['m']['total']);
?>
member[<?php echo $_smarty_tpl->getVariable('smarty')->value['section']['m']['index'];?>
]={'username':'<?php echo $_smarty_tpl->tpl_vars['member']->value[$_smarty_tpl->getVariable('smarty')->value['section']['m']['index']]['username'];?>
','realname':'<?php echo $_smarty_tpl->tpl_vars['member']->value[$_smarty_tpl->getVariable('smarty')->value['section']['m']['index']]['realname'];?>
'}
<?php endfor; endif; ?>
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
    <li class="me_a"><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an1.jpg" align="absmiddle"/><a href="admin.php?controller=admin_session&action=search">会话搜索</a><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an3.jpg" align="absmiddle"/></li>
    <li class="me_b"><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an11.jpg" align="absmiddle"/><a href="admin.php?controller=admin_session&action=search_html_log">内容搜索</a><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an33.jpg" align="absmiddle"/></li>
</ul>
</div></td></tr>

  <tr>
	<td class="">
<form method="get" name="session_search" action="admin.php">
				<table bordercolor="white" cellspacing="0" cellpadding="0" border="0" width="100%"  class="BBtable">
					<!--
					<tr>
						<td class="td_line" width="30%">数据表：</td>
						<td class="td_line" width="70%">
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
"><?php echo $_smarty_tpl->tpl_vars['table_list']->value[$_smarty_tpl->getVariable('smarty')->value['section']['t']['index']];?>
</option>
						<?php endfor; endif; ?>
						</select>
						<?php echo $_smarty_tpl->tpl_vars['language']->value['Sort'];?>

						</td>
					</tr>
					-->
					 <tr>
    <th class="list_bg" colspan="2"><?php echo $_smarty_tpl->tpl_vars['language']->value['Man'];?>
：<?php echo $_smarty_tpl->tpl_vars['language']->value['Search'];
echo $_smarty_tpl->tpl_vars['language']->value['Session'];?>
,留空表示<?php echo $_smarty_tpl->tpl_vars['language']->value['no'];?>
限制 </th>
  </tr>
					<tr  <?php if ($_smarty_tpl->getVariable('smarty')->value['section']['t']['index']%2 == 0) {?>bgcolor="f7f7f7"<?php }?>>
 <td> <?php echo $_smarty_tpl->tpl_vars['language']->value['Search'];
echo $_smarty_tpl->tpl_vars['language']->value['Session'];
echo $_smarty_tpl->tpl_vars['language']->value['Content'];?>
</td>
						<td><table><tr >
						<td width="100">
							<input type="radio" name="controller" value="admin_session" onClick="location.href='admin.php?controller=admin_session&action=search'">telnet/ssh<?php echo $_smarty_tpl->tpl_vars['language']->value['Session'];?>

							</td>
						<td width="100">
							<input type="radio" name="controller" value="admin_rdp" checked >rdp<?php echo $_smarty_tpl->tpl_vars['language']->value['Session'];?>

							</td>
							<td width="100">
							<input type="radio" name="controller" value="admin_vnc" onClick="location.href='admin.php?controller=admin_vnc&action=search'">vnc<?php echo $_smarty_tpl->tpl_vars['language']->value['Session'];?>

							</td>
							<td width="100">
							<input type="radio" name="controller" value="admin_ftp" onClick="location.href='admin.php?controller=admin_ftp&action=search'" >Ftp<?php echo $_smarty_tpl->tpl_vars['language']->value['Session'];?>

							</td><td width="100">
							<input type="radio" name="controller" value="admin_sftp" onClick="location.href='admin.php?controller=admin_sftp&action=search'">SFtp<?php echo $_smarty_tpl->tpl_vars['language']->value['Session'];?>

							</td><td width="100">
							<input type="radio" name="controller" value="admin_apppub" onClick="location.href='admin.php?controller=admin_apppub&action=search'" >应用<?php echo $_smarty_tpl->tpl_vars['language']->value['Session'];?>

							</td></tr><tr >
						<td width="100">
							<input type="radio" name="controller" value="admin_session" onClick="location.href='admin.php?controller=admin_apppub&action=plsql_search'">SQL查询
							</td>
							<td width="100"><input type="radio" name="controller" value="admin_apppub" onClick="location.href='admin.php?controller=admin_apppub&action=urlsearch'">应用URL</td><td><input type="radio" name="controller" value="admin_scp" onClick="location.href='admin.php?controller=admin_scp&action=search'">SCP</td><td></td><td></td><td></td><td></td>
						</tr></table>
						</td>
					</tr>
					<tr>
						<td class="td_line" width="30%"><?php echo $_smarty_tpl->tpl_vars['language']->value['Result'];?>
：</td>
						<td class="td_line" width="70%">
						<select  class="wbk"  name="orderby1">
							<option value='sid'><?php echo $_smarty_tpl->tpl_vars['language']->value['default'];?>
</option>
							<option value='addr'><?php echo $_smarty_tpl->tpl_vars['language']->value['DeviceAddress'];?>
</option>
							<option value='type'><?php echo $_smarty_tpl->tpl_vars['language']->value['Sessiontype'];?>
</option>
							<option value='luser'><?php echo $_smarty_tpl->tpl_vars['language']->value['Username'];?>
</option>
							<option value='start'><?php echo $_smarty_tpl->tpl_vars['language']->value['Session'];
echo $_smarty_tpl->tpl_vars['language']->value['StartTime'];?>
</option>
							<option value='end'><?php echo $_smarty_tpl->tpl_vars['language']->value['Session'];
echo $_smarty_tpl->tpl_vars['language']->value['EndTime'];?>
</option>
						</select>
						<?php echo $_smarty_tpl->tpl_vars['language']->value['Sort'];?>

						<select  class="wbk"  name="orderby2">
							<option value='asc'><?php echo $_smarty_tpl->tpl_vars['language']->value['ascendingorder'];?>
</option>
							<option value='desc'><?php echo $_smarty_tpl->tpl_vars['language']->value['decreasingorder'];?>
</option>
						</select>
						</td>
					</tr>
					<?php if ($_smarty_tpl->tpl_vars['admin_level']->value == 1) {?>
					<tr bgcolor="f7f7f7">
						<td class="td_line" width="30%">运维用户：</td>
						<td class="td_line" width="70%"><select name='luser' id="luser">
						<option value="">所有用户</option>
						<?php if (isset($_smarty_tpl->tpl_vars['smarty']->value['section']['m'])) unset($_smarty_tpl->tpl_vars['smarty']->value['section']['m']);
$_smarty_tpl->tpl_vars['smarty']->value['section']['m']['name'] = 'm';
$_smarty_tpl->tpl_vars['smarty']->value['section']['m']['loop'] = is_array($_loop=$_smarty_tpl->tpl_vars['member']->value) ? count($_loop) : max(0, (int) $_loop); unset($_loop);
$_smarty_tpl->tpl_vars['smarty']->value['section']['m']['show'] = true;
$_smarty_tpl->tpl_vars['smarty']->value['section']['m']['max'] = $_smarty_tpl->tpl_vars['smarty']->value['section']['m']['loop'];
$_smarty_tpl->tpl_vars['smarty']->value['section']['m']['step'] = 1;
$_smarty_tpl->tpl_vars['smarty']->value['section']['m']['start'] = $_smarty_tpl->tpl_vars['smarty']->value['section']['m']['step'] > 0 ? 0 : $_smarty_tpl->tpl_vars['smarty']->value['section']['m']['loop']-1;
if ($_smarty_tpl->tpl_vars['smarty']->value['section']['m']['show']) {
    $_smarty_tpl->tpl_vars['smarty']->value['section']['m']['total'] = $_smarty_tpl->tpl_vars['smarty']->value['section']['m']['loop'];
    if ($_smarty_tpl->tpl_vars['smarty']->value['section']['m']['total'] == 0)
        $_smarty_tpl->tpl_vars['smarty']->value['section']['m']['show'] = false;
} else
    $_smarty_tpl->tpl_vars['smarty']->value['section']['m']['total'] = 0;
if ($_smarty_tpl->tpl_vars['smarty']->value['section']['m']['show']):

            for ($_smarty_tpl->tpl_vars['smarty']->value['section']['m']['index'] = $_smarty_tpl->tpl_vars['smarty']->value['section']['m']['start'], $_smarty_tpl->tpl_vars['smarty']->value['section']['m']['iteration'] = 1;
                 $_smarty_tpl->tpl_vars['smarty']->value['section']['m']['iteration'] <= $_smarty_tpl->tpl_vars['smarty']->value['section']['m']['total'];
                 $_smarty_tpl->tpl_vars['smarty']->value['section']['m']['index'] += $_smarty_tpl->tpl_vars['smarty']->value['section']['m']['step'], $_smarty_tpl->tpl_vars['smarty']->value['section']['m']['iteration']++):
$_smarty_tpl->tpl_vars['smarty']->value['section']['m']['rownum'] = $_smarty_tpl->tpl_vars['smarty']->value['section']['m']['iteration'];
$_smarty_tpl->tpl_vars['smarty']->value['section']['m']['index_prev'] = $_smarty_tpl->tpl_vars['smarty']->value['section']['m']['index'] - $_smarty_tpl->tpl_vars['smarty']->value['section']['m']['step'];
$_smarty_tpl->tpl_vars['smarty']->value['section']['m']['index_next'] = $_smarty_tpl->tpl_vars['smarty']->value['section']['m']['index'] + $_smarty_tpl->tpl_vars['smarty']->value['section']['m']['step'];
$_smarty_tpl->tpl_vars['smarty']->value['section']['m']['first']      = ($_smarty_tpl->tpl_vars['smarty']->value['section']['m']['iteration'] == 1);
$_smarty_tpl->tpl_vars['smarty']->value['section']['m']['last']       = ($_smarty_tpl->tpl_vars['smarty']->value['section']['m']['iteration'] == $_smarty_tpl->tpl_vars['smarty']->value['section']['m']['total']);
?>
						<option value="<?php echo $_smarty_tpl->tpl_vars['member']->value[$_smarty_tpl->getVariable('smarty')->value['section']['m']['index']]['username'];?>
"><?php echo $_smarty_tpl->tpl_vars['member']->value[$_smarty_tpl->getVariable('smarty')->value['section']['m']['index']]['username'];?>
</option>
						<?php endfor; endif; ?>
						</select>&nbsp;&nbsp;&nbsp;&nbsp;<input type="checkbox" onclick="toRealname();" id="RealNameToId" value="on" >实名</td>
					</tr>
					<tr>
						<td class="td_line" width="30%">本地用户：</td>
						<td class="td_line" width="70%"><input name="user" type="text" class="wbk"></td>
					</tr>
					<?php }?>
					<tr bgcolor="f7f7f7">
						<td class="td_line" width="30%"><?php echo $_smarty_tpl->tpl_vars['language']->value['DeviceAddress'];?>
：</td>
						<td class="td_line" width="70%">
							<input name="addr" id="addr" type="text" class="wbk" /><br />
							<select  class="wbk"  name="fromlist" size="6" style="width:140px;height:110px;" onchange="javascript:document.getElementById('addr').value=this.options[this.selectedIndex].text">
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
								<option name="<?php echo $_smarty_tpl->tpl_vars['alldev']->value[$_smarty_tpl->getVariable('smarty')->value['section']['t']['index']]['device_ip'];?>
"><?php echo $_smarty_tpl->tpl_vars['alldev']->value[$_smarty_tpl->getVariable('smarty')->value['section']['t']['index']]['device_ip'];?>
</option>
								<?php endfor; endif; ?>
							</select>
						</td>
					</tr>
						<input type='hidden' value = 'all'>
					<tr>
						<td class="td_line" width="30%"><?php echo $_smarty_tpl->tpl_vars['language']->value['StartTime'];?>
：</td>
						<td class="td_line" width="70%"><input name="start1" id="f_rangeStart" type="text" class="wbk">&nbsp;<input type="button" onclick="changetype('timetype3')" id="f_rangeStart_trigger" name="f_rangeStart_trigger" value="起始时间"  class="wbk"></td>
					</tr>
					<tr bgcolor="f7f7f7">
						<td class="td_line" width="30%"><?php echo $_smarty_tpl->tpl_vars['language']->value['EndTime'];?>
：</td>
						<td class="td_line" width="70%"><input name="end2" id="f_rangeEnd2" type="text" class="wbk">&nbsp;<input type="button" onclick="changetype('timetype3')" id="f_rangeEnd_trigger2" name="f_rangeEnd_trigger2" value="终止时间"  class="wbk"></td>
					</tr>
					
					<tr>
						<td class="td_line" width="30%"><?php echo $_smarty_tpl->tpl_vars['language']->value['SourceAddress'];?>
：</td>
						<td class="td_line" width="70%"><input type="text" class="wbk" name="srcaddr"></td>
					</tr>
					<tr bgcolor="f7f7f7">
						<td class="td_line" colspan="2" align="center"><input name="submit" type="submit"  value="<?php echo $_smarty_tpl->tpl_vars['language']->value['Search'];?>
" onclick="setScroll();" class="an_02"></td>
					</tr>
				</table>
				<?php echo '<script'; ?>
 type="text/javascript">
                  new Calendar({
                          inputField: "f_rangeStart",
                          dateFormat: "%Y-%m-%d %H:%M:%S",showTime: true,
                          trigger: "f_rangeStart_trigger",
                          bottomBar: false,
						  popupDirection:'up',
                          onSelect: function() {
                                  var date = Calendar.intToDate(this.selection.get());
                                 
                                  this.hide();
                          }
                  });
                  new Calendar({
                      inputField: "f_rangeEnd2",
                      dateFormat: "%Y-%m-%d %H:%M:%S",showTime: true,
                      trigger: "f_rangeEnd_trigger2",
                      bottomBar: false,
					  popupDirection:'up',
                      onSelect: function() {
                              var date = Calendar.intToDate(this.selection.get());
                             
                              this.hide();
                      }
              });
                <?php echo '</script'; ?>
>
			</form>
	</td>
  </tr>
</table>


<?php echo '<script'; ?>
>
function setScroll(){
	window.parent.scrollTo(0,0);
}
<?php echo '</script'; ?>
>
<?php echo '<script'; ?>
>
function toRealname(){
	document.getElementById('luser').options.length=0;
	document.getElementById('luser').options[document.getElementById('luser').options.length]= new Option('所有用户','');
	if(document.getElementById('RealNameToId').checked){
		for(var i=0; i<member.length; i++){
			document.getElementById('luser').options[document.getElementById('luser').options.length]= new Option(member[i].realname,member[i].username);
		}
	}else{
		for(var i=0; i<member.length; i++){
			document.getElementById('luser').options[document.getElementById('luser').options.length]= new Option(member[i].username,member[i].username);
		}
	}
}
<?php echo '</script'; ?>
>

<?php }
}
?>