#ifndef SABAIVPN_PAGE_SABAI_H
#define SABAIVPN_PAGE_SABAI_H

	// sabai_ is the page served when the code is correct and the VPN service (nvram variable vpn_service) is set to 'Sabai'
char sabai_menu[] = "['SabaiVPN','sabaivpn', 0, [\n\
['PPTP',		'sabaivpn-pptp.asp'],\n\
['OpenVPN',		'sabaivpn-ovpn.asp'],\n\
//	['L2TP',		'sabaivpn-notyet.asp'],\n\
['Port Forwarding',	'forward-basic.asp'],\n\
['Dual Gateway',	'sabaivpn-dual.asp']\n\
] ]";

char sabai_astrill_menu[] = "(function(){ if(myName()=='astrill.cgi'){ E('header').parentNode.removeChild(E('header')); } })\
['AstrillVPN','sabaivpn', 0, [\n\
['VPN',			'ext/cgi-bin/astrill.cgi'],\n\
['Setup',		'sabaivpn-astrill.asp'],\n\
['Port Forwarding',	'forward-basic.asp'],\n\
['Dual Gateway',	'sabaivpn-dual.asp']\n\
] ]";

char sabai_pptp_js[] = "// /* BEGIN SABAI PPTP JS */\n\
\n\
function PPTPsave(act){\n\
 var fom = E('_fom');\n\
 var opt_mppe = ( fom.pptp_mppe.checked ? '1' : '0' ); var opt_stateful = ( fom.pptp_stateful.checked ? '1' : '0' );\n\
 pptp_args = \n\
 ( (nvram.vpn_user==fom.vpn_user.value) ? '' : ('&vpn_user='+fom.vpn_user.value) ) + \n\
 ( (nvram.vpn_pass==fom.vpn_pass.value) ? '' : ('&vpn_pass='+fom.vpn_pass.value) ) + \n\
 ( (nvram.vpn_server==fom.vpn_server.value) ? '' : ('&vpn_server='+fom.vpn_server.value) ) + \n\
 ( (nvram.pptp_mppe==opt_mppe) ? '' : ('&pptp_mppe='+opt_mppe) ) + \n\
 ( (nvram.pptp_stateful==opt_stateful) ? '' : ('&pptp_stateful='+opt_stateful) );\n\
\n\
 var pr = (nvram.pptp_running==1);\n\
 var arg = (pptp_args!='');\n\
\n\
 switch(act){\n\
  case 1:{\n\
   if(pr){ if(arg){ PPTP_tog('restart'); } }else{ PPTP_tog('start'); }\n\
   break;\n\
  }\n\
  case 2:{\n\
   if(!pr){ if(arg){ PPTP_tog('update'); } }else{ PPTP_tog('stop'); }\n\
   break;\n\
  }\n\
  case 3:{\n\
   if(arg){ PPTP_tog('update'); }\n\
   break;\n\
  }\n\
 }\n\
}\n\
function init(){\n\
hidden = E('hideme'); hide = E('hiddentext');\n\
}\n\
// /* END SABAI PPTP JS */\n";

char sabai_pptp_html[] = "<!-- BEGIN SABAI PPTP HTML -->\n\
\n\
<form id='_fom' method='post' action='tomato.cgi'>\n\
<div id='PPTPSettingsPage' class=''>\n\
<div class='section-title'>PPTP basic settings</div><div class='section'><script type='text/javascript'>\n\
// /*{ title: 'Enable PPTP', name: 'f_pptp_running', type: 'checkbox', value: nvram.pptp_running!='0' }, */\n\
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
<div><table><tbody><tr>\n\
<td><input type='button' value='Start' onclick='PPTPsave(1)'></td>\n\
<td><input type='button' value='Stop' onclick='PPTPsave(2)'></td>\n\
<td><input type='button' value='Save' onclick='PPTPsave(3)'></td>\n\
<td><input type='button' value='Cancel' onclick='javascript:reloadPage();'></td>\n\
</tr><tr><td id='footer' colspan=2><span id='footer-msg'></span></td></tr></tbody></table></div></div></form>\n\
\n\
<!-- END SABAI PPTP HTML -->\n\
";

