#include "tomato.h"
#include "sabaisub.h"

int *get_MAC_in_CFE(){
	int *macn = malloc(6*sizeof(*macn)); int i; for(i=0;i<6;i++){ macn[i] = -1; };
	FILE *cfe = fopen("/dev/mtdblock0","r"); if( (cfe != NULL) ){
		int testtell[10] = { 0 }; int t = 0; char mac[32] = {0};
		fseek(cfe,7680,SEEK_SET); fgets(mac,18,cfe);
		if( !T_ISITAMAC(0,mac) ){ fseek(cfe,257792,SEEK_SET); fgets(mac,18,cfe); }
		if( !T_ISITAMAC(0,mac) ){ rewind(cfe); i=262144;
			while( --i>0 ){
				if( (mac[0]=fgetc(cfe))=='m' ){ fgets(&mac[1],4,cfe);
					if( (strncmp(mac,"mac=",4))==0 ){ fgets(mac,18,cfe);
						if( T_ISITAMAC(0,mac) ){ i=0; }
					}else if( mac[3]=='a' ){ fgets(&mac[4],5,cfe);
						if( strncmp(mac,"macaddr=",8)==0 ){
							if(t<10){ testtell[t++] = ftell(cfe); }
						}
					}
				}
			}
		}
		while( (!T_ISITAMAC(0,mac))&&(i<10)&&(testtell[i]!=0) ){
				fseek(cfe, testtell[i++]-11, SEEK_SET); fgets(mac,12,cfe);
				if( strncmp(mac,"et0macaddr=",11)==0 ){ fgets(mac,18,cfe); }
		}
		if( T_ISITAMAC(0,mac) ){
			char *pch = strtok(mac,":");
			i=0; while(pch != NULL){ macn[i++] = strtol(pch, NULL, 16); pch = strtok(NULL, ":"); }
		}
		fclose(cfe);
	}
	return macn;
}

char *get_NV_Code(){
	int *MACN = get_MAC_in_CFE();
	int SUM = MACN[0]+MACN[1]+MACN[2]+MACN[3]+MACN[4]+MACN[5];
	char *e = (char*) malloc( 31*sizeof(*e) );
	if( SUM < 0 ){ e = cadaeic; }else{
		int S[] = { 83, 65, 66, 65, 65, 73 };
		int i,j,k,l; int M[6][6];
		for(i=0; i<6; i++){ for(k=0; k<6; k++){
				M[i][k]=MACN[i]*S[k];
		} }
		int N[6];
		for(i=0; i<6; i++){
			k=i; l=0; N[i]=0;
			for(j=0; j<6; j++){
				N[i]+=M[(l++%6)][(k++%6)];
			}
		}
		char t[31] = {'\0'}; char p[6];
		for(i=0; i<6; i++){
			snprintf(p,6,"%05i",N[i]); strncat(t,p,5);
		}
		strcpy(e,t);
	}
	return e;
}

