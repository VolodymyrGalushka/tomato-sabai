<!DOCTYPE HTML PUBLIC '-//W3C//DTD HTML 4.0//EN'>
<html>
<head>
<meta http-equiv='content-type' content='text/html;charset=utf-8'>
<meta name='robots' content='noindex,nofollow'>
<title id='VPN_TYPE'>[<% ident(); %>] SabaiVPN</title><link rel='stylesheet' type='text/css' href='sabai.css'>
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
<script type='text/javascript' src='sabaivpn.jsx?_http_id=<% nv(http_id); %>'></script>
<script type='text/javascript'>

var ipp='<% lipp(); %>.';
<% devlist(); %>

// /* BEGIN DUAL GATEWAY JS */

var f; var list={}; var vpna = false;
var gw_vpna=['<a href="http://','">VPN Accelerator<span class=\'superscript\'>&#x2020;</span></a>'];
var gw_radio=["<input type='radio' class='gw_def' name='gw_","' onclick='chgw(",",0)'><input type='radio' name='gw_","' onclick='chgw(",",1)'><input type='radio' name='gw_","' onclick='chgw(",",2)'><input type='radio' name='gw_","' onclick='chgw(",",3)'>"];

TomatoGrid.prototype.sortCompare = function(a, b){ var col = this.sortColumn; var ra = a.getRowData(); var rb = b.getRowData(); var r; if(col==3){ r=cmpInt(ra.gw,rb.gw); }else if(col==1){ r = cmpIP(ra.ip, rb.ip); }else{ r = cmpText(a.cells[col].innerHTML, b.cells[col].innerHTML); }; return this.sortAscending ? r : -r; }
var gw_grid = new TomatoGrid();

