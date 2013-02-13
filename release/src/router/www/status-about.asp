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
<title>[<% ident(); %>] About</title>

<link rel='stylesheet' type='text/css' href='sabai.css'>
<script type='text/javascript' src='tomato.js'></script>
<script type='text/javascript'>
//	<% nvram(""); %>	// http_id

var clicks = 0;
var tux;
var t = 0;
var r = 3;
var rd = 1;

function moo(){
	if ((r <= 2) || (r >= 25)) rd = -rd;
	r += rd; t += (Math.PI / 10); if (t > (2 * Math.PI)) t = 0;
	var x = tux.origX + (r * Math.sin(t)); var y = tux.origY + (r * Math.cos(t));
	tux.style.left = x + 'px'; tux.style.top = y + 'px';
	if (clicks > 0) setTimeout(moo, 33);
}

function onClick(){ if (++clicks < 10){ moo(); }else{ clicks = 0; } }

function init(){
		tux = E('tux');

		var o = elem.getOffset(tux);
		tux.origX = o.x; tux.origY = o.y;
		tux.style.position = 'absolute';
		tux.style.left = o.x + 'px'; tux.style.top = o.y + 'px';
		tux.addEventListener('click', onClick, false);
}
</script>

<!-- / / / -->

</head>
<body onload='init()'>
<table id='container' cellspacing=0>
<tr><td colspan=2 id='header'><a id='headlink' href='http://www.sabaitechnology.com'><img src='imgsabai.png' id='headlogo'></a>
	<div class='title' id='SVPNstatus'><% sabaid(); %></div>
	<div class='version' id='subversion'>version <!-- SABAI-VERSION --></div>
</td></tr>
<tr id='body'><td id='navi'><% sabaaiMenu(); %></td>
<td id='content'>
<div id='ident'><% ident(); %></div>


<!-- / / / -->

<div style='float:right;margin:20px 20px;text-align:center'>
<img src='imgtux.png' alt='Linux &amp; Tomato' id='tux'>
</div>
<div style='margin:20px 20px;font-size:14px;color:#555;'>
Tomato Firmware v<% version(1); %><br>
Sabai version: <!-- SABAI-VERSION --><br>

Custom VPN client interface and VPN service specific code, VPN port forwarding,<br>
dual gateway functionality, and other non-Tomato based code and Simplified VPN Interface<br>
 © <a href='www.sabaitechnology.com'>Sabai Technology</a>, <a href='mailto: development@sabaitechnology'>development@sabaitechnology.com</a>.<br>
<br>
Simplified VPN Client Interface - Sabai Technology US patent pending #13/292,509.<br>
<br>
We support and appreciate the exceptional work done by many in the development of<br>
Tomato and TomatoUSB software.  Sabai Technology proudly supports the Tomato project,<br>
on behalf of our customers!
<br><br>
Built on <% build_time(); %><br>
<br><br>

Based on Tomato Firmware v<% version(); %><br>
Copyright (C) 2006-2010 Jonathan Zarate<br>
<a href='http://www.polarcloud.com/tomato/' target='_new'>http://www.polarcloud.com/tomato/</a><br>
<br>

Linux kernel <% version(2); %> and Broadcom Wireless Driver <% version(3); %> updates,<br>
support for additional router models, dual-band and Wireless-N mode
<!-- USB-BEGIN -->
, USB support integration and GUI
<!-- USB-END -->
<!-- IPV6-BEGIN -->
, IPv6 support
<!-- IPV6-END -->
.<br>

