<!DOCTYPE HTML PUBLIC '-//W3C//DTD HTML 4.0//EN'>
<html>
<head>
<meta http-equiv='content-type' content='text/html;charset=utf-8'>
<meta name='robots' content='noindex,nofollow'>
<title>[<% ident(); %>] PPTP</title><link rel='stylesheet' type='text/css' href='sabai.css'>
<script type='text/javascript' src='tomato.js'></script>
<script type='text/javascript' src='sabai.jsx?_http_id=<% nv(http_id); %>'></script>
<script type='text/javascript'>

// /* BEGIN SABAI PPTP JS */
var f;
var processing = ['Sav','Start','Stopp','Eras'];

function PPTPsave(act){ if(act==3 && !confirm("Erase all PPTP settings?")) return; E('processing').innerHTML = ['Sav','Start','Stopp','Eras'][act] +'ing...'; async(true);
 que.drop('s_sabaipptp.cgi', reloadPage, 'fire='+ act +'&pptp_user='+ f.pptp_user.value +'&pptp_pass='+ f.pptp_pass.value +'&pptp_server='+ f.pptp_server.value +'&pptp_mppe='+ (f.pptp_mppe.checked?'1':'0') +'&pptp_stateful='+ (f.pptp_stateful.checked?'1':'0') +'&_http_id='+nvram.http_id);
}

function init(){ f=E('_fom'); new vpnStatus(); }
// /* END SABAI PPTP JS */

</script></head><body onload='init();' id='topmost'>
<table id='container' cellspacing=0><tr><td colspan=2 id='header'>
<a id='headlink' href='http://www.sabaitechnology.com'><img src='imgsabai.png' id='headlogo'></a>
<div class='title' id='SVPNstatus'><% sabaid(); %></div><div class='version' id='subversion'>version <!-- SABAI-VERSION --></div></td></tr>
<tr id='body'><td id='navi'><% sabaaiMenu(); %></td><td id='content'>

<!-- / / / -->

<!-- BEGIN SABAI PPTP HTML -->

<form id='_fom'>
<div class='section-title'>PPTP Setup</div><div class='section notail'><script type='text/javascript'>
createFieldTable('', [
{ title: 'Server', name: 'pptp_server', maxlen:64, size:66, type: 'text', value: nvram.pptp_server },
{ title: 'Username', name: 'pptp_user', maxlen:64, size:66, type: 'text', value: nvram.pptp_user },
{ title: 'Password', name: 'pptp_pass', maxlen:64, size:66, type: 'password', peekaboo: 1, value: nvram.pptp_pass },
{ title: 'Require MPPE-128', name: 'pptp_mppe', type: 'checkbox', value: nvram.pptp_mppe!='0' },
{ title: 'MPPE-Stateful', name: 'pptp_stateful', type: 'checkbox', value: nvram.pptp_stateful!='0' },
{ title: '', hidden: true, suffix: '<span id="processing">Processing...</span><img style="float: right" src="imgspin.gif">', rid: 'reg_spin' }
]); //</script></div>

<div class='controlButtons'>
<input type='button' value='Start' onclick='PPTPsave(1)'>
<input type='button' value='Stop' onclick='PPTPsave(2)'>
<input type='button' value='Erase' onclick='PPTPsave(3)'>
<input type='button' value='Save' onclick='PPTPsave(0)'>
<input type='button' value='Cancel' onclick='javascript:reloadPage();'>
<input type='button' value='Help' onclick='window.open("http://www.sabaitechnology.com/v/sabaiHelp/help.html#pptp","_newtab");'><br>
<table><tbody><tr><td id='footer' colspan=2><span id='footer-msg'></span></td></tr></tbody></table></div>
</form>

<!-- END SABAI PPTP HTML -->

<!-- / / / -->

</td></tr></table>
</body></html>
