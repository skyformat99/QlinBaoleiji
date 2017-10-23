<?php /* Smarty version 3.1.27, created on 2017-05-28 10:50:36
         compiled from "/opt/freesvr/web/htdocs/freesvr/audit/template/admin/apppriority_search.tpl" */ ?>
<?php
/*%%SmartyHeaderCode:1667439487592a3afc0a9882_39128266%%*/
if(!defined('SMARTY_DIR')) exit('no direct access allowed');
$_valid = $_smarty_tpl->decodeProperties(array (
  'file_dependency' => 
  array (
    'd6c6f9367ff9c8b2cc0c2758c49fbeb005e3b259' => 
    array (
      0 => '/opt/freesvr/web/htdocs/freesvr/audit/template/admin/apppriority_search.tpl',
      1 => 1474793216,
      2 => 'file',
    ),
  ),
  'nocache_hash' => '1667439487592a3afc0a9882_39128266',
  'variables' => 
  array (
    'language' => 0,
    'template_root' => 0,
    'member' => 0,
    'trnumber' => 0,
    'appservers' => 0,
  ),
  'has_nocache_code' => false,
  'version' => '3.1.27',
  'unifunc' => 'content_592a3afc144600_34218633',
),false);
/*/%%SmartyHeaderCode%%*/
if ($_valid && !is_callable('content_592a3afc144600_34218633')) {
function content_592a3afc144600_34218633 ($_smarty_tpl) {

$_smarty_tpl->properties['nocache_hash'] = '1667439487592a3afc0a9882_39128266';
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
<?php echo '<script'; ?>
>
function setScroll(){
	window.parent.scrollTo(0,0);
}
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
	<li class="me_a"><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an1.jpg" align="absmiddle"/><a href="admin.php?controller=admin_reports&action=apppriority_search">应用权限</a><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an3.jpg" align="absmiddle"/></li>
    <li class="me_b"><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an11.jpg" align="absmiddle"/><a href="admin.php?controller=admin_reports&action=systemaccount">系统账号</a><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an33.jpg" align="absmiddle"/></li>
	<li class="me_b"><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an11.jpg" align="absmiddle"/><a href="admin.php?controller=admin_reports&action=appaccount">应用账号</a><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an33.jpg" align="absmiddle"/></li>
	<?php if ($_SESSION['ADMIN_LEVEL'] == 1 || $_SESSION['ADMIN_LEVEL'] == 2) {?>
	<li class="me_b"><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an11.jpg" align="absmiddle"/><a href="admin.php?controller=admin_reports&action=admin_log">变更报表</a><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an33.jpg" align="absmiddle"/></li>
	<?php }?>
</ul>
</div></td></tr>


  
  <tr>
	<td class="">
<form method="get" name="session_search" action="admin.php?controller=admin_reports&action=apppriority" >
<input type="hidden" name="controller" value="admin_reports" />
<input type="hidden" name="action" value="apppriority" />
<input type="hidden" name="type" value="luser" />
				<table bordercolor="white" cellspacing="0" cellpadding="0" border="0" width="100%"  class="BBtable">
				 <tr>
    <th class="list_bg" colspan="2"><?php echo $_smarty_tpl->tpl_vars['language']->value['Man'];?>
：<?php echo $_smarty_tpl->tpl_vars['language']->value['Search'];?>
应用权限,留空表示<?php echo $_smarty_tpl->tpl_vars['language']->value['no'];?>
限制 </th>
  </tr>
					<?php $_smarty_tpl->tpl_vars["trnumber"] = new Smarty_Variable(0, null, 0);?>
					<tr  <?php if ($_smarty_tpl->tpl_vars['trnumber']->value++%2 == 0) {?>bgcolor="f7f7f7"<?php }?>>
					<td class="td_line" width="30%">运维用户：</td>
						<td class="td_line" width="70%">
						<select name='user' id="luser">
						</select>&nbsp;&nbsp;&nbsp;&nbsp;<input type="checkbox" onclick="toRealname();" id="RealNameToId" value="on" >&nbsp;实名</td>
					</tr>
					<tr  <?php if ($_smarty_tpl->tpl_vars['trnumber']->value++%2 == 0) {?>bgcolor="f7f7f7"<?php }?>>
						<td class="td_line" width="30%">应用发布IP：</td>
						<td class="td_line" width="70%">
						<select name='appserverip' id="appserverip">
						<option value="">所有</option>
						<?php if (isset($_smarty_tpl->tpl_vars['smarty']->value['section']['a'])) unset($_smarty_tpl->tpl_vars['smarty']->value['section']['a']);
$_smarty_tpl->tpl_vars['smarty']->value['section']['a']['name'] = 'a';
$_smarty_tpl->tpl_vars['smarty']->value['section']['a']['loop'] = is_array($_loop=$_smarty_tpl->tpl_vars['appservers']->value) ? count($_loop) : max(0, (int) $_loop); unset($_loop);
$_smarty_tpl->tpl_vars['smarty']->value['section']['a']['show'] = true;
$_smarty_tpl->tpl_vars['smarty']->value['section']['a']['max'] = $_smarty_tpl->tpl_vars['smarty']->value['section']['a']['loop'];
$_smarty_tpl->tpl_vars['smarty']->value['section']['a']['step'] = 1;
$_smarty_tpl->tpl_vars['smarty']->value['section']['a']['start'] = $_smarty_tpl->tpl_vars['smarty']->value['section']['a']['step'] > 0 ? 0 : $_smarty_tpl->tpl_vars['smarty']->value['section']['a']['loop']-1;
if ($_smarty_tpl->tpl_vars['smarty']->value['section']['a']['show']) {
    $_smarty_tpl->tpl_vars['smarty']->value['section']['a']['total'] = $_smarty_tpl->tpl_vars['smarty']->value['section']['a']['loop'];
    if ($_smarty_tpl->tpl_vars['smarty']->value['section']['a']['total'] == 0)
        $_smarty_tpl->tpl_vars['smarty']->value['section']['a']['show'] = false;
} else
    $_smarty_tpl->tpl_vars['smarty']->value['section']['a']['total'] = 0;
if ($_smarty_tpl->tpl_vars['smarty']->value['section']['a']['show']):

            for ($_smarty_tpl->tpl_vars['smarty']->value['section']['a']['index'] = $_smarty_tpl->tpl_vars['smarty']->value['section']['a']['start'], $_smarty_tpl->tpl_vars['smarty']->value['section']['a']['iteration'] = 1;
                 $_smarty_tpl->tpl_vars['smarty']->value['section']['a']['iteration'] <= $_smarty_tpl->tpl_vars['smarty']->value['section']['a']['total'];
                 $_smarty_tpl->tpl_vars['smarty']->value['section']['a']['index'] += $_smarty_tpl->tpl_vars['smarty']->value['section']['a']['step'], $_smarty_tpl->tpl_vars['smarty']->value['section']['a']['iteration']++):
$_smarty_tpl->tpl_vars['smarty']->value['section']['a']['rownum'] = $_smarty_tpl->tpl_vars['smarty']->value['section']['a']['iteration'];
$_smarty_tpl->tpl_vars['smarty']->value['section']['a']['index_prev'] = $_smarty_tpl->tpl_vars['smarty']->value['section']['a']['index'] - $_smarty_tpl->tpl_vars['smarty']->value['section']['a']['step'];
$_smarty_tpl->tpl_vars['smarty']->value['section']['a']['index_next'] = $_smarty_tpl->tpl_vars['smarty']->value['section']['a']['index'] + $_smarty_tpl->tpl_vars['smarty']->value['section']['a']['step'];
$_smarty_tpl->tpl_vars['smarty']->value['section']['a']['first']      = ($_smarty_tpl->tpl_vars['smarty']->value['section']['a']['iteration'] == 1);
$_smarty_tpl->tpl_vars['smarty']->value['section']['a']['last']       = ($_smarty_tpl->tpl_vars['smarty']->value['section']['a']['iteration'] == $_smarty_tpl->tpl_vars['smarty']->value['section']['a']['total']);
?>
						<option value="<?php echo $_smarty_tpl->tpl_vars['appservers']->value[$_smarty_tpl->getVariable('smarty')->value['section']['a']['index']]['appserverip'];?>
"><?php echo $_smarty_tpl->tpl_vars['appservers']->value[$_smarty_tpl->getVariable('smarty')->value['section']['a']['index']]['appserverip'];?>
</option>
						<?php endfor; endif; ?>
						</select></td>
					</tr>
					<tr  <?php if ($_smarty_tpl->tpl_vars['trnumber']->value++%2 == 0) {?>bgcolor="f7f7f7"<?php }?>>
						<td class="td_line" width="30%">本地用户：</td>
						<td class="td_line" width="70%"><input name="s_user" type="text" class="wbk"></td>
					</tr>
					<tr bgcolor="f7f7f7">
						<td class="td_line" colspan="2" align="center"><input name="submit" type="submit" onclick="setScroll();"  value="<?php echo $_smarty_tpl->tpl_vars['language']->value['Search'];?>
" class="an_02">
					</tr>
				</table>
				
			</form>
	</td>
  </tr>
</table>

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
toRealname();
<?php echo '</script'; ?>
>

<?php }
}
?>