function report(text){ E('messages').innerHTML=text; }
function populateGrid(){ var i, j;
 var al = arplist.slice(0); var dl = dhcpd_lease.slice(0); var ds = dhcpd_static.slice(0,-1);
 for(j=0; j<ds.length; j++){ ds[j] = ds[j].split('<'); }
 for(i=0; i<dl.length; i++){ var stat = 0;
  for(j=0; j<ds.length; j++){ if( ds[j][0].search( dl[i][2] ) != -1 ){ ds.splice(j,1); stat=1; } }
  for(j=0; j<al.length; j++){ if( al[j][0].search( dl[i][2] ) != -1 ){ al.splice(j,1); } }
  list[ dl[i][1].replace(ipp,'') ] = { name: dl[i][0], ip: dl[i][1], mac: dl[i][2], ips: stat, gws: 0, gw: 0 };
 }
 for(j=0; j<ds.length; j++){ for(i=0; i<al.length; i++){ if( ds[j][0].search( al[i][1] ) != -1 ){ al.splice(i,1); } }; list[ ds[j][1].replace(ipp,'') ] = { name: ds[j][2], ip: ds[j][1], mac: ds[j][0], ips: 1, gws: (ds[j][3]=='1'?1:0), gw: 0 }; }
 for(j=0; j<al.length; j++){ if( al[j][1].search(ipp) != -1 ){ list[ al[j][1].replace(ipp,'') ] = { name: 'i.'+al[j][2], ip: al[j][0], mac: al[j][1] , ips: 0, gws: 0, gw: 0 }; } }
 for(i=1; i<4; i++){ if(nvram['gw_'+i]=='') continue; var gwl = nvram['gw_'+i].split(' '); for(j=0; j<gwl.length; j++){ if(list[gwl[j]]!=undefined) list[gwl[j]].gw=i; } }
 if(vpna=list[nvram.ac_ip]){ delete list[nvram.ac_ip]; vpna.gw=1; vpna.gws=0; gw_grid.insert( -1, vpna, [vpna.mac.replace(/,/,'\n'), vpna.ip, vpna.name, gw_vpna.join(vpna.ip) ], false ); }
 for(var i in list){ gw_grid.insert( -1, list[i], [list[i].mac.replace(/,/,'\n'), list[i].ip, list[i].name, gw_radio.join(i) ], false ); f['gw_'+i][verify_gw(list[i].gw)].checked=true; }
}
function refreshResponse(text){ eval(text); gw_grid.removeAllData(); populateGrid(); gw_grid.resort(); }
function refreshList(){ que.drop('update.cgi',refreshResponse,'exec=devlist&_http_id='+nvram.http_id); }
function setupGrid(){ gw_grid.init('dev-grid', 'sort'); gw_grid.headerSet(['MAC Address', 'IP Address', 'Name',"<span class='gw_opt gw_opt_def' onclick='defgw(0)'>D</span><span class='gw_opt' onclick='defgw(1)'>L</span><span class='gw_opt' onclick='defgw(2)'>V</span><span class='gw_opt' onclick='defgw(3)'>A</span>"],null,[false,false,false,true]); populateGrid(); gw_grid.sort(1); gw_grid.recolor(); }
function radioValue(radioGroup){ for(var i=0; i<f[radioGroup].length; i++){ if(f[radioGroup][i].checked){ return f[radioGroup][i].value; } }; return false; }
function async(state){ E('reg_spin').style.display = state?'':'none'; for(var i=0; i<f.elements.length; i++){ f.elements[i].disabled = state; } }
function gw_response(text){ async(false); sv=JSON.parse(text); report(sv.sabai?'Gateway settings saved.':'There was an error.'); }
function savegw(){ report('Saving...'); async(true); var new_dhcpd_static=[]; var new_gw=[ [], [], [] ]; if(vpna){ list[nvram.ac_ip] = vpna; }
 for(var i in list){ if( list[i].gw==0 ){ if( list[i].ips==1 && list[i].gws==0 ) new_dhcpd_static.push( [ list[i].mac , list[i].ip ,  list[i].name , '0' ].join('<') ); }else{ new_dhcpd_static.push( [ list[i].mac , list[i].ip , list[i].name , '1' ].join('<') ); new_gw[ list[i].gw - 1 ].push( i ); } }
 for(i=0; i<3; i++){ new_gw[i] = 'gw_'+(i+1)+'='+(new_gw[i].length==0?'':new_gw[i].join(' ')); }
 que.drop('s_sabaigw.cgi',gw_response,'gw_def=0&dhcpd_static='+ (new_dhcpd_static.length==0?'':new_dhcpd_static.join('>') + '>') +'&'+new_gw.join('&')+'&_http_id='+nvram.http_id );
}
function verify_gw(dgw){ dgw=parseInt(dgw); if(dgw=='') return 0; if(dgw<0||dgw>3) return 0; return dgw; }
function defgw(gw){ for(var i in list){ f['gw_'+i][list[i].gw = gw].checked = true; } }
function chgw(ip,gw){ if(!list[ip]) return; list[ip].gw = gw; for(var i=0; i<f['gw_all'].length; i++){ f['gw_all'][i].checked = false; } }
function verifyFields(){}
function init(){ window.VPN_test=0; f=E('gw_form'); setupGrid(); hidden=E('hideme'); hide=E('hiddentext'); }
// /* END DUAL GATEWAY JS */

</script></head><body onload='init();' id='topmost'><table id='container' cellspacing=0>
<tr><td colspan=2 id='header'><a id='headlink' href=''><img src='' id='headlogo'></a>
<div class='title' id='SVPNstatus'>Sabai</div><div class='version' id='subversion'>version <!-- SABAI-VERSION --></div></td></tr>

<tr id='body'><td id='navi'><script type='text/javascript'>navi()</script></td><td id='content'>

<!-- / / / -->

<!-- BEGIN DUAL GATEWAY HTML -->
<form id='gw_form'>
<div class='section-title'>Gateway Setup</div><div class='section'><table id='dev-grid' class='tomato-grid' cellspacing=0></table></div>
<div style='text-align:right;'>
<img id='reg_spin' style='display: none;' src="spin.gif">
<input type='button' value='Save' onclick='savegw();' id='save-button'>
<input type='button' value='Cancel' onclick='location.reload();' id='cancel-button'>
<input type='button' value='Refresh' onclick='refreshList();' id='refresh-button'>
<input type='button' value='Help' onclick='window.open("http://www.sabaitechnology.com/v/sabaiHelp/help.html#gw","_newtab");'>
</div><div id='messages' />
</form>
<!-- div style='text-indent: 15px; padding-left: 5px; font-size: 1.1em;'><p>Text</div -->

<!-- END DUAL GATEWAY HTML -->

<!-- / / / -->

</td></tr></table>

<div id='hideme'><div class='centercolumncontainer'><div class='middlecontainer'>
 <div id='hiddentext'>Please wait...</div><br>
 <center><img src='./SabaiSpin.gif'></center>
</div>
</div></div>
</body></html>


