<?php /* Smarty version 3.1.27, created on 2017-05-18 16:01:12
         compiled from "/opt/freesvr/web/htdocs/freesvr/audit/template/admin/inputauth.tpl" */ ?>
<?php
/*%%SmartyHeaderCode:1022023128591d54c84557d7_32184334%%*/
if(!defined('SMARTY_DIR')) exit('no direct access allowed');
$_valid = $_smarty_tpl->decodeProperties(array (
  'file_dependency' => 
  array (
    '8c796924aec1208b8e76dc3d3039cfd1b267b887' => 
    array (
      0 => '/opt/freesvr/web/htdocs/freesvr/audit/template/admin/inputauth.tpl',
      1 => 1484100597,
      2 => 'file',
    ),
  ),
  'nocache_hash' => '1022023128591d54c84557d7_32184334',
  'variables' => 
  array (
    'showusers' => 0,
    'users' => 0,
    'username' => 0,
    'passwordsave' => 0,
    'saveednameit' => 0,
    'password' => 0,
    'saveedpwdit' => 0,
    'url' => 0,
    'devicesid' => 0,
  ),
  'has_nocache_code' => false,
  'version' => '3.1.27',
  'unifunc' => 'content_591d54c84befd8_82551585',
),false);
/*/%%SmartyHeaderCode%%*/
if ($_valid && !is_callable('content_591d54c84befd8_82551585')) {
function content_591d54c84befd8_82551585 ($_smarty_tpl) {

$_smarty_tpl->properties['nocache_hash'] = '1022023128591d54c84557d7_32184334';
?>
  <TABLE width="100%" border="0" cellspacing="0" cellpadding="0">
  <TBODY>
  <TR>
    <TD align="center" class="tb_t_bg">登录信息 </TD>
  </TR>
  <TR>
    <TD>
      <TABLE width="100%" border="0" cellspacing="0" cellpadding="0">
        <TBODY>
        <TR>
          <TD align="center">
           <form name="f1" method=post enctype="multipart/form-data" action="admin.php?controller=admin_pro&action=doinputauth" target="hide">
            <TABLE width="100%" bgcolor="#ffffff" border="0" cellspacing="1" 
            cellpadding="5" valign="top">
              <TBODY> 
			  <?php if ($_smarty_tpl->tpl_vars['showusers']->value) {?>
			  <TR bgcolor="#f7f7f7">
                <TD width="30%" height="32" align="right">用户: </TD>
                <TD>
				<select onchange="changeuser(this.value);">
				<option value="0" >请选择用户</option>
				<?php if (isset($_smarty_tpl->tpl_vars['smarty']->value['section']['u'])) unset($_smarty_tpl->tpl_vars['smarty']->value['section']['u']);
$_smarty_tpl->tpl_vars['smarty']->value['section']['u']['name'] = 'u';
$_smarty_tpl->tpl_vars['smarty']->value['section']['u']['loop'] = is_array($_loop=$_smarty_tpl->tpl_vars['users']->value) ? count($_loop) : max(0, (int) $_loop); unset($_loop);
$_smarty_tpl->tpl_vars['smarty']->value['section']['u']['show'] = true;
$_smarty_tpl->tpl_vars['smarty']->value['section']['u']['max'] = $_smarty_tpl->tpl_vars['smarty']->value['section']['u']['loop'];
$_smarty_tpl->tpl_vars['smarty']->value['section']['u']['step'] = 1;
$_smarty_tpl->tpl_vars['smarty']->value['section']['u']['start'] = $_smarty_tpl->tpl_vars['smarty']->value['section']['u']['step'] > 0 ? 0 : $_smarty_tpl->tpl_vars['smarty']->value['section']['u']['loop']-1;
if ($_smarty_tpl->tpl_vars['smarty']->value['section']['u']['show']) {
    $_smarty_tpl->tpl_vars['smarty']->value['section']['u']['total'] = $_smarty_tpl->tpl_vars['smarty']->value['section']['u']['loop'];
    if ($_smarty_tpl->tpl_vars['smarty']->value['section']['u']['total'] == 0)
        $_smarty_tpl->tpl_vars['smarty']->value['section']['u']['show'] = false;
} else
    $_smarty_tpl->tpl_vars['smarty']->value['section']['u']['total'] = 0;
if ($_smarty_tpl->tpl_vars['smarty']->value['section']['u']['show']):

            for ($_smarty_tpl->tpl_vars['smarty']->value['section']['u']['index'] = $_smarty_tpl->tpl_vars['smarty']->value['section']['u']['start'], $_smarty_tpl->tpl_vars['smarty']->value['section']['u']['iteration'] = 1;
                 $_smarty_tpl->tpl_vars['smarty']->value['section']['u']['iteration'] <= $_smarty_tpl->tpl_vars['smarty']->value['section']['u']['total'];
                 $_smarty_tpl->tpl_vars['smarty']->value['section']['u']['index'] += $_smarty_tpl->tpl_vars['smarty']->value['section']['u']['step'], $_smarty_tpl->tpl_vars['smarty']->value['section']['u']['iteration']++):
$_smarty_tpl->tpl_vars['smarty']->value['section']['u']['rownum'] = $_smarty_tpl->tpl_vars['smarty']->value['section']['u']['iteration'];
$_smarty_tpl->tpl_vars['smarty']->value['section']['u']['index_prev'] = $_smarty_tpl->tpl_vars['smarty']->value['section']['u']['index'] - $_smarty_tpl->tpl_vars['smarty']->value['section']['u']['step'];
$_smarty_tpl->tpl_vars['smarty']->value['section']['u']['index_next'] = $_smarty_tpl->tpl_vars['smarty']->value['section']['u']['index'] + $_smarty_tpl->tpl_vars['smarty']->value['section']['u']['step'];
$_smarty_tpl->tpl_vars['smarty']->value['section']['u']['first']      = ($_smarty_tpl->tpl_vars['smarty']->value['section']['u']['iteration'] == 1);
$_smarty_tpl->tpl_vars['smarty']->value['section']['u']['last']       = ($_smarty_tpl->tpl_vars['smarty']->value['section']['u']['iteration'] == $_smarty_tpl->tpl_vars['smarty']->value['section']['u']['total']);
?>
				<option value="<?php echo $_smarty_tpl->tpl_vars['users']->value[$_smarty_tpl->getVariable('smarty')->value['section']['u']['index']]['id'];?>
_<?php echo $_smarty_tpl->tpl_vars['users']->value[$_smarty_tpl->getVariable('smarty')->value['section']['u']['index']]['username'];?>
.,?<?php echo $_smarty_tpl->tpl_vars['users']->value[$_smarty_tpl->getVariable('smarty')->value['section']['u']['index']]['password'];?>
" <?php echo $_smarty_tpl->tpl_vars['users']->value[$_smarty_tpl->getVariable('smarty')->value['section']['u']['index']]['selected'];?>
 ><?php echo $_smarty_tpl->tpl_vars['users']->value[$_smarty_tpl->getVariable('smarty')->value['section']['u']['index']]['username'];?>
</option>
				<?php endfor; endif; ?>
				</select>
				</TD></TR>
              <TR>
			  <?php }?>
              <TR bgcolor="#f7f7f7">
                <TD width="30%" height="32" align="right">用户: </TD>
                <TD><INPUT name="username" id="username" type="text" value="<?php echo $_smarty_tpl->tpl_vars['username']->value;?>
" autocomplete="off"><?php if ($_smarty_tpl->tpl_vars['showusers']->value) {?>&nbsp;&nbsp;<INPUT type="hidden" id="passwordsave" value="<?php echo $_smarty_tpl->tpl_vars['passwordsave']->value;?>
" name="passwordsave"><INPUT type="checkbox" <?php if ($_smarty_tpl->tpl_vars['saveednameit']->value) {?>checked<?php }?> value="1" name="saveednameit">保存<?php }?>&nbsp;&nbsp;</TD></TR>
              <TR>
                <TD width="30%" height="32" align="right">密码: </TD>
                <TD><INPUT name="password" id="password" type="password" value="<?php echo $_smarty_tpl->tpl_vars['password']->value;?>
" autocomplete="off"><?php if ($_smarty_tpl->tpl_vars['showusers']->value) {?>&nbsp;&nbsp;<INPUT type="checkbox" <?php if ($_smarty_tpl->tpl_vars['saveedpwdit']->value) {?>checked<?php }?> value="1" name="saveedpwdit">保存<?php }?>&nbsp;&nbsp;</TD></TR>
              <TR>
                <TD height="32" align="right"></TD>
                <TD><INPUT class="an_02" type="submit" value="登录" name="actions">&nbsp;&nbsp;<?php if ($_smarty_tpl->tpl_vars['showusers']->value) {?><INPUT type="submit"  class="an_02" value="删除" name="actions"><?php }?></TD></TR></TBODY></TABLE>
	<input type="hidden" name="url" value="<?php echo $_smarty_tpl->tpl_vars['url']->value;?>
" />
	<input type="hidden" name="id" value="<?php echo $_smarty_tpl->tpl_vars['devicesid']->value;?>
" />
      </FORM></TD></TR></TBODY></TABLE>
<SCRIPT>

document.getElementById('username').value='';
document.getElementById('password').value='';
</SCRIPT></TR></TBODY></TABLE>



<?php }
}
?>