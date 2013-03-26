<ul id='topMenu' class='menu'>

<a href='#'><li class='menuSup' onclick="peeky('network'); return false;">Network</li></a>
<ul id='network' class='menu menuSub hidey'>
	<a href='sabai-act.asp' id='actLink'><li>Activate</li></a>
	<a href='network-basic.asp'><li>Basic</li></a>
	<a href='sabai-pptp.asp'><li>PPTP</li></a>
	<a href='sabai-ovpn.asp'><li>OpenVPN</li></a>
	<a href='sabai-gw.asp'><li>Gateways</li></a>
	<a href='firewall-forward.asp'><li>Port Forwarding</li></a>
	<a href='advanced-static.asp'><li>Static IP</li></a>
</ul>
<a href='#'><li class='menuSup' onclick="peeky('status'); return false;">Status</li></a>
<ul id='status' class='menu menuSub hidey'>
	<a href='status-overview.asp'><li>Overview</li></a>
	<a href='status-devices.asp'><li>Device List</li></a>
	<a href='status-time.asp'><li>Time</li></a>
	<a href='status-ident.asp'><li>Identification</li></a>
	<a href='status-webmon.asp'><li>Web Usage</li></a>
	<a href='status-log.asp'><li>Logs</li></a>
	<a href='status-about.asp'><li>About</li></a>
</ul>

<a href='#'><li class='menuSup' onclick="peeky('tools'); return false;">Diagnostics</li></a>
<ul id='tools' class='menu menuSub hidey'>
	<a href='tools-ping.asp'><li>Ping</li></a>
	<a href='tools-trace.asp'><li>Trace</li></a>
	<a href='tools-route.asp'><li>Route</li></a>
	<a href='tools-shell.asp'><li>System</li></a>
	<a href='tools-survey.asp'><li>Wireless Survey</li></a>
	<a href='tools-wol.asp'><li>WOL</li></a>
</ul>

<a href='#'><li class='menuSup' onclick="toggleAdv();" id='advancedLink'>Advanced</li></a>
<div class='hidey' id='advanced'>
<a href='#'><li class='menuSup' onclick="peeky('settings'); return false;">Settings</li></a>
<ul id='settings' class='menu menuSub hidey'>
	<a href='advanced-static.asp?advanced'><li>Static IP</li></a>
	<a href='advanced-mac.asp'><li>MAC Address</li></a>
	<a href='advanced-ipv6.asp'><li>IPv6</li></a>
	<a href='advanced-dhcpdns.asp'><li>DHCP &amp; DNS</li></a>
	<a href='advanced-ddns.asp'><li>DDNS</li></a>
	<a href='advanced-routing.asp'><li>Routing</li></a>
	<a href='advanced-wireless.asp'><li>Wireless</li></a>
</ul>

<a href='#'><li class='menuSup' onclick="peeky('firewall'); return false;">Firewall</li></a>
<ul id='firewall' class='menu menuSub hidey'>
	<a href='firewall-basic.asp'><li>Basic</li></a>
	<a href='firewall-forward.asp?firewall'><li>Port Forwarding</li></a>
	<a href='firewall-forwardipv6.asp'><li>IPv6 Port Forwarding</li></a>
	<a href='firewall-dmz.asp'><li>DMZ</li></a>
	<a href='firewall-triggered.asp'><li>Triggered</li></a>
	<a href='firewall-upnp.asp'><li>UPnP & NAT-PMP</li></a>
	<a href='firewall-ctnf.asp'><li>Conntrack Netfilter</li></a>
	<a href='firewall-wfilter.asp'><li>Wireless Filter</li></a>
</ul>

<a href='#'><li class='menuSup' onclick="peeky('file'); return false;">Network Storage</li></a>
<ul id='file' class='menu menuSub hidey'>
	<a href='file-samba.asp'><li>Sharing</li></a>
	<a href='file-usb.asp'><li>USB Support</li></a>
	<a href='file-ftp.asp'><li>FTP Server</li></a>
	<a href='file-cifs.asp'><li>CIFS Client</li></a>
	<a href='file-jffs2.asp'><li>JFFS</li></a>
</ul>

<a href='#'><li class='menuSup' onclick="peeky('admin'); return false;">Administration</li></a>
<ul id='admin' class='menu menuSub hidey'>
	<a href='admin-access.asp'><li>Admin Access</li></a>
	<a href='admin-buttons.asp'><li>Buttons &amp; LEDs</li></a>
	<a href='admin-debug.asp'><li>Debugging</li></a>
	<a href='admin-log.asp'><li>Logging</li></a>
	<a href='admin-sched.asp'><li>Scheduler</li></a>
	<a href='admin-scripts.asp'><li>Scripts</li></a>
	<a href='admin-misc.asp'><li>Miscellaneous</li></a>
	<a href='admin-restrict.asp'><li>Access Restrictions</li></a>

</ul>

<a href='#'><li class='menuSup' onclick="peeky('qos'); return false;">QoS</li></a>
<ul id='qos' class='menu menuSub hidey'>
	<a href='qos-settings.asp'><li>Basic Settings</li></a>
	<a href='qos-classify.asp'><li>Classification</li></a>
	<a href='qos-graphs.asp'><li>View Graphs</li></a>
	<a href='qos-detailed.asp'><li>View Details</li></a>
	<a href='qos-ctrate.asp'><li>Transfer Rates</li></a>
</ul>

<a href='#'><li class='menuSup' onclick="peeky('bwm'); return false;">Bandwidth</li></a>
<ul id='bwm' class='menu menuSub hidey'>
	<a href='bwm-monitoring.asp'><li>Monitoring</li></a>
	<a href='bwm-realtime.asp'><li>Realtime</li></a>
	<a href='bwm-24.asp'><li>Last 24 Hours</li></a>
	<a href='bwm-daily.asp'><li>Daily</li></a>
	<a href='bwm-weekly.asp'><li>Weekly</li></a>
	<a href='bwm-monthly.asp'><li>Monthly</li></a>
</ul>
</div>

<a href='admin-config.asp'><li class='menuSup'>Backup</li></a>
<a href='admin-upgrade.asp'><li class='menuSup'>Upgrade</li></a>
<a href='javascript:reboot()'><li class='menuSup'>Reboot...</li></a>

</ul>
<script type='text/javascript'>whereAmI();</script>
