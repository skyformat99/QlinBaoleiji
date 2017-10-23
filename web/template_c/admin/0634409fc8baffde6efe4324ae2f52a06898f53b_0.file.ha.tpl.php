<?php /* Smarty version 3.1.27, created on 2017-08-15 22:23:50
         compiled from "/opt/freesvr/web/htdocs/freesvr/audit/template/admin/ha.tpl" */ ?>
<?php
/*%%SmartyHeaderCode:1904914106599303f60cb599_24692687%%*/
if(!defined('SMARTY_DIR')) exit('no direct access allowed');
$_valid = $_smarty_tpl->decodeProperties(array (
  'file_dependency' => 
  array (
    '0634409fc8baffde6efe4324ae2f52a06898f53b' => 
    array (
      0 => '/opt/freesvr/web/htdocs/freesvr/audit/template/admin/ha.tpl',
      1 => 1502807024,
      2 => 'file',
    ),
  ),
  'nocache_hash' => '1904914106599303f60cb599_24692687',
  'variables' => 
  array (
    'language' => 0,
    'template_root' => 0,
    'ha' => 0,
    'trnumber' => 0,
    'eth' => 0,
  ),
  'has_nocache_code' => false,
  'version' => '3.1.27',
  'unifunc' => 'content_599303f614dcc3_09257150',
),false);
/*/%%SmartyHeaderCode%%*/
if ($_valid && !is_callable('content_599303f614dcc3_09257150')) {
function content_599303f614dcc3_09257150 ($_smarty_tpl) {

$_smarty_tpl->properties['nocache_hash'] = '1904914106599303f60cb599_24692687';
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
    <li class="me_b"><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an11.jpg" align="absmiddle"/><a href="admin.php?controller=admin_eth&action=serverstatus">服务状态</a><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an33.jpg" align="absmiddle"/></li>
	<li class="me_b"><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an11.jpg" align="absmiddle"/><a href="admin.php?controller=admin_status&action=latest">系统状态</a><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an33.jpg" align="absmiddle"/></li>
	<li class="me_a"><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an1.jpg" align="absmiddle"/><a href="admin.php?controller=admin_config&action=ha">双机配置</a><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an3.jpg" align="absmiddle"/></li>
	<li class="me_b"><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an11.jpg" align="absmiddle"/><a href="admin.php?controller=admin_backup">配置备份</a><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an33.jpg" align="absmiddle"/></li>
	<li class="me_b"><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an11.jpg" align="absmiddle"/><a href="admin.php?controller=admin_backup&action=backup_setting">数据同步</a><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an33.jpg" align="absmiddle"/></li>
	<li class="me_b"><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an11.jpg" align="absmiddle"/><a href="admin.php?controller=admin_backup&action=upgrade">软件升级</a><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an33.jpg" align="absmiddle"/></li>
	<li class="me_b"><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an11.jpg" align="absmiddle"/><a href="admin.php?controller=admin_backup&action=cronjob">定时任务</a><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an33.jpg" align="absmiddle"/></li>
	<li class="me_b"><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an11.jpg" align="absmiddle"/><a href="admin.php?controller=admin_index&action=changelogo">图标上传</a><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an33.jpg" align="absmiddle"/></li>
	<li class="me_b"><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an11.jpg" align="absmiddle"/><a href="admin.php?controller=admin_config&action=notice">系统通知</a><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an33.jpg" align="absmiddle"/></li>
</ul>
</div></td></tr>

  
  <tr><td><table bordercolor="white" cellspacing="0" cellpadding="5" border="0" width="100%" class="BBtable">
<form name="f1" method=post OnSubmit='return check()' action="admin.php?controller=admin_config&action=ha_save">
	<?php $_smarty_tpl->tpl_vars["trnumber"] = new Smarty_Variable(0, null, 0);?>
	<tr><td colspan="3" bgcolor="f7f7f7" align="center" style="font-weight: bold;font-size: 13px;">当&nbsp;&nbsp;&nbsp;&nbsp;前&nbsp;&nbsp;&nbsp;&nbsp;状&nbsp;&nbsp;&nbsp;&nbsp;态</td></tr>
<tr bgcolor="f7f7f7">
<td align="right">配置同步状态：</td>
		<td align=left>&nbsp;&nbsp;&nbsp;&nbsp;<?php if ($_smarty_tpl->tpl_vars['ha']->value['mysqlserver'] == 0) {?>关闭<?php } else {
echo $_smarty_tpl->tpl_vars['ha']->value['mysqlserver'];?>
&nbsp;&nbsp;&nbsp;&nbsp;<img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/<?php if ($_smarty_tpl->tpl_vars['ha']->value['mysqlstatus'] == 0) {?>hong.gif<?php } else { ?>Green.gif<?php }?>" ><?php }?>
		</td>
		
	</tr>

	<tr bgcolor="f7f7f7">
	<td align="right"> 浮动IP：</td>
		<td align=left>&nbsp;&nbsp;&nbsp;&nbsp;<?php if ($_smarty_tpl->tpl_vars['ha']->value['keepalivedstatus'] == 0) {?>关闭<?php } elseif ($_smarty_tpl->tpl_vars['ha']->value['keepalived'] == 1) {
echo $_smarty_tpl->tpl_vars['ha']->value['keepalivedip'];?>
&nbsp;&nbsp;&nbsp;&nbsp;(主)<?php } else { ?>&nbsp;&nbsp;&nbsp;&nbsp;<?php echo $_smarty_tpl->tpl_vars['ha']->value['keepalivedip'];?>
&nbsp;&nbsp;&nbsp;&nbsp;(从)<?php }?>
		</td>
		
	</tr>
	
	<tr><td colspan="3" bgcolor="f7f7f7" align="center" style="font-weight: bold;font-size: 13px;">双&nbsp;&nbsp;&nbsp;&nbsp;机&nbsp;&nbsp;&nbsp;&nbsp;配&nbsp;&nbsp;&nbsp;&nbsp;置</td></tr>
	<tr <?php if ($_smarty_tpl->tpl_vars['trnumber']->value++%2 == 0) {?>bgcolor="f7f7f7"<?php }?>>
	<td align="right">对端IP ：</td>
		<td align=left>
		<input type="text" class="wbk" name="masterip" value="<?php echo $_smarty_tpl->tpl_vars['ha']->value['masterip'];?>
" />
		</td>
		
	</tr>
	<tr bgcolor="f7f7f7">
	<td align="right"> 对端root口令：</td>
		<td align=left>
		<input type="password" class="wbk" name="password" value="<?php echo $_smarty_tpl->tpl_vars['ha']->value['password'];?>
" />
		</td>
	</tr>

	<tr bgcolor="f7f7f7">
	<td align="right"> HA接口：</td>
		<td align=left>
		<select name="eth" >
		<?php if (isset($_smarty_tpl->tpl_vars['smarty']->value['section']['e'])) unset($_smarty_tpl->tpl_vars['smarty']->value['section']['e']);
$_smarty_tpl->tpl_vars['smarty']->value['section']['e']['name'] = 'e';
$_smarty_tpl->tpl_vars['smarty']->value['section']['e']['loop'] = is_array($_loop=$_smarty_tpl->tpl_vars['eth']->value) ? count($_loop) : max(0, (int) $_loop); unset($_loop);
$_smarty_tpl->tpl_vars['smarty']->value['section']['e']['show'] = true;
$_smarty_tpl->tpl_vars['smarty']->value['section']['e']['max'] = $_smarty_tpl->tpl_vars['smarty']->value['section']['e']['loop'];
$_smarty_tpl->tpl_vars['smarty']->value['section']['e']['step'] = 1;
$_smarty_tpl->tpl_vars['smarty']->value['section']['e']['start'] = $_smarty_tpl->tpl_vars['smarty']->value['section']['e']['step'] > 0 ? 0 : $_smarty_tpl->tpl_vars['smarty']->value['section']['e']['loop']-1;
if ($_smarty_tpl->tpl_vars['smarty']->value['section']['e']['show']) {
    $_smarty_tpl->tpl_vars['smarty']->value['section']['e']['total'] = $_smarty_tpl->tpl_vars['smarty']->value['section']['e']['loop'];
    if ($_smarty_tpl->tpl_vars['smarty']->value['section']['e']['total'] == 0)
        $_smarty_tpl->tpl_vars['smarty']->value['section']['e']['show'] = false;
} else
    $_smarty_tpl->tpl_vars['smarty']->value['section']['e']['total'] = 0;
if ($_smarty_tpl->tpl_vars['smarty']->value['section']['e']['show']):

            for ($_smarty_tpl->tpl_vars['smarty']->value['section']['e']['index'] = $_smarty_tpl->tpl_vars['smarty']->value['section']['e']['start'], $_smarty_tpl->tpl_vars['smarty']->value['section']['e']['iteration'] = 1;
                 $_smarty_tpl->tpl_vars['smarty']->value['section']['e']['iteration'] <= $_smarty_tpl->tpl_vars['smarty']->value['section']['e']['total'];
                 $_smarty_tpl->tpl_vars['smarty']->value['section']['e']['index'] += $_smarty_tpl->tpl_vars['smarty']->value['section']['e']['step'], $_smarty_tpl->tpl_vars['smarty']->value['section']['e']['iteration']++):
$_smarty_tpl->tpl_vars['smarty']->value['section']['e']['rownum'] = $_smarty_tpl->tpl_vars['smarty']->value['section']['e']['iteration'];
$_smarty_tpl->tpl_vars['smarty']->value['section']['e']['index_prev'] = $_smarty_tpl->tpl_vars['smarty']->value['section']['e']['index'] - $_smarty_tpl->tpl_vars['smarty']->value['section']['e']['step'];
$_smarty_tpl->tpl_vars['smarty']->value['section']['e']['index_next'] = $_smarty_tpl->tpl_vars['smarty']->value['section']['e']['index'] + $_smarty_tpl->tpl_vars['smarty']->value['section']['e']['step'];
$_smarty_tpl->tpl_vars['smarty']->value['section']['e']['first']      = ($_smarty_tpl->tpl_vars['smarty']->value['section']['e']['iteration'] == 1);
$_smarty_tpl->tpl_vars['smarty']->value['section']['e']['last']       = ($_smarty_tpl->tpl_vars['smarty']->value['section']['e']['iteration'] == $_smarty_tpl->tpl_vars['smarty']->value['section']['e']['total']);
?>
		<option value="<?php echo $_smarty_tpl->tpl_vars['eth']->value[$_smarty_tpl->getVariable('smarty')->value['section']['e']['index']]['i'];?>
"><?php echo $_smarty_tpl->tpl_vars['eth']->value[$_smarty_tpl->getVariable('smarty')->value['section']['e']['index']]['name'];?>
</option>
		<?php endfor; endif; ?>
		</select>
		</td>
	</tr>

	<tr bgcolor="f7f7f7">
	<td align="right"> 浮动IP：</td>
		<td align=left>
		<input type="text" class="wbk" name="slaveip" value="<?php echo $_smarty_tpl->tpl_vars['ha']->value['slaveip'];?>
" />
		</td>
	</tr>
	<tr >
	<tr bgcolor="f7f7f7">
		<td></td>	<td  align="left"><input type="submit"  value="<?php echo $_smarty_tpl->tpl_vars['language']->value['Save'];?>
" class="an_02" ></td>
		</tr>
<input type="hidden" name="ac" value="<?php if ($_smarty_tpl->tpl_vars['ha']->value) {?>edit<?php } else { ?>new<?php }?>"/>
</form>
<form name="f1" method=post OnSubmit='return check()' action="admin.php?controller=admin_config&action=ha_save">
	<tr><td colspan="3" bgcolor="f7f7f7" align="center" style="font-weight: bold;font-size: 13px;">数&nbsp;&nbsp;&nbsp;&nbsp;据&nbsp;&nbsp;&nbsp;&nbsp;库&nbsp;&nbsp;&nbsp;&nbsp;配&nbsp;&nbsp;&nbsp;&nbsp;置</td></tr>
	<td align="right"> 数据库连接服务器：</td>
		<td align=left>
		<input type="text" class="wbk" name="dbaudithost" value="<?php echo $_smarty_tpl->tpl_vars['ha']->value['dbaudithost'];?>
" />
		</td>
	</tr>
	<tr bgcolor="f7f7f7">
		<td></td>	<td  align="left"><input type="submit"  value="<?php echo $_smarty_tpl->tpl_vars['language']->value['Save'];?>
" class="an_02" ></td>
		</tr>
<input type="hidden" name="ac" value="<?php if ($_smarty_tpl->tpl_vars['ha']->value) {?>edit<?php } else { ?>new<?php }?>"/>
</form>
	</table>
	

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

function changestatus(t){
	if(t=='master'){
		document.getElementById('masterip').disabled = 'disabled';
	}else{
		document.getElementById('masterip').disabled = '';
	}
	
}
<?php echo '</script'; ?>
>
</body>
</html>


<?php }
}
?>