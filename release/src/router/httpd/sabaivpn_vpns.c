#include "tomato.h"
#include "sabaivpn_vpns.h"

void wo_sabaai_vpns(){
	char *fire = webcgi_safeget("fire","");
	nvram_set("vpn_mesg",fire);
	if( !f_exists("/tmp/vpns.sh") ){ f_write("/tmp/vpns.sh", vpns_script, strlen(vpns_script), 0, 0777); }

	char *vpns_user = webcgi_safeget("vpn_user","");
	char *vpns_pass = webcgi_safeget("vpn_pass","");
	char *vpns_serv = webcgi_safeget("vpn_server","");
	char *vpns_fix = webcgi_safeget("vpn_fix","");
	if(strcmp(vpns_user,"")){ nvram_set("vpn_user",vpns_user); }
	if(strcmp(vpns_pass,"")){ nvram_set("vpn_pass",vpns_pass); }
	if(strcmp(vpns_serv,"")){ nvram_set("vpn_server",vpns_serv); }
	if(strcmp(vpns_fix,"")){ nvram_set("vpn_fix",vpns_fix); }
	if( strcmp(fire,"list")==0 ){
		eval("sh","/tmp/vpns.sh","list");
		web_puts(nvram_safe_get("vpns_serverlist"));
		return;
	}

nvram_set("vpn_mesg","Updated.");
web_printf("VPNS.\n\n");
	if( strcmp(fire,"start")==0 ){
		nvram_set("ovpn_up",uni_up);
		nvram_set("ovpn_dn",uni_dn);
		nvram_set("ovpn_si", vpns_script);
		nvram_set("script_init",vpns_si);
		nvram_set("ovpn_on","1");
		nvram_set("vpn_mesg","Script start.");
		eval("sh","/tmp/vpns.sh", "start");
	}else if( strcmp(fire,"stop")==0 ){
		nvram_set("ovpn_on","0");
		nvram_set("ovpn_si", "");
		nvram_set("script_init", "");
		nvram_set("vpn_mesg","Script stop.");
		eval("sh","/tmp/vpns.sh", "stop");
	}
	nvram_commit();
}
