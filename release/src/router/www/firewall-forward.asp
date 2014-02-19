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
<title>[<% ident(); %>] Forwarding: Basic</title>

<link rel='stylesheet' type='text/css' href='sabai.css'>
<script type='text/javascript' src='tomato.js'></script>

<!-- / / / -->
<style type='text/css'>
#fo-grid { width: auto; }
#fo-grid .co1 { width: 25px; text-align: center; }
#fo-grid .co2 { width: 70px; }
#fo-grid .co3 { width: 70px; }
#fo-grid .co4 { width: 120px; }
#fo-grid .co5 { width: 80px; }
#fo-grid .co6 { width: 55px; }
#fo-grid .co7 { width: 110px; }
#fo-grid .co8 { width: 200px; }

</style>

<script type='text/javascript' src='debug.js'></script>

<script type='text/javascript'>

//	<% nvram("portforward"); %>
var lipp = '<% lipp(); %>.';

function colon_v_portrange(e, quiet, v){
	if (v.match(/^(.*)[-:](.*)$/)) {
		var x = RegExp.$1; var y = RegExp.$2;
		x = fixPort(x, -1); y = fixPort(y, -1);
		if ((x == -1) || (y == -1)) { ferror.set(e, 'Invalid port range: ' + v, quiet); return null; }
		if (x > y) { v = x; x = y; y = v; }
		ferror.clear(e);
		if (x == y) return x;
		return x + ':' + y;
	}
	v = fixPort(v, -1);
	if (v == -1) { ferror.set(e, 'Invalid port', quiet); return null; }
	ferror.clear(e);
	return v;
}
function colon_v_iptport(e, quiet){
	var a, i, v, q;
	if ((e = E(e)) == null) return 0;
	a = e.value.split(/[,\.]/);
	if (a.length == 0) { ferror.set(e, 'Expecting a list of ports or port range.', quiet); return 0; }
	if (a.length > 10) { ferror.set(e, 'Only 10 ports/range sets are allowed.', quiet); return 0; }
	q = [];
	for (i = 0; i < a.length; ++i) { v = colon_v_portrange(e, quiet, a[i]); if (v == null) return 0; q.push(v); }
	e.value = q.join(',');
	ferror.clear(e);
	return 1;
}

var fog = new TomatoGrid();

fog.sortCompare = function(a, b) {
	var col = this.sortColumn;
	var da = a.getRowData();
	var db = b.getRowData();
	var r;

	switch (col) {
	case 2:	// src
	case 5:	// ia
		r = cmpIP(da[col], db[col]);
		break;
	case 0:	// on
	case 1: // proto
	case 4:	// ext prt
	case 5:	// int prt
		r = cmpInt(da[col], db[col]);
		break;
	default:
		r = cmpText(da[col], db[col]);
		break;
	}

	return this.sortAscending ? r : -r;
}

fog.dataToView = function(data) {
	return [(data[0] != '0') ? 'On' : '', ['TCP', 'UDP', 'Both'][data[1] - 1], ['WAN', 'VPN', 'Both'][data[2] - 1], (data[3].match(/(.+)-(.+)/)) ? (RegExp.$1 + ' -<br>' + RegExp.$2) : data[3], data[4], data[5], data[6], data[7]];
}

fog.fieldValuesToData = function(row) {
	var f = fields.getAll(row);
	return [f[0].checked ? 1 : 0, f[1].value, f[2].value, f[3].value, f[4].value, f[5].value, f[6].value, f[7].value];
}

fog.verifyFields = function(row, quiet) {
	var f = fields.getAll(row);
	var s;

	f[3].value = f[3].value.trim();
	ferror.clear(f[3]);
	if ((f[3].value.length) && (!v_iptaddr(f[3], quiet))) return 0;

	if (!colon_v_iptport(f[4], quiet)) return 0;
	ferror.clear(f[5]);
	if (f[4].value.search(/[-:,]/) != -1) {
		f[5].value = '';
		f[5].disabled = true;
	}
	else {
		f[5].disabled = false;
		f[5].value = f[5].value.trim();
		if (f[5].value != '') {
			if (!v_port(f[5], quiet)) return 0;
		}
	}
	ferror.clear(f[5]);

	s = f[6].value.trim();
	if (s.match(/^ *\d+ *$/)) f[6].value = lipp + s;
	if (!v_ip(f[6], quiet, 1)) return 0;

	f[7].value = f[7].value.replace(/>/g, '_');
	if (!v_nodelim(f[7], quiet, 'Description')) return 0;
	return 1;
}

fog.resetNewEditor = function() {
	var f = fields.getAll(this.newEditor);
	f[0].checked = 1;
	f[1].selectedIndex = 0;
	f[2].value = '';
	f[3].value = '';
	f[4].value = '';
	f[5].value = '';
	f[6].value = '';
	ferror.clearAll(fields.getAll(this.newEditor));
}

