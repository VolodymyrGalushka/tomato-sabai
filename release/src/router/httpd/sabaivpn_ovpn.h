#ifndef SABAIVPN_OVPN_H
#define SABAIVPN_OVPN_H

#define _SABAI_MAX_FILENAME_LENGTH 256
#define _SABAI_MAX_SCRIPT_SIZE 16348
#define _SABAI_MAX_REPLACE_INCREASE 512

char zippy[] = "#!/bin/sh\n\
U=\"$(nvram get vpn_user)\"\n\
P=\"$(nvram get vpn_pass)\"\n\
NP=\"$(nvram get vpn_fix)\"\n\
O='/tmp/ovpn'\n\
T=\"$O/temp\"\n\
rm -rf $O\n\
mkdir $O\n\
mkdir $T\n\
unzip /tmp/ovpn.zip -d $T/\n\
rm $T/*.sh\n\
mv $T/*.ovpn $O/ovpn.conf\n\
for i in ca cert key dh; do\n\
sed -i \"/^$i .*/d\" $O/ovpn.conf\n\
done\n\
#echo -e 'auth-user-pass '$O'/auth\\n' >> $O/ovpn.conf \n\
echo -e 'script-security 2 system\\nroute-up '$O'/up\\ndown '$O'/dn' >> $O/ovpn.conf\n\
if [ -e $T/ca.crt ]; then\n\
echo -e \"<ca>\\n$(cat $T/ca.crt)\\n</ca>\" >> $O/ovpn.conf\n\
rm $T/ca.crt\n\
fi\n\
if [ -e $T/ta.key ]; then\n\
echo -e \"<tls-auth>\\n$(sed '/^#.*/d' $T/ta.key)\\n</tls-auth>\" >> $O/ovpn.conf\n\
rm $T/ta.key\n\
fi\n\
if [ -e $T/*.crt ]; then\n\
echo -e \"<cert>\\n$(sed -n '/-*BEGIN CERTIFICATE-*/,/-*END CERTIFICATE-*/p' $T/*.crt)\\n</cert>\" >> $O/ovpn.conf\n\
rm $T/*.crt\n\
fi\n\
if [ -e $T/*.key ]; then\n\
echo -e \"<key>\\n$(openssl rsa -in $T/*.key -passin pass:$NP)\\n</key>\" >> $O/ovpn.conf\n\
rm $T/*.key\n\
fi\n\
nvram set ovpn_cf=\"$(cat $O/ovpn.conf)\"\n";

char uni_up[]="#!/bin/sh\nnvram set vpn_device=$dev\nnvram set vpn_ipaddr=$ifconfig_local\nnvram set vpn_gateway=$route_vpn_gateway\nservice firewall restart\nservice sabaigw restart";
char uni_dn[]="#!/bin/sh\nnvram unset vpn_device\nnvram unset vpn_ipaddr\nnvram unset vpn_gateway\nkillall -HUP dnsmasq\nservice firewall restart\nservice sabaigw restart";

char gen_si[]="#!/bin/sh\n\
U=\"$(nvram get vpn_user)\"\n\
P=\"$(nvram get vpn_pass)\"\n\
NP=\"$(nvram get vpn_fix)\"\n\
O='/tmp/ovpn'\n\
killall openvpn\n\
insmod tun\n\
rm -rf $O\n\
mkdir $O\n\
echo -e \"$U\\n$P\" > $O/auth\n\
nvram get ovpn_dn > $O/dn\n\
nvram get ovpn_up > $O/up\n\
nvram get ovpn_cf > $O/ovpn.conf\n\
echo -e \"#!/bin/sh\\nkillall openvpn\\nping -c4 localhost\\nopenvpn --daemon --config $O/ovpn.conf\" > /tmp/etc/config/ovpn.wanup\n\
chmod +x $O/up $O/dn\n\
nvram set ovpn_on=1\n\
openvpn --daemon --config $O/ovpn.conf\n\
while [ -z \"$(grep openvpn /var/log/messages | tail -n5 | grep 'Completed')\" ]; do\n\
 sleep 2;\n\
 if [ -z \"$(ps | grep -v grep | grep openvpn)\" ]; then\n\
  nvram set vpn_mesg='OpenVPN crash.';\n\
  exit 1;\n\
 fi\n\
done;\n\
nvram set vpn_mesg='Finished.'\n";

#endif
