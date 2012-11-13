#!/bin/sh
read -s -t1 act vpn_service msg inf ext;

_badmsg(){ echo "$1"; exit; }
_bad(){ _badmsg "reg={ sabai: false, msg: '$1; please contact technical support.' };"; }

exec 2>/dev/null
case $act in
	info)
nvram set reg_info="$inf";

key='tihuoveheSabaai'; miv='6c537f417d42af419241ad49';
salt="$(head -c32 /dev/urandom | md5sum | tr -d ' -'|head -c8)";
K="$(echo -n $salt$key | md5sum | tr -d ' -')";
I="$(echo -n $salt$miv | md5sum | tr -d ' -')";
salt64="$(echo -n $salt | openssl enc -e -a -A)";
con="$(echo "$msg,$inf,$ext" | openssl aes128 -e -a -A -K $K -iv $I | tr '+' '.')";
uri='http://'"$(nvram get srcreg)"'/grabs/mipsreg.php?plz='"$salt64$con";
res="$(wget $uri -qO-)" || _bad 'Error contacting server';
res="$(echo $res | openssl aes128 -d -a -A -nosalt -K $K -iv $I)" || _bad 'Request lost in translation';
sabai="${res:0:1}"
[ "$sabai" == "0" ] && _badmsg "${res:1}";
nvc="${res:1:30}"
res="${res:31}"
	;;
	code)
nvc=$inf
res="reg={ sabai: true, msg: '' };";
	;;
esac

nvram set srcnvrv=$nvc;
nvram set vpn_service=$vpn_service;
echo $res;
