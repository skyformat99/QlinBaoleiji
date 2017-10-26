<?php /* Smarty version 3.1.27, created on 2017-06-27 16:50:30
         compiled from "/opt/freesvr/web/htdocs/freesvr/audit/template/admin/adusers_tree.tpl" */ ?>
<?php
/*%%SmartyHeaderCode:170683075059521c569f0785_50085467%%*/
if(!defined('SMARTY_DIR')) exit('no direct access allowed');
$_valid = $_smarty_tpl->decodeProperties(array (
  'file_dependency' => 
  array (
    'be05a06e5a03eecb536082d04dd3b6e0aa63ce29' => 
    array (
      0 => '/opt/freesvr/web/htdocs/freesvr/audit/template/admin/adusers_tree.tpl',
      1 => 1480581356,
      2 => 'file',
    ),
  ),
  'nocache_hash' => '170683075059521c569f0785_50085467',
  'variables' => 
  array (
    'title' => 0,
    'template_root' => 0,
    'step' => 0,
    'adconfig' => 0,
    'members' => 0,
    'dn' => 0,
    'count' => 0,
    'cns' => 0,
    'ous' => 0,
    'groups' => 0,
    'nogroupusers' => 0,
    'member' => 0,
  ),
  'has_nocache_code' => false,
  'version' => '3.1.27',
  'unifunc' => 'content_59521c56b02703_59423462',
),false);
/*/%%SmartyHeaderCode%%*/
if ($_valid && !is_callable('content_59521c56b02703_59423462')) {
function content_59521c56b02703_59423462 ($_smarty_tpl) {

$_smarty_tpl->properties['nocache_hash'] = '170683075059521c569f0785_50085467';
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
<link href="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/cssjs/dtree.css" rel="stylesheet" type="text/css" />
<?php echo '<script'; ?>
 type="text/javascript" src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/cssjs/jquery-1.10.2.min.js"><?php echo '</script'; ?>
>
<?php echo '<script'; ?>
 type="text/javascript" src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/cssjs/jquery.csv-0.71.min.js"><?php echo '</script'; ?>
>
<?php echo '<script'; ?>
 type="text/javascript" src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/cssjs/ajaxdtree.js"><?php echo '</script'; ?>
>
</head>
<style>
.dtree {width: auto;overflow: scroll;height:400px;}
</style>
<?php echo '<script'; ?>
 type="text/javascript">
function checkgroupa(c, g){
	var elements = document.getElementsByTagName('input');
	for(var i=0; i<elements.length; i++){
		if(elements[i].type=='checkbox'&&elements[i].id.indexOf('u_'+g+'_')>=0){
			document.getElementById(elements[i].id).checked = c;
		}
	}

	return true;
}

<?php echo '</script'; ?>
>
<body>
<?php if (!$_smarty_tpl->tpl_vars['step']->value) {?>
<FORM name="f1" onSubmit="return check()" enctype="multipart/form-data" action="admin.php?controller=admin_config&action=adusers" method="post">

              <TABLE width="100%" bgcolor="#ffffff" border="0" cellspacing="0" cellpadding="0" valign="top"  class="BBtable">
                <TBODY>
				<tr bgcolor="f7f7f7"><td align="right">AD 服务器:</td>		
	<td>
		<input type="text" class="wbk" name="address" value="<?php echo $_smarty_tpl->tpl_vars['adconfig']->value['address'];?>
" />	
		</td>	
	<td align="right">
		 AD域 :</td>		
	<td>
		<input type="text" class="wbk" name="domain" value="<?php echo $_smarty_tpl->tpl_vars['adconfig']->value['domain'];?>
" />	
		</td>		
	</tr>

	<tr bgcolor=""><td align="right">AD 服务器账号:</td>		
	<td>
		<input type="text" class="wbk" name="adusername" value="<?php echo $_smarty_tpl->tpl_vars['adconfig']->value['adusername'];?>
" />	
		</td>
<td align="right"> AD 服务器密码:</td>		
	<td>
		<input type="password" class="wbk" name="adpassword" value="<?php echo $_smarty_tpl->tpl_vars['adconfig']->value['adpassword'];?>
" />	</td>
	</tr>
	<tr bgcolor="f7f7f7"><td align="right">OU:</td>		
	<td colspan="3">
		<input type="text" class="wbk" name="ou" size="50" value="<?php echo $_smarty_tpl->tpl_vars['adconfig']->value['ou'];?>
" />搜索目录的DN
		</td>
	</tr>
                  <TR>
                    <TD colspan="4" align="center"><INPUT class="an_02" type="submit" value="提交"></TD>
                  </TR>
                </TBODY>
              </TABLE>
</FORM>

<?php } elseif ($_smarty_tpl->tpl_vars['step']->value == 1) {?>
 <FORM name="f1" onSubmit="return check()" enctype="multipart/form-data" action="admin.php?controller=admin_config&action=adusers_save" method="post">

              <TABLE width="100%" bgcolor="#ffffff" border="0" cellspacing="0" cellpadding="0" valign="top"  class="BBtable">
                <TBODY>
				<TR id="autosutr" <?php if ($_smarty_tpl->getVariable('smarty')->value['section']['i']['index']%2 == 0) {?>bgcolor="f7f7f7"<?php }?>>
                    <TD width="20%" align="center">用户名 选择				
					</TD>
                  </TR>
				
                  <TR id="autosutr" <?php if ($_smarty_tpl->getVariable('smarty')->value['section']['i']['index']%2 == 0) {?>bgcolor="f7f7f7"<?php }?>>
                    <TD>
					<table><tr >
		<?php if (isset($_smarty_tpl->tpl_vars['smarty']->value['section']['i'])) unset($_smarty_tpl->tpl_vars['smarty']->value['section']['i']);
$_smarty_tpl->tpl_vars['smarty']->value['section']['i']['name'] = 'i';
$_smarty_tpl->tpl_vars['smarty']->value['section']['i']['loop'] = is_array($_loop=$_smarty_tpl->tpl_vars['members']->value) ? count($_loop) : max(0, (int) $_loop); unset($_loop);
$_smarty_tpl->tpl_vars['smarty']->value['section']['i']['show'] = true;
$_smarty_tpl->tpl_vars['smarty']->value['section']['i']['max'] = $_smarty_tpl->tpl_vars['smarty']->value['section']['i']['loop'];
$_smarty_tpl->tpl_vars['smarty']->value['section']['i']['step'] = 1;
$_smarty_tpl->tpl_vars['smarty']->value['section']['i']['start'] = $_smarty_tpl->tpl_vars['smarty']->value['section']['i']['step'] > 0 ? 0 : $_smarty_tpl->tpl_vars['smarty']->value['section']['i']['loop']-1;
if ($_smarty_tpl->tpl_vars['smarty']->value['section']['i']['show']) {
    $_smarty_tpl->tpl_vars['smarty']->value['section']['i']['total'] = $_smarty_tpl->tpl_vars['smarty']->value['section']['i']['loop'];
    if ($_smarty_tpl->tpl_vars['smarty']->value['section']['i']['total'] == 0)
        $_smarty_tpl->tpl_vars['smarty']->value['section']['i']['show'] = false;
} else
    $_smarty_tpl->tpl_vars['smarty']->value['section']['i']['total'] = 0;
if ($_smarty_tpl->tpl_vars['smarty']->value['section']['i']['show']):

            for ($_smarty_tpl->tpl_vars['smarty']->value['section']['i']['index'] = $_smarty_tpl->tpl_vars['smarty']->value['section']['i']['start'], $_smarty_tpl->tpl_vars['smarty']->value['section']['i']['iteration'] = 1;
                 $_smarty_tpl->tpl_vars['smarty']->value['section']['i']['iteration'] <= $_smarty_tpl->tpl_vars['smarty']->value['section']['i']['total'];
                 $_smarty_tpl->tpl_vars['smarty']->value['section']['i']['index'] += $_smarty_tpl->tpl_vars['smarty']->value['section']['i']['step'], $_smarty_tpl->tpl_vars['smarty']->value['section']['i']['iteration']++):
$_smarty_tpl->tpl_vars['smarty']->value['section']['i']['rownum'] = $_smarty_tpl->tpl_vars['smarty']->value['section']['i']['iteration'];
$_smarty_tpl->tpl_vars['smarty']->value['section']['i']['index_prev'] = $_smarty_tpl->tpl_vars['smarty']->value['section']['i']['index'] - $_smarty_tpl->tpl_vars['smarty']->value['section']['i']['step'];
$_smarty_tpl->tpl_vars['smarty']->value['section']['i']['index_next'] = $_smarty_tpl->tpl_vars['smarty']->value['section']['i']['index'] + $_smarty_tpl->tpl_vars['smarty']->value['section']['i']['step'];
$_smarty_tpl->tpl_vars['smarty']->value['section']['i']['first']      = ($_smarty_tpl->tpl_vars['smarty']->value['section']['i']['iteration'] == 1);
$_smarty_tpl->tpl_vars['smarty']->value['section']['i']['last']       = ($_smarty_tpl->tpl_vars['smarty']->value['section']['i']['iteration'] == $_smarty_tpl->tpl_vars['smarty']->value['section']['i']['total']);
?>
		<?php if (!$_smarty_tpl->tpl_vars['members']->value[$_smarty_tpl->getVariable('smarty')->value['section']['i']['index']]['checked']) {?>
		<td width="150"><input type='checkbox' name='username[]' value='<?php echo $_smarty_tpl->tpl_vars['members']->value[$_smarty_tpl->getVariable('smarty')->value['section']['i']['index']]['username'];?>
' ><?php echo $_smarty_tpl->tpl_vars['members']->value[$_smarty_tpl->getVariable('smarty')->value['section']['i']['index']]['username'];?>
</td><?php if (($_smarty_tpl->getVariable('smarty')->value['section']['i']['index']+1)%5 == 0) {?></tr><tr>
		
				 <?php }?> <?php }?> 
				<?php endfor; endif; ?>
		</tr></table>
<div class="dtree" id="dtree1">
	<?php echo '<script'; ?>
 type="text/javascript">

		ddev = new adTree('ddev',"dtree1",'users');
		ddev.icon['folder'] = 'template/admin/cssjs/img/group.gif';
		ddev.icon['folderOpen'] = 'template/admin/cssjs/img/groupopen.png';
		ddev.icon['node'] = 'template/admin/cssjs/img/user.gif';
		var i=0;
		ddev.add(0,-1,'<?php echo $_smarty_tpl->tpl_vars['dn']->value;
if ($_smarty_tpl->tpl_vars['count']->value) {?> (<?php echo $_smarty_tpl->tpl_vars['count']->value;?>
)<?php }?>','#','');
		//ddev.add(10000,0,'所有主机','admin.php?controller=admin_pro&action=dev_index','','main');
		<?php if (isset($_smarty_tpl->tpl_vars['smarty']->value['section']['ac'])) unset($_smarty_tpl->tpl_vars['smarty']->value['section']['ac']);
$_smarty_tpl->tpl_vars['smarty']->value['section']['ac']['name'] = 'ac';
$_smarty_tpl->tpl_vars['smarty']->value['section']['ac']['loop'] = is_array($_loop=$_smarty_tpl->tpl_vars['cns']->value) ? count($_loop) : max(0, (int) $_loop); unset($_loop);
$_smarty_tpl->tpl_vars['smarty']->value['section']['ac']['show'] = true;
$_smarty_tpl->tpl_vars['smarty']->value['section']['ac']['max'] = $_smarty_tpl->tpl_vars['smarty']->value['section']['ac']['loop'];
$_smarty_tpl->tpl_vars['smarty']->value['section']['ac']['step'] = 1;
$_smarty_tpl->tpl_vars['smarty']->value['section']['ac']['start'] = $_smarty_tpl->tpl_vars['smarty']->value['section']['ac']['step'] > 0 ? 0 : $_smarty_tpl->tpl_vars['smarty']->value['section']['ac']['loop']-1;
if ($_smarty_tpl->tpl_vars['smarty']->value['section']['ac']['show']) {
    $_smarty_tpl->tpl_vars['smarty']->value['section']['ac']['total'] = $_smarty_tpl->tpl_vars['smarty']->value['section']['ac']['loop'];
    if ($_smarty_tpl->tpl_vars['smarty']->value['section']['ac']['total'] == 0)
        $_smarty_tpl->tpl_vars['smarty']->value['section']['ac']['show'] = false;
} else
    $_smarty_tpl->tpl_vars['smarty']->value['section']['ac']['total'] = 0;
if ($_smarty_tpl->tpl_vars['smarty']->value['section']['ac']['show']):

            for ($_smarty_tpl->tpl_vars['smarty']->value['section']['ac']['index'] = $_smarty_tpl->tpl_vars['smarty']->value['section']['ac']['start'], $_smarty_tpl->tpl_vars['smarty']->value['section']['ac']['iteration'] = 1;
                 $_smarty_tpl->tpl_vars['smarty']->value['section']['ac']['iteration'] <= $_smarty_tpl->tpl_vars['smarty']->value['section']['ac']['total'];
                 $_smarty_tpl->tpl_vars['smarty']->value['section']['ac']['index'] += $_smarty_tpl->tpl_vars['smarty']->value['section']['ac']['step'], $_smarty_tpl->tpl_vars['smarty']->value['section']['ac']['iteration']++):
$_smarty_tpl->tpl_vars['smarty']->value['section']['ac']['rownum'] = $_smarty_tpl->tpl_vars['smarty']->value['section']['ac']['iteration'];
$_smarty_tpl->tpl_vars['smarty']->value['section']['ac']['index_prev'] = $_smarty_tpl->tpl_vars['smarty']->value['section']['ac']['index'] - $_smarty_tpl->tpl_vars['smarty']->value['section']['ac']['step'];
$_smarty_tpl->tpl_vars['smarty']->value['section']['ac']['index_next'] = $_smarty_tpl->tpl_vars['smarty']->value['section']['ac']['index'] + $_smarty_tpl->tpl_vars['smarty']->value['section']['ac']['step'];
$_smarty_tpl->tpl_vars['smarty']->value['section']['ac']['first']      = ($_smarty_tpl->tpl_vars['smarty']->value['section']['ac']['iteration'] == 1);
$_smarty_tpl->tpl_vars['smarty']->value['section']['ac']['last']       = ($_smarty_tpl->tpl_vars['smarty']->value['section']['ac']['iteration'] == $_smarty_tpl->tpl_vars['smarty']->value['section']['ac']['total']);
?>
			<?php if ($_smarty_tpl->tpl_vars['cns']->value[$_smarty_tpl->getVariable('smarty')->value['section']['ac']['index']]['usercount'] > 0) {?>
			ddev.add(<?php echo $_smarty_tpl->getVariable('smarty')->value['section']['ac']['index']+1;?>
,0,'<input type="checkbox" id="<?php echo $_smarty_tpl->getVariable('smarty')->value['section']['ac']['index']+1;?>
" name="cn[]" value="" onclick="checkgroupa(this.checked,<?php echo $_smarty_tpl->getVariable('smarty')->value['section']['ac']['index']+1;?>
);"><?php echo $_smarty_tpl->tpl_vars['cns']->value[$_smarty_tpl->getVariable('smarty')->value['section']['ac']['index']]['name'];?>
(<?php echo $_smarty_tpl->tpl_vars['cns']->value[$_smarty_tpl->getVariable('smarty')->value['section']['ac']['index']]['usercount'];?>
)','javascript:ddev.getChildren(<?php echo $_smarty_tpl->getVariable('smarty')->value['section']['ac']['index']+1;?>
, \'\', \'\', \'<?php echo $_smarty_tpl->tpl_vars['cns']->value[$_smarty_tpl->getVariable('smarty')->value['section']['ac']['index']]['name'];?>
\', \'<?php echo $_smarty_tpl->tpl_vars['dn']->value;?>
\');','<?php echo $_smarty_tpl->tpl_vars['cns']->value[$_smarty_tpl->getVariable('smarty')->value['section']['ac']['index']]['name'];?>
',null,ddev.icon.folder);
			<?php }?>
		<?php endfor; endif; ?>
		<?php if (isset($_smarty_tpl->tpl_vars['smarty']->value['section']['ao'])) unset($_smarty_tpl->tpl_vars['smarty']->value['section']['ao']);
$_smarty_tpl->tpl_vars['smarty']->value['section']['ao']['name'] = 'ao';
$_smarty_tpl->tpl_vars['smarty']->value['section']['ao']['loop'] = is_array($_loop=$_smarty_tpl->tpl_vars['ous']->value) ? count($_loop) : max(0, (int) $_loop); unset($_loop);
$_smarty_tpl->tpl_vars['smarty']->value['section']['ao']['show'] = true;
$_smarty_tpl->tpl_vars['smarty']->value['section']['ao']['max'] = $_smarty_tpl->tpl_vars['smarty']->value['section']['ao']['loop'];
$_smarty_tpl->tpl_vars['smarty']->value['section']['ao']['step'] = 1;
$_smarty_tpl->tpl_vars['smarty']->value['section']['ao']['start'] = $_smarty_tpl->tpl_vars['smarty']->value['section']['ao']['step'] > 0 ? 0 : $_smarty_tpl->tpl_vars['smarty']->value['section']['ao']['loop']-1;
if ($_smarty_tpl->tpl_vars['smarty']->value['section']['ao']['show']) {
    $_smarty_tpl->tpl_vars['smarty']->value['section']['ao']['total'] = $_smarty_tpl->tpl_vars['smarty']->value['section']['ao']['loop'];
    if ($_smarty_tpl->tpl_vars['smarty']->value['section']['ao']['total'] == 0)
        $_smarty_tpl->tpl_vars['smarty']->value['section']['ao']['show'] = false;
} else
    $_smarty_tpl->tpl_vars['smarty']->value['section']['ao']['total'] = 0;
if ($_smarty_tpl->tpl_vars['smarty']->value['section']['ao']['show']):

            for ($_smarty_tpl->tpl_vars['smarty']->value['section']['ao']['index'] = $_smarty_tpl->tpl_vars['smarty']->value['section']['ao']['start'], $_smarty_tpl->tpl_vars['smarty']->value['section']['ao']['iteration'] = 1;
                 $_smarty_tpl->tpl_vars['smarty']->value['section']['ao']['iteration'] <= $_smarty_tpl->tpl_vars['smarty']->value['section']['ao']['total'];
                 $_smarty_tpl->tpl_vars['smarty']->value['section']['ao']['index'] += $_smarty_tpl->tpl_vars['smarty']->value['section']['ao']['step'], $_smarty_tpl->tpl_vars['smarty']->value['section']['ao']['iteration']++):
$_smarty_tpl->tpl_vars['smarty']->value['section']['ao']['rownum'] = $_smarty_tpl->tpl_vars['smarty']->value['section']['ao']['iteration'];
$_smarty_tpl->tpl_vars['smarty']->value['section']['ao']['index_prev'] = $_smarty_tpl->tpl_vars['smarty']->value['section']['ao']['index'] - $_smarty_tpl->tpl_vars['smarty']->value['section']['ao']['step'];
$_smarty_tpl->tpl_vars['smarty']->value['section']['ao']['index_next'] = $_smarty_tpl->tpl_vars['smarty']->value['section']['ao']['index'] + $_smarty_tpl->tpl_vars['smarty']->value['section']['ao']['step'];
$_smarty_tpl->tpl_vars['smarty']->value['section']['ao']['first']      = ($_smarty_tpl->tpl_vars['smarty']->value['section']['ao']['iteration'] == 1);
$_smarty_tpl->tpl_vars['smarty']->value['section']['ao']['last']       = ($_smarty_tpl->tpl_vars['smarty']->value['section']['ao']['iteration'] == $_smarty_tpl->tpl_vars['smarty']->value['section']['ao']['total']);
?>
			<?php if ($_smarty_tpl->tpl_vars['ous']->value[$_smarty_tpl->getVariable('smarty')->value['section']['ao']['index']]['usercount'] > 0) {?>
			ddev.add(<?php echo $_smarty_tpl->getVariable('smarty')->value['section']['ac']['index']+1;
echo $_smarty_tpl->getVariable('smarty')->value['section']['ao']['index']+1;?>
,0,'<input type="checkbox" id="<?php echo $_smarty_tpl->getVariable('smarty')->value['section']['ac']['index']+1;
echo $_smarty_tpl->getVariable('smarty')->value['section']['ao']['index']+1;?>
" name="group[]" value="" onclick="checkgroupa(this.checked,<?php echo $_smarty_tpl->getVariable('smarty')->value['section']['ac']['index']+1;
echo $_smarty_tpl->getVariable('smarty')->value['section']['ao']['index']+1;?>
);"><?php echo $_smarty_tpl->tpl_vars['ous']->value[$_smarty_tpl->getVariable('smarty')->value['section']['ao']['index']]['name'];?>
(<?php echo $_smarty_tpl->tpl_vars['ous']->value[$_smarty_tpl->getVariable('smarty')->value['section']['ao']['index']]['usercount'];?>
)','javascript:ddev.getChildren(<?php echo $_smarty_tpl->getVariable('smarty')->value['section']['ac']['index']+1;
echo $_smarty_tpl->getVariable('smarty')->value['section']['ao']['index']+1;?>
, \'\', \'<?php echo $_smarty_tpl->tpl_vars['ous']->value[$_smarty_tpl->getVariable('smarty')->value['section']['ao']['index']]['name'];?>
\', \'\', \'<?php echo $_smarty_tpl->tpl_vars['dn']->value;?>
\');','<?php echo $_smarty_tpl->tpl_vars['ous']->value[$_smarty_tpl->getVariable('smarty')->value['section']['ao']['index']]['name'];?>
',null,ddev.icon.folder);
			<?php }?>
		<?php endfor; endif; ?>
		<?php if (isset($_smarty_tpl->tpl_vars['smarty']->value['section']['ag'])) unset($_smarty_tpl->tpl_vars['smarty']->value['section']['ag']);
$_smarty_tpl->tpl_vars['smarty']->value['section']['ag']['name'] = 'ag';
$_smarty_tpl->tpl_vars['smarty']->value['section']['ag']['loop'] = is_array($_loop=$_smarty_tpl->tpl_vars['groups']->value) ? count($_loop) : max(0, (int) $_loop); unset($_loop);
$_smarty_tpl->tpl_vars['smarty']->value['section']['ag']['show'] = true;
$_smarty_tpl->tpl_vars['smarty']->value['section']['ag']['max'] = $_smarty_tpl->tpl_vars['smarty']->value['section']['ag']['loop'];
$_smarty_tpl->tpl_vars['smarty']->value['section']['ag']['step'] = 1;
$_smarty_tpl->tpl_vars['smarty']->value['section']['ag']['start'] = $_smarty_tpl->tpl_vars['smarty']->value['section']['ag']['step'] > 0 ? 0 : $_smarty_tpl->tpl_vars['smarty']->value['section']['ag']['loop']-1;
if ($_smarty_tpl->tpl_vars['smarty']->value['section']['ag']['show']) {
    $_smarty_tpl->tpl_vars['smarty']->value['section']['ag']['total'] = $_smarty_tpl->tpl_vars['smarty']->value['section']['ag']['loop'];
    if ($_smarty_tpl->tpl_vars['smarty']->value['section']['ag']['total'] == 0)
        $_smarty_tpl->tpl_vars['smarty']->value['section']['ag']['show'] = false;
} else
    $_smarty_tpl->tpl_vars['smarty']->value['section']['ag']['total'] = 0;
if ($_smarty_tpl->tpl_vars['smarty']->value['section']['ag']['show']):

            for ($_smarty_tpl->tpl_vars['smarty']->value['section']['ag']['index'] = $_smarty_tpl->tpl_vars['smarty']->value['section']['ag']['start'], $_smarty_tpl->tpl_vars['smarty']->value['section']['ag']['iteration'] = 1;
                 $_smarty_tpl->tpl_vars['smarty']->value['section']['ag']['iteration'] <= $_smarty_tpl->tpl_vars['smarty']->value['section']['ag']['total'];
                 $_smarty_tpl->tpl_vars['smarty']->value['section']['ag']['index'] += $_smarty_tpl->tpl_vars['smarty']->value['section']['ag']['step'], $_smarty_tpl->tpl_vars['smarty']->value['section']['ag']['iteration']++):
$_smarty_tpl->tpl_vars['smarty']->value['section']['ag']['rownum'] = $_smarty_tpl->tpl_vars['smarty']->value['section']['ag']['iteration'];
$_smarty_tpl->tpl_vars['smarty']->value['section']['ag']['index_prev'] = $_smarty_tpl->tpl_vars['smarty']->value['section']['ag']['index'] - $_smarty_tpl->tpl_vars['smarty']->value['section']['ag']['step'];
$_smarty_tpl->tpl_vars['smarty']->value['section']['ag']['index_next'] = $_smarty_tpl->tpl_vars['smarty']->value['section']['ag']['index'] + $_smarty_tpl->tpl_vars['smarty']->value['section']['ag']['step'];
$_smarty_tpl->tpl_vars['smarty']->value['section']['ag']['first']      = ($_smarty_tpl->tpl_vars['smarty']->value['section']['ag']['iteration'] == 1);
$_smarty_tpl->tpl_vars['smarty']->value['section']['ag']['last']       = ($_smarty_tpl->tpl_vars['smarty']->value['section']['ag']['iteration'] == $_smarty_tpl->tpl_vars['smarty']->value['section']['ag']['total']);
?>
			<?php if ($_smarty_tpl->tpl_vars['groups']->value[$_smarty_tpl->getVariable('smarty')->value['section']['ag']['index']]['usercount'] > 0) {?>
			ddev.add(<?php echo $_smarty_tpl->getVariable('smarty')->value['section']['ac']['index']+1;
echo $_smarty_tpl->getVariable('smarty')->value['section']['ao']['index']+1;
echo $_smarty_tpl->getVariable('smarty')->value['section']['ag']['index']+1;?>
,0,'<input type="checkbox" id="<?php echo $_smarty_tpl->getVariable('smarty')->value['section']['ao']['index']+1;
echo $_smarty_tpl->getVariable('smarty')->value['section']['ag']['index']+1;?>
" name="group[]" value="" onclick="ddev.o(<?php echo $_smarty_tpl->getVariable('smarty')->value['section']['ao']['index']+1;
echo $_smarty_tpl->getVariable('smarty')->value['section']['ag']['index']+1;?>
);checkgroupa(this.checked,<?php echo $_smarty_tpl->getVariable('smarty')->value['section']['ac']['index']+1;
echo $_smarty_tpl->getVariable('smarty')->value['section']['ao']['index']+1;
echo $_smarty_tpl->getVariable('smarty')->value['section']['ag']['index']+1;?>
);"><?php echo $_smarty_tpl->tpl_vars['groups']->value[$_smarty_tpl->getVariable('smarty')->value['section']['ag']['index']]['groupname'];?>
(<?php echo $_smarty_tpl->tpl_vars['groups']->value[$_smarty_tpl->getVariable('smarty')->value['section']['ag']['index']]['usercount'];?>
)','javascript:ddev.getChildren(<?php echo $_smarty_tpl->getVariable('smarty')->value['section']['ac']['index']+1;
echo $_smarty_tpl->getVariable('smarty')->value['section']['ao']['index']+1;
echo $_smarty_tpl->getVariable('smarty')->value['section']['ag']['index']+1;?>
, \'<?php echo $_smarty_tpl->tpl_vars['groups']->value[$_smarty_tpl->getVariable('smarty')->value['section']['ag']['index']]['groupname'];?>
\', \'\',\'\', \'<?php echo $_smarty_tpl->tpl_vars['dn']->value;?>
\');','<?php echo $_smarty_tpl->tpl_vars['groups']->value[$_smarty_tpl->getVariable('smarty')->value['section']['ag']['index']]['groupname'];?>
',null,ddev.icon.folder);
			<?php }?>
		<?php endfor; endif; ?>
		<?php if (isset($_smarty_tpl->tpl_vars['smarty']->value['section']['nu'])) unset($_smarty_tpl->tpl_vars['smarty']->value['section']['nu']);
$_smarty_tpl->tpl_vars['smarty']->value['section']['nu']['name'] = 'nu';
$_smarty_tpl->tpl_vars['smarty']->value['section']['nu']['loop'] = is_array($_loop=$_smarty_tpl->tpl_vars['nogroupusers']->value) ? count($_loop) : max(0, (int) $_loop); unset($_loop);
$_smarty_tpl->tpl_vars['smarty']->value['section']['nu']['show'] = true;
$_smarty_tpl->tpl_vars['smarty']->value['section']['nu']['max'] = $_smarty_tpl->tpl_vars['smarty']->value['section']['nu']['loop'];
$_smarty_tpl->tpl_vars['smarty']->value['section']['nu']['step'] = 1;
$_smarty_tpl->tpl_vars['smarty']->value['section']['nu']['start'] = $_smarty_tpl->tpl_vars['smarty']->value['section']['nu']['step'] > 0 ? 0 : $_smarty_tpl->tpl_vars['smarty']->value['section']['nu']['loop']-1;
if ($_smarty_tpl->tpl_vars['smarty']->value['section']['nu']['show']) {
    $_smarty_tpl->tpl_vars['smarty']->value['section']['nu']['total'] = $_smarty_tpl->tpl_vars['smarty']->value['section']['nu']['loop'];
    if ($_smarty_tpl->tpl_vars['smarty']->value['section']['nu']['total'] == 0)
        $_smarty_tpl->tpl_vars['smarty']->value['section']['nu']['show'] = false;
} else
    $_smarty_tpl->tpl_vars['smarty']->value['section']['nu']['total'] = 0;
if ($_smarty_tpl->tpl_vars['smarty']->value['section']['nu']['show']):

            for ($_smarty_tpl->tpl_vars['smarty']->value['section']['nu']['index'] = $_smarty_tpl->tpl_vars['smarty']->value['section']['nu']['start'], $_smarty_tpl->tpl_vars['smarty']->value['section']['nu']['iteration'] = 1;
                 $_smarty_tpl->tpl_vars['smarty']->value['section']['nu']['iteration'] <= $_smarty_tpl->tpl_vars['smarty']->value['section']['nu']['total'];
                 $_smarty_tpl->tpl_vars['smarty']->value['section']['nu']['index'] += $_smarty_tpl->tpl_vars['smarty']->value['section']['nu']['step'], $_smarty_tpl->tpl_vars['smarty']->value['section']['nu']['iteration']++):
$_smarty_tpl->tpl_vars['smarty']->value['section']['nu']['rownum'] = $_smarty_tpl->tpl_vars['smarty']->value['section']['nu']['iteration'];
$_smarty_tpl->tpl_vars['smarty']->value['section']['nu']['index_prev'] = $_smarty_tpl->tpl_vars['smarty']->value['section']['nu']['index'] - $_smarty_tpl->tpl_vars['smarty']->value['section']['nu']['step'];
$_smarty_tpl->tpl_vars['smarty']->value['section']['nu']['index_next'] = $_smarty_tpl->tpl_vars['smarty']->value['section']['nu']['index'] + $_smarty_tpl->tpl_vars['smarty']->value['section']['nu']['step'];
$_smarty_tpl->tpl_vars['smarty']->value['section']['nu']['first']      = ($_smarty_tpl->tpl_vars['smarty']->value['section']['nu']['iteration'] == 1);
$_smarty_tpl->tpl_vars['smarty']->value['section']['nu']['last']       = ($_smarty_tpl->tpl_vars['smarty']->value['section']['nu']['iteration'] == $_smarty_tpl->tpl_vars['smarty']->value['section']['nu']['total']);
?>
			ddev.add(<?php echo $_smarty_tpl->getVariable('smarty')->value['section']['ac']['index']+1;
echo $_smarty_tpl->getVariable('smarty')->value['section']['ao']['index']+1;
echo $_smarty_tpl->getVariable('smarty')->value['section']['ag']['index']+1;
echo $_smarty_tpl->getVariable('smarty')->value['section']['nu']['index'];?>
,0,'<input type="checkbox" name="username[]" value="<?php echo $_smarty_tpl->tpl_vars['nogroupusers']->value[$_smarty_tpl->getVariable('smarty')->value['section']['nu']['index']]['username'];
if ($_smarty_tpl->tpl_vars['nogroupusers']->value[$_smarty_tpl->getVariable('smarty')->value['section']['nu']['index']]['ingroup']) {?>|<?php echo $_smarty_tpl->tpl_vars['nogroupusers']->value[$_smarty_tpl->getVariable('smarty')->value['section']['nu']['index']]['dn'];
}?>" ><?php echo $_smarty_tpl->tpl_vars['nogroupusers']->value[$_smarty_tpl->getVariable('smarty')->value['section']['nu']['index']]['username'];?>
','#','<?php echo $_smarty_tpl->tpl_vars['nogroupusers']->value[$_smarty_tpl->getVariable('smarty')->value['section']['nu']['index']]['username'];?>
');
		<?php endfor; endif; ?>
		ddev.show();	
		ddev.s(0);
	<?php echo '</script'; ?>
>
</div>
					</TD>
                  </TR>	
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
<?php $_smarty_tpl->tpl_vars['popsize'] = new Smarty_Variable(100, null, 0);?>
<?php $_smarty_tpl->tpl_vars['direction'] = new Smarty_Variable('up', null, 0);?>
                  <TR>
                    <TD colspan="2" align="left">密码<input type='password' name='password' class="input_shorttext" />&nbsp;<?php echo $_smarty_tpl->getSubTemplate ("select_sgroup_ajax.tpl", $_smarty_tpl->cache_id, $_smarty_tpl->compile_id, 0, $_smarty_tpl->cache_lifetime, array(), 0);
?>
&nbsp;&nbsp;<input type="checkbox" name="radiusauth" class="" value="1" <?php if ($_smarty_tpl->tpl_vars['member']->value['radiusauth']) {?>checked<?php }?>>RADIUS证&nbsp;&nbsp;<input type="checkbox" name="adauth" class="" value="1" checked>AD认证&nbsp;&nbsp;&nbsp;<INPUT class="an_02" type="submit" value="保存修改"></TD>
                  </TR>
                </TBODY>
              </TABLE>
			  <input type="hidden" name="step" value="2" />
</FORM>
<?php }?>
</body>
<iframe name="hide" height="0" frameborder="0" scrolling="no"></iframe>
</html>



<?php }
}
?>