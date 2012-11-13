#ifndef SABAIVPN_PPTP_H
#define SABAIVPN_PPTP_H

/* Can do without the %s bits at the moment.
# PPTP Server Info\n\
PPTP_DOMAIN=%s\n\
PPTP_SERVER=\"$(nvram get pptp_server)\"\n\
PPPD_OPTIONS=\"%s\"\n\
DEF_GATEWAY=%s\n\
\n\
ADD_SUBNETS=\"%s\"\n%s"\n\
*/

char pptp_script[]="#!/bin/sh\n\
\n\
# Login Info\n\
PPTP_USER=\"$(nvram get vpn_user)\"\n\
PPTP_PASSWORD=\"$(nvram get vpn_pass)\"\n\
\n\
# PPTP Server Info\n\
PPTP_DOMAIN=''\n\
PPTP_SERVER=\"$(nvram get vpn_server)\"\n\
PPPD_OPTIONS=''\n\
DEF_GATEWAY='Yes'\n\
\n\
ADD_SUBNETS=''\n\
# for example, \"192.168.100.0 192.168.101.0\"; this is needed if you're not using default gateway from VPN network, and your VPN network has multiple subnets.\n\
# Do not change anything below unless you know what you're doing...\n\
\n\
UNIT=5 # anything but 0\n\
SCRIPTS_PATH=/tmp/ppp/ppp$UNIT\n\
FIRE_PATH=/tmp/config\n\
DNSMASQ_CUSTOM=/etc/dnsmasq.custom\n\
TMPF=/tmp/$(date '+%%y%%d%%m%%H%%M%%S')\n\
\n\
_up()\n\
{\n\
\tif [ x$IFNAME == x ]; then\n\
\t\treturn 0\n\
\tfi\n\
\n\
\tnvram set pptp_on=1\n\
\tlogger -p 6 -t 'pptp-vpn['$$']' 'PPP link '$IFNAME' is up: server IP '$IPREMOTE', local IP '$IPLOCAL\n\
\n\
\techo \"IP-UP: \" $IFNAME $IPREMOTE $IPLOCAL\n\
\n\
\techo $IFNAME > $SCRIPTS_PATH/link\n\
\n\
\tifconfig $IFNAME arp multicast up\n\
\n\
\tnvram set ppp${UNIT}_get_ip=$IPLOCAL\n\
\tnvram set ppp${UNIT}_gateway=$IPREMOTE\n\
\n\
\tif [ x$PPTP_DOMAIN != x ]; then\n\
\t\techo \"rebind-domain-ok=$PPTP_DOMAIN\" > $TMPF\n\
\t\t[ -n $DNS1 ] && echo \"server=/$PPTP_DOMAIN/$DNS1\" >> $TMPF\n\
\telse\n\
\t\techo \"rebind-domain-ok=$PPTP_SERVER\" > $TMPF\n\
\tfi\n\
\techo \"server=/$PPTP_SERVER/#\" >> $TMPF\n\
\n\
\t# configure routes via remote gateway\n\
\tif [ x$IPREMOTE != x ]; then\n\
\n\
\t\t#find old gateway\n\
\t\twangw=`ip route ls to 0/0|cut -d ' ' -f3`\n\
\t\techo $wangw > $SCRIPTS_PATH/wangw\n\
\n\
\t\t# find old wan interface\n\
\t\twanif=`ip route ls to 0/0|cut -d ' ' -f5`\n\
\t\techo $wanif > $SCRIPTS_PATH/wanif\n\
\n\
\t\t# reset IP address of the interface for MASQ to flush the conntrack entries\n\
\t\tifconfig $IFNAME add 0.0.0.0\n\
\t\tifconfig $IFNAME add $IPLOCAL dstaddr $IPREMOTE netmask 255.255.255.255\n\
\n\
\t\t# delete existing routes\n\
\t\troute del default   dev $IFNAME\n\
\t\troute del $IPREMOTE dev $IFNAME\n\
\n\
\t\t# add routes to the gateway and to itself\n\
\t\troute add $IPREMOTE metric 0 dev $IFNAME\n\
\t\troute add $IPLOCAL  metric 0 dev $IFNAME\n\
\n\
\t\t# setup route to the pptp server via the old wan gateway\n\
\t\troute add -host $PPTP_SERVER gw $wangw\n\
\n\
\t\t# add routes to DNS servers\n\
\t\t[ -n $DNS1 ] && route add $DNS1 gw $IPREMOTE metric 0 dev $IFNAME\n\
\t\t[ -n $DNS2 ] && route add $DNS2 gw $IPREMOTE metric 0 dev $IFNAME\n\
\n\
\t\t# add route to the gateway subnet\n\
\t\troute add -net ${IPREMOTE%%'.'*}.0 gw $IPREMOTE netmask 255.255.255.0 metric 0 dev $IFNAME\n\
\n\
\t\t# setup default gateway\n\
\t\tmetric_ppp=1\n\
\t\tmetric_wan=0\n\
\t\tif [ \"$DEF_GATEWAY\" == \"Yes\" ]; then\n\
\t\t\tmetric_ppp=0\n\
\t\t\tmetric_wan=1\n\
\t\tfi\n\
\t\t# reset the default gateway route via physical interface\n\
\t\troute del default gw $wangw dev $wanif\n\
\t\troute del $wangw dev $wanif\n\
\t\troute add $wangw metric 0 dev $wanif\n\
\t\troute add default gw $wangw metric $metric_wan dev $wanif\n\
\t\t# add PPTP default gateway\n\
\t\troute add default gw $IPREMOTE metric $metric_ppp dev $IFNAME\n\
\n\
\t\t# add routes to additional subnets if any\n\
\t\tfor subnet in $ADD_SUBNETS\n\
\t\tdo\n\
\t\t\troute add -net $subnet gw $IPREMOTE netmask 255.255.255.0 metric 0 dev $IFNAME\n\
\t\tdone\n\
\n\
\t\t# remove route to the gateway - no longer needed\n\
\t\troute del $IPREMOTE dev $IFNAME\n\
\tfi\n\
\n\
\t# firewall script\n\
\tmkdir -p $FIRE_PATH\n\
\techo '#!/bin/sh\n\
\tif [ -f /var/run/ppp'$UNIT'.pid ] && [ -n $(cat /var/run/ppp'$UNIT'.pid) ]; then\n\
\tiptables -t nat -A PREROUTING -d '$IPLOCAL' -j WANPREROUTING\n\
\tiptables -t nat -A PREROUTING -i '$IFNAME' -d '$(nvram get lan_ipaddr)'/'$(nvram get lan_netmask)' -j DROP\n\
\tiptables -t nat -A POSTROUTING -o '$IFNAME' -j MASQUERADE\n\
\tiptables -I INPUT -i br0 -d '$IPLOCAL' -j DROP\n\
\tiptables -A FORWARD -i '$IFNAME' -j wanin\n\
\tiptables -A FORWARD -o '$IFNAME' -j wanout\n\
\tiptables -A FORWARD -i '$IFNAME' -j upnp\n\
\n\
\t# QoS rules (not needed)\n\
\t# iptables -t mangle -A FORWARD -o '$IFNAME' -j QOSO\n\
\t# iptables -t mangle -A OUTPUT -o '$IFNAME' -j QOSO\n\
\t# iptables -t mangle -A PREROUTING -i '$IFNAME' -j CONNMARK --restore-mark --mask 0xff\n\
\tfi\n\
\t' > \"$FIRE_PATH/ppp$UNIT.fire\"\n\
\tchmod +x \"$FIRE_PATH/ppp$UNIT.fire\"\n\
\n\
\tmv -f $TMPF $DNSMASQ_CUSTOM\n\
\tnvram set vpn_ipaddr=$IPLOCAL\n\
\tnvram set vpn_gateway=$IPREMOTE\n\
\tnvram set vpn_device=$IFNAME\n\
\tservice routing restart\n\
\tservice dnsmasq restart\n\
\tservice firewall restart\n\
#SABAI DUAL GATEWAY CODE BEGIN\n\
\tsh /www/gw.sh vpn\n\
#SABAI DUAL GATEWAY CODE BEGIN\n\
}\n\
\n\
_down()\n\
{\n\
\techo \"IP-DOWN\"\n\
\n\
\tlogger -p 6 -t 'pptp-vpn['$$']' 'PPP link is down, restoring default settings...'\n\
\n\
\tnvram unset ppp${UNIT}_get_ip\n\
\tnvram unset ppp${UNIT}_gateway\n\
\n\
\trm -f $FIRE_PATH/ppp$UNIT.fire\n\
\trm -f $SCRIPTS_PATH/link\n\
\techo \"\" > $DNSMASQ_CUSTOM\n\
\n\
\t#delete route the pptp server\n\
\troute del -host $PPTP_SERVER\n\
\n\
\t# restore default WAN gateway with metric 0\n\
\troute del default gw $(cat $SCRIPTS_PATH/wangw) dev $(cat $SCRIPTS_PATH/wanif)\n\
\troute del $(nvram get wan_gateway) dev $(nvram get wan_ifname)\n\
\troute add $(cat $SCRIPTS_PATH/wangw) metric 0 dev $(cat $SCRIPTS_PATH/wanif)\n\
\troute add default gw $(cat $SCRIPTS_PATH/wangw) metric 0 dev $(cat $SCRIPTS_PATH/wanif)\n\
\n\
\tservice routing restart\n\
\tservice dnsmasq restart\n\
\tservice firewall restart\n\
\tsh /www/gw.sh vpn\n\
\tnvram set pptp_on=0\n\
\tnvram unset vpn_device\n\
}\n\
\n\
_stop()\n\
{\n\
\tnvram set vpn_mesg='PPTP stopping...'\n\
\n\
\tkillall ppp$UNIT-up\n\
\tkillall ppp$UNIT-down\n\
\tfor i in `ps  w  | grep ppp$UNIT| sed -e 's/^[ \\t]*//' | cut -d' ' -f1`\n\
\tdo\n\
\tkill $i\n\
\tdone\n\
\twhile ps w | grep ppp$UNIT | grep file 2>&1 > /dev/null\n\
\tdo\n\
\tsleep 1\n\
\tdone\n\
\tnvram set vpn_mesg='PPTP stopped.'\n\
}\n\
\n\
_write_config()\n\
{\n\
\tmkdir -p $SCRIPTS_PATH\n\
\n\
\t[ -x \"$SCRIPTS_PATH/ppp$UNIT-up\" ] || echo '#!/bin/sh\n\
'$0' up' > \"$SCRIPTS_PATH/ppp$UNIT-up\"\n\
\tchmod +x \"$SCRIPTS_PATH/ppp$UNIT-up\"\n\
\n\
\t[ -x \"$SCRIPTS_PATH/ppp$UNIT-down\" ] || echo '#!/bin/sh\n\
'$0' down' > \"$SCRIPTS_PATH/ppp$UNIT-down\"\n\
\tchmod +x \"$SCRIPTS_PATH/ppp$UNIT-down\"\n\
\n\
\techo \"\tunit $UNIT\n\
\tusepeerdns\n\
\tplugin pptp.so\n\
\tpptp_server $PPTP_SERVER\n\
\tuser '$PPTP_USER'\n\
\tpassword '$PPTP_PASSWORD'\n\
\tdefault-asyncmap\n\
\tnopcomp\n\
\tnoaccomp\n\
\tnovj\n\
\tnobsdcomp\n\
\tnodeflate\n\
\tnoauth\n\
\trefuse-eap\n\
\trefuse-pap\n\
\trefuse-chap\n\
\trefuse-mschap\n\
\tmaxfail 0\n\
\tip-up-script '$SCRIPTS_PATH/ppp$UNIT-up'\n\
\tip-down-script '$SCRIPTS_PATH/ppp$UNIT-down'\n\
\tlcp-echo-interval 15\n\
\tlcp-echo-failure 6\n\
\tlcp-echo-adaptive\n\
\tpersist\n\
\tholdoff 20\n\
\tmtu 1400\n\" > \"$SCRIPTS_PATH/options\"\n\
# BEGIN TEST CODE\n\
\tif [ \"$(nvram get pptp_stateful)\" -eq \"1\" ]; then\n\
\t\techo \"\tmppe-stateful\" >> \"$SCRIPTS_PATH/options\"\n\
\telse\n\
\t\techo \"\tnomppe-stateful\n\" >> \"$SCRIPTS_PATH/options\"\n\
\tfi\n\
\tif [ \"$(nvram get pptp_mppe)\" -eq \"1\" ]; then\n\
\t\techo \"\trequire-mppe-128\n\" >> \"$SCRIPTS_PATH/options\"\n\
\telse\n\
\t\techo \"\tnomppe\n\" >> \"$SCRIPTS_PATH/options\"\n\
\tfi\n\
# END TEST CODE\n\
\techo $PPPD_OPTIONS | sed s/,/\\\\n/g >> \"$SCRIPTS_PATH/options\"\n\
}\n\
\n\
_start()\n\
{\n\
\techo \"Starting pppd$UNIT...\"\n\
\n\
\tpppd file \"$SCRIPTS_PATH/options\" &\n\
\tnvram set vpn_mesg='PPTP initialized.'\n\
}\n\
\n\
_restart()\n\
{\n\
\t_stop\n\
\t_write_config\n\
\t_start\n\
}\n\
\n\
_check_run()\n\
{\n\
\tif [ ! -f /proc/$(cat /var/run/ppp$UNIT.pid)/exe ]; then\n\
\t\techo \"pppd not running, restarting...\"\n\
\t\t_restart\n\
\telse\n\
\t\tifconfig ppp${UNIT} 2>&1 > /dev/null\n\
\t\tif [ $? -eq 1 ]; then\n\
\t\t\techo \"pppd$UNIT down, restarting...\"\n\
\t\t\t_restart\n\
\t\tfi\n\
\tfi\n\
}\n\
\n\
case $1 in\n\
\tstart)\n\
\t\t_restart\n\
\t\t;;\n\
\tstop)\n\
\t\t_stop\n\
\t\t;;\n\
\tup)\n\
\t\t_up\n\
\t\t;;\n\
\tdown)\n\
\t\t_down\n\
\t\t;;\n\
\tconfig)\n\
\t\t_write_config\n\
\t\t;;\n\
\tcheck)\n\
\t\t_check_run\n\
\t\t;;\n\
\t*)\n\
\t\t_restart\n\
\t\t;;\n\
esac\n\
\n\
exit $?\n";

#endif
