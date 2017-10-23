<?php /* Smarty version 3.1.27, created on 2017-08-01 17:46:51
         compiled from "/opt/freesvr/web/htdocs/freesvr/audit/template/admin/replay.tpl" */ ?>
<?php
/*%%SmartyHeaderCode:40031887159804e0ba9fc76_90885759%%*/
if(!defined('SMARTY_DIR')) exit('no direct access allowed');
$_valid = $_smarty_tpl->decodeProperties(array (
  'file_dependency' => 
  array (
    '35273443941ad0f649556c1ce464af5d81f3bc1b' => 
    array (
      0 => '/opt/freesvr/web/htdocs/freesvr/audit/template/admin/replay.tpl',
      1 => 1501580808,
      2 => 'file',
    ),
  ),
  'nocache_hash' => '40031887159804e0ba9fc76_90885759',
  'variables' => 
  array (
    'tool' => 0,
    'proxy_addr' => 0,
    'member' => 0,
    's' => 0,
    'random' => 0,
    'sid' => 0,
    'cid' => 0,
    'showdomain' => 0,
    'hostname' => 0,
  ),
  'has_nocache_code' => false,
  'version' => '3.1.27',
  'unifunc' => 'content_59804e0baf3cb5_02620880',
),false);
/*/%%SmartyHeaderCode%%*/
if ($_valid && !is_callable('content_59804e0baf3cb5_02620880')) {
function content_59804e0baf3cb5_02620880 ($_smarty_tpl) {

$_smarty_tpl->properties['nocache_hash'] = '40031887159804e0ba9fc76_90885759';
if ($_SESSION['urlprotocol'] == 1) {?>baoleiji<?php } else { ?>freesvr<?php }?>://"&action=<?php if ($_smarty_tpl->tpl_vars['tool']->value == 'putty.Putty') {?>StartPuttyDisplay<?php } elseif ($_smarty_tpl->tpl_vars['tool']->value == 'xshell.Xshell') {?>StartXshellDisplay<?php } else { ?>StartSecureCRTDisplay<?php }?>&host=<?php echo $_smarty_tpl->tpl_vars['proxy_addr']->value;?>
&monitorport=<?php if ($_smarty_tpl->tpl_vars['member']->value['sshport']) {
echo $_smarty_tpl->tpl_vars['member']->value['sshport'];
} else { ?>22<?php }?>&monitoruser=<?php echo $_smarty_tpl->tpl_vars['s']->value['luser'];?>
--monitor1&monitorpassword=<?php echo $_smarty_tpl->tpl_vars['random']->value;?>
&sid=<?php echo $_smarty_tpl->tpl_vars['sid']->value;?>
&cid=<?php echo $_smarty_tpl->tpl_vars['cid']->value;?>
--<?php echo $_smarty_tpl->tpl_vars['random']->value;?>
&proxy_addr=<?php echo $_smarty_tpl->tpl_vars['proxy_addr']->value;?>
&debug=<?php echo $_SESSION['ADMIN_FREESVRDEBUG'];?>
&showdomain=<?php echo $_smarty_tpl->tpl_vars['showdomain']->value;?>
&hostname=<?php echo urlencode($_smarty_tpl->tpl_vars['hostname']->value);?>
&"<?php }
}
?>