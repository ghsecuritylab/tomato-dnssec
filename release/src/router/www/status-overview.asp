<!DOCTYPE HTML PUBLIC '-//W3C//DTD HTML 4.0//EN'>
<!--
	Tomato GUI
	Copyright (C) 2006-2010 Jonathan Zarate
	http://www.polarcloud.com/tomato/

	Tomato VLAN GUI
	Copyright (C) 2011 Augusto Bott
	http://code.google.com/p/tomato-sdhc-vlan/

	For use with Tomato Firmware only.
	No part of this file may be used without permission.
-->
<html>
<head>
<meta http-equiv='content-type' content='text/html;charset=utf-8'>
<meta name='robots' content='noindex,nofollow'>
<title>[<% ident(); %>] Status: Overview</title>
<link rel='stylesheet' type='text/css' href='tomato.css'>
<% css(); %>
<script type='text/javascript' src='tomato.js'></script>
<script type='text/javascript' src='interfaces.js'></script>

<!-- / / / -->

<style type='text/css'>
.controls {
	width: 90px;
	margin-top: 5px;
	margin-bottom: 10px;
}
</style>

<script type='text/javascript' src='debug.js'></script>

<script type='text/javascript'>
wmo = {'ap':'Access Point','sta':'Wireless Client','wet':'Wireless Ethernet Bridge','wds':'WDS'};
auth = {'disabled':'-','wep':'WEP','wpa_personal':'WPA Personal (PSK)','wpa_enterprise':'WPA Enterprise','wpa2_personal':'WPA2 Personal (PSK)','wpa2_enterprise':'WPA2 Enterprise','wpaX_personal':'WPA / WPA2 Personal','wpaX_enterprise':'WPA / WPA2 Enterprise','radius':'Radius'};
enc = {'tkip':'TKIP','aes':'AES','tkip+aes':'TKIP / AES'};
bgmo = {'disabled':'-','mixed':'Auto','b-only':'B Only','g-only':'G Only','bg-mixed':'B/G Mixed','lrs':'LRS','n-only':'N Only'};

lastjiffiestotal = 0;
lastjiffiesidle = 0;
lastjiffiesusage = 100;
</script>

<script type='text/javascript' src='wireless.jsx?_http_id=<% nv(http_id); %>'></script>
<script type='text/javascript' src='status-data.jsx?_http_id=<% nv(http_id); %>'></script>

<script type='text/javascript'>
show_dhcpc = ((nvram.wan_proto == 'dhcp') || (((nvram.wan_proto == 'l2tp') || (nvram.wan_proto == 'pptp')) && (nvram.pptp_dhcp == '1')));
show_codi = ((nvram.wan_proto == 'pppoe') || (nvram.wan_proto == 'l2tp') || (nvram.wan_proto == 'pptp') || (nvram.wan_proto == 'ppp3g'));

show_radio = [];
for (var uidx = 0; uidx < wl_ifaces.length; ++uidx) {
/* REMOVE-BEGIN
//	show_radio.push((nvram['wl'+wl_unit(uidx)+'_radio'] == '1'));
REMOVE-END */
	if (wl_sunit(uidx)<0)
		show_radio.push((nvram['wl'+wl_fface(uidx)+'_radio'] == '1'));
}

nphy = features('11n');

function dhcpc(what)
{
	form.submitHidden('dhcpc.cgi', { exec: what, _redirect: 'status-overview.asp' });
}

function serv(service, sleep)
{
	form.submitHidden('service.cgi', { _service: service, _redirect: 'status-overview.asp', _sleep: sleep });
}

function wan_connect()
{
	serv('wan-restart', 5);
}

function wan_disconnect()
{
	serv('wan-stop', 2);
}

function wlenable(uidx, n)
{
	form.submitHidden('wlradio.cgi', { enable: '' + n, _nextpage: 'status-overview.asp', _nextwait: n ? 6 : 3, _wl_unit: wl_unit(uidx) });
}

var ref = new TomatoRefresh('status-data.jsx', '', 0, 'status_overview_refresh');

ref.refresh = function(text)
{
	stats = {};
	try {
		eval(text);
	}
	catch (ex) {
		stats = {};
	}
	show();
}


function c(id, htm)
{
	E(id).cells[1].innerHTML = htm;
}

