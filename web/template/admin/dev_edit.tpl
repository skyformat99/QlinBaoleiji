<!doctype html public "-//w3c//dtd html 4.0 transitional//en">
<html>
<head>
<title>{{$title}}</title>
<meta name="generator" content="editplus">
<meta name="author" content="nuttycoder">
<link href="{{$template_root}}/all_purpose_style.css" rel="stylesheet" type="text/css" />
<script type="text/javascript" src="{{$template_root}}/cssjs/jquery-1.10.2.min.js"></script>
<script src="./template/admin/cssjs/global.functions.js"></script>
<script src="./template/admin/cssjs/jscal2.js"></script>
<script src="./template/admin/cssjs/cn.js"></script>
<script src="./template/admin/cssjs/global.functions.js"></script>
<link type="text/css" rel="stylesheet" href="./template/admin/cssjs/jscal2.css" />
<script type="text/javascript" src="{{$template_root}}/cssjs/_ajaxdtree.js"></script>
<link href="{{$template_root}}/cssjs/dtree.css" rel="stylesheet" type="text/css" />
</head>

<body>
<script>



function change_option(number,index){
 for (var i = 0; i <= number; i++) {
      document.getElementById('current' + i).className = '';
      document.getElementById('content' + i).style.display = 'none';
 }
  document.getElementById('current' + index).className = 'current';
  document.getElementById('content' + index).style.display = 'block';
  if(index==1 || index==2 || index==3){
	document.getElementById('finalsubmit').style.display = 'block';
  }else{
	document.getElementById('finalsubmit').style.display = 'none';
  }
  return false;
}
</script>
<td width="84%" align="left" valign="top"><table width="100%" border="0" cellspacing="0" cellpadding="0"><tr><td valign="middle" class="hui_bj"><div class="menu">
<ul>
{{if $smarty.session.ADMIN_LEVEL eq 10}}
<li class="me_a"><img src="{{$template_root}}/images/an1.jpg" align="absmiddle"/><a href="admin.php?controller=admin_index&action=main">密码查看</a><img src="{{$template_root}}/images/an3.jpg" align="absmiddle"/></li>
<li class="me_b"><img src="{{$template_root}}/images/an11.jpg" align="absmiddle"/><a href="admin.php?controller=admin_pro&action=passwordedit">修改密码</a><img src="{{$template_root}}/images/an33.jpg" align="absmiddle"/></li>
<li class="me_b"><img src="{{$template_root}}/images/an11.jpg" align="absmiddle"/><a href="admin.php?controller=admin_pro&action=password_cron">定时任务</a><img src="{{$template_root}}/images/an33.jpg" align="absmiddle"/></li>
<li class="me_b"><img src="{{$template_root}}/images/an11.jpg" align="absmiddle"/><a href="admin.php?controller=admin_backup&action=backup_setting_forpassword">自动备份</a><img src="{{$template_root}}/images/an33.jpg" align="absmiddle"/></li>
<li class="me_b"><img src="{{$template_root}}/images/an11.jpg" align="absmiddle"/><a href="admin.php?controller=admin_index&action=passdown">密码文件下载</a><img src="{{$template_root}}/images/an33.jpg" align="absmiddle"/></li>
<li class="me_b"><img src="{{$template_root}}/images/an11.jpg" align="absmiddle"/><a href="admin.php?controller=admin_pro&action=passwordcheck">密码校验</a><img src="{{$template_root}}/images/an33.jpg" align="absmiddle"/></li>
{{elseif $smarty.session.ADMIN_LEVEL eq 10 or $smarty.session.ADMIN_LEVEL eq 101}}
<li class="me_a"><img src="{{$template_root}}/images/an1.jpg" align="absmiddle"/><a href="admin.php?controller=admin_index&action=main">密码查看</a><img src="{{$template_root}}/images/an3.jpg" align="absmiddle"/></li>
{{else}}
	<li class="me_b"><img src="{{$template_root}}/images/an11.jpg" align="absmiddle"/><a href="admin.php?controller=admin_member">用户管理</a><img src="{{$template_root}}/images/an33.jpg" align="absmiddle"/></li>
	{{if $from eq 'dir'}}
	<li class="me_b"><img src="{{$template_root}}/images/an11.jpg" align="absmiddle"/><a href="admin.php?controller=admin_pro&action=dev_index">设备管理</a><img src="{{$template_root}}/images/an33.jpg" align="absmiddle"/></li>
	{{else}}
	<li class="me_a"><img src="{{$template_root}}/images/an1.jpg" align="absmiddle"/><a href="admin.php?controller=admin_pro&action=dev_index">设备管理</a><img src="{{$template_root}}/images/an3.jpg" align="absmiddle"/></li>
	{{/if}}
	{{if $from eq 'dir'}}
	<li class="me_a"><img src="{{$template_root}}/images/an1.jpg" align="absmiddle"/><a href="admin.php?controller=admin_pro&action=dev_group">目录管理</a><img src="{{$template_root}}/images/an3.jpg" align="absmiddle"/></li>
	{{else}}
	<li class="me_b"><img src="{{$template_root}}/images/an11.jpg" align="absmiddle"/><a href="admin.php?controller=admin_pro&action=dev_group">目录管理</a><img src="{{$template_root}}/images/an33.jpg" align="absmiddle"/></li>
	{{/if}}
	<li class="me_b"><img src="{{$template_root}}/images/an11.jpg" align="absmiddle"/><a href="admin.php?controller=admin_member&action=workdept">用户属性</a><img src="{{$template_root}}/images/an33.jpg" align="absmiddle"/></li>
	<li class="me_b"><img src="{{$template_root}}/images/an11.jpg" align="absmiddle"/><a href="admin.php?controller=admin_pro&action=systemtype">系统类型</a><img src="{{$template_root}}/images/an33.jpg" align="absmiddle"/></li>
	<li class="me_b"><img src="{{$template_root}}/images/an11.jpg" align="absmiddle"/><a href="admin.php?controller=admin_pro&action=sshkey">SSH公私钥</a><img src="{{$template_root}}/images/an33.jpg" align="absmiddle"/></li>
	<li class="me_b"><img src="{{$template_root}}/images/an11.jpg" align="absmiddle"/><a href="admin.php?controller=admin_member&action=radiususer">RADIUS用户</a><img src="{{$template_root}}/images/an33.jpg" align="absmiddle"/></li>
	<li class="me_b"><img src="{{$template_root}}/images/an11.jpg" align="absmiddle"/><a href="admin.php?controller=admin_pro&action=passwordkey">密码密钥</a><img src="{{$template_root}}/images/an33.jpg" align="absmiddle"/></li>
	{{if $smarty.session.ADMIN_LEVEL eq 1}}
    <li class="me_b"><img src="{{$template_root}}/images/an11.jpg" align="absmiddle"/><a href="admin.php?controller=admin_member&action=online">在线用户</a><img src="{{$template_root}}/images/an33.jpg" align="absmiddle"/></li>
	{{/if}}
{{/if}}
</ul><span class="back_img"><A href="admin.php?controller={{if $smarty.session.ADMIN_LEVEL eq 10 or $smarty.session.ADMIN_LEVEL eq 101}}admin_index&action=main{{else}}{{if $smarty.get.appconfigedit}}admin_pro&action=dev_edit&id={{$id}}&gid={{$gid}}&apptable=1{{else}}admin_pro&action=dev_index&gid={{$gid}}{{/if}}{{/if}}&back=1"><IMG src="{{$template_root}}/images/back1.png" 
      width="80" height="30" border="0"></A></span>