<br>
Copyright (C) 2008-2011 Fedor Kozhevnikov, Ray Van Tassle, Wes Campaigne<br>
<a href='http://www.tomatousb.org/' target='_new'>http://www.tomatousb.org</a><br>
<!-- / / / -->
<br>
Based on a compilation by Toastman which may also include:<br>
<br>
"Teddy Bear" current features, notably:<br>
- USB Support, Samba, FTP, Media Servers<br>
- Web Monitor, Per-connection transfer rates<br>
- Additional ipv6 support in GUI, QOS, Conntrack<br>
<a href='http://www.tomatousb.org/' target='_new'>http://www.tomatousb.org</a><br>
<br>
"Victek RAF" features:<br>
- CPU Freq | Previous WAN IP<br>
- HFS/HFS+MAC OS x read support<br>
<!-- NOCAT-BEGIN -->
- Captive Portal (Based on NocatSplash) <br>
<!-- NOCAT-END -->
Copyright (C) 2007-2011 Vicente Soriano<br>
<!-- NOCAT-BEGIN -->
Captive Portal Copyright (C) 2011 Ofer Chen & Vicente Soriano<br>
<!-- NOCAT-END -->
<a href='http://victek.is-a-geek.com' target='_new'>http://victek.is-a-geek.com</a><br>
<br>
"Shibby" features:<br>
- Custom log file path<br>
<!-- LINUX26-BEGIN -->
- SD-idle tool integration for kernel 2.6<br>
<!-- USB-BEGIN -->
- 3G Modem support (big thanks for @LDevil)<br>
<!-- USB-END -->
<!-- LINUX26-END -->
<!-- SNMP-BEGIN -->
- SNMP integration and GUI<br>
<!-- SNMP-END -->
Copyright (C) 2011 Michał Rupental<br>
<a href='http://openlinksys.info' target='_new'>http://openlinksys.info</a><br>
<br>
<!-- JYAVENARD-BEGIN -->
"JYAvenard" Features<br>
Copyright (C) 2010-2011 Jean-Yves Avenard<br>
<a href='mailto:jean-yves@avenard.org'>jean-yves@avenard.org</a><br>
<br>
<!-- JYAVENARD-END -->
"Teaman" Features:<br>
- QOS-detailed & ctrate improved filters<br>
- Per-IP bandwidth monitoring of LAN clients [cstats v2]<br>
- IPTraffic conn/BW ratios graphs<br>
- Static ARP binding<br>
- CPU % usage<br>  
- Udpxy v1.0-Chipmunk-build 21<br>
<!-- VLAN-BEGIN -->
- Multiple LAN support integration and GUI<br>
- Multiple/virtual SSID support (experimental)<br>
<!-- VLAN-END -->
- Real-time bandwidth monitoring of LAN clients<br>
- Static ARP binding<br>
Copyright (C) 2011-2012 Augusto Bott<br>
<a href='http://code.google.com/p/tomato-sdhc-vlan/' target='_new'>http://code.google.com/p/tomato-sdhc-vlan/</a><br>
<br>
"Tiomo" Features:<br>
- IMQ based QOS Ingress<br>
- Incoming Class Bandwidth pie chart<br>
Copyright (C) 2012 Tiomo<br>
<br>
"Toastman" Features:<br>
- 250 entry limit in Static DHCP  & Wireless Filter<br>
- 500 entry limit in Access Restriction rules<br>
- Up to 80 QOS rules<br>
- IMQ based QOS/Bandwidth Limiter<br>
- Configurable QOS class names<br>
- Comprehensive QOS rule examples set by default<br>
- TC-ATM overhead calculation - patch by tvlz<br>
- GPT support for HDD by Yaniv Hamo<br>
Copyright (C) 2010-2012 Toastman<br>
<a href='http://www.toastmanfirmware.yolasite.com'>http://www.toastmanfirmware.yolasite.com</a><br>

<!-- Please do not remove or change the homepage link or donate button. Thanks. - Jon -->
<br>
<form action="https://www.paypal.com/cgi-bin/webscr" method="post">
<input type="hidden" name="cmd" value="_s-xclick">
<input type="image" src="imgpp.gif" border="0" name="submit" alt="Donate">
<input type="hidden" name="encrypted" value="-----BEGIN PKCS7-----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-----END PKCS7-----">
</form>

<div style='text-align: center; margin:2em 0; font-size: .85em'>
<b>Thanks to everyone who risked their routers, tested, reported bugs, made suggestions and contributed to the Tomato project. ^ _ ^</b>
</div>
</div>
<!-- / / / -->

</td></tr>
	<tr><td id='footer' colspan=2>&nbsp;</td></tr>
</table>
</body>
</html>
