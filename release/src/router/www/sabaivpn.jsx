// <% nvram("vpn_service,pptp_on,ovpn_on,vpn_user,vpn_pass,vpn_fix,vpn_server,vpn_proto,vpn_port,pptp_mppe,pptp_stateful,pptp_defgw,ovpn_type,ovpn_file,ovpn_si,ovpn_up,ovpn_dn,ovpn_cf,gw_run,gw_on,gw_def,gw_vpn,gw_local,gw_accel,ac_on,ac_ip,dhcpd_static,dhcp_start,dhcp_num,dhcpd_startip,dhcpd_endip,reg_info"); %>
var msg_sabaivpn = '<% sabaaiMSG() %>';
var uinf=((nvram.reg_info=='')?',,':nvram.reg_info).split(',');
// // 
var pptp_args=''; var user_pass,hidden;
var ovpn_settings = ['ovpn_cf','ovpn_up','ovpn_dn','ovpn_si'];
var ovpn = {}; var ovpn_diff = {}; var ovpn_changes = '';
var w='Please wait while ';
var msg_ovpnNi= w+'OpenVPN is enabled.';
var msg_ovpnSi= w+'Secure OpenVPN is enabled.';
var msg_ovpnAs= w+nvram.ovpn_type+' OpenVPN is disabled.';
var msg_pptpOn= w+'PPTP is adjusted.';
var msg_ovpnUI= w+'OpenVPN settings are updated.';
var msg_ovpnER= w+'OpenVPN settings are removed.';
var msg_PPtoOV= 'Would you like to disable PPTP and start OpenVPN?'
var msg_OVPNonn = 'Start OpenVPN with current script?'
function verifyFields(){}
function s_req(path,handler,args){ client = new XMLHttpRequest(); client.open('POST',path,true); client.onreadystatechange = function(){ if((client.readyState == 4)&&(client.status==200)){ handler(client.responseText); } }; client.send(args); }
function hideUi(hide_msg){ window.hidden_working = true; hide.innerHTML = (hide_msg); hidden.style.display = 'block'; }
function finRun(pass){ if(typeof pass!='function'){ showUi(); }else{ setTimeout( pass, 3000); } }
function showUi(text){ window.hidden_working = false; hidden.style.display = 'none'; window.location.reload(); }
function PPTPtog(cb){ hideUi(msg_pptpOn); s_req('tomato.cgi', function(){ finRun(cb); },'pptp_on='+ ( E('_f_pptp_on').checked ? '1' : '0') +user_pass+'&_service=sabaivpnpptp-start&_http_id='+nvram.http_id); }
function PPTP_tog(act){
hideUi(w+'PPTP '+act+'s.');
s_req('s_sabaipptp.cgi', showUi,'fire='+act+pptp_args+'&_http_id='+nvram.http_id);
}
function OVPNoff(cb){ hideUi(msg_ovpnAs); s_req('s_stopovpn.cgi', function(){ finRun(cb); },null ); }
function OVPNonn(cb){ hideUi(msg_ovpnNi); s_req('s_startovpn.cgi', function(){ finRun(cb); },null ); }
function OVPNrem(cb){ hideUi(msg_ovpnER); s_req('s_eraseovpn.cgi', function(){ finRun(cb); },null ); }
function OVPNupd(cb){ hideUi(msg_ovpnUI); s_req('tomato.cgi', function(){ finRun(cb); }, ovpn_changes +'_http_id='+nvram.http_id ); }
function startovpn(){
if( nvram.ovpn_on==1 ){ alert('OpenVPN is already running.'); }
else if( confirm( (nvram.pptp_on=='1') ? msg_PPtoOV : msg_OVPNonn ) ){
if(diffScripts()==0){ OVPNonn(); }else{ savescriptchanges(OVPNonn); }
}
}
function stopovpn(){ if(nvram.ovpn_on==1){ if( confirm('Stop OpenVPN?') ){ OVPNoff(); } }else{ alert('OpenVPN is not running; use Erase Script to remove settings.'); } }
function eraseovpn(callback){ if(callback==null){ callback = showUi; }
if(nvram.ovpn_file==''){ alert('No OpenVPN script is loaded'); }
else if(confirm('Erasing your script ('+nvram.ovpn_file+') will also stop OpenVPN and disconnect the VPN.  Would you like to continue?')){ OVPNrem(callback); }
}
function changeScript(){ var f = E('newscript'); var fe = f.file.value;
if( (fe.substr(-4)=='.zip')||(fe.substr(-3)=='.sh')||(fe.substr(-5)=='.ovpn')||(fe.substr(-5)=='.conf') ){ hideUi(msg_ovpnUI); form.addIdAction(f); f.submit(); }else{ alert('You must supply a .sh, .zip, .conf, or .ovpn file.'); showUi(); }
}
function saveoptionchanges(callback){ if(callback == null){ callback = showUi; }
hideUi(msg_ovpnUI); s_req('tomato.cgi', callback, 'sabaivpn_fallback=' +( E('check_fallback').checked ? '1' : '0' )+ '&sabaivpn_generic_updown=' +( E('check_generic_updown').checked ? '1' : '0' ) +'&_http_id='+nvram.http_id );
}
function savescriptchanges(callback){
if(callback == null){
if( diffScripts() == 0 ){ alert('No changes to save.'); return; }
callback = showUi;
if(!confirm('Changing your script can prevent your VPN connection from working and potentially disable your router.  Are you sure?')) return;
}
var lastArgs='';
if(nvram.ovpn_type==''){ lastArgs+='ovpn_type=GenScript&'; }
if(nvram.ovpn_file==''){ lastArgs+='ovpn_file=Generated&'; }
hideUi(msg_ovpnUI);
s_req('tomato.cgi', callback, lastArgs+encodescripts()+'_http_id='+nvram.http_id );
}
// BEGIN	STATUS
function show_VPN_status(vpnstats){
 var sv; var rip;
 if(sv = E('subversion')){
  sv.parentNode.removeChild(sv); sv = E('SVPNstatus'); sv.className = 'version vpnstatus';
  sv.innerHTML="<div id='m_vpn_stats'>VPN is <span id='m_vpn_status'></span> via <span id='m_vpn_contype'></span><br><span id='vpn_mesg'></span><span id='gw_stat'></span><br><span id='external_ip'>Retrieving Internet IP...</span><br></div>";
 }
 E('m_vpn_status').innerHTML = vpnstats.vpnstatus; E('m_vpn_contype').innerHTML = vpnstats.vpnconnectiontype;
 E('gw_stat').innerHTML = 'Dual Gateway is '+(vpnstats.gw_run==0?'off':(vpnstats.gw_on==0?'waiting':'on'))+'.';
 E('vpn_mesg').innerHTML = vpnstats.vpn_mesg;
 if(window.VPN_count==null) window.VPN_count=0;
 if(vpnstats.vpnstatus=='Connected' && ( window.VPN_count<3 ) ){
  que.drop('get_remote_ip.sh', function(resp){
   if(resp.search('wget')!=-1){ setTimeout(redo_VPN_stats,3000); return; }
//   if(window.VPN_count==null) window.VPN_count=0;
   var ipf=resp.split(';');
   if(window.VPN_ip==null) window.VPN_ip=ipf[0];
   if(window.VPN_ip==ipf[0]) window.VPN_count++;
   E('external_ip').innerHTML = 'IP: '+ipf[0]+ (ipf[1]==''?'':' in ' +ipf[1]) + (ipf[2]==''?'':'; ' +ipf[2]);
  } );
 }
}

function redo_VPN_stats(){ if(window.hidden_working==true){ setTimeout( redo_VPN_stats , 3000 ); }else{ que.drop('vpnstatus.asp', update_VPN_stats); } }

function update_VPN_stats(vpns){ if( (vpns!=null) && (vpns!=undefined) ){ eval(vpns);
 if( (vpnstats.ovpn_status==1)||(vpnstats.pptp_status==1) ){
  show_VPN_status(vpnstats);
  if(window.VPN_test==null){ window.VPN_test=4; };
  setTimeout(redo_VPN_stats, ( vpnstats.vpnstatus!='Connected'?5000: (window.VPN_test-->0 ? 15000 : 600000 ) ) );
 }
}else{ redo_VPN_stats(); } }

if(nvram.ovpn_on==1||nvram.pptp_on==1){ redo_VPN_stats(); }else{ setTimeout(redo_VPN_stats,3000); }

// END		STATUS
// 
