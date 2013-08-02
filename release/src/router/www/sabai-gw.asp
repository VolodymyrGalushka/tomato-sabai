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

var ipp='<% lipp(); %>.';
<% devlist(); %>
// /* BEGIN GATEWAYS JS */

var f; var list={}; var staticList = false; var vpna = false; var statics = false;
var gw_vpna=['<a href="http://','">VPN Accelerator</a>'];
var gw_radio=["<input type='radio' class='gw_def' name='gw_","' onclick='chgw(\"","\",0)'><input type='radio' name='gw_","' onclick='chgw(\"","\",1)'><input type='radio' name='gw_","' onclick='chgw(\"","\",2)'><input type='radio' name='gw_","' onclick='chgw(\"","\",3)'>"];

TomatoGrid.prototype.sortCompare = function(a, b){ var col = this.sortColumn; var ra = a.getRowData(); var rb = b.getRowData(); var r; if(col==3){ r=cmpInt(ra.gw,rb.gw); }else if(col==1){ r = cmpIP(ra.ip, rb.ip); }else{ r = cmpText(a.cells[col].innerHTML, b.cells[col].innerHTML); }; return this.sortAscending ? r : -r; }
var gw_grid = new TomatoGrid();

function report(text){ E('messages').innerHTML=text; }
function A(text){ E('testing').innerHTML+= (text + '\n'); }
function B(text){ E('testing').innerHTML=text + '\n'; }
function C(obj){ return (JSON.stringify(obj)); }
function D(obj){ var txt=[];
 for(var i in obj){ txt.push(i +': '+ C(obj[i])); }
 return txt.join('\n');
}

function populateGrid(){
 var i, j;
 var arp = {};
 var sip = {};
 var tmp = dhcpd_static.slice(0,-1);
 var last;
 for(j=0; j<tmp.length; j++){
  tmp[j] = tmp[j].split('<');
  sip[ tmp[j][1] ] = { mac: tmp[j][0], ip: tmp[j][1], host: tmp[j][2], static: true };
 }
 for(j=0; j<arplist.length; j++){ if(arplist[j][2] != 'br0') continue;
  arp[ arplist[j][0] ] = { mac: arplist[j][1], ip: arplist[j][0] };
 }
 for(j=0; j<dhcpd_lease.length; j++){
  list[ dhcpd_lease[j][1] ] = { mac: dhcpd_lease[j][2], ip: dhcpd_lease[j][1], host: dhcpd_lease[j][0] };
 }

// A('\tDHCP:\n'+ D(list)); A('\tSIP:\n'+ D(sip)); A('\tARP:\n'+ D(arp));

 for(var i in list){
  for(var j in sip){
   if( sip[j].mac.search(list[i].mac) != -1 ){ // if dhcp device at i has the same mac address as static device at j
    if( j == i ){ // and the same ip
     sip[j].ignore = true; // ignore when merging lists
     list[j].static = true; // but mark as a static entry
     list[j].mac = sip[j].mac // and use the static list mac entry, since it will contain both of the addresses assigned that IP, if the device has two MACs (usually wireless and wired)
    }else{
     list[i].reboot = true; // if the macs match but the IPs don't, we need to renew that device's IP address
    }
   }else{
    list[j] = sip[j]; // if this is a device currently not listed, merge its entry into the list
   }
  }
 }
 for(var j in sip){ if(!sip[j].ignore) list[j] = sip[j]; }
 for(var i in list){
  // if a device from the arp list has the same IP or Mac as one in the DHCP list, we ignore it
  // could possible do better, but hard to figure out what; this is for rogue devices who should be assigned a static IP anyhow
  for(var j in arp){ if( (j==i) || (arp[j].mac.search(list[i].mac) != -1) ) arp[j].ignore = 1; }
 }
 for(var j in arp){ if(!arp[j].ignore) list[j] = arp[j]; }

 for(var i in list) list[i].gw = 0; // set default gw

// A('\tFinal:\n'+ D(list));
 
 for(i=1; i<4; i++){
  if(nvram['gw_'+i]=='') continue;
  var gwl = nvram['gw_'+i].split(' ');
  for(j=0; j<gwl.length; j++){
   tmp = ipp + gwl[j];
   if(list[ tmp ]!=undefined) list[ tmp ].gw = i;
  }
 }
 tmp = ipp + nvram.ac_ip;
 if(vpna=list[tmp]){ // the VPNA is a special case; we don't want people assigning it because this would break it.
  delete list[tmp]; // remove its entry from the list; we'll add it to the table manually
  vpna.gw=1; // it is always assigned to the local table
  gw_grid.insert( -1, vpna, [vpna.mac.replace(/,/,'\n'), vpna.ip, vpna.host, gw_vpna.join(vpna.ip) ], false );
 }

 for(var i in list){ gw_grid.insert( -1, list[i], [list[i].mac.replace(/,/,'\n'), list[i].ip, list[i].host, gw_radio.join(i) ], false ); f['gw_'+i][verify_gw(list[i].gw)].checked=true; }

}

