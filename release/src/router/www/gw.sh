#!/bin/sh
exec 3>&1
exec 2>>/tmp/gw.log
exec 1>>/tmp/gw.log

_commit(){ nvram commit; echo 'Committed.' >&3; }

_static(){
	nvram set dhcpd_static="$(echo $args | cut -d ',' -f2)";
	_commit
	echo $args | cut -d ',' -f1 > /var/tmp/dhcp/delete
	chmod 0666 /var/tmp/dhcp/delete
	killall -SIGUSR2 dnsmasq
	while [ -e /var/tmp/dhcp/delete ]; do sleep 1; done
	service dhcpd restart && service firewall restart
	echo 'IP reassigned.' >&3;
}

_add(){
	ip="$(echo $args | cut -d ',' -f1)";
	t="$(echo $args | cut -d ',' -f2)";

	nvram set gw_local="$(echo $args | cut -d ',' -f3)";
	nvram set gw_vpn="$(echo $args | cut -d ',' -f4)";
	nvram set gw_accel="$(echo $args | cut -d ',' -f5)";

	if [ $(nvram get gw_on) -eq 1 ]; then
		ip rule | grep $ip | cut -d ':' -f2 | while read rl; do
			ip rule del $rl;
		done
		case $t in
			1)	[ $(nvram get gw_def) -eq 1 ] && ip rule add from $ip table 1;	;;
			2)	[ $(nvram get gw_def) -eq 0 ] && ip rule add from $ip table 1;	;;
			3)	ip rule add from $ip table 2;	;;
		esac
	fi
}

_init(){
	[ $(nvram get gw_run) -eq 0 ] && exit 0;
	nvram set gw_on="1";
	nvram set gw_oldrt="$(ip route show)";
	vd="$(nvram get vpn_device)";
	vgw="$(nvram get vpn_gateway)";
	lp="$(nvram get lan_ipaddr | cut -d '.' -f1,2,3)"'.';

	ip route ls to 0.0.0.0/1 > /tmp/oldrt
	ip route ls to 128.0.0.0/1 >> /tmp/oldrt
	ip route|grep ^default >> /tmp/oldrt

	if [ $(nvram get gw_def) -eq 0 ]; then
		if [ $(nvram get pptp_on) -eq 1 ]; then
			route add $vgw dev $vd
			ip route del default via $vgw dev $vd
			ip route add default via $vgw dev $vd table 1
			route del $vgw dev $vd
		elif [ $(nvram get ovpn_on) -eq 1 ]; then
			ip route del 0.0.0.0/1 via $vgw dev $vd
			ip route del 128.0.0.0/1 via $vgw dev $vd
			ip route add 0.0.0.0/1 via $vgw dev $vd table 1
			ip route add 128.0.0.0/1 via $vgw dev $vd table 1
		fi
		alt="$(nvram get gw_vpn)"
	else
		wd="$(nvram get wan_iface)";
		wg="$(nvram get wan_gateway_get)";
		route del default gw $wg dev $wd
		ip route add default via $wg dev $wd table 1
		ip rule add from $lp"$(nvram get ac_ip)" table 1
		alt="$(nvram get gw_local)"
	fi

	ip route add default via $lp"$(nvram get ac_ip)" dev br0 table 2
	route add "$(nvram get srcipt)" dev $vd

	for i in $alt; do
		ip rule add from $lp$i table 1
	done
	for i in $(nvram get gw_accel); do
		ip rule add from $lp$i table 2
	done
}

_fold(){
	[ $(nvram get gw_on) -eq 0 ] && exit 0;
	nvram set gw_on="0";
	lp="$(nvram get lan_ipaddr | cut -d '.' -f1,2,3)"'.';
	irs=$(ip rule|grep -v 'from all lookup');
	wg="$(nvram get wan_gateway_get)";
	vd="$(nvram get vpn_device)";
	vgw="$(nvram get vpn_gateway)";

	for i in $(nvram get gw_local) $(nvram get gw_vpn) $(nvram get gw_accel); do
		echo "$irs" | grep $lp$i | cut -d ':' -f2 | while read rl; do
			ip rule del $rl;
		done
	done

	ip route flush table 1
	ip route flush table 2

	ip route del $(ip route ls to 0.0.0.0/1)
	ip route del $(ip route ls to 128.0.0.0/1)
	ip route | grep ^default | while read rt; do
		ip route del $rt
	done
	[ $(nvram get pptp_on) -eq 1 ] && route add $vgw dev $vd
	nvram get gw_oldrt | while read rt; do
		[ -z "$(ip route show $rt)" ] && ip route add $rt
	done
	[ $(nvram get pptp_on) -eq 1 ] && route del $vgw dev $vd
	[ -e /tmp/gw.log ] && mv /tmp/gw.log /tmp/gw.old

	[ -n "$wg" ] && [ -z "ip route show | grep ^default | grep $wg" ] && ip route add default via $wg dev $(nvram get wan_iface);
}

_open(){
	nvram set gw_run=1;
	nvram set gw_def="$args";
	_init
	_commit
	echo 'Dual Gateway activated.' >&3;
}

_close(){
	nvram set gw_run=0;
	_fold
	_commit
	echo 'Dual Gateway deactivated.' >&3;
}

if [ -z "$1" ]; then
	read act args;
else
	act="$1";
fi

case "$act" in
	init)	_init	;;
	fold)	_fold	;;
	add)	_add	;;
	commit)	_commit	;;
	static)	_static	;;
	open)	_open	;;
	close)	_close	;;
esac
