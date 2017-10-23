<?php /* Smarty version 3.1.27, created on 2017-05-19 14:33:08
         compiled from "/opt/freesvr/web/htdocs/freesvr/audit/template/admin/eth.tpl" */ ?>
<?php
/*%%SmartyHeaderCode:1896710510591e91a466d0c7_81516259%%*/
if(!defined('SMARTY_DIR')) exit('no direct access allowed');
$_valid = $_smarty_tpl->decodeProperties(array (
  'file_dependency' => 
  array (
    '2f5886a77b69fac4190ce71edd86a88cbd55fd2c' => 
    array (
      0 => '/opt/freesvr/web/htdocs/freesvr/audit/template/admin/eth.tpl',
      1 => 1474793221,
      2 => 'file',
    ),
  ),
  'nocache_hash' => '1896710510591e91a466d0c7_81516259',
  'variables' => 
  array (
    'language' => 0,
    'template_root' => 0,
    'file' => 0,
    'name' => 0,
    'trnumber' => 0,
    'onboot' => 0,
    'systemversion' => 0,
    'ipaddr0' => 0,
    'netmask0' => 0,
    'ipaddr1' => 0,
    'netmask1' => 0,
    'ipaddr2' => 0,
    'netmask2' => 0,
    'ipaddr' => 0,
    'netmask' => 0,
    'gateway' => 0,
    'ipv6init' => 0,
    'ipv6addr' => 0,
    'ipv6gateway' => 0,
    'sshconfig' => 0,
    'eths' => 0,
  ),
  'has_nocache_code' => false,
  'version' => '3.1.27',
  'unifunc' => 'content_591e91a4771fa6_98732135',
),false);
/*/%%SmartyHeaderCode%%*/
if ($_valid && !is_callable('content_591e91a4771fa6_98732135')) {
function content_591e91a4771fa6_98732135 ($_smarty_tpl) {

$_smarty_tpl->properties['nocache_hash'] = '1896710510591e91a466d0c7_81516259';
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
/images/an1.jpg" align="absmiddle"/><a href="admin.php?controller=admin_eth&action=ifcfgeth">网络配置</a><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an3.jpg" align="absmiddle"/></li>
	<li class="me_b"><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an11.jpg" align="absmiddle"/><a href="admin.php?controller=admin_eth&action=config_route">静态路由</a><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an33.jpg" align="absmiddle"/></li>
	<li class="me_b"><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an11.jpg" align="absmiddle"/><a href="admin.php?controller=admin_eth&action=ping">PING</a><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an33.jpg" align="absmiddle"/></li>
  <li class="me_b"><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an11.jpg" align="absmiddle"/><a href="admin.php?controller=admin_eth&action=tracepath">TRACE</a><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an33.jpg" align="absmiddle"/></li>
</ul><span class="back_img"><A href="admin.php?controller=admin_eth&action=ifcfgeth&back=1"><IMG src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/back1.png" 
      width="80" height="30" border="0"></A></span>
</div></td></tr>



  <tr><td><table bordercolor="white" cellspacing="0" cellpadding="5" border="0" width="100%" class="BBtable">
<form name="f1" method=post OnSubmit='return check()' action="admin.php?controller=admin_eth&action=eth_save&file=<?php echo urlencode($_smarty_tpl->tpl_vars['file']->value);?>
&name=<?php echo $_smarty_tpl->tpl_vars['name']->value;?>
">

<tr><th colspan="3" class="list_bg"></th></tr>
	<?php $_smarty_tpl->tpl_vars["trnumber"] = new Smarty_Variable($_smarty_tpl->tpl_vars['trnumber']->value+1, null, 0);?>
	<tr <?php if ($_smarty_tpl->tpl_vars['trnumber']->value%2 == 0) {?>bgcolor="f7f7f7"<?php }?>><td width="33%" align=right>启动:</td>
		<td align=left width="67%">
		<select name="onboot" >
		<option value="yes" <?php if ($_smarty_tpl->tpl_vars['onboot']->value == 'yes') {?>selected<?php }?>>启用</option>
		<option value="no" <?php if ($_smarty_tpl->tpl_vars['onboot']->value == 'no') {?>selected<?php }?>>禁用</option>
		</select>
		</td>		
	</tr>
	<?php if ($_smarty_tpl->tpl_vars['systemversion']->value == 7) {?>
	<tr <?php if ($_smarty_tpl->tpl_vars['trnumber']->value%2 == 0) {?>bgcolor="f7f7f7"<?php }?>>
		<td width="33%" align=right>
		IPv4地址1:		
		</td>
		<td width="67%">
		<input type=text name="ipaddr0" size=35 value="<?php echo $_smarty_tpl->tpl_vars['ipaddr0']->value;?>
" >&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
		掩码1:<select name=netmask0 >
			<?php if (isset($_smarty_tpl->tpl_vars['smarty']->value['section']['i0'])) unset($_smarty_tpl->tpl_vars['smarty']->value['section']['i0']);
$_smarty_tpl->tpl_vars['smarty']->value['section']['i0']['name'] = 'i0';
$_smarty_tpl->tpl_vars['smarty']->value['section']['i0']['loop'] = is_array($_loop=32) ? count($_loop) : max(0, (int) $_loop); unset($_loop);
$_smarty_tpl->tpl_vars['smarty']->value['section']['i0']['show'] = true;
$_smarty_tpl->tpl_vars['smarty']->value['section']['i0']['max'] = $_smarty_tpl->tpl_vars['smarty']->value['section']['i0']['loop'];
$_smarty_tpl->tpl_vars['smarty']->value['section']['i0']['step'] = 1;
$_smarty_tpl->tpl_vars['smarty']->value['section']['i0']['start'] = $_smarty_tpl->tpl_vars['smarty']->value['section']['i0']['step'] > 0 ? 0 : $_smarty_tpl->tpl_vars['smarty']->value['section']['i0']['loop']-1;
if ($_smarty_tpl->tpl_vars['smarty']->value['section']['i0']['show']) {
    $_smarty_tpl->tpl_vars['smarty']->value['section']['i0']['total'] = $_smarty_tpl->tpl_vars['smarty']->value['section']['i0']['loop'];
    if ($_smarty_tpl->tpl_vars['smarty']->value['section']['i0']['total'] == 0)
        $_smarty_tpl->tpl_vars['smarty']->value['section']['i0']['show'] = false;
} else
    $_smarty_tpl->tpl_vars['smarty']->value['section']['i0']['total'] = 0;
if ($_smarty_tpl->tpl_vars['smarty']->value['section']['i0']['show']):

            for ($_smarty_tpl->tpl_vars['smarty']->value['section']['i0']['index'] = $_smarty_tpl->tpl_vars['smarty']->value['section']['i0']['start'], $_smarty_tpl->tpl_vars['smarty']->value['section']['i0']['iteration'] = 1;
                 $_smarty_tpl->tpl_vars['smarty']->value['section']['i0']['iteration'] <= $_smarty_tpl->tpl_vars['smarty']->value['section']['i0']['total'];
                 $_smarty_tpl->tpl_vars['smarty']->value['section']['i0']['index'] += $_smarty_tpl->tpl_vars['smarty']->value['section']['i0']['step'], $_smarty_tpl->tpl_vars['smarty']->value['section']['i0']['iteration']++):
$_smarty_tpl->tpl_vars['smarty']->value['section']['i0']['rownum'] = $_smarty_tpl->tpl_vars['smarty']->value['section']['i0']['iteration'];
$_smarty_tpl->tpl_vars['smarty']->value['section']['i0']['index_prev'] = $_smarty_tpl->tpl_vars['smarty']->value['section']['i0']['index'] - $_smarty_tpl->tpl_vars['smarty']->value['section']['i0']['step'];
$_smarty_tpl->tpl_vars['smarty']->value['section']['i0']['index_next'] = $_smarty_tpl->tpl_vars['smarty']->value['section']['i0']['index'] + $_smarty_tpl->tpl_vars['smarty']->value['section']['i0']['step'];
$_smarty_tpl->tpl_vars['smarty']->value['section']['i0']['first']      = ($_smarty_tpl->tpl_vars['smarty']->value['section']['i0']['iteration'] == 1);
$_smarty_tpl->tpl_vars['smarty']->value['section']['i0']['last']       = ($_smarty_tpl->tpl_vars['smarty']->value['section']['i0']['iteration'] == $_smarty_tpl->tpl_vars['smarty']->value['section']['i0']['total']);
?>
			<option value="<?php echo $_smarty_tpl->getVariable('smarty')->value['section']['i0']['index']+1;?>
" <?php if ($_smarty_tpl->tpl_vars['netmask0']->value == $_smarty_tpl->getVariable('smarty')->value['section']['i0']['index']+1) {?>selected<?php }?>><?php echo $_smarty_tpl->getVariable('smarty')->value['section']['i0']['index']+1;?>
</option>
			<?php endfor; endif; ?>
			</select>
	  </td>
	</tr>
	<tr <?php if ($_smarty_tpl->tpl_vars['trnumber']->value%2 == 0) {?>bgcolor=""<?php }?>>
		<td width="33%" align=right>
		IPv4地址2:		
		</td>
		<td width="67%">
		<input type=text name="ipaddr1" size=35 value="<?php echo $_smarty_tpl->tpl_vars['ipaddr1']->value;?>
" >&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
		掩码2:<select name=netmask1 >
			<?php if (isset($_smarty_tpl->tpl_vars['smarty']->value['section']['i1'])) unset($_smarty_tpl->tpl_vars['smarty']->value['section']['i1']);
$_smarty_tpl->tpl_vars['smarty']->value['section']['i1']['name'] = 'i1';
$_smarty_tpl->tpl_vars['smarty']->value['section']['i1']['loop'] = is_array($_loop=32) ? count($_loop) : max(0, (int) $_loop); unset($_loop);
$_smarty_tpl->tpl_vars['smarty']->value['section']['i1']['show'] = true;
$_smarty_tpl->tpl_vars['smarty']->value['section']['i1']['max'] = $_smarty_tpl->tpl_vars['smarty']->value['section']['i1']['loop'];
$_smarty_tpl->tpl_vars['smarty']->value['section']['i1']['step'] = 1;
$_smarty_tpl->tpl_vars['smarty']->value['section']['i1']['start'] = $_smarty_tpl->tpl_vars['smarty']->value['section']['i1']['step'] > 0 ? 0 : $_smarty_tpl->tpl_vars['smarty']->value['section']['i1']['loop']-1;
if ($_smarty_tpl->tpl_vars['smarty']->value['section']['i1']['show']) {
    $_smarty_tpl->tpl_vars['smarty']->value['section']['i1']['total'] = $_smarty_tpl->tpl_vars['smarty']->value['section']['i1']['loop'];
    if ($_smarty_tpl->tpl_vars['smarty']->value['section']['i1']['total'] == 0)
        $_smarty_tpl->tpl_vars['smarty']->value['section']['i1']['show'] = false;
} else
    $_smarty_tpl->tpl_vars['smarty']->value['section']['i1']['total'] = 0;
if ($_smarty_tpl->tpl_vars['smarty']->value['section']['i1']['show']):

            for ($_smarty_tpl->tpl_vars['smarty']->value['section']['i1']['index'] = $_smarty_tpl->tpl_vars['smarty']->value['section']['i1']['start'], $_smarty_tpl->tpl_vars['smarty']->value['section']['i1']['iteration'] = 1;
                 $_smarty_tpl->tpl_vars['smarty']->value['section']['i1']['iteration'] <= $_smarty_tpl->tpl_vars['smarty']->value['section']['i1']['total'];
                 $_smarty_tpl->tpl_vars['smarty']->value['section']['i1']['index'] += $_smarty_tpl->tpl_vars['smarty']->value['section']['i1']['step'], $_smarty_tpl->tpl_vars['smarty']->value['section']['i1']['iteration']++):
$_smarty_tpl->tpl_vars['smarty']->value['section']['i1']['rownum'] = $_smarty_tpl->tpl_vars['smarty']->value['section']['i1']['iteration'];
$_smarty_tpl->tpl_vars['smarty']->value['section']['i1']['index_prev'] = $_smarty_tpl->tpl_vars['smarty']->value['section']['i1']['index'] - $_smarty_tpl->tpl_vars['smarty']->value['section']['i1']['step'];
$_smarty_tpl->tpl_vars['smarty']->value['section']['i1']['index_next'] = $_smarty_tpl->tpl_vars['smarty']->value['section']['i1']['index'] + $_smarty_tpl->tpl_vars['smarty']->value['section']['i1']['step'];
$_smarty_tpl->tpl_vars['smarty']->value['section']['i1']['first']      = ($_smarty_tpl->tpl_vars['smarty']->value['section']['i1']['iteration'] == 1);
$_smarty_tpl->tpl_vars['smarty']->value['section']['i1']['last']       = ($_smarty_tpl->tpl_vars['smarty']->value['section']['i1']['iteration'] == $_smarty_tpl->tpl_vars['smarty']->value['section']['i1']['total']);
?>
			<option value="<?php echo $_smarty_tpl->getVariable('smarty')->value['section']['i1']['index']+1;?>
" <?php if ($_smarty_tpl->tpl_vars['netmask1']->value == $_smarty_tpl->getVariable('smarty')->value['section']['i1']['index']+1) {?>selected<?php }?>><?php echo $_smarty_tpl->getVariable('smarty')->value['section']['i1']['index']+1;?>
</option>
			<?php endfor; endif; ?>
			</select>
	  </td>
	</tr>
	<tr <?php if ($_smarty_tpl->tpl_vars['trnumber']->value%2 == 0) {?>bgcolor="f7f7f7"<?php }?>>
		<td width="33%" align=right>
		IPv4地址3:		
		</td>
		<td width="67%">
		<input type=text name="ipaddr2" size=35 value="<?php echo $_smarty_tpl->tpl_vars['ipaddr2']->value;?>
" >&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
		掩码3:<select name=netmask2 >
			<?php if (isset($_smarty_tpl->tpl_vars['smarty']->value['section']['i2'])) unset($_smarty_tpl->tpl_vars['smarty']->value['section']['i2']);
$_smarty_tpl->tpl_vars['smarty']->value['section']['i2']['name'] = 'i2';
$_smarty_tpl->tpl_vars['smarty']->value['section']['i2']['loop'] = is_array($_loop=32) ? count($_loop) : max(0, (int) $_loop); unset($_loop);
$_smarty_tpl->tpl_vars['smarty']->value['section']['i2']['show'] = true;
$_smarty_tpl->tpl_vars['smarty']->value['section']['i2']['max'] = $_smarty_tpl->tpl_vars['smarty']->value['section']['i2']['loop'];
$_smarty_tpl->tpl_vars['smarty']->value['section']['i2']['step'] = 1;
$_smarty_tpl->tpl_vars['smarty']->value['section']['i2']['start'] = $_smarty_tpl->tpl_vars['smarty']->value['section']['i2']['step'] > 0 ? 0 : $_smarty_tpl->tpl_vars['smarty']->value['section']['i2']['loop']-1;
if ($_smarty_tpl->tpl_vars['smarty']->value['section']['i2']['show']) {
    $_smarty_tpl->tpl_vars['smarty']->value['section']['i2']['total'] = $_smarty_tpl->tpl_vars['smarty']->value['section']['i2']['loop'];
    if ($_smarty_tpl->tpl_vars['smarty']->value['section']['i2']['total'] == 0)
        $_smarty_tpl->tpl_vars['smarty']->value['section']['i2']['show'] = false;
} else
    $_smarty_tpl->tpl_vars['smarty']->value['section']['i2']['total'] = 0;
if ($_smarty_tpl->tpl_vars['smarty']->value['section']['i2']['show']):

            for ($_smarty_tpl->tpl_vars['smarty']->value['section']['i2']['index'] = $_smarty_tpl->tpl_vars['smarty']->value['section']['i2']['start'], $_smarty_tpl->tpl_vars['smarty']->value['section']['i2']['iteration'] = 1;
                 $_smarty_tpl->tpl_vars['smarty']->value['section']['i2']['iteration'] <= $_smarty_tpl->tpl_vars['smarty']->value['section']['i2']['total'];
                 $_smarty_tpl->tpl_vars['smarty']->value['section']['i2']['index'] += $_smarty_tpl->tpl_vars['smarty']->value['section']['i2']['step'], $_smarty_tpl->tpl_vars['smarty']->value['section']['i2']['iteration']++):
$_smarty_tpl->tpl_vars['smarty']->value['section']['i2']['rownum'] = $_smarty_tpl->tpl_vars['smarty']->value['section']['i2']['iteration'];
$_smarty_tpl->tpl_vars['smarty']->value['section']['i2']['index_prev'] = $_smarty_tpl->tpl_vars['smarty']->value['section']['i2']['index'] - $_smarty_tpl->tpl_vars['smarty']->value['section']['i2']['step'];
$_smarty_tpl->tpl_vars['smarty']->value['section']['i2']['index_next'] = $_smarty_tpl->tpl_vars['smarty']->value['section']['i2']['index'] + $_smarty_tpl->tpl_vars['smarty']->value['section']['i2']['step'];
$_smarty_tpl->tpl_vars['smarty']->value['section']['i2']['first']      = ($_smarty_tpl->tpl_vars['smarty']->value['section']['i2']['iteration'] == 1);
$_smarty_tpl->tpl_vars['smarty']->value['section']['i2']['last']       = ($_smarty_tpl->tpl_vars['smarty']->value['section']['i2']['iteration'] == $_smarty_tpl->tpl_vars['smarty']->value['section']['i2']['total']);
?>
			<option value="<?php echo $_smarty_tpl->getVariable('smarty')->value['section']['i2']['index']+1;?>
" <?php if ($_smarty_tpl->tpl_vars['netmask2']->value == $_smarty_tpl->getVariable('smarty')->value['section']['i2']['index']+1) {?>selected<?php }?>><?php echo $_smarty_tpl->getVariable('smarty')->value['section']['i2']['index']+1;?>
</option>
			<?php endfor; endif; ?>
			</select>
	  </td>
	</tr>
	<?php } else { ?>
	<?php $_smarty_tpl->tpl_vars["trnumber"] = new Smarty_Variable(0, null, 0);?>
	<tr <?php if ($_smarty_tpl->tpl_vars['trnumber']->value%2 == 0) {?>bgcolor="f7f7f7"<?php }?>>
		<td width="33%" align=right>
		IPv4地址:		
		</td>
		<td width="67%">
		<input type=text name="ipaddr" size=35 value="<?php echo $_smarty_tpl->tpl_vars['ipaddr']->value;?>
" >
	  </td>
	</tr>
	
	<?php $_smarty_tpl->tpl_vars["trnumber"] = new Smarty_Variable($_smarty_tpl->tpl_vars['trnumber']->value+1, null, 0);?>
	<tr <?php if ($_smarty_tpl->tpl_vars['trnumber']->value%2 == 0) {?>bgcolor="f7f7f7"<?php }?>>
		<td width="33%" align=right>
		IPv4掩码:		
		</td>
		<td width="67%">
		<input type=text name="netmask" size=35 value="<?php echo $_smarty_tpl->tpl_vars['netmask']->value;?>
" >
	  </td>
	</tr>
	<?php }?>
<?php $_smarty_tpl->tpl_vars["trnumber"] = new Smarty_Variable($_smarty_tpl->tpl_vars['trnumber']->value+1, null, 0);?>
	<tr <?php if ($_smarty_tpl->tpl_vars['trnumber']->value%2 == 0) {?>bgcolor="f7f7f7"<?php }?>>
		<td width="33%" align=right>
		IPv4网关:		
		</td>
		<td width="67%">
		<input type=text name="gateway" size=35 value="<?php echo $_smarty_tpl->tpl_vars['gateway']->value;?>
" >
	  </td>
	</tr>
<?php $_smarty_tpl->tpl_vars["trnumber"] = new Smarty_Variable($_smarty_tpl->tpl_vars['trnumber']->value+1, null, 0);?>
	<tr <?php if ($_smarty_tpl->tpl_vars['trnumber']->value%2 == 0) {?>bgcolor="f7f7f7"<?php }?>><td width="33%" align=right>IPv6启用:</td>
		<td align=left width="67%">
		<select name="ipv6init" >
		<option value="yes" <?php if ($_smarty_tpl->tpl_vars['ipv6init']->value == 'yes') {?>selected<?php }?>>打开</option>
		<option value="no" <?php if ($_smarty_tpl->tpl_vars['ipv6init']->value == 'no' || !$_smarty_tpl->tpl_vars['ipv6init']->value) {?>selected<?php }?>>关闭</option>
		</select>
		</td>		
	</tr>
<?php $_smarty_tpl->tpl_vars["trnumber"] = new Smarty_Variable($_smarty_tpl->tpl_vars['trnumber']->value+1, null, 0);?>
	<tr <?php if ($_smarty_tpl->tpl_vars['trnumber']->value%2 == 0) {?>bgcolor="f7f7f7"<?php }?>><td width="33%" align=right>IPv6地址:</td>
		<td align=left width="67%">
		<input type="text" class="wbk" name="ipv6addr" value="<?php echo $_smarty_tpl->tpl_vars['ipv6addr']->value;?>
" />	
		</td>
		
	</tr>
	<?php $_smarty_tpl->tpl_vars["trnumber"] = new Smarty_Variable($_smarty_tpl->tpl_vars['trnumber']->value+1, null, 0);?>
	<tr <?php if ($_smarty_tpl->tpl_vars['trnumber']->value%2 == 0) {?>bgcolor="f7f7f7"<?php }?>><td width="33%" align=right>IPv6网关:</td>
		<td align=left width="67%">
		<input type="text" class="wbk" name="ipv6gateway" value="<?php echo $_smarty_tpl->tpl_vars['ipv6gateway']->value;?>
" />	
		</td>		
	</tr>
<?php if ($_smarty_tpl->tpl_vars['name']->value == 'ETH0' || $_smarty_tpl->tpl_vars['name']->value == 'BR0') {?>
<?php $_smarty_tpl->tpl_vars["trnumber"] = new Smarty_Variable($_smarty_tpl->tpl_vars['trnumber']->value+1, null, 0);?>
	<tr <?php if ($_smarty_tpl->tpl_vars['trnumber']->value%2 == 0) {?>bgcolor="f7f7f7"<?php }?>><td width="33%" align=right>DNS<?php echo $_smarty_tpl->tpl_vars['language']->value['Server'];?>
一:</td>
		<td align=left width="67%">
		<input type="text" class="wbk" name="nameserver1" value="<?php echo $_smarty_tpl->tpl_vars['sshconfig']->value['nameserver1'];?>
" />	
		</td>
		
	</tr>
	<?php $_smarty_tpl->tpl_vars["trnumber"] = new Smarty_Variable($_smarty_tpl->tpl_vars['trnumber']->value+1, null, 0);?>
	<tr <?php if ($_smarty_tpl->tpl_vars['trnumber']->value%2 == 0) {?>bgcolor="f7f7f7"<?php }?>><td width="33%" align=right>DNS<?php echo $_smarty_tpl->tpl_vars['language']->value['Server'];?>
二:</td>
		<td align=left width="67%">
		<input type="text" class="wbk" name="nameserver2" value="<?php echo $_smarty_tpl->tpl_vars['sshconfig']->value['nameserver2'];?>
" />	
		</td>		
	</tr>
<?php }?>	
<?php if ($_GET['name'] == 'BR0') {?>
<?php $_smarty_tpl->tpl_vars["trnumber"] = new Smarty_Variable($_smarty_tpl->tpl_vars['trnumber']->value+1, null, 0);?>
	<tr <?php if ($_smarty_tpl->tpl_vars['trnumber']->value%2 == 0) {?>bgcolor="f7f7f7"<?php }?>><td width="33%" align=right>绑定网卡:</td>
		<td align=left width="67%">
		<?php if (isset($_smarty_tpl->tpl_vars['smarty']->value['section']['e'])) unset($_smarty_tpl->tpl_vars['smarty']->value['section']['e']);
$_smarty_tpl->tpl_vars['smarty']->value['section']['e']['name'] = 'e';
$_smarty_tpl->tpl_vars['smarty']->value['section']['e']['loop'] = is_array($_loop=$_smarty_tpl->tpl_vars['eths']->value) ? count($_loop) : max(0, (int) $_loop); unset($_loop);
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
		<input type='checkbox' name='eths[]' value='<?php echo $_smarty_tpl->tpl_vars['eths']->value[$_smarty_tpl->getVariable('smarty')->value['section']['e']['index']]['file'];?>
' <?php if ($_smarty_tpl->tpl_vars['eths']->value[$_smarty_tpl->getVariable('smarty')->value['section']['e']['index']]['br0']) {?>checked<?php }?> /><?php echo $_smarty_tpl->tpl_vars['eths']->value[$_smarty_tpl->getVariable('smarty')->value['section']['e']['index']]['name'];?>
&nbsp;&nbsp;&nbsp;&nbsp;
		<?php endfor; endif; ?>
		</td>		
	</tr>
<?php }?>
	<?php $_smarty_tpl->tpl_vars["trnumber"] = new Smarty_Variable($_smarty_tpl->tpl_vars['trnumber']->value+1, null, 0);?>
	<tr <?php if ($_smarty_tpl->tpl_vars['trnumber']->value%2 == 0) {?>bgcolor="f7f7f7"<?php }?>>
			<td  align="center" colspan=2>
			<?php if ($_GET['name'] == 'BR0') {?><input  type="submit" name="ac" value="网卡绑定" class="an_02">&nbsp;&nbsp;<?php }?><input  type="submit" onclick="return reset();" value="重启网络" class="an_02">&nbsp;&nbsp;<input type="submit"  value="<?php echo $_smarty_tpl->tpl_vars['language']->value['Save'];?>
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
function reset(){
	if(confim('确定要重<?php echo $_smarty_tpl->tpl_vars['language']->value['new'];
echo $_smarty_tpl->tpl_vars['language']->value['Start'];?>
吗?')){
		document.location='admin.php?controller=admin_eth&action=network_restart'
		return false;
	}
	return false;
}
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