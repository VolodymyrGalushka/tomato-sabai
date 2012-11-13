#!/bin/sh
exec 2>&1;

##exec 3>&1#exec 2>>/tmp/gw.log#exec 1>>/tmp/gw.log

_commit(){ nvram commit >/dev/null; }

_makeVPNTable(){
 ([ $(nvram get pptp_on) -eq 0 ] && [ $(nvram get ovpn_on) -eq 0 ]) && return;
 vpn_device="$(nvram get vpn_device)";
 vpn_gateway="$(nvram get vpn_gateway)";
 route add $vpn_gateway dev $vpn_device
 ip route | grep $vpn_device | while read vpn_rt; do
  ip route del $vpn_rt;
  ip route add $vpn_rt table 2;
 done
 route del $vpn_gateway dev $vpn_device
 route add wb2.sabaitechnology.com dev $vpn_device
}

_makeTables(){
 for i in 1 2 3; do ip route flush table $i; done
 ip route add default via $(nvram get wan_gateway_get) dev $(nvram get wan_iface) table 1
 _makeVPNTable;
 ip route add default via "$lan_prefix.$(nvram get ac_ip)" dev br0 table 3
}

_set(){
 [ "$statics" == "-" ] && statics=""; nvram set dhcpd_static="$static"; service dhcpd restart;
 [ -z "$gw" ] && return;
 g=0;
 for i in $(echo $gw | sed -e 's/;/ /g'); do
  i="$(echo $i | sed -e 's/,/ /g')";
  [ "$i" == "-" ] && i='';
  : $(( g++ ));
  nvram set "gw_$g=$i";
 done
}

_assign(){
 for i in 1 2 3; do
  for j in $(nvram get gw_$i); do
   ip rule add from "$lan_prefix.$j" table $i
  done
 done
 [ ! $default -eq 0 ] && ip rule add from "$lan_prefix.1/24" table $default
}

_setup(){
 lan_prefix="$(nvram get lan_ipaddr | cut -d '.' -f1,2,3)";
 _makeTables; _assign;
}

_save(){ _statics; _set; _setup; _commit; }

[ -z "$1" ] && read act default static gw || act=$1;

case "$act" in
	save)	_save;	;;
	vpn)	_vpn;	;;
	init)	_setup;	;;
esac
