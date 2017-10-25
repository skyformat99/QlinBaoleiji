<?php /* Smarty version 3.1.27, created on 2017-07-08 10:33:18
         compiled from "/opt/freesvr/web/htdocs/freesvr/audit/template/admin/rdplogin_mstsc.tpl" */ ?>
<?php
/*%%SmartyHeaderCode:21122907435960446edd5a29_59726759%%*/
if(!defined('SMARTY_DIR')) exit('no direct access allowed');
$_valid = $_smarty_tpl->decodeProperties(array (
  'file_dependency' => 
  array (
    '2b5e370cb1819adc4c14d0df2a7a71576a1704c5' => 
    array (
      0 => '/opt/freesvr/web/htdocs/freesvr/audit/template/admin/rdplogin_mstsc.tpl',
      1 => 1499420332,
      2 => 'file',
    ),
  ),
  'nocache_hash' => '21122907435960446edd5a29_59726759',
  'variables' => 
  array (
    'ip' => 0,
    'port' => 0,
    'dusername' => 0,
    'username' => 0,
    'password' => 0,
    'dynamic_pwd' => 0,
    'entrust_password' => 0,
    'localhost' => 0,
    'screen' => 0,
    'console' => 0,
    'rdpclipauth_up' => 0,
    'rdpdiskauth_up' => 0,
    'member' => 0,
    'sid' => 0,
    'showdomain' => 0,
    'hostname' => 0,
  ),
  'has_nocache_code' => false,
  'version' => '3.1.27',
  'unifunc' => 'content_5960446ee207c5_08404855',
),false);
/*/%%SmartyHeaderCode%%*/
if ($_valid && !is_callable('content_5960446ee207c5_08404855')) {
function content_5960446ee207c5_08404855 ($_smarty_tpl) {

$_smarty_tpl->properties['nocache_hash'] = '21122907435960446edd5a29_59726759';
if ($_SESSION['urlprotocol'] == 1) {?>baoleiji<?php } else { ?>freesvr<?php }?>://\"&action=StartMstsc&host=<?php echo $_smarty_tpl->tpl_vars['ip']->value;?>
&port=<?php echo $_smarty_tpl->tpl_vars['port']->value;?>
&target_username=<?php echo $_smarty_tpl->tpl_vars['dusername']->value;?>
&target_ip=<?php echo $_smarty_tpl->tpl_vars['ip']->value;?>
&bpp=16&username=<?php echo $_smarty_tpl->tpl_vars['username']->value;?>
&password=<?php echo $_smarty_tpl->tpl_vars['password']->value;
echo $_smarty_tpl->tpl_vars['dynamic_pwd']->value;?>
&entrust_password=<?php echo $_smarty_tpl->tpl_vars['entrust_password']->value;?>
&localhost=<?php echo $_smarty_tpl->tpl_vars['localhost']->value;?>
&screen=<?php echo $_smarty_tpl->tpl_vars['screen']->value;
if ($_smarty_tpl->tpl_vars['console']->value == 'TRUE') {?>&rdparg=admin<?php }
if ($_smarty_tpl->tpl_vars['rdpclipauth_up']->value) {?>&clipboard=1<?php } else { ?>&clipboard=0<?php }?>&disk=<?php if ($_smarty_tpl->tpl_vars['rdpdiskauth_up']->value) {
echo $_smarty_tpl->tpl_vars['member']->value['rdpdisk'];
}?>&sid=<?php echo $_smarty_tpl->tpl_vars['sid']->value;?>
&sshport=<?php echo $_smarty_tpl->tpl_vars['member']->value['sshport'];?>
&rdpport=<?php echo $_smarty_tpl->tpl_vars['member']->value['rdpport'];?>
&showdomain=<?php echo $_smarty_tpl->tpl_vars['showdomain']->value;?>
&hostname=<?php echo urlencode($_smarty_tpl->tpl_vars['hostname']->value);?>
&\"<?php }
}
?>