char sabai_ovpn_js[] = "// /* BEGIN SABAI OVPN JS */\n\
\n\
var hidden;\n\
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
  var ro = el.value.match(/\\n/g).length;\n\
  el.rows = (ro>15) ? 15 : ro;\n\
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
 E('ta_ovpn_cf').value = conf; E('ta_ovpn_up').value = def_ovpn_up; E('ta_ovpn_dn').value = def_ovpn_dn;\n\
 ovpn_diff.ovpn_cf=true; ovpn_diff.ovpn_up=true; ovpn_diff.ovpn_up=true;\n\
 toggleMan();\n\
}\n\
\n\
// END		OVPN UI FUNCTIONS\n\
// /* END SABAI OVPN JS */\n";

char sabai_ovpn_html[] = "<!-- BEGIN SABAI OVPN HTML -->\n\
\n\
<div id='OVPNSettingsPage' class=''>\n\
\n\
<div class='section-title'>OpenVPN Setup</div><div class='section'>\n\
<div id='current_ovpn_script' className=''>Current File: </div><br>\n\
<div id='script-upload' class='hiddenChildMenu'>\n\
<form id='newscript' method='post' action='s_grabovpn.cgi' encType='multipart/form-data'>\n\
<input type='file' id='testscript' name='file' onchange='changeScript();' size='50' style='height:20px'>\n\
<br><br>\n\
You may supply an OpenVPN DD-WRT style script or a zip file containing your configuration files (ca.crt, client.crt, ta.key, client.key, config.ovpn).\n\
</form>\n\
</div>\n\
<form id='ovpn_setup'>\n\
<input type='button' value='Start' id='start-button' onclick='startovpn();' style='height:20px'>\n\
<input type='button' value='Stop' id='stop-button' onclick='stopovpn();' style='height:20px'>\n\
<input type='button' value='New Script' id='newscript-button' onclick='toggleUpload();' style='height:20px'>\n\
<input type='button' value='Erase Script' id='erase-button' onclick='eraseovpn();' style='height:20px'>\n\
<input type='button' value='Options' id='OVPN_extended_button' onclick='toggleOptions();' style='height:20px'>\n\
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
<!-- END SABAI OVPN HTML -->\n";

