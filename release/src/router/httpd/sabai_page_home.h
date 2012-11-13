#ifndef SABAIVPN_PAGE_HOME_H
#define SABAIVPN_PAGE_HOME_H

	// home_ is the page served when the code is correct and the VPN service (nvram variable vpn_service) is set to 'Homebase'
char *sabai_home[] = {
"['HomebaseVPN','sabaivpn', 0, [\n\
['VPN',			'sabaivpn-home.asp'],\n\
['Port Forwarding',	'forward-basic.asp'],\n\
['Dual Gateway',	'sabaivpn-dual.asp']\n\
] ]",
"// BEGIN HOMEBASE JS\n\
var TIMER = 1000;\n\
var user_pass;\n\
var hidden; var hide; var fom;\n\
\n\
function hideHidden(){ hidden.style.display = 'none'; }\n\
function showHidden(){ hidden.style.display = 'block'; }\n\
function hideUi(hide_msg){ hide.innerHTML = (hide_msg); showHidden(); }\n\
function showUi(text){ hideHidden(); window.location.reload(); }\n\
\n\
function updateLoginInfo(afterRun){  hideUi('Please wait while Login information is updated.'); que.drop('tomato.cgi', function(text){ setTimeout( afterRun||showUi , 10000); }, 'pptp_autofire=0'+user_pass+'&_http_id='+nvram.http_id ); }\n\
function OVPNoff(afterRun){ hideUi('Please wait while '+nvram.ovpn_type+' OpenVPN is disabled.'); que.drop('s_stopovpn.cgi' , function(text){ setTimeout( afterRun||showUi , 10000); } ); }\n\
function OVPNon(afterRun){ hideUi('Please wait while OpenVPN is enabled.'); que.drop('s_normalovpn.cgi', function(text){ setTimeout( afterRun||showUi , 10000); } ); }\n\
function OVPNSon(afterRun){ hideUi('Please wait while Secure OpenVPN is enabled.'); que.drop('s_secureovpn.cgi', function(text){ setTimeout( afterRun||showUi , 10000); } ); }\n\
function PPTPoff(afterRun){ hideUi('Please wait while PPTP is disabled.'); que.drop('tomato.cgi', function(text){ setTimeout( afterRun||showUi , 10000); }, 'pptp_autofire=0'+user_pass+'&_service=sabaivpnpptp-start'+'&_http_id='+nvram.http_id ); }\n\
function PPTPon(afterRun){ hideUi('Please wait while PPTP is enabled.'); que.drop('tomato.cgi', function(text){ setTimeout( afterRun||showUi , 10000); },'pptp_autofire=1'+user_pass+'&pptp_defgw=1&_service=sabaivpnpptp-start&_http_id='+nvram.http_id ); }\n\
\n\
function OVPN_Check(){ if( nvram.pptp_on!=0 ){ PPTPoff( OVPNon ); }else if( user_pass.length > 0 ){ OVPNoff( function(){ updateLoginInfo( OVPNon ); } ); }else{ OVPNon(); } }\n\
function OVPNS_Check(){ if( nvram.pptp_on!=0 ){ PPTPoff( OVPNSon ); }else if( user_pass.length > 0 ){ OVPNoff( function(){ updateLoginInfo( OVPNSon ); } ); }else{ OVPNSon(); } }\n\
function save(){\n\
 user_pass = ( (nvram.pptp_server.substr(0,3)==fom.pptp_server.value) ? '' : '&pptp_server='+fom.pptp_server.value+'.vpn.goldenfrog.com' );\n\
 switch(fom.pptp_or_openvpn.value) {\n\
  case 'pptp' : { hideUi(); if(nvram.ovpn_type!=''){ OVPNoff( PPTPon ); }else{ PPTPon(); }; break; }\n\
  case 'open' : { hideUi(); if( (nvram.ovpn_type!='')&&(nvram.ovpn_type=='Normal') ){ OVPNoff( OVPN_Check ); }else{ OVPN_Check() }; break; }\n\
  case 'opensecure' : { hideUi(); if( (nvram.ovpn_type!='')&&(nvram.ovpn_type=='Secure') ){ OVPNoff( OVPNS_Check ); }else{ OVPNS_Check() }; break; }\n\
  case 'off' : { if( (nvram.pptp_on==1)&&(confirm('Take down PPTP connection?')) ){ PPTPoff(); }; if( (nvram.ovpn_type!='')&&(confirm('Take down OpenVPN connection?')) ){ OVPNoff(); }; if( user_pass.length > 0 ){ hideUi('Saving login information.'); updateLoginInfo(); }; break; }\n\
 }\n\
}\n\
function verifyFields(){}\n\
function init(){ fom = E('Homebase_form'); hidden = E('hideme'); hide = E('hiddentext'); }\n\
// END HOMEBASE JS",
"<!-- BEGIN HOMEBASE HTML -->\n\
<form id='Homebase_form'><div class='section-title'>HomebaseVPN Setup</div><div class='section'><script type='text/javascript'>\n\
createFieldTable('', [\n\
{ title: 'Connection Type', name: 'pptp_or_openvpn', type: 'select',\n\
options: [ ['pptp','PPTP'],['open','OpenVPN Standard'],['opensecure','OpenVPN Secure'],['off','Disabled'] ],\n\
value: ( (nvram.pptp_on==1) ? 'pptp' : ( (nvram.ovpn_type=='') ? 'off' : ( (nvram.ovpn_type=='Normal') ? 'open' : 'opensecure' ) ) )\n\
},\n\
{ title: 'Server', name: 'pptp_server', type: 'select',\n\
options: [ ['us1','Los Angeles, US'],['us2','Washington, DC, US'],['eu1','Amsterdam, Netherlands'],['hk1','Hong Kong, China'],['uk1','London, UK'] ],\n\
value: ( nvram.pptp_server.substr(0,3) )\n\
},\n\
]);//</script></div>\n\
<div class='section-title hiddenChildMenu'>PPTP advanced settings</div><div class='section hiddenChildMenu'><script type='text/javascript'>\n\
createFieldTable('', [\n\
{ title: 'Domain', name: 'pptp_domain', maxlen:64, size:66, type: 'text', value: nvram.pptp_domain },\n\
{ title: 'Options', name: 'pptp_options', maxlen:64, size:66, type: 'text', value: nvram.options },\n\
{ title: 'Use Default Gateway on Remote Network', name: 'f_pptp_defgw', type: 'checkbox', value: nvram.pptp_defgw!='0' },\n\
{ title: 'Add subnets', name: 'pptp_subnets', maxlen:64, size:66, type: 'text', value: nvram.pptp_subnets }\n\
]); //</script></div>\n\
<input type='button' value='Apply Settings Now' id='_savescript_button' onclick='save();' style='height:20px'>\n\
<input type='button' value='Cancel' id='_cancel_button' onclick='window.location.reload();' style='height:20px'></form>\n\
\n\
<!-- END HOMEBASE HTML -->"
};

#endif
