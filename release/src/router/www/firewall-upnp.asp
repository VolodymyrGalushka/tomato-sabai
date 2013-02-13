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
<title>[<% ident(); %>] Forwarding: UPnP / NAT-PMP</title>

<link rel='stylesheet' type='text/css' href='sabai.css'>
<script type='text/javascript' src='tomato.js'></script>

<!-- / / / -->

<style type='text/css'>
#upnp-grid .co1, #upnp-grid .co2, #upnp-grid .co4, #upnp-grid .co5 { width: 10%; }
#upnp-grid .co3 { width: 15%; }
</style>

<script type='text/javascript'>
	var fom;

/* REMOVE-BEGIN
	!!TB - additional miniupnp settings
REMOVE-END */
//	<% nvram("upnp_enable,upnp_mnp,upnp_clean,upnp_secure,upnp_clean_interval,upnp_clean_threshold,upnp_min_port_ext,upnp_max_port_ext,upnp_min_port_int,upnp_max_port_int"); %>

// <% upnpinfo(); %>

nvram.upnp_enable = fixInt(nvram.upnp_enable, 0, 3, 0);

function submitDelete(proto, eport){ form.submitHidden('upnp.cgi', { remove_proto: proto, remove_eport: eport, _redirect: 'firewall-upnp.asp' }); }
function deleteData(data){ if (confirm('Delete ' + data[3] + ' ' + data[0] + ' -> ' + data[2] + ':' + data[1] + ' ?')) submitDelete(data[3], data[0]); }

var ug = new TomatoGrid();
ug.onClick = function(cell) { deleteData(cell.parentNode.getRowData()); }
ug.rpDel = function(e) { deleteData(PR(e).getRowData()); }

ug.setup = function() {
	this.init('upnp-grid', 'sort delete');
	this.headerSet(['External', 'Internal', 'IP Address', 'Protocol', 'Duration', 'Description']);
	ug.populate();
}
// ['TCP 31000 192.168.134.5 31000 [Test] 0', 'TCP 31001 192.168.134.5 31001 [Test2] 0'];
ug.populate = function() {
	var i, j, r, row, data;
	if (nvram.upnp_enable != 0) {
		var data = mupnp_data.split('\n');
//		alert(data.join('!~!'));
		for (i = 0; i < data.length; ++i) {
			if (data[i] == null || data[i]=='') continue;
			r = data[i].split(' ');

			if( r[0]!='TCP' && r[0]!='UDP' ) continue;
			if( r[1]<1 || r[1]>65535 ) continue;
			if( r[3]<1 || r[3]>65535 ) continue;
			r[2] = fixIP(r[2], false); if(r[2]==null) continue;

			row = this.insertData(-1, [r[1], r[3], r[2], r[0], r[5], r[4]]);
			if (!r[0]) { for (j = 0; j < 5; ++j) { elem.addClass(row.cells[j], 'disabled'); } }
			for (j = 0; j < 5; ++j) { row.cells[j].title = 'Click to delete'; }
		}
		this.sort(2);
	}
	E('upnp-delete-all').disabled = (ug.getDataCount() == 0);
}

function deleteAll(){
	if (!confirm('Delete all entries?')) return;
	submitDelete('*', '0');
}

function verifyFields(focused, quiet){
/* REMOVE-BEGIN
	!!TB - additional miniupnp settings
REMOVE-END */
	var enable = E('_f_enable_upnp').checked || E('_f_enable_natpmp').checked;
	var bc = E('_f_upnp_clean').checked;

	E('_f_upnp_clean').disabled = (enable == 0);
	E('_f_upnp_secure').disabled = (enable == 0);
	E('_f_upnp_mnp').disabled = (E('_f_enable_upnp').checked == 0);
	E('_upnp_clean_interval').disabled = (enable == 0) || (bc == 0);
	E('_upnp_clean_threshold').disabled = (enable == 0) || (bc == 0);
	elem.display(PR(E('_upnp_clean_interval')), (enable != 0) && (bc != 0));
	elem.display(PR(E('_upnp_clean_threshold')), (enable != 0) && (bc != 0));

	if(fom.upnp_min_port_ext.value < 2) fom.upnp_min_port_ext.value = 2;
	if(fom.upnp_min_port_int.value < 2) fom.upnp_min_port_int.value = 2;
	if(fom.upnp_max_port_ext.value > 65535) fom.upnp_max_port_ext.value = 65535;
	if(fom.upnp_max_port_int.value > 65535) fom.upnp_max_port_int.value = 65535;

	if ((enable != 0) && (bc != 0)) {
		if (!v_range('_upnp_clean_interval', quiet, 60, 65535)) return 0;
		if (!v_range('_upnp_clean_threshold', quiet, 0, 9999)) return 0;
	}
	else {
		ferror.clear(E('_upnp_clean_interval'));
		ferror.clear(E('_upnp_clean_threshold'));
	}

	return 1;
}

