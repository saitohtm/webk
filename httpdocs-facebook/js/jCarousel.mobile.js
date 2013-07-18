/*
 * jCarousel for Moblie - jQuery Plugin
 * http://www.inkdesign.jp/donwload/jCarousel-mobile/
 *
 * Original: jCarousel - jQuery Plugin
 * http://d.hatena.ne.jp/kudakurage/
 *
 * Thanks for  Kazuyuki Motoyama
 *
 * Copyright (c) 2010 hiloki (EC studio, inkdesign)
 * Licensed under the MIT license
 *
 * $Date: 2010-09-09
 * $version: 1.1
 *
 * This jQuery plugin will only run on devices running Mobile Safari
 * on iPhone or iPod Touch devices running iPhone OS 2.0 or later.
 * http://developer.apple.com/iphone/library/documentation/AppleApplications/Reference/SafariWebContent/HandlingEvents/HandlingEvents.html#//apple_ref/doc/uid/TP40006511-SW5
 */
var jCarousel = {
    ua: "pc",
    num: 0,
    target: [],
    sel: [],
    activeBool: false,
    active: 0,
    main: 0,
    colorSet: {
        black: {
            back: "#666",
            active: "#eee",
            shadow: "#333"
        },
        white: {
            back: "#ddd",
            active: "#999",
            shadow: "#333"
        }
    }
};
jCarousel.set = function (d) {
    jCarousel.color = jCarousel.colorSet.black;
    jCarousel.main = 0;
    if (typeof d == "object") {
        if (d.color == "white") {
            jCarousel.color = jCarousel.colorSet.white
        }
        if (!isNaN(d.main)) {
            jCarousel.main = eval(d.main)
        }
    }
    $(".jCarousel").each(function () {
        if (!$(this).attr("name")) {
            var b = jCarousel.num,
                e = $(this).width(),
                i = $(this).find("li").length;
            $(this).attr("name", b);
            jCarousel.target[b] = this;
            jCarousel.sel[b] = {
                width: e,
                max: i,
                left: 0,
                current: 0,
                startX: 0,
                endX: 0,
                auto: 0
            };
            $(this).wrap('<div class="jCarouselWrapper' + b + '"></div>');
            for (var l = "", j = 0; j < i; j++) {
                l += '<a rel="' + j + '" name="' + b + '"></a>'
            };
            $(".jCarouselWrapper" + b).append('<div class="jCarouselNavi">' + l + "</div>");
            $(".jCarouselWrapper" + b + ' .jCarouselNavi a[rel="' + jCarousel.sel[b].current + '"]').addClass("selected");
            $(".jCarouselWrapper" + b).css({
                overflow: "hidden",
                width: "100%"
            });
            $(this).css({
                width: "900000px",
                listStyle: "none",
                padding: 0,
                margin: 0,
                backgroundColor: "transparent"
            });
            $(this).find("li").css("float", "left");
            $(this).find("li").css({
                width: e + "px",
                listStyle: "none",
                padding: 0,
                margin: 0,
                color: "#000"
            });
            $(".jCarouselWrapper" + b + " .jCarouselNavi").css({
                clear: "both",
                textAlign: "center"
            });
            $(".jCarouselWrapper" + b + " .jCarouselNavi b").css({
                fontSize: "14px",
                margin: "0 3px",
                verticalAlign: "5px"
            });
            $(".jCarouselWrapper" + b + " .jCarouselNavi a").css({
                display: "inline-block",
                width: "8px",
                height: "8px",
                margin: "5px",
                padding: "0px",
                backgroundColor: jCarousel.color.back,
                cursor: "pointer",
                borderRadius: "4px",
                boxShadow: "0px -1px 1px " + jCarousel.color.shadow,
                webkitBorderRadius: "4px",
                webkitBoxShadow: "0px -1px 1px " + jCarousel.color.shadow
            });
            $(".jCarouselWrapper" + b + " .jCarouselNavi a.selected").css({
                backgroundColor: jCarousel.color.active
            });
            if (jCarousel.ua == "mobile") {
                $(this).bind("touchstart", function () {
                    var a = $(this).attr("name");
                    jCarousel.active = a;
                    jCarousel.sel[a].startX = event.touches[0].pageX;
                    jCarousel.activeBool = true
                });
                $(window).bind("touchmove", function () {
                    if (jCarousel.activeBool) {
                        var a = jCarousel.active;
                        jCarousel.sel[a].endX = event.touches[0].pageX;
                        var c = -jCarousel.sel[a].startX + jCarousel.sel[a].endX;
                        $(jCarousel.target[a]).css({
                            marginLeft: jCarousel.sel[a].left + c + "px"
                        })
                    }
                });
                $(window).bind("touchend", function () {
                    if (jCarousel.activeBool) {
                        jCarousel.activeBool = false;
                        var a = jCarousel.active,
                            c = -jCarousel.sel[a].startX + jCarousel.sel[a].endX,
                            h = jCarousel.sel[a].width / 5,
                            g = jCarousel.sel[a].current,
                            k = jCarousel.sel[a].max;
                        if (c > h && g > 0) {
                            g--
                        } else {
                            c < -h && g < k - 1 && g++
                        }
                        jCarousel.slide(a, g, 200)
                    }
                })
            }
            $(".jCarouselNavi a").click(function () {
                var a = $(this).attr("name"),
                    c = $(this).attr("rel");
                jCarousel.slide(a, c, 800);
                return false
            });
            jCarousel.num++
        }
    })
};
jCarousel.ini = function () {
    var a = navigator.userAgent;
    jCarousel.ua = a.indexOf("iPhone") > -1 || a.indexOf("iPad") > -1 || a.indexOf("iPod") > -1 ? "mobile" : "pc";
    $(window).bind("orientationchange", function () {
        jCarousel.resize()
    });
    $(window).resize(function () {
        jCarousel.resize()
    })
};
jCarousel.slide = function (f, a) {
    jCarousel.activeBool = false;
    var c = -a * jCarousel.sel[f].width;

    /* 直した部分（CSS を指定するだけ、アニメーションは -webkit-transition で */
    $(jCarousel.target[f]).css({
        marginLeft: c + "px"
    });

    jCarousel.sel[f].left = c;
    jCarousel.sel[f].current = a;
    $(".jCarouselWrapper" + f + " .jCarouselNavi a").css({
        backgroundColor: jCarousel.color.back
    });
    $(".jCarouselWrapper" + f + " .jCarouselNavi a[rel='" + a + "']").css({
        backgroundColor: jCarousel.color.active
    })
};
jCarousel.resize = function () {
    $(".jCarousel").each(function () {
        var f = $(this).attr("name"),
            a = $(".jCarouselWrapper" + f).width();
        jCarousel.sel[f].width = a;
        var c = -jCarousel.sel[f].current * jCarousel.sel[f].width;
        jCarousel.sel[f].left = c;
        $(this).find("li").css({
            width: a + "px"
        });
        $(this).css({
            marginLeft: c + "px"
        })
    })
};
jQuery.extend(jQuery.easing, {
    easeCarousel: function (j, a, h, g, c) {
        return g * ((a = a / c - 1) * a * a + 1) + h
    }
});
$(function () {
    jCarousel.ini();
    jCarousel.set()
});