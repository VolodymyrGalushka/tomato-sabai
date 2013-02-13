<!DOCTYPE HTML PUBLIC '-//W3C//DTD HTML 4.0//EN'><html><head>
<meta http-equiv='content-type' content='text/html;charset=utf-8'>
<meta name='robots' content='noindex,nofollow'>
<title>[<% ident(); %>] Advanced: Routing</title>
<link rel='stylesheet' type='text/css' href='sabai.css'>
<script type='text/javascript' src='tomato.js'></script>

<!-- / / / -->

<style type='text/css'>
#ara-grid .co1, #ara-grid .co2, #ara-grid .co3 { width: 20%; }
#ara-grid .co4 { width: 6%; }
#ara-grid .co5 { width: 34%; }
#ars-grid .co1, #ars-grid .co2, #ars-grid .co3  { width: 20%; }
#ars-grid .co4 { width: 6%; }
#ars-grid .co5 { width: 10%; }
#ars-grid .co6 { width: 24%; }
</style>

<script type='text/javascript' src='debug.js'></script>

<script type='text/javascript'>
// <% nvram("wk_mode,dr_setting,lan_stp,routes_static,dhcp_routes,lan_ifname,wan_ifname,wan_iface,emf_enable"); %>
// <% activeroutes(); %>

var ara = new TomatoGrid();

ara.setup = function() {
	var i, a;

	this.init('ara-grid', 'sort');
	this.headerSet(['Destination', 'Gateway / Next Hop', 'Subnet Mask', 'Metric', 'Interface']);
	for (i = 0; i < activeroutes.length; ++i) {
		a = activeroutes[i];
		if (a[0] == nvram.lan_ifname) a[0] += ' (LAN)';
			else if (a[0] == nvram.wan_iface) a[0] += ' (WAN)';
			else if (a[0] == nvram.wan_ifname) a[0] += ' (MAN)';
		this.insertData(-1, [a[1],a[2],a[3],a[4],a[0]]);
	}
}

function earlyInit(){ ara.setup(); }
function init(){ ara.recolor(); }
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

<input type='hidden' name='_nextpage' value='advanced-routing.asp'>
<input type='hidden' name='_service' value='routing-restart'>

<input type='hidden' name='routes_static'>
<input type='hidden' name='lan_stp'>
<input type='hidden' name='dhcp_routes'>
<input type='hidden' name='emf_enable'>
<input type='hidden' name='dr_lan_tx'>
<input type='hidden' name='dr_lan_rx'>
<input type='hidden' name='dr_wan_tx'>
<input type='hidden' name='dr_wan_rx'>

<div class='section-title'>Current Routing Table</div>
<div class='section'>
	<table class='tomato-grid' id='ara-grid'></table>
</div>
<div><input type='button' value='Reload' id='cancel-button' onclick='reloadPage();'></div>

<!-- / / / -->

</td></tr>
<tr><td id='footer' colspan=2><span id='footer-msg'></span></td></tr>
</table>
</form>
<script type='text/javascript'>earlyInit()</script>
</body>
</html>