char sabai_dual_js[] = "// /* BEGIN DUAL GATEWAY JS */\n\
\n\
var list = []; var statics=''; var shreq=''; var hidden, hide, vg, va, str_vg, str_va;\n\
var d_startip, d_start, d_end, d_num;\n\
\n\
function say(text){ E('messages').appendChild( document.createTextNode(text) ); }\n\
function add(type){ E('messages').appendChild( document.createElement(type) ); }\n\
\n\
function group_insert(gr,ad){ var loc = gr.indexOf(ad); if(loc==-1){ gr.push(ad); } }\n\
function group_extract(gr,ad){ var loc = gr.indexOf(ad); if(loc!=-1){ gr.splice(loc,1); } }\n\
function group_pack(gr){ return gr.join(' ').replace(ipp,'').replace(/^\\s+|\\s+$/g,''); }\n\
\n\
function saveGroups(){\n\
 str_vg=group_pack(vg); str_va=group_pack(va);\n\
 hideUi('Please wait while we adjust your router.');\n\
 s_req('./tomato.cgi', showUi ,'vpn_group_vpn='+str_vg+'&vpn_group_accel='+str_va+'&_http_id='+nvram.http_id);\n\
}\n\
\n\
function addToRoute(event,li){\n\
 var groups=[[],vg,va]; var fro = list[li].vpnroute; var to = event.target.value;\n\
 list[li].vpnroute=to; group_extract(groups[fro],list[li].ipp); group_insert(groups[to],list[li].ipp);\n\
 str_vg=group_pack(vg); str_va=group_pack(va);\n\
 E('save-button').disabled='true'; E('refresh-button').disabled='true';\n\
 s_req('./gw.sh',\n\
  function(){\n\
   E('save-button').disabled='';\n\
   E('refresh-button').disabled='';\n\
   refreshList();\n\
 },'add,'+list[li].ip+','+fro+','+to+','+str_vg+','+str_va );\n\
}\n\
\n\
function makeStatic(event,li){ li=list[li];\n\
 var ips=[];\n\
 var stp=( (nvram.dhcp_start!='') ? parseInt( nvram.dhcp_start ,10) : parseInt( nvram.dhcpd_startip.substring( nvram.dhcpd_startip.lastIndexOf('.') +1) ,10) );\n\
 var fip=( (nvram.dhcp_num!='') ? (stp+parseInt( nvram.dhcp_num ,10)) : parseInt( nvram.dhcpd_endip.substring( nvram.dhcpd_endip.lastIndexOf('.')+1 ) ,10) );\n\
 for(var i=0; i<list.length; i++){ ips[i]=parseInt(list[i].ipp,10); }\n\
 var np=200;\n\
 while( (np<254)&&(ips.indexOf(np)!=-1) ){ np++; if( (np>=stp)&&(np<=fip) ){ np=fip+1; } }\n\
 if(np==255){ alert('You have no spare ip addresses.  Please reduce the DHCP pool, disconnect some devices, or introduce another router.  Contact technical support for details.'); return; }\n\
 var static_newlist=nvram.dhcpd_static+[li.mac, ipp+np, li.name].join('<')+'>';\n\
 hideUi('Please wait while we adjust your DHCP settings.');\n\
 s_req('s_static.cgi',showUi,'ip='+li.ip+'&statics='+static_newlist+'&_http_id='+nvram.http_id);\n\
}\n\
\n\
TomatoGrid.prototype.sortCompare = function(a, b){ var col = this.sortColumn; var ra = a.getRowData(); var rb = b.getRowData(); var r; if(col==3){ return; }else if(col==1){ r = cmpIP(ra.ip, rb.ip); }else{ r = cmpText(a.cells[col].innerHTML, b.cells[col].innerHTML); }; return this.sortAscending ? r : -r; }\n\
var gw_grid = new TomatoGrid();\n\
\n\
populateGrid = function(){ var i, j, a, b, c, e;\n\
 list = [];\n\
 var al = arplist.slice(0); var dl = dhcpd_lease.slice(0); var ds = dhcpd_static.slice(0,-1);\n\
 for(j=0; j<ds.length; j++){ ds[j] = ds[j].split('<'); }\n\
 for(i=0; i<dl.length; i++){ var stat = '0';\n\
  for(j=0; j<ds.length; j++){ if( ds[j][0].search( dl[i][2] ) != -1 ){ ds.splice(j,1); stat='1'; } }\n\
  for(j=0; j<al.length; j++){ if( al[j][0].search( dl[i][2] ) != -1 ){ al.splice(j,1); } }\n\
  list.push({ name: dl[i][0], ip: dl[i][1], ipp: dl[i][1].replace(ipp,''), mac: dl[i][2], staticIP : stat, vpnroute : 0 });\n\
 }\n\
 for(j=0; j<ds.length; j++){\n\
  for(i=0; i<al.length; i++){ if( ds[j][0].search( al[i][1] ) != -1 ){ al.splice(i,1); } }\n\
  list.push({ name: ds[j][2], ip: ds[j][1], ipp: ds[j][1].replace(ipp,''), mac: ds[j][0] , staticIP : '1', vpnroute : 0 });\n\
 }\n\
 for(j=0; j<al.length; j++){ if( al[j][1].search(ipp) != -1 ){\n\
   list.push({ name: 'i.'+al[j][2], ip: al[j][0], ipp: al[j][1].replace(ipp,''), mac: al[j][1] , staticIP : '0', vpnroute : 0 });\n\
 } }\n\
\n\
 for(i=0; i<list.length; i++){ if(vg.indexOf(list[i].ipp)!=-1){ list[i].vpnroute=1; }else if(va.indexOf(list[i].ipp)!=-1){ list[i].vpnroute=2; } }\n\
\n\
 for(i=0; i<list.length; i++){\n\
  var addit = ( list[i].staticIP==1 ? \"<select onchange='addToRoute(event,\"+i+\");'><option value='0'\"+ ( list[i].vpnroute==0 ? ' selected' : '' ) +\">Local</option><option value='1'\"+ ( list[i].vpnroute==1 ? ' selected' : '' ) +\">VPN</option><option value='2'\"+ ( list[i].vpnroute==2 ? ' selected' : '' ) +\">VPN Accelerator</option></select>\" : \"<input type='button' width='100px' value='Add' onclick='makeStatic(event,\"+i+\");'>\" );\n\
  gw_grid.insert ( -1, list[i], [list[i].mac.replace(/,/,'\\n'), list[i].ip, list[i].name, addit ], false );\n\
 }\n\
}\n\
\n\
function refreshResponse(text){ eval(text); gw_grid.removeAllData(); populateGrid(); gw_grid.resort(); }\n\
function refreshList(){ s_req('update.cgi',refreshResponse,'exec=devlist&_http_id='+nvram.http_id); }\n\
\n\
function setupGrid(){\n\
 gw_grid.init('dev-grid', 'sort'); gw_grid.headerSet(['MAC Address', 'IP Address', 'Name','Route']);\n\
 populateGrid(); gw_grid.sort(1); gw_grid.recolor();\n\
}\n\
\n\
function dgwtoggle(){\n\
 if(nvram.vpn_group_on=='1'){ if(!confirm('This will restart your VPN; would you like to continue?')){ return; } }\n\
 E('dgwButton').disabled = true; hideUi( ( nvram.vpn_group_on=='0' ? 'A' : 'Dea' )+ 'ctivating Dual Gateway...'); s_req('gw.sh',showUi, ( nvram.vpn_group_on=='0' ? 'open' : 'close' ) ); }\n\
\n\
function init(){\n\
 E('dgwButton').value = ( nvram.vpn_group_on=='1' ? 'Deactivate' : 'Activate' ) + ' Dual Gateway';\n\
 str_vg = nvram.vpn_group_vpn; str_va = nvram.vpn_group_accel;\n\
 vg = ( (str_vg!='') ? str_vg.split(' ') : [] ); va = ( (str_va!='') ? str_va.split(' ') : [] );\n\
 setupGrid(); hidden=E('hideme'); hide=E('hiddentext');\n\
}\n\
\n\
function verifyFields(){}\n\
\n\
// /* END DUAL GATEWAY JS */\n";

