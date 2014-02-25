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
<title>[<% ident(); %>] QoS: Classification</title>

<link rel='stylesheet' type='text/css' href='sabai.css'>
<script type='text/javascript' src='tomato.js'></script>
<script type='text/javascript' src='protocols.js'></script>

<!-- / / / -->

<style type='text/css'>
#qg div {
	padding: 0 0 1px 0;
	margin: 0;
}

#qg .co1 {
	width: 370px;
}
#qg .co2 {
	width: 80px;
}
#qg .co3 {
	width: 300px;
}
#qg .co4 {
	width: 40px;
}
#qg .x1a {
	width: 34%;
	float: left;
}
#qg .x1b {
	width: 66%;
	float: left;
}

#qg .x2a {
	width: 35%;
	float: left;
	clear: left;
}
#qg .x2b {
	width: 23%;
	float: left;
}
#qg .x2c {
	width: 41%;
	float: left;
}

#qg .x3a {
	width: 40%;
	float: left;
	clear: left;
}
#qg .x3b {
	width: 60%;
	float: left;
}

#qg .x4a {
	width: 58%;
	float: left;
	clear: left;
}
#qg .x4b {
	width: 41%;
	float: left;
}
#qg .x5a {
	float: left;
	clear: left;
	width: 70px;
}

#qg .x5b {
	float: left;
	padding: 2px 8px 0 8px;
	width: 10px;
	text-align: center;
}
#qg .x5c {
	float: left;
	width: 70px;
}
#qg .x5d {
	float: left;
	padding: 2px 0 0 8px;
	width: 100px;
}

</style>

<script type='text/javascript' src='debug.js'></script>

<script type='text/javascript'>

//	<% nvram("qos_enable,qos_orules"); %>

var abc = ['Highest', 'High', 'Medium', 'Low', 'Lowest', 'A','B','C','D','E'];

var ipp2p = [
	[0,'IPP2P (disabled)'],[0xFFF,'All IPP2P filters'],[1,'AppleJuice'],[2,'Ares'],[4,'BitTorrent'],[8,'Direct Connect'],
	[16,'eDonkey'],[32,'Gnutella'],[64,'Kazaa'],[128,'Mute'],[256,'SoulSeek'],[512,'Waste'],[1024,'WinMX'],[2048,'XDCC']];

var dscp = [
	['','DSCP (any)'],['0x00','BE'],
	['0x08','CS1'],['0x10','CS2'],['0x18','CS3'],['0x20','CS4'],['0x28','CS5'],['0x30','CS6'],['0x38','CS7'],
	['0x0a','AF11'],['0x0c','AF12'],['0x0e','AF13'],['0x12','AF21'],['0x14','AF22'],['0x16','AF23'],
	['0x1a','AF31'],['0x1c','AF32'],['0x1e','AF33'],['0x22','AF41'],['0x24','AF42'],['0x26','AF43'],
	['0x2e','EF'],['*','DSCP value']];
for (i = 1; i < dscp.length - 1; ++i)
	dscp[i][1] = 'DSCP Class ' + dscp[i][1];

// <% layer7(); %>
layer7.sort();
for (i = 0; i < layer7.length; ++i)
	layer7[i] = [layer7[i],layer7[i]];
layer7.unshift(['', 'Layer 7 (disabled)']);

var class1 = [[-1,'Disabled']];
for (i = 0; i < 10; ++i) class1.push([i, abc[i]]);
var class2 = class1.slice(1);
var ruleCounter = 0;

var qosg = new TomatoGrid();

function dscpClass(v)
{
	var s, i;

	s = '';
	if (v != '') {
		for (i = 1; i < dscp.length - 1; ++i)	// skip 1st and last elements
			if (dscp[i][0] * 1 == v * 1) {
				s = dscp[i][1];
				break;
			}
	}
	return s;
}

qosg.dataToView = function(data) {
	var b = [];
	var s, i;

	if (data[0] != 0) {
		b.push(((data[0] == 1) ? 'To ' : 'From ') + data[1]);
	}
	if (data[2] >= -1) {
		if (data[2] == -1) b.push('TCP/UDP');
			else if (data[2] >= 0) b.push(protocols[data[2]] || data[2]);
		if (data[3] != 'a') {
			if (data[3] == 'd') s = 'Dst ';
				else if (data[3] == 's') s = 'Src ';
					else s = '';
			b.push(s + 'Port: ' + data[4].replace(/:/g, '-'));
		}
	}
	if (data[5] != 0) {
		for (i = 0; i < ipp2p.length; ++i)
			if (ipp2p[i][0] == data[5]) {
				b.push('IPP2P: ' + ipp2p[i][1]);
				break;
			}

	}
	else if (data[6] != '') {
		b.push('L7: ' + data[6])
	}

	if (data[9] != '') {
		s = dscpClass(data[9]);
		if (s != '') b.push(s);
		else b.push('DSCP Value: ' + data[9]);
	}

	if (data[7] != '') {
		b.push('Transferred: ' + data[7] + ((data[8] == '') ? '<small>KB+</small>' : (' - ' + data[8] + '<small>KB</small>')));
	}

	return [b.join('<br>'), class1[(data[10] * 1) + 1][1], escapeHTML(data[11]), (ruleCounter >= 0) ? ''+ ++ruleCounter : ''];
}

