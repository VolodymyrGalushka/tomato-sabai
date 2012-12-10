<!DOCTYPE HTML PUBLIC '-//W3C//DTD HTML 4.0//EN'>
<html>
<head>
<meta http-equiv='content-type' content='text/html;charset=utf-8'>
<meta name='robots' content='noindex,nofollow'>
<title id='VPN_TYPE'>[<% ident(); %>] SabaiVPN</title><link rel='stylesheet' type='text/css' href='sabai.css'>
<style type='text/css'>
</style>
<script type='text/javascript' src='tomato.js'></script>
<script type='text/javascript' src='sabaivpn.jsx?_http_id=<% nv(http_id); %>'></script>
<script type='text/javascript'>
<% isitsafe(); %>
// // /* BEGIN REGISTRATION JS */
var info, f, ls, acc;

//var pro={ sub: '<% nv("wan_gateway_get"); %>'=='192.168.222.1', msg: '<% sabaaiMSG() %>', lic: '<% nv('srcnvrl'); %>', act: '<% nv('srcnvrv'); %>' };
var pro={ sub: true, msg: '<% sabaaiMSG() %>', lic: '<% nv('srcnvrl'); %>', act: '<% nv('srcnvrv'); %>' };

function async(state){ E('reg_spin').style.display = state?'':'none'; for(var i=0; i<f.elements.length; i++){ f.elements[i].disabled = state; } }
function get(script,action,process){ async(true); que.drop(script, function(text){ async(false); process(JSON.parse(text)); }, action ); }

function skipToken(){ var skip=(f.skip.value=='0'); f.skip.value=(skip?'1':'0'); E('row_email').style.display=(skip?'none':''); E('row_token').style.display=(skip?'':'none'); E('skip_button').value=(skip?'Back: I need':'Skip: I have') +' an Activation Token'; }

function finished(res){ if(res.sabai){ location.reload(); }else{ if(res.msg!='') report(res.msg); } }

function manualReply(res){ acc.value='"'+res.msg+'"'; E('row_code').style.display=''; E('row_status').style.display='none'; E('skip_button').style.display='none'; skipToken(); report("Please give the contents of the Code box to your support representative; they will retrieve your Activation Token."); }
function manualActivation(){ get('register.sh', 'manual '+pro.msg+','+f.act_email.value, manualReply ); }

function activate(){ if(f.skip.value=='1'){ if(f.act_token.value.length==0){ report('Please enter an Activation Token.'); }else get('register.sh', 'gotToken '+f.act_token.value, finished ); }else{ if(pro.lic==''){ manualActivation(); }else{ get('register.sh', 'activate '+ pro.msg+','+f.act_email.value, finished ); } } }
function getInit(){ f.step.value=(pro.lic==''?'program':'activate'); if(pro.act!='') return; if((pro.lic=='') && pro.sub) get('register.sh', 'program '+pro.msg, finished ); }

function report(text){ E('infobox').innerHTML = text; }
function verifyFields(){}
function init(){ f=E('fom'); ls=E('license_status'); acc=E('activation_code'); getInit(); }
// /* END REGISTRATION JS */

</script></head><body onload='init();' id='topmost'><form id='fom'><table id='container' cellspacing=0>
<tr><td colspan=2 id='header'><a id='headlink' href=''><img src='' id='headlogo'></a>
<div class='title' id='SVPNstatus'>Sabai</div><div class='version' id='subversion'>version <!-- SABAI-VERSION --></div></td></tr>
<tr id='body'><td id='navi'><script type='text/javascript'>navi()</script></td><td id='content'>

<!-- / / / -->

<!-- BEGIN REGISTRATION HTML -->
<div class='section-title'>Sabai Router Registration<span id='remacs' style='color: red; font-size: 12px;'></span></div><div class='section'>
<input type='hidden' name='step' value='program'>
<input type='hidden' name='skip' value='0'>
<script type='text/javascript'>
createFieldTable('', [
	{ title: '', rid: 'row_status', hidden: (pro.act!=''||pro.lic!=''), suffix: "<span style='font-weight: bold'>This router <span style='color: red'>needs</span> an Initialization Token.</span>" },
	{ title: 'E-mail', hidden: (pro.act!=''), rid: 'row_email', name: 'act_email', type: 'text', maxlen: 256, size: 30, value: '' },
	{ title: 'Activation Token', hidden: true, rid: 'row_token', name: 'act_token', type: 'text', size: '60' },
	{ title: '', hidden: (pro.act!=''&&pro.lic!=''),
 suffix: "<input id='req_button' value='Activate' onclick='activate();' type='button'> <input id='skip_button' value='Skip: I have an Activation Token' onclick='skipToken();' type='button'>" },

	{ title: 'Processing...', hidden: true, rid: 'reg_spin', suffix: '<img src="spin.gif">' },

	{ title: 'Code', hidden: true, rid: 'row_code', suffix: "<textarea id='activation_code' readonly='readonly' onclick='this.select();' style='width: 100%; height: 6em'></textarea>" },

	{ title: 'Go to', hidden: (pro.act==''), rid: 'row_choices',
 suffix: "<input value='PPTP' onclick='location.pathname=\"/sabaivpn-pptp.asp\"' type='button'> <input value='OpenVPN' onclick='location.pathname=\"/sabaivpn-ovpn.asp\"' type='button'>" },

]);
</script>

</div>

<span id='infobox'> </span>

<br><br><a href='http://sabaitechnology.zendesk.com'>Technical Support</a>
<!-- END REGISTRATION HTML -->

<!-- / / / -->

</td></tr></table>

<div id='hideme'><div class='centercolumncontainer'><div class='middlecontainer'>
 <div id='hiddentext'>Please wait...</div><br>
 <center><img src='./SabaiSpin.gif'></center>
</div>
</div></div>

</body></html>

