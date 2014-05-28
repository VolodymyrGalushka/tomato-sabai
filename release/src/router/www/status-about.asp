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

function moo()
{
	if ((r <= 2) || (r >= 25)) rd = -rd;
	r += rd;
	t += (Math.PI / 10);
	if (t > (2 * Math.PI)) t = 0;

	var x = tux.origX + (r * Math.sin(t));
	var y = tux.origY + (r * Math.cos(t));

	tux.style.left = x + 'px';
	tux.style.top = y + 'px';

	if (clicks > 0) setTimeout(moo, 33);
}

function onClick()
{
	try {
		++clicks;
		if (clicks < 10) moo();
			else clicks = 0;
	}
	catch (ex) {
	}
}

function init()
{
		tux = E('tux');

		var o = elem.getOffset(tux);
		tux.origX = o.x;
		tux.origY = o.y;

		tux.style.position = 'absolute';
		tux.style.left = o.x + 'px';
		tux.style.top = o.y + 'px';

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


Support for additional router models, dual-band and Wireless-N mode
<!-- USB-BEGIN -->
, USB support integration and GUI
<!-- USB-END -->
<!-- IPV6-BEGIN -->
, IPv6 support
<!-- IPV6-END -->
<br>
Linux kernel <% version(2); %> and Broadcom Wireless Driver <% version(3); %> updates,<br>
support for additional router models, dual-band and Wireless-N mode.<br>
Copyright (C) 2008-2011 Fedor Kozhevnikov, Ray Van Tassle, Wes Campaigne<br>
<a href='http://www.tomatousb.org/' target='_new'>http://www.tomatousb.org</a><br>
<!-- / / / -->
<br>

<!-- OPENVPN-BEGIN -->
<b>OpenVPN integration and GUI,</b><br>
Copyright (C) 2010 Keith Moyer,<br>
<a href='mailto:tomatovpn@keithmoyer.com'>tomatovpn@keithmoyer.com</a><br>
<br>
<!-- OPENVPN-END -->

Based on a compilation by Shibby which may also include:<br>
<b>"Shibby" features:</b><br>
<!-- BBT-BEGIN -->
- Transmission 2.83 integration<br>
<!-- BBT-END -->
<!-- BT-BEGIN -->
- GUI for Transmission<br>
<!-- BT-END -->
<!-- NFS-BEGIN -->
- NFS utils integration and GUI<br>
<!-- NFS-END -->
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
<!-- UPS-BEGIN -->
- APCUPSD integration and GUI (implemented by @arrmo)<br>
<!-- UPS-END -->
<!-- DNSCRYPT-BEGIN -->
- DNScrypt-proxy 1.3.4 integration and GUI<br>
<!-- DNSCRYPT-END -->
<!-- TOR-BEGIN -->
- TOR Project integration and GUI<br>
<!-- TOR-END -->
- TomatoAnon project integration and GUI<br>
- TomatoThemeBase project integration and GUI<br>
- Ethernet Ports State<br>
- Extended MOTD (written by @Monter, modified by @Shibby)<br>
- Webmon Backup Script<br>
Copyright (C) 2011-2013 Michał Rupental<br>
<a href='http://openlinksys.info' target='_new'>http://openlinksys.info</a><br>
<br>

<!-- VPN-BEGIN -->
<b>"JYAvenard" features:</b><br>
<!-- OPENVPN-BEGIN -->
- OpenVPN enhancements &amp; username/password only authentication<br>
<!-- OPENVPN-END -->
<!-- PPTPD-BEGIN -->
- PPTP VPN Client integration and GUI<br>
<!-- PPTPD-END -->
Copyright (C) 2010-2012 Jean-Yves Avenard<br>
<a href='mailto:jean-yves@avenard.org'>jean-yves@avenard.org</a><br>
<br>

<!-- OPENVPN-BEGIN -->
<b>"TomatoEgg" feature:</b><br>
- Openvpn username/password verify feature and configure GUI.<br>
<br>
<!-- OPENVPN-END -->
<!-- VPN-END -->

<b>"Victek" features:</b><br>
- Extended Sysinfo<br>
<!-- NOCAT-BEGIN -->
- Captive Portal. (Based in NocatSplash)<br>
<!-- NOCAT-END -->
<!-- NGINX-BEGIN -->
- Web Server. (NGinX)<br>
<!-- NGINX-END -->
<!-- HFS-BEGIN -->
- HFS / HFS+ filesystem integration<br>
<!-- HFS-END -->
Copyright (C) 2007-2011 Ofer Chen & Vicente Soriano<br>
<a href='http://victek.is-a-geek.com' target='_new'>http://victek.is-a-geek.com</a><br>
<br>

<b>"Teaman" features:</b><br>
- QOS-detailed & ctrate filters<br>
- Realtime bandwidth monitoring of LAN clients<br>
- Static ARP binding<br>
- VLAN administration GUI<br>
- Multiple LAN support integration and GUI<br>
- Multiple/virtual SSID support (experimental)<br>
- UDPxy integration and GUI<br>
<!-- PPTPD-BEGIN -->
- PPTP Server integration and GUI<br>
<!-- PPTPD-END -->
Copyright (C) 2011 Augusto Bott<br>
<a href='http://code.google.com/p/tomato-sdhc-vlan/' target='_new'>Tomato-sdhc-vlan Homepage</a><br>
<br>

<b>"Lancethepants" Features:</b><br>
<!-- DNSSEC-BEGIN -->
- DNSSEC integration and GUI<br>
<!-- DNSSEC-END -->
<!-- DNSCRYPT-BEGIN -->
- DNSCrypt-Proxy selectable/manual resolver<br>
<!-- DNSCRYPT-END -->
- Comcast DSCP Fix GUI<br>
Copyright (C) 2014 Lance Fredrickson<br>
<a href='mailto:lancethepants@gmail.com'>lancethepants@gmail.com</a><br>
<br>

<b>"Toastman" features:</b><br>
- Configurable QOS class names<br>
- Comprehensive QOS rule examples set by default<br>
- TC-ATM overhead calculation - patch by tvlz<br>
- GPT support for HDD by Yaniv Hamo<br>
- Tools-System refresh timer<br>
Copyright (C) 2011 Toastman<br>
<a href='http://www.linksysinfo.org/index.php?threads/using-qos-tutorial-and-discussion.28349/' target='_new'>Using QoS - Tutorial and discussion</a><br>
<br>

<b>"Tiomo" Features:</b><br>
- IMQ based QOS Ingress<br>
- Incoming Class Bandwidth pie chart<br>
Copyright (C) 2012 Tiomo<br>
<br>

<!-- SDHC-BEGIN -->
<b>"Slodki" feature:</b><br>
- SDHC integration and GUI<br>
Copyright (C) 2009 Tomasz Słodkowicz<br>
<a href='http://gemini.net.pl/~slodki/tomato-sdhc.html' target='_new'>tomato-sdhc</a><br>
<br>
<!-- SDHC-END -->

<b>"Victek/PrinceAMD/Phykris/Shibby" feature:</b><br>
- Revised IP/MAC Bandwidth Limiter<br>
<br>

Based on Tomato Firmware v1.28<br>
Copyright (C) 2006-2010 Jonathan Zarate<br>
<a href='http://www.polarcloud.com/tomato/' target='_new'>http://www.polarcloud.com/tomato/</a><br>
<!-- Please do not remove or change the homepage link or donate button. Thanks. - Jon -->
<form action="https://www.paypal.com/cgi-bin/webscr" method="post">
<input type="hidden" name="cmd" value="_s-xclick">
<input type="image" src="imgpp.gif" border="0" name="submit" alt="Donate">
<input type="hidden" name="encrypted" value="-----BEGIN PKCS7-----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-----END PKCS7-----">
</form>

<!-- / / / -->
<br>

Includes code from micro_httpd/mini_httpd <br>
Copyright © 1999,2000 by Jef Poskanzer &lt;jef@acme.com&gt;.<br>
All rights reserved.<br>
<em>
  Redistribution and use in source and binary forms, with or without<br>
  modification, are permitted provided that the following conditions<br>
  are met:<br>
<ol>
  <li> Redistributions of source code must retain the above copyright
    notice, this list of conditions and the following disclaimer.</li>
  <li> Redistributions in binary form must reproduce the above copyright
  notice, this list of conditions and the following disclaimer in the
    documentation and/or other materials provided with the distribution.</li>
</ol>
  THIS SOFTWARE IS PROVIDED BY THE AUTHOR AND CONTRIBUTORS ``AS IS'' AND   <br>
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE      <br>
  IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE <br>
ARE DISCLAIMED.  IN NO EVENT SHALL THE AUTHOR OR CONTRIBUTORS BE LIABLE    <br>
  FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL <br>
  DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS  <br>
  OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)    <br>
  HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT <br>
  LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY  <br>
  OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF   <br>
  SUCH DAMAGE.  <br>
</em>
<br>
<br>

Portions of the code are licensed under the GNU General Public License version 2. <br>
A copy of this license and the source code it covers is <a href="http://blog.sabaitechnology.com/source/">available on our website</a>.

</div>
<!-- / / / -->

</td></tr>
	<tr><td id='footer' colspan=2>&nbsp;</td></tr>
</table>
</body>
</html>
