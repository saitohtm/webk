//<![CDATA[
$(function(){
	var hsort_flg = false;
	//setup
	var vg = $("#grid-content").vgrid({
		easing: "easeOutQuint",
		useLoadImageEvent: true,
		useFontSizeListener: true,
		time: 400,
		delay: 20,
		fadeIn: {
			time: 500,
			delay: 50
		},
		onStart: function(){
			$("#message1")
				.css("visibility", "visible")
				.fadeOut("slow",function(){
					$(this).show().css("visibility", "hidden");
				});
		},
		onFinish: function(){
			$("#message2")
				.css("visibility", "visible")
				.fadeOut("slow",function(){
					$(this).show().css("visibility", "hidden");
				});
		}
	});


	//delete
//	vg.find("a").live('click', function(e){
//		$(this).parent().parent().fadeOut(200, function(){
//			$(this).remove();
//			vg.vgrefresh();
//		});
//		return false;
//	});

});
//]]>