function show()
{
	c('cpu', stats.cpuload);
	c('cpupercent', stats.cpupercent);
	c('uptime', stats.uptime);
	c('time', stats.time);
	c('wanip', stats.wanip);
	c('wanprebuf',stats.wanprebuf); //Victek
	c('wannetmask', stats.wannetmask);
	c('wangateway', stats.wangateway);
	c('dns', stats.dns);
	c('memory', stats.memory);
	c('swap', stats.swap);
	elem.display('swap', stats.swap != '');

/* IPV6-BEGIN */
	c('ip6_wan', stats.ip6_wan);
	elem.display('ip6_wan', stats.ip6_wan != '');
	c('ip6_lan', stats.ip6_lan);
	elem.display('ip6_lan', stats.ip6_lan != '');
	c('ip6_lan_ll', stats.ip6_lan_ll);
	elem.display('ip6_lan_ll', stats.ip6_lan_ll != '');
/* IPV6-END */

	c('wanstatus', stats.wanstatus);
	c('wanuptime', stats.wanuptime);
	if (show_dhcpc) c('wanlease', stats.wanlease);
	if (show_codi) {
		E('b_connect').disabled = stats.wanup;
		E('b_disconnect').disabled = !stats.wanup;
	}

	for (var uidx = 0; uidx < wl_ifaces.length; ++uidx) {
		if (wl_sunit(uidx)<0) {
			c('radio'+uidx, wlstats[uidx].radio ? 'Enabled' : '<b>Disabled</b>');
			c('rate'+uidx, wlstats[uidx].rate);
			if (show_radio[uidx]) {
				E('b_wl'+uidx+'_enable').disabled = wlstats[uidx].radio;
				E('b_wl'+uidx+'_disable').disabled = !wlstats[uidx].radio;
			}
			c('channel'+uidx, stats.channel[uidx]);
			if (nphy) {
				c('nbw'+uidx, wlstats[uidx].nbw);
			}
			c('interference'+uidx, stats.interference[uidx]);
			elem.display('interference'+uidx, stats.interference[uidx] != '');

			if (wlstats[uidx].client) {
				c('rssi'+uidx, wlstats[uidx].rssi || '');
				c('noise'+uidx, wlstats[uidx].noise || '');
				c('qual'+uidx, stats.qual[uidx] || '');
			}
		}
		c('ifstatus'+uidx, wlstats[uidx].ifstatus || '');
	}
}

function earlyInit()
{
	elem.display('b_dhcpc', show_dhcpc);
	elem.display('b_connect', 'b_disconnect', show_codi);
	if (nvram.wan_proto == 'disabled')
		elem.display('wan-title', 'sesdiv_wan', 0);
	for (var uidx = 0; uidx < wl_ifaces.length; ++uidx) {
		if (wl_sunit(uidx)<0)
			elem.display('b_wl'+wl_fface(uidx)+'_enable', 'b_wl'+wl_fface(uidx)+'_disable', show_radio[uidx]);
	}
	show();
}

function init() {
	var c;
	if (((c = cookie.get('status_overview_system_vis')) != null) && (c != '1')) toggleVisibility("system");
	if (((c = cookie.get('status_overview_wan_vis')) != null) && (c != '1')) toggleVisibility("wan");
	if (((c = cookie.get('status_overview_lan_vis')) != null) && (c != '1')) toggleVisibility("lan");
	for (var uidx = 0; uidx < wl_ifaces.length; ++uidx) {
		u = wl_fface(uidx);
		if (((c = cookie.get('status_overview_wl_'+u+'_vis')) != null) && (c != '1')) toggleVisibility("wl_"+u);
	}

	ref.initPage(3000, 3);
}

function toggleVisibility(whichone) {
	if (E('sesdiv_' + whichone).style.display == '') {
		E('sesdiv_' + whichone).style.display = 'none';
		E('sesdiv_' + whichone + '_showhide').innerHTML = '(Click here to show)';
		cookie.set('status_overview_' + whichone + '_vis', 0);
	} else {
		E('sesdiv_' + whichone).style.display='';
		E('sesdiv_' + whichone + '_showhide').innerHTML = '(Click here to hide)';
		cookie.set('status_overview_' + whichone + '_vis', 1);
	}
}
</script>

</head>
<body onload='init()'>
<form>
<table id='container' cellspacing=0>
<tr><td colspan=2 id='header'>
	<div class='title'>Tomato</div>
	<div class='version'>Version <% version(); %></div>
