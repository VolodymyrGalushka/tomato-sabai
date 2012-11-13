<!DOCTYPE HTML PUBLIC '-//W3C//DTD HTML 4.0//EN'><html><head><meta http-equiv='content-type' content='text/html;charset=utf-8'><meta name='robots' content='noindex,nofollow'>
<title>[<% ident(); %>] Sabai Debugging Page</title>
<link rel='stylesheet' type='text/css' href='sabai.css'>
<script type='text/javascript' src='tomato.js'></script>
<style type='text/css'>
 #nvram_content { width: 95%; height: 300px; }
 .section-title a { color: red; font-size: 12px; }
</style>
<script type='text/javascript'>
function verifyFields(){  };
<% nvram("t_model_name,log_file,et0macaddr,remote_management,remote_mgt_https,sshd_eas,sshd_remote,sshd_pass,web_wl_filter,dmz_enable,dmz_ipaddr,dmz_sip"); %>
<% uptime(); %>
<% sysinfo(); %>
<% wlstats(); %>
<% nvstat(); %>
<% isitsafe(); %>
var lipp = '<% lipp(); %>.';

function NVRAMresetButton(){
	var i = E('restore-mode').value;
	if(i==0){ return; }
	if((i == 2) && (features('!nve'))){
		if (!confirm('WARNING: Erasing the NVRAM on a ' + nvram.t_model_name + ' router may be harmful. It may not be able to re-setup the NVRAM correctly after a complete erase. Proceeed anyway?')){ return; }
	}
	if (!confirm('Are you sure?')){ return; }
	E('reset-button').disabled = 1;
	form.submit('aco-reset-form');
}

function DMZsave(){ var fom; var en; var s;
	function DMZverifyFields(){
		var sip, dip, off; off = !E('_f_dmz_enable').checked; dip = E('_f_dmz_ipaddr'); dip.disabled = off; sip = E('_f_dmz_sip'); sip.disabled = off;
		if(off){ ferror.clearAll(dip, sip); return 1; }; if(dip.value.indexOf('.') == -1){ dip.value = lipp + dip.value; }
		if(!v_ip(dip)){ return 0; }; if((sip.value.length) && (!v_iptaddr(sip, false, 15))){ return 0; }
		ferror.clear(sip); return 1;
	}
	if(!DMZverifyFields(null, false)){ return; }
	fom = E('_fom'); en = fom.f_dmz_enable.checked; fom.dmz_enable.value = en ? 1 : 0;
	if(en){ s = fom.f_dmz_ipaddr.value; fom.dmz_ipaddr.value = (s.indexOf(lipp) == 0) ? s.replace(lipp, '') : s; }
	fom.dmz_sip.value = fom.f_dmz_sip.value.split(/\s*,\s*/).join(','); form.submit(fom, 0);
}

function toggleLogging(){ que.drop('tomato.cgi',window.location.reload,'?_service=logging-restart&log_file=' +( (nvram.log_file==1) ? '0':'1')+ '&_http_id='+nvram.http_id); }

function toggleField(event,field){ dhis = event.target; state = (dhis.value.substr(0,4)=='Show');
 dhis.value = ((state)?'Hide ':'Show ') + field + ' value';
 var dval = E('s_'+field);
 dval.innerHTML = ((!state)?'':nvram[field]); dval.className = ((state)?'':'hiddenChildMenu');
}

function showAllNvram(event){ que.drop('shell.cgi',function(text){ eval(text); var nvc=E('nvram_content'); nvc.className=''; nvc.innerHTML = cmdresult; },'action=execute&command=nvram%20show&_http_id='+nvram.http_id); }

</script></head><body>
<table id='container' cellspacing=0>
<tr><td colspan=2 id='header'><a id='headlink' href=''><img src='' id='headlogo'></a>
<div class='title' id='SVPNstatus'>Sabai</div><div class='version' id='subversion'>version <% sabaiversion(); %></div></td></tr>
<tr id='body'><td id='navi'><script type='text/javascript'>navi()</script></td><td id='content'>

<div class='section-title'>MACs <a href='./advanced-mac.asp' target='_new'>More Settings</a></div><div class='section'>
<script> createFieldTable('', [
 { title: 'Hardware MAC:', text: isitsafe.hwmac },
 { title: 'NVRAM MAC:', text: nvram.et0macaddr }
]); //</script></div>

<div class='section-title'>Syslog <a href='./admin-log.asp' target='_new'>More Settings</a></div><div class='section'><script type='text/javascript'>
createFieldTable('', [ {
 title: 'Logging is '+((nvram.log_file==1) ? 'on' : 'off')+'.', name: 'f_log_file',
 suffix: '<input type=\'button\' onclick=\'toggleLogging()\' value=\''+ ((nvram.log_file==1) ? 'Stop' : 'Start')+' Logging\'>' } ]); //</script>
</div>

<div class='section-title'>NVRAM Configuration <a href='./admin-config.asp' target='_new'>Backup/Restore</a></div><div class='section'>
<input onclick="showAllNvram(event)" value="Show all NVRAM values." type="button"><br>
<textarea class='hiddenChildMenu' id='nvram_content'></textarea>
</div>

<div class='section-title'>Adminstrative Access <a href='./admin-access.asp' target='_new'>FixIt</a></div><div class='section'><script type='text/javascript'>
createFieldTable('', [
	{ text: 'Web Interface Remote Access' + ((nvram.remote_management==0)?' is disabled.':' via '+( (nvram.remote_mgt_https==1)?'HTTPS':'HTTP' )+' is enabled.')+'  Web Interface Wireless Access is '+((nvram.web_wl_filter==0)?'disabled.':'enabled.') },
	{ text: 'SSH Daemon '+((nvram.sshd_eas==1)?'':'not ')+'Enabled at Startup and '+((nvram.sshd_remote==1)?'allows':'does not allow')+' remote login.  SSH '+((nvram.sshd_pass==1)?'allows':'does not allow')+' password login.' }
]);
</script>
</div>

<div class='section-title'>DMZ <a href='./forward-dmz.asp' target='_new'>FixIt</a></div><div class='section'>
<script type='text/javascript'>createFieldTable('', [
	{ text: 'DMZ is '+( (nvram.dmz_enable != '1') ? 'disabled':'enabled for '+((nvram.dmz_ipaddr.indexOf('.')!=-1)?nvram.dmz_ipaddr:(lipp+nvram.dmz_ipaddr))+((nvram.dmz_sip.length>0)?'; IP Restrictions: '+nvram.dmz_sip:'')) } ]); 
//</script></div>

<!-- END DEBUG PAGE -->
</td></tr>
</table>
</body>
</html>
