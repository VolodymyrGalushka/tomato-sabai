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
<title>[<% ident(); %>] Status: Logs</title>

<link rel='stylesheet' type='text/css' href='sabai.css'>
<script type='text/javascript' src='tomato.js'></script>

<!-- / / / -->

<script type='text/javascript' src='debug.js'></script>

<script type='text/javascript'>

//	<% nvram("vpn_service,log_file"); %>


///* DAVID BEGIN */

function find(){
 var s = E('find-text').value;
 if(s.length){
  que.drop( 'logs/view.cgi' , postLog, 'find=' + escapeCGI(s) + '&_http_id=' + nvram.http_id );
 }
}

function postLog(text){
 var LR = E('log_response');
 if(LR.firstChild){
  LR.removeChild(LR.firstChild);
 }
 LR.appendChild(document.createTextNode(text));
}

function bubble_catch(event){
 event.stopPropagation();
}

function getLog(allornone){
 var lines;
 if(allornone != null){
  lines = 'all';
 }else{
  lines = E('lineCount').value;
  if(lines>1000){
   lines = 'all';
  }
 }
 que.drop( 'logs/view.cgi' , postLog, 'which=' + lines + '&_http_id=' + nvram.http_id );
}

///* DAVID END */

function init()
{
	var e = E('find-text');
	if (e) e.onkeypress = function(ev) {
		if (checkEvent(ev).keyCode == 13) find();
	}
}

</script>

<!-- DAVID BEGIN -->
<style type='text/css'>

.tablemenu { width: 100%; border: 1px transparent double !important; border-collapse: collapse; }

.tablemenu td { border: 1px black solid; text-align: center; }

#finder { position: relative; top: 0px; height: 22px;}

#log_response{ width: 100%; height: 480px; }

</style>
<!-- DAVID END -->

</head>
<body onload='init()'>
<form id='_fom' action='javascript:{}'>
<table id='container' cellspacing=0>
<tr><td colspan=2 id='header'><a id='headlink' href=''><img src='' id='headlogo'></a>
	<div class='title' id='SVPNstatus'>Sabai</div>
	<div class='version' id='subversion'>version <!-- SABAI-VERSION --></div>
</td></tr>
<tr id='body'><td id='navi'><script type='text/javascript'>navi()</script></td>
<td id='content'>


<!-- / / / -->

<div id='logging'>
	<div class='section-title'>Logs</div>
	<div class='section'>

<!-- DAVID BEGIN -->

<table class='tablemenu'><tbody><tr>
 <td><a onclick='getLog(null);'>View Last <input onclick='bubble_catch(event);' id='lineCount' size='5' value='25' /> Lines</a></td>
 <td><a onclick='getLog(true);'>View All</a></td>
 <td><a href="logs/syslog.txt?_http_id=<% nv(http_id) %>">Download Log File</a></td>
 <td><input type="text" maxsize=32 size=33 id="find-text"><input type="button" value="Find" onclick="find()" id='finder'></td>
 <td>&raquo; <a href="admin-log.asp">Logging Configuration</a></td>
</tr></tbody></table>

<textarea id='log_response'></textarea>

<!-- DAVID END -->

	</div>
</div>

<script type='text/javascript'>
if (nvram.log_file != '1') {
	W('<div class="note-disabled">Internal logging disabled.</b><br><br><a href="admin-log.asp">Enable &raquo;</a></div>');
	E('logging').style.display = 'none';
}
</script>
</td></tr>
<tr><td id='footer' colspan=2>&nbsp;</td></tr>
</table>
</form>
</body>
</html>