</div></td></tr>

   
</table>
<table width="100%" border="0" cellspacing="0" cellpadding="0">

  <tr>
	<td class="">

        <table width="100%" border="0" cellspacing="0" cellpadding="0">
          <tr>
            <td align="center"><form name="f1" method=post OnSubmit='return check()' action="admin.php?controller=admin_pro&action=dev_save&id={{$id}}&appconfigedit={{$appconfigedit}}&appconfigid={{$appconfig1.seq}}&gid={{$gid}}">
		<input type="password" name="hiddenpassword" id="hiddenpassword" style="display:none"/>	 <DIV style="WIDTH:100%" id=navbar>
 {{if !$appconfigedit}}
				 <div id="content1" class="content">
				   <div class="contentMain">
	<table border=0 width=100% cellpadding=5 cellspacing=1 bgcolor="#FFFFFF" valign=top class="BBtable">
	<TR>
      <TD height="27" colspan="4" class="tb_t_bg">基本信息</TD>
    </TR>
	{{assign var="trnumber" value=0}}
	<tr {{if $trnumber % 2 == 0}}bgcolor="f7f7f7"{{/if}}>
		<td width="15%" align=right>
		主机名		
		</td>
		<td width="35%">
		<input type=text name="hostname" size=35 value="{{$hostname}}" >
	  </td>
	  <td width="15%" align=right>
			系统类型  </td>
		<td width="35%"><select  class="wbk"  name="type_id">
		{{section name=g loop=$alltype}}
			<OPTION VALUE="{{$alltype[g].id}}" {{if $alltype[g].id == $type_id}}selected{{/if}}>{{$alltype[g].device_type}}</option>
		{{/section}}
		</select>
	  </td>
	</tr>
	{{assign var="trnumber" value=$trnumber+1}}
	<tr {{if $trnumber % 2 == 0}}bgcolor="f7f7f7"{{/if}}>
		<td width="15%" align=right>
		IPv4地址
		</td>
		<td width="35%">
		<input type=text name="IP" size=35 value="{{$IP}}" {{if $id}}readonly{{/if}}>
	  </td>
	  <td width="15%" align=right>
			IPv6 </td>
		<td width="35%"><input type=text name="ipv6" size=35 value="{{$ipv6}}" >
	  </td>
	</tr>
	{{assign var="trnumber" value=$trnumber+1}}
	<tr {{if $trnumber % 2 == 0}}bgcolor="f7f7f7"{{/if}}>
		
	  <td width="15%" align=right>
		设备组
		</td>
		<td width="35%" colspan="3">
		{{include file="select_sgroup_ajax.tpl" }} 
			
		</td>
	</tr>

	{{assign var="trnumber" value=$trnumber+1}}
	<tr {{if $trnumber % 2 == 0}}bgcolor="f7f7f7"{{/if}}>
		<td width="15%" align=right>
		超级管理员口令:	
		</td>
		<td width="35%">
				<input type="password" size=35 name="superpassword" value="{{$superpassword}}"/>
	  </td>
	  <td width="15%" align=right>
		再输一次口令:	
		</td>
		<td width="35%">
				<input type="password" size=35 name="superpassword2" value="{{$superpassword}}"/>
	  </td>

	</tr>
	
	{{assign var="trnumber" value=$trnumber+1}}
	<tr {{if $trnumber % 2 == 0}}bgcolor="f7f7f7"{{/if}}>
		<td width="15%" align=right>
		修改方式	
		</td>
		<td width="35%">
		<input type='radio' name="stra_type" value='mon' {{if $method == 'mon' || $method ==''}}checked{{/if}}>
		按月
		<input type='radio' name="stra_type" value='week' {{if $method == 'week'}}checked{{/if}}>
		每周
		<input type='radio' name="stra_type" value='custom'{{if $method == 'user'}}checked{{/if}}>
		自定义
	  </td>
	  <td width="15%" align=right>
		频率
		</td>
		<td width="35%">
		<input type=text name="freq" size=35 value="{{if $freq}}{{$freq}}{{else}}1{{/if}}" >**
		</td>
	</tr>
	{{assign var="trnumber" value=$trnumber+1}}
	<tr {{if $trnumber % 2 == 0}}bgcolor="f7f7f7"{{/if}}>
		<td colspan='4'>
		**频率的说明：如果修改方式选择每周，这里填写周几（1—7）,如果是按月，填写几号（1—31）,如果是自定义，这里是几日更新一次（大于0的整数）
		</td>
	</tr>
	
