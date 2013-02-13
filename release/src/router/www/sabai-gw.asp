<!DOCTYPE HTML PUBLIC '-//W3C//DTD HTML 4.0//EN'>
<html>
<head>
<meta http-equiv='content-type' content='text/html;charset=utf-8'>
<meta name='robots' content='noindex,nofollow'>
<title>[<% ident(); %>] Gateways</title><link rel='stylesheet' type='text/css' href='sabai.css'>
<style type='text/css'>
.co1 { width: 25%; text-align: center; }
.co2 { width: 20%; }
.co3 { width: 30%; text-indent: 10px; }
.co4 { width: 25%; text-align: center; }
.header { text-align: center; }
.superscript { vertical-align: super; font-size: .7em; }
input[type="button"] { width: 100px; }
input[type="radio"], .gw_opt { margin-left: 25px; width: 12px; display: inline-block; }
.gw_0 input { margin-left: 5px; margin-right: 20px; }
.opt { text-align: center; }
.opts { text-align: center; background-color: #EDEDED; vertical-align: text-bottom; }
.opts input { vertical-align: text-bottom; }
.gw_def { margin-left: 0px !important; }
.gw_opt { width: 14px; margin: 0 0 0 25px; }
.gw_opt_def { margin: 0; }
.stupid_table { visibility: collapse; }
.stupid_table td { width: 25%; }
</style>
<script type='text/javascript' src='tomato.js'></script>
<script type='text/javascript' src='sabai.jsx?_http_id=<% nv(http_id); %>'></script>
<script type='text/javascript'>

///* var head=['name','ip','mac','ips','gws','gw']; */
var ipp='<% lipp(); %>.';
<% devlist(); %>
// /* BEGIN GATEWAYS JS */

var f; var list={}; var vpna = false;
var gw_vpna=['<a href="http://','">VPN Accelerator</a>'];
var gw_radio=["<input type='radio' class='gw_def' name='gw_","' onclick='chgw(",",0)'><input type='radio' name='gw_","' onclick='chgw(",",1)'><input type='radio' name='gw_","' onclick='chgw(",",2)'><input type='radio' name='gw_","' onclick='chgw(",",3)'>"];

TomatoGrid.prototype.sortCompare = function(a, b){ var col = this.sortColumn; var ra = a.getRowData(); var rb = b.getRowData(); var r; if(col==3){ r=cmpInt(ra.gw,rb.gw); }else if(col==1){ r = cmpIP(ra.ip, rb.ip); }else{ r = cmpText(a.cells[col].innerHTML, b.cells[col].innerHTML); }; return this.sortAscending ? r : -r; }
var gw_grid = new TomatoGrid();

function report(text){ E('messages').innerHTML=text; }

function populateGrid(){
 var i, j;
 var arp = arplist.slice(0); var dyn = dhcpd_lease.slice(0); var sta = dhcpd_static.slice(0,-1); for(j=0; j<sta.length; j++){ sta[j] = sta[j].split('<'); }
 for(i=0; i<dyn.length; i++){ var stat = 0; var gwAuto = 1; var atip = dyn[i][1];
  for(j=0; j<sta.length; j++){ if( sta[j][0].search( dyn[i][2] ) != -1 ){ atip=sta[j][1]; gwAuto = sta[j][3]; stat=1; sta.splice(j,1); } }
  for(j=0; j<arp.length; j++){ if( arp[j][1].search( dyn[i][2] ) != -1 ){ arp.splice(j,1); } }
  list[ atip.replace(ipp,'') ] = { name: dyn[i][0], ip: atip, mac: dyn[i][2], ips: stat, gws: gwAuto, gw: 0 };
 }
 for(j=0; j<sta.length; j++){ for(i=0; i<arp.length; i++){ if( sta[j][0].search( arp[i][1] ) != -1 ){ arp.splice(i,1); } }; list[ sta[j][1].replace(ipp,'') ] = { name: sta[j][2], ip: sta[j][1], mac: sta[j][0], ips: 1, gws: (sta[j][3]=='1'?1:0), gw: 0 }; }
 for(j=0; j<arp.length; j++){ if( arp[j][0].search(ipp) != -1 ){ var alip = arp[j][0].replace(ipp,''); if(!list[ alip ]) list[ alip ] = { name: 'i:'+arp[j][2]+'@'+alip, ip: arp[j][0], mac: arp[j][1] , ips: 0, gws: 1, gw: 0 }; } }
 for(i=1; i<4; i++){ if(nvram['gw_'+i]=='') continue; var gwl = nvram['gw_'+i].split(' '); for(j=0; j<gwl.length; j++){ if(list[gwl[j]]!=undefined) list[gwl[j]].gw=i; } }
 if(vpna=list[nvram.ac_ip]){ delete list[nvram.ac_ip]; vpna.gw=1; vpna.gws=0; gw_grid.insert( -1, vpna, [vpna.mac.replace(/,/,'\n'), vpna.ip, vpna.name, gw_vpna.join(vpna.ip) ], false ); }
 for(var i in list){ gw_grid.insert( -1, list[i], [list[i].mac.replace(/,/,'\n'), list[i].ip, list[i].name, gw_radio.join(i) ], false ); f['gw_'+i][verify_gw(list[i].gw)].checked=true; }
}
function toggleExplain(){ E('toggleDesc').innerHTML= ( peeky('explanation')?'Hide':'Show' ); return false; }

function setupGrid(){ gw_grid.init('dev-grid', 'sort'); gw_grid.headerSet(['MAC Address', 'IP Address', 'Name',"<span class='gw_opt gw_opt_def' onclick='defgw(0)'>D</span><span class='gw_opt' onclick='defgw(1)'>L</span><span class='gw_opt' onclick='defgw(2)'>V</span><span class='gw_opt' onclick='defgw(3)'>A</span>"],null,[false,false,false,true]); populateGrid(); gw_grid.sort(1); gw_grid.recolor(); }
function radioValue(radioGroup){ for(var i=0; i<f[radioGroup].length; i++){ if(f[radioGroup][i].checked){ return f[radioGroup][i].value; } }; return false; }
function gw_response(text){ async(false); sv=JSON.parse(text); if(!sv.sabai) report('There was an error.'); else reloadPage(); }
function savegw(){ report('Saving...'); async(true);
 var def=verify_gw(radioValue('gw_def')); var new_dhcpd_static=[]; var new_gw=[ [], [], [] ];
 if(vpna){ list[nvram.ac_ip] = vpna; }
 for(var i in list){
  if( (list[i].gws==0 && list[i].ips==1) || list[i].gw!=0) new_dhcpd_static.push( [ list[i].mac , list[i].ip ,  list[i].name , list[i].gws ].join('<') );
  if(list[i].gw!=0) new_gw[ list[i].gw - 1 ].push( i )
 }
 for(i=0; i<3; i++){ new_gw[i] = 'gw_'+(i+1)+'='+(new_gw[i].length==0?'':new_gw[i].join(' ')); }
 var sdhcp = (new_dhcpd_static.length==0?'':new_dhcpd_static.join('>') + '>');
 que.drop('s_sabaigw.cgi',gw_response,'gw_def='+ def +'&dhcpd_static='+ sdhcp +'&'+new_gw.join('&')+'&_http_id='+nvram.http_id );
}
function verify_gw(dgw){ dgw=parseInt(dgw,10); if(dgw==''||isNaN(dgw)) return 0; if(dgw<0||dgw>3) return 0; return dgw; }
function defgw(gw){ for(var i in list){ f['gw_'+i][list[i].gw = gw].checked = true; }; f.gw_all[gw].checked=false; }
function chgw(ip,gw){ if(!list[ip]) return; list[ip].gw = gw; }
function init(){ f=E('gw_form'); f.gw_def[verify_gw(nvram.gw_def)].checked = true; setupGrid(); new vpnStatus(); }
// /* END GATEWAYS JS */

</script></head><body onload='init();' id='topmost'><table id='container' cellspacing=0>
<tr><td colspan=2 id='header'><a id='headlink' href='http://www.sabaitechnology.com'><img src='imgsabai.png' id='headlogo'></a>
<div class='title' id='SVPNstatus'><% sabaid(); %></div><div class='version' id='subversion'>version <!-- SABAI-VERSION --></div></td></tr>

<tr id='body'><td id='navi'><% sabaaiMenu(); %></td><td id='content'>

<!-- / / / -->

<!-- BEGIN GATEWAYS HTML -->
<form id='gw_form'>
<div class='section-title'>Gateway Setup</div><div class='section' style='padding-bottom: 5px;'>
<table id="top-grid" class="tomato-grid" cellspacing="0"><tbody>
<tr><td class='opt' colspan='2'>Default</td><td class='opt' colspan='1'></td><td class='opt' colspan='1'>Assign All</td></tr>
<tr>
 <td class='opts gw_0' colspan='2'>
  <span>None: <input value="0" name="gw_def" type="radio"></span>
  <span>Local: <input value="1" name="gw_def" type="radio"></span>
  <span>VPN: <input value="2" name="gw_def" type="radio"></span>
  <span>Accelerator: <input value="3" name="gw_def" type="radio"></span>
 </td>
 <td class='opt' colspan='1'></td>
 <td class='opts' colspan='1'><input type='radio' name='gw_all' onclick='defgw(0)' class='gw_def'><input type='radio' name='gw_all' onclick='defgw(1)'><input type='radio' name='gw_all' onclick='defgw(2)'><input type='radio' name='gw_all' onclick='defgw(3)'></td>
</tr>
<tr class='stupid_table'><td></td><td></td><td></td><td></td></tr>
</tbody></table>
<table id='dev-grid' class='tomato-grid' cellspacing=0></table></div>
<div style='text-align:right;'>
<img id='reg_spin' style='display: none;' src="imgspin.gif">
<input type='button' value='Save' onclick='savegw();' id='save-button'>
<input type='button' value='Cancel' onclick='location.reload();' id='cancel-button'>
<input type='button' value='Help' onclick='window.open("http://www.sabaitechnology.com/v/sabaiHelp/help.html#gw","_newtab");'>
</div><div id='messages'></div>
</form>

<!-- END GATEWAYS HTML -->

<!-- / / / -->

<!-- pre id='testing'>T</pre -->
<br>
<span>Each device connected to the network will be displayed in the device list above. For each device, the user has the option of assigning a gateway; (D)efault, (L)ocal), (V)PN, or (A)ccelerator within the device table.
 <a href='#' onclick='toggleExplain();'>(<span id='toggleDesc'>Show</span> Description)</a>