</td></tr>
<tr id='body'><td id='navi'><script type='text/javascript'>navi()</script></td>
<td id='content'>
<div id='ident'><% ident(); %></div>

<!-- / / / -->

<div class='section-title'>System <small><i><a href='javascript:toggleVisibility("system");'><span id='sesdiv_system_showhide'>(Click here to hide)</span></a></i></small></div>
<div class='section' id='sesdiv_system'>
<script type='text/javascript'>
createFieldTable('', [
	{ title: 'Name', text: nvram.router_name },
	{ title: 'Model', text: nvram.t_model_name },
	{ title: 'Chipset', text: stats.systemtype },
	{ title: 'CPU Freq', text: stats.cpumhz },
	{ title: 'Flash Size', text: stats.flashsize },
	null,
	{ title: 'Time', rid: 'time', text: stats.time },
	{ title: 'Uptime', rid: 'uptime', text: stats.uptime },
	{ title: 'CPU Load <small>(1 / 5 / 15 mins)</small>', rid: 'cpu', text: stats.cpuload },
	{ title: 'CPU Usage', rid: 'cpupercent', text: stats.cpupercent },
	{ title: 'Total / Free Memory', rid: 'memory', text: stats.memory },
	{ title: 'Total / Free Swap', rid: 'swap', text: stats.swap, hidden: (stats.swap == '') },
]);
</script>
</div>

<div class='section-title' id='wan-title'>WAN <small><i><a href='javascript:toggleVisibility("wan");'><span id='sesdiv_wan_showhide'>(Click here to hide)</span></a></i></small></div>
<div class='section' id='sesdiv_wan'>
<script type='text/javascript'>
createFieldTable('', [
	{ title: 'MAC Address', text: nvram.wan_hwaddr },
	{ title: 'Connection Type', text: { 'dhcp':'DHCP', 'static':'Static IP', 'pppoe':'PPPoE', 'pptp':'PPTP', 'l2tp':'L2TP', 'ppp3g':'3G Modem' }[nvram.wan_proto] || '-' },
	{ title: 'IP Address', rid: 'wanip', text: stats.wanip },
	{ title: 'Previous WAN IP', rid: 'wanprebuf', text: stats.wanprebuf, hidden: ((nvram.wan_proto != 'pppoe') && (nvram.wan_proto != 'pptp') && (nvram.wan_proto != 'l2tp') && (nvram.wan_proto != 'ppp3g')) }, //Victek
	{ title: 'Subnet Mask', rid: 'wannetmask', text: stats.wannetmask },
	{ title: 'Gateway', rid: 'wangateway', text: stats.wangateway },
/* IPV6-BEGIN */
	{ title: 'IPv6 Address', rid: 'ip6_wan', text: stats.ip6_wan, hidden: (stats.ip6_wan == '') },
/* IPV6-END */
	{ title: 'DNS', rid: 'dns', text: stats.dns },
	{ title: 'MTU', text: nvram.wan_run_mtu },
	null,
	{ title: 'Status', rid: 'wanstatus', text: stats.wanstatus },
	{ title: 'Connection Uptime', rid: 'wanuptime', text: stats.wanuptime },
	{ title: 'Remaining Lease Time', rid: 'wanlease', text: stats.wanlease, ignore: !show_dhcpc }
]);
</script>
<span id='b_dhcpc' style='display:none'>
	<input type='button' class='controls' onclick='dhcpc("renew")' value='Renew'>
	<input type='button' class='controls' onclick='dhcpc("release")' value='Release'> &nbsp;
</span>
<input type='button' class='controls' onclick='wan_connect()' value='Connect' id='b_connect' style='display:none'>
<input type='button' class='controls' onclick='wan_disconnect()' value='Disconnect' id='b_disconnect' style='display:none'>
</div>


<div class='section-title'>LAN <small><i><a href='javascript:toggleVisibility("lan");'><span id='sesdiv_lan_showhide'>(Click here to hide)</span></a></i></small></div>
<div class='section' id='sesdiv_lan'>
<script type='text/javascript'>

