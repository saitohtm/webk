/**
 * cvi_corners_lib.js 2.1 (22-Apr-2011) (c) by Christian Effenberger 
 * All Rights Reserved. Source: corner.netzgesta.de
 * Distributed under Netzgestade Non-commercial Software License Agreement.
 * This license permits free of charge use on non-commercial 
 * and private web sites only under special conditions. 
 * Read more at... http://www.netzgesta.de/cvi/LICENSE.html

 * syntax:
	cvi_corners.defaultXradius = 16;		//INT 0-100 (px)
	cvi_corners.defaultYradius = 0;			//INT 0-100 (px)
	cvi_corners.defaultCorners = "1111";	//STR "0000"-"1111" [top left|top right|bottom left|bottom right]
	cvi_corners.defaultBorder = 0;			//INT 0-100 (px) borderwidth
	cvi_corners.defaultColor = "#0000ff";	//STR "#000000"-"#ffffff" bordercolor
	cvi_corners.defaultOpacity = 100;		//INT 0-100 (%) borderopacity
	cvi_corners.defaultBezel = false;		//BOL true | false
	
	depends on: cvi_filter_lib.js
		cvi_corners.defaultFilter = null;//OBJ [{f='grayscale'},{f='emboss', s:1}...]
		
	cvi_corners.remove( image );
	cvi_corners.add( image, options );
	cvi_corners.modify( image, options );
	cvi_corners.add( image, { xradius: value, yradius: value, corners: value, border: value, color: value, opacity: value } );
	cvi_corners.modify( image, { xradius: value, yradius: value, corners: value, border: value, color: value, opacity: value } );
 *
**/

function hextorgba(val,trans) {
	function hex2dec(hex){return(Math.max(0,Math.min(parseInt(hex,16),255)));}
	var cr=hex2dec(val.substr(1,2)),cg=hex2dec(val.substr(3,2)),cb=hex2dec(val.substr(5,2));
	return 'rgba('+cr+','+cg+','+cb+','+trans+')';
}

