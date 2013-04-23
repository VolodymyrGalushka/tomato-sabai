#include "tomato.h"
#include "sabai.h"
#include <sys/ioctl.h>

//FILE *bug = fopen("/cifs1/newovpn/bug.ovpn.txt","w"); fprintf(bug,"Debug?\n"); fclose(bug);
// INTERNAL BEGIN

unsigned char S[] = { 83, 65, 66, 65, 65, 73 };
int macSum = 0;
unsigned char M[6] = { 0 };
char NV[31] = {0};

void lanMac(){ if(macSum!=0) return; int i,f; struct ifreq ifr; strncpy(ifr.ifr_name, "eth0" ,IFNAMSIZ); ifr.ifr_name[IFNAMSIZ-1] = 0;
 if(((f=socket(AF_INET,SOCK_DGRAM,0))>=0)&&(ioctl(f,SIOCGIFHWADDR,&ifr)==0)){ close(f); for(i=0,macSum=0;i<6;i++){ macSum += M[i] = ifr.ifr_hwaddr.sa_data[i]; } }
}

void nvCode(){ lanMac(); if(!NV[0]){ int c,k,n; for(c=0; c<6; c++){ n=0; k=6; while(k-->0){ n += M[k]*S[(c+k)%6]; }; snprintf( &NV[ 5*c ], 6, "%05i", n); } } }

void asp_sabaiErr(){ if(f_exists("/tmp/sabaierr")){ do_file("/tmp/sabaierr"); remove("/tmp/sabaierr"); } }

int nvram_update(const char *variable, const char *value){ char *nv_old = nvram_get(variable);
	int change = (value!=NULL) && (nv_old==NULL || (strcmp(nv_old,value)!=0));
	if( change ) nvram_set(variable,value);
	return change;
}

int isSabai(){ nvCode(); return nvram_match("srcnvrv",NV); }

// INTERNAL END
// CGI BEGIN

void wo_sabaai_pptp(){
	int fire = atoi(webcgi_safeget("fire","0"));
	int nc = nvram_update("pptp_user",webcgi_get("pptp_user"))
		| nvram_update("pptp_pass",webcgi_get("pptp_pass"))
		| nvram_update("pptp_server",webcgi_get("pptp_server"))
		| nvram_update("pptp_mppe",webcgi_safeget("pptp_mppe","1"))
		| nvram_update("pptp_stateful",webcgi_safeget("pptp_stateful","0"))
		| nvram_update("vpn_servername",webcgi_safeget("vpn_servername",""));

	if( fire ){
		int updateFile = nvram_update("vpn_file","p");
		if( !f_exists(SABAIWANUP) || updateFile) f_write(SABAIWANUP, pptp_script, strlen(pptp_script), 0, 0700);
		nc |= nvram_update("vpn_up","0")
			| nvram_update("vpn_ready","0")
			| updateFile;
		if( fire == 1 ){
			nc |= nvram_update("vpn_on","1")
				| nvram_update("vpn_type","PPTP")
				| nvram_update("script_wanup",pptp_script);
			eval("sh",SABAIWANUP,"start");
		}else{
			eval("sh",SABAIWANUP,"stop");
			nc |= nvram_update("vpn_on","0")
				| nvram_update("vpn_type","")
				| nvram_update("script_wanup","");
			if( fire == 3 ){
				nc |= nvram_update("pptp_user","")
					| nvram_update("pptp_pass","")
					| nvram_update("pptp_server","")
					| nvram_update("vpn_file","");
				remove(SABAIWANUP);
			}
		}
	}
	if(nc) nvram_commit();
	web_printf("{ \"sabai\": true, \"msg\": \"PPTP %i complete.\", \"committed\": \"%i\" }", fire, nc);
}

#define OVPN_BUG TRUE

void wo_sabaai_ovpn(){
	int fire = atoi(webcgi_safeget("fire","0"));
	int nc = nvram_update("ovpn_user",webcgi_get("ovpn_user"))
		| nvram_update("ovpn_pass",webcgi_get("ovpn_pass"))
		| nvram_update("ovpn_cf",webcgi_get("ovpn_cf"))
		| nvram_update("ovpn_server",webcgi_safeget("ovpn_server",""))
		| nvram_update("vpn_servername",webcgi_safeget("vpn_servername",""));

	if( fire > 0 ){
		int updateFile = nvram_update("vpn_file","o");
		if( !f_exists(SABAIWANUP) || updateFile) f_write(SABAIWANUP, ovpn_script, strlen(ovpn_script), 0, 0700);
		nc |= nvram_update("vpn_up","0")
			| nvram_update("vpn_ready","0")
			| updateFile;
		if( fire == 1 ){
			nc |= nvram_update("vpn_on","1")
				| nvram_update("vpn_type","OpenVPN")
				| nvram_update("script_wanup",ovpn_script);

			eval("sh",SABAIWANUP, "start");
		}else{
			eval("sh",SABAIWANUP, "stop");
			nc |= nvram_update("vpn_on","0")
				| nvram_update("vpn_type","")
				| nvram_update("script_wanup","");
			if( fire == 3 ){
				nc |= nvram_update("ovpn_user","")
					| nvram_update("ovpn_pass","")
					| nvram_update("ovpn_cf","")
					| nvram_update("ovpn_file","")
					| nvram_update("vpn_file","");
				remove(SABAIWANUP);
			}
		}
	}
	if(nc) nvram_commit();
	web_printf("{ \"sabai\": true, \"msg\": \"OpenVPN %i complete.\", \"committed\": \"%i\" }", fire, nc);
}

