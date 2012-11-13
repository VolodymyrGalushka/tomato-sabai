#ifndef SABAIVPN_PAGE_HMA_H
#define SABAIVPN_PAGE_HMA_H

	// sabai_ is the page served when the code is correct and the VPN service (nvram variable vpn_service) is set to 'Sabai'

char *sabai_hma[] = {
"['HMA VPN','sabaivpn', 0, [\n\
	['VPN',			'sabaivpn-hma.asp'],\n\
	['Port Forwarding',	'forward-basic.asp'],\n\
	['Dual Gateway',	'sabaivpn-dual.asp']\n\
] ]","// /* BEGIN HMA JS */\n\
var fom, hmaServers, vsf;\n\
function HMAerr(_msg){ E('footer-msg').innerHTML=_msg; E('footer-msg').style.visibility='visible'; }\n\
function getHMAStatus(){ que.drop('hma.sh',setHMAStatus,'status'); }\n\
function setHMAStatus(text){ E('ovpn_log').innerHTML = text; }\n\
function toggleLog(){ var cur = E('ovpn_status'); var but = E('ovpn_status_toggle'); cur.style.display = (cur.style.display=='none' ? '' : 'none'); but.value = (but.value=='View Log' ? 'Hide Log' : 'View Log'); }\n\
function getHMAServers(renew){ window.hidden_working=true; hideUi('Please wait while we check available servers.'); que.drop('hma.sh',setHMAServers, (renew?'re':'')+'list' ); }\n\
function setHMAServers(list){ hmaError=false; window.hidden_working=false; hidden.style.display = 'none'; eval(list); list='';\n\
 if(hmaError){ HMAerr(hmaError); return; };\n\
 for(var i=0; i<hmaServers.length; i++){ list+='<option value=\"'+ i +'\"'+ (hmaServers[i].ip==nvram.vpn_server?' selected':'') +'>'+hmaServers[i].name+'</option>\\n'; }\n\
 vsf.innerHTML=list;\n\
 fom['vpn_proto'][ nvram.vpn_proto=='tcp'?0:1 ].checked=true; verifyFields(); if(nvram.ovpn_on=='1') getHMAStatus();\n\
}\n\
function VPNsave(act){ if(fom.vpn_type.value=='PPTP'){ PPTPsave(act); }else{ OVPNsave(act); } }\n\
function PPTPsave(act){ vpn_server=hmaServers[fom.vpn_server.value].ip;\n\
 pptp_args=\n\
 ( (nvram.vpn_user==fom.vpn_user.value) ? '' : ('&vpn_user='+fom.vpn_user.value) ) + \n\
 ( (nvram.vpn_pass==fom.vpn_pass.value) ? '' : ('&vpn_pass='+fom.vpn_pass.value) ) + \n\
 ( (nvram.vpn_server==vpn_server) ? '' : ('&vpn_server='+vpn_server) );\n\
 var pr = (nvram.pptp_on==1); var arg = (pptp_args!='');\n\
 switch(act){\n\
  case 'start':{ if(pr){ if(arg){ PPTP_tog('restart'); } }else{ PPTP_tog('start'); }; break; }\n\
  case 'update':{ if(!pr){ if(arg){ PPTP_tog('update'); } }else{ PPTP_tog('stop'); }; break; }\n\
  case 'stop':{ PPTP_tog('stop'); break; }\n\
  case 'clear':{ PPTP_tog('stop'); break; }\n\
 }\n\
}\n\
function OVPNsave(act){\n\
 var fom = E('_fom');\n\
 vpn_server=hmaServers[fom.vpn_server.value]; var proto=fom['vpn_proto'][1].checked?'udp':'tcp';\n\
 if(fom.vpn_user.value=='' || fom.vpn_fix.value==''){ HMAerr('Please enter your HMA username and password to proceed.'); return; }\n\
 ovpn_args = act+' '+fom.vpn_user.value+' '+fom.vpn_fix.value+' '+vpn_server.ip+' '+proto+' '+vpn_server[proto];\n\
 hideUi('Please wait while we adjust your HMA settings.');\n\
 que.drop('hma.sh',showUi,ovpn_args);\n\
}\n\
function verifyFields(){\n\
 var lastVPN = E('_vpn_type').value; cookie.set('_lastVPN',lastVPN,30);\n\
 E('_vpn_pass').parentNode.parentNode.style.display = ( lastVPN=='PPTP' ? '' : 'none' );\n\
 ovpn_dis=( lastVPN=='OVPN' ? '' : 'none' );\n\
 E('_vpn_fix').parentNode.parentNode.style.display=ovpn_dis;\n\
 E('_vpn_proto').style.display=ovpn_dis;\n\
 E('ovpn_status_toggle').style.display=ovpn_dis;\n\
 if(nvram.ovpn_on==1){ E('startButton').value='Restart'; }\n\
 if(hmaServers!=undefined){\n\
  if(fom['vpn_proto'][1].checked && hmaServers[fom.vpn_server.value]['udp']==0) fom['vpn_proto'][0].checked='true';\n\
  fom['vpn_proto'][0].disabled=hmaServers[fom.vpn_server.value]['tcp']==0?true:false;\n\
  fom['vpn_proto'][1].disabled=hmaServers[fom.vpn_server.value]['udp']==0?true:false;\n\
 }\n\
}\n\
function init(){ hidden = E('hideme'); hide = E('hiddentext'); fom = E('_fom'); vsf=E('_vpn_server'); getHMAServers(); }\n\
// /* END HMA JS */\n","<!-- BEGIN HMA HTML -->\n\
<!-- span id='SVPNstatus'><span style='display: none;' id='subversion'></span></span -->\n\
<form id='_fom' method='post' action='tomato.cgi'>\n\
<div id='OVPNSettingsPage' class=''>\n\
<div class='section-title'>HMA Settings</div><div class='section'><script type='text/javascript'>\n\
createFieldTable('', [\n\
{ title: 'Username', name: 'vpn_user', maxlen:64, size:66, type: 'text', value: nvram.vpn_user },\n\
{ title: 'PPTP Password*', name: 'vpn_pass', maxlen:64, size:66, type: 'password', peekaboo: 1, value: nvram.vpn_pass },\n\
{ title: 'Password*', name: 'vpn_fix', maxlen:64, size:66, type: 'password', peekaboo: 1, value: nvram.vpn_fix },\n\
{ title: 'VPN type', name: 'vpn_type', type: 'select', options: [['PPTP','PPTP'],['OVPN','OpenVPN']],\n\
value: (nvram.pptp_on==1 ? 'PPTP' : (nvram.ovpn_on==1 ? 'OVPN' : cookie.get('_lastVPN') ) )\n\
},\n\
{ title: 'Server (protocol)', name: 'vpn_server', type: 'select', options: [], value: nvram.vpn_server,\n\
 suffix: \"<span id='_vpn_proto'> TCP <input type='radio' name='vpn_proto' value='tcp' class='proto' onchange='verifyFields();'> UDP <input type='radio' name='vpn_proto' value='udp' class='proto' onchange='verifyFields();'></span>\"\n\
}\n\
]); //</script>\n\
\n\
<input type='button' value='Start' onclick='VPNsave(\"start\")' id='startButton'>\n\
<input type='button' value='Stop' onclick='VPNsave(\"stop\")'>\n\
<input type='button' value='Save' onclick='VPNsave(\"save\")'>\n\
<input type='button' value='Cancel' onclick='javascript:reloadPage();'>\n\
<input type='button' value='Update' onclick='getHMAServers(true);'>\n\
<input id='ovpn_status_toggle' type='button' value='View Log' onclick='toggleLog();'><br><br>\n\
<span style='font: 12px sans-serif;'>*Please note that PPTP passwords may be found on the PPTP Servers page of your HMA account.<br>(Your OpenVPN password is your HMA account password.)</span>\n\
<br><span id='footer-msg'></span>\n\
<table><tbody><tr><td id='footer'></td></tr></tbody></table>\n\
<span id='ovpn_status' style='display: none;'>\n\
<input type='button' value='Refresh' onclick='getHMAStatus();'>\n\
<textarea id='ovpn_log' rows=20 style='width: 100%;'>  OpenVPN does not currently appear to be running; click Refresh to check the log.</textarea>\n\
</span>\n\
</div></div></form>\n\
<!-- END HMA HTML -->"};



#endif
