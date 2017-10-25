<?php /* Smarty version 3.1.27, created on 2017-07-10 09:38:58
         compiled from "/opt/freesvr/web/htdocs/freesvr/audit/template/admin/WebSysbaseOraclelogin_mstsc.tpl" */ ?>
<?php
/*%%SmartyHeaderCode:11136488785962dab263b983_96968751%%*/
if(!defined('SMARTY_DIR')) exit('no direct access allowed');
$_valid = $_smarty_tpl->decodeProperties(array (
  'file_dependency' => 
  array (
    '4ada68ce81d2bef9017f2242239d4e0c79bba2b8' => 
    array (
      0 => '/opt/freesvr/web/htdocs/freesvr/audit/template/admin/WebSysbaseOraclelogin_mstsc.tpl',
      1 => 1499420329,
      2 => 'file',
    ),
  ),
  'nocache_hash' => '11136488785962dab263b983_96968751',
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
    'member' => 0,
    'showdomain' => 0,
    'hostname' => 0,
    'rdpclientversion' => 0,
  ),
  'has_nocache_code' => false,
  'version' => '3.1.27',
  'unifunc' => 'content_5962dab26a4725_70572469',
),false);
/*/%%SmartyHeaderCode%%*/
if ($_valid && !is_callable('content_5962dab26a4725_70572469')) {
function content_5962dab26a4725_70572469 ($_smarty_tpl) {

$_smarty_tpl->properties['nocache_hash'] = '11136488785962dab263b983_96968751';
if ($_SESSION['urlprotocol'] == 1) {?>baoleiji<?php } else { ?>freesvr<?php }?>://\"&action=StartMstscAutoRun&autorun=<?php echo $_smarty_tpl->tpl_vars['autorun']->value;?>
&host=<?php echo $_smarty_tpl->tpl_vars['host']->value;?>
&port=<?php echo $_smarty_tpl->tpl_vars['port']->value;?>
&username=<?php echo $_smarty_tpl->tpl_vars['username']->value;?>
&password=<?php echo $_smarty_tpl->tpl_vars['password']->value;?>
&path=<?php echo $_smarty_tpl->tpl_vars['path']->value;?>
&param=<?php echo $_smarty_tpl->tpl_vars['param']->value;?>
&disconnectsecouldapp=<?php echo $_smarty_tpl->tpl_vars['disconnectsecouldapp']->value;?>
&&debug=<?php echo $_SESSION['ADMIN_FREESVRDEBUG'];?>
&sshport=<?php echo $_smarty_tpl->tpl_vars['member']->value['sshport'];?>
&rdpport=<?php echo $_smarty_tpl->tpl_vars['member']->value['rdpport'];?>
&showdomain=<?php echo $_smarty_tpl->tpl_vars['showdomain']->value;?>
&hostname=<?php echo urlencode($_smarty_tpl->tpl_vars['hostname']->value);?>
&rdpclientversion=<?php echo $_smarty_tpl->tpl_vars['rdpclientversion']->value;?>
&\"


<?php }
}
?>