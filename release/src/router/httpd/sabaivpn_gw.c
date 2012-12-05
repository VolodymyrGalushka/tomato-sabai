#include "tomato.h"

void wo_sabaai_gw(){
/*
	char *gw_def=webcgi_safeget("gw_def",""); char *gw_1=webcgi_safeget("gw_1",""); char *gw_2=webcgi_safeget("gw_1",""); char *gw_3=webcgi_safeget("gw_1",""); char *dhcpd_static = webcgi_safeget("dhcpd_static","");
	nvram_set("gw_def",gw_def); nvram_set("gw_1",gw_1); nvram_set("gw_2",gw_2); nvram_set("gw_3",gw_3); nvram_set("dhcpd_static",dhcpd_static);
*/

	nvram_set("gw_def",webcgi_safeget("gw_def","0")); nvram_set("gw_1",webcgi_safeget("gw_1","")); nvram_set("gw_2",webcgi_safeget("gw_2","")); nvram_set("gw_3",webcgi_safeget("gw_3",""));

	char *old_dhcpd_static=nvram_safe_get("dhcpd_static"); char *new_dhcpd_static=webcgi_safeget("dhcpd_static","");
	if(strcmp(old_dhcpd_static,new_dhcpd_static)!=0){ nvram_set("dhcpd_static",new_dhcpd_static); exec_service("dhcpd-restart"); }

	nvram_commit();
	exec_service("sabaigw-restart");

//	web_printf("{ \"sabai\": true, \"gw_def\": \"%s\", \"gw_1\": \"%s\", \"gw_2\": \"%s\", \"gw_3\": \"%s\", \"dhcpd_static\": \"%s\" }", gw_def, gw_1,gw_2,gw_3,dhcpd_static);
	web_printf("{ \"sabai\": true }");
}
