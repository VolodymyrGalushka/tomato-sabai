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
<title>[<% ident(); %>] Clear Cookies</title>

<link rel='stylesheet' type='text/css' href='sabai.css'>
<script type='text/javascript' src='tomato.js'></script>
</head>
<body>
<table id='container' cellspacing=0>
<tr><td colspan=2 id='header'><a id='headlink' href='http://www.sabaitechnology.com'><img src='imgsabai.png' id='headlogo'></a>
	<div class='title' id='SVPNstatus'><% sabaid(); %></div>
	<div class='version' id='subversion'>version <!-- SABAI-VERSION --></div>
</td></tr>
<tr id='body'><td id='navi'><% sabaaiMenu(); %></td>
<td id='content'>


<!-- / / / -->

<b>Cookies Cleared</b>

<script type='text/javascript'>
b = [];
c = document.cookie.split(';');
for (i = 0; i < c.length; ++i) {
	if (c[i].match(/^\s*tomato_(.+?)=/)) {
		b.push('<li>' + c[i]);
		cookie.unset(RegExp.$1);
	}
}
if (b.length == 0) b.push('<li>no cookie found');
W('<ul>' + b.join('') + '</ul>');
</script>


<!-- / / / -->

</td></tr>
<tr><td id='footer' colspan=2>&nbsp;</td></tr>
</table>
</body>
</html>