char *get_R_Code(){
	int *MACN = get_MAC_in_CFE();
	int SUM = MACN[0]+MACN[1]+MACN[2]+MACN[3]+MACN[4]+MACN[5];
	char *ei = malloc(6*sizeof(*ei)); ei[5] = 0;
	if( SUM < 0 ){ ei = "space"; }else{
		int SA[] = { 83, 65, 66, 65, 65, 73 };
		char C[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZ123456789abcdefghijklmnopqrstuvwxyz";
		int i,n;
		for(i=0; i<6; i++){ MACN[i]*=SA[i]; }
		int el[5] = { 0 };
		for(i=0; i<6; i++){
			n=5;
			while(n--){
				el[n]+=(MACN[i]%10);
				MACN[i]/=10;
			}
		}
		for(i=0; i<5; i++){ ei[i] = C[el[i]]; }
	}
	return ei;
}

bool if_sabaai(){ return (strcmp(get_NV_Code(),nvram_safe_get("srcnvrv"))==0); }	//bool if_sabaai(){ char *NVcode = get_NV_Code(); char *NVvalue = nvram_safe_get("srcnvrv"); return (strcmp(get_NV_Code(),nvram_safe_get("srcnvrv"))==0); }

char *sabaaiMenu(char *vs){
	if( strcmp(vs,"sabai")==0 ){ return (sabai_sabai[0]); }else
#if STRONGTF == 0
	if( strcmp(vs,"strong")==0 ){ return (sabai_strong[0]); }else
#else
	if( strcmp(vs,"strong")==0 ){ return (sabai_strongup); }else
#endif
	if( strcmp(vs,"vypr")==0 ){ return (sabai_vypr[0]); }else
	if( strcmp(vs,"vpns")==0 ){ return (sabai_vpns[0]); }else
	if( strcmp(vs,"homebase")==0 ){ return (sabai_home[0]); }else
	if( strcmp(vs,"hma")==0 ){ return (sabai_hma[0]); }else
//	if( strcmp(vs,"astrill")==0 ){ return (sabai_astrill[0]); }else
	{ return (sabai_reg[0]); }
}

void asp_sabaaiMenu(){ web_puts( if_sabaai() ? sabaaiMenu(nvram_safe_get("vpn_service")) : sabai_reg[0] ); }

void asp_sabaaiVPN(int argc, char **argv){
	if( (argc!=1) || (argv[0]==NULL) ) return;
	char page = argv[0][0]; char piece = argv[0][1];
	if(piece=='x'){ web_puts(sabai_jsx); return; }
	if( !if_sabaai() || page=='R' ){
		if( piece=='h' ) web_puts(sabai_reg[2]);
		if( piece=='j' ) web_puts(sabai_reg[1]);
		return;
	}
	switch(page){
		case '0':{
			if( piece=='h' ) web_puts(sabai_sabai[2]);
			if( piece=='j' ) web_puts(sabai_sabai[1]);
			if( piece=='H' ) web_puts(sabai_sabai[4]);
			if( piece=='J' ) web_puts(sabai_sabai[3]);
		break; }
		case 'S':{
			if( piece=='h' ) web_puts(sabai_strong[2]);
			if( piece=='j' ) web_puts(sabai_strong[1]);
			if( piece=='H' ) web_puts(sabai_strong[4]);
			if( piece=='J' ) web_puts(sabai_strong[3]);
		break; }
		case 'D':{
			if( piece=='h' ) web_puts(sabai_dual[2]);
			if( piece=='j' ) web_puts(sabai_dual[1]);
		break; }
		case 'V':{
			if( piece=='h' ) web_puts(sabai_vypr[2]);
			if( piece=='j' ) web_puts(sabai_vypr[1]);
		break; }
		case 'H':{
			if( piece=='h' ) web_puts(sabai_home[2]);
			if( piece=='j' ) web_puts(sabai_home[1]);
		break; }
		case 'C':{
			if( piece=='h' ) web_puts(sabai_vpns[2]);
			if( piece=='j' ) web_puts(sabai_vpns[1]);
		break; }
		case 'M':{
			if( piece=='h' ) web_puts(sabai_hma[2]);
			if( piece=='j' ) web_puts(sabai_hma[1]);
		break; }
/*		case 'A':{
			if( piece=='h' ) web_puts(sabai_astrill[2]);
			if( piece=='j' ) web_puts(sabai_astrill[1]);
		break; }
*//*		case 'P':{
			if( piece=='h' ) web_puts(sabai_apo[2]);
			if( piece=='j' ) web_puts(sabai_apo[1]);
		break; }
*/	}
}

void wo_sabaai_register(){
	char *Rcode = get_R_Code();
	char *Scode = webcgi_safeget("scode","");
	char *NVcode = get_NV_Code();
	char *vs;
	if((strcmp(Scode,"")==0)||strncmp(Rcode,Scode,5)){ web_printf("svm = { status: false, mesg: 'Registration code failed; please try again or contact technical support.', service: '' };\n\n"); return; }
	switch(Scode[5]){
		case '0':{ vs="sabai"; break; }
		case 'S':{ vs="strong"; break; }
		case 'V':{ vs="vypr"; break; }
		case 'H':{ vs="homebase"; break; }
		case 'C':{ vs="vpns"; break; }
		case 'A':{ vs="astrill"; break; }
		case 'M':{ vs="hma"; break; }
		case 'P':{ vs="apo"; break; }
		default: { vs=""; }
	}
	nvram_set("srcnvrv",NVcode); nvram_set("vpn_service",vs); nvram_commit(); web_printf("svm = { status: true, mesg: 'Thank you for registering!', service: '%s', menu: %s };\n\n",vs,sabaaiMenu(vs));
}

void asp_sabai_version(){ web_puts(SABAIVPNVERSION); }
void asp_isitsabai(){ web_printf("%s",(if_sabaai()?"true":"false")); }

void wo_sabaai_hwmac(){ int i=6; char macstr[13] = {0}; int *mac = get_MAC_in_CFE();
 while(i--){ sprintf( &macstr[2*(5-i)] ,"%02X",mac[5-i]); }; macstr[13] = 0;
 web_printf("%s\n%s\n",macstr,nvram_safe_get("et0macaddr") );
}


void asp_isitsafe(){ int i=6; char macstr[18] = {0}; int *mac = get_MAC_in_CFE(); while(i--){ sprintf( &macstr[3*(5-i)] ,"%02X:",mac[5-i]); }; macstr[17] = 0;
 web_printf("isitsafe={ hwmac: '%s', nvmac: '%s' };\n",macstr,nvram_safe_get("et0macaddr") );
}

//void asp_sabai_hash(){ eval("md5sum","/dev/mtd0ro"); }

void asp_sabai_msg(){
	int i; int *mac = get_MAC_in_CFE();
	unsigned char S[] = { 83, 65, 66, 65, 65, 73 };
	for(i=0; i<6; i++){ mac[i] = (~mac[i]^S[i])&255 ; };
	char servc[25] = { 0 };
	for(i=0; i<6; i++){ sprintf(&servc[4*i],"%02x%02x",mac[i],S[i]); }
	web_puts(servc);
}
