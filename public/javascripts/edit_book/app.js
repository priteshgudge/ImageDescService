// Filename: app.js
define([
  'jquery',
  'underscore',
  'backbone',
  '/javascripts/edit_book/views/side_bar.js',
  '/javascripts/edit_book/views/book_content.js',
  '/javascripts/edit_book/collections/dynamic_image_collection.js',
  '/javascripts/edit_book/collections/image_category_collection.js'
], function($, _, Backbone, SideBarView, BookContentView, DynamicImageCollection, ImageCategoryCollection){
  
  var initialize = function() {
    //Initial the images.
    var images = new DynamicImageCollection();
    var q = images.fetch({ data: $.param({ book_id: $("#book_id").val(), book_fragment_id: $("#book_fragment_id").val()}) });
    q.done(function() {
      var sideBarView = new SideBarView();

      //Load up the image_categories.
      var imageCategories = new ImageCategoryCollection();
      imageCategories.fetch().done(function() {
        var bookContentView = new BookContentView();
        sideBarView.collection = images;
        bookContentView.collection = images;
        bookContentView.imageCategories = imageCategories;
        sideBarView.render()
        bookContentView.render();
      });
    });
  }

  return {
    initialize: initialize
  };
});
