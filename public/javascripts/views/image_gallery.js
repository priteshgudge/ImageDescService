//Edit Image.
define([
  'jquery',
  'underscore',
  'backbone',
  'bootstrap/modal',
  'fancybox',
  '/javascripts/models/decision_tree_image.js',
  '/javascripts/collections/question_collection.js',
  'text!/javascripts/templates/image_gallery.html',
  '/javascripts/views/decision_tree.js',
  '/javascripts/views/describe.js'
], function($, _, Backbone, modal, fancybox, DecisionTreeImage, QuestionCollection, imageGalleryTemplate, DecisionTreeView, DescribeView){
  var ImageGalleryView = Backbone.View.extend({
    
    el: $("#imageGallery"),

    // Cache the template function for a single item.
    template: _.template(imageGalleryTemplate),

    // The DOM events specific to an item.
    events: {
      "click .toDescribe" : "startDecisionTreeForImage"
    },

    initialize: function() {
      var imageGallery = this;
      $('#questionnaire').modal({
        keyboard: true,
        show: false,
        backdrop: 'static'
      });
      $('#questionnaire').on('show.bs.modal', function (e) {
        imageGallery.startDecisionTree();
      });

      $("#questionnaire").on('hidden.bs.modal', function (e) {
        imageGallery.resetDecisionTree();
      });
      $('.fancybox').fancybox({ 
        'scrolling'     : 'no',
        'overlayOpacity': 0.1,
        'showCloseButton'   : true
      });
      imageGallery.decisionTree = new DecisionTreeView();
    },

    render: function() {
      this.$el.html(this.template({images: this.collection.toJSON()}));
      return this;
    },

    startDecisionTreeForImage: function(evt) {
      var imageGallery = this;
      evt.preventDefault();
      //Set image.
      var imageId = $(evt.currentTarget).data("image-id").toString();
      var selectedImage = this.collection.findWhere({"image_id":imageId});
      imageGallery.selectedImage = selectedImage;
      $("#questionnaire").modal('show');
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

    startDecisionTree: function() {
      var gallery = this;
      var questions = new QuestionCollection();
      questions.fetch({
        success: function(collection) {
          gallery.decisionTree.selectedImage = gallery.selectedImage;
          gallery.decisionTree.collection = collection;
          gallery.decisionTree.render();
        }
      });
    },

    resetDecisionTree: function() {
      $("#describe").html("");
      $("#summary").html("");
      $("#question").show();
      $("#buttons").show();
      $("#zoomerReset").trigger("click");
      $("#contextToggle").html("View Image In Context");
    }

  });
  return ImageGalleryView;
});
