#include "tomato.h"

void wo_makeStatic(){
	nvram_set("dhcpd_static",webcgi_safeget("statics",""));
	nvram_commit();
	char *p=webcgi_safeget("ip","");
	if( strcmp(p,"")==0 ){ return; }
	f_write_string("/var/tmp/dhcp/delete", p, FW_CREATE|FW_NEWLINE, 0666);
	killall("dnsmasq", SIGUSR2);
	f_wait_notexists("/var/tmp/dhcp/delete", 5);
	exec_service("dhcpd-restart");
//	sleep(2);
//	exec_service("firewall-restart");
	web_printf("IP reassigned.");
// EXP
}

void wo_sabaai_dual(){
//	char *vl = webcgi_safeget("vl",""); char *vg = webcgi_safeget("vg",""); char *va = webcgi_safeget("va","");
//	nvram_set("vpn_group_vpn",vg); nvram_set("vpn_group_local",vl); nvram_set("vpn_group_accel",va);
//	nvram_set("dhcpd_static",webcgi_safeget("statics",""));
//	nvram_commit();
//	chmod("/tmp/dgw.sh",strtol("0777", 0, 8));
//	char *args[] = { "/bin/sh", "/tmp/dgw.sh", NULL, NULL };
//	_eval(args, NULL, 0, NULL);
//	web_puts("Dual Gateway Activated.");
}
