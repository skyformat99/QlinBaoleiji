<!doctype html public "-//w3c//dtd html 4.0 transitional//en">
<html>
<head>
<title>{{$language.Master}}{{$language.page}}面</title>
<meta name="generator" content="editplus">
<meta name="author" content="nuttycoder">
<link href="{{$template_root}}/all_purpose_style.css" rel="stylesheet" type="text/css" />

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
    <li class="me_b"><img src="{{$template_root}}/images/an11.jpg" align="absmiddle"/><a href="admin.php?controller=admin_eth&action=serverstatus">服务状态</a><img src="{{$template_root}}/images/an33.jpg" align="absmiddle"/></li>
	<li class="me_b"><img src="{{$template_root}}/images/an11.jpg" align="absmiddle"/><a href="admin.php?controller=admin_status&action=latest">系统状态</a><img src="{{$template_root}}/images/an33.jpg" align="absmiddle"/></li>
	<li class="me_a"><img src="{{$template_root}}/images/an1.jpg" align="absmiddle"/><a href="admin.php?controller=admin_config&action=ha">双机配置</a><img src="{{$template_root}}/images/an3.jpg" align="absmiddle"/></li>
	<li class="me_b"><img src="{{$template_root}}/images/an11.jpg" align="absmiddle"/><a href="admin.php?controller=admin_backup">配置备份</a><img src="{{$template_root}}/images/an33.jpg" align="absmiddle"/></li>
	<li class="me_b"><img src="{{$template_root}}/images/an11.jpg" align="absmiddle"/><a href="admin.php?controller=admin_backup&action=backup_setting">数据同步</a><img src="{{$template_root}}/images/an33.jpg" align="absmiddle"/></li>
	<li class="me_b"><img src="{{$template_root}}/images/an11.jpg" align="absmiddle"/><a href="admin.php?controller=admin_backup&action=upgrade">软件升级</a><img src="{{$template_root}}/images/an33.jpg" align="absmiddle"/></li>
	<li class="me_b"><img src="{{$template_root}}/images/an11.jpg" align="absmiddle"/><a href="admin.php?controller=admin_backup&action=cronjob">定时任务</a><img src="{{$template_root}}/images/an33.jpg" align="absmiddle"/></li>
	<li class="me_b"><img src="{{$template_root}}/images/an11.jpg" align="absmiddle"/><a href="admin.php?controller=admin_index&action=changelogo">图标上传</a><img src="{{$template_root}}/images/an33.jpg" align="absmiddle"/></li>
	<li class="me_b"><img src="{{$template_root}}/images/an11.jpg" align="absmiddle"/><a href="admin.php?controller=admin_config&action=notice">系统通知</a><img src="{{$template_root}}/images/an33.jpg" align="absmiddle"/></li>
</ul>
</div></td></tr>

  
  <tr><td><table bordercolor="white" cellspacing="0" cellpadding="5" border="0" width="100%" class="BBtable">
<form name="f1" method=post OnSubmit='return check()' action="admin.php?controller=admin_config&action=ha_save">
	{{assign var="trnumber" value=0}}
	<tr><td colspan="3" bgcolor="f7f7f7" align="center" style="font-weight: bold;font-size: 13px;">当&nbsp;&nbsp;&nbsp;&nbsp;前&nbsp;&nbsp;&nbsp;&nbsp;状&nbsp;&nbsp;&nbsp;&nbsp;态</td></tr>
<tr bgcolor="f7f7f7">
<td align="right">配置同步状态：</td>
		<td align=left>&nbsp;&nbsp;&nbsp;&nbsp;{{if $ha.mysqlserver eq 0}}关闭{{else}}{{$ha.mysqlserver}}&nbsp;&nbsp;&nbsp;&nbsp;<img src="{{$template_root}}/images/{{if $ha.mysqlstatus eq 0}}hong.gif{{else}}Green.gif{{/if}}" >{{/if}}
		</td>
		
	</tr>

	<tr bgcolor="f7f7f7">
	<td align="right"> 浮动IP：</td>
		<td align=left>&nbsp;&nbsp;&nbsp;&nbsp;{{if $ha.keepalivedstatus eq 0}}关闭{{elseif $ha.keepalived eq 1}}{{$ha.keepalivedip}}&nbsp;&nbsp;&nbsp;&nbsp;(主){{else}}&nbsp;&nbsp;&nbsp;&nbsp;{{$ha.keepalivedip}}&nbsp;&nbsp;&nbsp;&nbsp;(从){{/if}}
		</td>
		
	</tr>
	
	<tr><td colspan="3" bgcolor="f7f7f7" align="center" style="font-weight: bold;font-size: 13px;">双&nbsp;&nbsp;&nbsp;&nbsp;机&nbsp;&nbsp;&nbsp;&nbsp;配&nbsp;&nbsp;&nbsp;&nbsp;置</td></tr>
	<tr {{if $trnumber++ % 2 == 0}}bgcolor="f7f7f7"{{/if}}>
	<td align="right">对端IP ：</td>
		<td align=left>
		<input type="text" class="wbk" name="masterip" value="{{$ha.masterip}}" />
		</td>
		
	</tr>
	<tr bgcolor="f7f7f7">
	<td align="right"> 对端root口令：</td>
		<td align=left>
		<input type="password" class="wbk" name="password" value="{{$ha.password}}" />
		</td>
	</tr>

	<tr bgcolor="f7f7f7">
	<td align="right"> HA接口：</td>
		<td align=left>
		<select name="eth" >
		{{section name=e loop=$eth}}
		<option value="{{$eth[e].i}}">{{$eth[e].name}}</option>
		{{/section}}
		</select>
		</td>
	</tr>

	<tr bgcolor="f7f7f7">
	<td align="right"> 浮动IP：</td>
		<td align=left>
		<input type="text" class="wbk" name="slaveip" value="{{$ha.slaveip}}" />
		</td>
	</tr>
	<tr >
	<tr bgcolor="f7f7f7">
		<td></td>	<td  align="left"><input type="submit"  value="{{$language.Save}}" class="an_02" ></td>
		</tr>
<input type="hidden" name="ac" value="{{if $ha}}edit{{else}}new{{/if}}"/>
</form>
<form name="f1" method=post OnSubmit='return check()' action="admin.php?controller=admin_config&action=ha_save">
	<tr><td colspan="3" bgcolor="f7f7f7" align="center" style="font-weight: bold;font-size: 13px;">数&nbsp;&nbsp;&nbsp;&nbsp;据&nbsp;&nbsp;&nbsp;&nbsp;库&nbsp;&nbsp;&nbsp;&nbsp;配&nbsp;&nbsp;&nbsp;&nbsp;置</td></tr>
	<td align="right"> 数据库连接服务器：</td>
		<td align=left>
		<input type="text" class="wbk" name="dbaudithost" value="{{$ha.dbaudithost}}" />
		</td>
	</tr>
	<tr bgcolor="f7f7f7">
		<td></td>	<td  align="left"><input type="submit"  value="{{$language.Save}}" class="an_02" ></td>
		</tr>
<input type="hidden" name="ac" value="{{if $ha}}edit{{else}}new{{/if}}"/>
</form>
	</table>
	

		</table>
	</td>
  </tr>
</table>


<script language="javascript">
<!--
function check()
{
/*
   if(!checkIP(f1.ip.value) && f1.netmask.value != '32' ) {
	alert('地址为{{$language.HostName}}时，掩码应为32');
	return false;
   }   
   if(checkIP(f1.ip.value) && !checknum(f1.netmask.value)) {
	alert('请{{$language.Input}}正确掩码');
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
</script>
</body>
</html>