</span>
<br>
<ul id='explanation' class='explain hidey'>
<li><b>(D) Default</b>: Any devices not assigned to Local, VPN, or Accelerator in the device list, will use the default as designated in the default assignment function at the top of the page. ('None' automatically assigns traffic to the routers current network state.)</li>
<li><b>(L) Local</b>: The internet connection provided by an ISP, i.e. a normal, non-VPN connection.</li>
<li><b>(V) VPN</b>: The connection through VPN, as set up on this router (either PPTP or OpenVPN).</li>
<li><b>(A) Accelerator</b>: A Sabai VPN Accelerator connection (a secondary device that handles VPN functions in place of the router. <a href="http://www.sabaitechnology.com/VPN-Accelerator-for-fast-VPN-routing-p/acc1st.htm">More Information</a>).</li>
<li> 
<li><b>Assign All</b>: Places every listed device on the gateway for that column.</li>
<li><b>MAC Address*</b>: The 'hardware' address of the device; this usually does not change and is somewhat unique.</li>
<li><b>IP Address*</b>: The assigned Internet Protocol address of the device; this can regularly change, but will be made static if necessary to assign to a gateway.</li>
<li><b>Name*</b>: The host name the device reports or the name assigned on the <a href='advanced-static.asp'>Static IP page</a>; in the case of devices for which their is no reported hostname, one is assigned of the form i.interface@ipaddress.</li>
<li><b>*</b> This information can be edited on the <a href='advanced-static.asp'>Static IP page</a>.</li>
<li><b>D L V A</b>: The gateway assigned to the device (D: Default, L: Local, V: VPN, A: Accelerator).</li>
<li><b>Save</b>: Save settings and restart the gateway service to apply them.</li>
<li><b>Cancel</b>: Discard any changes and reload the page.</li>
<li><b>Refresh</b>: Check for new devices. (This will also discard any changes.)</li>
</ul>

</td></tr></table>
</body></html>
