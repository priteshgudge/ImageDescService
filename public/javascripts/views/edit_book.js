//Side bar navigation.
define([
  'jquery',
  'underscore',
  'backbone',
  '/javascripts/views/side_bar.js',
  '/javascripts/views/book_content.js',
  '/javascripts/views/example_modal.js',
  '/javascripts/collections/dynamic_image_collection.js',
  '/javascripts/collections/image_category_collection.js'
], function($, _, Backbone, SideBarView, BookContentView, ExampleModalView, DynamicImageCollection, ImageCategoryCollection) {
  var EditBookView = Backbone.View.extend({
    
    el: $('#edit_book'),

    render: function() {
      var images = new DynamicImageCollection();
      var q = images.fetch({ data: $.param({ book_id: $("#book_id").val(), book_fragment_id: $("#book_fragment_id").val()}) });
      var editBook = this;
      q.done(function() {
        editBook.renderSideBar(images);
        //Load up the image_categories.
        var imageCategories = new ImageCategoryCollection();
        imageCategories.fetch().done(function() {
          editBook.renderBookContent(images, imageCategories);

          //Load up examples for each category.
          editBook.loadExamples(imageCategories);
        });
      });
    },

    renderSideBar: function(images) {
      var sideBarView = new SideBarView();
      sideBarView.collection = images;
      sideBarView.render();
    },
    
    renderBookContent: function(images, imageCategories) {
      var bookContentView = new BookContentView();
      bookContentView.collection = images;
      bookContentView.imageCategories = imageCategories;
      bookContentView.render();
    },

    loadExamples: function(imageCategories) {
      _.each(imageCategories.models, function(category) {
        var modalView = new ExampleModalView();
        modalView.model = category;
        var template = modalView.render();
        $("body").append(template.$el);
      });
    }
  });
  return EditBookView;
});
