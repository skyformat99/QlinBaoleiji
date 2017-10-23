<?php /* Smarty version 3.1.27, created on 2017-10-10 13:42:34
         compiled from "/opt/freesvr/web/htdocs/freesvr/audit/template/admin/addldapserver.tpl" */ ?>
<?php
/*%%SmartyHeaderCode:27750135159dc5dcad370d6_36150037%%*/
if(!defined('SMARTY_DIR')) exit('no direct access allowed');
$_valid = $_smarty_tpl->decodeProperties(array (
  'file_dependency' => 
  array (
    '57cda87597b550a62dd6fdf1c69591d4f60139ce' => 
    array (
      0 => '/opt/freesvr/web/htdocs/freesvr/audit/template/admin/addldapserver.tpl',
      1 => 1499420329,
      2 => 'file',
    ),
  ),
  'nocache_hash' => '27750135159dc5dcad370d6_36150037',
  'variables' => 
  array (
    'language' => 0,
    'template_root' => 0,
  ),
  'has_nocache_code' => false,
  'version' => '3.1.27',
  'unifunc' => 'content_59dc5dcad87411_31917717',
),false);
/*/%%SmartyHeaderCode%%*/
if ($_valid && !is_callable('content_59dc5dcad87411_31917717')) {
function content_59dc5dcad87411_31917717 ($_smarty_tpl) {

$_smarty_tpl->properties['nocache_hash'] = '27750135159dc5dcad370d6_36150037';
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

</head>

<body>
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
<td width="84%" align="left" valign="top"><table width="100%" border="0" cellspacing="0" cellpadding="0"><tr><td valign="middle" class="hui_bj"><div class="menu">
<ul>
    <li class="me_a"><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an1.jpg" align="absmiddle"/><a href="admin.php?controller=admin_config&action=config_ssh">认证配置</a><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an3.jpg" align="absmiddle"/></li>
	<li class="me_b"><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an11.jpg" align="absmiddle"/><a href="admin.php?controller=admin_config&action=certs">证书配置</a><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an33.jpg" align="absmiddle"/></li>
    <li class="me_b"><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an11.jpg" align="absmiddle"/><a href="admin.php?controller=admin_config&action=config_ftp">系统参数</a><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an33.jpg" align="absmiddle"/></li>
    <li class="me_b"><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an11.jpg" align="absmiddle"/><a href="admin.php?controller=admin_config&action=login_times">密码策略</a><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an33.jpg" align="absmiddle"/></li>
	<li class="me_b"><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an11.jpg" align="absmiddle"/><a href="admin.php?controller=admin_config&action=syslog_mail_alarm">告警配置</a><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an33.jpg" align="absmiddle"/></li>
	<li class="me_b"><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an11.jpg" align="absmiddle"/><a href="admin.php?controller=admin_config&action=status_warning">告警参数</a><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an33.jpg" align="absmiddle"/></li>
	<li class="me_b"><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an11.jpg" align="absmiddle"/><a href="admin.php?controller=admin_config&action=loadbalance">负载均衡</a><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an33.jpg" align="absmiddle"/></li>
</ul><span class="back_img"><A href="admin.php?controller=admin_config&action=config_ssh&back=1"><IMG src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/back1.png" 
      width="80" height="30" border="0"></A></span>
</div></td></tr>


<tr><th colspan="6" class="list_bg"></th></tr>


  <tr><td><table bordercolor="white" cellspacing="0" cellpadding="5" border="0" width="100%" class="BBtable">
<form name="f1" method=post OnSubmit='return check()' action="admin.php?controller=admin_config&action=doaddldapserver">


	<tr bgcolor="f7f7f7"><td align="right">类型:</td>		
	<td>
		<select name="type" ><option value="ldap">LDAP</option><option value="ad">AD</option></select>
		</td>
	</tr>
	<tr><td align="right">服务器IP:</td>		
		<td>
		<input type="text" class="wbk" name="newip" value="" />
		</td>
	</tr>
	<tr bgcolor="f7f7f7">
<td align="right"> 服务器端口:</td>		
	<td>
		<input type="text" class="wbk" name="newport" value="" />	</td>	
</tr>
<tr>
	<td align="right">
		 域 :</td>		
	<td>
		<input type="text" class="wbk" name="newdomain" value="" />	
		</td>		
	</tr>
<tr>
	<td align="right">
		 透明登录 :</td>		
	<td>
		<input type="checkbox" value="1" name="transpant"  />	
		</td>		
	</tr>

	<tr>
			<td  align="center" colspan=6><input type="submit"  value="<?php echo $_smarty_tpl->tpl_vars['language']->value['Save'];?>
" class="an_02"></td>
		</tr>

	</table>
</form>

		</table>
	</td>
  </tr>
</table>


<?php echo '<script'; ?>
 language="javascript">
<!--
function check()
{
/*
   if(!checkIP(f1.ip.value) && f1.netmask.value != '32' ) {
	alert('地址为<?php echo $_smarty_tpl->tpl_vars['language']->value['HostName'];?>
时，掩码应为32');
	return false;
   }   
   if(checkIP(f1.ip.value) && !checknum(f1.netmask.value)) {
	alert('请<?php echo $_smarty_tpl->tpl_vars['language']->value['Input'];?>
正确掩码');
	return false;
   }
*/
   return true;

}//end check
// -->

function checkIP(ip)
{
	var ips = ip.split('.');
	if(ips.length==4 && ips[0]>=0 && ips[0]<256 && ips[1]>=0 && ips[1]<256 && ips[2]>=0 && ips[2]<256 && ips[3]>=0 && ips[3]<256)
		return ture;
	else
		return false;
}

function checknum(num)
{

	if( isDigit(num) && num > 0 && num < 65535)
		return ture;
	else
		return false;

}

function isDigit(s)
{
var patrn=/^[0-9]{1,20}$/;
if (!patrn.exec(s)) return false;
return true;
}

<?php echo '</script'; ?>
>
</body>
</html>


<?php }
}
?>