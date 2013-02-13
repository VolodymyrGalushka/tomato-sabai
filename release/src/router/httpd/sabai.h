#ifndef SABAI_H
#define SABAI_H

#define T_ISITAMAC(T_START,T_MAC) ( (T_MAC[T_START+2]==':')&&(T_MAC[T_START+5]==':')&&(T_MAC[T_START+8]==':')&&(T_MAC[T_START+11]==':')&&(T_MAC[T_START+14]==':') )

#define _SABAI_FILE_BUFFER 12288
#define _SABAI_FILE_RANGE_ERROR "File size was smaller than 16 or larger than 12288 characters (~12KiB).";
#define SABAIWANUP "/tmp/script_wanup.sh"
#define SABAIGW "/www/gw.sh"
#define SABAIMENU "/www/menu.asp"
#define SABAIPARTS "/tmp/parts.sh"

int nvram_update(const char *variable, const char *value);

char parts_script[]="\
#!/bin/sh\n\
src=/tmp/parts.src; res=/tmp/parts.res; tmp=/tmp/parts.tmp; err=/tmp/sabaierr;\n\
exec 2>$err\n\
[ ! -e $src ] && echo 'Source missing.'>>$err && exit 0\n\
b=\"$(head -n1 $src | tr -d '\\r-' )\"\n\
cat $src | tr -d '\\r' | sed \"{\n\
	1d\n\
	/^$/d\n\
	/^Content-Type:/d\n\
	/_http_id/,/^-*$b/d\n\
	/^-*$b/d\n\
	/^Content-/,/^-----BEGIN/ { /^Content-/! { /^-----BEGIN/!d } }\n\
	/^Content-/,/-----END/ {\n\
		/^Content-/h\n\
		s/^Content-.* name=\\\"\\([^\\\"]*\\)\\\";.*/<\\1>/\n\
		/-----END/ { G; s/Content-.* name=\\\"\\([^\\\"]*\\)\\\";.*/<\\/\\1>/; }\n\
	}\n\
}\" >$tmp\n\
[ -e $err ] && sed -i \"s/\\\"/'/g\" $err\n\
[ -s $err ] && exit 0;\n\
nvram get ovpn_cf | tr -d '\\r' >$res\n\
sed \"/<[^>]*>/,/<\\/[^>]*>/!d\" $tmp >>$res\n\
sed -i -e \"/^$/d\" -e \"/^[;#]/d\" $res\n\
nvram set ovpn_cf=\"$(cat $res)\"\n\
#rm -f $src $res $err\n";

char ovpn_script[]="\
#!/bin/sh\n\
exec 2>&1;\
 exec 1>/var/log/ovpn.log;\n\
me="SABAIWANUP"\n\
pr=/tmp/ovpn\n\
\
_services(){\
 "SABAIGW" ds;\
 service firewall restart;\
 }\n\
\
_setParameters(){\n\
 [ -n \"$dev\" ] && nvram set vpn_device=$dev\
 || (ifconfig tun0 >/dev/null 2>&1 && nvram set vpn_device=\"tun0\")\
 || (ifconfig tap0 >/dev/null 2>&1 && nvram set vpn_device=\"tap0\")\
 ||  logger -p 6 -t 'ovpn['$$']' 'DEV WAS EMPTY.';\n\
 ([ -n \"$route_vpn_gateway\" ] && nvram set vpn_gateway=$route_vpn_gateway)\
 || ([ -n \"$route_gateway_1\" ] && nvram set vpn_gateway=$route_gateway_1)\
 || ([ -n \"$ifconfig_remote\" ] && nvram set vpn_gateway=$ifconfig_remote)\
 ||  logger -p 6 -t 'ovpn['$$']' 'VPN_GATEWAY WAS EMPTY.';\n\
 [ -n \"$ifconfig_local\" ] && nvram set vpn_ipaddr=$ifconfig_local\
 ||  logger -p 6 -t 'ovpn['$$']' 'IFCONFIG_LOCAL WAS EMPTY.';\n\
}\n\
\
_up(){\n\
 _setParameters;\
 nvram set vpn_up=1;\
 _services;\
 nvram set vpn_ready=1;\
 }\n\
\
_dn(){\
 nvram set vpn_ready=0;\
 nvram set vpn_up=0;\
 _services;\
 nvram unset vpn_device;\
 nvram unset vpn_ipaddr;\
 nvram unset vpn_gateway;\
 }\n\
\
_stop(){ killall openvpn; }\n\
\
_conf(){\
 insmod tun;\
 mkdir -p $pr;\
 [ ! -h /tmp/var/wwwext/ovpn.txt ] && ln -s $pr/ovpn.log /tmp/var/wwwext/ovpn.txt;\
 nvram get ovpn_cf >$pr/ovpn;\
 echo -e \"\\n\
daemon\\n\
script-security 2 system\\n\
log $pr/ovpn.log\\n\
route-up \\\"$me up\\\"\\n\
down \\\"$me dn\\\"\\n\
auth-iuser \\\"\"$(nvram get ovpn_user)\"\\\"\\n\
auth-ipass \\\"\"$(nvram get ovpn_pass)\"\\\"\\n\
\" >>$pr/ovpn;\
 }\n\
\
_start(){\
 [ -e /var/run/ppp5.pid ] && kill $(cat /var/run/ppp5.pid);\
 _stop;\
 _conf;\
 openvpn $pr/ovpn;\
 }\n\
\
_restart(){\
 killall -SIGHUP openvpn;\
 }\n\
\
case $1 in\n\
 up)	_up	;;\n\
 dn)	_dn	;;\n\
 stop)	_stop	;;\n\
 *)	_start	;;\n\
esac\n\
";

