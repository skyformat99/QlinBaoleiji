<?php /* Smarty version 3.1.27, created on 2017-07-10 11:22:02
         compiled from "/opt/freesvr/web/htdocs/freesvr/audit/template/admin/sshkey_edit.tpl" */ ?>
<?php
/*%%SmartyHeaderCode:11961909485962f2da227d22_41077674%%*/
if(!defined('SMARTY_DIR')) exit('no direct access allowed');
$_valid = $_smarty_tpl->decodeProperties(array (
  'file_dependency' => 
  array (
    '2cef1c6e89ebf1523d40a7f8d64400ce037ac61f' => 
    array (
      0 => '/opt/freesvr/web/htdocs/freesvr/audit/template/admin/sshkey_edit.tpl',
      1 => 1477107487,
      2 => 'file',
    ),
  ),
  'nocache_hash' => '11961909485962f2da227d22_41077674',
  'variables' => 
  array (
    'title' => 0,
    'template_root' => 0,
    'sshkey' => 0,
    'trnumber' => 0,
    'language' => 0,
  ),
  'has_nocache_code' => false,
  'version' => '3.1.27',
  'unifunc' => 'content_5962f2da2cfc43_88959501',
),false);
/*/%%SmartyHeaderCode%%*/
if ($_valid && !is_callable('content_5962f2da2cfc43_88959501')) {
function content_5962f2da2cfc43_88959501 ($_smarty_tpl) {

$_smarty_tpl->properties['nocache_hash'] = '11961909485962f2da227d22_41077674';
?>
<!doctype html public "-//w3c//dtd html 4.0 transitional//en">
<html>
<head>
<title><?php echo $_smarty_tpl->tpl_vars['title']->value;?>
</title>
<meta name="generator" content="editplus">
<meta name="author" content="nuttycoder">
<link href="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/all_purpose_style.css" rel="stylesheet" type="text/css" />

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
</head>
 <SCRIPT language=javascript src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/selectdate.js"></SCRIPT>

<body>


	<table width="100%" border="0" cellspacing="0" cellpadding="0">
 <tr><td valign="middle" class="hui_bj"><div class="menu">
<ul>
<?php if ($_SESSION['ADMIN_LEVEL'] == 10) {?>
<li class="me_b"><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an11.jpg" align="absmiddle"/><a href="admin.php?controller=admin_index&action=main">密码查看</a><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an33.jpg" align="absmiddle"/></li>
<li class="me_b"><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an11.jpg" align="absmiddle"/><a href="admin.php?controller=admin_pro&action=passwordedit">修改密码</a><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an33.jpg" align="absmiddle"/></li>
<li class="me_b"><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an11.jpg" align="absmiddle"/><a href="admin.php?controller=admin_pro&action=password_cron">定时任务</a><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an33.jpg" align="absmiddle"/></li>
<li class="me_b"><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an11.jpg" align="absmiddle"/><a href="admin.php?controller=admin_backup&action=backup_setting_forpassword">自动备份</a><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an33.jpg" align="absmiddle"/></li>
<li class="me_b"><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an11.jpg" align="absmiddle"/><a href="admin.php?controller=admin_index&action=passdown">密码文件下载</a><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an33.jpg" align="absmiddle"/></li>
<li class="me_b"><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an11.jpg" align="absmiddle"/><a href="admin.php?controller=admin_pro&action=passwordcheck">密码校验</a><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an33.jpg" align="absmiddle"/></li>
<?php } else { ?>
     <li class="me_b"><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an11.jpg" align="absmiddle"/><a href="admin.php?controller=admin_member">用户管理</a><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an33.jpg" align="absmiddle"/></li>
	<li class="me_b"><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an11.jpg" align="absmiddle"/><a href="admin.php?controller=admin_pro&action=dev_index">设备管理</a><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an33.jpg" align="absmiddle"/></li>
	<li class="me_b"><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an11.jpg" align="absmiddle"/><a href="admin.php?controller=admin_pro&action=dev_group">目录管理</a><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an33.jpg" align="absmiddle"/></li>
	<li class="me_b"><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an11.jpg" align="absmiddle"/><a href="admin.php?controller=admin_member&action=workdept">用户属性</a><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an33.jpg" align="absmiddle"/></li>
	<li class="me_b"><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an11.jpg" align="absmiddle"/><a href="admin.php?controller=admin_pro&action=systemtype">系统类型</a><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an33.jpg" align="absmiddle"/></li>
	<li class="me_a"><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an1.jpg" align="absmiddle"/><a href="admin.php?controller=admin_pro&action=sshkey">SSH公私钥</a><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an3.jpg" align="absmiddle"/></li>
	<li class="me_b"><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an11.jpg" align="absmiddle"/><a href="admin.php?controller=admin_member&action=radiususer">RADIUS用户</a><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an33.jpg" align="absmiddle"/></li>
	<li class="me_b"><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an11.jpg" align="absmiddle"/><a href="admin.php?controller=admin_pro&action=passwordkey">密码密钥</a><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an33.jpg" align="absmiddle"/></li>
	<?php if ($_SESSION['ADMIN_LEVEL'] == 1) {?>
    <li class="me_b"><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an11.jpg" align="absmiddle"/><a href="admin.php?controller=admin_member&action=online">在线用户</a><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an33.jpg" align="absmiddle"/></li>
	<?php }?>
<?php }?>
</ul><span class="back_img"><A href="admin.php?controller=admin_pro&action=sshkey&back=1"><IMG src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/back1.png" 
      width="80" height="30" border="0"></A></span>
</div></td></tr>
  <tr>
	<td class=""><table width="100%" border="0" cellspacing="0" cellpadding="0"  >
          <tr>
            <td align="center"><form name="f1" method=post action="admin.php?controller=admin_pro&action=sshkey_save&id=<?php echo $_smarty_tpl->tpl_vars['sshkey']->value['id'];?>
" enctype="multipart/form-data">
<input type="password" style="display:none"/> 
	<table border=0 width=100% cellpadding=5 cellspacing=0 bgcolor="#FFFFFF" valign=top class="BBtable">
	<tr><th colspan="3" class="list_bg"></th></tr>
	<?php $_smarty_tpl->tpl_vars["trnumber"] = new Smarty_Variable(0, null, 0);?>
	<tr <?php if ($_smarty_tpl->tpl_vars['trnumber']->value%2 == 0) {?>bgcolor="f7f7f7"<?php }?> >
		<td width="33%" align=right>
		名称:
		</td>
		<td width="67%">
		<input type=text name="sshkeyname" id="sshkeyname" size=35 value="<?php echo $_smarty_tpl->tpl_vars['sshkey']->value['sshkeyname'];?>
" >
	  </td>
	</tr>
	<?php $_smarty_tpl->tpl_vars["trnumber"] = new Smarty_Variable($_smarty_tpl->tpl_vars['trnumber']->value+1, null, 0);?>
	<tr <?php if ($_smarty_tpl->tpl_vars['trnumber']->value%2 == 0) {?>bgcolor="f7f7f7"<?php }?> >
		<td width="33%" align=right>
		私钥密码
		</td>
		<td width="67%">
		<input type=password name="password" id="password" size=35 value="<?php echo $_smarty_tpl->tpl_vars['sshkey']->value['keypassword'];?>
" >
	  </td>
	</tr>
	<?php $_smarty_tpl->tpl_vars["trnumber"] = new Smarty_Variable($_smarty_tpl->tpl_vars['trnumber']->value+1, null, 0);?>
	<tr <?php if ($_smarty_tpl->tpl_vars['trnumber']->value%2 == 0) {?>bgcolor="f7f7f7"<?php }?>  id="originalpassword2tr">
		<td width="33%" align=right>
		确认私钥密码
		</td>
		<td width="67%">
		<input type=password name="password_confirm" id="password_confirm" size=35 value="<?php echo $_smarty_tpl->tpl_vars['sshkey']->value['keypassword'];?>
" >
	  </td>
	</tr>

		<?php $_smarty_tpl->tpl_vars["trnumber"] = new Smarty_Variable($_smarty_tpl->tpl_vars['trnumber']->value+1, null, 0);?>
	<tr <?php if ($_smarty_tpl->tpl_vars['trnumber']->value%2 == 0) {?>bgcolor="f7f7f7"<?php }?>>
                  <TD width="" align=right>上传私钥 SFTP/SSH key </TD>
                  <TD><input type="file" name="key"  />(<?php if ($_smarty_tpl->tpl_vars['sshkey']->value['sshprivatekey_exists']) {?>已上传<?php } else { ?><font color='red'>未上传</font><?php }?>)</TD>
                </TR>
		<?php $_smarty_tpl->tpl_vars["trnumber"] = new Smarty_Variable($_smarty_tpl->tpl_vars['trnumber']->value+1, null, 0);?>
	<tr <?php if ($_smarty_tpl->tpl_vars['trnumber']->value%2 == 0) {?>bgcolor="f7f7f7"<?php }?>>
                  <TD width="" align=right>上传公钥 SFTP/SSH key </TD>
                  <TD><input type="file" name="pkey"  />(<?php if ($_smarty_tpl->tpl_vars['sshkey']->value['sshpublickey_exists']) {?>已上传<?php } else { ?><font color='red'>未上传</font><?php }?>)</TD>
                </TR>
		<?php $_smarty_tpl->tpl_vars["trnumber"] = new Smarty_Variable($_smarty_tpl->tpl_vars['trnumber']->value+1, null, 0);?>
	<tr <?php if ($_smarty_tpl->tpl_vars['trnumber']->value%2 == 0) {?>bgcolor="f7f7f7"<?php }?>>
                  <TD width="" align=right>描述: </TD>
                  <TD><textarea name="desc" cols="50" rows="10"><?php echo $_smarty_tpl->tpl_vars['sshkey']->value['desc'];?>
</textarea></TD>
                </TR>
   
	<tr><td></td><td><input type=submit  value="<?php echo $_smarty_tpl->tpl_vars['language']->value['Save'];?>
" class="an_02"></td></tr></table>
<input type="hidden" name="upload" value="1" />
</form>
	</td>
  </tr>
</table>
</body>
<iframe name="hide" height="0" frameborder="0" scrolling="no"></iframe>
</html>



<?php }
}
?>