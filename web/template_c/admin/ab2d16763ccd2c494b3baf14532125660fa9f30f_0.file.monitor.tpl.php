<?php /* Smarty version 3.1.27, created on 2017-08-01 17:48:42
         compiled from "/opt/freesvr/web/htdocs/freesvr/audit/template/admin/monitor.tpl" */ ?>
<?php
/*%%SmartyHeaderCode:63141366759804e7a875dd3_35475466%%*/
if(!defined('SMARTY_DIR')) exit('no direct access allowed');
$_valid = $_smarty_tpl->decodeProperties(array (
  'file_dependency' => 
  array (
    'ab2d16763ccd2c494b3baf14532125660fa9f30f' => 
    array (
      0 => '/opt/freesvr/web/htdocs/freesvr/audit/template/admin/monitor.tpl',
      1 => 1501580891,
      2 => 'file',
    ),
  ),
  'nocache_hash' => '63141366759804e7a875dd3_35475466',
  'variables' => 
  array (
    'tool' => 0,
    's' => 0,
    'member' => 0,
    'luser' => 0,
    'sid' => 0,
    'cid' => 0,
    'random' => 0,
    'showdomain' => 0,
    'hostname' => 0,
  ),
  'has_nocache_code' => false,
  'version' => '3.1.27',
  'unifunc' => 'content_59804e7a8bf445_59156496',
),false);
/*/%%SmartyHeaderCode%%*/
if ($_valid && !is_callable('content_59804e7a8bf445_59156496')) {
function content_59804e7a8bf445_59156496 ($_smarty_tpl) {

$_smarty_tpl->properties['nocache_hash'] = '63141366759804e7a875dd3_35475466';
if ($_SESSION['urlprotocol'] == 1) {?>baoleiji<?php } else { ?>freesvr<?php }?>://"&action=<?php if ($_smarty_tpl->tpl_vars['tool']->value == 'putty.Putty') {?>StartPuttyMonitor<?php } elseif ($_smarty_tpl->tpl_vars['tool']->value == 'xshell.Xshell') {?>StartXshellMonitor<?php } else { ?>StartSecureCRTMonitor<?php }?>&putty_path=c:\\freesvr\\ssh\\putty.exe&host=<?php echo $_smarty_tpl->tpl_vars['s']->value['host'];?>
&monitorport=<?php if ($_smarty_tpl->tpl_vars['member']->value['sshport']) {
echo $_smarty_tpl->tpl_vars['member']->value['sshport'];
} else { ?>22<?php }?>&monitoruser=<?php echo $_smarty_tpl->tpl_vars['luser']->value;?>
--monitor&monitorpassword=freesvr&sid=-<?php echo $_smarty_tpl->tpl_vars['sid']->value;?>
-&cid=<?php echo $_smarty_tpl->tpl_vars['cid']->value;?>
--<?php echo $_smarty_tpl->tpl_vars['random']->value;?>
&proxy_addr=<?php echo $_smarty_tpl->tpl_vars['s']->value['host'];?>
&debug=<?php echo $_SESSION['ADMIN_FREESVRDEBUG'];?>
&showdomain=<?php echo $_smarty_tpl->tpl_vars['showdomain']->value;?>
&hostname=<?php echo urlencode($_smarty_tpl->tpl_vars['hostname']->value);?>
&"<?php }
}
?>