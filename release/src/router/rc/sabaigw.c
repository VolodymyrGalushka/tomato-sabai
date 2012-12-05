#include "rc.h"
//#include <shutils.h>

void do_sabaigw(bool start){
	char *args[] = { "/bin/sh", "/www/gw.sh", (start?"start":"stop"), NULL, NULL };
	_eval(args, NULL, 0, NULL);
}
