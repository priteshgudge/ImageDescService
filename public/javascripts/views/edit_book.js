//Side bar navigation.
define([
  'jquery',
  'underscore',
  'backbone',
  '/javascripts/views/side_bar.js',
  '/javascripts/views/book_content.js',
  '/javascripts/collections/dynamic_image_collection.js',
  '/javascripts/collections/image_category_collection.js'
], function($, _, Backbone, SideBarView, BookContentView, DynamicImageCollection, ImageCategoryCollection) {
  var EditBookView = Backbone.View.extend({
    
    el: $('#edit_book'),

    render: function() {
      var images = new DynamicImageCollection();
      var q = images.fetch({ data: $.param({ book_id: $("#book_id").val(), book_fragment_id: $("#book_fragment_id").val()}) });
      q.done(function() {
        var sideBarView = new SideBarView();
        sideBarView.collection = images;
        sideBarView.render();
        //Load up the image_categories.
        var imageCategories = new ImageCategoryCollection();
        imageCategories.fetch().done(function() {
          var bookContentView = new BookContentView();
          bookContentView.collection = images;
          bookContentView.imageCategories = imageCategories;
          bookContentView.render();
        });
      });
    }
  });
  return EditBookView;
});
