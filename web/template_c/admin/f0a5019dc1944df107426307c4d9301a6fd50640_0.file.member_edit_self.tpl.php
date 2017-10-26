<?php /* Smarty version 3.1.27, created on 2017-05-14 08:40:30
         compiled from "/opt/freesvr/web/htdocs/freesvr/audit/template/admin/member_edit_self.tpl" */ ?>
<?php
/*%%SmartyHeaderCode:2259520415917a77e3923d6_30608297%%*/
if(!defined('SMARTY_DIR')) exit('no direct access allowed');
$_valid = $_smarty_tpl->decodeProperties(array (
  'file_dependency' => 
  array (
    'f0a5019dc1944df107426307c4d9301a6fd50640' => 
    array (
      0 => '/opt/freesvr/web/htdocs/freesvr/audit/template/admin/member_edit_self.tpl',
      1 => 1493340030,
      2 => 'file',
    ),
  ),
  'nocache_hash' => '2259520415917a77e3923d6_30608297',
  'variables' => 
  array (
    'language' => 0,
    'template_root' => 0,
    'msg' => 0,
    'pwdshould' => 0,
    'member' => 0,
    'pwdremain' => 0,
    'priority_cache' => 0,
    'logintype' => 0,
    'ldaps' => 0,
    'ads' => 0,
  ),
  'has_nocache_code' => false,
  'version' => '3.1.27',
  'unifunc' => 'content_5917a77e4d7508_91566473',
),false);
/*/%%SmartyHeaderCode%%*/
if ($_valid && !is_callable('content_5917a77e4d7508_91566473')) {
function content_5917a77e4d7508_91566473 ($_smarty_tpl) {

$_smarty_tpl->properties['nocache_hash'] = '2259520415917a77e3923d6_30608297';
?>
<!doctype html public "-//w3c//dtd html 4.0 transitional//en">
<html>
<head>
<title><?php echo $_smarty_tpl->tpl_vars['language']->value['Master'];
echo $_smarty_tpl->tpl_vars['language']->value['page'];?>
面</title>
<meta name="generator" content="editplus">
<meta name="author" content="nuttycoder">
<link href="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/all_purpose_style.css" rel="stylesheet" type="text/css" />
<?php echo '<script'; ?>
 language="javascript">
	function check_add_user(){
		return(true);
	}
<?php echo '</script'; ?>
>
</head>
<style type="text/css">
a {
    color: #003499;
    text-decoration: none;
} 
a:hover {
    color: #000000;
    text-decoration: underline;
}
</style>
<body>

	
	<table width="100%" border="0" cellspacing="0" cellpadding="0">
	 <tr><td valign="middle" class="hui_bj"><div class="menu">
<ul>

	<li class="me_a"><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an1.jpg" align="absmiddle"/><a href="admin.php?controller=admin_member&action=edit_self">修改个人信息</a><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an3.jpg" align="absmiddle"/></li>
</ul>
</div></td></tr>
	  <tr>
		<td class="">
			<form method="post" name="add_user" action="admin.php?controller=admin_member&action=save_self" enctype="multipart/form-data">
			 <input type="password" style="display:none"/> 	<table bordercolor="white" cellspacing="1" cellpadding="5" border="0" width="100%" class="BBtable">
<tr><th colspan="3" class="list_bg"></th></tr>
				<?php if ($_smarty_tpl->tpl_vars['msg']->value) {?>
					<tr bgcolor="red">
						<td>提示：</td>
						<td><?php echo $_smarty_tpl->tpl_vars['msg']->value;?>
</td>
					</tr>
				<?php }?>
					<tr bgcolor="f7f7f7">
						<td align="right" width="33%">原密码：</td>
						<td><input type="password" name="oripassword" class="input_shorttext"> <?php echo $_smarty_tpl->tpl_vars['pwdshould']->value;?>
</td>
					</tr>
					<tr>
						<td align="right" width="33%"><?php echo $_smarty_tpl->tpl_vars['language']->value['Password'];?>
：</td>
						<td><input type="password" name="password1" class="input_shorttext"></td>
					</tr>
					<tr bgcolor="f7f7f7">
						<td align="right" width="33%"><?php echo $_smarty_tpl->tpl_vars['language']->value['Commitpassword'];?>
：</td>
						<td><input type="password" name="password2" class="input_shorttext"></td>
					</tr>
					<tr>
						<td align="right" width="33%"><?php echo $_smarty_tpl->tpl_vars['language']->value['Mailbox'];?>
：</td>
						<td><input type="text" name="email" class="input_shorttext" value="<?php echo $_smarty_tpl->tpl_vars['member']->value['email'];?>
"></td>
					</tr>
					<tr>
						<td align="right" width="33%">密码有效期：</td>
						<td><?php echo $_smarty_tpl->tpl_vars['pwdremain']->value;?>
</td>
					</tr>
				<?php if ($_smarty_tpl->tpl_vars['member']->value['level'] != 11) {?>
					<tr bgcolor="f7f7f7">
						<td align="right" width="33%">登录提示：</td>
						<td><input type="checkbox" name="login_tip" value="1" <?php if ($_smarty_tpl->tpl_vars['member']->value['login_tip']) {?>checked<?php }?>></td>
					</tr>
					<tr>
						<td align="right" width="33%">RDP分辨率：</td>
						<td>
						<select  class="wbk"  name='rdp_screen' id='rdp_screen' > 
					<option value="3" <?php if ($_smarty_tpl->tpl_vars['member']->value['rdp_screen'] == 3) {?>selected<?php }?>>全屏</option>
					<option value="1" <?php if ($_smarty_tpl->tpl_vars['member']->value['rdp_screen'] == 1) {?>selected<?php }?>>800*600</option>
					<option value="2" <?php if ($_smarty_tpl->tpl_vars['member']->value['rdp_screen'] == 2) {?>selected<?php }?>>1024*768</option>
					</select>

						</td>
					</tr>
					<tr bgcolor="f7f7f7">
						<td align="right" width="33%">RDP磁盘映射：</td>
						<td>
						<input type="text" name="rdpdisk" class="input_shorttext" value="<?php echo $_smarty_tpl->tpl_vars['member']->value['rdpdisk'];?>
">例子C:;D:;E:;
						</td>
					</tr>
				  <tr bgcolor="f7f7f7">
						<td align="right" width="33%">使用权限缓存：</td>
						<td><input type="checkbox" name="searchcache" value="1" <?php if ($_smarty_tpl->tpl_vars['priority_cache']->value || $_smarty_tpl->tpl_vars['member']->value['searchcache']) {?>checked<?php }?> <?php if ($_smarty_tpl->tpl_vars['priority_cache']->value) {?>onclick="this.checked=true;alert('系统已经设定强制使用缓存，如有问题请联系管理员')"<?php }?>>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<input type="button" onclick="window.location='admin.php?controller=admin_index&action=do_devices_cache'" height="35" align="middle" value="更新权限" border="0" class="bnnew2"/></td>
					</tr>
				 <tr>
						<td align="right" width="33%">显示目录：</td>
						<td><input type="checkbox" name="ldap" value="1" <?php if ($_smarty_tpl->tpl_vars['member']->value['ldap']) {?>checked<?php }?>></td>
					</tr>
                </TR>
				<tr bgcolor="">
						<td align="right" width="33%">PLSQL启动延时:</td>
						<td>
						<input type="text" name="appdelay" class="input_shorttext" value="<?php echo $_smarty_tpl->tpl_vars['member']->value['appdelay'];?>
">秒
						</td>
					</tr>
					<TR bgcolor="f7f7f7">
                  <TD align="right" width="33%">优先登录方式 </TD>
                  <TD><select  class="wbk"  name=firstauth>
<?php if ($_smarty_tpl->tpl_vars['logintype']->value['localauth']) {?>
                     <OPTION value="localauth" <?php if ($_smarty_tpl->tpl_vars['member']->value['firstauth'] == 'localauth') {?>selected<?php }?>>本地登录</OPTION>
<?php }?>
<?php if ($_smarty_tpl->tpl_vars['logintype']->value['radiusauth']) {?>
                     <OPTION value="radiusauth" <?php if ($_smarty_tpl->tpl_vars['member']->value['firstauth'] == 'radiusauth') {?>selected<?php }?>>RADIUS</OPTION>
<?php }?>
<?php if ($_smarty_tpl->tpl_vars['logintype']->value['emailauth']) {?>
                     <OPTION value="emailauth" <?php if ($_smarty_tpl->tpl_vars['member']->value['firstauth'] == 'emailauth') {?>selected<?php }?>>邮件</OPTION>
<?php }?>
<?php if ($_smarty_tpl->tpl_vars['logintype']->value['ldapauth']) {?>
<?php if (isset($_smarty_tpl->tpl_vars['smarty']->value['section']['l'])) unset($_smarty_tpl->tpl_vars['smarty']->value['section']['l']);
$_smarty_tpl->tpl_vars['smarty']->value['section']['l']['name'] = 'l';
$_smarty_tpl->tpl_vars['smarty']->value['section']['l']['loop'] = is_array($_loop=$_smarty_tpl->tpl_vars['ldaps']->value) ? count($_loop) : max(0, (int) $_loop); unset($_loop);
$_smarty_tpl->tpl_vars['smarty']->value['section']['l']['show'] = true;
$_smarty_tpl->tpl_vars['smarty']->value['section']['l']['max'] = $_smarty_tpl->tpl_vars['smarty']->value['section']['l']['loop'];
$_smarty_tpl->tpl_vars['smarty']->value['section']['l']['step'] = 1;
$_smarty_tpl->tpl_vars['smarty']->value['section']['l']['start'] = $_smarty_tpl->tpl_vars['smarty']->value['section']['l']['step'] > 0 ? 0 : $_smarty_tpl->tpl_vars['smarty']->value['section']['l']['loop']-1;
if ($_smarty_tpl->tpl_vars['smarty']->value['section']['l']['show']) {
    $_smarty_tpl->tpl_vars['smarty']->value['section']['l']['total'] = $_smarty_tpl->tpl_vars['smarty']->value['section']['l']['loop'];
    if ($_smarty_tpl->tpl_vars['smarty']->value['section']['l']['total'] == 0)
        $_smarty_tpl->tpl_vars['smarty']->value['section']['l']['show'] = false;
} else
    $_smarty_tpl->tpl_vars['smarty']->value['section']['l']['total'] = 0;
if ($_smarty_tpl->tpl_vars['smarty']->value['section']['l']['show']):

            for ($_smarty_tpl->tpl_vars['smarty']->value['section']['l']['index'] = $_smarty_tpl->tpl_vars['smarty']->value['section']['l']['start'], $_smarty_tpl->tpl_vars['smarty']->value['section']['l']['iteration'] = 1;
                 $_smarty_tpl->tpl_vars['smarty']->value['section']['l']['iteration'] <= $_smarty_tpl->tpl_vars['smarty']->value['section']['l']['total'];
                 $_smarty_tpl->tpl_vars['smarty']->value['section']['l']['index'] += $_smarty_tpl->tpl_vars['smarty']->value['section']['l']['step'], $_smarty_tpl->tpl_vars['smarty']->value['section']['l']['iteration']++):
$_smarty_tpl->tpl_vars['smarty']->value['section']['l']['rownum'] = $_smarty_tpl->tpl_vars['smarty']->value['section']['l']['iteration'];
$_smarty_tpl->tpl_vars['smarty']->value['section']['l']['index_prev'] = $_smarty_tpl->tpl_vars['smarty']->value['section']['l']['index'] - $_smarty_tpl->tpl_vars['smarty']->value['section']['l']['step'];
$_smarty_tpl->tpl_vars['smarty']->value['section']['l']['index_next'] = $_smarty_tpl->tpl_vars['smarty']->value['section']['l']['index'] + $_smarty_tpl->tpl_vars['smarty']->value['section']['l']['step'];
$_smarty_tpl->tpl_vars['smarty']->value['section']['l']['first']      = ($_smarty_tpl->tpl_vars['smarty']->value['section']['l']['iteration'] == 1);
$_smarty_tpl->tpl_vars['smarty']->value['section']['l']['last']       = ($_smarty_tpl->tpl_vars['smarty']->value['section']['l']['iteration'] == $_smarty_tpl->tpl_vars['smarty']->value['section']['l']['total']);
?>
<option value='ldapauth_<?php echo $_smarty_tpl->tpl_vars['ldaps']->value[$_smarty_tpl->getVariable('smarty')->value['section']['l']['index']]['address'];?>
' <?php if ($_smarty_tpl->tpl_vars['member']->value['firstauth'] == ('ldapauth_').($_smarty_tpl->tpl_vars['ldaps']->value[$_smarty_tpl->getVariable('smarty')->value['section']['l']['index']]['address'])) {?>selected<?php }?>>LDAP <?php echo $_smarty_tpl->tpl_vars['ldaps']->value[$_smarty_tpl->getVariable('smarty')->value['section']['l']['index']]['domain'];?>
</option>
<?php endfor; endif; ?>
<?php }?>
<?php if ($_smarty_tpl->tpl_vars['logintype']->value['adauth']) {?>
<?php if (isset($_smarty_tpl->tpl_vars['smarty']->value['section']['a'])) unset($_smarty_tpl->tpl_vars['smarty']->value['section']['a']);
$_smarty_tpl->tpl_vars['smarty']->value['section']['a']['name'] = 'a';
$_smarty_tpl->tpl_vars['smarty']->value['section']['a']['loop'] = is_array($_loop=$_smarty_tpl->tpl_vars['ads']->value) ? count($_loop) : max(0, (int) $_loop); unset($_loop);
$_smarty_tpl->tpl_vars['smarty']->value['section']['a']['show'] = true;
$_smarty_tpl->tpl_vars['smarty']->value['section']['a']['max'] = $_smarty_tpl->tpl_vars['smarty']->value['section']['a']['loop'];
$_smarty_tpl->tpl_vars['smarty']->value['section']['a']['step'] = 1;
$_smarty_tpl->tpl_vars['smarty']->value['section']['a']['start'] = $_smarty_tpl->tpl_vars['smarty']->value['section']['a']['step'] > 0 ? 0 : $_smarty_tpl->tpl_vars['smarty']->value['section']['a']['loop']-1;
if ($_smarty_tpl->tpl_vars['smarty']->value['section']['a']['show']) {
    $_smarty_tpl->tpl_vars['smarty']->value['section']['a']['total'] = $_smarty_tpl->tpl_vars['smarty']->value['section']['a']['loop'];
    if ($_smarty_tpl->tpl_vars['smarty']->value['section']['a']['total'] == 0)
        $_smarty_tpl->tpl_vars['smarty']->value['section']['a']['show'] = false;
} else
    $_smarty_tpl->tpl_vars['smarty']->value['section']['a']['total'] = 0;
if ($_smarty_tpl->tpl_vars['smarty']->value['section']['a']['show']):

            for ($_smarty_tpl->tpl_vars['smarty']->value['section']['a']['index'] = $_smarty_tpl->tpl_vars['smarty']->value['section']['a']['start'], $_smarty_tpl->tpl_vars['smarty']->value['section']['a']['iteration'] = 1;
                 $_smarty_tpl->tpl_vars['smarty']->value['section']['a']['iteration'] <= $_smarty_tpl->tpl_vars['smarty']->value['section']['a']['total'];
                 $_smarty_tpl->tpl_vars['smarty']->value['section']['a']['index'] += $_smarty_tpl->tpl_vars['smarty']->value['section']['a']['step'], $_smarty_tpl->tpl_vars['smarty']->value['section']['a']['iteration']++):
$_smarty_tpl->tpl_vars['smarty']->value['section']['a']['rownum'] = $_smarty_tpl->tpl_vars['smarty']->value['section']['a']['iteration'];
$_smarty_tpl->tpl_vars['smarty']->value['section']['a']['index_prev'] = $_smarty_tpl->tpl_vars['smarty']->value['section']['a']['index'] - $_smarty_tpl->tpl_vars['smarty']->value['section']['a']['step'];
$_smarty_tpl->tpl_vars['smarty']->value['section']['a']['index_next'] = $_smarty_tpl->tpl_vars['smarty']->value['section']['a']['index'] + $_smarty_tpl->tpl_vars['smarty']->value['section']['a']['step'];
$_smarty_tpl->tpl_vars['smarty']->value['section']['a']['first']      = ($_smarty_tpl->tpl_vars['smarty']->value['section']['a']['iteration'] == 1);
$_smarty_tpl->tpl_vars['smarty']->value['section']['a']['last']       = ($_smarty_tpl->tpl_vars['smarty']->value['section']['a']['iteration'] == $_smarty_tpl->tpl_vars['smarty']->value['section']['a']['total']);
?>
<option value='adauth_<?php echo $_smarty_tpl->tpl_vars['ads']->value[$_smarty_tpl->getVariable('smarty')->value['section']['a']['index']]['address'];?>
' <?php if ($_smarty_tpl->tpl_vars['member']->value['firstauth'] == ('adauth_').($_smarty_tpl->tpl_vars['ads']->value[$_smarty_tpl->getVariable('smarty')->value['section']['a']['index']]['address'])) {?>selected<?php }?>>AD <?php echo $_smarty_tpl->tpl_vars['ads']->value[$_smarty_tpl->getVariable('smarty')->value['section']['a']['index']]['domain'];?>
</option>
<?php endfor; endif; ?>
<?php }?>
                  </SELECT>                  
				  </TD></tr>
				  <tr bgcolor="">
						<td align="right" width="33%">CRT启动新标签</td>
						<td><input type="checkbox" name="crttab" value="1" <?php if ($_smarty_tpl->tpl_vars['member']->value['crttab']) {?>checked<?php }?>>
						</td>
					</tr>
				<tr bgcolor="f7f7f7">
						<td align="right" width="33%">客户端IP</td>
						<td><?php echo $_smarty_tpl->tpl_vars['member']->value['websourceip'];?>

						</td>
					</tr>
					<tr bgcolor="">
						<td align="right" width="33%">显示行数：</td>
						<td>
						<input type="text" name="rows" class="input_shorttext" value="<?php echo $_smarty_tpl->tpl_vars['member']->value['rows'];?>
">
						</td>
					</tr>
					<TR bgcolor="#f7f7f7">
      <TD align="right" bordercolor="white">SSH登录端口： </TD>
      <TD bordercolor="white"><input type="text" id="sshport" name="sshport" value="<?php echo $_smarty_tpl->tpl_vars['member']->value['sshport'];?>
" >
      </TD></tr><tr>
      <TD align="right" bordercolor="white">RDP登录端口：</TD>
      <TD bordercolor="white"><input type="text" id="rdpport" name="rdpport" value="<?php echo $_smarty_tpl->tpl_vars['member']->value['rdpport'];?>
" >
      </TD>
    </TR>
    				<?php }?>
    				<tr>
						<td align="right" width="33%">工具显示主机名：</td>
						<td>
						<select  class="wbk"  name='toolhostname' id='toolhostname' > 
					<option value="0" <?php if ($_smarty_tpl->tpl_vars['member']->value['toolhostname'] == 0) {?>selected<?php }?>>IP</option>
					<option value="1" <?php if ($_smarty_tpl->tpl_vars['member']->value['toolhostname'] == 1) {?>selected<?php }?>>主机名</option>
					</select>

						</td>
					</tr>
					<tr >
						<td  align="center" colspan=2><input  type="submit" value="<?php echo $_smarty_tpl->tpl_vars['language']->value['Commit'];?>
" class="an_02"></td>
					</tr>
				</table>
			</form>
			
		</td>
	  </tr>
	</table>
</body>
</html>


<?php }
}
?>