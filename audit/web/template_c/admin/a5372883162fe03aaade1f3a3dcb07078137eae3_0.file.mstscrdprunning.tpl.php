<?php /* Smarty version 3.1.27, created on 2017-07-30 09:49:53
         compiled from "/opt/freesvr/web/htdocs/freesvr/audit/template/admin/mstscrdprunning.tpl" */ ?>
<?php
/*%%SmartyHeaderCode:716673294597d3b413dc630_50916991%%*/
if(!defined('SMARTY_DIR')) exit('no direct access allowed');
$_valid = $_smarty_tpl->decodeProperties(array (
  'file_dependency' => 
  array (
    'a5372883162fe03aaade1f3a3dcb07078137eae3' => 
    array (
      0 => '/opt/freesvr/web/htdocs/freesvr/audit/template/admin/mstscrdprunning.tpl',
      1 => 1499420332,
      2 => 'file',
    ),
  ),
  'nocache_hash' => '716673294597d3b413dc630_50916991',
  'variables' => 
  array (
    'session' => 0,
    'sid' => 0,
    'vpnip' => 0,
    'password' => 0,
  ),
  'has_nocache_code' => false,
  'version' => '3.1.27',
  'unifunc' => 'content_597d3b41416a81_21876456',
),false);
/*/%%SmartyHeaderCode%%*/
if ($_valid && !is_callable('content_597d3b41416a81_21876456')) {
function content_597d3b41416a81_21876456 ($_smarty_tpl) {

$_smarty_tpl->properties['nocache_hash'] = '716673294597d3b413dc630_50916991';
if ($_SESSION['urlprotocol'] == 1) {?>baoleiji<?php } else { ?>freesvr<?php }?>://"&action=StartMstscMonitor&host=<?php echo $_smarty_tpl->tpl_vars['session']->value['proxy_addr'];?>
&port=3391&username=<?php echo $_smarty_tpl->tpl_vars['sid']->value;?>
&bpp=<?php echo $_smarty_tpl->tpl_vars['session']->value['bpp'];?>
&vpnip=<?php echo $_smarty_tpl->tpl_vars['vpnip']->value;?>
&window_size=<?php echo $_smarty_tpl->tpl_vars['session']->value['window_size'];?>
&password=<?php echo $_smarty_tpl->tpl_vars['password']->value;?>
&debug=<?php echo $_SESSION['ADMIN_FREESVRDEBUG'];?>
&"<?php }
}
?>