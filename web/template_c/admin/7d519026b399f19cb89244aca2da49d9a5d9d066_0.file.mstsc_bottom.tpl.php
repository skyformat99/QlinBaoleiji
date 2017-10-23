<?php /* Smarty version 3.1.27, created on 2017-08-11 12:21:59
         compiled from "/opt/freesvr/web/htdocs/freesvr/audit/template/admin/mstsc_bottom.tpl" */ ?>
<?php
/*%%SmartyHeaderCode:1284560291598d30e738ac88_33088367%%*/
if(!defined('SMARTY_DIR')) exit('no direct access allowed');
$_valid = $_smarty_tpl->decodeProperties(array (
  'file_dependency' => 
  array (
    '7d519026b399f19cb89244aca2da49d9a5d9d066' => 
    array (
      0 => '/opt/freesvr/web/htdocs/freesvr/audit/template/admin/mstsc_bottom.tpl',
      1 => 1474793221,
      2 => 'file',
    ),
  ),
  'nocache_hash' => '1284560291598d30e738ac88_33088367',
  'variables' => 
  array (
    'logindebug' => 0,
    'member' => 0,
  ),
  'has_nocache_code' => false,
  'version' => '3.1.27',
  'unifunc' => 'content_598d30e73c5ad3_48765363',
),false);
/*/%%SmartyHeaderCode%%*/
if ($_valid && !is_callable('content_598d30e73c5ad3_48765363')) {
function content_598d30e73c5ad3_48765363 ($_smarty_tpl) {

$_smarty_tpl->properties['nocache_hash'] = '1284560291598d30e738ac88_33088367';
?>
<?php echo '<script'; ?>
 language="javascript">
function go(url,iid){
	var app_act = document.getElementById('app_act').options[document.getElementById('app_act').options.selectedIndex].value;
	var hid = document.getElementById('hide');
	document.getElementById(iid).href=url+'&app_act='+app_act;
	//alert(hid.src);
	<?php if ($_smarty_tpl->tpl_vars['logindebug']->value) {?>
	window.open(document.getElementById(iid).href);
	<?php }?>
	return true;
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
<iframe id="hide" name="hide" height="0" frameborder="0" scrolling="no"></iframe>


<?php }
}
?>