{{if $smarty.session.ADMIN_LEVEL eq 1 or $smarty.session.ADMIN_LEVEL eq 3 or $smarty.session.ADMIN_LEVEL eq 21 or $smarty.session.ADMIN_LEVEL eq 101}}
	
	{{assign var="trnumber" value=$trnumber+1}}
	<tr {{if $trnumber % 2 == 0}}bgcolor="f7f7f7"{{/if}}>
		<td width="15%" align=right>
		SSH默认端口	
		</td>
		<td width="35%">
		<input type=text name="sshport" size=35 value="{{if $id }}{{$sshport}}{{else}}22{{/if}}" >
	  </td>
	  <td width="15%" align=right>
		TELNET默认端口	
		</td>
		<td width="35%">
		<input type=text name="telnetport" size=35 value="{{if $id }}{{$telnetport}}{{else}}23{{/if}}" >
	  </td>
	</tr>
	{{assign var="trnumber" value=$trnumber+1}}
	<tr {{if $trnumber % 2 == 0}}bgcolor="f7f7f7"{{/if}}>
		<td width="15%" align=right>
		FTP默认端口
		</td>
		<td width="35%">
		<input type=text name="ftpport" size=35 value="{{if $id }}{{$ftpport}}{{else}}21{{/if}}" >
	  </td>
	  <td width="15%" align=right>
		RDP默认端口
		</td>
		<td width="35%">
		<input type=text name="rdpport" size=35 value="{{if $id }}{{$rdpport}}{{else}}3389{{/if}}" >
	  </td>
	</tr>
	{{assign var="trnumber" value=$trnumber+1}}
	<tr {{if $trnumber % 2 == 0}}bgcolor="f7f7f7"{{/if}}>
		<td width="15%" align=right>
		VNC默认端口	
		</td>
		<td width="35%">
		<input type=text name="vncport" size=35 value="{{if $id }}{{$vncport}}{{else}}5900{{/if}}" >
	  </td>
	  <td width="15%" align=right>
		X11默认端口	
		</td>
		<td width="35%">
		<input type=text name="x11port" size=35 value="{{if $id }}{{$x11port}}{{else}}3389{{/if}}" >
	  </td>
	</tr>
{{else}}
<input type="hidden" name="transport" value="{{$transport}}" >
<input type="hidden" name="sshport" value="{{if $id }}{{$sshport}}{{else}}22{{/if}}" >
<input type="hidden" name="telnetport" value="{{if $id }}{{$telnetport}}{{else}}23{{/if}}" >
<input type="hidden" name="ftpport" value="{{if $id }}{{$ftpport}}{{else}}21{{/if}}" >
<input type="hidden" name="rdpport" value="{{if $id }}{{$rdpport}}{{else}}3389{{/if}}" >
<input type="hidden" name="vncport" value="{{if $id }}{{$vncport}}{{else}}3389{{/if}}" >
<input type="hidden" name="x11port" value="{{if $id }}{{$x11port}}{{else}}3389{{/if}}" >
	{{/if}}
	</table> </div>
				 </div>
				 <div id="content2" class="content" >
				   <div class="contentMain">
				   <table border=0 width=100% cellpadding=5 cellspacing=1 bgcolor="#FFFFFF" valign=top class="BBtable">
				   <TR>
      <TD height="27" colspan="4" class="tb_t_bg">扩展信息</TD>
    </TR>
	{{assign var="trnumber" value=$trnumber+1}}
	<tr {{if $trnumber % 2 == 0}}bgcolor="f7f7f7"{{/if}}>
		<td width="15%" align=right>
		固定资产名称	
		</td>
		<td width="35%">
		<input type=text name="asset_name" size=35 value="{{$asset_name}}" >
	  </td>
	  <td width="15%" align=right>
		规格型号	
		</td>
		<td width="35%">
		<input type=text name="asset_specification" size=35 value="{{$asset_specification}}" >
	  </td>
	</tr>
	{{assign var="trnumber" value=$trnumber+1}}
	<tr {{if $trnumber % 2 == 0}}bgcolor="f7f7f7"{{/if}}>
		<td width="15%" align=right>
		部门名称	
		</td>
		<td width="35%">
		<input type=text name="asset_department" size=35 value="{{$asset_department}}" >
	  </td>
	  <td width="15%" align=right>
		存放地点	
		</td>
		<td width="35%">
		<input type=text name="asset_location" size=35 value="{{$asset_location}}" >
	  </td>
	</tr>
	{{assign var="trnumber" value=$trnumber+1}}
	<tr {{if $trnumber % 2 == 0}}bgcolor="f7f7f7"{{/if}}>
		<td width="15%" align=right>
		支持厂商	
		</td>
		<td width="35%">
		<input type=text name="asset_company" size=35 value="{{$asset_company}}" >
	  </td>
	  <td width="15%" align=right>
		开始使用日期	
		</td>
		<td width="35%">
		<input type=text name="asset_start" id="asset_start" size=35 value="{{$asset_start}}" >&nbsp;&nbsp;<input type="button"  id="f_rangeStart_trigger" name="f_rangeStart_trigger" value="选择时间" class="wbk"> 

	  </td>
	</tr>	
	{{assign var="trnumber" value=$trnumber+1}}
	<tr {{if $trnumber % 2 == 0}}bgcolor="f7f7f7"{{/if}}>
		<td width="15%" align=right>
		使用年限	
		</td>
		<td width="35%">
		<input type=text name="asset_usedtime" size=35 value="{{$asset_usedtime}}" >
	  </td>
	  <td width="15%" align=right>
		保修日期	
		</td>
		<td width="35%">
		<input type=text name="asset_warrantdate" id="asset_warrantdate" size=35 value="{{$asset_warrantdate}}" >&nbsp;&nbsp;<input type="button"  id="f_rangeEnd_trigger" name="f_rangeEnd_trigger" value="选择时间" class="wbk"> 
	  </td>
	</tr>
	{{assign var="trnumber" value=$trnumber+1}}
	<tr {{if $trnumber % 2 == 0}}bgcolor="f7f7f7"{{/if}}>
		<td width="15%" align=right>
		使用状况	
		</td>
		<td width="35%">
		<input type=text name="asset_status" size=35 value="{{$asset_status}}" >
	  </td>
	  <td width="15%" align=right>
		</td>
		<td width="35%">
	  </td>
	</tr>
