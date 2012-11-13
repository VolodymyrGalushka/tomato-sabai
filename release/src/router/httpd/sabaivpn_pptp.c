#include "httpd.h"
#include "tomato.h"
#include "sabaivpn_pptp.h"

void wo_sabaai_PPTP(){
	char *fire = webcgi_safeget("fire","");
	char *vpn_user = webcgi_safeget("vpn_user","");
	char *vpn_pass = webcgi_safeget("vpn_pass","");
	char *vpn_serv = webcgi_safeget("vpn_server","");
	char *pptp_mppe = webcgi_safeget("pptp_mppe","");
	char *pptp_stateful = webcgi_safeget("pptp_stateful","");

	nvram_set("vpn_type","p");
	if(strcmp(vpn_user,"")){ nvram_set("vpn_user",vpn_user); }
	if(strcmp(vpn_pass,"")){ nvram_set("vpn_pass",vpn_pass); }
	if(strcmp(vpn_serv,"")){ nvram_set("vpn_server",vpn_serv); }
	if(strcmp(pptp_mppe,"")){ nvram_set("pptp_mppe",pptp_mppe); }
	if(strcmp(pptp_stateful,"")){ nvram_set("pptp_stateful",pptp_stateful); }

web_printf("PPTP.\n\n");
nvram_set("vpn_mesg","PPTP updated.");

	if( strcmp(fire,"erase")==0 ){
		if( !f_exists("/tmp/script_wanup.sh") ){
			f_write("/tmp/script_wanup.sh", pptp_script, strlen(pptp_script), 0, 0700);
		}
		eval("sh","/tmp/script_wanup.sh", "stop");
		nvram_set("script_wanup", "");
		remove("/tmp/script_wanup.sh");
	}else if(strcmp(fire,"update")){
		nvram_set("script_wanup", pptp_script);
		if( !f_exists("/tmp/script_wanup.sh") ){
			f_write("/tmp/script_wanup.sh", pptp_script, strlen(pptp_script), 0, 0700);
		}
		if( strcmp(fire,"start")==0 ){
			if( nvram_get_int("ovpn_on")==1 ){
				nvram_unset("script_init"); nvram_set("ovpn_on","0");
				nvram_commit(); killall("openvpn", SIGTERM);
				remove("/tmp/ovpn/up"); remove("/tmp/ovpn/dn"); remove("/tmp/ovpn/ovpn.conf"); remove("/tmp/ovpnsi.sh"); remove("/etc/config/ovpn.wanup"); remove("/tmp/etc/config/ovpnpass.txt");
			}
			nvram_set("pptp_on","1");
			eval("sh","/tmp/script_wanup.sh", "start");
			nvram_set("script_wanup", pptp_script);
		}else if( strcmp(fire,"stop")==0 ){
			nvram_set("pptp_on","0");
			eval("sh","/tmp/script_wanup.sh", "stop");
			nvram_set("script_wanup", "");
		}
	}
	nvram_commit();
}
