/**
 * lcslog.js  v 0.4.11
 * Last Updated: 2009-07-02
 * Author : Chin Mi Ae, Lee Dae Beom
 * Copyright 2009 NHN Corp. All rights Reserved.
 * NHN PROPRIETARY/CONFIDENTIAL. Use is subject to license terms.
 *
 * This code includes some part of the
 * "Flash Player Detection Kit Revision 1.5" by Michael Williams
 * & Copyright 2005-2007 Adobe Macromedia Softward.LLC. All rights reserved.
 */


var lcs_isie = (navigator.appName == "Microsoft Internet Explorer"); 
var lcs_isns = (navigator.appName == "Netscape" );
var lcs_isopera = (navigator.appVersion.indexOf("Opera") >=  0 );
var lcs_ismac = (navigator.userAgent.indexOf("MAC")>=0); 

var lcs_add = {};
var lcs_bc = {};

var lcs_ver = "v0.4.11";
var lcs_count = 0;
lcs_obj = [];

function lcs_do( etc ) {
	// TODO : check lcs server name!! 
	if (!lcs_SerName) { var lcs_SerName = "lcs.livedoor.net"; }

	var rs = "";
	var index;

	try {
		var lcs_Addr = (window.location.protocol ? window.location.protocol : "http:")+"//" + lcs_SerName + "/m?";
	} catch(e){ return; }

	try {
		rs = lcs_Addr + "u=" + encodeURIComponent(document.URL) 
			+ "&e=" + (document.referrer ? encodeURIComponent(document.referrer) : "");
	} catch(e) {
	}

	try {

	if (typeof lcs_add.i == 'undefined' )
		lcs_add.i = "";

	for( var index in lcs_add)
	{
		if( typeof lcs_add[index] != 'function' ) 
			rs += "&" + index + "=" + encodeURIComponent(lcs_add[index]);
	}

	for( var index in etc )
	{
		if ( (index.length >= 3 && (typeof etc[index] != 'function')) || index == 'qy')
		{
			rs += "&" + index + "=" + encodeURIComponent(etc[index]);
		}
	}

	
	lcs_getBrowserCapa();

	for( var index in lcs_bc )
	{
		if( typeof lcs_bc[index] != 'function' ) 
			rs += "&" + index + "=" + encodeURIComponent(lcs_bc[index]);
	}

	if(lcs_count > 0 )
	{
		var timeStr = (new Date).getTime();
		rs += "&ts=" + timeStr;
	}
	rs += "&EOU";

	if (document.images) {
		var obj = (new Image());
		lcs_obj.push(obj);
		obj.src = rs;
	} else {
		document.write( '<im' + 'g sr' + 'c="' + rs + '" width="1" height="1" border="0" />');
	}
	lcs_count++;

	} catch(e) {
		return;
	}
}

function lcs_do_gdid( gdid , etc) {

	try {
		if (gdid) {
			lcs_add["i"] = gdid;

			if (etc){
				lcs_do(etc);
			} else {
				lcs_do();
			}
			
		}
	} catch (e) {
	}
}

function lcs_getBrowserCapa() {
	lcs_getOS();
	
	lcs_getlanguage();
	
	lcs_getScreen();

	lcs_getWindowSize();

	lcs_getColorDepth();

	lcs_getJavaEnabled();  

	lcs_getJavascriptVer();

	lcs_getCookieEnabled(); 

	lcs_getSwfVer();

	lcs_getSLVersion();

	lcs_getConnectType();

	lcs_getPlugIn();

}

function lcs_getOS() {
	var lcs_os = "";
	try {
		(navigator.platform ? lcs_os = navigator.platform : "");
	} catch (e) {
	}
	lcs_bc["os"] = lcs_os;
}

function lcs_getlanguage() {
	var lcs_ln = "";
	try {
		(navigator.userLanguage? lcs_ln = navigator.userLanguage : (navigator.language)? lcs_ln = navigator.language : "");
	} catch (e) {
	}

	lcs_bc["ln"] = lcs_ln;
}

function lcs_getScreen() {
	var lcs_sr = "";
	try {
		if ( window.screen && screen.width && screen.height)
		{
			lcs_sr = screen.width + 'x'+ screen.height;
		}
		else if ( window.java || self.java ) 
		{
			var sr = java.awt.Toolkit.getDefaultToolkit().getScreenSize();
			lcs_sr = sr.width + 'x' + sr.height;

		}
	} catch(e) {
		lcs_sr = "";
	}

	lcs_bc["sr"] = lcs_sr;
}


function lcs_getWindowSize() {
	lcs_bc["bw"] = '';
	lcs_bc["bh"] = '';
	try {
		lcs_bc["bw"] = document.documentElement.clientWidth ? document.documentElement.clientWidth : document.body.clientWidth;
		lcs_bc["bh"] = document.documentElement.clientHeight ? document.documentElement.clientHeight : document.body.clientHeight;
	}
	catch(e) {
	}
}

