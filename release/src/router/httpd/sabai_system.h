#ifndef SABAI_SYSTEM_H
#define SABAI_SYSTEM_H

char sabai_jsx[] = "// /*BEGIN SABAIVPN ACTIVE JAVASCRIPT */\n\
var pptp_args=''; var user_pass,hidden;\n\
var ovpn_settings = ['ovpn_cf','ovpn_up','ovpn_dn','ovpn_si'];\n\
var ovpn = {}; var ovpn_diff = {}; var ovpn_changes = '';\n\
var w='Please wait while ';\n\
var msg_ovpnNi= w+'OpenVPN is enabled.';\n\
var msg_ovpnSi= w+'Secure OpenVPN is enabled.';\n\
var msg_ovpnAs= w+nvram.ovpn_type+' OpenVPN is disabled.';\n\
var msg_pptpOn= w+'PPTP is adjusted.';\n\
var msg_ovpnUI= w+'OpenVPN settings are updated.';\n\
var msg_ovpnER= w+'OpenVPN settings are removed.';\n\
var msg_PPtoOV= 'Would you like to disable PPTP and start OpenVPN?'\n\
var msg_OVPNonn = 'Start OpenVPN with current script?'\n\
\n\
function verifyFields(){}\n\
function s_req(path,handler,args){ client = new XMLHttpRequest(); client.open('POST',path,true); client.onreadystatechange = function(){ if((client.readyState == 4)&&(client.status==200)){ handler(client.responseText); } }; client.send(args); }\n\
function hideUi(hide_msg){ window.hidden_working = true; hide.innerHTML = (hide_msg); hidden.style.display = 'block'; }\n\
function finRun(pass){ if(typeof pass!='function'){ showUi(); }else{ setTimeout( pass, 3000); } }\n\
function showUi(text){ window.hidden_working = false; hidden.style.display = 'none'; window.location.reload(); }\n\
function PPTPtog(cb){ hideUi(msg_pptpOn); s_req('tomato.cgi', function(){ finRun(cb); },'pptp_on='+ ( E('_f_pptp_on').checked ? '1' : '0') +user_pass+'&_service=sabaivpnpptp-start&_http_id='+nvram.http_id); }\n\
function PPTP_tog(act){\n\
 hideUi(w+'PPTP '+act+'s.');\n\
 s_req('s_sabaipptp.cgi', showUi,'fire='+act+pptp_args+'&_http_id='+nvram.http_id);\n\
}\n\
function OVPNoff(cb){ hideUi(msg_ovpnAs); s_req('s_stopovpn.cgi', function(){ finRun(cb); },null ); }\n\
function OVPNonn(cb){ hideUi(msg_ovpnNi); s_req('s_startovpn.cgi', function(){ finRun(cb); },null ); }\n\
function OVPNrem(cb){ hideUi(msg_ovpnER); s_req('s_eraseovpn.cgi', function(){ finRun(cb); },null ); }\n\
function OVPNupd(cb){ hideUi(msg_ovpnUI); s_req('tomato.cgi', function(){ finRun(cb); }, ovpn_changes +'_http_id='+nvram.http_id ); }\n\
\n\
function startovpn(){\n\
 if( nvram.ovpn_on==1 ){ alert('OpenVPN is already running.'); }\n\
 else if( confirm( (nvram.pptp_on=='1') ? msg_PPtoOV : msg_OVPNonn ) ){\n\
  if(diffScripts()==0){ OVPNonn(); }else{ savescriptchanges(OVPNonn); }\n\
 }\n\
}\n\
\n\
function stopovpn(){ if(nvram.ovpn_on==1){ if( confirm('Stop OpenVPN?') ){ OVPNoff(); } }else{ alert('OpenVPN is not running; use Erase Script to remove settings.'); } }\n\
\n\
function eraseovpn(callback){ if(callback==null){ callback = showUi; }\n\
 if(nvram.ovpn_file==''){ alert('No OpenVPN script is loaded'); }\n\
 else if(confirm('Erasing your script ('+nvram.ovpn_file+') will also stop OpenVPN and disconnect the VPN.  Would you like to continue?')){ OVPNrem(callback); }\n\
}\n\
\n\
function changeScript(){ var f = E('newscript'); var fe = f.file.value;\n\
 if( (fe.substr(-4)=='.zip')||(fe.substr(-3)=='.sh')||(fe.substr(-5)=='.ovpn')||(fe.substr(-5)=='.conf') ){ hideUi(msg_ovpnUI); form.addIdAction(f); f.submit(); }else{ alert('You must supply a .sh, .zip, .conf, or .ovpn file.'); showUi(); }\n\
}\n\
\n\
function saveoptionchanges(callback){ if(callback == null){ callback = showUi; }\n\
 hideUi(msg_ovpnUI); s_req('tomato.cgi', callback, 'sabaivpn_fallback=' +( E('check_fallback').checked ? '1' : '0' )+ '&sabaivpn_generic_updown=' +( E('check_generic_updown').checked ? '1' : '0' ) +'&_http_id='+nvram.http_id );\n\
}\n\
\n\
function savescriptchanges(callback){\n\
 if(callback == null){\n\
  if( diffScripts() == 0 ){ alert('No changes to save.'); return; }\n\
  callback = showUi;\n\
  if(!confirm('Changing your script can prevent your VPN connection from working and potentially disable your router.  Are you sure?')) return;\n\
 }\n\
 var lastArgs='';\n\
 if(nvram.ovpn_type==''){ lastArgs+='ovpn_type=GenScript&'; }\n\
 if(nvram.ovpn_file==''){ lastArgs+='ovpn_file=Generated&'; }\n\
 hideUi(msg_ovpnUI);\n\
// 'sabaivpn_fallback=' +( E('check_fallback').checked ? '1' : '0' )+ '&sabaivpn_generic_updown=' +( E('check_generic_updown').checked ? '1' : '0' )+'&'+\n\
 s_req('tomato.cgi', callback, lastArgs+encodescripts()+'_http_id='+nvram.http_id );\n\
}\n\
\n\
// BEGIN	STATUS\n\
\n\
function show_VPN_status(vpnstats){\n\
 var sv; var rip;\n\
 if(sv = E('subversion')){\n\
  sv.parentNode.removeChild(sv); sv = E('SVPNstatus'); sv.className = 'version vpnstatus';\n\
  sv.innerHTML=\"<div id='m_vpn_stats'>VPN is <span id='m_vpn_status'></span> via <span id='m_vpn_contype'></span><br><span id='vpn_mesg'></span><span id='gw_stat'></span><br><span id='external_ip'>Retrieving Internet IP...</span><br></div>\";\n\
 }\n\
 E('m_vpn_status').innerHTML = vpnstats.vpnstatus; E('m_vpn_contype').innerHTML = vpnstats.vpnconnectiontype;\n\
 E('gw_stat').innerHTML = 'Dual Gateway is '+(vpnstats.gw_run==0?'off':(vpnstats.gw_on==0?'waiting':'on'))+'.';\n\
 E('vpn_mesg').innerHTML = vpnstats.vpn_mesg;\n\
 if(vpnstats.vpnstatus=='Connected'){\n\
  que.drop('get_remote_ip.sh', function(resp){\n\
   if(resp.search('wget')!=-1){ setTimeout(redo_VPN_stats,3000); return; }\n\
   var ipf=resp.split(';');\n\
   E('external_ip').innerHTML = 'IP: '+ipf[0]+ (ipf[1]==''?'':' in ' +ipf[1]) + (ipf[2]==''?'':'; ' +ipf[2]);\n\
  } );\n\
 }\n\
}\n\
\n\
function redo_VPN_stats(){ if(window.hidden_working==true){ setTimeout( redo_VPN_stats , 3000 ); }else{ que.drop('vpnstatus.asp', update_VPN_stats); } }\n\
\n\
function update_VPN_stats(vpns){ if( (vpns!=null) && (vpns!=undefined) ){ eval(vpns);\n\
 if( (vpnstats.ovpn_status==1)||(vpnstats.pptp_status==1) ){\n\
  show_VPN_status(vpnstats);\n\
  if(window.VPN_test==null){ window.VPN_test=4; };\n\
  setTimeout(redo_VPN_stats, ( vpnstats.vpnstatus=='Connecting'?5000: ( vpnstats.vpnstatus=='Connected'?(window.VPN_test-->0?15000:120000):3000 ) ) );\n\
 }\n\
}else{ redo_VPN_stats(); } }\n\
\n\
if(nvram.ovpn_on==1||nvram.pptp_on==1){ redo_VPN_stats(); }else{ setTimeout(redo_VPN_stats,3000); }\n\
\n\
// END		STATUS\n\
\n\
// /*END SABAIVPN ACTIVE JAVASCRIPT */\n\
";

#endif