function save(){
/* REMOVE-BEGIN
	!!TB - miniupnp
REMOVE-END */
	if (!verifyFields(null, 0)) return;

	fom.upnp_enable.value = 0;
	if (fom.f_enable_upnp.checked) fom.upnp_enable.value = 1;
	if (fom.f_enable_natpmp.checked) fom.upnp_enable.value |= 2;

/* REMOVE-BEGIN
	!!TB - additional miniupnp settings
REMOVE-END */
	fom.upnp_mnp.value = E('_f_upnp_mnp').checked ? 1 : 0;
	fom.upnp_clean.value = E('_f_upnp_clean').checked ? 1 : 0;
	fom.upnp_secure.value = E('_f_upnp_secure').checked ? 1 : 0;

	fom.f_upnp_clean.disabled = true;
	fom.f_upnp_secure.disabled = true;
	fom.f_enable_upnp.disabled = true;
	fom.f_enable_natpmp.disabled = true;

	form.submit(fom, 0);
}

function init(){ fom=E('_fom'); ug.setup(); ug.recolor(); verifyFields(null, 1); }

/* REMOVE-BEGIN
	!!TB - miniupnp
REMOVE-END */
function submit_complete(){ reloadPage(); }
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

<input type='hidden' name='_nextpage' value='firewall-upnp.asp'>
<input type='hidden' name='_service' value='upnp-restart'>

<input type='hidden' name='upnp_enable'>
<!-- REMOVE-BEGIN
	!!TB - additional miniupnp settings
REMOVE-END -->
<input type='hidden' name='upnp_mnp'>
<input type='hidden' name='upnp_clean'>
<input type='hidden' name='upnp_secure'>

<div class='section-title'>Forwarded Ports</div>
<div class='section'>
	<table id='upnp-grid' class='tomato-grid'></table>
	<div style='width: 100%; text-align: right'><input type='button' value='Delete All' onclick='deleteAll()' id='upnp-delete-all'> <input type='button' value='Refresh' onclick='javascript:reloadPage();'></div>
</div>

<div class='section-title'>Settings</div>
<div class='section'>
<script type='text/javascript'>
createFieldTable('', [
	{ title: 'Enable UPnP', name: 'f_enable_upnp', type: 'checkbox', value: (nvram.upnp_enable & 1) },
	{ title: 'Enable NAT-PMP', name: 'f_enable_natpmp', type: 'checkbox', value: (nvram.upnp_enable & 2) },
/* REMOVE-BEGIN
	!!TB - additional miniupnp settings
REMOVE-END */
	{ title: 'Inactive Rules Cleaning', name: 'f_upnp_clean', type: 'checkbox', value: (nvram.upnp_clean == '1') },
	{ title: 'Cleaning Interval', indent: 2, name: 'upnp_clean_interval', type: 'text', maxlen: 5, size: 7,
		suffix: ' <small>seconds</small>', value: nvram.upnp_clean_interval },
	{ title: 'Cleaning Threshold', indent: 2, name: 'upnp_clean_threshold', type: 'text', maxlen: 4, size: 7,
		suffix: ' <small>redirections</small>', value: nvram.upnp_clean_threshold },
	{ title: 'Secure Mode', name: 'f_upnp_secure', type: 'checkbox',
		suffix: ' <small>(when enabled, UPnP clients are allowed to add mappings only to their IP)</small>',
		value: (nvram.upnp_secure == '1') },
	null,
	{ title: 'Allowed UPnP Ports', suffix: ' <small>(UPnP clients will only be allowed to map ports in the external range to ports in the internal range)</small>', },
	{ title: 'External Port Range', indent: 2, multi: [
		{ name: 'upnp_min_port_ext', type: 'text', maxlen: 6, size: 4, value: nvram.upnp_min_port_ext, suffix: ' - ' },
		{ name: 'upnp_max_port_ext', type: 'text', maxlen: 6, size: 4, value: nvram.upnp_max_port_ext, suffix: ' <small>(Setting the external lower bound here to less than 1024 may interfere with network services.)</small>' },
	] },
	{ title: 'Internal Port Range', indent: 2, multi: [
		{ name: 'upnp_min_port_int', type: 'text', maxlen: 6, size: 4, value: nvram.upnp_min_port_int, suffix: ' - ' },
		{ name: 'upnp_max_port_int', type: 'text', maxlen: 6, size: 4, value: nvram.upnp_max_port_int, suffix: ' <small>Valid port ranges are from 2 to 65535.</small>' }
	] },
	null,
	{ title: 'Show In My Network Places',  name: 'f_upnp_mnp',  type: 'checkbox',  value: (nvram.upnp_mnp == '1') }
]);
</script>
</div>


<!-- / / / -->

</td></tr>
<tr><td id='footer' colspan=2>
	<span id='footer-msg'></span>
	<input type='button' value='Save' id='save-button' onclick='save()'>
	<input type='button' value='Cancel' id='cancel-button' onclick='javascript:reloadPage();'>
</td></tr>
</table>
</form>
<!-- REMOVE-BEGIN
	!!TB - added verifyFields
REMOVE-END -->
</body>
</html>