function lcs_getColorDepth(){
	lcs_bc["c"] = "";
	try {
		if (window.screen) {
			lcs_bc["c"] = screen.colorDepth ? screen.colorDepth : screen.pixelDepth;
		}
		else if (window.java || self.java ) {
			var c = java.awt.Toolkit.getDefaultToolkit().getColorModel().getPixelSize();
			lcs_bc["c"] = c;
		}
	} catch (e) {
		lcs_bc["c"] = "";
	}
}

function lcs_getJavaEnabled() { 
	lcs_bc["j"] = "";
	try {
		lcs_bc["j"]= navigator.javaEnabled() ? "Y":"N";
	} catch (e) {
	}

}

function lcs_getCookieEnabled() {
	lcs_bc["k"] = "";
	try {
		lcs_bc["k"]= navigator.cookieEnabled ? "Y":"N";
	} catch (e) {
	}

}

function lcs_getConnectType() {
	var lcs_ct = "";
	try {
		if ( lcs_isie && !lcs_ismac && document.body ) {
			var obj = document.body.addBehavior("#default#clientCaps");
			lcs_ct = document.body.connectionType;
			document.body.removeBehavior(obj);
		}
	} catch(e) {
	}

	lcs_bc["ct"] = lcs_ct;
}

function lcs_getJavascriptVer() {
	var j = "1.0";
	try {
		if(String && String.prototype) {
			j = "1.1";
			if(j.search)
			{
				j = "1.2";
				var dt = new Date, no = 0;
				if ( dt.getUTCDate)
				{
					j = "1.3";
					var i, ie = navigator.appVersion.indexOf('MSIE');
					if (ie > 0 ) 
					{
						var apv =  parseInt(i = navigator.appVersion.substring(ie+5));
						if (apv > 3) { n_apv = parseFloat(i); }
					}
					if(lcs_isie && lcs_ismac && apv >= 5) 
					{
						j = "1.4"; 
					}
					if(no.toFixed)
					{
						j = "1.5";
						var a = new Array;
						if (a.every)
						{
							j = "1.6";
							i = 0;
							var obj = new Object;
							var test = function(obj) { var i = 0; try {	i = new Iterator(obj)} catch(e) {} return i};
							i = test(obj);
							if(i && i.next) j = "1.7";
							
							if(a.reduce) j = "1.8";
							
						}
	
					}
				}
			}
		}
	} catch (e) {}
	lcs_bc["jv"] = j;
}

function lcs_getSwfVer(){
	var flashVer = ''; 
	var isWin = false;

	try {
		isWin = (navigator.appVersion.toLowerCase().indexOf("win") != -1) ? true : false;
   
		if (navigator.plugins != null && navigator.plugins.length > 0) {
			if (navigator.plugins["Shockwave Flash 2.0"] || navigator.plugins["Shockwave Flash"]) {
				var swVer2 = navigator.plugins["Shockwave Flash 2.0"] ? " 2.0" : "";
				var flashDescription = navigator.plugins["Shockwave Flash" + swVer2].description;
				var descArray = flashDescription.split(" ");
				var tempArrayMajor = descArray[2].split(".");           
				var versionMajor = tempArrayMajor[0];
				var versionMinor = tempArrayMajor[1];
				flashVer = parseInt(versionMajor,10) + "." + parseInt(versionMinor, 10);
			}
		}
		else if (navigator.userAgent.toLowerCase().indexOf("webtv/2.6") != -1) flashVer = "4.0";
		else if (navigator.userAgent.toLowerCase().indexOf("webtv/2.5") != -1) flashVer = "3.0";
		else if (navigator.userAgent.toLowerCase().indexOf("webtv") != -1) flashVer = "2.0";
		else if ( lcs_isie && isWin && !lcs_isopera ) {
		    var version = '';
		    var axo;

		    try {
       			axo = new ActiveXObject("ShockwaveFlash.ShockwaveFlash.7");
   		     	version = axo.GetVariable("$version");
		    } catch (e) {}

		    if (!version)
		    {
		        try {
       		    	axo = new ActiveXObject("ShockwaveFlash.ShockwaveFlash.6");
           		 	version = "WIN 6,0,21,0";
	            	axo.AllowScriptAccess = "always";
            		version = axo.GetVariable("$version");
        			} catch (e) {}
    		}

			if (!version)
			{
				try {
					axo = new ActiveXObject("ShockwaveFlash.ShockwaveFlash.3");
					version = "WIN 3,0,18,0";
					version = axo.GetVariable("$version");
				} catch (e) {}
			}
		  
			if (!version)
			{
				try {
					axo = new ActiveXObject("ShockwaveFlash.ShockwaveFlash");
					version = "WIN 2,0,0,11";
				} catch (e) {}
			}
		   
			if (version.indexOf(',') > 0 ) {
				version = version.replace( /%20/,'');
				version = version.replace( /[a-zA-Z]*[^0-9]/,'');
				var verArray = version.split(",");
				version = parseInt(verArray[0],10) + "." + parseInt(verArray[1],10);
			}
			flashVer = version;
		}
	} catch (e) {}
	
	lcs_bc["fv"] = flashVer;
}

