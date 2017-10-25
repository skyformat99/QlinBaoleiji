<?php /* Smarty version 3.1.27, created on 2017-06-02 22:15:07
         compiled from "/opt/freesvr/web/htdocs/freesvr/audit/template/admin/editvncport.tpl" */ ?>
<?php
/*%%SmartyHeaderCode:1141802368593172eb47d021_40909387%%*/
if(!defined('SMARTY_DIR')) exit('no direct access allowed');
$_valid = $_smarty_tpl->decodeProperties(array (
  'file_dependency' => 
  array (
    '3b13d4fd57b0b79b6c4ac2b1c0a117b7a48ac133' => 
    array (
      0 => '/opt/freesvr/web/htdocs/freesvr/audit/template/admin/editvncport.tpl',
      1 => 1477639568,
      2 => 'file',
    ),
  ),
  'nocache_hash' => '1141802368593172eb47d021_40909387',
  'variables' => 
  array (
    'rdptype' => 0,
    'port' => 0,
    'url' => 0,
    'devicesid' => 0,
  ),
  'has_nocache_code' => false,
  'version' => '3.1.27',
  'unifunc' => 'content_593172eb4d2c59_94686814',
),false);
/*/%%SmartyHeaderCode%%*/
if ($_valid && !is_callable('content_593172eb4d2c59_94686814')) {
function content_593172eb4d2c59_94686814 ($_smarty_tpl) {

$_smarty_tpl->properties['nocache_hash'] = '1141802368593172eb47d021_40909387';
?>
<TABLE width="100%" border="0" cellspacing="0" cellpadding="0">
  <TBODY>
  <TR>
    <TD align="center" class="tb_t_bg">选择端口号 </TD>
  </TR>
  <TR>
    <TD>
      <TABLE width="100%" border="0" cellspacing="0" cellpadding="0">
        <TBODY>
        <TR>
          <TD align="center">
          <form name="f1" method=post enctype="multipart/form-data" action="admin.php?controller=admin_pro&action=doeditvncport" <?php if ($_smarty_tpl->tpl_vars['rdptype']->value != 'activex') {?>target="hide"<?php }?>>
            <TABLE width="100%" bgcolor="#ffffff" border="0" cellspacing="1" 
            cellpadding="5" valign="top" height="70">
              <TBODY>
              <TR>
                <TD align="center">
				<select name=vncport >
				<option value="<?php echo $_smarty_tpl->tpl_vars['port']->value;?>
" ><?php echo $_smarty_tpl->tpl_vars['port']->value;?>
</option>
				<?php if (isset($_smarty_tpl->tpl_vars['smarty']->value['section']['v'])) unset($_smarty_tpl->tpl_vars['smarty']->value['section']['v']);
$_smarty_tpl->tpl_vars['smarty']->value['section']['v']['name'] = 'v';
$_smarty_tpl->tpl_vars['smarty']->value['section']['v']['loop'] = is_array($_loop=9) ? count($_loop) : max(0, (int) $_loop); unset($_loop);
$_smarty_tpl->tpl_vars['smarty']->value['section']['v']['show'] = true;
$_smarty_tpl->tpl_vars['smarty']->value['section']['v']['max'] = $_smarty_tpl->tpl_vars['smarty']->value['section']['v']['loop'];
$_smarty_tpl->tpl_vars['smarty']->value['section']['v']['step'] = 1;
$_smarty_tpl->tpl_vars['smarty']->value['section']['v']['start'] = $_smarty_tpl->tpl_vars['smarty']->value['section']['v']['step'] > 0 ? 0 : $_smarty_tpl->tpl_vars['smarty']->value['section']['v']['loop']-1;
if ($_smarty_tpl->tpl_vars['smarty']->value['section']['v']['show']) {
    $_smarty_tpl->tpl_vars['smarty']->value['section']['v']['total'] = $_smarty_tpl->tpl_vars['smarty']->value['section']['v']['loop'];
    if ($_smarty_tpl->tpl_vars['smarty']->value['section']['v']['total'] == 0)
        $_smarty_tpl->tpl_vars['smarty']->value['section']['v']['show'] = false;
} else
    $_smarty_tpl->tpl_vars['smarty']->value['section']['v']['total'] = 0;
if ($_smarty_tpl->tpl_vars['smarty']->value['section']['v']['show']):

            for ($_smarty_tpl->tpl_vars['smarty']->value['section']['v']['index'] = $_smarty_tpl->tpl_vars['smarty']->value['section']['v']['start'], $_smarty_tpl->tpl_vars['smarty']->value['section']['v']['iteration'] = 1;
                 $_smarty_tpl->tpl_vars['smarty']->value['section']['v']['iteration'] <= $_smarty_tpl->tpl_vars['smarty']->value['section']['v']['total'];
                 $_smarty_tpl->tpl_vars['smarty']->value['section']['v']['index'] += $_smarty_tpl->tpl_vars['smarty']->value['section']['v']['step'], $_smarty_tpl->tpl_vars['smarty']->value['section']['v']['iteration']++):
$_smarty_tpl->tpl_vars['smarty']->value['section']['v']['rownum'] = $_smarty_tpl->tpl_vars['smarty']->value['section']['v']['iteration'];
$_smarty_tpl->tpl_vars['smarty']->value['section']['v']['index_prev'] = $_smarty_tpl->tpl_vars['smarty']->value['section']['v']['index'] - $_smarty_tpl->tpl_vars['smarty']->value['section']['v']['step'];
$_smarty_tpl->tpl_vars['smarty']->value['section']['v']['index_next'] = $_smarty_tpl->tpl_vars['smarty']->value['section']['v']['index'] + $_smarty_tpl->tpl_vars['smarty']->value['section']['v']['step'];
$_smarty_tpl->tpl_vars['smarty']->value['section']['v']['first']      = ($_smarty_tpl->tpl_vars['smarty']->value['section']['v']['iteration'] == 1);
$_smarty_tpl->tpl_vars['smarty']->value['section']['v']['last']       = ($_smarty_tpl->tpl_vars['smarty']->value['section']['v']['iteration'] == $_smarty_tpl->tpl_vars['smarty']->value['section']['v']['total']);
?>				
				<?php if ($_smarty_tpl->tpl_vars['port']->value != "590".((string)$_smarty_tpl->getVariable('smarty')->value['section']['v']['index'])) {?>
				<option value="590<?php echo $_smarty_tpl->getVariable('smarty')->value['section']['v']['index'];?>
" >590<?php echo $_smarty_tpl->getVariable('smarty')->value['section']['v']['index'];?>
</option>
				<?php }?>
				<?php endfor; endif; ?>
				</select>
				</TD></TR>
              <TR>
                <TD align="center"><INPUT class="an_02" type="submit" value="确定"></TD></TR></TBODY></TABLE>
           <input type="hidden" name="url" value="<?php echo $_smarty_tpl->tpl_vars['url']->value;?>
" />
	<input type="hidden" name="id" value="<?php echo $_smarty_tpl->tpl_vars['devicesid']->value;?>
" />
      </FORM></TD></TR></TBODY></TABLE></TR></TBODY></TABLE><?php }
}
?>