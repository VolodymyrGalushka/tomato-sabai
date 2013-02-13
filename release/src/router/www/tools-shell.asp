<!DOCTYPE HTML PUBLIC '-//W3C//DTD HTML 4.0//EN'>
<!--
	Tomato GUI

	For use with Tomato Firmware only.
	No part of this file may be used without permission.
-->
<html>
<head>
<meta http-equiv='content-type' content='text/html;charset=utf-8'>
<meta name='robots' content='noindex,nofollow'>
<title>[<% ident(); %>] Tools: System Commands</title>

<link rel='stylesheet' type='text/css' href='sabai.css'>
<script type='text/javascript' src='tomato.js'></script>

<!-- / / / -->

<script type='text/javascript'>

//	<% nvram(""); %>	// http_id

var s,f;
var cmdresult = '';
var cmd = null;

function verifyFields(focused, quiet){ return 1; }

function escapeText(s){
	function esc(c) {
		return '&#' + c.charCodeAt(0) + ';';
	}
	return s.replace(/[&"'<>]/g, esc).replace(/\n/g, ' <br>').replace(/ /g, '&nbsp;');
}

function spin(x){
	E('execb').disabled = x;
	f.f_cmd.disabled = x;
	E('wait').style.visibility = x ? 'visible' : 'hidden';
	if (!x) cmd = null;
}

function updateResult(){
	E('result').innerHTML = '<tt>' + escapeText(cmdresult) + '</tt>';
	cmdresult = '';
	spin(0);
}

function execute(){
	// Opera 8 sometimes sends 2 clicks
	if (cmd) return;
	spin(1);

	cmd = new XmlHttp();
	cmd.onCompleted = function(text, xml) {
		eval(text);
		updateResult();
	}
	cmd.onError = function(x) {
		cmdresult = 'ERROR: ' + x;
		updateResult();
	}

	s = f.f_cmd.value;
	cmd.post('shell.cgi', 'action=execute&command=' + escapeCGI(s.replace(/\r/g, '')));
	cookie.set('shellcmd', escape(s));
}

function init(){
	f = E('_exec');
	if ((s = cookie.get('shellcmd')) != null) f.f_cmd.value = unescape(s);
}
</script>

</head>

<body onload='init()'>
<form id='_exec'>
<table id='container' cellspacing=0>
<tr><td colspan=2 id='header'><a id='headlink' href='http://www.sabaitechnology.com'><img src='imgsabai.png' id='headlogo'></a>
	<div class='title' id='SVPNstatus'><% sabaid(); %></div>
	<div class='version' id='subversion'>version <!-- SABAI-VERSION --></div>
</td></tr>
<tr id='body'><td id='navi'><% sabaaiMenu(); %></td>
<td id='content'>


<!-- / / / -->

<div class='section-title'>Execute System Commands</div>
<div class='section'>

<textarea class='content' name="f_cmd" id="_f_cmd" wrap="off"></textarea>
<input style='float:right;margin-top:.5em;' type='button' value='Execute' onclick='execute()' id='execb'></div>

<div style="visibility:hidden;text-align:right" id="wait">Please wait... <img src='imgspin.gif' style="vertical-align:top"></div>
<pre id='result'></pre>

<!-- / / / -->

</td></tr>
<tr><td id='footer' colspan=2>&nbsp;</td></tr>
</table>
</form>
</body>
</html>
