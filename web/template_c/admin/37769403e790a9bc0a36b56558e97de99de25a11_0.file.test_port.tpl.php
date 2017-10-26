<?php /* Smarty version 3.1.27, created on 2017-07-21 11:09:20
         compiled from "/opt/freesvr/web/htdocs/freesvr/audit/template/admin/test_port.tpl" */ ?>
<?php
/*%%SmartyHeaderCode:1423322045597170601e7836_79833245%%*/
if(!defined('SMARTY_DIR')) exit('no direct access allowed');
$_valid = $_smarty_tpl->decodeProperties(array (
  'file_dependency' => 
  array (
    '37769403e790a9bc0a36b56558e97de99de25a11' => 
    array (
      0 => '/opt/freesvr/web/htdocs/freesvr/audit/template/admin/test_port.tpl',
      1 => 1474793216,
      2 => 'file',
    ),
  ),
  'nocache_hash' => '1423322045597170601e7836_79833245',
  'variables' => 
  array (
    'c' => 0,
    'strloginapprove' => 0,
    'login_method' => 0,
    'logininfo' => 0,
  ),
  'has_nocache_code' => false,
  'version' => '3.1.27',
  'unifunc' => 'content_5971706023d406_67797811',
),false);
/*/%%SmartyHeaderCode%%*/
if ($_valid && !is_callable('content_5971706023d406_67797811')) {
function content_5971706023d406_67797811 ($_smarty_tpl) {

$_smarty_tpl->properties['nocache_hash'] = '1423322045597170601e7836_79833245';
?>
<TABLE width="100%" border="0" cellspacing="0" cellpadding="0">
  <TBODY>
  <TR>
    <TD>
      <TABLE width="100%" border="0" cellspacing="0" cellpadding="0">
        <TBODY>
        <TR>
          <TD align="center">
            <TABLE width="100%" bgcolor="#ffffff" border="0" cellspacing="1" 
            cellpadding="5" valign="top">
              <TBODY>
               <TR>
               <TD align="center">IP</TD><TD align="center"><?php echo $_smarty_tpl->tpl_vars['c']->value['device_ip'];?>
</TD></TR>
			   <TR>
               <TD align="center">协议</TD><TD align="center"><?php echo $_smarty_tpl->tpl_vars['c']->value['login_method'];?>
</TD></TR>
			   <TR>
               <TD align="center">端口</TD><TD align="center"><?php echo $_smarty_tpl->tpl_vars['c']->value['port'];?>
</TD></TR>
			   <TR>
               <TD align="center">用户名</TD><TD align="center"><?php echo $_smarty_tpl->tpl_vars['c']->value['username'];?>
</TD></TR>
			   <TR>
               <TD align="center">授权策略</TD><TD align="center"><?php echo $_smarty_tpl->tpl_vars['c']->value['forbidden_commands_groups'];?>
</TD></TR>
			   <TR>
               <TD align="center">周组策略</TD><TD align="center"><?php echo $_smarty_tpl->tpl_vars['c']->value['weektime'];?>
</TD></TR>
			   <TR>
               <TD align="center">来源IP组</TD><TD align="center"><?php echo $_smarty_tpl->tpl_vars['c']->value['sourceip'];?>
</TD></TR>
			   <TR>
			    <TR>
               <TD align="center">双人操作</TD><TD align="center"><?php echo $_smarty_tpl->tpl_vars['c']->value['twoauth'];?>
/<?php echo $_smarty_tpl->tpl_vars['strloginapprove']->value;?>
</TD></TR>
			   <TR>
			   <?php if ($_smarty_tpl->tpl_vars['login_method']->value == 'RDP') {?>
			   <TR>
               <TD align="center">上行剪切板</TD><TD align="center"><?php if (!$_smarty_tpl->tpl_vars['c']->value['rdpclipauth_up']) {?>不<?php }?>允许</TD></TR>
			   <TR>
               <TD align="center">下行剪切板</TD><TD align="center"><?php if (!$_smarty_tpl->tpl_vars['c']->value['rdpclipauth_down']) {?>不<?php }?>允许</TD></TR>
			   <TR>
			    <TR>
               <TD align="center">磁盘映射</TD><TD align="center"><?php if (!$_smarty_tpl->tpl_vars['c']->value['rdpdiskauth_up']) {?>不<?php }?>允许</TD></TR>
			   <TR>
			   <?php }?>
               <TD align="center">连接状态</TD><TD align="center"><?php echo $_smarty_tpl->tpl_vars['c']->value['result'];?>
</TD></TR>

				</TBODY></TABLE>
	<input type="hidden" name="id" value="<?php echo $_smarty_tpl->tpl_vars['logininfo']->value['id'];?>
" />
     </TD></TR></TBODY></TABLE></TR></TBODY></TABLE><?php }
}
?>