</table>
 </div>
</div>
{{/if}}

 {{if !$appconfigedit}}
	<tr id="finalsubmit"><td align="center">{{if $id and $monitor==1}}{{if !$appconfigedit}}<input type=button {{if !$id}}readonly{{/if}} onclick="admin.php?controller=admin_pro&action=server_detect&ip={{$IP}}"  value="硬件检测" class="an_02">{{/if}}{{/if}}&nbsp;&nbsp;&nbsp;&nbsp;<input type=submit  value="保存修改" class="an_02" onclick="save();return true;"></td></tr></table>

</form>
{{/if}}
	</td>
  </tr>
</table>
  <script type="text/javascript">
var cal = Calendar.setup({
    onSelect: function(cal) { cal.hide() },
    showTime: true,
	popupDirection: 'up'
});
cal.manageFields("f_rangeStart_trigger", "asset_start", "%Y-%m-%d %H:%M:%S");
cal.manageFields("f_rangeEnd_trigger", "asset_warrantdate", "%Y-%m-%d %H:%M:%S");


</script>
<script language="javascript">
function save(){
}
function my_confirm(str){
	if(!confirm(str + "？"))
	{
		window.event.returnValue = false;
	}
}

function changeport() {
	if(document.getElementById("ssh").selected==true)  {
		f1.port.value = 22;
	}
	if(document.getElementById("telnet").selected==true)  {
		f1.port.value = 23;
	}
}

