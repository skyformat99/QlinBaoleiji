<?php /* Smarty version 3.1.27, created on 2017-06-27 09:28:30
         compiled from "/opt/freesvr/web/htdocs/freesvr/audit/template/admin/loginreports_list.tpl" */ ?>
<?php
/*%%SmartyHeaderCode:7185491145951b4be3267d2_56808723%%*/
if(!defined('SMARTY_DIR')) exit('no direct access allowed');
$_valid = $_smarty_tpl->decodeProperties(array (
  'file_dependency' => 
  array (
    '39204d0ea199a9a75b085814683b9f57e3f6921e' => 
    array (
      0 => '/opt/freesvr/web/htdocs/freesvr/audit/template/admin/loginreports_list.tpl',
      1 => 1474793216,
      2 => 'file',
    ),
  ),
  'nocache_hash' => '7185491145951b4be3267d2_56808723',
  'variables' => 
  array (
    'language' => 0,
    'template_root' => 0,
    '_config' => 0,
    'alluser' => 0,
    'allserver' => 0,
    'curr_url' => 0,
    'f_rangeStart' => 0,
    'f_rangeEnd' => 0,
    'allsession' => 0,
    'session_num' => 0,
    'page_list' => 0,
    'curr_page' => 0,
    'total_page' => 0,
    'items_per_page' => 0,
    'now_table_name' => 0,
    'admin_level' => 0,
    'table_list' => 0,
    'data' => 0,
    'info' => 0,
    'changelevelstr' => 0,
  ),
  'has_nocache_code' => false,
  'version' => '3.1.27',
  'unifunc' => 'content_5951b4be45b316_26515018',
),false);
/*/%%SmartyHeaderCode%%*/
if ($_valid && !is_callable('content_5951b4be45b316_26515018')) {
function content_5951b4be45b316_26515018 ($_smarty_tpl) {
if (!is_callable('smarty_modifier_date_format')) require_once '/opt/freesvr/web/htdocs/freesvr/audit/smarty/plugins/modifier.date_format.php';

$_smarty_tpl->properties['nocache_hash'] = '7185491145951b4be3267d2_56808723';
?>
<!doctype html public "-//w3c//dtd html 4.0 transitional//en">
<html>
<head>
<title><?php echo $_smarty_tpl->tpl_vars['language']->value['LoingReport'];
echo $_smarty_tpl->tpl_vars['language']->value['List'];?>
</title>
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
<link type="text/css" rel="stylesheet" href="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/cssjs/jscal2.css" />
<link type="text/css" rel="stylesheet" href="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/cssjs/border-radius.css" />
<?php echo '<script'; ?>
 src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/cssjs/jscal2.js"><?php echo '</script'; ?>
>
<?php echo '<script'; ?>
 src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/cssjs/cn.js"><?php echo '</script'; ?>
>
<?php echo '<script'; ?>
 type="text/javascript">
function changetype(sid){
document.getElementById(sid).checked=true;
}
function searchit(){
	url = "admin.php?controller=admin_reports&action=logintims";
	url += "&f_rangeStart="+document.report.elements.f_rangeStart.value;
	url += "&f_rangeEnd="+document.report.elements.f_rangeEnd.value;
	<?php if ($_smarty_tpl->tpl_vars['_config']->value['LDAP']) {?>
	<?php if ($_smarty_tpl->tpl_vars['_config']->value['TREEMODE']) {?>
	var obj1=document.getElementById('groupiddh');	
	gid=obj1.value;
	<?php } else { ?>
	for(var i=1; true; i++){
		var obj=document.getElementById('groupid'+i);
		if(obj!=null&&obj.options.selectedIndex>-1){
			gid=obj.options[obj.options.selectedIndex].value;
			continue;
		}
		break;
	}
	<?php }?>
	url += "&groupid="+gid;
	<?php }?>
	document.report.action = url;
	document.report.submit();
	return false;
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
<?php if ($_GET['from'] == 'configreport') {?>
<li class="me_a"><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an1.jpg" align="absmiddle"/><a href="admin.php?controller=admin_reports&action=configreport">报表配置</a><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an3.jpg" align="absmiddle"/></li>
<li class="me_b"><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an11.jpg" align="absmiddle"/><a href="admin.php?controller=admin_reports&action=cronreports">报表自动生成配置</a><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an33.jpg" align="absmiddle"/></li>
<li class="me_b"><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an11.jpg" align="absmiddle"/><a href="admin.php?controller=admin_reports&action=downloadcronreport">下载报表</a><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an33.jpg" align="absmiddle"/></li>
<?php } else { ?>
    <li class="me_b"><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an11.jpg" align="absmiddle"/><a href="admin.php?controller=admin_reports&action=loginacct">授权明细</a><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an33.jpg" align="absmiddle"/></li>
<?php if ($_SESSION['ADMIN_LEVEL'] == 1 || $_SESSION['ADMIN_LEVEL'] == 2 || $_SESSION['ADMIN_LEVEL'] == 21 || $_SESSION['ADMIN_LEVEL'] == 3 || $_SESSION['ADMIN_LEVEL'] == 101) {?>	
    <li class="me_a"><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an1.jpg" align="absmiddle"/><a href="admin.php?controller=admin_reports&action=logintims">登录统计</a><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an3.jpg" align="absmiddle"/></li>
<?php }?>
<?php if ($_SESSION['ADMIN_LEVEL'] == 1 || $_SESSION['ADMIN_LEVEL'] == 2 || $_SESSION['ADMIN_LEVEL'] == 21 || $_SESSION['ADMIN_LEVEL'] == 3 || $_SESSION['ADMIN_LEVEL'] == 101) {?>
	<li class="me_b"><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an11.jpg" align="absmiddle"/><a href="admin.php?controller=admin_reports&action=loginfailed">登录尝试</a><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an33.jpg" align="absmiddle"/></li>
<?php }?>
	<li class="me_b"><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an11.jpg" align="absmiddle"/><a href="admin.php?controller=admin_reports&action=devloginreport">系统登录报表</a><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an33.jpg" align="absmiddle"/></li>
	<li class="me_b"><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an11.jpg" align="absmiddle"/><a href="admin.php?controller=admin_reports&action=apploginreport">应用登录报表</a><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an33.jpg" align="absmiddle"/></li>
	<li class="me_b"><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an11.jpg" align="absmiddle"/><a href="admin.php?controller=admin_reports&action=workflow_approve">审批报表</a><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an33.jpg" align="absmiddle"/></li>
<?php }?>
</ul><?php if ($_GET['from'] == 'configreport') {?><span class="back_img"><A href="admin.php?controller=admin_reports&action=configreport"><IMG src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/back1.png" width="80" height="30" border="0"></A></span><?php }?>
</div></td></tr>

 
  <tr>
    <td class="main_content">
<form action="<?php echo $_smarty_tpl->tpl_vars['curr_url']->value;?>
" method="post" name="report" >

		<?php echo $_smarty_tpl->getSubTemplate ("select_sgroup_ajax.tpl", $_smarty_tpl->cache_id, $_smarty_tpl->compile_id, 0, $_smarty_tpl->cache_lifetime, array(), 0);
?>
          
<?php echo $_smarty_tpl->tpl_vars['language']->value['Starttime'];?>
：<input type="text" class="wbk"  name="f_rangeStart" size="13" id="f_rangeStart" value="<?php echo smarty_modifier_date_format($_smarty_tpl->tpl_vars['f_rangeStart']->value,'%Y-%m-%d');?>
" />
 <input type="button" onclick="changetype('timetype3')" id="f_rangeStart_trigger" name="f_rangeStart_trigger" value="<?php echo $_smarty_tpl->tpl_vars['language']->value['Edittime'];?>
"  class="wbk">


 <?php echo $_smarty_tpl->tpl_vars['language']->value['Endtime'];?>
：
<input  type="text" class="wbk" name="f_rangeEnd" size="13" id="f_rangeEnd"  value="<?php echo smarty_modifier_date_format($_smarty_tpl->tpl_vars['f_rangeEnd']->value,'%Y-%m-%d');?>
" />
 <input type="button" onclick="changetype('timetype3')" id="f_rangeEnd_trigger" name="f_rangeEnd_trigger" value="<?php echo $_smarty_tpl->tpl_vars['language']->value['Edittime'];?>
"  class="wbk">
 &nbsp;&nbsp;<input type="submit" height="35" align="middle" onClick="return searchit();" border="0" value=" 确定 " class="bnnew2"/>
     &nbsp;&nbsp;
	 
</form> 
	  </td>
  </tr>
  <?php echo '<script'; ?>
 type="text/javascript">
                  new Calendar({
                          inputField: "f_rangeStart",
                          dateFormat: "%Y-%m-%d",
                          trigger: "f_rangeStart_trigger",
                          bottomBar: false,
                          onSelect: function() {
                                  var date = Calendar.intToDate(this.selection.get());
                                 
                                  this.hide();
                          }
                  });
                  new Calendar({
                      inputField: "f_rangeEnd",
                      dateFormat: "%Y-%m-%d",
                      trigger: "f_rangeEnd_trigger",
                      bottomBar: false,
                      onSelect: function() {
                              var date = Calendar.intToDate(this.selection.get());
                             
                              this.hide();
                      }
              });
                <?php echo '</script'; ?>
>
  <tr><td><table bordercolor="white" cellspacing="0" cellpadding="5" border="0" width="100%" class="BBtable">
					<tr>
						<th class="list_bg"   width="10%"><?php echo $_smarty_tpl->tpl_vars['language']->value['Username'];?>
</th>
						<th class="list_bg"   width="10%">别名</th>
						<th class="list_bg"   width="10%">运维组</th>
						<th class="list_bg"   width="5%">ssh</th>
						<th class="list_bg"   width="10%">telnet</th>
						<th class="list_bg"   width="5%">rdp</th>
						<th class="list_bg"   width="5%">应用</th>
						<th class="list_bg"   width="5%">vnc</th>
						<th class="list_bg"   width="5%">ftp</th>
						<th class="list_bg"   width="5%">sftp</th>
						<th class="list_bg"   width="10%">前台</th>
						<th class="list_bg"   width="10%">X11</th>
						<th class="list_bg"   width="15%"><?php echo $_smarty_tpl->tpl_vars['language']->value['total'];?>
</th>
					</tr>
					<?php if (isset($_smarty_tpl->tpl_vars['smarty']->value['section']['t'])) unset($_smarty_tpl->tpl_vars['smarty']->value['section']['t']);
$_smarty_tpl->tpl_vars['smarty']->value['section']['t']['name'] = 't';
$_smarty_tpl->tpl_vars['smarty']->value['section']['t']['loop'] = is_array($_loop=$_smarty_tpl->tpl_vars['allsession']->value) ? count($_loop) : max(0, (int) $_loop); unset($_loop);
$_smarty_tpl->tpl_vars['smarty']->value['section']['t']['show'] = true;
$_smarty_tpl->tpl_vars['smarty']->value['section']['t']['max'] = $_smarty_tpl->tpl_vars['smarty']->value['section']['t']['loop'];
$_smarty_tpl->tpl_vars['smarty']->value['section']['t']['step'] = 1;
$_smarty_tpl->tpl_vars['smarty']->value['section']['t']['start'] = $_smarty_tpl->tpl_vars['smarty']->value['section']['t']['step'] > 0 ? 0 : $_smarty_tpl->tpl_vars['smarty']->value['section']['t']['loop']-1;
if ($_smarty_tpl->tpl_vars['smarty']->value['section']['t']['show']) {
    $_smarty_tpl->tpl_vars['smarty']->value['section']['t']['total'] = $_smarty_tpl->tpl_vars['smarty']->value['section']['t']['loop'];
    if ($_smarty_tpl->tpl_vars['smarty']->value['section']['t']['total'] == 0)
        $_smarty_tpl->tpl_vars['smarty']->value['section']['t']['show'] = false;
} else
    $_smarty_tpl->tpl_vars['smarty']->value['section']['t']['total'] = 0;
if ($_smarty_tpl->tpl_vars['smarty']->value['section']['t']['show']):

            for ($_smarty_tpl->tpl_vars['smarty']->value['section']['t']['index'] = $_smarty_tpl->tpl_vars['smarty']->value['section']['t']['start'], $_smarty_tpl->tpl_vars['smarty']->value['section']['t']['iteration'] = 1;
                 $_smarty_tpl->tpl_vars['smarty']->value['section']['t']['iteration'] <= $_smarty_tpl->tpl_vars['smarty']->value['section']['t']['total'];
                 $_smarty_tpl->tpl_vars['smarty']->value['section']['t']['index'] += $_smarty_tpl->tpl_vars['smarty']->value['section']['t']['step'], $_smarty_tpl->tpl_vars['smarty']->value['section']['t']['iteration']++):
$_smarty_tpl->tpl_vars['smarty']->value['section']['t']['rownum'] = $_smarty_tpl->tpl_vars['smarty']->value['section']['t']['iteration'];
$_smarty_tpl->tpl_vars['smarty']->value['section']['t']['index_prev'] = $_smarty_tpl->tpl_vars['smarty']->value['section']['t']['index'] - $_smarty_tpl->tpl_vars['smarty']->value['section']['t']['step'];
$_smarty_tpl->tpl_vars['smarty']->value['section']['t']['index_next'] = $_smarty_tpl->tpl_vars['smarty']->value['section']['t']['index'] + $_smarty_tpl->tpl_vars['smarty']->value['section']['t']['step'];
$_smarty_tpl->tpl_vars['smarty']->value['section']['t']['first']      = ($_smarty_tpl->tpl_vars['smarty']->value['section']['t']['iteration'] == 1);
$_smarty_tpl->tpl_vars['smarty']->value['section']['t']['last']       = ($_smarty_tpl->tpl_vars['smarty']->value['section']['t']['iteration'] == $_smarty_tpl->tpl_vars['smarty']->value['section']['t']['total']);
?>
					<tr <?php if ($_smarty_tpl->getVariable('smarty')->value['section']['t']['index']%2 == 0) {?>bgcolor="f7f7f7"<?php }?>>
						<td><?php echo $_smarty_tpl->tpl_vars['allsession']->value[$_smarty_tpl->getVariable('smarty')->value['section']['t']['index']]['username'];?>
</td>
						<td><?php echo $_smarty_tpl->tpl_vars['allsession']->value[$_smarty_tpl->getVariable('smarty')->value['section']['t']['index']]['realname'];?>
</td>
						<td><?php echo $_smarty_tpl->tpl_vars['allsession']->value[$_smarty_tpl->getVariable('smarty')->value['section']['t']['index']]['groupname'];?>
</td>
						<td><?php if (!$_smarty_tpl->tpl_vars['allsession']->value[$_smarty_tpl->getVariable('smarty')->value['section']['t']['index']]['sct']) {?>0<?php } else {
echo $_smarty_tpl->tpl_vars['allsession']->value[$_smarty_tpl->getVariable('smarty')->value['section']['t']['index']]['sct'];
}?></td>
						<td><?php if (!$_smarty_tpl->tpl_vars['allsession']->value[$_smarty_tpl->getVariable('smarty')->value['section']['t']['index']]['tct']) {?>0<?php } else {
echo $_smarty_tpl->tpl_vars['allsession']->value[$_smarty_tpl->getVariable('smarty')->value['section']['t']['index']]['tct'];
}?></td>
						<td><?php if (!$_smarty_tpl->tpl_vars['allsession']->value[$_smarty_tpl->getVariable('smarty')->value['section']['t']['index']]['rct']) {?>0<?php } else {
echo $_smarty_tpl->tpl_vars['allsession']->value[$_smarty_tpl->getVariable('smarty')->value['section']['t']['index']]['rct'];
}?></td>
						<td><?php if (!$_smarty_tpl->tpl_vars['allsession']->value[$_smarty_tpl->getVariable('smarty')->value['section']['t']['index']]['act']) {?>0<?php } else {
echo $_smarty_tpl->tpl_vars['allsession']->value[$_smarty_tpl->getVariable('smarty')->value['section']['t']['index']]['act'];
}?></td>
						<td><?php if (!$_smarty_tpl->tpl_vars['allsession']->value[$_smarty_tpl->getVariable('smarty')->value['section']['t']['index']]['vct']) {?>0<?php } else {
echo $_smarty_tpl->tpl_vars['allsession']->value[$_smarty_tpl->getVariable('smarty')->value['section']['t']['index']]['vct'];
}?></td>
						<td><?php if (!$_smarty_tpl->tpl_vars['allsession']->value[$_smarty_tpl->getVariable('smarty')->value['section']['t']['index']]['fct']) {?>0<?php } else {
echo $_smarty_tpl->tpl_vars['allsession']->value[$_smarty_tpl->getVariable('smarty')->value['section']['t']['index']]['fct'];
}?></td>
						<td><?php if (!$_smarty_tpl->tpl_vars['allsession']->value[$_smarty_tpl->getVariable('smarty')->value['section']['t']['index']]['sfct']) {?>0<?php } else {
echo $_smarty_tpl->tpl_vars['allsession']->value[$_smarty_tpl->getVariable('smarty')->value['section']['t']['index']]['sfct'];
}?></td>
						<td><?php if (!$_smarty_tpl->tpl_vars['allsession']->value[$_smarty_tpl->getVariable('smarty')->value['section']['t']['index']]['webct']) {?>0<?php } else {
echo $_smarty_tpl->tpl_vars['allsession']->value[$_smarty_tpl->getVariable('smarty')->value['section']['t']['index']]['webct'];
}?></td>
						<td><?php if (!$_smarty_tpl->tpl_vars['allsession']->value[$_smarty_tpl->getVariable('smarty')->value['section']['t']['index']]['xct']) {?>0<?php } else {
echo $_smarty_tpl->tpl_vars['allsession']->value[$_smarty_tpl->getVariable('smarty')->value['section']['t']['index']]['xct'];
}?></td>
						<td><?php if (!$_smarty_tpl->tpl_vars['allsession']->value[$_smarty_tpl->getVariable('smarty')->value['section']['t']['index']]['ct']) {?>0<?php } else {
echo $_smarty_tpl->tpl_vars['allsession']->value[$_smarty_tpl->getVariable('smarty')->value['section']['t']['index']]['ct'];
}?></td>
					</tr>
					<?php endfor; endif; ?>
					<tr>
						<td colspan="13" align="right">
							<?php echo $_smarty_tpl->tpl_vars['language']->value['all'];
echo $_smarty_tpl->tpl_vars['session_num']->value;
echo $_smarty_tpl->tpl_vars['language']->value['Session'];?>
  <?php echo $_smarty_tpl->tpl_vars['page_list']->value;?>
  <?php echo $_smarty_tpl->tpl_vars['language']->value['Page'];?>
：<?php echo $_smarty_tpl->tpl_vars['curr_page']->value;?>
/<?php echo $_smarty_tpl->tpl_vars['total_page']->value;
echo $_smarty_tpl->tpl_vars['language']->value['page'];?>
  <?php echo $_smarty_tpl->tpl_vars['items_per_page']->value;
echo $_smarty_tpl->tpl_vars['language']->value['item'];
echo $_smarty_tpl->tpl_vars['language']->value['Log'];?>
/<?php echo $_smarty_tpl->tpl_vars['language']->value['page'];?>
  <?php echo $_smarty_tpl->tpl_vars['language']->value['Goto'];?>
<input name="pagenum" type="text" class="wbk" size="2" onKeyPress="if(event.keyCode==13) window.location='<?php echo $_smarty_tpl->tpl_vars['curr_url']->value;?>
&page='+this.value;"><?php echo $_smarty_tpl->tpl_vars['language']->value['page'];?>
 <!--当前数据表: <?php echo $_smarty_tpl->tpl_vars['now_table_name']->value;?>
-->   导出：<a href="<?php echo $_smarty_tpl->tpl_vars['curr_url']->value;?>
&derive=1" target="hide"><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/excel.png" border=0></a>  <a href="<?php echo $_smarty_tpl->tpl_vars['curr_url']->value;?>
&derive=2"  target="hide"><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/html.png" border=0></a>  <a href="<?php echo $_smarty_tpl->tpl_vars['curr_url']->value;?>
&derive=3" ><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/word.png" border=0></a>  <a href="<?php echo $_smarty_tpl->tpl_vars['curr_url']->value;?>
&derive=4" ><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/pdf.png" border=0></a> <?php if ($_smarty_tpl->tpl_vars['admin_level']->value == 1) {?><a href="<?php echo $_smarty_tpl->tpl_vars['curr_url']->value;?>
&delete=1"></a><?php }?>
						<!--
						<select  class="wbk"  name="table_name">
						<?php if (isset($_smarty_tpl->tpl_vars['smarty']->value['section']['t'])) unset($_smarty_tpl->tpl_vars['smarty']->value['section']['t']);
$_smarty_tpl->tpl_vars['smarty']->value['section']['t']['name'] = 't';
$_smarty_tpl->tpl_vars['smarty']->value['section']['t']['loop'] = is_array($_loop=$_smarty_tpl->tpl_vars['table_list']->value) ? count($_loop) : max(0, (int) $_loop); unset($_loop);
$_smarty_tpl->tpl_vars['smarty']->value['section']['t']['show'] = true;
$_smarty_tpl->tpl_vars['smarty']->value['section']['t']['max'] = $_smarty_tpl->tpl_vars['smarty']->value['section']['t']['loop'];
$_smarty_tpl->tpl_vars['smarty']->value['section']['t']['step'] = 1;
$_smarty_tpl->tpl_vars['smarty']->value['section']['t']['start'] = $_smarty_tpl->tpl_vars['smarty']->value['section']['t']['step'] > 0 ? 0 : $_smarty_tpl->tpl_vars['smarty']->value['section']['t']['loop']-1;
if ($_smarty_tpl->tpl_vars['smarty']->value['section']['t']['show']) {
    $_smarty_tpl->tpl_vars['smarty']->value['section']['t']['total'] = $_smarty_tpl->tpl_vars['smarty']->value['section']['t']['loop'];
    if ($_smarty_tpl->tpl_vars['smarty']->value['section']['t']['total'] == 0)
        $_smarty_tpl->tpl_vars['smarty']->value['section']['t']['show'] = false;
} else
    $_smarty_tpl->tpl_vars['smarty']->value['section']['t']['total'] = 0;
if ($_smarty_tpl->tpl_vars['smarty']->value['section']['t']['show']):

            for ($_smarty_tpl->tpl_vars['smarty']->value['section']['t']['index'] = $_smarty_tpl->tpl_vars['smarty']->value['section']['t']['start'], $_smarty_tpl->tpl_vars['smarty']->value['section']['t']['iteration'] = 1;
                 $_smarty_tpl->tpl_vars['smarty']->value['section']['t']['iteration'] <= $_smarty_tpl->tpl_vars['smarty']->value['section']['t']['total'];
                 $_smarty_tpl->tpl_vars['smarty']->value['section']['t']['index'] += $_smarty_tpl->tpl_vars['smarty']->value['section']['t']['step'], $_smarty_tpl->tpl_vars['smarty']->value['section']['t']['iteration']++):
$_smarty_tpl->tpl_vars['smarty']->value['section']['t']['rownum'] = $_smarty_tpl->tpl_vars['smarty']->value['section']['t']['iteration'];
$_smarty_tpl->tpl_vars['smarty']->value['section']['t']['index_prev'] = $_smarty_tpl->tpl_vars['smarty']->value['section']['t']['index'] - $_smarty_tpl->tpl_vars['smarty']->value['section']['t']['step'];
$_smarty_tpl->tpl_vars['smarty']->value['section']['t']['index_next'] = $_smarty_tpl->tpl_vars['smarty']->value['section']['t']['index'] + $_smarty_tpl->tpl_vars['smarty']->value['section']['t']['step'];
$_smarty_tpl->tpl_vars['smarty']->value['section']['t']['first']      = ($_smarty_tpl->tpl_vars['smarty']->value['section']['t']['iteration'] == 1);
$_smarty_tpl->tpl_vars['smarty']->value['section']['t']['last']       = ($_smarty_tpl->tpl_vars['smarty']->value['section']['t']['iteration'] == $_smarty_tpl->tpl_vars['smarty']->value['section']['t']['total']);
?>
						<option value="<?php echo $_smarty_tpl->tpl_vars['table_list']->value[$_smarty_tpl->getVariable('smarty')->value['section']['t']['index']];?>
" <?php if ($_smarty_tpl->tpl_vars['table_list']->value[$_smarty_tpl->getVariable('smarty')->value['section']['t']['index']] == $_smarty_tpl->tpl_vars['now_table_name']->value) {?>selected<?php }?>><?php echo $_smarty_tpl->tpl_vars['table_list']->value[$_smarty_tpl->getVariable('smarty')->value['section']['t']['index']];?>
</option>
						<?php endfor; endif; ?>
						</select>
						-->
						</td>
					</tr>
				</table>
	</td>
  </tr>
  <?php if ($_smarty_tpl->tpl_vars['data']->value) {?>
  <tr><td class="main_content"><img src="include/pChart/graphgenerate.php?<?php echo $_smarty_tpl->tpl_vars['data']->value;
echo $_smarty_tpl->tpl_vars['info']->value;?>
graphtype=pie"</td></tr>
  <tr><td class="main_content"><img src="include/pChart/graphgenerate.php?<?php echo $_smarty_tpl->tpl_vars['data']->value;
echo $_smarty_tpl->tpl_vars['info']->value;?>
graphtype=bar"</td></tr>
  <?php }?>
</table>
<?php echo '<script'; ?>
 type="text/javascript">
function loginexport(){
var exportid = document.getElementById("exportid");
exportid.href="<?php echo $_smarty_tpl->tpl_vars['curr_url']->value;?>
&derive=1&f_rangeStart="+document.getElementById('f_rangeStart').value+"&f_rangeEnd="+document.getElementById('f_rangeEnd').value;
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
<iframe name="hide" height="0" frameborder="0" scrolling="no"></iframe>
</body>
</html>


<?php }
}
?>