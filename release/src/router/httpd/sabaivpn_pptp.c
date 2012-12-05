#include "httpd.h"
#include "tomato.h"
#include "sabaivpn_pptp.h"

void wo_sabaai_PPTP(){
	char *fire		= webcgi_safeget("fire"		,"");
	char *vpn_user		= webcgi_safeget("vpn_user"	,"");
	char *vpn_pass		= webcgi_safeget("vpn_pass"	,"");
	char *vpn_serv		= webcgi_safeget("vpn_server"	,"");
	char *pptp_mppe		= webcgi_safeget("pptp_mppe"	,"1");
	char *pptp_stateful	= webcgi_safeget("pptp_stateful","0");

	bool changed = FALSE;

	if( strcmp(vpn_user	,nvram_safe_get("vpn_user")	) != 0 ){ nvram_set("vpn_user"		,vpn_user);		changed = TRUE; }
	if( strcmp(vpn_pass	,nvram_safe_get("vpn_pass")	) != 0 ){ nvram_set("vpn_pass"		,vpn_pass);		changed = TRUE; }
	if( strcmp(vpn_serv	,nvram_safe_get("vpn_server")	) != 0 ){ nvram_set("vpn_server"	,vpn_serv);		changed = TRUE; }
	if( strcmp(pptp_mppe	,nvram_safe_get("pptp_mppe")	) != 0 ){ nvram_set("pptp_mppe"		,pptp_mppe);		changed = TRUE; }
	if( strcmp(pptp_stateful,nvram_safe_get("pptp_stateful")) != 0 ){ nvram_set("pptp_stateful"	,pptp_stateful);	changed = TRUE; }

	nvram_set("vpn_mesg","PPTP updated.");
	web_printf("PPTP.\n\n");

	if( (strcmp(fire,"save") == 0) && changed ){ nvram_commit(); return; }

	if( ! f_exists("/tmp/script_wanup.sh") ) f_write("/tmp/script_wanup.sh", pptp_script, strlen(pptp_script), 0, 0700);

	if( strcmp(fire,"start") == 0 ){
		if( nvram_get_int("ovpn_on")==1 ){
			nvram_unset("script_init"); nvram_set("ovpn_on","0");
			nvram_commit(); killall("openvpn", SIGTERM);
			remove("/tmp/ovpn/up"); remove("/tmp/ovpn/dn"); remove("/tmp/ovpn/ovpn.conf"); remove("/tmp/ovpnsi.sh"); remove("/etc/config/ovpn.wanup"); remove("/tmp/etc/config/ovpnpass.txt");
		}
		nvram_set("pptp_on","1");
		nvram_set("script_wanup", pptp_script);
		eval("sh","/tmp/script_wanup.sh", "start");
		changed = TRUE;
	}else if( strcmp(fire,"stop") == 0 ){
		nvram_set("pptp_on","0");
		nvram_set("script_wanup", "");
		eval("sh","/tmp/script_wanup.sh", "stop");
		changed = TRUE;
	}
	nvram_commit();
}
