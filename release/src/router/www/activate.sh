#!/bin/sh
exec 2>/var/log/activate.log
p1='192.168.200.2'; p2='192.168.222.197'; p3="$(nvram get srcnvrp)";
_msg(){ echo "{ \"sabai\": $1, \"msg\": \"$2\" }"; exit; }
_bad(){ _msg 'false' "$1"; }
_crypt(){ key='tihuoveheSabaai'; miv='6c537f417d42af419241ad49'; salt="$(head -c32 /dev/urandom | md5sum | tr -d ' -'|head -c8)"; K="$(echo -n $salt$key | md5sum | tr -d ' -')"; I="$(echo -n $salt$miv | md5sum | tr -d ' -')"; salt64="$(echo -n $salt | openssl enc -e -a -A)"; con="$salt64$(echo "$1" | openssl aes128 -e -a -A -K $K -iv $I | tr '+' '.')"; }
_manual(){ _crypt "$(nvram get srcnvrl),$(md5sum /dev/mtd0ro | cut -d' ' -f1),$data"; _msg 'true' "$con"; }
_request(){ unset $data; _crypt "$2"; res="$(wget $1$con -qO-)" || _bad "Error contacting server"; res="$(echo $res | openssl aes128 -d -a -A -nosalt -K $K -iv $I)" || _bad 'Request lost in translation'; data="$(echo "$res" | tail -n+2)"; res="$(echo "$res" | head -n1)"; ret="${res:0:1}"; res="${res:1}"; [ $ret -eq 0 ] && _bad $res; }
_isThere(){ ping -c1 -W2 -w3 $1 >/dev/null 2>&1 && p=$1; }
_program(){
	[ -n "$(nvram get srcnvrl)" ] && _bad "Router already licensed."
	_isThere $p1 || _isThere $p2 || _bad "Can't contact proxy.";
	_request "http://$p/grabs/proxy.php?plz=" "$(md5sum /dev/mtd0ro | cut -d' ' -f1),$data";
	nvram set srcnvrl="$data";
	nvram commit >/dev/null 2>&1;
	echo "$res";
}
_activate(){ _request "http://$p3/grabs/activate.php?plz=act&kthx=" "$(nvram get srcnvrl),$(md5sum /dev/mtd0ro | cut -d' ' -f1),$data"; _gotToken; }
_gotToken(){ nvram set srcnvrv="$data"; nvram commit >/dev/null 2>&1; _msg 'true' "Activated!"; }

read -s -t1 act data || act=$1;

case $act in
	program)	_program	;;
	activate)	_activate	;;
	manual)		_manual		;;
	gotToken)	_gotToken	;;
	*)	_bad 'No action.';	;;
esac
