<?php /* Smarty version 3.1.27, created on 2017-10-10 17:31:16
         compiled from "/opt/freesvr/web/htdocs/freesvr/audit/template/admin/logs_statistic.tpl" */ ?>
<?php
/*%%SmartyHeaderCode:50746996059dc93647a9442_95695686%%*/
if(!defined('SMARTY_DIR')) exit('no direct access allowed');
$_valid = $_smarty_tpl->decodeProperties(array (
  'file_dependency' => 
  array (
    '4d54f07699575bc469b4b5a99b5ffe559100fe70' => 
    array (
      0 => '/opt/freesvr/web/htdocs/freesvr/audit/template/admin/logs_statistic.tpl',
      1 => 1474793217,
      2 => 'file',
    ),
  ),
  'nocache_hash' => '50746996059dc93647a9442_95695686',
  'variables' => 
  array (
    'title' => 0,
    'template_root' => 0,
    'orderby2' => 0,
    'alllog' => 0,
    'allmember' => 0,
    'total' => 0,
    'page_list' => 0,
    'curr_page' => 0,
    'total_page' => 0,
    'items_per_page' => 0,
    'curr_url' => 0,
  ),
  'has_nocache_code' => false,
  'version' => '3.1.27',
  'unifunc' => 'content_59dc936481ca73_48561728',
),false);
/*/%%SmartyHeaderCode%%*/
if ($_valid && !is_callable('content_59dc936481ca73_48561728')) {
function content_59dc936481ca73_48561728 ($_smarty_tpl) {

$_smarty_tpl->properties['nocache_hash'] = '50746996059dc93647a9442_95695686';
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
<SCRIPT language=javascript src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/cssjs/calendar.js"></SCRIPT>
<link type="text/css" rel="stylesheet" href="./template/admin/cssjs/jscal2.css" />
<link type="text/css" rel="stylesheet" href="./template/admin/cssjs/border-radius.css" />
<?php echo '<script'; ?>
 src="./template/admin/cssjs/jscal2.js"><?php echo '</script'; ?>
>
<?php echo '<script'; ?>
 src="./template/admin/cssjs/cn.js"><?php echo '</script'; ?>
>
<?php echo '<script'; ?>
 type="text/javascript">
function searchit(){
	document.f1.submit();	
	//alert(document.search.action);
	//return false;
	return true;
}
function searchit(){
	document.report.action = "admin.php?controller=admin_pro&action=logs_statistic";
	document.report.action += "&start_time="+document.report.f_rangeStart.value;
	document.report.action += "&end_time="+document.report.f_rangeEnd.value;
	document.report.submit();
	return false;
}
<?php echo '</script'; ?>
>
</head>

<body>


	<table width="100%" border="0" cellspacing="0" cellpadding="0">
 	 <tr><td valign="middle" class="hui_bj"><div class="menu">
<ul>
	<li class="me_b"><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an11.jpg" align="absmiddle"/><a href="admin.php?controller=admin_pro&action=logs_index">改密明细</a><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an33.jpg" align="absmiddle"/></li>
	<li class="me_a"><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an1.jpg" align="absmiddle"/><a href="admin.php?controller=admin_pro&action=logs_statistic">改密统计</a><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/an3.jpg" align="absmiddle"/></li>
</ul>
</div></td></tr>
   <TR>
                    <TD colspan = "7" class="main_content">
					<form name ='report' action='admin.php?controller=admin_pro&action=logs_index' method=post>
					开始日期：<input type="text" class="wbk"  name="f_rangeStart" size="13" id="f_rangeStart" value=""/>
					 <input type="button" onClick="changetype('timetype3')" id="f_rangeStart_trigger" name="f_rangeStart_trigger" value="选择时间" class="wbk">
					 结束日期：
					<input  type="text" class="wbk" name="f_rangeEnd" size="13" id="f_rangeEnd" value=""/>
					 <input type="button" onClick="changetype('timetype3')" id="f_rangeEnd_trigger" name="f_rangeEnd_trigger" value="选择时间" class="wbk">
					&nbsp;&nbsp;<input type="submit" height="35" align="middle" onClick="return searchit();" border="0" value=" 确定 " class="bnnew2"/>
					</form>
					  <?php echo '<script'; ?>
 type="text/javascript">
var cal = Calendar.setup({
    onSelect: function(cal) { cal.hide() },
    showTime: true
});
cal.manageFields("f_rangeStart_trigger", "f_rangeStart", "%Y-%m-%d %H:%M:%S");
cal.manageFields("f_rangeEnd_trigger", "f_rangeEnd", "%Y-%m-%d %H:%M:%S");


<?php echo '</script'; ?>
>
					</TD>
                  </TR>
  <tr>
	<td class=""><table width="100%" border="0" cellspacing="0" cellpadding="0" class="BBtable">
                <TBODY>
			<form name="member_list" action="admin.php?controller=admin_pro&action=logs_del" method="post">

                  <TR>
					<th class="list_bg" ></TD>
                    <th class="list_bg" ><a href="admin.php?controller=admin_pro&action=logs_index&orderby1=device_ip&orderby2=<?php echo $_smarty_tpl->tpl_vars['orderby2']->value;?>
" >服务器地址</a></TD>
                    <th class="list_bg" ><a href="admin.php?controller=admin_pro&action=logs_index&orderby1=username&orderby2=<?php echo $_smarty_tpl->tpl_vars['orderby2']->value;?>
" >主机名</a></TD>
                    <th class="list_bg" ><a href="admin.php?controller=admin_pro&action=logs_index&orderby1=username&orderby2=<?php echo $_smarty_tpl->tpl_vars['orderby2']->value;?>
" >用户</a></TD>
                    <th class="list_bg" ><a href="admin.php?controller=admin_pro&action=logs_index&orderby1=username&orderby2=<?php echo $_smarty_tpl->tpl_vars['orderby2']->value;?>
" >开始时间</a></TD>
                    <th class="list_bg" ><a href="admin.php?controller=admin_pro&action=logs_index&orderby1=username&orderby2=<?php echo $_smarty_tpl->tpl_vars['orderby2']->value;?>
" >结束时间</a></TD>
                    <th class="list_bg" ><a href="admin.php?controller=admin_pro&action=logs_index&orderby1=username&orderby2=<?php echo $_smarty_tpl->tpl_vars['orderby2']->value;?>
" >改密次数</a></TD>
                    <th class="list_bg" ><a href="admin.php?controller=admin_pro&action=logs_index&orderby1=username&orderby2=<?php echo $_smarty_tpl->tpl_vars['orderby2']->value;?>
" >成功</a></TD>
                    <th class="list_bg" ><a href="admin.php?controller=admin_pro&action=logs_index&orderby1=username&orderby2=<?php echo $_smarty_tpl->tpl_vars['orderby2']->value;?>
" >失败</a></TD>
                  </TR>

            </tr>
			<?php if (isset($_smarty_tpl->tpl_vars['smarty']->value['section']['t'])) unset($_smarty_tpl->tpl_vars['smarty']->value['section']['t']);
$_smarty_tpl->tpl_vars['smarty']->value['section']['t']['name'] = 't';
$_smarty_tpl->tpl_vars['smarty']->value['section']['t']['loop'] = is_array($_loop=$_smarty_tpl->tpl_vars['alllog']->value) ? count($_loop) : max(0, (int) $_loop); unset($_loop);
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
			<tr  <?php if ($_smarty_tpl->getVariable('smarty')->value['section']['t']['index']%2 == 0) {?>bgcolor="f7f7f7"<?php }?>>
			<td><?php if ($_smarty_tpl->tpl_vars['allmember']->value[$_smarty_tpl->getVariable('smarty')->value['section']['t']['index']]['level'] != 10 && $_smarty_tpl->tpl_vars['allmember']->value[$_smarty_tpl->getVariable('smarty')->value['section']['t']['index']]['level'] != 2 && $_smarty_tpl->tpl_vars['allmember']->value[$_smarty_tpl->getVariable('smarty')->value['section']['t']['index']]['level'] != 1) {?><input type="checkbox" name="chk_member[]" value="<?php echo $_smarty_tpl->tpl_vars['alllog']->value[$_smarty_tpl->getVariable('smarty')->value['section']['t']['index']]['id'];?>
"><?php }?></td>
				<td> <?php echo $_smarty_tpl->tpl_vars['alllog']->value[$_smarty_tpl->getVariable('smarty')->value['section']['t']['index']]['device_ip'];?>
</td>
				<td> <?php echo $_smarty_tpl->tpl_vars['alllog']->value[$_smarty_tpl->getVariable('smarty')->value['section']['t']['index']]['hostname'];?>
</td>
				<td><?php echo $_smarty_tpl->tpl_vars['alllog']->value[$_smarty_tpl->getVariable('smarty')->value['section']['t']['index']]['username'];?>
</td>
				<td><?php echo $_smarty_tpl->tpl_vars['alllog']->value[$_smarty_tpl->getVariable('smarty')->value['section']['t']['index']]['start'];?>
</td>
				<td><?php echo $_smarty_tpl->tpl_vars['alllog']->value[$_smarty_tpl->getVariable('smarty')->value['section']['t']['index']]['end'];?>
</td>
				<td><?php echo $_smarty_tpl->tpl_vars['alllog']->value[$_smarty_tpl->getVariable('smarty')->value['section']['t']['index']]['ct'];?>
</td>
				<td><?php echo $_smarty_tpl->tpl_vars['alllog']->value[$_smarty_tpl->getVariable('smarty')->value['section']['t']['index']]['success'];?>
</td>
				<td><?php echo $_smarty_tpl->tpl_vars['alllog']->value[$_smarty_tpl->getVariable('smarty')->value['section']['t']['index']]['fail'];?>
</td>
			</tr>
			<?php endfor; endif; ?>

                <tr>
				<td colspan="2" align="left">
							
						</td>
	           <td  colspan="8" align="right">
		   			共<?php echo $_smarty_tpl->tpl_vars['total']->value;?>
个记录  <?php echo $_smarty_tpl->tpl_vars['page_list']->value;?>
  页次：<?php echo $_smarty_tpl->tpl_vars['curr_page']->value;?>
/<?php echo $_smarty_tpl->tpl_vars['total_page']->value;?>
页  <?php echo $_smarty_tpl->tpl_vars['items_per_page']->value;?>
个记录/页  转到第<input name="pagenum" type="text" class="wbk" size="2" onKeyPress="if(event.keyCode==13) {window.location='admin.php?controller=admin_pro&action=logs_index&page='+this.value;return false;}">页   导出：<a href="<?php echo $_smarty_tpl->tpl_vars['curr_url']->value;?>
&derive=1" target="hide"><img src="<?php echo $_smarty_tpl->tpl_vars['template_root']->value;?>
/images/excel.png" border=0></a>
		   </td>
		</tr>
		</form>
		</TBODY>
              </TABLE>	</td>
  </tr>
</table>

<?php echo '<script'; ?>
 language="javascript">

function my_confirm(str){
	if(!confirm(str + "？"))
	{
		window.event.returnValue = false;
	}
}

<?php echo '</script'; ?>
>
</body>
<iframe name="hide" height="0" frameborder="0" scrolling="no"></iframe>
</html>



<?php }
}
?>