/* VLAN-BEGIN */
var s='';
var t='';
for (var i = 0 ; i <= MAX_BRIDGE_ID ; i++) {
	var j = (i == 0) ? '' : i.toString();
	if (nvram['lan' + j + '_ifname'].length > 0) {
		if (nvram['lan' + j + '_proto'] == 'dhcp') {
			if ((!fixIP(nvram.dhcpd_startip)) || (!fixIP(nvram.dhcpd_endip))) {
				var x = nvram['lan' + j + '_ipaddr'].split('.').splice(0, 3).join('.') + '.';
				nvram['dhcpd' + j + '_startip'] = x + nvram['dhcp' + j + '_start'];
				nvram['dhcpd' + j + '_endip'] = x + ((nvram['dhcp' + j + '_start'] * 1) + (nvram['dhcp' + j + '_num'] * 1) - 1);
			}
			s += ((s.length>0)&&(s.charAt(s.length-1) != ' ')) ? ', ' : '';
			s += '<a href="status-devices.asp">' + nvram['dhcpd' + j + '_startip'] + ' - ' + nvram['dhcpd' + j + '_endip'] + '</a> on LAN' + j + ' (br' + i + ')';
		} else {
			s += ((s.length>0)&&(s.charAt(s.length-1) != ' ')) ? ', ' : '';
			s += 'Disabled on LAN' + j + ' (br' + i + ')';
		}
		t += ((t.length>0)&&(t.charAt(t.length-1) != ' ')) ? ', ' : '';
		t += nvram['lan' + j + '_ipaddr'] + '/' + numberOfBitsOnNetMask(nvram['lan' + j + '_netmask']) + ' on LAN' + j + ' (br' + i + ')';
	}
}

createFieldTable('', [
	{ title: 'Router MAC Address', text: nvram.et0macaddr },
	{ title: 'Router IP Addresses', text: t },
	{ title: 'Gateway', text: nvram.lan_gateway, ignore: nvram.wan_proto != 'disabled' },
/* IPV6-BEGIN */
	{ title: 'Router IPv6 Address', rid: 'ip6_lan', text: stats.ip6_lan, hidden: (stats.ip6_lan == '') },
	{ title: 'IPv6 Link-local Address', rid: 'ip6_lan_ll', text: stats.ip6_lan_ll, hidden: (stats.ip6_lan_ll == '') },
/* IPV6-END */
	{ title: 'DNS', rid: 'dns', text: stats.dns, ignore: nvram.wan_proto != 'disabled' },
	{ title: 'DHCP', text: s }
]);
/* VLAN-END */

/* NOVLAN-BEGIN */
if (nvram.lan_proto == 'dhcp') {
	if ((!fixIP(nvram.dhcpd_startip)) || (!fixIP(nvram.dhcpd_endip))) {
		var x = nvram.lan_ipaddr.split('.').splice(0, 3).join('.') + '.';
		nvram.dhcpd_startip = x + nvram.dhcp_start;
		nvram.dhcpd_endip = x + ((nvram.dhcp_start * 1) + (nvram.dhcp_num * 1) - 1);
	}
	s = '<a href="status-devices.asp">' + nvram.dhcpd_startip + ' - ' + nvram.dhcpd_endip + '</a>';
}
else {
	s = 'Disabled';
}
createFieldTable('', [
	{ title: 'Router MAC Address', text: nvram.et0macaddr },
	{ title: 'Router IP Address', text: nvram.lan_ipaddr },
	{ title: 'Subnet Mask', text: nvram.lan_netmask },
	{ title: 'Gateway', text: nvram.lan_gateway, ignore: nvram.wan_proto != 'disabled' },
/* IPV6-BEGIN */
	{ title: 'Router IPv6 Address', rid: 'ip6_lan', text: stats.ip6_lan, hidden: (stats.ip6_lan == '') },
	{ title: 'IPv6 Link-local Address', rid: 'ip6_lan_ll', text: stats.ip6_lan_ll, hidden: (stats.ip6_lan_ll == '') },
/* IPV6-END */
	{ title: 'DNS', rid: 'dns', text: stats.dns, ignore: nvram.wan_proto != 'disabled' },
	{ title: 'DHCP', text: s }
]);
/* NOVLAN-END */

</script>
</div>