qosg.fieldValuesToData = function(row) {
	var f = fields.getAll(row);
	var proto = f[2].value;
	var dir = f[3].value;
	var vdscp = (f[7].value == '*') ? f[8].value : f[7].value;
	if ((proto != -1) && (proto != 6) && (proto != 17)) dir = 'a';
	return [f[0].value, f[0].selectedIndex ? f[1].value : '',
			proto, dir, (dir != 'a') ? f[4].value : '',
			f[5].value, f[6].value, f[9].value, f[10].value, 
			vdscp, f[11].value, f[12].value];
}

qosg.dataToFieldValues = function(data) {
	var s = '';

	if (data[9] != '') {
		if (dscpClass(data[9]) == '') s = '*';
		else s = data[9].toLowerCase();
	}

	return [data[0], data[1], data[2], data[3], data[4], data[5], data[6], s, data[9], data[7], data[8], data[10], data[11]];
}

qosg.resetNewEditor = function() {
	var f = fields.getAll(this.newEditor);
	f[0].selectedIndex = 0;
	f[1].value = '';
	f[2].selectedIndex = 1;
	f[3].selectedIndex = 0;
	f[4].value = '';
	f[5].selectedIndex = 0;
	f[6].selectedIndex = 0;
	f[7].selectedIndex = 0;
	f[8].value = '';
	f[9].value = '';
	f[10].value = '';
	f[11].selectedIndex = 5;
	f[12].value = '';
	this.enDiFields(this.newEditor);
	ferror.clearAll(fields.getAll(this.newEditor));
}

qosg._disableNewEditor = qosg.disableNewEditor;
qosg.disableNewEditor = function(disable) {
	qosg._disableNewEditor(disable);
	if (!disable) {
		this.enDiFields(this.newEditor);
	}
}

qosg.enDiFields = function(row) {
	var f = fields.getAll(row);
	var x;

	f[1].disabled = (f[0].selectedIndex == 0);
	x = f[2].value;
	x = ((x != -1) && (x != 6) && (x != 17));
	f[3].disabled = x;
	if (f[3].selectedIndex == 0) x = 1;
	f[4].disabled = x;

	f[6].disabled = (f[5].selectedIndex != 0);
	f[5].disabled = (f[6].selectedIndex != 0);

	f[8].disabled = (f[7].value != '*');
}

function v_dscp(e, quiet)
{
	if ((e = E(e)) == null) return 0;
	var v = e.value;
	if ((!v.match(/^ *(0x)?[0-9A-Fa-f]+ *$/)) || (v < 0) || (v > 63)) {
		ferror.set(e, 'Invalid DSCP value. Valid range: 0x00-0x3F', quiet);
		return 0;
	}
	e.value = '0x' + (v * 1).hex(2);
	ferror.clear(e);
	return 1;
}

qosg.verifyFields = function(row, quiet) {
	var f = fields.getAll(row);
	var a, b, e;

	this.enDiFields(row);
	ferror.clearAll(f);

	a = f[0].value * 1;
	if ((a == 1) || (a == 2)) {
		if (!v_length(f[1], quiet, 1)) return 0;
		if (!_v_iptaddr(f[1], quiet, 0, 1, 1)) return 0;
	}
	else if ((a == 3) && (!v_mac(f[1], quiet))) return 0;

	b = f[2].selectedIndex;
	if ((b > 0) && (b <= 3) && (f[3].selectedIndex != 0) && (!v_iptport(f[4], quiet))) return 0;

	var BMAX = 1024 * 1024;

	e = f[9];
	a = e.value = e.value.trim();
	if (a != '') {
		if (!v_range(e, quiet, 0, BMAX)) return 0;
		a *= 1;
	}

	e = f[10];
	b = e.value = e.value.trim();
	if (b != '') {
		b *= 1;
		if (b >= BMAX) e.value = '';
			else if (!v_range(e, quiet, 0, BMAX)) return 0;
		if (a == '') f[9].value = a = 0;
	}
	else if (a != '') {
		b = BMAX;
	}

	if ((b != '') && (a >= b)) {
		ferror.set(f[9], 'Invalid range', quiet);
		return 0;
	}

	if (f[7].value == '*') {
		if (!v_dscp(f[8], quiet)) return 0;
	}
	else f[8].value = f[7].value;

	if (!v_nodelim(f[12], quiet, 'Description', 1)) return 0;
	return v_length(f[12], quiet);
}

