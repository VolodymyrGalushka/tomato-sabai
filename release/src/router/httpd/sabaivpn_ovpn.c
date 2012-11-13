#include "tomato.h"
#include <sys/stat.h>
#include "sabaivpn_ovpn.h"

void parse_strong_script( char *c ){
	char *o[4];
	while( (c = strstr(c, "nvram set ")) ){
		if	( c[10]=='o' ){
			if	(strncmp(&c[10],"ovpn_cfg"  , 8)==0){ c[0]='\0'; o[0]=&c[18]; }
			else if	(strncmp(&c[10],"ovpn_up"   , 7)==0){ c[0]='\0'; o[1]=&c[17]; }
			else if	(strncmp(&c[10],"ovpn_dn"   , 7)==0){ c[0]='\0'; o[2]=&c[17]; }
		}else if( c[10]=='r' ){
			if	(strncmp(&c[10],"rc_startup",10)==0){ c[0]='\0'; o[3]=&c[20]; }
		}
		c++;
	}
	int i; int l=0;
	for(i=0; i<4; i++){
		while( (o[i][0]==' ') || (o[i][0]=='\'') || (o[i][0]=='=') ){ o[i]++; }
		l = strlen(o[i])-1;
		while( (o[i][l]!='\'') ){ o[i][l--]='\0'; }
		while( (o[i][l]=='\'') || (o[i][l]==' ') || (o[i][l]=='\n') ){ o[i][l--]='\0'; }
	}

	char *ss = strstr(o[0],"script-security");
	ss[0] = '\0'; ss++; ss = strchr(ss,'\n');
	int ssl = strlen(ss); l = strlen(o[0]);
	char *oc = (char *) malloc( sizeof(oc)*(l + ssl + 24) ); oc[0] = '\0';
	strncat(oc,o[0],l);
	strncat(oc,"script-security 2 system",24);
	strncat(oc,ss,ssl);
	nvram_set("ovpn_cf",oc);
	free(oc);

	nvram_set("ovpn_up",uni_up);
	nvram_set("ovpn_dn",uni_dn);
	nvram_set("ovpn_si",gen_si);
}

void process_zip_data(){
	FILE *zip = fopen("/tmp/zipinator.sh","w"); fprintf(zip,"%s\n",zippy); fclose(zip);
	nvram_set("ovpn_si",gen_si);
	nvram_set("ovpn_up",uni_up);
	nvram_set("ovpn_dn",uni_dn);
	chmod("/tmp/zipinator.sh",strtol("0777", 0, 8));
	char *args[] = { "/bin/sh", "/tmp/zipinator.sh", NULL, NULL };
	_eval(args, NULL, 0, NULL);
}

void wi_grabovpn_script(char *url, int len, char *boundary){
	check_id(url);
	char *buf; const char *error; int n; char filename[_SABAI_MAX_FILENAME_LENGTH] = {0}; filename[0]='\0';
	buf = NULL; error = NULL;
	if(!skip_header_get_filename(&len, filename, _SABAI_MAX_FILENAME_LENGTH)){ error = "Error reading header"; goto ERROR; }
	if((len < 10) || (len > _SABAI_MAX_SCRIPT_SIZE)){ error = "Invalid file"; goto ERROR; }

	int bufsize = len + _SABAI_MAX_REPLACE_INCREASE; 
	if((buf = malloc(bufsize)) == NULL){ error = "Not enough memory"; goto ERROR; }
	while(bufsize--){ buf[bufsize] = 0; };
	n = web_read(buf, len); len -= n;

	char *ext = strrchr(filename,'.');
	if( strcmp(ext,".sh") ==0 ){
		parse_strong_script(buf);
		nvram_set("ovpn_type","StrongScript"); nvram_commit();
	}else if( strcmp(ext,".zip")==0 ){
		FILE *zip_in = fopen("/tmp/ovpn.zip","wb"); fwrite(buf,1,n,zip_in); fclose(zip_in);
		process_zip_data();
		nvram_set("ovpn_type","ZipScript");
	}else if( (strcmp(ext,".ovpn")==0)||(strcmp(ext,".conf")==0) ){
		char *bufend = strstr(buf,boundary);
		int i=0;
		while ( bufend[i]=='-' ){ bufend[i--]='\0'; }
		strcat(buf,"\ndaemon\nscript-security 2 system\nroute-up /tmp/ovpn/up\ndown /tmp/ovpn/dn\n");
		nvram_set("ovpn_cf",buf);
		nvram_set("ovpn_si",gen_si);
		nvram_set("ovpn_up",uni_up);
		nvram_set("ovpn_dn",uni_dn);
		nvram_set("ovpn_type","StrongOVPN");
	}else{ error = "Not a .sh or .zip or .ovpn file!"; goto ERROR; }
	nvram_set("ovpn_file",filename);
	nvram_commit();

ERROR:
	free(buf);
	if (error != NULL) resmsg_set(error);
	web_eat(len);
	redirect("./sabaivpn-ovpn.asp");
}

