<!DOCTYPE HTML PUBLIC '-//W3C//DTD HTML 4.0//EN'>
<!--
	Tomato GUI
	Copyright (C) 2006-2010 Jonathan Zarate
	http://www.polarcloud.com/tomato/

	For use with Tomato Firmware only.
	No part of this file may be used without permission.
-->
<html>
<head>
<meta http-equiv='content-type' content='text/html;charset=utf-8'>
<meta name='robots' content='noindex,nofollow'>
<title>[<% ident(); %>] Admin: Upgrade</title>

<link rel='stylesheet' type='text/css' href='sabai.css'>
<script type='text/javascript' src='tomato.js'></script>

<!-- / / / -->
<style type='text/css'>
#afu-progress { text-align: center; padding: 200px 0; width: 890px; }
#afu-time { font-size: 26px; }
#upgradeInfoTable { border: none; }
#upgradeInfoTable td { padding-left: 1em; }
#errMsg { font-size: 1.5em; color: red; }
</style>
<script type='text/javascript'>

var knownModels = {
 'E1550':false,
 'E2500':false,
 'E3200':false,
 'E3000':false,
 'E2000':false,
 'E4200':['E4200 v1'],
 'Netgear-3500Lv2':['WNR3500L v2'],
 'F7D3302':['F7D3302','F7D7302'],
 'K26USB-NVRAM60K-MIPSR2':['RT-N16','RT-N66U','E3000']
}; //['E1550','E2500','E3200','E2000','E4200 v1']

var fom, fileName, model, ext;
//	<% sysinfo(); %>
// <% nvram("jffs2_on,t_model_name"); %>

function clock(){
	var t = ((new Date()).getTime() - startTime) / 1000;
	elem.setInnerHTML('afu-time', Math.floor(t / 60) + ':' + Number(Math.floor(t % 60)).pad(2));
}

function report(text){ if(text===false){ E('errMsg').innerHTML = ''; }else{ E('errMsg').appendChild( T(text) ); E('errMsg').appendChild( A('br') ); } }

function disableUpgrade(){ E('afu-upgrade-button').disabled = true; }

function verifyFileName(){
	report(false);
	fileName = fixFile(fom.file.value);

	ext = fileName.substr(-4).toLowerCase();
	if (ext.search(/\.(bin|trx|chk)$/i) == -1){ report('Expecting a ".bin", ".trx", or ".chk" file; this is a "'+ ext +'".'); disableUpgrade(); }

	modelName=nvram.t_model_name;

	var found = false;
	for(var i in knownModels){
		if(fileName.search(new RegExp(i,"i"))==-1) continue;
		var models = knownModels[ i ] ? knownModels[ i ] : [i];
		for(var j=0; j<models.length; j++){
			if(modelName.search(new RegExp( models[j] ,"i"))!=-1) found = true;
		}
	}

	if(!found){ report('The name of this file and the reported hardware have no known model names in common; proceed at your own risk.'); }
}

function upgrade(){
	if (ext.search(/\.(bin|trx|chk)$/i) == -1){ alert('Expecting a ".bin", ".trx", or ".chk" file.'); return; }
	if (!confirm('Are you sure you want to upgrade this \"'+ nvram.t_model_name +'\" using \"' + fileName + '\"?')) return;

	disableUpgrade();

	E('content').style.verticalAlign = 'middle';
	elem.display('afu-input', false); elem.display('afu-progress', true); elem.display('navi', false)

	startTime = (new Date()).getTime(); setInterval('clock()', 800);
	fom.action += '?_reset=' + (E('f_reset').checked ? "1" : "0");
	form.addIdAction(fom);
	fom.submit();
}

function b(text){ E('blarg').appendChild(T(text)); E('blarg').appendChild(A('br')); }
function init(){
 fom = E('form_upgrade');
 E('freeMemory').innerHTML = scaleSize(sysinfo.totalfreeram);
 E('hwModel').innerHTML = nvram.t_model_name;
}
</script>

</head>
<body onload='init();'>
<table id='container' cellspacing=0>
<tr><td colspan=2 id='header'><a id='headlink' href='http://www.sabaitechnology.com'><img src='imgsabai.png' id='headlogo'></a>
	<div class='title' id='SVPNstatus'><% sabaid(); %></div>
	<div class='version' id='subversion'>version <!-- SABAI-VERSION --></div>
</td></tr>
<tr id='body'><td id='navi'><% sabaaiMenu(); %></td>
<td id='content'>

<!-- / / / -->

<div id='afu-input'>
	<div class='section-title'>Upgrade Firmware</div>
	<div class='section'>
		<form id='form_upgrade' method='post' action='upgrade.cgi' encType='multipart/form-data'>
		<div id='box-input'>
			Select the file to use:<br>
			<input type='file' name='file' size='50' style='height:20px' onchange="verifyFileName();"> <input type='button' value='Upgrade' id='afu-upgrade-button' onclick='upgrade()' style='height:20px'>
		</div>
		</form>
		<br><form name='form_reset' action='javascript:{}'>
		<div id='reset-input'>
			<input type='checkbox' id='f_reset'> After flashing, erase all data in NVRAM memory
		</div>
		</form>
		<table id='upgradeInfoTable'>
		<tr><td colspan=2><span id='errMsg'></span></td></tr>
		<tr><td>Current Version:</td><td><% version(1); %></td></tr>
		<tr><td>Sabai Version:</td><td><!-- SABAI-VERSION --></td></tr>
		<tr><td>Reported Hardware:</td><td><span id='hwModel'></span></td></tr>
		<tr><td>Free Memory:</td><td><span id='freeMemory'></span>&nbsp;&nbsp;<small>(aprox. size that can be buffered completely in RAM)</small></td></tr>
		</table>
	</div>
</div>

<!-- JFFS2-BEGIN -->
<div class='note-disabledw' style='display:none' id='jwarn'>
<b>Cannot upgrade if JFFS is enabled.</b><br><br>
An upgrade may overwrite the JFFS partition currently in use. Before upgrading,
please backup the contents of the JFFS partition, disable it, then reboot the router.<br><br><br>
<a href='file-jffs2.asp'>Disable &raquo;</a>
</div>
<!-- JFFS2-END -->

<div id='afu-progress' style='display:none;margin:auto'>
	<img src='imgspin.gif' style='vertical-align:baseline'> <span id='afu-time'>0:00</span><br>
	Please wait while the firmware is uploaded &amp; flashed.<br>
	<b>Warning:</b> Do not interrupt this browser or the router!<br>
</div>

<!-- / / / -->

</td></tr>
<tr><td id='footer' colspan=2>&nbsp;</td></tr>
</table>
<!-- JFFS2-BEGIN -->
<script type='text/javascript'>
if (nvram.jffs2_on != '0') {
	E('jwarn').style.display = '';
	E('afu-input').style.display = 'none';
}
</script>
<!-- JFFS2-END -->
</body>
</html>