{{if $smarty.session.ADMIN_LEVEL eq 3 and $smarty.session.ADMIN_MSERVERGROUP}}
var ug = document.getElementById('servergroup');
for(var i=0; i<ug.options.length; i++){
	if(ug.options[i].value=={{$smarty.session.ADMIN_MSERVERGROUP}}){
		ug.selectedIndex=i;
		ug.onchange = function(){ug.selectedIndex=i;}
		break;
	}
}
{{/if}}

</script>
<script>

function opentable(id){
	if(document.getElementById(id).style.display=='none'){
		document.getElementById(id+"_img").src='template/admin/cssjs/img/nolines_minus.gif'
		document.getElementById(id).style.display=''
	}else{
		document.getElementById(id+"_img").src='template/admin/cssjs/img/nolines_plus.gif'
		document.getElementById(id).style.display='none'
	}
    window.parent.reinitIframe();
}
{{if $smarty.get.accounttable}}
opentable('accounttable');
{{/if}}
{{if $smarty.get.apptable}}
opentable('apptable');
{{/if}}


//change_option({{if $smarty.session.CACTI_CONFIG_ON}}4{{else}}2{{/if}},{{$tab}});
{{if $_config.LDAP}}
{{$changelevelstr}}
{{/if}}

</script>
</body>
<iframe name="hide" height="0" frameborder="0" scrolling="no"></iframe>
</html>



