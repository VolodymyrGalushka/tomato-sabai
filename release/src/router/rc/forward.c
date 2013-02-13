/* Tomato Firmware Copyright (C) 2006-2009 Jonathan Zarate */

#include "rc.h"
#include <arpa/inet.h>

extern char chain_wan_prerouting[];

static const char tcpudp[2][4] = {"tcp", "udp"};

void ipt_forward(ipt_table_t table){
 char *lanip = nvram_safe_get("lan_ipaddr"); char *wanip = nvram_safe_get("wan_ipaddr");
 char *vpnip = nvram_safe_get("vpn_ipaddr"); char *vpnif = nvram_safe_get("vpn_device");
 char *nv, *nvp, *b;
 const char *proto, *vpnpf, *saddr, *xports, *iport, *iaddr, *desc, *c, *mdport; int n,i,j,v,vpn_up;
 char *wanvpn[2] = { wanip , vpnip };

 vpn_up = ( (nvram_get_int("vpn_up")==1) && ( (strcmp(vpnif,"")!=0) && (strcmp(vpnip,"")!=0) ) );
 v=(vpn_up?3:1); // v=(1+(vpn_up<<1));

 nvp = nv = strdup(nvram_safe_get("portforward"));
 if (!nv) return;
 while ((b = strsep(&nvp, ">")) != NULL) {
  n = vstrsep(b, "<", &c, &proto, &vpnpf, &saddr, &xports, &iport, &iaddr, &desc);
  if ((n < 8) || (*c != '1')) continue;
  mdport = ( (strchr(xports, ',') != NULL) || (strchr(xports, ':') != NULL) ) ? "-m multiport --dports" : "--dport";

  for(i=0; i<2; ++i){ if( (1 << i) & (*proto - '0') ){ // BEGIN TCP/UDP LOOP
   if (table == IPT_TABLE_NAT) {
    if(nvram_get_int("nf_loopback")==1){
     ipt_write("-A POSTROUTING -p %s %s %s -s %s/%s -d %s -j SNAT --to-source %s\n",tcpudp[i], mdport, *iport ? iport : xports, lanip, nvram_safe_get("lan_netmask"), iaddr, wanip);
    }
    for(j=0; j<2; ++j){ if( (1 << j) & (*vpnpf - '0') & v ){ // BEGIN WAN/VPN LOOP
     ipt_write("-I PREROUTING -p %s %s%s -d %s %s %s -j DNAT --to %s%s%s\n", tcpudp[i], *saddr ? "-s " : "", *saddr ? saddr : "", wanvpn[j],mdport,xports, iaddr,*iport ? ":" : "", iport);
    } } // END WAN/VPN LOOP
   } else if (table == IPT_TABLE_FILTER){
    ipt_write("-I FORWARD -p %s -d %s%s%s -j ACCEPT\n",tcpudp[i], iaddr, *iport ? " --dport " : "", *iport ? iport : "");
   }
  } } // END TCP/UDP LOOP

 }
 free(nv);
// if((table==IPT_TABLE_FILTER)&&(nvram_get_int("wan_route")==1)){ ipt_write("-I FORWARD -s %s/%s -j ACCEPT\n", wanip, nvram_safe_get("wan_netmask")); }
 if(table==IPT_TABLE_FILTER){
  if(nvram_get_int("wan_route")==1){ ipt_write("-I FORWARD -s %s/%s -j ACCEPT\n", wanip, nvram_safe_get("wan_netmask")); }
  if(vpn_up){
   ipt_write("-I INPUT -i br0 -d %s -j DROP\n", vpnip);
   ipt_write("-A FORWARD -i %s -j wanin\n", vpnif);
   ipt_write("-A FORWARD -o %s -j wanout\n", vpnif);
   ipt_write("-A FORWARD -i %s -j upnp\n", vpnif);
  }
 }
 if((table==IPT_TABLE_NAT)&&vpn_up){
  ipt_write("-A PREROUTING -d %s -j WANPREROUTING\n",vpnip);
  ipt_write("-A PREROUTING -i %s -d %s/%s -j DROP\n",vpnif,lanip,nvram_safe_get("lan_netmask"));
  ipt_write("-A POSTROUTING -o %s -j MASQUERADE\n", vpnif);
 }
}

