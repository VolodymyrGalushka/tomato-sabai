<!DOCTYPE HTML PUBLIC '-//W3C//DTD HTML 4.0//EN'>
<html>
<head>
<meta http-equiv='content-type' content='text/html;charset=utf-8'>
<meta name='robots' content='noindex,nofollow'>
<title>[<% ident(); %>] OpenVPN</title><link rel='stylesheet' type='text/css' href='sabai.css'>
<style type='text/css'>
 #confPane { width: 100%; font: 10pt "Courier New",Monospace; border: 1px solid #C7C7C7; overflow: auto; }
 .ovpn_ta { width: 100%; font: 10pt "Courier New",Monospace; color: black; }
</style>
<script type='text/javascript' src='tomato.js'></script>
<script type='text/javascript' src='sabai.jsx?_http_id=<% nv(http_id); %>'></script>
<script type='text/javascript'>

// /* BEGIN SABAI OVPN JS */

var f, confEdit, confShow, editButton, showButton, logButton;
var ovpn = false; var changes = {}; var safe = { conf: false, auth: false };
var conf = nvram.ovpn_cf.replace(/\r/g,"").replace(/\n\n/g,"\n");
var nofile = (conf == '');
var keys={ ca: false, cert: false, key: false, 'tls-auth': false };

function restrain(el,aboo){ if(!Array.isArray(el)) el = [el]; for(var i=0; i<el.length; i++){ el[i]=E(el[i]); if(!el[i]) continue; el[i].disabled = aboo; } }

function uploadFile(){ var of=E('ovpnUpload'); var fe = of.file.value.substr(-5); if( fe!='.ovpn' && fe!='.conf' ){ report('Please supply a .conf or .ovpn file.'); return }; report("Processing file..."); form.addIdAction(of); of.submit(); }

function openvpn(act){
 if(act==3 && !confirm("Erase all OpenVPN settings?")) return; E('processing').innerHTML = ['Sav','Start','Stopp','Eras'][act] +'ing...'; async(true);
 que.drop('s_sabaiovpn.cgi',
  function(resp){ async(false); report( ((res = parseJson(resp)) && res.sabai) ? res.msg : 'Bad JSON in message.' ); if(res.sabai) location.reload(); },
  'fire='+ act + (safe.auth?'&ovpn_user='+ f.ovpn_user.value +'&ovpn_pass='+ f.ovpn_pass.value:'') + (safe.conf?'&ovpn_cf='+ escapeCGI(conf):'') +'&_http_id='+nvram.http_id
 );
}

