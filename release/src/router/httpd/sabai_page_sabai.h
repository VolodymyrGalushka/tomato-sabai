#ifndef SABAIVPN_PAGE_SABAI_H
#define SABAIVPN_PAGE_SABAI_H

	// sabai_ is the page served when the code is correct and the VPN service (nvram variable vpn_service) is set to 'Sabai'

char *sabai_sabai[] = {
"['VPN','sabaivpn', 0, [\n\
['PPTP',		'sabaivpn-pptp.asp'],\n\
['OpenVPN',		'sabaivpn-ovpn.asp'],\n\
//	['L2TP',		'sabaivpn-notyet.asp'],\n\
['Port Forwarding',	'forward-basic.asp'],\n\
['Dual Gateway',	'sabaivpn-dual.asp']\n\
] ]",
"// /* BEGIN SABAI PPTP JS */\n\
\n\
var actions=['start','stop','save'];\n\
function PPTPsave(act_num){\n\
 act=actions[act_num];\n\
 var fom = E('_fom');\n\
 pptp_args='&vpn_user='+ fom.vpn_user.value +'&vpn_pass='+ fom.vpn_pass.value +'&vpn_server='+ fom.vpn_server.value +'&pptp_mppe='+ (fom.pptp_mppe.checked?'1':'0') +'&pptp_stateful='+ (fom.pptp_stateful.checked?'1':'0');\n\
 PPTP_tog(act);\n\
}\n\
function init(){ hidden = E('hideme'); hide = E('hiddentext'); }\n\
// /* END SABAI PPTP JS */\n",
"<!-- BEGIN SABAI PPTP HTML -->\n\
\n\
<form id='_fom' method='post' action='tomato.cgi'>\n\
<div id='PPTPSettingsPage' class=''>\n\
<div class='section-title'>PPTP basic settings</div><div class='section'><script type='text/javascript'>\n\
// /*{ title: 'Enable PPTP', name: 'f_pptp_on', type: 'checkbox', value: nvram.pptp_on!='0' }, */\n\
createFieldTable('', [\n\
{ title: 'Server', name: 'vpn_server', maxlen:64, size:66, type: 'text', value: nvram.vpn_server },\n\
{ title: 'Username', name: 'vpn_user', maxlen:64, size:66, type: 'text', value: nvram.vpn_user },\n\
{ title: 'Password', name: 'vpn_pass', maxlen:64, size:66, type: 'password', peekaboo: 1, value: nvram.vpn_pass },\n\
{ title: 'Require MPPE-128', name: 'pptp_mppe', type: 'checkbox', value: nvram.pptp_mppe!='0' },\n\
{ title: 'MPPE-Stateful', name: 'pptp_stateful', type: 'checkbox', value: nvram.pptp_stateful!='0' }\n\
]); //</script></div>\n\
<div class='section-title hiddenChildMenu'>PPTP advanced settings</div><div class='section hiddenChildMenu'><script type='text/javascript'>\n\
createFieldTable('', [\n\
{ title: 'Domain', name: 'pptp_domain', maxlen:64, size:66, type: 'text', value: nvram.pptp_domain },\n\
{ title: 'Options', name: 'pptp_options', maxlen:64, size:66, type: 'text', value: nvram.pptp_options },\n\
{ title: 'Use Default Gateway on Remote Network', name: 'f_pptp_defgw', type: 'checkbox', value: nvram.pptp_defgw!='0' },\n\
{ title: 'Add subnets', name: 'pptp_subnets', maxlen:64, size:66, type: 'text', value: nvram.pptp_subnets }\n\
]); //</script></div>\n\
\n\
<div>\n\
<input type='button' value='Start' onclick='PPTPsave(0)'>\n\
<input type='button' value='Stop' onclick='PPTPsave(1)'>\n\
<input type='button' value='Save' onclick='PPTPsave(2)'>\n\
<input type='button' value='Cancel' onclick='javascript:reloadPage();'>\n\
<input type='button' value='Help' onclick='window.open(\"http://www.sabaitechnology.com/v/sabaiHelp/help.html#pptp\",\"_newtab\");'><br>\n\
<table><tbody><tr><td id='footer' colspan=2><span id='footer-msg'></span></td></tr></tbody></table></div></div></form>\n\
\n\
<!-- END SABAI PPTP HTML -->\n\
",
"// /* BEGIN SABAI OVPN JS */\n\
\n\
var hidden; var ovpn_settings = ['ovpn_cf','ovpn_up','ovpn_dn','ovpn_si'];\n\
\n\
function init(){\n\
E('current_ovpn_script').innerHTML += (nvram.ovpn_file||'None');\n\
if( nvram.ovpn_file == '' ){ E('script-upload').className=''; }else{ parseOvpnScript(); }\n\
hidden = E('hideme'); hide = E('hiddentext');\n\
}\n\
// BEGIN	OVPN SCRIPT PROCESSING\n\
\n\
function diffScripts(){ var diffi = 0; for(var i=0; i<ovpn_settings.length; i++){ diffi += (ovpn_diff[ovpn_settings[i]] ? 1 : 0 ); }; return diffi; }\n\
function encodescripts(){\n\
 var elem_up = E('ta_ovpn_up'); var elem_si = E('ta_ovpn_si'); var old_up = elem_up.value; var old_si = elem_si.value;\n\
 var enc = '';\n\
 if(diffScripts()>0){\n\
  for(var i=0; i<ovpn_settings.length; i++){\n\
   var process = E('ta_'+ovpn_settings[i]).value;\n\
   if( (ovpn_diff[ovpn_settings[i]]) || (nvram[ovpn_settings[i]] == '') ){\n\
    enc += ovpn_settings[i] +'='+ escapeCGI(process) +'&';\n\
   }\n\
  }\n\
 }\n\
 return enc;\n\
}\n\
\n\
function OVPNisDiff(event){ ovpn_diff[event.target.id.substr(3)] = (event.target.defaultValue != event.target.value); }\n\
\n\
function parseOvpnScript(){\n\
 for(var i=0; i<ovpn_settings.length; i++){\n\
 var el = E('ta_'+ovpn_settings[i]);\n\
  el.value = el.defaultValue = nvram[ovpn_settings[i]];\n\
  var ro = (el.value.match(/\\n/g)||'').length;\n\
  el.rows = (ro>15) ? 15 : (ro<5 ? 5 : ro);\n\
  el.onchange = OVPNisDiff;\n\
 }\n\
}\n\
\n\
// END		OVPN OVPN SCRIPT PROCESSING\n\
// BEGIN	OVPN UI FUNCTIONS\n\
function exte_show(event){\n\
 for(var i=0; i<exte_list.length; i++){ E('exte_'+exte_list[i]+'_area').className='hiddenChildMenu'; E('exte_'+exte_list[i]+'_button').className='VPN_tab_off'; }\n\
 E( 'exte_'+event.target.id.slice(5,-7)+'_area' ).className = '';\n\
 event.target.className = 'VPN_tab_on';\n\
}\n\
\n\
function toggleUpload(){\n\
 var newbut = E('newscript-button'); var scrupl = E('script-upload'); //.className='';\n\
 if( newbut.value == 'New Script' ){ newbut.value = 'Hide Upload Menu'; scrupl.className = ''; }else{ newbut.value = 'New Script'; scrupl.className = 'hiddenChildMenu'; }\n\
}\n\
\n\
function toggleOptions(){\n\
 var extbut = E('OVPN_extended_button'); var extended = E('OVPN_extended');\n\
 switch(extbut.value){\n\
  case 'Options' : { extended.className = ''; extbut.value = 'Hide Options'; break; }\n\
  case 'Hide Options' : { extended.className = 'hiddenChildMenu'; extbut.value = 'Options'; break; }\n\
 }\n\
}\n\
\n\
function toggleMan(){ var eman = E('exte_man'); var egen = E('exte_gen'); egen.className = 'hiddenChildMenu'; eman.className = ''; }\n\
function toggleGen(){ var eman = E('exte_man'); var egen = E('exte_gen'); egen.className = ''; eman.className = 'hiddenChildMenu'; }\n\
\n\
function generateOVPN(){\n\
 var conf = E('ta_gen_cfg').value;\n\
 var adds = [ E('ta_gen_cacrt').value, E('ta_gen_clientcrt').value, E('ta_gen_takey').value, E('ta_gen_clientkey').value ];\n\
 var wrap = ['ca','cert','tls-auth','key'];\n\
 for(var i=0; i<adds.length; i++){ conf+= '\\n<' +wrap[i]+ '>\\n' +adds[i]+ '\\n</' +wrap[i]+ '>'; }\n\
 conf.replace(/^\\n$/g,'')\n\
 E('ta_ovpn_cf').value = conf; ovpn_diff.ovpn_cf=true;\n\
 toggleMan();\n\
}\n\
\n\
// END		OVPN UI FUNCTIONS\n\
// /* END SABAI OVPN JS */\n",
"<!-- BEGIN SABAI OVPN HTML -->\n\
\n\
<div id='OVPNSettingsPage' class=''>\n\
\n\
<div class='section-title'>OpenVPN Setup</div><div class='section'>\n\
<div id='current_ovpn_script' className=''>Current File: </div><br>\n\
<div id='script-upload' class='hiddenChildMenu'>\n\
<form id='newscript' method='post' action='s_grabovpn.cgi' encType='multipart/form-data'>\n\
<input type='file' id='testscript' name='file' onchange='changeScript();' size='50' style='height:20px'>\n\
<br><br>\n\
You may supply an OpenVPN DD-WRT script, a zip file (containing ca.crt, client.crt, ta.key, client.key, config.ovpn), or a complete .conf or .ovpn.\n\
</form>\n\
</div>\n\
<form id='ovpn_setup'>\n\
<input type='button' value='Start' id='start-button' onclick='startovpn();' style='height:20px'>\n\
<input type='button' value='Stop' id='stop-button' onclick='stopovpn();' style='height:20px'>\n\
<input type='button' value='New Script' id='newscript-button' onclick='toggleUpload();' style='height:20px'>\n\
<input type='button' value='Erase Script' id='erase-button' onclick='eraseovpn();' style='height:20px'>\n\
<input type='button' value='Options' id='OVPN_extended_button' onclick='toggleOptions();' style='height:20px'>\n\
<input type='button' value='Help' onclick='window.open(\"http://www.sabaitechnology.com/v/sabaiHelp/help.html#ovpn\",\"_newtab\");' style='height:20px'>\n\
\n\
<span id='OVPN_extended' class='hiddenChildMenu'>\n\
<input type='button' value='Manual Script' id='manScript_button' onclick='toggleMan();' style='height:20px'>\n\
<input type='button' value='Generate Script' id='genScript_button' onclick='toggleGen()' style='height:20px'>\n\
<br><br>\n\
<!--<input id='check_fallback' type='checkbox'> Fallback to local connection. <input id='check_generic_updown' type='checkbox'> Use generic Up/Down scripts. -->\n\
<div id='exte_man' class='hiddenChildMenu'>\n\
<input type='button' value='Save Script Changes' id='changescript_button' onclick='savescriptchanges();' style='height:20px'><br>\n\
<br>OpenVPN Configuration<br><textarea id='ta_ovpn_cf'></textarea>\n\
<br>Up Script*<br><textarea id='ta_ovpn_up'></textarea>\n\
<br>Down Script*<br><textarea id='ta_ovpn_dn'></textarea>\n\
<br>Boot Script*<br><textarea id='ta_ovpn_si'></textarea>\n\
(* Defaults to generic if empty.)\n\
</div>\n\
\n\
<div id='exte_gen' class='hiddenChildMenu'>\n\
<input type='button' value='Generate Script' id='genscript_button' onclick='generateOVPN();' style='height:20px'><br>\n\
<br>OpenVPN Configuration<br><textarea id='ta_gen_cfg' rows='10'></textarea>\n\
<br>CA Certificate<br><textarea id='ta_gen_cacrt' rows='10'></textarea>\n\
<br>Client Certificate<br><textarea id='ta_gen_clientcrt' rows='10'></textarea>\n\
<br>TA Key<br><textarea id='ta_gen_takey' rows='10'></textarea>\n\
<br>Client Key<br><textarea id='ta_gen_clientkey' rows='10'></textarea>\n\
</div>\n\
\n\
</span>\n\
\n\
</div></div>\n\
</form></div>\n\
<br>\n\
</div>\n\
\n\
<!-- END SABAI OVPN HTML -->\n" };

#endif
