#include "tomato.h"
#include "sabaivpn_vypr.h"

void wo_sabaai_vypr(){
	char *fire = webcgi_safeget("fire","");
	nvram_set("vpn_mesg",webcgi_safeget("vpn_type",""));
	nvram_set("vpn_type","PPTP");
	if( !f_exists("/tmp/vypr.sh") ){ f_write("/tmp/vypr.sh", vypr_script, strlen(vypr_script), 0, 0777); }

	char *vypr_user = webcgi_safeget("vpn_user","");
	char *vypr_pass = webcgi_safeget("vpn_pass","");
	char *vypr_serv = webcgi_safeget("vpn_server","");
	if(strcmp(vypr_user,"")){ nvram_set("vpn_user",vypr_user); }
	if(strcmp(vypr_pass,"")){ nvram_set("vpn_pass",vypr_pass); }
	if(strcmp(vypr_serv,"")){ nvram_set("vpn_server",vypr_serv); }
nvram_set("vpn_mesg","Updated.");
web_printf("VYPR.\n\n");
	if( strcmp(fire,"start")==0 ){
		nvram_set("ovpn_up",uni_up);
		nvram_set("ovpn_dn",uni_dn);
		nvram_set("ovpn_si", vypr_script);
		nvram_set("script_init",vypr_si);
		nvram_set("ovpn_on","1");
		nvram_set("vpn_mesg","Script start.");
		eval("sh","/tmp/vypr.sh", "start");
	}else if( strcmp(fire,"stop")==0 ){
		nvram_set("ovpn_on","0");
		nvram_set("ovpn_si", "");
		nvram_set("script_init", "");
		nvram_set("vpn_mesg","Script stop.");
		eval("sh","/tmp/vypr.sh", "stop");
	}
	nvram_commit();
}