function parseFile(){
 if(conf==''||ovpn!=false) return; ovpn=[]; var inline = [];
 var t;
 while(t = conf.match(/<([^>]*)>[^<]*<\/\1>/)){
  inline.push({ name: t[1], value: t[0].replace(/<\/?[^>]*>/g,'').trim(), disabled: false, x: true, f: false });
  conf=conf.replace(t[0],"").replace(new RegExp('\n'+ t[1] +' [^\n]*'),'').trim();
 }
 var cf = conf.split("\n"); var cfi, nin; while( (cfi = cf.shift()) != null){ if(cfi=='') continue; cfi = cfi.split(' '); var nin=(cfi[0]=='ca'|cfi[0]=='cert'|cfi[0]=='key'|cfi[0]=='tls-auth'); ovpn.push({ name: cfi[0].replace(/^;/,'').replace(/^#/,''), value: (cfi.length>1?cfi.slice(1).join(' '):false), disabled: (cfi[0][0] == ';' || cfi[0][0] == '#'), x: nin, f: nin }); }
 ovpn = ovpn.concat(inline); var frag = document.createDocumentFragment();
 for(var i=0; i<ovpn.length; i++){ ovpn[i].olddisabled = ovpn[i].disabled; ovpn[i].oldvalue = ovpn[i].value; if(ovpn[i].f) changes[i] = true; var nr = A('tr'); frag.appendChild(nr); nr.innerHTML = '<td class="title indent1"><input type="checkbox" onchange="alter(event,\'disabled\','+i+');"'+ (ovpn[i].disabled?'':' checked') +'> '+ ovpn[i].name +'</td><td class="content">'+ ( (ovpn[i].x || ovpn[i].f)?'<textarea rows="5" onchange="alter(event,\'value\','+i+');" class="ovpn_ta">'+ (ovpn[i].f?'#Paste contents of ':'') + ovpn[i].value +'</textarea>':(ovpn[i].value?'<input type="text" onchange="alter(event,\'value\','+i+');" size=33 value="'+ ovpn[i].value +'">':'') ) +'</td>'; }
 E('_editOvpn').parentNode.appendChild(frag);
}

function formFile(){
 report(''); restrain(['startButton','stopButton','eraseButton','saveButton'],false);
 safe = { conf: (Object.keys(changes).length!=0), auth: ((f.ovpn_user.value!=nvram.ovpn_user)||(f.ovpn_pass.value!=nvram.ovpn_pass)) }
 if(!safe.conf && !safe.auth){ report('No changes were made.'); confPane.innerHTML = escapeHTML(conf); peek('saveButton',false); return; }
 report('Click Save to keep these changes, Cancel to discard them.'); updateAuth(f.ovpn_user.value,f.ovpn_pass.value); peek('saveButton',true);
 if( !ovpn || !(ovpn.length>0) ){ report("Configuration error."); return; }
 var confLines = [], inline = [];
 for(var i=0; i<ovpn.length; i++){
//  if(ovpn[i].f && (ovpn[i].value == ovpn[i].oldvalue) ){ report("Please upload "+ ovpn[i].value +" or click Edit to provide its contents in the field below."); return; }
  if(ovpn[i].x){ inline.push('<'+ovpn[i].name+'>\n'+ ovpn[i].value +'\n</'+ovpn[i].name+'>'); }else{ confLines.push( (ovpn[i].disabled?';':'') + ovpn[i].name + (ovpn[i].value?' '+ovpn[i].value:'') ); }
  ovpn[i].oldvalue = ovpn[i].value; ovpn[i].olddisabled = ovpn[i].disabled;
 }
 conf = confLines.concat(inline).join('\n');
 confPane.innerHTML = escapeHTML(conf);
}

function alter(event, property, i){ ovpn[i][property] = (event.target.type == 'checkbox') ? ! event.target.checked : event.target.value; if ( (ovpn[i].value == ovpn[i].oldvalue) && (ovpn[i].disabled == ovpn[i].olddisabled) ) delete changes[i]; else changes[i] = true; }

function toggleEdit(){
 report(''); var swap=(editButton.value=='Edit'); editButton.value = ( swap ? 'Done' : 'Edit' );
 restrain(['startButton','stopButton','eraseButton','saveButton'],true);
 peek(confShow,!swap); peek('controlButtons',!swap); peek(confEdit,swap); if(swap) parseFile(); else formFile();
}

function uploadPieces(){
 uf=E('pieceUpload');
 for(var i=0; i<uf.elements.length; i++){
  if(uf.elements[i].value==''){ report("Missing "+ uf.elements[i].name +" file."); return; }
 }
 form.addIdAction(uf);
 uf.submit();
}

function checkInlines(){ if( (conf=='') || !conf.match(/\n(ca|cert|key|tls-auth) /g) ) return;
 test=false;
 txt=[]; frm=[];
 for(var i in keys){
  fi=conf.match(new RegExp('\n'+i +' [^\n]*'));
  li=conf.match(new RegExp('<'+i+'>[^<]*</'+i+'>'));
  if(fi && !li){
   test=true; keys[i] = fi[0].replace(/\n/,'').replace(new RegExp( '^'+i+' ') ,'');
   keyName = keys[i].split(' ').shift();
   txt.push( keyName );
   frm.push('<td>'+ i +': '+ keyName +"</td><td><input type='file' name='"+ i +"' size='50'></td>");
  }
 }
 if(!test) return;
 E('uploadRow').style.display = '';
// toggleShow(); toggleEdit();
 E('uploadList').innerHTML = txt.join(', ');
 E('uploadPieces').innerHTML = '<tr>'+frm.join('</tr><tr>') +'</tr>';
}

function updateLog(){ que.drop('ext/ovpn.txt',function(resp){ if(resp!='') E('logPane').innerHTML = escapeHTML(resp); }); }
function toggleLog(){ report(''); var swap=(logButton.value=='Show Log'); logButton.value = ( swap ? 'Hide' : 'Show' )+' Log'; peek(logShow,swap); if(swap) updateLog(); }
function toggleShow(){ report(''); var swap=(showButton.value=='Show File'); showButton.value = ( swap ? 'Hide' : 'Show' )+' File'; peek(editButton,swap); peek(confShow,swap); }
function updateAuth(user,pass){ user = user || nvram.ovpn_user; pass = pass || nvram.ovpn_pass; E('authText').innerHTML = ( ( (user == '') && (pass == '') )?'None': user +'/'+ pass.replace(/./g,'*') ); }

function checkMessages(){ if(E('sabaiErrPre').childNodes.length >0){ E('sabaiErr').className=''; } }

function init(){ f=E('_fom');
 confShow=E('confShow'); confEdit=E('confEdit'); showButton=E('showButton'); logButton=E('logButton'); editButton=E('editButton'); uploadButton=E('uploadButton'); confPane=E('confPane');
 peek('controlButtons',!nofile); restrain(['startButton','stopButton','eraseButton','logButton'],nofile); checkMessages(); updateAuth(); checkInlines();
 new vpnStatus();
}
// /* END SABAI OVPN JS */

function report(text){ E('message_row').style.display = (text==''?'none':''); E('message').innerHTML = text; }
//function rebug(text){ E('testing').innerHTML = text; }
</script></head><body onload='init();' id='topmost'>
<table id='container' cellspacing=0><tr><td colspan=2 id='header'>
<a id='headlink' href='http://www.sabaitechnology.com'><img src='imgsabai.png' id='headlogo'></a>
<div class='title' id='SVPNstatus'><% sabaid(); %></div><div class='version' id='subversion'>version <!-- SABAI-VERSION --></div></td></tr>
<tr id='body'><td id='navi'><% sabaaiMenu(); %></td><td id='content'>

<!-- / / / -->

<!-- BEGIN SABAI OVPN HTML -->

<div class='section-title'>OpenVPN Setup</div>
<div id='sabaiErr' class='hidey'>The following errors were encountered when attempted to parse OpenVPN control files:<br><pre id='sabaiErrPre'><% sabaiErr("ovpn"); %></pre></div>
<div class='section notail'><script type='text/javascript'>
createFieldTable('', [
{ title: 'Upload File', rid: 'ovpnUploadFile', hidden: !nofile, suffix: "<form id='ovpnUpload' method='post' action='s_ovpn_get.cgi' encType='multipart/form-data'><input type='file' name='file' onchange='uploadFile();' size='50' style='height:20px'></form>" },
{ title: 'Current File', rid: 'ovpnUploadCurrent', text: nvram.ovpn_file, hidden: nofile },
{ title: '', hidden: true, suffix: '<span id="processing">Processing...</span><img style="float: right" src="imgspin.gif">', rid: 'reg_spin' },
{ title: '', rid: 'message_row', hidden: true, text: '<span id="message"></span>' },
{ title: '', rid: 'uploadRow', hidden: true, text: 'The following files are required to complete setup: <span id="uploadList"></span>; please upload them.<form id="pieceUpload" method="post" action="s_ovpn_parts.cgi" encType="multipart/form-data"><table id="uploadPieces"></table><input type="button" onclick=\"uploadPieces();\" value="Upload" style="float: right;"></form>' }
]); //</script></div>

<form id='_fom'>
<div class='controlButtons'>
<input type='button' id='startButton' value='Start' onclick='openvpn(1)'>
<input type='button' id='stopButton' value='Stop' onclick='openvpn(2)'>
<input type='button' id='eraseButton' value='Erase' onclick='openvpn(3)'>
<input type='button' value='Show Log' id='logButton' onclick="toggleLog();">
<input type='button' value='Show File' id='showButton' onclick="toggleShow();">
<input type='button' value='Edit' id='editButton' onclick="toggleEdit();" class='hidey'>
<input type='button' value='Save' onclick='openvpn(0)' id='saveButton' class='hidey'>
<input type='button' value='Cancel' onclick='location.reload();'>
</div>

<div class='section hidey' id='confShow'><script type='text/javascript'>
createFieldTable('', [
{ title: 'Username/Password', text: '<span id="authText"></span>' },
{ text: '<pre id="confPane">'+ conf.replace(/</g,"&lt;").replace(/>/g,"&gt;") +'</pre>' }
]); //</script></div>
<div class='section hidey' id='confEdit'><script type='text/javascript'>
createFieldTable('', [
{ title: 'Username/Password', multi: [
 { title: 'Username', name: 'ovpn_user', maxlen:64, size:33, type: 'text', value: nvram.ovpn_user, suffix: ' / ' },
 { title: 'Password', name: 'ovpn_pass', maxlen:64, size:33, type: 'password', peekaboo: 1, value: nvram.ovpn_pass }
] },
{ title: '', hidden: nofile, text: '', rid: '_editOvpn', hidden: true },
]); //</script></div>

<div class='section hidey' id='logShow'><script type='text/javascript'>
createFieldTable('', [
{ title: 'OpenVPN Log', text: "<input type='button' value='Update Log' onclick=\"updateLog();\">" },
{ text: '<pre id="logPane">Log Empty.</pre>' }
]); //</script></div>

</form>
<!-- pre id="testing"></pre -->
<!-- END SABAI OVPN HTML -->

<!-- / / / -->

</td></tr></table>
</body></html>
