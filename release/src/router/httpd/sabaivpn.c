#include "tomato.h"

void wo_sabaai_vpna(){

//char hand[]="/mnt/Testy/mipsy/ossl.sh";
//char key[]="tihuoveheSabaai"; char miv[]="6c537f417d42af419241ad49";

	char *data=webcgi_safeget("plz","");
	if( strcmp(data,"")==0 ){
		web_printf("Yep, there was an error.\n");
	}else{
		web_printf("This data was received:\n%s\n",data);
	}

//	FILE *f = popen(hand,"w");
	FILE *f = popen("/mnt/Testy/mipsy/ossl.sh","w");
//	fprintf(f,"%s %s %s\n",inup,key,miv);
	fprintf(f,"tihuoveheSabaai 6c537f417d42af419241ad49 %s\n",data);
	fclose(f);

/*	FILE *bug=fopen("/tmp/debug.vpna","a");
	fprintf(bug,"Received: ~%s~\n",webcgi_safeget("plz","DONOTWANT"));
	fclose(bug);
	web_printf("Received: ~%s~\n",webcgi_safeget("plz","DONOTWANT"));
*/
}
