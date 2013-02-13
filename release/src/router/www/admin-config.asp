<!DOCTYPE HTML PUBLIC '-//W3C//DTD HTML 4.0//EN'>
<!-- Tomato GUI Copyright (C) 2006-2010 Jonathan Zarate http://www.polarcloud.com/tomato/ For use with Tomato Firmware only. No part of this file may be used without permission. -->
<html>
<head>
<meta http-equiv='content-type' content='text/html;charset=utf-8'>
<meta name='robots' content='noindex,nofollow'>
<title>[<% ident(); %>] Admin: Configuration</title>

<link rel='stylesheet' type='text/css' href='sabai.css'>
<script type='text/javascript' src='tomato.js'></script>

<!-- / / / -->

<script type='text/javascript'>
//	<% nvram("et0macaddr,t_features,t_model_name"); %>
//	<% nvstat(); %>
	var a = nvstat.free / nvstat.size * 100.0;

function backupNameChanged(){
	var name = fixFile(E('backup-name').value);
	E('backup-link').href = ( (name.length > 1) ? ('cfg/' + name + '.cfg?_http_id=' + nvram.http_id) : '?' )
}

function backupButton(){
	var name = fixFile(E('backup-name').value);
	if (name.length <= 1) {
		alert('Invalid filename');
		return;
	}
	location.href = 'cfg/' + name + '.cfg?_http_id=' + nvram.http_id;
}

function restoreButton(){
	var name, i, f;

	name = fixFile(E('restore-name').value);
	name = name.toLowerCase();
	if ((name.indexOf('.cfg') != (name.length - 4)) && (name.indexOf('.cfg.gz') != (name.length - 7))) {
		alert('Incorrect filename. Expecting a ".cfg" file.');
		return;
	}
	if (!confirm('Are you sure?')) return;
	E('restore-button').disabled = 1;

	f = E('restore-form');
	form.addIdAction(f);
	f.submit();
}

function resetButton(){
	var i;

	i = E('restore-mode').value;
	if (i == 0) retuddrn;
	if ((i == 2) && (features('!nve'))) {
		if (!confirm('WARNING: Erasing the NVRAM on a ' + nvram.t_model_name + ' router may be harmful. It may not be able to re-setup the NVRAM correctly after a complete erase. Proceeed anyway?')) return;
	}
	if (!confirm('Are you sure?')) return;
	E('reset-button').disabled = 1;
	form.submit('aco-reset-form');
}
function init(){
	backupNameChanged();
	if (a <= 5) E('nvwarn').style.display = 'block';
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

<div class='section-title'>Backup Configuration</div>
<div class='section'>
	<form>
		<script type='text/javascript'>
		W("<input type='text' size='40' maxlength='64' id='backup-name' onchange='backupNameChanged()' value='tomato_v" + ('<% version(); %>'.replace(/\./g, '')) + "_m" + nvram.et0macaddr.replace(/:/g, '').substring(6, 12) + "'>");
		</script>
		.cfg &nbsp;
		<input type='button' name='f_backup_button' onclick='backupButton()' value='Backup'><br>
		<a href='' id='backup-link'>Link</a>
	</form>
</div>

<br><br>

<div class='section-title'>Restore Configuration</div>
<div class='section'>
	<form id='restore-form' method='post' action='cfg/restore.cgi' encType='multipart/form-data'>
		Select the configuration file to restore:<br>
		<input type='file' size='40' id='restore-name' name='filename'> <input type='button' name='f_restore_button' id='restore-button' value='Restore' onclick='restoreButton()'>
		<br>
	</form>
</div>

<br><br>

<div class='section-title'>Restore Default Configuration</div>
<div class='section'>
	<form id='aco-reset-form' method='post' action='cfg/defaults.cgi'>
	<select name='mode' id='restore-mode'>
		<option value=0>Select...</option>
		<option value=1>Restore default router settings (normal)</option>
		<option value=2>Erase all data in NVRAM memory (thorough)</option>
	</select>
	<input type='button' value='OK' onclick='resetButton()' id='reset-button'>
	</form>
</div>

<br>

<div class='section-title'></div>
<div class='section'>
<script type='text/javascript'>
createFieldTable('', [
	{ title: 'Total / Free NVRAM:', text: scaleSize(nvstat.size) + ' / ' + scaleSize(nvstat.free) + ' <small>(' + (a).toFixed(2) + '%)</small>' }
]);

</script>

<div class='note-warn' style='display:none' id='nvwarn'>The NVRAM free space is very low. It is strongly recommended to erase all data in NVRAM memory, and reconfigure the router manually in order to clean up all unused and obsolete entries.</div>
</div>

<!-- / / / -->

</td></tr>
<tr><td id='footer' colspan=2>&nbsp;</td></tr>
</table>
<br><br>
</body>
</html>
