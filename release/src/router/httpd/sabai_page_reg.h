#ifndef SABAIVPN_PAGE_REG_H
#define SABAIVPN_PAGE_REG_H

	// reg_ is the page served when the router either has no registration code, or has an incorrect code.

char *sabai_reg[] = {
"['Activate','sabaivpn-act.asp']",
"// /* BEGIN REGISTRATION JS */\n\
var msg, f, regButton, canButton, whatReg=false;\n\
\n\
function receipt(text){ E('reg_spin').className = 'hiddenChildMenu'; regButton.disabled=''; canButton.disabled='';\n\
 eval(text);\n\
 if(!reg.sabai){ report(reg.msg); }else{\n\
  if(!whatReg){ swapReg(); E('_reg_code').value=reg.code; }\n\
  report('<br>Please take the time to note your registration code. You may need it in the case that your router needs to be fully reset or loses its settings.<br>Please visit the VPN page to begin.');\n\
  grabMenu();\n\
 }\n\
}\n\
\n\
function register(){\n\
 E('reg_spin').className = ''; regButton.disabled='disabled'; canButton.disabled='disabled';\n\
 que.drop('register.sh',receipt,(whatReg?'code':'info') +' '+ vpn_service+' '+ msg_sabaivpn +' '+ (whatReg ? f.reg_code.value : f.reg_email.value+','+f.reg_cid.value+','+f.reg_oid.value+' '+vpn_service+','+(f.reg_remind.checked?'1':0)) );\n\
}\n\
\n\
function report(text){ msg.innerHTML = text; }\n\
function toggleReminder(){ E('ifReminder').innerHTML=(E('_reg_remind').checked?'Send':'Don\\'t send'); }\n\
function swapReg(){ whatReg=!whatReg; E('infoReg').style.display=whatReg?'none':''; E('codeReg').style.display=whatReg?'':'none'; }\n\
function verifyFields(){}\n\
function init(){ msg = E('msg'); f=E('fom');\n\
 E('remacs').innerHTML=(isitsafe.nvmac.toUpperCase()==isitsafe.hwmac.toUpperCase()?'':' &iexcl;MAC mismatch!');\n\
 regButton=E('register_button'); canButton=E('cancel_button');\n\
}\n\
// /* END REGISTRATION JS */\n",
"<!-- BEGIN REGISTRATION HTML -->\n\
<div class='section-title'>Sabai Router Registration<span id='remacs' style='color: red; font-size: 12px;'></span></div><div class='section'>\n\
<div id='infoReg'><script type='text/javascript'>\n\
createFieldTable('', [\n\
	{ title: 'E-mail', name: 'reg_email', type: 'text', maxlen: 128, size: 30, value: uinf[0] },\n\
	{ title: 'Customer ID', name: 'reg_cid', type: 'text', maxlen: 10, size: 10, value: uinf[1] },\n\
	{ title: 'Order ID', name: 'reg_oid', type: 'text', maxlen: 10, size: 10, value: uinf[2], suffix: \"<input id='swapRegButton' value='Use Code' onclick='swapReg();' type='button'>\" },\n\
	{ text: \"<input type='checkbox' checked=checked id='_reg_remind' onchange='toggleReminder();' name='reg_remind'> <span id='ifReminder'>Send</span> me an e-mail with my registration code.\" }\n\
]);\n\
</script></div><div id='codeReg' style='display:none;'><script type='text/javascript'>\n\
createFieldTable('', [\n\
	{ title: 'Code', name: 'reg_code', type: 'text', maxlen: 30, size: 30, value: '', suffix: \"<input id='swapRegButton' value='Return' onclick='swapReg();' type='button'>\" }\n\
]);\n\
</script></div>\n\
</div>\n\
\n\
<span id='msg'>Thank you for purchasing a Sabai Technology integrated VPN router.<br>\n\
Please enter the e-mail you used when you purchased the router or upgrade, your Customer ID and Order ID.\n\
 (This information should be available in or on the packaging with your order and in your order e-mail confirmation.)<br>\n\
Alternatively, you may enter a registration code.<br></span><br>\n\
<img id='reg_spin' src='spin.gif' class='hiddenChildMenu'>\n\
<input value='Register' id='register_button' onclick='register();' type='button'>\n\
<input value='Cancel' id='cancel_button' onclick='window.location.reload();' type='button'>\n\
\n\
<br><br><a href='http://sabaitechnology.zendesk.com'>Technical Support</a>\n\
<!-- END REGISTRATION HTML -->\n\
"};

#endif
