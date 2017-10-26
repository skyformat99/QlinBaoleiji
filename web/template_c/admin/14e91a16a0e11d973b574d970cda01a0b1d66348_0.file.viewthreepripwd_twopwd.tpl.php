<?php /* Smarty version 3.1.27, created on 2017-08-07 13:30:31
         compiled from "/opt/freesvr/web/htdocs/freesvr/audit/template/admin/viewthreepripwd_twopwd.tpl" */ ?>
<?php
/*%%SmartyHeaderCode:21104073165987faf74d3317_21349631%%*/
if(!defined('SMARTY_DIR')) exit('no direct access allowed');
$_valid = $_smarty_tpl->decodeProperties(array (
  'file_dependency' => 
  array (
    '14e91a16a0e11d973b574d970cda01a0b1d66348' => 
    array (
      0 => '/opt/freesvr/web/htdocs/freesvr/audit/template/admin/viewthreepripwd_twopwd.tpl',
      1 => 1474793222,
      2 => 'file',
    ),
  ),
  'nocache_hash' => '21104073165987faf74d3317_21349631',
  'has_nocache_code' => false,
  'version' => '3.1.27',
  'unifunc' => 'content_5987faf74ff608_07397046',
),false);
/*/%%SmartyHeaderCode%%*/
if ($_valid && !is_callable('content_5987faf74ff608_07397046')) {
function content_5987faf74ff608_07397046 ($_smarty_tpl) {

$_smarty_tpl->properties['nocache_hash'] = '21104073165987faf74d3317_21349631';
?>
  <TABLE width="100%" border="0" cellspacing="0" cellpadding="0">
  <TBODY>
  <TR>
    <TD align="center" class="tb_t_bg">填写三权密码</TD>
  </TR>
  <TR>
    <TD>
      <TABLE width="100%" border="0" cellspacing="0" cellpadding="0" class="BBtable">
        <TBODY>
        <TR>
          <TD align="center">
           <form name="f1" method=post enctype="multipart/form-data" action="admin.php?controller=admin_config&action=doviewthreepripwd_twopwd" target="_blank">
            <TABLE width="100%" bgcolor="#ffffff" border="0" cellspacing="1" 
            cellpadding="5" valign="top">
              <TBODY>
              <TR bgcolor="#f7f7f7">
                <TD width="30%" height="32" align="right">Audit密码: </TD>
                <TD><INPUT name="auditpassword"   id="auditpassword" type="password" value="" autocomplete="off"></TD></TR>
              <TR>
                <TD width="30%" height="32" align="right">Password密码: </TD>
                <TD><INPUT name="passwordpassword" id="passwordpassword" type="password" value="" autocomplete="off"></TD></TR>
              <TR>
                <TD height="32" align="right"></TD>
                <TD><INPUT class="an_02" type="submit" value="提交" name="actions"></TD></TR></TBODY></TABLE>
      </FORM></TD></TR></TBODY></TABLE></TR></TBODY></TABLE>



<?php }
}
?>