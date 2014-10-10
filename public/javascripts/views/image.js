//Image with zoom options.
define([
  'jquery',
  'underscore',
  'backbone',
  'jquery-ui',
  'text!/javascripts/templates/image_with_zoom.html'
], function($, _, Backbone, jqueryui, imageWithZoomTemplate) {
  var ImageView = Backbone.View.extend({
    //div.
    tagName:  "div",

    itemWidth: -1,
    itemHeight: -1,
    widthValue: -1,
    heightValue: -1,
    maxHeightValue: 1000,
    defaultHeightValue: 450,
    maxWidthValue: 1000,
    defaultWidthValue: 450,
    zoomValue: 1.2,
    moveValue: 50,
    x: -1,
    y: -1,
    xValue: -1,
    yValue: -1,

    // The DOM events specific to an item.
    events: {
      "click .zoomerLeft": "moveLeft",
      "click .zoomerRight": "moveRight",
      "click .zoomerUp": "moveUp",
      "click .zoomerDown": "moveDown",
      "click .zoomerIn": "zoomIn",
      "click .zoomerOut": "zoomOut",
      "click .zoomerReset": "reset",
      "click .toggle": "toggleImage"
    },

    // Render the image with zoom options
    render: function() {
      var compiledTemplate = _.template( imageWithZoomTemplate, {image: this.model});
      this.$el.html(compiledTemplate);
      this.$('.fancybox').fancybox({ 
        'scrolling'     : 'no',
        'overlayOpacity': 0.1,
        'showCloseButton'   : true
      });
      return this;
    },

    initializeZoomer: function() {
      //Get initial image sizes.
      var imageView = this;
      imageView.$(".loader").show();
      imageView.$(".console").hide();
      imageView.$(".target").load(function() {
        var image = imageView.$(".target");
        imageView.itemWidth = image.width();
        imageView.itemHeight = image.height();
        imageView.defaultWidthValue = imageView.itemWidth;
        imageView.defaultHeightValue = imageView.itemHeight;
        imageView.$(".thumbnail").css("overflow", "hidden");
        imageView.$(".thumbnail").css("height", imageView.itemHeight);
        imageView.$(".thumbnail").css("width", imageView.itemWidth);
        imageView.$(".console").show();
        imageView.$(".loader").hide();
      });
    },

    toggleImage: function(e) {
      var imageView = this;
      e.preventDefault();
      var isContext = imageView.isContext(imageView.$(".target").attr("src"));
      $(e.currentTarget).html(isContext ? "View Image In Context" : "View Image");
      var toggleImageSource = isContext ? imageView.model.get("path") : imageView.model.get("context_image_path");
      imageView.$(".target").attr("src", "/images/zoomer/ajax-loader.gif")
      imageView.$(".thumbnail").css("");
      imageView.$(".target").css("");
      imageView.$(".target").attr("src", toggleImageSource);
      imageView.initializeZoomer();
      imageView.$(".lightboxTrigger").attr("href", toggleImageSource);
    },

    isContext: function(currentSrc) {
      return currentSrc.indexOf("_context") > -1;
    },

    zoomIn: function() {
      var imageView = this;
      imageView.setXYAndHeight();
      var xValue, yValue;
      if (imageView.itemWidth < imageView.maxWidthValue) {
          imageView.widthValue = imageView.itemWidth * imageView.zoomValue;
          if (imageView.widthValue > imageView.maxWidthValue) {
            imageView.widthValue = imageView.maxWidthValue;
          }
          xValue = imageView.x - ((imageView.widthValue - imageView.itemWidth) / 2);
          if (xValue > 0) {
            xValue = 0;
          }
          if (imageView.defaultWidthValue + Math.abs(xValue) > imageView.widthValue) {
            xValue = imageView.defaultWidthValue - imageView.widthValue;
          }
          imageView.heightValue = imageView.itemHeight * imageView.zoomValue;
          if (imageView.heightValue > imageView.maxHeightValue) {
            imageView.heightValue = imageView.maxHeightValue;
          }
          yValue = imageView.y - ((imageView.heightValue - imageView.itemHeight) / 2);
          if (yValue > 0) {
            yValue = 0;
          }
          if (imageView.defaultHeightValue + Math.abs(yValue) > imageView.heightValue) yValue = imageView.defaultHeightValue - imageView.heightValue;

          if (imageView.heightValue == imageView.defaultHeightValue) { 
            imageView.stopDrag(); 
          } else { 
            imageView.startDrag(); 
          }
          imageView.$(".target").stop(true, true).animate({width: imageView.widthValue, "max-width": imageView.widthValue, top: yValue, left: xValue});
          imageView.itemWidth = imageView.widthValue;
      }
    },

    zoomOut: function() {
      var imageView = this;
      imageView.setXYAndHeight();
      var xValue, yValue;
      if (imageView.itemWidth > imageView.defaultWidthValue) {
        imageView.widthValue = imageView.itemWidth / imageView.zoomValue;
        if (imageView.widthValue < imageView.defaultWidthValue) imageView.widthValue = imageView.defaultWidthValue;
        xValue = imageView.x + ((imageView.itemWidth - imageView.widthValue) / 2);
        if (xValue > 0) xValue = 0;
        if (imageView.defaultWidthValue + Math.abs(xValue) > imageView.widthValue) xValue = imageView.defaultWidthValue - imageView.widthValue;
    
        imageView.heightValue = imageView.itemHeight / imageView.zoomValue;
        if (imageView.heightValue < imageView.defaultHeightValue) imageView.heightValue = imageView.defaultHeightValue;
        yValue = imageView.y + ((imageView.itemHeight - imageView.heightValue) / 2);
        if (yValue > 0) xValue = 0;
        if (imageView.defaultHeightValue + Math.abs(yValue) > imageView.heightValue) yValue = imageView.defaultHeightValue - imageView.heightValue;

        if (imageView.heightValue == imageView.defaultHeightValue) { imageView.stopDrag(); }
        else { imageView.startDrag(); }

        imageView.$(".target").stop(true, true).animate({width: imageView.widthValue, "max-width": imageView.widthValue, top: yValue, left: xValue});
        imageView.itemWidth = imageView.widthValue;
      }
    },

    startDrag: function() {
      var imageView = this;
      var i = imageView.$(".target");
      var topLimit = 0;
      var leftLimit = 0;

      this.$(".target").draggable({
        start: function(event, ui) {
          if (ui.position != undefined) {
            topLimit = ui.position.top;
            leftLimit = ui.position.left;
          }
        },
        drag: function(event, ui) {
          topLimit = ui.position.top;
          leftLimit = ui.position.left;
          var bottomLimit = i.height() - imageView.defaultHeightValue;
          var rightLimit = i.width() - imageView.defaultWidthValue;         
          if (ui.position.top < 0 && ui.position.top * -1 > bottomLimit) topLimit = bottomLimit * -1;
          if (ui.position.top > 0) topLimit = 0;          
          if (ui.position.left < 0 && ui.position.left * -1 > rightLimit) leftLimit = rightLimit * -1;
          if (ui.position.left > 0) leftLimit = 0;
          ui.position.top = topLimit;
          ui.position.left = leftLimit;
        }
      });

      i.css("cursor", "move");
    },

    reset: function() {
      var imageView = this;
      imageView.stopDrag();
      this.$(".target").stop(true, true).animate({width: imageView.defaultWidthValue, top: 0, left: 0});
    },

    stopDrag: function() {
      var i = this.$(".target");
      if (i.data('draggable')) {
        i.draggable("destroy");
        i.css("cursor", "default");
      }
    },

    moveUp: function() {
      var imageView = this;
      imageView.setXYAndHeight();
      var yValue;
      yValue = imageView.y + imageView.moveValue;
      if (yValue > 0) {
        yValue = 0;
      }
      imageView.$(".target").stop(true, true).animate({top: yValue});
    },

    moveDown: function() {
      var imageView = this;
      imageView.setXYAndHeight();
      var yValue;
      yValue = imageView.y - imageView.moveValue;
      if (imageView.defaultHeightValue + Math.abs(yValue) > imageView.itemHeight) {
        yValue = imageView.defaultHeightValue - imageView.itemHeight;
      }
      imageView.$(".target").stop(true, true).animate({top: yValue});
    },

    moveLeft: function() {
      var imageView = this;
      imageView.setXYAndHeight();
      var xValue;
      xValue = imageView.x + imageView.moveValue;
      if (xValue > 0) {
        xValue = 0;
      }
      imageView.$(".target").stop(true, true).animate({left: xValue});
    },

    moveRight: function() {
      var imageView = this;
      imageView.setXYAndHeight();
      var xValue;
      xValue = imageView.x - imageView.moveValue;
      if (imageView.defaultWidthValue + Math.abs(xValue) > imageView.itemWidth) {
        xValue = imageView.defaultWidthValue - imageView.itemWidth;
      }
      imageView.$(".target").stop(true, true).animate({left: xValue});
    },

    setXYAndHeight: function() {
      this.y = this.$(".target").position().top;
      this.x = this.$(".target").position().left;
      this.itemHeight = this.$(".target").height();
    }

  });
  return ImageView;
});