<script type='text/javascript'>
for (var uidx = 0; uidx < wl_ifaces.length; ++uidx) {
/* REMOVE-BEGIN
//	u = wl_unit(uidx);
REMOVE-END */
	u = wl_fface(uidx);
	W('<div class=\'section-title\' id=\'wl'+u+'-title\'>Wireless');
	if (wl_ifaces.length > 0)
		W(' (' + wl_display_ifname(uidx) + ')');
	W(' <small><i><a href=\'javascript:toggleVisibility("wl_' + u + '");\'><span id=\'sesdiv_wl_' +u + '_showhide\'>(Click here to hide)</span></a></i></small>');
	W('</div>');
	W('<div class=\'section\' id=\'sesdiv_wl_'+u+'\'>');
	sec = auth[nvram['wl'+u+'_security_mode']] + '';
	if (sec.indexOf('WPA') != -1) sec += ' + ' + enc[nvram['wl'+u+'_crypto']];

	wmode = wmo[nvram['wl'+u+'_mode']] + '';
	if ((nvram['wl'+u+'_mode'] == 'ap') && (nvram['wl'+u+'_wds_enable'] * 1)) wmode += ' + WDS';

	createFieldTable('', [
		{ title: 'MAC Address', text: nvram['wl'+u+'_hwaddr'] },
		{ title: 'Wireless Mode', text: wmode },
		{ title: 'Wireless Network Mode', text: bgmo[nvram['wl'+u+'_net_mode']], ignore: (wl_sunit(uidx)>=0) },
		{ title: 'Interface Status', rid: 'ifstatus'+uidx, text: wlstats[uidx].ifstatus },
		{ title: 'Radio', rid: 'radio'+uidx, text: (wlstats[uidx].radio == 0) ? '<b>Disabled</b>' : 'Enabled', ignore: (wl_sunit(uidx)>=0) },
/* REMOVE-BEGIN */
//	{ title: 'SSID', text: (nvram['wl'+u+'_ssid'] + ' <small><i>' + ((nvram['wl'+u+'_mode'] != 'ap') ? '' : ((nvram['wl'+u+'_closed'] == 0) ? '(Broadcast Enabled)' : '(Broadcast Disabled)')) + '</i></small>') },
/* REMOVE-END */
		{ title: 'SSID', text: nvram['wl'+u+'_ssid'] },
		{ title: 'Broadcast', text: (nvram['wl'+u+'_closed'] == 0) ? 'Enabled' : '<b>Disabled</b>', ignore: (nvram['wl'+u+'_mode'] != 'ap') },
		{ title: 'Security', text: sec },
		{ title: 'Channel', rid: 'channel'+uidx, text: stats.channel[uidx], ignore: (wl_sunit(uidx)>=0) },
		{ title: 'Channel Width', rid: 'nbw'+uidx, text: wlstats[uidx].nbw, ignore: ((!nphy) || (wl_sunit(uidx)>=0)) },
		{ title: 'Interference Level', rid: 'interference'+uidx, text: stats.interference[uidx], hidden: ((stats.interference[uidx] == '') || (wl_sunit(uidx)>=0)) },
		{ title: 'Rate', rid: 'rate'+uidx, text: wlstats[uidx].rate, ignore: (wl_sunit(uidx)>=0) },
		{ title: 'RSSI', rid: 'rssi'+uidx, text: wlstats[uidx].rssi || '', ignore: ((!wlstats[uidx].client) || (wl_sunit(uidx)>=0)) },
		{ title: 'Noise', rid: 'noise'+uidx, text: wlstats[uidx].noise || '', ignore: ((!wlstats[uidx].client) || (wl_sunit(uidx)>=0)) },
		{ title: 'Signal Quality', rid: 'qual'+uidx, text: stats.qual[uidx] || '', ignore: ((!wlstats[uidx].client) || (wl_sunit(uidx)>=0)) }
	]);

	W('<input type=\'button\' class=\'controls\' onclick=\'wlenable('+uidx+', 1)\' id=\'b_wl'+uidx+'_enable\' value=\'Enable\' style=\'display:none\'>');
	W('<input type=\'button\' class=\'controls\' onclick=\'wlenable('+uidx+', 0)\' id=\'b_wl'+uidx+'_disable\' value=\'Disable\' style=\'display:none\'>');
	W('</div>');
}
</script>


<!-- / / / -->

</td></tr>
<tr><td id='footer' colspan=2>
	<script type='text/javascript'>genStdRefresh(1,1,'ref.toggle()');</script>
</td></tr>
</table>
</form>
<script type='text/javascript'>earlyInit()</script>
</body>
</html>