/*
void ipt_forward(ipt_table_t table){
	char *nv, *nvp, *b;
	const char *proto, *saddr, *xports, *iport, *iaddr, *desc;
	const char *c;
	const char *mdport;
	int i, n;
	char ip[64];
	char src[64];

	nvp = nv = strdup(nvram_safe_get("portforward"));
	if (!nv) return;

	while ((b = strsep(&nvp, ">")) != NULL) {


//			[<1.01] 1<3<30,40-45<60<5<desc
//			[<1.07] 1<3<30,40-45<60<192.168.1.5<desc
//
//			1<3<71.72.73.74<30,40-45<60<192.168.1.5<desc
//
//			1 = enabled
//			3 = tcp & udp
//			71.72.73.74 = src addr
//			30,40-45 = ext port
//			60 = int port
//			192.168.1.5 = dst addr
//			desc = desc

		n = vstrsep(b, "<", &c, &proto, &saddr, &xports, &iport, &iaddr, &desc);
		if ((n < 6) || (*c != '1')) continue;
		if (n == 6) {
			// <1.07
			desc = iaddr;
			iaddr = iport;
			iport = xports;
			xports = saddr;
			saddr = "";
		}

		if (!ipt_addr(src, sizeof(src), saddr, "src", IPT_V4, 1, "IPv4 port forwarding", desc))
			continue;

		if (strchr(iaddr, '.') == NULL && strtol(iaddr, NULL, 10) > 0) {
			// < 1.01: 5 -> 192.168.1.5
			strcpy(ip, lan_cclass);
			strlcat(ip, iaddr, sizeof(ip));
		}
		else {
			if (host_addrtypes(iaddr, IPT_V4) != IPT_V4) {
				ipt_log_unresolved(iaddr, "IPv4", "IPv4 port forwarding", desc);
				continue;
			}
			strlcpy(ip, iaddr, sizeof(ip));
		}

		mdport = (strchr(xports, ',') != NULL) ? "-m multiport --dports" : "--dport";
		for (i = 0; i < 2; ++i) {
			if ((1 << i) & (*proto - '0')) {
				c = tcpudp[i];
				if (table == IPT_TABLE_NAT) {
					ipt_write("-A %s -p %s %s %s %s -j DNAT --to-destination %s%s%s\n",
						chain_wan_prerouting,
						c,
						src,
						mdport, xports,
						ip,  *iport ? ":" : "", iport);

					if (nvram_get_int("nf_loopback") == 1) {
						for (n = 0; n < wanfaces.count; ++n) {
							if (*(wanfaces.iface[n].name)) {
								ipt_write("-A POSTROUTING -p %s %s %s -s %s/%s -d %s -j SNAT --to-source %s\n",
									c,
									mdport, *iport ? iport : xports,
									nvram_safe_get("lan_ipaddr"),	// corrected by ipt
									nvram_safe_get("lan_netmask"),
									ip,
									wanfaces.iface[n].ip);
							}
						}
					}
				}
				else {	// filter
					ipt_write("-A wanin %s -p %s -m %s -d %s %s %s -j %s\n",
						src,
						c,
						c,
						ip,
						mdport, *iport ? iport : xports,
						chain_in_accept);
				}
			}
		}
	}
	free(nv);
}
*/

void ipt_triggered(ipt_table_t table)
{
	char *nv, *nvp, *b;
	const char *proto, *mports, *fports;
	const char *c;
	char *p;
	int i;
	int first;
	char s[256];

	nvp = nv = strdup(nvram_safe_get("trigforward"));
	if (!nv) return;

	first = 1;
	while ((b = strsep(&nvp, ">")) != NULL) {
		if ((vstrsep(b, "<", &c, &proto, &mports, &fports) != 4) || (*c != '1')) continue;
		for (i = 0; i < 2; ++i) {
			if ((1 << i) & (*proto - '0')) {
				if (first) {
					// should only be created if there is at least one enabled

					if (table == IPT_TABLE_NAT) {
						ipt_write("-A %s -j TRIGGER --trigger-type dnat\n", chain_wan_prerouting);
						goto QUIT;
					}

					ipt_write(":triggers - [0:0]\n"
							  "-A wanout -j triggers\n"
							  "-A wanin -j TRIGGER --trigger-type in\n");

					first = 0;
				}
				strlcpy(s, mports, sizeof(s));
				if ((p = strchr(s, ':')) != NULL) *p = '-';
				if ((p = strchr(fports, ':')) != NULL) *p = '-';
				c = tcpudp[i];
				ipt_write("-A triggers -p %s -m %s --dport %s "
						  "-j TRIGGER --trigger-type out --trigger-proto %s --trigger-match %s --trigger-relate %s\n",
							c, c, mports,
							c, s, fports);
				// can't use multiport... trigger-match must be set to the same
				// ports as dport since it's used to refresh timer during inbound	-- zzz
			}
		}
	}

QUIT:
	free(nv);
}

#ifdef TCONFIG_IPV6
void ip6t_forward(void)
{
	char *nv, *nvp, *b;
	const char *proto, *saddr, *daddr, *dports, *desc;
	const char *c;
	const char *mdport;
	int i;
	char src[128];

	nvp = nv = strdup(nvram_safe_get("ipv6_portforward"));
	if (!nv) return;

	while ((b = strsep(&nvp, ">")) != NULL) {
		/*
			1<3<2001:23:45:67::/64<2600:abc:def:123::1<30,40-45<desc

			1 = enabled
			3 = tcp & udp
			2001:23:45:67::/64 = src addr
			2600:abc:def:123::1 = dst addr (optional)
			30,40-45 = dst port
			desc = desc
		*/
		if ((vstrsep(b, "<", &c, &proto, &saddr, &daddr, &dports, &desc) != 6) || (*c != '1')) continue;

		if (!ipt_addr(src, sizeof(src), saddr, "src", IPT_V6, 1, "IPv6 port forwarding", desc))
			continue;

		if ((*daddr) && (host_addrtypes(daddr, IPT_V6) != IPT_V6)) {
			ipt_log_unresolved(daddr, "IPv6", "IPv6 port forwarding", desc);
			continue;
		}

		mdport = (strchr(dports, ',') != NULL) ? "-m multiport --dports" : "--dport";
		for (i = 0; i < 2; ++i) {
			if ((1 << i) & (*proto - '0')) {
				c = tcpudp[i];
				ip6t_write("-A wanin %s -p %s -m %s %s%s %s %s -j %s\n",
					src,
					c,
					c,
					(*daddr) ? "-d " : "", daddr,
					mdport, dports,
					chain_in_accept);
			}
		}
	}
	free(nv);
}
#endif