function toggleExplain(){ E('toggleDesc').innerHTML= ( peeky('explanation')?'Hide':'Show' ); return false; }

function setupGrid(){
 gw_grid.init('dev-grid', 'sort');
 gw_grid.headerSet(['MAC Address', 'IP Address', 'Name',"<span class='gw_opt gw_opt_def' onclick='defgw(0)'>D</span><span class='gw_opt' onclick='defgw(1)'>L</span><span class='gw_opt' onclick='defgw(2)'>V</span><span class='gw_opt' onclick='defgw(3)'>A</span>"],null,[false,false,false,true]);
 populateGrid();
 gw_grid.sort(1); gw_grid.recolor();
}
function radioValue(radioGroup){ for(var i=0; i<f[radioGroup].length; i++){ if(f[radioGroup][i].checked){ return f[radioGroup][i].value; } }; return false; }
function gw_response(text){ async(false); sv=JSON.parse(text); if(!sv.sabai) report('There was an error.'); else reloadPage(); }
function savegw(){
 report('Saving...'); async(true);
 var def=verify_gw(radioValue('gw_def'));
 if(vpna){ list[ vpna.ip ] = vpna; }

 var sip = [];
 var gateways = [ [], [], [], [] ]; // the array at 0 is pretty much ignored; it's here for convenience in the code

 for(var i in list){
  if(list[i].gw==0){ // skip entries with no gateway set, but add them to the static list if they were previously static
   if(list[i].static) sip.push(i);
   continue;
  }
  // if an entry is not static but assigned a gateway, we want to make it static so it'll work
  sip.push(i)
  gateways[ list[i].gw ].push( i.replace(ipp,'') );
 }

 for(i=1; i<4; i++){ gateways[i] = 'gw_'+i+'='+(gateways[i].length==0?'':gateways[i].join(' ')); }

 gateways.shift(); // discard the empty array

 for(i=0; i<sip.length; i++){
  tmp = list[ sip[i] ];
  sip[i] = [ tmp.mac, tmp.ip, tmp.host ].join('<');
 }
 sip = sip.join('>') + '>';

 que.drop('s_sabaigw.cgi',gw_response,'gw_def='+ def +'&dhcpd_static='+ sip +'&'+gateways.join('&')+'&_http_id='+nvram.http_id );

}
function verify_gw(dgw){ dgw=parseInt(dgw,10); if(dgw==''||isNaN(dgw)) return 0; if(dgw<0||dgw>3) return 0; return dgw; }
function defgw(gw){ for(var i in list){ f['gw_'+i][list[i].gw = gw].checked = true; }; f.gw_all[gw].checked=false; }
function chgw(ip,gw){ if(!list[ip]) return; list[ip].gw = gw; }
function init(){
 f=E('gw_form');
 f.gw_def[verify_gw(nvram.gw_def)].checked = true;
 setupGrid();
// new vpnStatus();
}
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

<!-- pre id='testing'></pre -->

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