/*#define BIG_BUFFER 65536
void wi_sabaai_ovpn_getlong(char *url, int len, char *boundary){
	check_id(url);
	char buf[BIG_BUFFER] = { 0 };
	len -= web_read(buf, len);
	f_write("/cifs1/mipsy/testovpn.boundary", boundary, strlen(boundary), 0, 0664);
	f_write("/cifs1/mipsy/testovpn.out", buf, strlen(buf), 0, 0664);
	redirect("sabai-ovpn.asp");
}*/

void wi_sabaai_ovpn_get(char *url, int len, char *boundary){
	check_id(url);
	const char *error = NULL;
	if((16 > len) || (len > _SABAI_FILE_BUFFER)){ error = _SABAI_FILE_RANGE_ERROR; goto ERROR; }
	char buf[_SABAI_FILE_BUFFER] = { 0 };
	len -= web_read(buf, len);

	char *filename, *file, *end;
	if( (filename = strstr(buf,"filename=\"")) == NULL){ error = "Invalid file."; goto ERROR; }
	filename += 10;
	if( (end = strstr(filename,"\"")) == NULL){ error = "Invalid file."; goto ERROR; }
	*end = 0;
	if( (file = strstr(end+1,"\r\n\r\n")) != NULL ){ file += 4; }else if( (file = strstr(end+1,"\n\n")) != NULL ){ file += 2; }else { error = "Invalid file."; goto ERROR; }
	if( (end = strstr(file,boundary)) == NULL){ error = "Invalid file."; goto ERROR; }
	while( *end == '-' || *end == '\r' || *end == '\n' ){ *end = 0; end--; }
	end = strrchr(filename,'.');
	if( (strcmp(end,".ovpn")!=0)&&(strcmp(end,".conf")!=0) ){ error = "Not a .conf or .ovpn file."; goto ERROR; }

	f_write("/tmp/newovpn.in", file, strlen(file), 0, 0664);
	f_write(SABAICLEAN, cleaner_script, strlen(cleaner_script), 0, 0700);
	eval("sh",SABAICLEAN);
	remove(SABAICLEAN);

	FILE *cleanin = fopen("/tmp/newovpn.out","r");
	int dif = (file - buf)+1;
	int final = fread(file,1,_SABAI_FILE_BUFFER-dif,cleanin);
	file[final] = 0;
	fclose(cleanin);
	if(final > _SABAI_FILE_LIMIT){ error = _SABAI_FILE_RANGE_ERROR; goto ERROR; }

	remove("/tmp/newovpn.in");
	remove("/tmp/newovpn.out");

	nvram_set("ovpn_cf",file);
	nvram_set("ovpn_file",filename);
	nvram_commit();

ERROR:
	web_eat(len);
	if (error != NULL) f_write("/tmp/sabaierr", error, strlen(error), 0, 0600);
	redirect("sabai-ovpn.asp");
}

void wi_sabaai_ovpn_parts(char *url, int len, char *boundary){
	check_id(url);
	int lend = len;
	if((16 > len) || (len > _SABAI_FILE_BUFFER)){
		char error[] = _SABAI_FILE_RANGE_ERROR;
		f_write("/tmp/sabaierr", error, strlen(error), 0, 0600);
		goto ERROR;
	}
	char buf[_SABAI_FILE_BUFFER] = { 0 };
	lend -= web_read(buf, len);
	f_write("/tmp/parts.src", buf, len, 0, 0660);
	f_write(SABAIPARTS, parts_script, strlen(parts_script), 0, 0700);
	eval("sh",SABAIPARTS);
	remove(SABAIPARTS);
ERROR:
	web_eat(lend);
	redirect("sabai-ovpn.asp");
}

void wo_sabaai_gw(){
	int gwRestart = nvram_update("gw_def",webcgi_safeget("gw_def","0"))
		| nvram_update("gw_1",webcgi_safeget("gw_1",""))
		| nvram_update("gw_2",webcgi_safeget("gw_2",""))
		| nvram_update("gw_3",webcgi_safeget("gw_3",""));

	int dsRestart = nvram_update("dhcpd_static",webcgi_safeget("dhcpd_static","0"));

	if(gwRestart || dsRestart){ nvram_commit(); eval("sh", SABAIGW, (dsRestart?"ds":"start") ); }
	web_printf("{ \"sabai\": true }");
}

// CGI END
// ASP BEGIN

void asp_sabaaiMenu(){ do_file(SABAIMENU); }
void asp_sabaid(){
 char *rname = nvram_get("router_name");
 web_printf("%s",( rname && (strcmp(rname,"Sabai")!=0) ) ? rname : "" );
}
void asp_lanMacStr(){ lanMac(); web_printf("%02X:%02X:%02X:%02X:%02X:%02X", M[0], M[1], M[2], M[3], M[4], M[5]); }
void asp_sabaiMsg(){ lanMac(); int i; unsigned char n[6]={0}; i=6; while(i-->0) n[i]=~M[i]^S[i]; web_printf("%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",n[0], n[0]^n[1], n[1], n[1]^n[2], n[2], n[2]^n[3], n[3], n[3]^n[4], n[4], n[4]^n[5], n[5]); }
void asp_isitsabai(){ web_puts((isSabai()?"true":"false")); }

// ASP END
// SABAI
