// <% nvram("pptp_user,pptp_pass,pptp_server,pptp_mppe,pptp_stateful,ovpn_user,ovpn_pass,ovpn_file,ovpn_cf,gw_def,gw_1,gw_2,gw_3,ac_ip"); %>

function verifyFields(){}
function parseJson(JSONin){ var result=false; try { result=JSON.parse(JSONin); }catch(ex){ /* tragically, there's nothing we can do */ }; return result; }
function async(state){ var spinny=E('reg_spin'); if(spinny) spinny.style.display = state?'':'none'; if(f) for(var i=0; i<f.elements.length; i++){ f.elements[i].disabled = state; } }

// BEGIN	STATUS
function vpnStatus(){
 var sv=false,vpn=false,ip=false,workingNow=false; var faultLimit = 10, vpnLimit = 4, vpnDelay = 15000, statusLimit = 10, statusDelay = 5000;
 function setVpnIp(resp){ workingNow=false;
  if(ip=parseJson(resp)) sv.ip.innerHTML = 'IP: '+ (ip.ip||'Unknown') + ( (ip.city||ip.region||ip.country) ?'<br>':'') + (!ip.city?'': ip.city+ ((ip.region||ip.country)?', ':'') ) + (!ip.region?'': ip.region+ (ip.country?', ':'') ) + (ip.country||'');
 }
 function getVpnIp(){
  if(!vpn.up || !vpn.ready || (faultLimit--<0)) return;
  workingNow=true;
  que.drop('checkip.sh', setVpnIp);
 }

 function prepareStatus(){ sv.old.parentNode.removeChild(sv.old); sv.old = false; sv.status=E('SVPNstatus');
  sv.status.className = 'version vpnstatus'; sv.status.innerHTML="VPN is <span id='vpn_up'></span> via <span id='vpn_type'></span><br><span id='vpn_ip'>Retrieving Internet IP...</span><br>";
  sv.up=E('vpn_up'); sv.type=E('vpn_type'); sv.ip=E('vpn_ip');
 }
 function setStatus(resp){ workingNow=false;
  if((vpn=parseJson(resp)) && vpn.on){ if(sv.old) prepareStatus(); sv.up.innerHTML = (vpn.up?'up':'connecting'); sv.type.innerHTML = vpn.type; getVpnIp(); }
  if(statusLimit>0){ statusLimit--; }else{ statusDelay+=15000; }
  getStatus();
 }
 function updateStatus(){ if(window.hidden_working==true || workingNow){ getStatus(); }else{ workingNow=true; que.drop('vpnstatus.asp', setStatus); } }
 function getStatus(){ setTimeout( updateStatus, statusDelay ); }
 function init(){ if(!sv) sv = { old: E('subversion') }; setTimeout( updateStatus, 500 ); }
 init();
}
// END		STATUS
