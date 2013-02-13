<!DOCTYPE HTML PUBLIC '-//W3C//DTD HTML 4.0//EN'>
<html>
<head>
<meta http-equiv='content-type' content='text/html;charset=utf-8'>
<meta name='robots' content='noindex,nofollow'>
<title>[<% ident(); %>] Activation</title><link rel='stylesheet' type='text/css' href='sabai.css'>
<style type='text/css'>
</style>
<script type='text/javascript' src='tomato.js'></script>
<script type='text/javascript' src='sabai.jsx?_http_id=<% nv(http_id); %>'></script>
<script type='text/javascript'>
// // /* BEGIN REGISTRATION JS */
var info, f;
var pro={ msg: '<% sabaaiMSG() %>', lic: '<% nv('srcnvrl'); %>', mac: ( ('<% lanMac(); %>'.toUpperCase())==('<% nv("et0macaddr"); %>'.toUpperCase()) ), sabai: ('<% isitsabai(); %>'==='true') };

function report(text){ E('infobox').innerHTML = text; }
function get(script,action,process){ async(true); que.drop(script, function(text){ async(false); process(JSON.parse(text)); }, action ); }
function finished(res){ if(res.sabai){ location.reload(); }else{ if(res.msg && res.msg!='') report(res.msg); } }

function program(){ get('activate.sh', 'program '+pro.msg, finished ); }

function useToken(){ if(f.act_token.value.length==0) report('Please enter a valid token.'); else get('activate.sh', 'gotToken '+ f.act_token.value, finished ); }
function manualReply(res){ if(!res || !res.sabai){ report(res?res.msg:'Error 43.'); return; }; f.act_code.value=res.msg; peek('manualSection',true); peek('autoSection',false); }
function activate(manual){ if(f.act_email.value.length==0){ report('Please enter a valid e-mail address.  Note: your activation code will be sent to this e-mail address.'); return; }
 get('activate.sh', (manual?'manual ':'activate ')+pro.msg+','+f.act_email.value, (manual?manualReply:finished) );
}

function init(){ peek('actLink',true); f=E('fom'); E('remacs').innerHTML=(pro.mac?'':' &iexcl;MAC mismatch!'); peek(pro.lic==''?'activateButton':'programButton',false);
}
// /* END REGISTRATION JS */

</script></head><body onload='init();' id='topmost'><form id='fom'><table id='container' cellspacing=0>
<tr><td colspan=2 id='header'><a id='headlink' href='http://www.sabaitechnology.com'><img src='imgsabai.png' id='headlogo'></a>
<div class='title' id='SVPNstatus'><% sabaid(); %></div><div class='version' id='subversion'>version <!-- SABAI-VERSION --></div></td></tr>
<tr id='body'><td id='navi'><% sabaaiMenu(); %></td><td id='content'>

<!-- / / / -->

<!-- BEGIN REGISTRATION HTML -->
<div class='section-title'>Sabai Router Registration<span id='remacs' style='font-size: 12px;'></span></div>

<div class='section' id='autoSection'>
<script type='text/javascript'>
createFieldTable('', [
	{ title: 'E-mail', hidden: (pro.sabai), rid: 'emailRow', name: 'act_email', type: 'text', maxlen: 256, size: 30, value: '' },
	{ title: '', hidden: pro.sabai, suffix:
 "<input id='activateButton' value='Activate' onclick='activate(false);' type='button'> "+
 "<input id='manualButton' value='Activate Manually' onclick='activate(true);' type='button'> "+
 "<input id='programButton' value='Program' onclick='program();' type='button'>"
 },
	{ text: 'Please enter a valid e-mail address to register your router. Note: your activation code will be sent to this e-mail address.',  hidden: pro.sabai },
	{ title: 'Processing...', hidden: true, rid: 'reg_spin', suffix: '<img src="imgspin.gif">' },
	{ text: 'Your Sabai router is now activated!',  hidden: (!pro.sabai) },
	{ title: 'Go to', hidden: (!pro.sabai),
 suffix:
 "<input value='PPTP' onclick='location.pathname=\"/sabai-pptp.asp\"' type='button'> "+
 "<input value='OpenVPN' onclick='location.pathname=\"/sabai-ovpn.asp\"' type='button'>"
 },

]);
</script>

</div>

<div class='section hidey' id='manualSection'>
<script type='text/javascript'>
createFieldTable('', [
	{ title: 'Code', rid: 'row_code', suffix:
 "<textarea id='act_code' readonly='readonly' onclick='this.select();' style='width: 100%; height: 6em'></textarea>"+
 "<br>Please enter the activation token you received or give the contents of the code box to your support representative; they will retrieve your token."
 },
	{ title: 'Activation Token', rid: 'row_token', name: 'act_token', type: 'text', size: '60' },
	{ title: '', hidden: pro.sabai, suffix:
 "<input id='activateButton' value='Activate' onclick='useToken();' type='button'> "
 },
	{ title: 'Processing...', hidden: true, rid: 'reg_spin', suffix: '<img src="imgspin.gif">' },
]);
</script>

</div>

<span id='infobox'></span>
<span id='actCodeInfo'>You may contact <a>activation@sabaitechnology.com</a> for assistance with the activation process.</span>
<br><br><a href='http://sabaitechnology.zendesk.com'>Technical Support</a>
<!-- END REGISTRATION HTML -->

<!-- / / / -->

</td></tr></table>
</body></html>
