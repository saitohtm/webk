// Copyright 2008 futomi  http://www.html5.jp/
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//   http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
// border-radius.js v1.0.0

(function () {

addEventListener(window, "load", init);

/* -------------------------------------------------------------------
* initialize the document.
* ----------------------------------------------------------------- */
function init() {
	if( ! /CSS\d+Compat/.test(document.compatMode) ) { return; }
	var elms = getElementsByClassName(document, "html5jp-border-radius");
	for( var i=0; i<elms.length; i++ ) {
		var elm = elms.item(i);
		var display = get_style(elm, 'display');
		if( ! /(block|table)/.test(display) ) { continue; }
		round(elm);
	}
}

/* -------------------------------------------------------------------
* round the corners.
* ----------------------------------------------------------------- */

function round(elm) {
	/* get parameters from css attribute value in the target element. */
	var p = get_params(elm);
	/* get background-color */
	var bgcolor = get_style(elm, 'background-color');
	if( ! bgcolor ) { return; }
	/* get margin, padding, border */
	var css = get_styles(elm,  [
		'width',
		'margin-top', 'margin-right', 'margin-bottom', 'margin-left',
		'padding-top', 'padding-right', 'padding-bottom', 'padding-left',
		'border-top-width', 'border-right-width', 'border-bottom-width', 'border-left-width',
		'border-top-style', 'border-right-style', 'border-bottom-style', 'border-left-style',
		'border-top-color', 'border-right-color', 'border-bottom-color', 'border-left-color',
		'float', 'clear'
	]);
	/* get width, height, padding of the target element.(integer) */
	var size = get_box_size(elm);
	if(! size ) { return; }
	var width = Math.ceil(size['w']);
	var height = Math.ceil(size['h']);
	var padding_left = Math.ceil(conv_to_pixel(elm, css['padding-left']));
	var padding_right = Math.ceil(conv_to_pixel(elm, css['padding-right']));
	var padding_top = Math.ceil(conv_to_pixel(elm, css['padding-top']));
	var padding_bottom = Math.ceil(conv_to_pixel(elm, css['padding-bottom']));
	/* get border-width and border-color of the target element. (getted border-width is the one of thickest border in the four sides.) */
	var max_border = get_css_max_border(elm);
	var border_width = Math.ceil(max_border['width']);
	var border_color = max_border['color'];
	/* if border width is thicker than the radius, set the radius to the border width */
	for( var k in p ) {
		if(p[k] > 0 && border_width > p[k]) {
			p[k] = Math.ceil(border_width);
		}
	}
	/* set 0px to borer and margin of the target element */
	clear_border_margin(elm);
	/* create a table element */
	var table = document.createElement("TABLE");
	/* initialize the style of the table element */
	init_style(table);
	/* apply default styles to the table element */
	table_width = width + padding_right + padding_left + border_width * 2;
	table.style.display = get_style(elm, 'display');
	table.style.width = table_width + "px";
	table.style.borderCollapse = 'collapse';
	table.style.marginTop = css['margin-top'];
	table.style.marginRight = css['margin-right'];
	table.style.marginBottom = css['margin-bottom'];
	table.style.marginLeft = css['margin-left'];
	if(document.uniqueID) {
		table.style.styleFloat = css['float'];
	} else {
		table.style.cssFloat = css['float'];
	}
	table.style.clear = css['clear'];
	/* create a tbody element */
	var tbody = document.createElement("TBODY");
	init_style(tbody);
	for( var i=0; i<3; i++ ) {
		var tr = document.createElement("TR");
		init_style(tr);
		if(i==1) {
			for( var j=0; j<3; j++ ) {
				var td = document.createElement("TD");
				init_style(td);
				td.style.height = height + "px";
				if(j==1) {
					var clone = elm.cloneNode(true);
					clone.style.width = width + "px";
					clone.style.paddingLeft = padding_left + "px";
					clone.style.paddingRight = padding_right + "px";
					clone.style.paddingTop = padding_top + "px";
					clone.style.paddingBottom = padding_bottom + "px";
					td.style.width = width + "px";
					td.appendChild(clone);
					td.style.backgroundColor = bgcolor;
					tr.appendChild(td);
				} else if(border_width > 0) {
					td.style.width = border_width + "px";
					td.style.emptyCells = 'show';
					tr.appendChild(td);
				}
			}
		} else {
			var td = document.createElement("TD");
			init_style(td);
			if(border_width > 0) {
				td.colSpan = 3;
			}
			td.style.emptyCells = 'show';
			td.style.padding = '0';
			td.style.margin = '0';
			td.style.width = table_width + "px";
			var r = 0;
			if(i==0) {
				r = Math.max(p["top-left"], p["top-right"]);
			} else if(i==2) {
				r = Math.max(p["bottom-left"], p["bottom-right"]);
			}
			if(r > 0) {
				td.style.height = Math.ceil(r + border_width/2) + "px";
			} else {
				td.style.height = border_width + "px";
			}
			tr.appendChild(td);
		}
		tbody.appendChild(tr);
	}
	table.appendChild(tbody);
	/* replace the target element to the table element */
	elm.parentNode.replaceChild(table, elm);
	/* draw corners */
	draw_corner(table, p, bgcolor, border_width, border_color);
}

function get_params(elm) {
	var p = {
		"top-left":0,
		"top-right":0,
		"bottom-left":0,
		"bottom-right":0
	};
	var c = elm.className;
	if( ! c ) { return p; }
	var m = c.match(/\[([^\]]+)\]/);
	if( ! m  ) {
		return {
			"top-left":5,
			"top-right":5,
			"bottom-left":5,
			"bottom-right":5
		};
	}
	var parts = m[1].split(";");
	for( var i=0; i<parts.length; i++ ) {
		var pair = parts[i];
		if(pair == "") { continue; }
		var m = pair.match(/^([a-zA-Z0-9\-]+)\:(\d+[a-z\%]+)$/);
		if( ! m ) { continue; }
		var k = m[1];
		var v = m[2];
		if( /^\d+(px)?$/.test(v) ) {
			v = parseInt(v);
		} else if( /^\d+.+$/.test(v) ) {
			v = conv_to_pixel(elm, v);
		}
		if( k == "radius" ) {
			p["top-left"] = v;
			p["top-right"] = v;
			p["bottom-left"] = v;
			p["bottom-right"] = v;
		} else if( k == "top" ) {
			p["top-left"] = v;
			p["top-right"] = v;
		} else if( k == "bottom" ) {
			p["bottom-left"] = v;
			p["bottom-right"] = v;
		} else if( k == "left" ) {
			p["top-left"] = v;
			p["bottom-left"] = v;
		} else if( k == "right" ) {
			p["top-right"] = v;
			p["bottom-right"] = v;
		} else if( /^(top|bottom)\-(left|right)$/.test(k) ) {
			p[k] = v;
		}
	}
	return p;
}

function init_style(elm) {
	var s = elm.style;
	s.borderWidth = "0px";
	s.margin = "0px";
	s.padding = "0px";
	s.backgroundColor = "transparent";
	s.backgroundImage = "none";
	s.overflow = "visible";
	s.position = "static";
	s.styleFloat = "none";
	s.clear = "none";
}

function draw_corner(table, p, bgcolor, border_width, border_color) {
	var canvast = document.createElement("CANVAS");
	if(canvast.getContext) {
		draw_corner_by_canvas(table, p, bgcolor, border_width, border_color);
	} else if(document.uniqueID) {
		if (!document.namespaces["v"]) {
			document.namespaces.add("v", "urn:schemas-microsoft-com:vml");
		}
		var style_sheet = document.createStyleSheet();
		style_sheet.cssText = "v\\:*{behavior:url(#default#VML)}";
		draw_corner_by_vml(table, p, bgcolor, border_width, border_color);
	}
}

function draw_corner_by_canvas(table, p, bgcolor, border_width, border_color) {
	var s = border_width / 2;
	/* top, bottom */
	var tds = [table.rows[0].cells[0], table.rows[2].cells[0]];
	for( var i=0; i<2; i++ ) {
		var td = tds[i];
		var w = parseFloat(td.style.width);
		var h = parseFloat(td.style.height);
		var canvas = document.createElement("CANVAS");
		td.appendChild(canvas);
		canvas.width = w;
		canvas.height = h;
		canvas.style.display = "block";
		canvas.style.margin = "0px";
		canvas.style.padding = "0px";
		canvas.style.width = w + "px";
		canvas.style.height = h + "px";
		var ctx = canvas.getContext('2d');
		ctx.lineWidth = border_width;
		ctx.strokeStyle = border_color;
		ctx.fillStyle = bgcolor;
		ctx.lineCap = "round";
		ctx.beginPath();
		if(i==0) {
			var rL = p["top-left"];
			var rR = p["top-right"];
			var rMax = Math.max(rL, rR);
			if(rMax == 0) { rMax = s; }
			ctx.moveTo(s, h);
			ctx.lineTo(s, h-rMax+rL);
			if(rL > 0) {
				ctx.arc(s+rL, h-rMax+rL, rL, 180 * Math.PI / 180, 270 * Math.PI / 180, false);
			}
			ctx.lineTo(w-s-rR, h-rMax);
			if(rR > 0) {
				ctx.arc(w-s-rR, h-rMax+rR, rR, 270 * Math.PI / 180, 360 * Math.PI / 180, false);
			}
			ctx.lineTo(w-s, h);
		} else if(i==1) {
			var rL = p["bottom-left"];
			var rR = p["bottom-right"];
			var rMax = Math.max(rL, rR);
			if(rMax == 0) { rMax = s; }
			ctx.moveTo(s, 0);
			ctx.lineTo(s, rMax-rL);
			if(rL > 0) {
				ctx.arc(s+rL, rMax-rL, rL, 180 * Math.PI / 180, 90 * Math.PI / 180, true);
			}
			ctx.lineTo(w-s-rR, rMax);
			if(rR > 0) {
				ctx.arc(w-s-rR, rMax-rR, rR, 90 * Math.PI / 180, 0, true);
			}
			ctx.lineTo(w-s, 0);
		}
		ctx.fill();
		if(border_width>0) {
			ctx.stroke();
		}
	}
	/* left, right */
	if(border_width > 0) {
		var tdh = [table.rows[1].cells[0], table.rows[1].cells[2]];
		for( var i=0; i<2; i++ ) {
			var td = tdh[i];
			td.style.backgroundColor = border_color;
		}
	}
}

function draw_corner_by_vml(table, p, bgcolor, border_width, border_color) {
	var s = 0;
	if(border_width > 0) {
		s = Math.ceil(border_width / 2);
		if(border_width % 2 == 0) { s ++; }
	}
	/* top, bottom */
	var tdv = [table.rows[0].cells[0], table.rows[2].cells[0]];
	for( var i=0; i<2; i++ ) {
		var td = tdv[i];
		var w = parseFloat(td.style.width);
		var h = parseFloat(td.style.height);
		var atrs = {
			coordorigin: "0 0",
			coordsize: w+","+h,
			style: "width:"+w+"; height:"+h+"; position:absolute; margin-left:0; margin-top:0;",
			fillcolor: bgcolor,
			strokecolor: border_width ? border_color : bgcolor,
			strokeweight: (border_width ? border_width : 1) + "px",
			strokejoinstyle: "miter"
		};
		var vtag = "";
		if(i == 0) {
			var rL = p["top-left"];
			var rR = p["top-right"];
			var rMax = Math.max(rL, rR);
			if(border_width > 0) {
				var path = [];
				path.push("m", w-s, h, "l", w-s, h-rMax+rR);
				if(rR > 0) {
					path.push("at", w-s-(rR*2), h-rMax, w-s, h+rR, w-s, h-rMax+rR, w-s-rR, h-rMax);
				}
				path.push("l", s+rL, h-rMax);
				if(rL > 0) {
					path.push("at", s, h-rMax, s+(rL*2), h-rMax+(rL*2), s+rL, h-rMax, s, h-rMax+rL);
				}
				path.push("l", s, h);
				atrs['stroked'] = "false";
				atrs['filled'] = "true";
				atrs['path'] = path.join(" ") + " x e";
				vtag += make_vml_tag(atrs);
				atrs['stroked'] = "true";
				atrs['filled'] = "false";
				atrs['path'] = path.join(" ") + " e";
			} else {
				var path = [];
				path.push("m", w-1, h, "l", w-1, h-rMax+rR);
				if(rR > 0) {
					path.push("at", w-1-(rR*2), h-rMax, w-1, h-rMax+(rR*2), w-1, h-rMax+rR, w-1-rR, h-rMax);
				}
				path.push("l", rL, h-rMax);
				if(rL > 0) {
					path.push("at", 0, h-rMax, 0+(rL*2), h-rMax+(rL*2), 0+rL, h-rMax, 0, h-rMax+rL);
				}
				path.push("l", s, h);
				atrs['stroked'] = "false";
				atrs['filled'] = "true";
				atrs['path'] = path.join(" ") + " x e";
				vtag += make_vml_tag(atrs);
				atrs['stroked'] = "true";
				atrs['filled'] = "false";
				atrs['path'] = path.join(" ") + " e";
			}
			vtag += make_vml_tag(atrs);
		} else if(i == 1) {
			var rL = p["bottom-left"];
			var rR = p["bottom-right"];
			var rMax = Math.max(rL, rR);
			if(border_width > 0) {
				var path = [];
				path.push("m", s, -1, "l", s, rMax-rL);
				if(rL > 0) {
					path.push("at", s, rMax-(rL*2), s+(rL*2), rMax, s, rMax-rL, s+rL, rMax);
				}
				path.push("l", w-s-rR, rMax);
				if(rR > 0) {
					path.push("at", w-s-(rR*2), rMax-(rR*2), w-s, rMax, w-s-rR, rMax, w-s, rMax-rR);
				}
				path.push("l", w-s, -1);
				atrs['stroked'] = "false";
				atrs['filled'] = "true";
				atrs['path'] = path.join(" ") + " x e";
				vtag += make_vml_tag(atrs);
				atrs['stroked'] = "true";
				atrs['filled'] = "false";
				atrs['path'] = path.join(" ") + " e";
			} else {
				var path = [];
				path.push("m", 0, -1, "l", 0, rMax-rL);
				if(rL > 0) {
					path.push("at", 0, rMax-(rL*2), 0+(rL*2), rMax, 0, rMax-rL, 0+rL, rMax);
				}
				path.push("l", w-1-rR, rMax);
				if(rR > 0) {
					path.push("at", w-1-(rR*2), rMax-(rR*2), w-1, rMax, w-1-rR, rMax, w-1, rMax-rR);
				}
				path.push("l", w-1, -1);
				atrs['stroked'] = "false";
				atrs['filled'] = "true";
				atrs['path'] = path.join(" ") + " x e";
				vtag += make_vml_tag(atrs);
				atrs['stroked'] = "true";
				atrs['filled'] = "false";
				atrs['path'] = path.join(" ") + " e";
			}
			vtag += make_vml_tag(atrs);
		}
		td.innerHTML = vtag;
	}
	/* left, right */
	if(border_width > 0) {
		var tdh = [table.rows[1].cells[0], table.rows[1].cells[2]];
		for( var i=0; i<2; i++ ) {
			var td = tdh[i];
			var w = parseFloat(td.style.width);
			var h = parseFloat(td.style.height);
			var atrs = {
				coordorigin: "0 0",
				coordsize: w+","+h,
				style: "width:"+w+"; height:"+h+"; position:absolute; margin-left:0; margin-top:0;",
				strokecolor: border_color,
				strokeweight: border_width + "px",
				stroked: "true",
				filled: "false"
			};
			var vtag = "";
			if(i == 0) {
				atrs['path'] = ["m", s, -1, "l", s, h, "e"].join(" ");
			} else if(i == 1) {
				atrs['path'] = ["m", w-s, -1, "l", w-s, h, "e"].join(" ");
			}
			vtag += make_vml_tag(atrs, { endcap: "flat" });
			td.innerHTML = vtag;
		}
	}
}

function make_vml_tag(shape_atrs, add_stroke_atrs) {
	var vtag = '<v:shape';
	for( var k in shape_atrs ) {
		var v = " " + k + '="' + shape_atrs[k] + '"';
		vtag += v;
	}
	vtag += '>';
	var stroke_atrs = {
		linestyle: "Single",
		endcap: "round",
		joinstyle: "miter"
	};
	if(add_stroke_atrs) {
		for( var k in add_stroke_atrs ) {
			stroke_atrs[k] = add_stroke_atrs[k];
		}
	}
	var svtag = '<v:stroke';
	for( var k in stroke_atrs ) {
		var v = " " + k + '="' + stroke_atrs[k] + '"';
		svtag += v;
	}
	svtag += ' />';
	vtag += svtag;
	vtag += '</v:shape>';
	return vtag;
}

function clear_border_margin(elm) {
	var sides = ['Top', 'Right', 'Bottom', 'Left'];
	for( var i=0; i<4; i++ ) {
		elm.style["border"+sides[i]+"Width"] = '0px';
		elm.style["margin"+sides[i]] = '0px';
	}
}

function get_css_max_border(elm) {
	var width = 0;
	var sides = ['top', 'right', 'bottom', 'left'];
	var max_side = 'top';
	for( var i=0; i<4; i++ ) {
		var w = get_style(elm, "border-"+sides[i]+"-width");
		w = conv_to_pixel(elm, w);
		if(w > width) {
			width = w;
			max_side = sides[i];
		}
	}
	var color = get_style(elm, "border-"+max_side+"-color");
	return {width: width, color: color};
}

function conv_to_pixel(elm, size) {
	if( ! size ) {
		return 0;
	}
	if( /^[\d\.]+px$/.test(size) ) {
		return parseFloat(size);
	}
	if(document.uniqueID && /^(thin|medium|thick)$/.test(size) ) {
		if(size == "thin") {
			return 1;
		} else if(size == "medium") {
			return 3;
		} else if(size == "thick") {
			return 5;
		}
	}
	var sty = elm.style.left
	var rtm = elm.runtimeStyle.left;
	elm.runtimeStyle.left = elm.currentStyle.left;
	elm.style.left = size;
	var px = elm.style.pixelLeft;
	elm.style.left = sty;
	elm.runtimeStyle.left = rtm;
	return px;
}

function get_box_size(elm) {
	var display = get_style(elm, 'display');
	if(display == "table" || elm.nodeName == "TABLE") {
		var w = elm.clientWidth;
		var h = elm.clientHeight;
		if(w && h) {
			return {w:w, h:h};
		} else {
			w = get_style(elm, 'width');
			if( /px$/.test(w) ) {
				w = parseFloat(w);
			} else {
				w= conv_to_pixel(elm, w);
			}
			h = get_style(elm, 'height');
			if( /px$/.test(h) ) {
				h = parseFloat(h);
			} else {
				h= conv_to_pixel(elm, h);
			}
		}
	} else {
		var w = get_style(elm, 'width');
		if( /px$/.test(w) ) {
			w = parseFloat(w);
		} else {
			w = conv_to_pixel(elm, w);
			if( ! w ) {
				w = elm.clientWidth;
			}
		}
		var h = get_style(elm, 'height');
		if( /px$/.test(h) ) {
			h = parseFloat(h);
		} else {
			h = conv_to_pixel(elm, h);
			if( ! h ) {
				h = elm.clientHeight;
			}
		}
	}
	if(w && h) {
		return {w:w, h:h};
	} else {
		return null;
	}
}

function get_style(elm, property) {
	if( document.defaultView ) {
		return document.defaultView.getComputedStyle(elm, null).getPropertyValue(property);
	} else if( elm.currentStyle ) {
		property = conv_css_prt_to_atr(property);
		return elm.currentStyle.getAttribute(property);
	} else {
		return null;
	}
}

function get_styles(elm, properties) {
	var css = {};
	if( document.defaultView ) {
		for(var i=0; i<properties.length; i++) {
			var property = properties[i];
			css[property] = document.defaultView.getComputedStyle(elm, null).getPropertyValue(property);
		}
	} else if( elm.currentStyle ) {
		for(var i=0; i<properties.length; i++) {
			var property = properties[i];
			var atr = conv_css_prt_to_atr(property);
			css[property] = elm.currentStyle.getAttribute(atr);
		}
	} else {
		return null;
	}
	return css;
}

function conv_css_prt_to_atr(prt) {
	if(prt == "float") {
		if(document.uniqueID) {
			return "styleFloat";
		} else {
			return "cssFloat";
		}
	} else {
		return prt.replace(/\-([a-z])/g, function(d,c){return c.toUpperCase();});
	}
}

/* -------------------------------------------------------------------
* below, funstions related DOM
* ----------------------------------------------------------------- */

/* ------------------------------------------------------------------
[syntax]
  addEventListener(elm, type, func, useCapture)
[description]
  set a event listener
[arguments]
  ・elm
      element node object
  ・type
      event type
  ・func
      call back function object
[returned values]
  if success, return true. if failure, return false.
------------------------------------------------------------------- */
function addEventListener(elm, type, func) {
	if(! elm) { return false; }
	if(elm.addEventListener) {
		elm.addEventListener(type, func, false);
	} else if(elm.attachEvent) {
		/* thanks to http://ejohn.org/projects/flexible-javascript-events/ */
		elm['e'+type+func] = func;
		elm[type+func] = function(){elm['e'+type+func]( window.event );}
		elm.attachEvent( 'on'+type, elm[type+func] );
	} else {
		return false;
	}
	return true;
}

/* ------------------------------------------------------------------
[syntax]
  getElementsByClassName(element, classNames)
[description]
  return a list of nodes which have class attribute value as same as specified name from child nodes of specified element.
[arguments]
  ・element
      element node object
  ・classNames
      class attribute value
[returned values]
  nodeList
------------------------------------------------------------------- */
function getElementsByClassName(element, classNames) {
	if(element.getElementsByClassName) {
		return element.getElementsByClassName(classNames);
	}
	/* split a string on spaces */
	var split_a_string_on_spaces = function(string) {
		string = string.replace(/^[\t\s]+/, "");
		string = string.replace(/[\t\s]+$/, "");
		var tokens = string.split(/[\t\s]+/);
		return tokens;
	};
	var tokens = split_a_string_on_spaces(classNames);
	var tn = tokens.length;
	var nodes = element.all ? element.all : element.getElementsByTagName("*");
	var n = nodes.length;
	var array = new Array();
	if( tn > 0 ) {
		if( document.evaluate ) {
			var contains = new Array();
			for(var i=0; i<tn; i++) {
				contains.push('contains(concat(" ",@class," "), " '+ tokens[i] + '")');
			}
			var xpathExpression = "/descendant::*[" + contains.join(" and ") + "]";
			var iterator = document.evaluate(xpathExpression, element, null, XPathResult.ORDERED_NODE_SNAPSHOT_TYPE, null);
			var inum = iterator.snapshotLength;
			for( var i=0; i<inum; i++ ) {
				var elm = iterator.snapshotItem(i);
				if( elm != element ) {
					array.push(iterator.snapshotItem(i));
				}
			}
		} else {
			for(var i=0; i<n; i++) {
				var elm = nodes.item(i);
				if( elm.className == "" ) { continue; }
				var class_list = split_a_string_on_spaces(elm.className);
				var class_name = class_list.join(" ");
				var f = true;
				for(var j=0; j<tokens.length; j++) {
					var re = new RegExp('(^|\\s)' + tokens[j] + '(\\s|$)')
					if( ! re.test(class_name) ) {
						f = false;
						break;
					}
				}
				if(f == true) {
					array.push(elm);
				}
			}
		}
	}
	/* add item(index) method to the array as if it behaves such as a NodeList interface. */
	array.item = function(index) {
		if(array[index]) {
			return array[index];
		} else {
			return null;
		}
	};
	//
	return array;
}

function event_target(evt) {
	if(evt && evt.target) {
		if(evt.target.nodeType == 3) {
			return evt.target.parentNode;
		} else {
			return evt.target;
		}
	} else if(window.event && window.event.srcElement) {
		return window.event.srcElement;
	} else {
		return null;
	}
}

})();
