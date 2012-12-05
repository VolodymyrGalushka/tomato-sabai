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
<title>[<% ident(); %>] Advanced: Firewall</title>

<link rel='stylesheet' type='text/css' href='sabai.css'>
<script type='text/javascript' src='tomato.js'></script>

<!-- / / / -->

<script type='text/javascript' src='debug.js'></script>

<script type='text/javascript'>

//	<% nvram("vpn_service,block_wan,multicast_pass,nf_loopback,ne_syncookies,wan_route"); %>

function verifyFields(focused, quiet)
{
	return 1;
}

function save()
{
	var fom;

	if (!verifyFields(null, 0)) return;

	fom = E('_fom');
	fom.block_wan.value = E('_f_icmp').checked ? 0 : 1;
	fom.multicast_pass.value = E('_f_multicast').checked ? 1 : 0;
	fom.ne_syncookies.value = E('_f_syncookies').checked ? 1 : 0;
	fom.wan_route.value = E('_wan_route').checked ? 1 : 0;
	form.submit(fom, 1);
}
</script>

</head>
<body>
<form id='_fom' method='post' action='tomato.cgi'>
<table id='container' cellspacing=0>
<tr><td colspan=2 id='header'><a id='headlink' href=''><img src='' id='headlogo'></a>
	<div class='title' id='SVPNstatus'>Sabai</div>
	<div class='version' id='subversion'>version <!-- SABAI-VERSION --></div>
</td></tr>
<tr id='body'><td id='navi'><script type='text/javascript'>navi()</script></td>
<td id='content'>


<!-- / / / -->

<input type='hidden' name='_nextpage' value='advanced-firewall.asp'>
<input type='hidden' name='_service' value='firewall-restart'>

<input type='hidden' name='block_wan'>
<input type='hidden' name='multicast_pass'>
<input type='hidden' name='ne_syncookies'>

<div class='section-title'>Firewall</div>
<div class='section'>
<script type='text/javascript'>
createFieldTable('', [
	{ title: 'Respond to ICMP ping', name: 'f_icmp', type: 'checkbox', value: nvram.block_wan == '0' },
	{ title: 'Allow multicast', name: 'f_multicast', type: 'checkbox', value: nvram.multicast_pass == '1' },
	{ title: 'NAT loopback', name: 'nf_loopback', type: 'select', options: [[0,'All'],[1,'Forwarded Only'],[2,'Disabled']], value: fixInt(nvram.nf_loopback, 0, 2, 1) },
	{ title: 'Enable SYN cookies', name: 'f_syncookies', type: 'checkbox', value: nvram.ne_syncookies != '0' },
	{ title: 'Enable WAN route input', name: 'wan_route', type: 'checkbox', value: nvram.wan_route == '1' }
]);
</script>
</div>
<div id='footer'>
	<span id='footer-msg'></span>
	<input type='button' value='Save' id='save-button' onclick='save()'>
	<input type='button' value='Cancel' id='cancel-button' onclick='reloadPage();'>
</div>

<!-- / / / -->

</td></tr>
</table>
</form>
<script type='text/javascript'>
verifyFields(null, 1);
E('_nf_loopback').style.className = 'hiddenChildMenu';
</script>
</body>
</html>
