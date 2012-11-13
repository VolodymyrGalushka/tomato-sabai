#ifndef SABAIVPN_VPNS_H
#define SABAIVPN_VPNS_H

extern char uni_up[];
extern char uni_dn[];

char vpns_si[]="#!/bin/sh\nnvram get ovpn_si>/tmp/vpns.sh\nchmod +x /tmp/vpns.sh\nsh /tmp/vpns.sh start\n";

char vpns_script[] = "#!/bin/sh\n\
user=\"$(nvram get vpn_user)\";\n\
pass=\"$(nvram get vpn_pass)\";\n\
serv=\"$(nvram get vpn_server)\";\n\
fix=\"$(nvram get vpn_fix)\";\n\
O='/tmp/ovpn'; T='/tmp/etc/config'; Z='/tmp/vpnskey.zip';\n\
vpns_w=\"$(nvram get srcvpns)\";\n\
[ -z \"$vpns_alt\" ] && vpns_w='www.vpnsecure.me/545s136s4dw8';\n\
sl='http://'$vpns_w'/serverListSabiEnc.php';\n\
kf='http://'$vpns_w'/keySabiEnc.php';\n\
k='sabaai'; m='6c537f417d42af419241ad49';\n\
act=\"$1\";\n\
nvram set vpn_mesg=\"Received $act command.\";\n\
\n\
_bad(){ nvram set vpn_mesg=\"$1\"; rm -rf $O $T $Z; exit 1; }\n\
_enc(){\n\
	[ -z \"$(ping -c1 www.vpnsecure.me | grep -o '1 packets received')\" ] && _bad 'No connection.';\n\
	rand=\"$(head -c32 /dev/urandom | md5sum | tr -d ' -')\";\n\
	salt=\"${rand:0:8}\";\n\
	K=\"$(echo -n $salt$k | md5sum | tr -d ' -')\";\n\
	I=\"$(echo -n $salt$m | md5sum | tr -d ' -')\";\n\
	salt64=\"$(echo -n $salt | openssl enc -e -a -A)\";\n\
	con=\"$(echo \"$user,$pass\" | openssl aes128 -e -a -A -K $K -iv $I | tr '+' '.')\";\n\
}\n\
_getkey(){ nvram set vpn_mesg='Retrieving key.'; _enc; ( ! wget $kf'?plz='$salt64$con -qO $Z || [ \"$(head -c12 $Z)\" == \"Unauthorized\" ]) && _bad 'Key retrieval failure. Please check your credentials.'; }\n\
_list(){ _enc; nvram set vpns_serverlist=\"$(wget $sl'?plz='$salt64$con -qO- | openssl aes128 -d -a -A -nosalt -K $K -iv $I | sed 's|<br/>|;|g')\"; }\n\
_config(){\n\
	nvram set vpn_mesg='Configuring.';\n\
	[ ! -e \"$Z\" ] && _getkey\n\
	rm -rf $O; mkdir -p $O;\n\
	! unzip -q $Z -d $O/ && _bad 'Configuration error.';\n\
	mv $O/*.key $O/key.enc\n\
	mv $O/*.ovpn $O/ovpn\n\
	mv $O/ca.crt $O/ca\n\
	mv $O/*.crt $O/crt\n\
	! openssl rsa -in $O/key.enc -out $O/key -passin pass:$fix >/dev/null 2>&1 && _bad 'RSA key decryption fail; please check your signup password.';\n\
	for i in ca cert key proto dh remote; do sed -i \"/^$i /d\" $O/ovpn; done\n\
	echo -e \"daemon\\nlog $O/log\\nscript-security 2 system\\nroute-up $O/up\\ndown $O/dn\\n<ca>\\n$(cat $O/ca)\\n</ca>\\n<cert>\\n$(cat $O/crt)\\n</cert>\\n<key>\\n$(cat $O/key)\\n</key>\" >> $O/ovpn\n\
	nvram set ovpn_cf=\"$(cat $O/ovpn)\";\n\
}\n\
_start(){\n\
	nvram set vpn_mesg='Starting VPNSecure...';\n\
	killall openvpn >/dev/null 2>&1\n\
	insmod tun >/dev/null 2>&1\n\
	rm -rf $O\n\
	mkdir -p $O\n\
	mkdir -p $T && echo -e \"#!/bin/sh\\nkillall openvpn\\nping -c4 localhost\\nopenvpn $O/ovpn\" > $T/ovpn.wanup\n\
	[ -z \"$(nvram get ovpn_cf)\" ] && _config || nvram get ovpn_cf > $O/ovpn\n\
	nvram get ovpn_up > $O/up\n\
	nvram get ovpn_dn > $O/dn\n\
	chmod +x $O/up $O/dn $T/ovpn.wanup\n\
	server=\"$(nvram get vpns_serverlist | cut -d ';' -f$((serv+1)))\"\n\
	ip=\"$(echo $server | cut -d '|' -f2)\"\n\
	port=\"$(echo $server | cut -d '|' -f3)\"\n\
	pro=\"$(echo $server | cut -d '|' -f4)\"\n\
	echo -e \"\\nproto $pro\\nremote $ip $port\" >> $O/ovpn\n\
	openvpn $O/ovpn\n\
	nvram set vpn_mesg='Initializing OpenVPN daemon...';\n\
	while [ -z \"$(tail $O/log | grep -o 'Initialization Sequence Completed')\" ]; do sleep 2; [ -z \"$(ps | grep -v grep | grep -o openvpn)\" ] && _bad 'OpenVPN error'; done;\n\
	nvram set vpn_mesg='Connection complete.';\n\
}\n\
\n\
_stop(){ killall openvpn && nvram set vpn_mesg='Disconnection complete.'; }\n\
\n\
case \"$act\" in\n\
	list)	_list	;;\n\
	start)	_start	;;\n\
	stop)	_stop	;;\n\
esac\n";

#endif
