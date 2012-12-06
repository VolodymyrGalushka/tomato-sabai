#!/bin/sh
rm /var/log/sabaigw.*
exec 2>/var/log/sabaigw.err
exec 1>/var/log/sabaigw.log

lan_prefix="$(nvram get lan_ipaddr | cut -d '.' -f1,2,3)";
#default="$(nvram get gw_def)";

_fin(){ ip route flush cache; }

_stop(){
 for i in 1 2 3; do ip route flush table $i; done
 ip rule | grep "$lan_prefix" | cut -d':' -f2 | while read old_rule; do ip rule del $old_rule; done
 _fin
}

_start(){
 _stop
 ip route | grep $lan_prefix | while read rt; do ip route add $rt table 1; done
 wan_gateway="$(nvram get wan_gateway_get)"; wan_iface="$(nvram get wan_iface)";
 ([ -n "$wan_gateway" ] && [ "$wan_gateway" == "0.0.0.0" ]) && [ -n "$wan_iface" ] && ip route add default via $wan_gateway dev $wan_iface table 1 || ip route add default dev $wan_iface table 1
 ip route add default via "$lan_prefix.$(nvram get ac_ip)" dev br0 table 3

 if([ $(nvram get pptp_on) -eq 1 ] || [ $(nvram get ovpn_on) -eq 1 ]); then
  vpn_device="$(nvram get vpn_device)";
  vpn_gateway="$(nvram get vpn_gateway)";
  ip route add $vpn_gateway dev $vpn_device table 2
  ip route | grep $vpn_device | while read vpn_rt; do
   ip route add $vpn_rt table 2;
  done
  ip route del $vpn_gateway dev $vpn_device table 2
  route add $(nvram get srcnvrp) dev $vpn_device
 fi

 ip rule | grep "$lan_prefix" | cut -d':' -f2 | while read old_rule; do ip rule del $old_rule; done
# [ ! $default -eq 0 ] && ip rule add from "$lan_prefix.1/24" table $default
 for i in 1 2 3; do
  for j in $(nvram get gw_$i); do
   ip rule add from "$lan_prefix.$j" table $i
  done
 done
 _fin
}

case $1 in
	stop)	_stop	;;
	start)	_start	;;
esac