var cvi_corners = {
	defaultXradius : 16,
	defaultYradius : 0,
	defaultCorners : "1111",
	defaultBorder : 0,
	defaultColor : "#0000ff",
	defaultOpacity : 100,
	defaultBezel : false,
	defaultFilter : null,
	defaultCallback : null,
	add: function(image, options) {
		if(image.tagName.toUpperCase() == "IMG") {
			var defopts = { "xradius" : cvi_corners.defaultXradius, "yradius" : cvi_corners.defaultYradius, "corners" : cvi_corners.defaultCorners, "border" : cvi_corners.defaultBorder, "color" : cvi_corners.defaultColor, "opacity" : cvi_corners.defaultOpacity, "bezel" : cvi_corners.defaultBezel, "filter" : cvi_corners.defaultFilter, "callback" : cvi_corners.defaultCallback }
			if(options) {
				for(var i in defopts) { if(!options[i]) { options[i] = defopts[i]; }}
			} else {
				options = defopts;
			}
			var imageWidth  = ('iwidth'  in options) ? parseInt(options.iwidth)  : image.width;
			var imageHeight = ('iheight' in options) ? parseInt(options.iheight) : image.height;
			try {
				var object = image.parentNode; 
				if(document.all&&document.namespaces&&!window.opera&&(!document.documentMode||document.documentMode<9)) {
					if(document.namespaces['v']==null) {
						var e=["shape","shapetype","group","background","path","formulas","handles","fill","stroke","shadow","textbox","textpath","imagedata","line","polyline","curve","roundrect","oval","rect","arc","image"],s=document.createStyleSheet(); 
						for(var i=0; i<e.length; i++) {s.addRule("v\\:"+e[i],"behavior: url(#default#VML);");} document.namespaces.add("v","urn:schemas-microsoft-com:vml");
					}
					var display = (image.currentStyle.display.toLowerCase()=='block')?'block':'inline-block';        
					var canvas = document.createElement(['<var style="zoom:1;overflow:hidden;display:' + display + ';width:' + imageWidth + 'px;height:' + imageHeight + 'px;padding:0;">'].join(''));
					var flt =  image.currentStyle.styleFloat.toLowerCase();
					display = (flt=='left'||flt=='right')?'inline-block':display;
					canvas.options = options;
					canvas.dpl = display;
					canvas.id = image.id;
					canvas.alt = image.alt;
					canvas.title = image.title;
					canvas.source = image.src;
					canvas.className = image.className;
					canvas.style.cssText = image.style.cssText;
					canvas.height = imageHeight;
					canvas.width = imageWidth;
					object.replaceChild(canvas,image);
					cvi_corners.modify(canvas, options);
				} else {
					var canvas = document.createElement('canvas');
					if(canvas.getContext("2d")) {
						canvas.options = options;
						canvas.id = image.id;
						canvas.alt = image.alt;
						canvas.title = image.title;
						canvas.source = image.src;
						canvas.className = image.className;
						canvas.style.cssText = image.style.cssText;
						canvas.style.height = imageHeight+'px';
						canvas.style.width = imageWidth+'px';
						canvas.height = imageHeight;
						canvas.width = imageWidth;
						object.replaceChild(canvas,image);
						cvi_corners.modify(canvas, options);
					}
				}
			} catch (e) {
			}
		}
	},
	
	modify: function(canvas, options) {
		try {			
			var xradius = (typeof options['xradius']=='number'?options['xradius']:canvas.options['xradius']); 
			var yradius = (typeof options['yradius']=='number'?options['yradius']:canvas.options['yradius']); 
			var corners = (typeof options['corners']=='string'?options['corners']:canvas.options['corners']); 
			var border = (typeof options['border']=='number'?options['border']:canvas.options['border']); 
			var color = (typeof options['color']=='string'?options['color']:canvas.options['color']); canvas.options['color']=color;
			var opacity = (typeof options['opacity']=='number'?options['opacity']:canvas.options['opacity']); canvas.options['opacity']=opacity;
			var bezel = (typeof options['bezel']=='boolean'?options['bezel']:canvas.options['bezel']); canvas.options['bezel']=bezel;
			var filter = (typeof options['filter']=='object'?options['filter']:canvas.options['filter']); canvas.options['filter']=filter;
			var callback = (typeof options['callback']=='string'?options['callback']:canvas.options['callback']); canvas.options['callback']=callback;
			var bc = '#0000ff'; bc = (color.match(/^#[0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f]$/i)?color:bc); var bo = opacity==0?0:opacity/100;
			xradius = Math.min(parseInt(canvas.width/2),xradius); yradius = Math.min(parseInt(canvas.height/2),yradius);
			if(xradius>0 && yradius==0) yradius = Math.min(parseInt(canvas.height/2),xradius);
			if(yradius>0 && xradius==0) xradius = Math.min(parseInt(canvas.width/2),yradius);
			border = border>0?Math.min(border*2,Math.min(yradius,xradius)):0; canvas.options['border'] = border;
			canvas.options['xradius'] = xradius; canvas.options['yradius'] = yradius; canvas.options['corners']=corners;
			var tl = 1; var tr = 1; var bl = 1; var br = 1; var tmp = corners;
			if(tmp != '') {tl = (tmp.substr(0,1)!="1"?0:(xradius>0?1:0)); tr = (tmp.substr(1,1)!="1"?0:(xradius>0?1:0)); bl = (tmp.substr(2,1)!="1"?0:(xradius>0?1:0)); br = (tmp.substr(3,1)!="1"?0:(xradius>0?1:0)); }
			if(document.all&&document.namespaces&&!window.opera&&(!document.documentMode||document.documentMode<9)) {
				if(canvas.tagName.toUpperCase() == "VAR") {
					var path = "m 0," + yradius; var display = canvas.dpl; bd = border>0?Math.min(border/2,2):0;
					if(bl==1) {path += " l 0," + (canvas.height-yradius) + (bezel?" l ":" qy ") + xradius + "," + canvas.height;}else {path += " l 0," + canvas.height;}
					if(br==1) {path += " l " + (canvas.width-xradius) + "," + canvas.height + (bezel?" l ":" qx ") + canvas.width + "," + (canvas.height-yradius);}else {path += " l " + canvas.width + "," + canvas.height;}
					if(tr==1) {path += " l " + canvas.width + "," + yradius + (bezel?" l ":" qy ") + (canvas.width-xradius) + ",0";}else {path += " l " + canvas.width + ",0";}	
					if(tl==1) {path += " l " + xradius + ",0 " + (bezel?" l ":" qx ") + " 0," + yradius;}else {path += " l 0,0";}	
					path += " x e";
					canvas.innerHTML = '<v:shape strokeweight="'+bd+'px" stroked="'+(bd>0?"t":"f")+'" strokecolor="'+bc+'" filled="t" fillcolor="#ffffff" coordorigin="0,0" coordsize="' + canvas.width + ',' + canvas.height + '" path="' + path + '" style="zoom:1;margin:-1px 0 0 -1px;padding: 0;display:' + display + ';width:' + canvas.width + 'px;height:' + canvas.height + 'px;"><v:fill src="' + canvas.source + '" type="frame" /></v:shape>';
					if(typeof window[callback]==='function') {window[callback](canvas.id,'cvi_corners');}
				}
			} else {
				if(canvas.tagName.toUpperCase() == "CANVAS" && canvas.getContext("2d")) {
					var context = canvas.getContext("2d"), prepared=(context.getImageData?true:false), alternate=false;
					var img = new Image();
					img.onload = function() {
						if(prepared&&(typeof cvi_filter!='undefined')&&filter!=null&&filter.length>0) {iw=Math.round(canvas.width); ih=Math.round(canvas.height);
							var source=document.createElement('canvas'); source.height=ih+4; source.width=iw+4; var src=source.getContext("2d");
							var buffer=document.createElement('canvas'); buffer.height=ih; buffer.width=iw; var ctx=buffer.getContext("2d");
							if(src&&ctx) {alternate=true; ctx.clearRect(0,0,iw,ih); ctx.drawImage(img,0,0,iw,ih); 
								src.clearRect(0,0,iw+4,ih+4); src.drawImage(img,0,0,iw+4,ih+4); src.drawImage(img,2,2,iw,ih); 
								for(var i in filter) {cvi_filter.add(source,buffer,filter[i],iw,ih);}
							}
						}
						context.clearRect(0,0,canvas.width,canvas.height);
						context.save();
						context.beginPath();
						context.moveTo(0,yradius);
						if(bl==1) {context.lineTo(0,canvas.height-yradius);if(bezel) {context.lineTo(xradius,canvas.height);}else {context.quadraticCurveTo(0,canvas.height,xradius,canvas.height);}}else {context.lineTo(0,canvas.height);}
						if(br==1) {context.lineTo(canvas.width-xradius,canvas.height);if(bezel) {context.lineTo(canvas.width,canvas.height-yradius);}else {context.quadraticCurveTo(canvas.width,canvas.height,canvas.width,canvas.height-yradius);}}else {context.lineTo(canvas.width,canvas.height);}
						if(tr==1) {context.lineTo(canvas.width,yradius);if(bezel) {context.lineTo(canvas.width-xradius,0);}else {context.quadraticCurveTo(canvas.width,0,canvas.width-xradius,0);}}else {context.lineTo(canvas.width,0);}	
						if(tl==1) {context.lineTo(xradius,0);if(bezel) {context.lineTo(0,yradius);}else {context.quadraticCurveTo(0,0,0,yradius);}}else {context.lineTo(0,0);}	
						context.closePath();
						context.clip();
						context.fillStyle = 'rgba(0,0,0,0)';
						context.fillRect(0,0,canvas.width,canvas.height);
						if(alternate) {
							context.drawImage(source,2,2,canvas.width,canvas.height,0,0,canvas.width,canvas.height);
						} else {
							context.drawImage(img,0,0,canvas.width,canvas.height);
						}
						if(border>0) {
							context.beginPath();
							context.moveTo(0,yradius);
							if(bl==1) {context.lineTo(0,canvas.height-yradius);if(bezel) {context.lineTo(xradius,canvas.height);}else {context.quadraticCurveTo(0,canvas.height,xradius,canvas.height);}}else {context.lineTo(0,canvas.height);}
							if(br==1) {context.lineTo(canvas.width-xradius,canvas.height);if(bezel) {context.lineTo(canvas.width,canvas.height-yradius);}else {context.quadraticCurveTo(canvas.width,canvas.height,canvas.width,canvas.height-yradius);}}else {context.lineTo(canvas.width,canvas.height);}
							if(tr==1) {context.lineTo(canvas.width,yradius);if(bezel) {context.lineTo(canvas.width-xradius,0);}else {context.quadraticCurveTo(canvas.width,0,canvas.width-xradius,0);}}else {context.lineTo(canvas.width,0);}	
							if(tl==1) {context.lineTo(xradius,0);if(bezel) {context.lineTo(0,yradius);}else {context.quadraticCurveTo(0,0,0,yradius);}}else {context.lineTo(0,0);}	
							context.closePath();
							context.strokeStyle = hextorgba(bc,bo);
							context.lineWidth = border;
							context.stroke(); 
						}
						context.restore();
						if(typeof window[callback]==='function') {window[callback](canvas.id,'cvi_corners');}
					}
					img.src = canvas.source;
				}
			}
		} catch (e) {
		}
	},

	replace : function(canvas) {
		var object = canvas.parentNode; 
		var img = document.createElement('img');
		img.id = canvas.id;
		img.alt = canvas.alt;
		img.title = canvas.title;
		img.src = canvas.source;
		img.className = canvas.className;
		img.height = canvas.height;
		img.width = canvas.width;
		img.style.cssText = canvas.style.cssText;
		img.style.height = canvas.height+'px';
		img.style.width = canvas.width+'px';
		object.replaceChild(img,canvas);
	},

	remove : function(canvas) {
		if(document.all&&document.namespaces&&!window.opera&&(!document.documentMode||document.documentMode<9)) {
			if(canvas.tagName.toUpperCase() == "VAR") {
				cvi_corners.replace(canvas);
			}
		} else {
			if(canvas.tagName.toUpperCase() == "CANVAS") {
				cvi_corners.replace(canvas);
			}
		}
	}
}