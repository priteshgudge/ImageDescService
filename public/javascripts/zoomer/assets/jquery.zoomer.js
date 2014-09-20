/* -------------------------------------------------------------
	Class: jQquery Zoomer!
	Description: Image zooming & Panning + lightbox tool
	Author: pezflash - http://www.codecanyon.net/user/pezflash
	Version: 1.0
---------------------------------------------------------------- */

(function($) {
	$.zoomer = {version: '1.0'};
	
	$.zoomer = function(settings) {

		$.zoomer.settings = {
			/*----- DEFAULT SETTINGS - NOTE: HTML SETTINGS WILL OVERWRITE THESE ONES -----*/
			defaultWidthValue: 361,				/*	INITIAL VIEWER IMAGE WIDTH (IN PIXELS) */
			defaultHeightValue: 361,			/*	INITIAL VIEWER IMAGE HEIGHT (IN PIXELS) */
			defaultMaxWidthValue: 361,
			defaultMaxHeightValue: 361,
			maxWidthValue: 1000,				/*	MAXIMUM WIDTH VALUE (IN PIXELS) */
			maxHeightValue: 1000,				/*	MAXIMUM HEIGHT VALUE (IN PIXELS) */
			moveValue: 50,						/*	MOVE AMOUNT (IN PIXELS) */
			zoomValue: 1.4,						/*	ZOOMING FACTOR */
			thumbnailsWidthValue: 85,			/*	THUMBNAILS WIDTH (IN PIXELS) */
			thumbnailsHeightValue: 78,			/*	THUMBNAILS HEIGHT (IN PIXELS) */
			thumbnailsBoxWidthValue: 370,		/*	THUMBNAILS CONTENT BOX WIDTH (IN PIXELS) */
			zoomerTheme: 'dark'					/*	THEME STYLE - OPTIONS: 'light' 'dark' 'compact' */
		}

		$.zoomer.setSettings = function(settings) {
			$.zoomer.settings = jQuery.extend($.zoomer.settings, settings);
		}

		$.zoomer.setSettings(settings);

		
		/* SET THEME FOR CONSOLE IMAGES */
		$.zoomer.setImageTheme = function(value) {
			return '<img src="/javascripts/zoomer/images/console_' + $.zoomer.settings.zoomerTheme + '/' + value + '.png">';
		};

		/* MOVE FUNCTION */
		$.zoomer.move = function(i, value) {
			var y = i.position().top;
			var x = i.position().left;
			var yValue;
			var xValue;
			var itemWidth = i.width();
			var itemHeight = i.height();
			
			if (value == 'up') {
				yValue = y + $.zoomer.settings.moveValue;
				if (yValue > 0) yValue = 0;
				i.stop(true, true).animate({top: yValue});
			}
			
			if (value == 'down') {		
				yValue = y - $.zoomer.settings.moveValue;
				if ($.zoomer.settings.defaultHeightValue + Math.abs(yValue) > itemHeight) yValue = $.zoomer.settings.defaultHeightValue - itemHeight;
				i.stop(true, true).animate({top: yValue});
			}
			
			if (value == 'left') {	
				xValue = x + $.zoomer.settings.moveValue;
				if (xValue > 0) xValue = 0;
				i.stop(true, true).animate({left: xValue});
			}
			
			if (value == 'right') {
				xValue = x - $.zoomer.settings.moveValue;
				if ($.zoomer.settings.defaultWidthValue + Math.abs(xValue) > itemWidth) xValue = $.zoomer.settings.defaultWidthValue - itemWidth;
				i.stop(true, true).animate({left: xValue});
			}
		};

		/* ZOOM FUNCTION */
		$.zoomer.zoom = function(i, value) {
			var y = i.position().top;
			var x = i.position().left;
			var yValue;
			var xValue;
			var itemWidth = i.width();
			var itemHeight = i.height();
			var widthValue;
			var heightValue;

			if (value == 'in') {
				if (itemHeight < $.zoomer.settings.maxHeightValue) {
				
					widthValue = itemWidth * $.zoomer.settings.zoomValue;
					if (widthValue > $.zoomer.settings.maxWidthValue) widthValue = $.zoomer.settings.maxWidthValue;
					xValue = x - ((widthValue - itemWidth) / 2);
					if (xValue > 0) xValue = 0;
					if ($.zoomer.settings.defaultWidthValue + Math.abs(xValue) > widthValue) xValue = $.zoomer.settings.defaultWidthValue - widthValue;
					
					heightValue = itemHeight * $.zoomer.settings.zoomValue;
					if (heightValue > $.zoomer.settings.maxHeightValue) heightValue = $.zoomer.settings.maxHeightValue;
					yValue = y - ((heightValue - itemHeight) / 2);
					if (yValue > 0) yValue = 0;
					if ($.zoomer.settings.defaultHeightValue + Math.abs(yValue) > heightValue) yValue = $.zoomer.settings.defaultHeightValue - heightValue;

					if (heightValue == $.zoomer.settings.defaultHeightValue) { $.zoomer.stopDrag(i); }
					else { $.zoomer.startDrag(i); }

					i.stop(true, true).animate({height: heightValue, width: widthValue, top: yValue, left: xValue});
				}
			}
				
			if (value == 'out') {	
				if (itemHeight > $.zoomer.settings.defaultHeightValue) {
				
					widthValue = itemWidth / $.zoomer.settings.zoomValue;
					if (widthValue < $.zoomer.settings.defaultWidthValue) widthValue = $.zoomer.settings.defaultWidthValue;
					xValue = x + ((itemWidth - widthValue) / 2);
					if (xValue > 0) xValue = 0;
					if ($.zoomer.settings.defaultWidthValue + Math.abs(xValue) > widthValue) xValue = $.zoomer.settings.defaultWidthValue - widthValue;
			
					heightValue = itemHeight / $.zoomer.settings.zoomValue;
					if (heightValue < $.zoomer.settings.defaultHeightValue) heightValue = $.zoomer.settings.defaultHeightValue;
					yValue = y + ((itemHeight - heightValue) / 2);
					if (yValue > 0) xValue = 0;
					if ($.zoomer.settings.defaultHeightValue + Math.abs(yValue) > heightValue) yValue = $.zoomer.settings.defaultHeightValue - heightValue;

					if (heightValue == $.zoomer.settings.defaultHeightValue) { $.zoomer.stopDrag(i); }
					else { $.zoomer.startDrag(i); }

					i.stop(true, true).animate({height: heightValue, width: widthValue, top: yValue, left: xValue});
				}
			}
			
			if (value == 'reset') {
				$.zoomer.stopDrag(i);
				i.stop(true, true).animate({height: $.zoomer.settings.defaultHeightValue, width: $.zoomer.settings.defaultWidthValue, top: 0, left: 0});
			}
		};

		/* DRAGGING FUNCTIONS - LIMIT ON BOUNDARIES*/
		$.zoomer.startDrag = function(i) {
			var topLimit = 0;
			var leftLimit = 0;

			i.draggable({
				start: function(event, ui) {
					if (ui.position != undefined) {
						topLimit = ui.position.top;
						leftLimit = ui.position.left;
					}
				},
				drag: function(event, ui) {
					topLimit = ui.position.top;
					leftLimit = ui.position.left;
					var bottomLimit = i.height() - $.zoomer.settings.defaultHeightValue;
					var rightLimit = i.width() - $.zoomer.settings.defaultWidthValue;					
					if (ui.position.top < 0 && ui.position.top * -1 > bottomLimit) topLimit = bottomLimit * -1;
					if (ui.position.top > 0) topLimit = 0;					
					if (ui.position.left < 0 && ui.position.left * -1 > rightLimit) leftLimit = rightLimit * -1;
					if (ui.position.left > 0) leftLimit = 0;
					ui.position.top = topLimit;
					ui.position.left = leftLimit;
				}
			});

			i.css("cursor", "move");
		};

		$.zoomer.stopDrag = function(i) {
			if (i.data('draggable')) {
				i.draggable("destroy");
				i.css("cursor", "default");
			}
		};

		
		/* ASIGN MAIN TARGET AND RESIZE ELEMENTS */	
		var z = $(".zoomer");
		z.find(".holder").css('width', $.zoomer.settings.defaultWidthValue);
		z.find(".holder .image").css('height', $.zoomer.settings.defaultHeightValue);
		z.find(".holder .image").css('width', $.zoomer.settings.defaultWidthValue);
		z.find(".thumbs").css('width', $.zoomer.settings.thumbnailsBoxWidthValue);
		z.find(".thumbs img").css('width', $.zoomer.settings.thumbnailsWidthValue);
		z.find(".thumbs img").css('height', $.zoomer.settings.thumbnailsHeightValue);
		
		var i = z.find(".holder .image .target");
		i.css('height', $.zoomer.settings.defaultHeightValue);
		i.css('width', $.zoomer.settings.defaultWidthValue);	
		
		
		/* ASIGN BUTTON ACTIONS & IMAGES (THEME) */
		$("#zoomerLeft").click(function(event) { event.preventDefault(); $.zoomer.move(i, 'left');}).prepend($.zoomer.setImageTheme('left'));
		$("#zoomerRight").click(function(event) { event.preventDefault();  $.zoomer.move(i, 'right');}).prepend($.zoomer.setImageTheme('right'));
		$("#zoomerUp").click(function(event) { event.preventDefault(); $.zoomer.move(i, 'up');}).prepend($.zoomer.setImageTheme('up'));
		$("#zoomerDown").click(function(event) { event.preventDefault(); $.zoomer.move(i, 'down');}).prepend($.zoomer.setImageTheme('down'));
		$("#zoomerIn").click(function(event) { event.preventDefault();$.zoomer.zoom(i, 'in');}).prepend($.zoomer.setImageTheme('in'));
		$("#zoomerOut").click(function(event) { event.preventDefault();$.zoomer.zoom(i, 'out');}).prepend($.zoomer.setImageTheme('out'));
		$("#zoomerReset").click(function(event) { event.preventDefault();$.zoomer.zoom(i, 'reset');}).prepend($.zoomer.setImageTheme('reset'));
		$("#zoomerView").click(function(event) { event.preventDefault();$(".lightbox a[href='" + i.attr("src") + "']:eq(0)").trigger("click");}).prepend($.zoomer.setImageTheme('view'));
		
		
		/* IMAGE REPLACEMENT & PRETTYLOADER */
		$.prettyLoader();
		$.zoomer.replaceImage = function(newImageSrc) {
			$.zoomer.stopDrag(i);
			$.prettyLoader.show();
			i.stop(true, true).animate({height: settings.defaultHeightValue, width: settings.defaultWidthValue, top: 0, left: 0}, 300, function() {
				i.stop(true, true).fadeTo('fast', 0, function() {
					var $newImg = $("<img src='" + newImageSrc + "' style='display:none;'>");
					$newImg.load(function() {
						i.attr("src", newImageSrc);
						$.zoomer.updateImageSizes(i);
						i.stop(true, true).fadeTo('slow', 1, 'linear');
						$.prettyLoader.hide();
					});
				});
			});
		};

		$.zoomer.updateImageSizes = function (i) {
	      //Get image width and height.
	      var pic_real_width, pic_real_height;
	      $("<img/>").attr("src", $(i).attr("src")).load(function() {
	          pic_real_width = this.width;   
	          pic_real_height = this.height; 
	          if (pic_real_width > $.zoomer.settings.defaultMaxWidthValue) {
	            $.zoomer.updateWidth(i);
	          } else {
	            $.zoomer.updateHeight(i);
	          }
	      });
	    };

	    $.zoomer.updateWidth = function(i) {
	      $(i).css("height", "");
	      $(".image-resize").css("width", $.zoomer.settings.defaultMaxWidthValue);
	      $("#zoomer").css("width", $.zoomer.settings.defaultMaxWidthValue);
	      var newHeight = $(i).height();
	      if (newHeight > $.zoomer.settings.defaultMaxWidthValue) {
	        $.zoomer.updateHeight(i);
	      } else {
	        $(".image-resize").css("height", $(i).height());
	         $.zoomer.setSettings({defaultWidthValue: $.zoomer.settings.defaultMaxWidthValue, defaultHeightValue: newHeight});
	      }
	    };

	    $.zoomer.updateHeight = function(i) {
	      $(i).css("width", "");
	      $(".image-resize").css("height", $.zoomer.settings.defaultMaxHeightValue);
	      var newWidth = $(i).width();
	      $(".image-resize").css("width", newWidth);
	      $("#zoomer").css("width", newWidth);
	      $.zoomer.setSettings({defaultHeightValue: $.zoomer.settings.defaultMaxHeightValue, defaultWeightValue: newWidth});
	    };
	};

})(jQuery);