qosg.setup = function() {
	var i, a, b;
	a = [[-2, 'Any Protocol'],[-1,'TCP/UDP'],[6,'TCP'],[17,'UDP']];
	for (i = 0; i < 256; ++i) {
		if ((i != 6) && (i != 17)) a.push([i, protocols[i] || i]);
	}

	// what a mess...
	this.init('qg', 'move', 50, [
		{ multi: [
			{ type: 'select', options: [[0,'Any Address'],[1,'Dst IP'],[2,'Src IP'],[3,'Src MAC']],
				prefix: '<div class="x1a">', suffix: '</div>' },
			{ type: 'text', prefix: '<div class="x1b">', suffix: '</div>' },

			{ type: 'select', prefix: '<div class="x2a">', suffix: '</div>', options: a },
			{ type: 'select', prefix: '<div class="x2b">', suffix: '</div>',
				options: [['a','Any Port'],['d','Dst Port'],['s','Src Port'],['x','Src or Dst']] },
			{ type: 'text', prefix: '<div class="x2c">', suffix: '</div>' },

			{ type: 'select', prefix: '<div class="x3a">', suffix: '</div>', options: ipp2p },
			{ type: 'select', prefix: '<div class="x3b">', suffix: '</div>', options: layer7 },

			{ type: 'select', prefix: '<div class="x4a">', suffix: '</div>', options: dscp },
			{ type: 'text', prefix: '<div class="x4b">', suffix: '</div>' },

			{ type: 'text', prefix: '<div class="x5a">', suffix: '</div>' },
			{ type: 'text', prefix: '<div class="x5b"> - </div><div class="x5c">', suffix: '</div><div class="x5d">KB Transferred</div>' }
		] },
		{ type: 'select', options: class1, vtop: 1 },
		{ type: 'text', maxlen: 32, vtop: 1 }
	]);

	this.headerSet(['Match Rule', 'Class', 'Description', '#']);

// addr_type < addr < proto < port_type < port < ipp2p < L7 < bcount < dscp < class < desc

	a = nvram.qos_orules.split('>');
	for (i = 0; i < a.length; ++i) {
		b = a[i].split('<');

		if (b.length == 9) {
			// fixup < 0.08		!!! temp
			b.splice(7, 0, '', '', '');
		}
		else if (b.length == 10) {
			// fixup < 1.28.xx55
			b.splice(8, 0, '');
		}

		if (b.length == 11) {
			c = b[7].split(':');
			b.splice(7, 1, c[0], (c.length == 1) ? '' : c[1]);
			b[11] = unescape(b[11]);
		}
		else continue;
		b[4] = b[4].replace(/:/g, '-');
		qosg.insertData(-1, b);
	}
	ruleCounter = -1;

	this.showNewEditor();
	this.resetNewEditor();
}

function verifyFields(focused, quiet)
{
	return 1;
}

function save()
{
	if (qosg.isEditing()) return;

	var fom = E('_fom');
	var i, a, b, c;

	c = qosg.getAllData();
	a = [];
	for (i = 0; i < c.length; ++i) {
		b = c[i].slice(0);
		b[4] = b[4].replace(/-/g, ':');
		b.splice(7, 2, (b[7] == '') ? '' : [b[7],b[8]].join(':'));
		b[10] = escapeD(b[10]);
		a.push(b.join('<'));
	}
	fom.qos_orules.value = a.join('>');

	form.submit(fom, 0);
}

function init()
{
	qosg.recolor();
}
</script>

</head>
<body onload='init()'>
<form id='_fom' method='post' action='tomato.cgi'>
<table id='container' cellspacing=0>
<tr><td colspan=2 id='header'><a id='headlink' href='http://www.sabaitechnology.com'><img src='imgsabai.png' id='headlogo'></a>
	<div class='title' id='SVPNstatus'><% sabaid(); %></div>
	<div class='version' id='subversion'>version <!-- SABAI-VERSION --></div>
</td></tr>
<tr id='body'><td id='navi'><% sabaaiMenu(); %></td>
<td id='content'>


<!-- / / / -->

<input type='hidden' name='_nextpage' value='qos-classify.asp'>
<input type='hidden' name='_service' value='qos-restart'>
<input type='hidden' name='qos_orules'>

<div class='section-title'>QoS Classes</div>
<div class='section'>
	<table class='tomato-grid' cellspacing=1 id='qg'></table>
</div>

<br>
<script type='text/javascript'>
if (nvram.qos_enable != '1') {
	W('<div class="note-warn"><b>QoS disabled.</b> &nbsp; <a href="qos-settings.asp">Enable &raquo;</a></div>');
}
else {
	showNotice('<% notice("iptables"); %>');
}
</script>

<!-- / / / -->

</td></tr>
<tr><td id='footer' colspan=2>
	<span id='footer-msg'></span>
	<input type='button' value='Save' id='save-button' onclick='save()'>
	<input type='button' value='Cancel' id='cancel-button' onclick='reloadPage();'>
</td></tr>
</table>
</form>
<script type='text/javascript'>qosg.setup();</script>
</body>
</html>
