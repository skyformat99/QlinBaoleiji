<?php /* Smarty version 3.1.27, created on 2017-07-19 14:06:56
         compiled from "/opt/freesvr/web/htdocs/freesvr/audit/template/admin/mstsc.tpl" */ ?>
<?php
/*%%SmartyHeaderCode:228999477596ef7002341d0_76007707%%*/
if(!defined('SMARTY_DIR')) exit('no direct access allowed');
$_valid = $_smarty_tpl->decodeProperties(array (
  'file_dependency' => 
  array (
    '65362400bb8221bc78bb3b78a1198b8233d7a938' => 
    array (
      0 => '/opt/freesvr/web/htdocs/freesvr/audit/template/admin/mstsc.tpl',
      1 => 1499420332,
      2 => 'file',
    ),
  ),
  'nocache_hash' => '228999477596ef7002341d0_76007707',
  'variables' => 
  array (
    'session' => 0,
    'sid' => 0,
    'stime' => 0,
    'rdpclientversion' => 0,
  ),
  'has_nocache_code' => false,
  'version' => '3.1.27',
  'unifunc' => 'content_596ef7002756d7_74964612',
),false);
/*/%%SmartyHeaderCode%%*/
if ($_valid && !is_callable('content_596ef7002756d7_74964612')) {
function content_596ef7002756d7_74964612 ($_smarty_tpl) {

$_smarty_tpl->properties['nocache_hash'] = '228999477596ef7002341d0_76007707';
if ($_SESSION['urlprotocol'] == 1) {?>baoleiji<?php } else { ?>freesvr<?php }?>://"&action=StartRdpReplay&host=<?php echo $_smarty_tpl->tpl_vars['session']->value['proxy_addr'];?>
&port=3390&username=<?php echo $_smarty_tpl->tpl_vars['sid']->value;?>
&window_size=<?php echo $_smarty_tpl->tpl_vars['session']->value['window_size'];?>
&bpp=<?php echo $_smarty_tpl->tpl_vars['session']->value['bpp'];?>
&cport=8888<?php if ($_smarty_tpl->tpl_vars['stime']->value) {?>&stime=<?php echo $_smarty_tpl->tpl_vars['stime']->value;
}?>&debug=<?php echo $_SESSION['ADMIN_FREESVRDEBUG'];?>
&rdpclientversion=<?php echo $_smarty_tpl->tpl_vars['rdpclientversion']->value;?>
&"<?php }
}
?>