void wo_sabaai_OVPN_start(){
	nvram_set("ovpn_on","1");
	nvram_set("vpn_mesg","Starting OpenVPN...");
	if( nvram_get_int("pptp_on")==1 ){ eval("sh","/tmp/script_wanup.sh", "stop"); nvram_set("script_wanup", ""); }
	if(strcmp(nvram_safe_get("ovpn_on"),"1")==0){ killall("openvpn", SIGTERM); }
	char* ovpn_si = nvram_safe_get("ovpn_si");
	char* ovpn_up = nvram_safe_get("ovpn_up");
	char* ovpn_dn = nvram_safe_get("ovpn_dn");
	if( strlen(ovpn_si)==0 ){ nvram_set("ovpn_si",gen_si); ovpn_si=gen_si; }
	if( strlen(ovpn_up)==0 ){ nvram_set("ovpn_up",uni_up); }
	if( strlen(ovpn_dn)==0 ){ nvram_set("ovpn_dn",uni_dn); }
	nvram_set("script_init",ovpn_si);
	nvram_set("vpn_mesg","Initializing script...");
	FILE *script_init_file; script_init_file = fopen("/tmp/ovpnsi.sh","w");
	fprintf(script_init_file,"%s\n",ovpn_si);
	fclose(script_init_file);
	chmod("/tmp/ovpnsi.sh",strtol("0777", 0, 8));

	char *args[] = { "/bin/sh", "/tmp/ovpnsi.sh", NULL, NULL };
	_eval(args, NULL, 0, NULL);
	nvram_commit();
	web_printf("OpenVPN activated.");
}

void wo_sabaai_OVPN_stop(){
	killall("openvpn", SIGTERM);
	nvram_unset("script_init"); nvram_set("ovpn_on","0");
	nvram_commit();
	remove("/tmp/ovpn/ovpn.conf"); remove("/tmp/ovpnsi.sh"); remove("/etc/config/ovpn.wanup"); remove("/tmp/etc/config/ovpnpass.txt");
	sleep(1);
	remove("/tmp/ovpn/up"); remove("/tmp/ovpn/dn");
	web_printf("OpenVPN stopped.");
}

void wo_sabaai_OVPN_erase(){
	killall("openvpn", SIGTERM);
	nvram_unset("script_init"); nvram_unset("ovpn_dn"); nvram_unset("ovpn_up"); nvram_unset("ovpn_cf"); nvram_unset("ovpn_type"); nvram_unset("ovpn_file"); nvram_set("ovpn_on","0"); nvram_commit();
	remove("/tmp/ovpn/ovpn.conf"); remove("/tmp/ovpnsi.sh"); remove("/etc/config/ovpn.wanup"); remove("/tmp/etc/config/ovpnpass.txt");
	sleep(1);
	remove("/tmp/ovpn/up"); remove("/tmp/ovpn/dn"); 
	web_printf("OpenVPN script purged.");
}
