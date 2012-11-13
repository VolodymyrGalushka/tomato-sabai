#ifndef SABAIVPN_VYPR_H
#define SABAIVPN_VYPR_H

extern char uni_up[];
extern char uni_dn[];

char vypr_si[]="#!/bin/sh\nnvram get ovpn_si>/tmp/vypr.sh\nchmod +x /tmp/vypr.sh\nsh /tmp/vypr.sh start\n";

char vypr_script[] = "#!/bin/sh\n\
user=$(nvram get vpn_user);\n\
pass=$(nvram get vpn_pass);\n\
serv=$(nvram get vpn_server);\n\
$sec=$(nvram get vpn_type);\n\
O='/tmp/ovpn'; T='/tmp/etc/config';\n\
ca='http://www.goldenfrog.com/downloads/ca.vyprvpn.com.crt';\n\
so=\"1194\n\";\n\
act=\"$1\";\n\
nvram set vpn_mesg='Received $act command.';\n\
\n\
_bad(){ nvram set vpn_mesg='$1'; rm -rf $O $T; exit 1; }\n\
_config(){\n\
	nvram set vpn_mesg='Configuring.';\n\
	rm -rf $O; mkdir -p $O;\n\
	vca=\"$(nvram get vpn_vyprca)\";\n\
	[ -z \"$vca\" ] && vca=\"$(wget $ca -qO-)\" && nvram set vpn_vyprca=\"$vca\" || _bad 'Failed to retrieve VYPR ca.';\n\
	echo -e \"client\ndev tun\nresolv-retry infinite\nnobind\npersist-key\npersist-tun\npersist-remote-ip\ncomp-lzo\nverb 4\nauth-user-pass $O/auth\ndaemon\nlog $O/log\nscript-security 2 system\nroute-up $O/up\ndown $O/dn\n<ca>\n$vca\n</ca>\n\" > $O/ovpn\n\
	nvram set ovpn_cf=\"$(cat $O/ovpn)\";\n\
}\n\
_start(){\n\
	nvram set vpn_mesg='Starting VyprVPN...';\n\
	killall openvpn >/dev/null 2>&1\n\
	insmod tun >/dev/null 2>&1\n\
	rm -rf $O\n\
	mkdir -p $O\n\
	mkdir -p $T && echo -e \"#!/bin/sh\nkillall openvpn\nping -c4 localhost\nopenvpn $O/ovpn\" > $T/ovpn.wanup\n\
	[ -z \"$(nvram get ovpn_cf)\" ] && _config || nvram get ovpn_cf > $O/ovpn\n\
	nvram get ovpn_up > $O/up\n\
	nvram get ovpn_dn > $O/dn\n\
	chmod +x $O/up $O/dn $T/ovpn.wanup\n\
	echo -e \"$(nvram get vpn_user)\n$(nvram get vpn_pass)\" > $O/auth\n\
	[ \"$sec\" == \"s\" ] && so=\"443\nauth SHA256\ncipher AES-256-CBC\nkeysize 256\ntls-cipher DHE-RSA-AES256-SHA:DHE-DSS-AES256-SHA:AES256-SHA\";\n\
	echo -e \"tls-remote $serv\nproto udp\nremote $serv $so\" >> $O/ovpn\n\
	openvpn $O/ovpn\n\
	nvram set vpn_mesg='Initializing OpenVPN daemon...';\n\
	while [ -z \"$(tail $O/log | grep -o 'Initialization Sequence Completed')\" ]; do sleep 2; [ -z \"$(ps | grep -v grep | grep -o openvpn)\" ] && _bad 'OpenVPN error'; done;\n\
	nvram set vpn_mesg='Connection complete.';\n\
}\n\
\n\
_stop(){ killall openvpn && nvram set vpn_mesg='Disconnection complete.'; }\n\
\n\
case \"$act\" in\n\
	start)	_start	;;\n\
	stop)	_stop	;;\n\
esac\n";

#endif