function lcs_getSLVersion() {
	var lcs_sl = "";

	try {
		if (navigator.plugins && navigator.plugins.length > 0 )
		{
			lcs_sl = navigator.plugins["Silverlight Plug-In"].description || navigator.plugins["WPFe Plug-In"].description;
			if (lcs_sl == '1.0.30226.2') lcs_sl = '2.0.30226.2';
		}
		else 
		{
			var wrap, obj;
			if (typeof ActiveXObject != 'undefined') {
				try { obj = new ActiveXObject('AgControl.AgControl'); 
				} catch(e) {}
			} else {
				wrap = document.createElement('div');
				wrap.innerHTML = '<object type="application/x-silverlight" style="position:absolute;" />';
				document.body.insertBefore(wrap, document.body.firstChild);
				obj = wrap.firstChild;
			}

			if (/\bopera\b/i.test(navigator.userAgent)) 
				for (var start = new Date().getTime(); typeof obj.isVersionSupported == 'undefined' && (new Date().getTime() - start < 1000); );
	
			if (typeof obj.isVersionSupported != 'undefined') {
	
				for (var major = 0; major < 9; major++) {
		
					for (var minor = 0; minor <= 9; minor++) {
						var v = major + '.' + minor;
						if (obj.isVersionSupported(v)) {
							lcs_sl = v;
						}
						else break;
		
					}
		
				}
				
			}
			
			if (obj) obj = null;
			if (wrap) document.body.removeChild(wrap);
		}

		if ( lcs_sl.indexOf('.') > 0 ) {
			var verArray = lcs_sl.split('.');
			lcs_sl = verArray[0] + '.' + verArray[1];
		}
	} catch(e) { }

	lcs_bc["sl"] =  lcs_sl;
}


function lcs_getPlugIn() {
	var plArr = {};
	var lcs_p = "";

   	if (navigator.plugins && navigator.plugins.length > 0)
	{
		try {
			var piArr = navigator.plugins;
			for (var i = 0; i < piArr.length; i++)
			{
				plArr[piArr[i].name] = '';		
			}
		} catch (e) {
		}
	} else {
		try {
			if (lcs_bc['fv'] != '' )
				plArr["Shockwave Flash"] = '';

			if (lcs_bc['sl'] != '' )
				plArr["Silverlight"] = '';
		} catch (e) {
		}

	    try {
			if (new ActiveXObject("SWCtl.SWCtl")) { plArr["Shockwave Director"] = '';}
        } catch (e) {
        }

	    try {
			if (new ActiveXObject("rmocx.RealPlayer G2 Control")
				|| new ActiveXObject("RealPlayer.RealPlayer(tm) ActiveX Control (32-bit)") 
				|| new ActiveXObject("RealVideo.RealVideo(tm) ActiveX Control (32-bit)")) {
				plArr["RealPlayer"] = '';
			}
        } catch (e) {
        }

		try {
			var index = navigator.userAgent.indexOf('MSIE');
			if (index != -1)
			{ 
				var ie_ver = parseFloat(navigator.userAgent.substring(index + 4 + 1));
				if (ie_ver < 7 ){
					if (new ActiveXObject("QuickTime.QuickTime")) {
						plArr["QuickTime"] = '';
					}

					if (new ActiveXObject("MediaPlayer.MediaPlayer.1")) { 
						plArr["Windows Media"] = '';
					} else {
						var obj_item = document.getElementsByTagName("object");	
						for(var i=0; i <  obj_item.length ; i++ ) {
							if(obj_item[i].classid) {
								var clsid = obj_item[i].classid.toUpperCase();
 								if ( clsid == "CLSID:6BF52A52-394A-11D3-B153-00C04F79FAA6" 
											|| clsid == "CLSID:22D6F312-B0F6-11D0-94AB-0080C74C7E95" ) {
									if (new ActiveXObject("MediaPlayer.MediaPlayer.1")) {
										plArr["Windows Media"] = '';
									}
								}
		
							}
								
						}
					}
				}
			}
		} catch (e) {
		}
	}

	for( var index in plArr ) {
		if( typeof plArr[index] != 'function' ) 
		lcs_p += index + ';';
	}

	lcs_bc["p"] = lcs_p.length ? lcs_p.substr(0, lcs_p.length-1) : lcs_p;
}

