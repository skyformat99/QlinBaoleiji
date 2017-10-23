<?php /* Smarty version 3.1.27, created on 2017-08-08 09:50:44
         compiled from "/opt/freesvr/web/htdocs/freesvr/audit/template/admin/editpassword.tpl" */ ?>
<?php
/*%%SmartyHeaderCode:822788215598918f412b215_79306669%%*/
if(!defined('SMARTY_DIR')) exit('no direct access allowed');
$_valid = $_smarty_tpl->decodeProperties(array (
  'file_dependency' => 
  array (
    'a7f7f40f256dd4350a21285148f89e26650811a7' => 
    array (
      0 => '/opt/freesvr/web/htdocs/freesvr/audit/template/admin/editpassword.tpl',
      1 => 1502157031,
      2 => 'file',
    ),
  ),
  'nocache_hash' => '822788215598918f412b215_79306669',
  'variables' => 
  array (
    'template_root' => 0,
    'alluser' => 0,
    'allserver' => 0,
    'pwdconfig_login_pwd_length' => 0,
    'pwdconfig_password_ban_word' => 0,
    'pwdconfig_pwdstrong1' => 0,
    'pwdconfig_pwdstrong2' => 0,
    'pwdconfig_pwdstrong3' => 0,
    'pwdconfig_pwdstrong4' => 0,
    '_config' => 0,
    'changelevelstr' => 0,
  ),
  'has_nocache_code' => false,
  'version' => '3.1.27',
  'unifunc' => 'content_598918f41ac460_66088024',
),false);
/*/%%SmartyHeaderCode%%*/
if ($_valid && !is_callable('content_598918f41ac460_66088024')) {
function content_598918f41ac460_66088024 ($_smarty_tpl) {

$_smarty_tpl->properties['nocache_hash'] = '822788215598918f412b215_79306669';
?>
<!doctype html public "-//w3c//dtd html 4.0 transitional//en">
<html>
<head>
<title>主页面</title>
<meta name="generator" content="editplus">
<meta name="author" content="nuttycoder">
<link href="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/all_purpose_style.css" rel="stylesheet" type="text/css" />
<?php echo '<script'; ?>
 src="./template/admin/cssjs/global.functions.js"><?php echo '</script'; ?>
>
<?php echo '<script'; ?>
 type="text/javascript" src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/cssjs/jquery-1.10.2.min.js"><?php echo '</script'; ?>
>
<?php echo '<script'; ?>
 type="text/javascript" src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/cssjs/_ajaxdtree.js"><?php echo '</script'; ?>
>
<link href="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/cssjs/dtree.css" rel="stylesheet" type="text/css" />
<?php echo '<script'; ?>
 type="text/javascript">
function reloadimg(duration){
	var img = document.getElementById("zoomGraphImage");
	img.src=img.src+"&duration="+duration+"&"+parseInt(10000*Math.random());
}
<?php echo '</script'; ?>
>

<?php echo '<script'; ?>
>

var foundparent = false;
var servergroup = new Array();
var usergroup = new Array();
var alluser = new Array();
var allserver = new Array();
var i=0;
<?php if (isset($_smarty_tpl->tpl_vars['smarty']->value['section']['au'])) unset($_smarty_tpl->tpl_vars['smarty']->value['section']['au']);
$_smarty_tpl->tpl_vars['smarty']->value['section']['au']['name'] = 'au';
$_smarty_tpl->tpl_vars['smarty']->value['section']['au']['loop'] = is_array($_loop=$_smarty_tpl->tpl_vars['alluser']->value) ? count($_loop) : max(0, (int) $_loop); unset($_loop);
$_smarty_tpl->tpl_vars['smarty']->value['section']['au']['show'] = true;
$_smarty_tpl->tpl_vars['smarty']->value['section']['au']['max'] = $_smarty_tpl->tpl_vars['smarty']->value['section']['au']['loop'];
$_smarty_tpl->tpl_vars['smarty']->value['section']['au']['step'] = 1;
$_smarty_tpl->tpl_vars['smarty']->value['section']['au']['start'] = $_smarty_tpl->tpl_vars['smarty']->value['section']['au']['step'] > 0 ? 0 : $_smarty_tpl->tpl_vars['smarty']->value['section']['au']['loop']-1;
if ($_smarty_tpl->tpl_vars['smarty']->value['section']['au']['show']) {
    $_smarty_tpl->tpl_vars['smarty']->value['section']['au']['total'] = $_smarty_tpl->tpl_vars['smarty']->value['section']['au']['loop'];
    if ($_smarty_tpl->tpl_vars['smarty']->value['section']['au']['total'] == 0)
        $_smarty_tpl->tpl_vars['smarty']->value['section']['au']['show'] = false;
} else
    $_smarty_tpl->tpl_vars['smarty']->value['section']['au']['total'] = 0;
if ($_smarty_tpl->tpl_vars['smarty']->value['section']['au']['show']):

            for ($_smarty_tpl->tpl_vars['smarty']->value['section']['au']['index'] = $_smarty_tpl->tpl_vars['smarty']->value['section']['au']['start'], $_smarty_tpl->tpl_vars['smarty']->value['section']['au']['iteration'] = 1;
                 $_smarty_tpl->tpl_vars['smarty']->value['section']['au']['iteration'] <= $_smarty_tpl->tpl_vars['smarty']->value['section']['au']['total'];
                 $_smarty_tpl->tpl_vars['smarty']->value['section']['au']['index'] += $_smarty_tpl->tpl_vars['smarty']->value['section']['au']['step'], $_smarty_tpl->tpl_vars['smarty']->value['section']['au']['iteration']++):
$_smarty_tpl->tpl_vars['smarty']->value['section']['au']['rownum'] = $_smarty_tpl->tpl_vars['smarty']->value['section']['au']['iteration'];
$_smarty_tpl->tpl_vars['smarty']->value['section']['au']['index_prev'] = $_smarty_tpl->tpl_vars['smarty']->value['section']['au']['index'] - $_smarty_tpl->tpl_vars['smarty']->value['section']['au']['step'];
$_smarty_tpl->tpl_vars['smarty']->value['section']['au']['index_next'] = $_smarty_tpl->tpl_vars['smarty']->value['section']['au']['index'] + $_smarty_tpl->tpl_vars['smarty']->value['section']['au']['step'];
$_smarty_tpl->tpl_vars['smarty']->value['section']['au']['first']      = ($_smarty_tpl->tpl_vars['smarty']->value['section']['au']['iteration'] == 1);
$_smarty_tpl->tpl_vars['smarty']->value['section']['au']['last']       = ($_smarty_tpl->tpl_vars['smarty']->value['section']['au']['iteration'] == $_smarty_tpl->tpl_vars['smarty']->value['section']['au']['total']);
?>
alluser[i++]={uid:<?php echo $_smarty_tpl->tpl_vars['alluser']->value[$_smarty_tpl->getVariable('smarty')->value['section']['au']['index']]['uid'];?>
,username:'<?php echo $_smarty_tpl->tpl_vars['alluser']->value[$_smarty_tpl->getVariable('smarty')->value['section']['au']['index']]['username'];?>
',realname:'<?php echo $_smarty_tpl->tpl_vars['alluser']->value[$_smarty_tpl->getVariable('smarty')->value['section']['au']['index']]['realname'];?>
',groupid:<?php echo $_smarty_tpl->tpl_vars['alluser']->value[$_smarty_tpl->getVariable('smarty')->value['section']['au']['index']]['groupid'];?>
,level:<?php echo $_smarty_tpl->tpl_vars['alluser']->value[$_smarty_tpl->getVariable('smarty')->value['section']['au']['index']]['level'];?>
};
<?php endfor; endif; ?>
var i=0;
<?php if (isset($_smarty_tpl->tpl_vars['smarty']->value['section']['as'])) unset($_smarty_tpl->tpl_vars['smarty']->value['section']['as']);
$_smarty_tpl->tpl_vars['smarty']->value['section']['as']['name'] = 'as';
$_smarty_tpl->tpl_vars['smarty']->value['section']['as']['loop'] = is_array($_loop=$_smarty_tpl->tpl_vars['allserver']->value) ? count($_loop) : max(0, (int) $_loop); unset($_loop);
$_smarty_tpl->tpl_vars['smarty']->value['section']['as']['show'] = true;
$_smarty_tpl->tpl_vars['smarty']->value['section']['as']['max'] = $_smarty_tpl->tpl_vars['smarty']->value['section']['as']['loop'];
$_smarty_tpl->tpl_vars['smarty']->value['section']['as']['step'] = 1;
$_smarty_tpl->tpl_vars['smarty']->value['section']['as']['start'] = $_smarty_tpl->tpl_vars['smarty']->value['section']['as']['step'] > 0 ? 0 : $_smarty_tpl->tpl_vars['smarty']->value['section']['as']['loop']-1;
if ($_smarty_tpl->tpl_vars['smarty']->value['section']['as']['show']) {
    $_smarty_tpl->tpl_vars['smarty']->value['section']['as']['total'] = $_smarty_tpl->tpl_vars['smarty']->value['section']['as']['loop'];
    if ($_smarty_tpl->tpl_vars['smarty']->value['section']['as']['total'] == 0)
        $_smarty_tpl->tpl_vars['smarty']->value['section']['as']['show'] = false;
} else
    $_smarty_tpl->tpl_vars['smarty']->value['section']['as']['total'] = 0;
if ($_smarty_tpl->tpl_vars['smarty']->value['section']['as']['show']):

            for ($_smarty_tpl->tpl_vars['smarty']->value['section']['as']['index'] = $_smarty_tpl->tpl_vars['smarty']->value['section']['as']['start'], $_smarty_tpl->tpl_vars['smarty']->value['section']['as']['iteration'] = 1;
                 $_smarty_tpl->tpl_vars['smarty']->value['section']['as']['iteration'] <= $_smarty_tpl->tpl_vars['smarty']->value['section']['as']['total'];
                 $_smarty_tpl->tpl_vars['smarty']->value['section']['as']['index'] += $_smarty_tpl->tpl_vars['smarty']->value['section']['as']['step'], $_smarty_tpl->tpl_vars['smarty']->value['section']['as']['iteration']++):
$_smarty_tpl->tpl_vars['smarty']->value['section']['as']['rownum'] = $_smarty_tpl->tpl_vars['smarty']->value['section']['as']['iteration'];
$_smarty_tpl->tpl_vars['smarty']->value['section']['as']['index_prev'] = $_smarty_tpl->tpl_vars['smarty']->value['section']['as']['index'] - $_smarty_tpl->tpl_vars['smarty']->value['section']['as']['step'];
$_smarty_tpl->tpl_vars['smarty']->value['section']['as']['index_next'] = $_smarty_tpl->tpl_vars['smarty']->value['section']['as']['index'] + $_smarty_tpl->tpl_vars['smarty']->value['section']['as']['step'];
$_smarty_tpl->tpl_vars['smarty']->value['section']['as']['first']      = ($_smarty_tpl->tpl_vars['smarty']->value['section']['as']['iteration'] == 1);
$_smarty_tpl->tpl_vars['smarty']->value['section']['as']['last']       = ($_smarty_tpl->tpl_vars['smarty']->value['section']['as']['iteration'] == $_smarty_tpl->tpl_vars['smarty']->value['section']['as']['total']);
?>
allserver[i++]={hostname:'<?php echo $_smarty_tpl->tpl_vars['allserver']->value[$_smarty_tpl->getVariable('smarty')->value['section']['as']['index']]['hostname'];?>
',device_ip:'<?php echo $_smarty_tpl->tpl_vars['allserver']->value[$_smarty_tpl->getVariable('smarty')->value['section']['as']['index']]['device_ip'];?>
',groupid:<?php echo $_smarty_tpl->tpl_vars['allserver']->value[$_smarty_tpl->getVariable('smarty')->value['section']['as']['index']]['groupid'];?>
};
<?php endfor; endif; ?>

<?php echo '</script'; ?>
>
<?php echo '<script'; ?>
 type="text/javascript">


function GetRandomNum(Min,Max)
{   
var Range = Max - Min;   
var Rand = Math.random();   
return(Min + Math.round(Rand * Range));   
}   
var num = GetRandomNum(1,<?php echo $_smarty_tpl->tpl_vars['pwdconfig_login_pwd_length']->value;?>
);  

var numbers = ['0','1','2','3','4','5','6','7','8','9'];
var schars = ['a','b','c','d','e','f','g','h','i','j','k','l','m','n','o','p','q','r','s','t','u','v','w','x','y','z','A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P','Q','R','S','T','U','V','W','X','Y','Z'];
//var bchars = [];
var sschars = ['~','!','@','#','$','%','^','&','*','(',')','<','>','?',':','"','{','}','\'',';','/','.',','];
var chars = ['A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P','Q','R','S','T','U','V','W','X','Y','Z','a','b','c','d','e','f','g','h','i','j','k','l','m','n','o','p','q','r','s','t','u','v','w','x','y','z','0','1','2','3','4','5','6','7','8','9','~','!','@','#','$','%','^','&','*','<','>','?',':','"','\'',';','.',','];

function generateMixed() {
	 var banword = '<?php echo $_smarty_tpl->tpl_vars['pwdconfig_password_ban_word']->value;?>
';
     var res = "";
	 for (var i=0; i<<?php echo $_smarty_tpl->tpl_vars['pwdconfig_pwdstrong1']->value;?>
; i++ )
	 {
		var id = Math.ceil(Math.random()*(numbers.length-1));
		res += numbers[id]
	 }
	 for (var i=0; i<<?php echo $_smarty_tpl->tpl_vars['pwdconfig_pwdstrong2']->value;?>
; i++ )
	 {
		var id = Math.ceil(Math.random()*(schars.length-1));
		res += schars[id]
	 }
	 /*for (var i=0; i<<?php echo $_smarty_tpl->tpl_vars['pwdconfig_pwdstrong3']->value;?>
; i++ )
	 {
		var id = Math.ceil(Math.random()*(bchars.length-1));
		res += bchars[id]
	 }
	 for (var i=0; i<<?php echo $_smarty_tpl->tpl_vars['pwdconfig_pwdstrong4']->value;?>
; i++ )
	 {
		var id = Math.ceil(Math.random()*(sschars.length-1));
		res += sschars[id]
	 }*/
     for(var i = 0; i <<?php echo $_smarty_tpl->tpl_vars['pwdconfig_login_pwd_length']->value;?>
 ; ) {
		var id = Math.ceil(Math.random()*(chars.length-1));
		if(banword.indexOf(chars[id])<0){
			res += chars[id];
			i++;
		}
     }
     return res;
}

function setrandompwd(){
	if(document.getElementById('autosetpwd').checked){
		var pwd = generateMixed();
		document.getElementById('password').value=pwd;
	}else{
		document.getElementById('password').value='';
	}
}
<?php echo '</script'; ?>
>
<?php echo '<script'; ?>
 src="./template/admin/cssjs/jscal2.js"><?php echo '</script'; ?>
>
<?php echo '<script'; ?>
 src="./template/admin/cssjs/cn.js"><?php echo '</script'; ?>
>
<link type="text/css" rel="stylesheet" href="./template/admin/cssjs/jscal2.css" />
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
<li class="me_b"><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an11.jpg" align="absmiddle"/><a href="admin.php?controller=admin_index&action=main">密码查看</a><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an33.jpg" align="absmiddle"/></li>
<li class="me_a"><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an1.jpg" align="absmiddle"/><a href="admin.php?controller=admin_pro&action=passwordedit">修改密码</a><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an3.jpg" align="absmiddle"/></li>
<?php if ($_SESSION['ADMIN_LEVEL'] == 10) {?>
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
<?php }?>
<?php if ($_SESSION['ADMIN_LEVEL'] != 10 && $_SESSION['ADMIN_LEVEL'] != 101) {?>
    <li class="me_b"><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an11.jpg" align="absmiddle"/><a href="admin.php?controller=admin_pro&action=dev_group">设备目录</a><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an33.jpg" align="absmiddle"/></li>
	<?php }?>
</ul>
</div></td></tr>
  <tr><td><table bordercolor="white" cellspacing="0" cellpadding="5" border="0" width="100%" class="BBtable">
<form name="f1" method=post OnSubmit='return check()' action="admin.php?controller=admin_pro&action=passwordedit">
	
	 
	<tr ><td>设备选择</td>
		<td align=left>
		<?php echo $_smarty_tpl->getSubTemplate ("select_sgroup_ajax.tpl", $_smarty_tpl->cache_id, $_smarty_tpl->compile_id, 0, $_smarty_tpl->cache_lifetime, array(), 0);
?>
          
		&nbsp;&nbsp;&nbsp;服务器IP:
		<input type="text"  name="server" size="13" value="" class="wbk"/> 
		
		&nbsp;&nbsp;&nbsp;
		用户:
		<input type="text"  name="device" size="13" value="" class="wbk"/> 
		
		</td>
		
	</tr>
	<tr bgcolor="f7f7f7"><td>密码修改:</td>
		<td align=left>
		<select  class="wbk"  name='pwdpolicy'>		
		<option value=1 >强制修改</option>
		<option value=0 >策略修改</option>
		</select>
		</td>
		
	</tr>
	<tr bgcolor="f7f7f7"><td>密&nbsp;&nbsp;码:</td>
		<td align=left>
		<input type="text" class="wbk" name="password" id="password" value="" />&nbsp;&nbsp;&nbsp;&nbsp;<input onClick="setrandompwd();" id="autosetpwd" type="checkbox" name="autosetpwd" value="1" />随机密码
		</td>		
	</tr>
	<tr >
			<td colspan="2" align="center"><input type="submit"  value="生成密码" class="an_02"></td>
		</tr>

	</table>
	<input type="hidden" name="ac" value="doit" />
</form>

		</table>
	</td>
  </tr>
</table>
  <?php echo '<script'; ?>
 type="text/javascript">
var cal = Calendar.setup({
    onSelect: function(cal) { cal.hide() },
    showTime: true
});
cal.manageFields("f_rangeStart_trigger", "f_rangeStart", "%Y-%m-%d %H:%M:%S");


<?php echo '</script'; ?>
>

<?php echo '<script'; ?>
 language="javascript">
<!--
function check()
{
/*
   if(!checkIP(f1.ip.value) && f1.netmask.value != '32' ) {
	alert('地址为主机名时，掩码应为32');
	return false;
   }   
   if(checkIP(f1.ip.value) && !checknum(f1.netmask.value)) {
	alert('请录入正确掩码');
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
<?php echo '<script'; ?>
>
<?php if ($_smarty_tpl->tpl_vars['_config']->value['LDAP']) {?>
<?php echo $_smarty_tpl->tpl_vars['changelevelstr']->value;?>

<?php }?>
<?php echo '</script'; ?>
>
</body>
</html>



<?php }
}
?>