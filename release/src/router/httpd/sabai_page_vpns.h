#ifndef SABAIVPN_PAGE_VPNS_H
#define SABAIVPN_PAGE_VPNS_H

	// vpns_ is the page served when the code is correct and the VPN service (nvram variable vpn_service) is set to 'VPNS'
char *sabai_vpns[] = {
"['VPNSecure','sabaivpn', 0, [\n\
['VPN',			'sabaivpn-vpns.asp'],\n\
['Port Forwarding',	'forward-basic.asp'],\n\
['Dual Gateway',	'sabaivpn-dual.asp']\n\
] ]",
"// BEGIN VPNS JS\n\
var slist = ''; var vf;\n\
\n\
function displayVPNSServerList(rl){ if(rl==null || rl==undefined || rl==''){ return; }; rl = rl.split(';');\n\
 var serverOpts=E('_vpn_server'); serverOpts.innerHTML='';\n\
 for(var i=0; i<rl.length; i++){ rl[i] = rl[i].split('|'); serverOpts.innerHTML+='<option value=\"'+i+'\"'+ (i==nvram.vpn_server ? 'selected' : '') +'>'+ rl[i][0] +'</option>'; };\n\
 slist = rl;\n\
}\n\
\n\
function grabVPNSServerList(newlist){\n\
 if(vf.vpn_user.value.length==0){ alert('Please supply your VPNsecure username in order to list available servers.'); return; }\n\
 que.drop('s_vpns.cgi', displayVPNSServerList, 'fire=list&vpn_user='+vf.vpn_user.value+'&_http_id='+nvram.http_id )\n\
}\n\
\n\
function vpnsMesg(resp){\n\
 E('vpnsstatus').innerHTML = resp.replace(/\\n/g,'<br>');\n\
 if(resp.search('complete')==-1){ setTimeout(vpnsStat,3000); }else{\n\
  redo_VPN_stats();\n\
 }\n\
}\n\
\n\
function vpns(act){\n\
 var vu = E('_vpn_user').value; var vp = E('_vpn_pass').value; var vs = E('_vpn_server').value; var vf = E('_vpn_fix').value\n\
 var args= ( ( nvram.vpn_user == vu ) ? '' : '&vpn_user='+vu ) + ( ( nvram.vpn_pass == vp ) ? '' : '&vpn_pass='+vp ) + ( ( nvram.vpn_server == vs ) ? '' : '&vpn_server='+vs ) + ( ( nvram.vpn_fix == vf ) ? '' : '&vpn_fix='+vf );\n\
 var arg = (args.length>0); var ovpn = (nvram.ovpn_on==1);\n\
 switch(act){\n\
  case 1: { if( !ovpn||arg ){ hideUi('Starting VPNSecure.'); que.drop('./s_vpns.cgi', showUi, 'fire=start' +args+'&_http_id='+nvram.http_id ); }; break; }\n\
  case 2: { if(  ovpn||arg ){ hideUi('Stopping VPNSecure.'); que.drop('./s_vpns.cgi', showUi, 'fire=stop'  +args+'&_http_id='+nvram.http_id ); }; break; }\n\
  case 3: { if(  ovpn||arg ){ hideUi('Updating VPNSecure.'); que.drop('./s_vpns.cgi', showUi, 'fire=update'+args+'&_http_id='+nvram.http_id ); }; break; }\n\
 }\n\
}\n\
\n\
function init(){ vf=E('vpns_form'); hidden = E('hideme'); hide = E('hiddentext'); displayVPNSServerList(nvram.vpns_serverlist); }\n\
\n\
// END VPNS JS\n",
"<!-- BEGIN VPNS HTML -->\n\
\n\
<form id='vpns_form'>\n\
<div class='section-title'>VPNSecure</div>\n\
<div class='section'><script type='text/javascript'>\n\
createFieldTable('', [\n\
{ title: 'Username', name: 'vpn_user', maxlen:64, size:66, type: 'text', value: nvram.vpn_user },\n\
{ title: 'Password', name: 'vpn_pass', maxlen:64, size:66, type: 'password', peekaboo: 1, value: nvram.vpn_pass },\n\
{ title: 'Key Password', name: 'vpn_fix', maxlen:64, size:66, type: 'password', peekaboo: 1, value: nvram.vpn_fix },\n\
{ title: 'Server', name: 'vpn_server', type: 'select',\n\
options: [[,'Click->']],\n\
value: ( 0 ), suffix: '<input id=\"req_server_list\" type=\"button\" style=\"height:20px\" onclick=\"grabVPNSServerList();\" value=\"Relist\">'\n\
},\n\
]);//</script></div>\n\
<div class='section-title hiddenChildMenu'>PPTP advanced settings</div><div class='section hiddenChildMenu'><script type='text/javascript'>\n\
createFieldTable('', [\n\
{ title: 'Domain', name: 'pptp_domain', maxlen:64, size:66, type: 'text', value: nvram.pptp_domain },\n\
{ title: 'Options', name: 'pptp_options', maxlen:64, size:66, type: 'text', value: nvram.options },\n\
{ title: 'Use Default Gateway on Remote Network', name: 'f_pptp_defgw', type: 'checkbox', value: nvram.pptp_defgw!='0' },\n\
{ title: 'Add subnets', name: 'pptp_subnets', maxlen:64, size:66, type: 'text', value: nvram.pptp_subnets }\n\
]); //</script></div>\n\
<input type='button' value='Start' onclick='vpns(1);' style='height:20px'>\n\
<input type='button' value='Stop' onclick='vpns(2);' style='height:20px'>\n\
<input type='button' value='Save' onclick='vpns(3);' style='height:20px'>\n\
<input type='button' value='Cancel' onclick='window.location.reload();' style='height:20px'></form>\n\
<br><div id='vpnsstatus' />\n\
\n\
<!-- END VPNS HTML -->\n"};

#endif
