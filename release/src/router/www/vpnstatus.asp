var vpnstats = {
	ovpn_status: '<% nv('ovpn_on'); %>',
	pptp_status: '<% nv('pptp_on'); %>',
	vpn_mesg: '<% nv('vpn_mesg'); %>',
	vpnstatus: '<% vpnstatus(); %>',
	gw_run: '<% nv('gw_run') %>',
	gw_on: '<% nv('gw_on') %>',
	vpnconnectiontype: '<% vpnconnectiontype(); %>',
	vpnipaddress: '<% vpnipaddress(); %>',
	vpnnetmask: '<% vpnnetmask(); %>',
	vpngateway: '<% vpngateway(); %>'
}
