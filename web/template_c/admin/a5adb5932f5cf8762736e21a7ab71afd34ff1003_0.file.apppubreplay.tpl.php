<?php /* Smarty version 3.1.27, created on 2017-07-19 13:31:16
         compiled from "/opt/freesvr/web/htdocs/freesvr/audit/template/admin/apppubreplay.tpl" */ ?>
<?php
/*%%SmartyHeaderCode:1064367448596eeea40a5fc6_14627051%%*/
if(!defined('SMARTY_DIR')) exit('no direct access allowed');
$_valid = $_smarty_tpl->decodeProperties(array (
  'file_dependency' => 
  array (
    'a5adb5932f5cf8762736e21a7ab71afd34ff1003' => 
    array (
      0 => '/opt/freesvr/web/htdocs/freesvr/audit/template/admin/apppubreplay.tpl',
      1 => 1499420335,
      2 => 'file',
    ),
  ),
  'nocache_hash' => '1064367448596eeea40a5fc6_14627051',
  'variables' => 
  array (
    'autorun' => 0,
    'host' => 0,
    'port' => 0,
    'username' => 0,
    'password' => 0,
    'path' => 0,
    'param' => 0,
    'disconnectsecouldapp' => 0,
  ),
  'has_nocache_code' => false,
  'version' => '3.1.27',
  'unifunc' => 'content_596eeea40e4097_99556501',
),false);
/*/%%SmartyHeaderCode%%*/
if ($_valid && !is_callable('content_596eeea40e4097_99556501')) {
function content_596eeea40e4097_99556501 ($_smarty_tpl) {

$_smarty_tpl->properties['nocache_hash'] = '1064367448596eeea40a5fc6_14627051';
if ($_SESSION['urlprotocol'] == 1) {?>baoleiji<?php } else { ?>freesvr<?php }?>://"&action=StartMstscAutoRunReplay&autorun=<?php echo $_smarty_tpl->tpl_vars['autorun']->value;?>
&host=<?php echo $_smarty_tpl->tpl_vars['host']->value;?>
&port=<?php echo $_smarty_tpl->tpl_vars['port']->value;?>
&username=<?php echo $_smarty_tpl->tpl_vars['username']->value;?>
&password=<?php echo $_smarty_tpl->tpl_vars['password']->value;?>
&path=<?php echo $_smarty_tpl->tpl_vars['path']->value;?>
&param=<?php echo $_smarty_tpl->tpl_vars['param']->value;?>
&disconnectsecouldapp=<?php echo $_smarty_tpl->tpl_vars['disconnectsecouldapp']->value;?>
&debug=<?php echo $_SESSION['ADMIN_FREESVRDEBUG'];?>
&"<?php }
}
?>