char pptp_script[]="\
#!/bin/sh\n\
exec 2>&1; exec 1>/var/log/ppp5.log;\n\
pptpServer=$(nvram get pptp_server);\n\
me="SABAIWANUP";\n\
pr=/tmp/ppp/ppp5\n\
dnsmasqCustom=/etc/dnsmasq.custom\n\
\
_services(){ service routing restart; "SABAIGW" ds; service firewall restart; }\n\
\
_up(){\n\
 [ -z $IFNAME ] && exit 0;\
 echo -e \"Server: $pptpServer; if: $IFNAME; ip: $IPLOCAL-->$IPREMOTE; dns: $DNS1,$DNS2\" >$SP/ppp5.info\n\
 nvram set vpn_up=1;\
 nvram set vpn_ipaddr=$IPLOCAL;\
 nvram set vpn_gateway=$IPREMOTE;\
 nvram set vpn_device=$IFNAME\n\
 if [ -n $IPREMOTE ]; then\n\
\
 wangw=$(ip route ls to 0/0 | egrep -o \"via [^ ]*\" | cut -d' ' -f2);\
 wanif=$(ip route ls to 0/0 | egrep -o \"dev [^ ]*\" | cut -d' ' -f2);\
 nvram set pptp_wangw=$wangw;\
 nvram set pptp_wanif=$wanif;\n\
 route add $IPLOCAL metric 0 dev $IFNAME;\
 route add -host $pptpServer gw $wangw\n\
 [ -n $DNS1 ] && route add $DNS1 gw $IPREMOTE metric 0 dev $IFNAME;\
 [ -n $DNS2 ] && route add $DNS2 gw $IPREMOTE metric 0 dev $IFNAME\n\
 route add -net ${IPREMOTE%'.'*}.0 gw $IPREMOTE netmask 255.255.255.0 metric 0 dev $IFNAME\n\
 route del default gw $wangw dev $wanif;\
 route add default gw $wangw metric 1 dev $wanif;\
 route add default gw $IPREMOTE metric 0 dev $IFNAME\n\
 route del $IPREMOTE dev $IFNAME;\
 route del $pptpServer gw $wangw metric 1 dev $wanif\n\
\
 else\n\
\
 logger -p 6 -t 'pptp['$$']' 'IPREMOTE WAS EMPTY.';\n\
\
 fi\n\
 echo -e \"rebind-domain-ok=$pptpServer\\nserver=/$pptpServer/#\" >>$dnsmasqCustom;\n\
 _services;\n\
 nvram set vpn_ready=1;\n\
 logger -p 6 -t 'pptp['$$']' \"PPTP on $IFNAME:$IPLOCAL->$IPREMOTE.\"\n\
}\n\
\
_dn(){\n\
 nvram set vpn_ready=0;\n\
 nvram set vpn_up=0;\
 nvram unset vpn_device;\
 nvram unset vpn_ipaddr;\
 nvram unset vpn_gateway;\n\
 wangw=$(nvram get pptp_wangw);\
 wanif=$(nvram get pptp_wanif);\n\
 route del -host $pptpServer;\
 route del $pptpServer gw $wangw dev $wanif\n\
 route del default gw $wangw dev $wanif;\
 route add default gw $wangw metric 0 dev $wanif\n\
 :>$dnsmasqCustom;\
 _services;\
 logger -p 6 -t 'pptp['$$']' 'PPTP off.'\n\
}\n\
\
_config(){\n\
 mkdir -p $pr\n\
 echo -e \"#!/bin/sh\\n$me up\" >$pr/ppp5up; echo -e \"#!/bin/sh\\n$me dn\" >$pr/ppp5dn; chmod +x $pr/ppp5up $pr/ppp5dn\n\
 echo -e \"\\n\
unit 5\\n\
usepeerdns\\n\
plugin pptp.so\\n\
pptp_server $pptpServer\\n\
user '$(nvram get pptp_user)'\\n\
password '$(nvram get pptp_pass)'\\n\
default-asyncmap\\n\
nopcomp\\n\
noaccomp\\n\
novj\\n\
nobsdcomp\\n\
nodeflate\\n\
noauth\\n\
refuse-eap\\n\
refuse-pap\\n\
refuse-chap\\n\
refuse-mschap\\n\
maxfail 0\\n\
ip-up-script $pr/ppp5up\\n\
ip-down-script $pr/ppp5dn\\n\
lcp-echo-interval 15\\n\
lcp-echo-failure 6\\n\
lcp-echo-adaptive\\n\
persist\\n\
holdoff 20\\n\
mtu 1400\\n\
\" >$pr/options\n\
 ([ $(nvram get pptp_stateful) -eq 1 ] && echo 'mppe-stateful' || echo 'nomppe-stateful'; [ $(nvram get pptp_mppe) -eq 1 ] && echo 'require-mppe-128' || echo 'nomppe') >>$pr/options\n\
}\n\
\
_stop(){ [ -e /var/run/ppp5.pid ] && kill $(cat /var/run/ppp5.pid); }\n\
_start(){ pppd file $pr/options & }\n\
_init(){ [ -n \"$(ps | grep openvpn)\" ] && killall openvpn; _stop; _config; _start; }\n\
\
case $1 in\n\
	stop)	_stop	;;\n\
	up)	_up	;;\n\
	dn)	_dn	;;\n\
	*)	_init	;;\n\
esac\n\
";

#endif
