#ifndef SABAIVPN_PAGE_DUAL_H
#define SABAIVPN_PAGE_DUAL_H

	// Dual Gateway Page

char *sabai_dual[] = {"/* No Menu */",
"// /* BEGIN DUAL GATEWAY JS */\n\
\n\
var list = []; var statics=''; var shreq=''; var hidden, hide, vl, vg, va, str_vl, str_vg, str_va;\n\
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
 hideUi('Please wait while we adjust your router.');\n\
 que.drop('./gw.sh', showUi ,'commit');\n\
}\n\
function addedToRoute(text){ refreshList(); E('save-button').disabled=''; E('refresh-button').disabled=''; }\n\
function addToRoute(event,li){\n\
 var groups=[[],vl,vg,va]; var fro = list[li].vpnroute; var to = event.target.value;\n\
\n\
 list[li].vpnroute=to;\n\
\n\
 group_extract(groups[fro],list[li].ipp); group_insert(groups[to],list[li].ipp);\n\
\n\
 str_vl=group_pack(vl); str_vg=group_pack(vg); str_va=group_pack(va);\n\
\n\
 E('save-button').disabled='true'; E('refresh-button').disabled='true';\n\
 que.drop('./gw.sh', addedToRoute,'add '+list[li].ip+','+to+','+str_vl+','+str_vg+','+str_va );\n\
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
 que.drop('s_static.cgi',showUi,'ip='+li.ip+'&statics='+static_newlist+'&_http_id='+nvram.http_id);\n\
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
 for(i=0; i<list.length; i++){\n\
  if(vl.indexOf(list[i].ipp)!=-1){ list[i].vpnroute=1; }else\n\
  if(vg.indexOf(list[i].ipp)!=-1){ list[i].vpnroute=2; }else\n\
  if(va.indexOf(list[i].ipp)!=-1){ list[i].vpnroute=3; }\n\
  var addit = list[i].ipp==nvram.ac_ip ? '<a href=\"http://'+ list[i].ip +'\">VPN Accelerator (local)</a>' : ( list[i].staticIP==1 ? \n\
\"<select onchange='addToRoute(event,\"+i+\");'><option value='0'\"+ ( list[i].vpnroute==0 ? ' selected' : '' ) +\">Default</option>\"+\n\
\"<option value='1'\"+ ( list[i].vpnroute==1 ? ' selected' : '' ) +\">Local</option>\"+\n\
\"<option value='2'\"+ ( list[i].vpnroute==2 ? ' selected' : '' ) +\">VPN</option>\"+\n\
\"<option value='3'\"+ ( list[i].vpnroute==3 ? ' selected' : '' ) +\">VPN Accelerator</option>\"+\n\
\"</select>\" : \"<input type='button' width='100px' value='Add' onclick='makeStatic(event,\"+i+\");'>\" );\n\
  gw_grid.insert ( -1, list[i], [list[i].mac.replace(/,/,'\\n'), list[i].ip, list[i].name, addit ], false );\n\
 }\n\
}\n\
\n\
function refreshResponse(text){ eval(text); gw_grid.removeAllData(); populateGrid(); gw_grid.resort(); }\n\
function refreshList(){ que.drop('update.cgi',refreshResponse,'exec=devlist&_http_id='+nvram.http_id); }\n\
\n\
function setupGrid(){\n\
 gw_grid.init('dev-grid', 'sort'); gw_grid.headerSet(['MAC Address', 'IP Address', 'Name','Route']);\n\
 populateGrid(); gw_grid.sort(1); gw_grid.recolor();\n\
}\n\
\n\
function dgwtoggle(){\n\
 var def=E('gw_def').value;\n\
 E('dgwButton').disabled = true;\n\
 hideUi( ( nvram.gw_on=='0' ? 'A' : 'Dea' )+ 'ctivating Dual Gateway...');\n\
 que.drop('gw.sh',showUi, (nvram.gw_on=='0'?'open':'close')+' '+def );\n\
}\n\
\n\
function deftoggle(){ E('gw_def_help').innerHTML = (E('gw_def').value==1?'VPN':'local internet'); }\n\
\n\
function init(){\n\
 E('dgwButton').value = ( nvram.gw_on==1 ? 'Deactivate' : 'Activate' ) + ' Dual Gateway';\n\
 if(nvram.gw_on==1){ E('gw_def').disabled = true; E('gw_def_txt').style.color = 'silver'; }\n\
 E('gw_def').value=nvram.gw_def;\n\
 deftoggle();\n\
 str_vl = nvram.gw_local; str_vg = nvram.gw_vpn; str_va = nvram.gw_accel;\n\
 vl = ( (str_vl!='') ? str_vl.split(' ') : [] ); vg = ( (str_vg!='') ? str_vg.split(' ') : [] ); va = ( (str_va!='') ? str_va.split(' ') : [] );\n\
 setupGrid(); hidden=E('hideme'); hide=E('hiddentext');\n\
}\n\
\n\
function verifyFields(){}\n\
\n\
// /* END DUAL GATEWAY JS */\n",
"<!-- BEGIN DUAL GATEWAY HTML -->\n\
\n\
<input type='button' onclick='dgwtoggle();' id='dgwButton' style='width: 180px; margin-left: 10px;'> <span id='gw_def_txt'>The default gateway is <select id='gw_def' onchange='deftoggle();'><option value='0'>Local</option><option value='1'>VPN</option></select>*.</span><br><br>\n\
<div class='section-title'>Devices</div><div class='section'><table id='dev-grid' class='tomato-grid' cellspacing=0></table></div>\n\
<div style='text-align:right;'>\n\
<input type='button' value='Save' onclick='saveGroups();' id='save-button'>\n\
<input type='button' value='Refresh' onclick='refreshList();' id='refresh-button'>\n\
<input type='button' value='Help' onclick='window.open(\"http://www.sabaitechnology.com/v/sabaiHelp/help.html#gw\",\"_newtab\");'>\n\
</div><div id='messages' />\n\
<div style='text-indent: 15px; padding-left: 5px; font-size: 1.1em;'>\n\
<p>*This selects the default route; all devices on &quot;Default&quot; will go through the <span id='gw_def_help'>local</span> connection when the Dual Gateway is activated.  This cannot be changed while Dual Gateway is active.\n\
<p>Devices must be assigned a static DHCP IP address to take advantage of Dual Gateway functionality.  Please click &quot;Add&quot; to automatically assign a static DHCP IP address, or visit <a href='status-devices.asp'>the Device List</a> or <a href='basic-static.asp'>Static DHCP page</a> to assign them an address manually.  Once the device is assigned the static DHCP IP address, you may choose a route from the drop down menu for that device.\n\
<p>After your device has a Static DHCP address, you will need to disconnect/reconnect your device to the router to get the new address and routing.  You may wish to verify the device's IP address matches that listed here after assigning a static IP.\n\
<p>Devices will be assigned immediately when you make a selection, but the route will not be permanent until you click &quot;Save&quot; at the bottom of the page.  Please note that some actions on other pages (those that trigger an NVRAM commit) will make these routes permanent.\n\
</div>\n\
\n\
<!-- END DUAL GATEWAY HTML -->\n"};

#endif
