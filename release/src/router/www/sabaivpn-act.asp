<!DOCTYPE HTML PUBLIC '-//W3C//DTD HTML 4.0//EN'>
<html>
<head>
<meta http-equiv='content-type' content='text/html;charset=utf-8'>
<meta name='robots' content='noindex,nofollow'>
<title id='VPN_TYPE'>[<% ident(); %>] SabaiVPN</title><link rel='stylesheet' type='text/css' href='sabai.css'>
<script type='text/javascript' src='tomato.js'></script>
<script type='text/javascript' src='sabaivpn.jsx?_http_id=<% nv(http_id); %>'></script>
<script type='text/javascript'>
<% isitsafe(); %>
// // /* BEGIN REGISTRATION JS */
var msg, f, regButton, canButton, whatReg=false;

var pro={ lic: '<% nv('srcnvrl'); %>', tok: '<% nv('srcnvrt'); %>'};

function skipLicense(){ E('row_prep').style.display='none'; E('row_email').style.display=''; }
function skipToken(skip){ if( skip && f.act_email.value.length==0 ){ report('Please enter a valid e-mail address.'); return; };
 E('row_email').style.display=(skip?'none':''); E('row_token').style.display=(skip?'':'none');
}

function getLicense(){ async(); que.drop('activate.sh',receipt, 'license' ); }

function getToken(){ async();
 if( f.act_email.value.length==0 ){ report('Please enter a valid e-mail address.'); return; }
 que.drop('activate.sh',receipt, 'token '+ f.act_email.value );
}

function useToken(){ async();
 if( f.act_token.value.length==0 ){ report('Please enter a token.'); return; }
 que.drop('activate.sh',receipt, 'register '+ f.act_email.value +' '+ f.act_token.value );
}

function receipt(text){ E('reg_spin').className = 'hiddenChildMenu'; regButton.disabled=''; canButton.disabled='';
 eval(text);
 if(!reg.sabai){ report(reg.msg); }else{
  if(!whatReg){ swapReg(); E('_reg_code').value=reg.code; }
  report('<br>Please take the time to note your registration code. You may need it in the case that your router needs to be fully reset or loses its settings.<br>Please visit the VPN page to begin.');
  grabMenu();
 }
}

function async(){ E('reg_spin').style.display = '';
 for(var i=0; i<f.elements.length; i++){ f.elements[i].disabled = true; }
}
// que.drop('activate.sh',receipt,(whatReg?'code':'info') +' '+ vpn_service+' '+ msg_sabaivpn +' '+ (whatReg ? f.reg_code.value : f.reg_email.value+','+f.reg_cid.value+','+f.reg_oid.value+' '+vpn_service+','+(f.reg_remind.checked?'1':0)) );

function report(text){ msg.innerHTML = text; }

function verifyFields(){}

function init(){ msg = E('msg'); f=E('fom');
 E('remacs').innerHTML=(isitsafe.nvmac.toUpperCase()==isitsafe.hwmac.toUpperCase()?'':' &iexcl;MAC mismatch!');
 E(pro.lic==''?'row_prep':'row_email').style.display='';
}
// /* END REGISTRATION JS */

</script></head><body onload='init();' id='topmost'><form id='fom'><table id='container' cellspacing=0>
<tr><td colspan=2 id='header'><a id='headlink' href=''><img src='' id='headlogo'></a>
<div class='title' id='SVPNstatus'>Sabai</div><div class='version' id='subversion'>version <% sabaiversion(); %></div></td></tr>
<tr id='body'><td id='navi'><script type='text/javascript'>navi()</script></td><td id='content'>

<!-- / / / -->

<!-- BEGIN REGISTRATION HTML -->
<div class='section-title'>Sabai Router Registration<span id='remacs' style='color: red; font-size: 12px;'></span></div><div class='section'>
<script type='text/javascript'>
createFieldTable('', [
	{ title: 'Processing...', hidden: true, rid: 'reg_spin', suffix: '<img src="spin.gif">' },
	{ title: 'Prepare', hidden: true, rid: 'row_prep', type: 'hidden',
 suffix: "<input value='Request License' onclick='getLicense();' type='button'> <input value='I have a license' onclick='skipLicense();' type='button'>" },
	{ title: 'E-mail', hidden: true, rid: 'row_email', name: 'act_email', type: 'text', maxlen: 256, size: 30,
 suffix: "<br><br><input value='Request Token' onclick='getToken();' type='button'> <input value='I have a Token' onclick='skipToken(true);' type='button'>" },
	{ title: 'Activation Token', hidden: true, rid: 'row_token', name: 'act_token', type: 'text', maxlen: 128, size: 60,
 suffix: "<br><br><input value='Use Token' onclick='useToken();' type='button'> <input value='I need a Token' onclick='skipToken(false);' type='button'>" },


]);
</script>

</div>

<span id='msg'>Thank you for purchasing a Sabai Technology integrated VPN router.<br>
Please enter the e-mail you used when you purchased the router or upgrade, your Customer ID and Order ID.
 (This information should be available in or on the packaging with your order and in your order e-mail confirmation.)<br>
Alternatively, you may enter a registration code.<br></span><br>

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

