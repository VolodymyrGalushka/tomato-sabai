#ifndef SABAIVPN_PAGE_VYPR_H
#define SABAIVPN_PAGE_VYPR_H

	// vypr_ is the page served when the code is correct and the VPN service (nvram variable vpn_service) is set to 'Vypr'
char *sabai_vypr[] = {
"['VyprVPN','sabaivpn', 0, [\n\
['VPN',			'sabaivpn-vypr.asp'],\n\
['Port Forwarding',	'forward-basic.asp'],\n\
['Dual Gateway',	'sabaivpn-dual.asp']\n\
] ]",
"// /* BEGIN VYPR JS */\n\
var vf;\n\
\n\
function OVPNsave(act){ var arg = (pptp_args!=''); var ovpn = (nvram.ovpn_on==1);\n\
 switch(act){\n\
  case 1: { if( !ovpn||arg ){ hideUi('Starting VyprVPN.'); que.drop('./s_vypr.cgi', showUi, 'fire=start' +pptp_args+'&_http_id='+nvram.http_id ); }; break; }\n\
  case 2: { if(  ovpn||arg ){ hideUi('Stopping VyprVPN.'); que.drop('./s_vypr.cgi', showUi, 'fire=stop'  +pptp_args+'&_http_id='+nvram.http_id ); }; break; }\n\
  case 3: { if(  ovpn||arg ){ hideUi('Updating VyprVPN.'); que.drop('./s_vypr.cgi', showUi, 'fire=update'+pptp_args+'&_http_id='+nvram.http_id ); }; break; }\n\
 }\n\
}\n\
\n\
function PPTPsave(act){ var pr = (nvram.pptp_on==1); var arg = (pptp_args!='');\n\
 switch(act){\n\
  case 1:{ if(pr){ if(arg){ PPTP_tog('restart'); } }else{ PPTP_tog('start'); }; break; }\n\
  case 2:{ if(!pr){ if(arg){ PPTP_tog('update'); } }else{ PPTP_tog('stop'); }; break; }\n\
  case 3:{ if(arg){ PPTP_tog('update'); }; break; }\n\
 }\n\
}\n\
\n\
function Vyprsave(act){\n\
 pptp_args =\n\
 ( (nvram.vpn_user==vf.vpn_user.value) ? '' : ('&vpn_user='+vf.vpn_user.value) ) + \n\
 ( (nvram.vpn_pass==vf.vpn_pass.value) ? '' : ('&vpn_pass='+vf.vpn_pass.value) ) + \n\
 ( (nvram.vpn_server==vf.vpn_server.value) ? '' : ('&vpn_server='+vf.vpn_server.value) ) +\n\
 ( (nvram.vpn_type==vf.vpn_type.value) ? '' : ('&vpn_type='+vf.vpn_type.value) );\n\
 vf.vpntype=='p'?PPTPsave(act):OVPNsave(act);\n\
}\n\
function init(){ hidden=E('hideme'); hide=E('hiddentext'); vf=E('_fom'); }\n\
// /* END VYPR JS */\n",
"<!-- BEGIN VYPR HTML -->\n\
\n\
<form id='_fom'>\n\
<div id='PPTPSettingsPage' class=''><div class='section-title'>VyprVPN Setup</div><img id='vyprlogo' src='VyprGoldenfrog_logo.png'><div class='section'>\n\
<script type='text/javascript'>\n\
createFieldTable('', [\n\
{ title: 'Server', name: 'vpn_server', maxlen:64, size:66, type: 'text', value: nvram.vpn_server },\n\
{ title: 'Username', name: 'vpn_user', maxlen:64, size:66, type: 'text', value: nvram.vpn_user },\n\
{ title: 'Password', name: 'vpn_pass', maxlen:64, size:66, type: 'password', peekaboo: 1, value: nvram.vpn_pass },\n\
{ title: 'Connection Type', name: 'vpn_type', type: 'select', options: [ ['p','PPTP'],['o','OpenVPN'],['s','Secure OpenVPN'] ], value: nvram.vpn_type },\n\
]); //</script></div>\n\
\n\
<div>\n\
<input type='button' value='Start' onclick='Vyprsave(1)'>\n\
<input type='button' value='Stop' onclick='Vyprsave(2)'>\n\
<input type='button' value='Save' onclick='Vyprsave(3)'>\n\
<input type='button' value='Cancel' onclick='javascript:reloadPage();'>\n\
<input type='button' value='Help' onclick='window.open(\"http://www.sabaitechnology.com/v/sabaiHelp/help.html#pptp\",'_newtab');'><br>\n\
<table><tbody><tr><td id='footer' colspan=2><span id='footer-msg'></span></td></tr></tbody></table></div></div></form>\n\
\n\
<!-- END VYPR HTML -->"};

#endif