fog.setup = function() {
	this.init('fo-grid', 'sort', 50, [
		{ type: 'checkbox' },
		{ type: 'select', options: [[1, 'TCP'],[2, 'UDP'],[3,'Both']] },
		{ type: 'select', options: [[1, 'WAN'],[2, 'VPN'],[3,'Both']] },
		{ type: 'text', maxlen: 32 },
		{ type: 'text', maxlen: 16 },
		{ type: 'text', maxlen: 5 },
		{ type: 'text', maxlen: 15 },
		{ type: 'text', maxlen: 32 }]);
	this.headerSet(['On', 'Proto', 'VPN', 'Src Address', 'Ext Ports', 'Int Port', 'Int Address', 'Description']);
	var nv = nvram.portforward.split('>');
	for (var i = 0; i < nv.length; ++i) {
	if (r = nv[i].match(/^(\d)<(\d)<(\d)<(.*)<(.+?)<(\d*)<([\d.]*)<(.*)$/)){
			r[1] *= 1; r[2] *= 1; r[3] *= 1; r[5] = r[5].replace(/:/g, '-');
			if (r[7].match(/^ *\d+ *$/)) r[7] = lipp + r[7];
			fog.insertData(-1, [ r[1],r[2],r[3],r[4],r[5],r[6],r[7],r[8] ]);
		}
	}
	fog.sort(6);
	fog.showNewEditor();
}

function srcSort(a, b)
{
	if (a[2].length) return -1;
	if (b[2].length) return 1;
	return 0;
}

function save()
{
	if (window.newEdits&&!confirm("Save without adding last edited row?")) return;

	var data = fog.getAllData().sort(srcSort);
	var s = '';
	for (var i = 0; i < data.length; ++i) {
		data[i][4] = data[i][4].replace(/-/g, ':');
		s += data[i].join('<') + '>';
	}
	var fom = E('_fom');
	fom.portforward.value = s;
	form.submit(fom, 0, 'tomato.cgi');
}

function init(){ fog.recolor(); fog.resetNewEditor(); }
</script>
</head>
<body onload='init()'>
<form id='_fom' method='post' action='javascript:{}'>
<table id='container' cellspacing=0>
<tr><td colspan=2 id='header'><a id='headlink' href='http://www.sabaitechnology.com'><img src='imgsabai.png' id='headlogo'></a>
	<div class='title' id='SVPNstatus'><% sabaid(); %></div>
	<div class='version' id='subversion'>version <!-- SABAI-VERSION --></div>
</td></tr>
<tr id='body'><td id='navi'><% sabaaiMenu(); %></td>
<td id='content'>

<!-- / / / -->

<input type='hidden' name='_nextpage' value='firewall-forward.asp'>
<input type='hidden' name='_service' value='firewall-restart'>

<input type='hidden' name='portforward'>

<div class='section-title'>Port Forwarding</div>
<div class='section'>
	<table class='tomato-grid' cellspacing=1 id='fo-grid'></table>
	<script type='text/javascript'>fog.setup();</script>
</div>
<div id='footer'>
	<span id='footer-msg'></span>
	<input type='button' value='Save' id='save-button' onclick='save()'>
	<input type='button' value='Cancel' id='cancel-button' onclick='reloadPage();'>
	<input type='button' value='Help' onclick='window.open("http://www.sabaitechnology.com/v/sabaiHelp/help.html#pf","_newtab");'>
</div>
<div>
<ul class='explain'>
<li><b>Proto</b> - Which protocol (tcp or udp) to forward.
<li><b>VPN</b> - Forward ports through the normal internet connection (WAN) or through the tunnel (VPN), or both. Note that the <a href='sabai-gw.asp'>Gateways</a> feature may result in may result in undefined behavior when devices routed through an interface have ports forwarded through a different interface.  Additionally, ports will only be forwarded through the VPN when the VPN service is active.
<li><b>Src Address</b> <i>(optional)</i> - Forward only if from this address. Ex: "1.2.3.4", "1.2.3.4 - 2.3.4.5", "1.2.3.0/24", "me.example.com".
<li><b>Ext Ports</b> - The port(s) to be forwarded, as seen from the WAN. Ex: "2345", "200,300", "200-300,400".
<li><b>Int Port</b> - The destination port inside the LAN. Only one port per entry is supported.
<li><b>Int Address</b> - The destination address inside the LAN.
</ul>
</div>
<br>
<script type='text/javascript'>showNotice('<% notice("iptables"); %>');</script>

<!-- / / / -->

</td></tr>
</table>
</form>
</body>
</html>