char sabai_dual_html[] = "<!-- BEGIN DUAL GATEWAY HTML -->\n\
\n\
<input type='button' onclick='dgwtoggle();' id='dgwButton' style='width: 180px; margin-left: 10px;'><br><br>\n\
<div class='section-title'>Devices</div><div class='section'><table id='dev-grid' class='tomato-grid' cellspacing=0></table></div>\n\
<div style='text-align:right;'>\n\
<input type='button' value='Save' onclick='saveGroups();' id='save-button'>\n\
<input type='button' value='Refresh' onclick='refreshList();' id='refresh-button'>\n\
</div><div id='messages' />\n\
<div style='text-indent: 15px; padding-left: 5px; font-size: 1.1em;'>\n\
<p>When the Dual Gateway is activated, all devices connected to the router will be routed through the local internet connection unless assigned to go out through the VPN.\n\
<p>Devices must be assigned a static DHCP IP address to take advantage of Dual Gateway functionality.  Please click \"Add\" to automatically assign a static DHCP IP address, or visit <a href='status-devices.asp'>the Device List</a> or <a href='basic-static.asp'>Static DHCP page</a> to assign them an address manually.  Once the device is assigned the static DHCP IP address, please choose either Local or VPN from the drop down menu for the device to assign that device's route.\n\
<p>Devices will be assigned immediately when you make a selection, but the route will not be permanent until you click \"Save\" at the bottom of the page.\n\
<p>After your device has a Static DHCP address, you will need to disconnect/reconnect your device to the router to get the new address and routing.\n\
</div>\n\
<!-- END DUAL GATEWAY HTML -->\n";

#endif
