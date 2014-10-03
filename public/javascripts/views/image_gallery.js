//Edit Image.
define([
  'jquery',
  'jquery-ui',
  'underscore',
  'backbone',
  'zoomer',
  '/javascripts/models/decision_tree_image.js',
  '/javascripts/collections/question_collection.js',
  'text!/javascripts/templates/image_gallery.html',
  '/javascripts/views/decision_tree.js',
  '/javascripts/views/describe.js'
], function($, jquery_ui, _, Backbone, zoomer, DecisionTreeImage, QuestionCollection, imageGalleryTemplate, DecisionTreeView, DescribeView){
  var ImageGalleryView = Backbone.View.extend({
    
    el: $("#imageGallery"),

    // Cache the template function for a single item.
    template: _.template(imageGalleryTemplate),

    // The DOM events specific to an item.
    events: {
      "click .toDescribe" : "startDecisionTreeForImage"
    },

    initialize: function() {
      $.zoomer({
        defaultWidthValue: 350,
        defaultHeightValue: 350,
        defaultMaxWidthValue: 350,
        defaultMaxHeightValue: 350,
        maxWidthValue: 1000,
        maxHeightValue: 1000,
        moveValue: 50,
        zoomValue: 1.4,
        thumbnailsWidthValue: 62,
        thumbnailsHeightValue: 62,
        thumbnailsBoxWidthValue: 410,
        zoomerTheme: 'light'
      });
      this.decisionTree = new DecisionTreeView();
    },

    render: function() {

      _.each(this.collection.models, function(img) {
        var newImage = new DecisionTreeImage();
        newImage.src = img["path"];
        var newContextImage = new DecisionTreeImage();
        newContextImage.src = img["context_image_path"];
      });

      this.$el.html(this.template({images: this.collection.toJSON()}));
      return this;
    },

    startDecisionTreeForImage: function(evt) {
      var imageGallery = this;
      evt.preventDefault();
      //Set image.
      var imageId = $(evt.currentTarget).data("image-id").toString();
      var selectedImage = this.collection.findWhere({"image_id":imageId});
      imageGallery.bindImageToggle(imageGallery.getToggleImageSource(selectedImage.get("path")));
      $.zoomer.replaceImage(selectedImage.get("path"));
      this.openDialog(selectedImage);
    },

    bindImageToggle: function(imageSrc) {
      var imageGallery = this;
      var toggleImageSource = imageGallery.getToggleImageSource(imageSrc);
      $("#lightboxTrigger").attr("href", toggleImageSource);
      $("#contextToggle").off("click");
      $("#contextToggle").attr("href", imageSrc);
      $("#contextToggle").on("click", function(evt) {
        $(this).html(imageGallery.getToggleImageLabel(imageSrc));
        evt.preventDefault();
        $.zoomer.replaceImage(imageSrc);
        imageGallery.bindImageToggle(toggleImageSource);
      });
    },

    getToggleImageSource: function(currentSrc) {
      return this.isContext(currentSrc) ? currentSrc.replace("_context.jpg", ".jpg") 
        : currentSrc.replace(".jpg", "_context.jpg");
    },

    getToggleImageLabel: function(currentSrc) {
      return this.isContext(currentSrc) ? "View Image" : "View Image In Context";
    },

    isContext: function(currentSrc) {
      return currentSrc.indexOf("_context") > -1;
    },

    openDialog: function(selectedImage) {
      var gallery = this;
      var dialog = $("#questionnaire").dialog({
        autoOpen: false,
        modal: true,
        width: 850,
        height: 550,
        open: function() {
          
          var questions = new QuestionCollection();
          questions.fetch({
            success: function(collection) {
              gallery.decisionTree.selectedImage = selectedImage;
              gallery.decisionTree.collection = collection;
              gallery.decisionTree.render();
            }
          });
        }, 
        close: function() {
          gallery.resetDecisionTree();
        }
      });
      dialog.dialog("open");
    },

    resetDecisionTree: function() {
      $("#describe").html("");
      $("#summary").html("");
      $("#question").show();
      $("#buttons").show();
      $("#zoomerReset").trigger("click");
      $("#questionnaire").dialog("close");
      $("#contextToggle").html("View Image In Context");
    }

  });
  return ImageGalleryView;
});
