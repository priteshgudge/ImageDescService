//Side bar navigation.
define([
  'jquery',
  'underscore',
  'backbone',
  '/javascripts/views/side_bar.js',
  '/javascripts/views/book_content.js',
  '/javascripts/views/example_modal.js',
  '/javascripts/views/math_cheat_sheet.js',
  '/javascripts/collections/dynamic_image_collection.js',
  '/javascripts/collections/image_category_collection.js'
], function($, _, Backbone, SideBarView, BookContentView, ExampleModalView, MathCheatSheetView, DynamicImageCollection, ImageCategoryCollection) {
  var EditBookView = Backbone.View.extend({
    
    el: $('#edit_book'),

    render: function() {
      var editBookView = this;

      editBookView.categories = new ImageCategoryCollection();
      editBookView.categories.fetch({
        success: function(categories, response, options) {
          editBookView.loadExamples();
          editBookView.images = new DynamicImageCollection();
          editBookView.images.fetch({
            data: {book_id: $("#book_id").val(), book_fragment_id: $("#book_fragment_id").val()},
            success: function(images, response, options) {
              editBookView.renderSideBar();
              editBookView.renderBookContent();
            }
          });
        }
      });
      //add math cheat sheet.
      var mathCheatSheet = new MathCheatSheetView();
      $("body").append(mathCheatSheet.render().$el);
      MathJax.Hub.Queue(["Typeset",MathJax.Hub]);
    },

    renderSideBar: function() {
      var sideBarView = new SideBarView();
      sideBarView.collection = this.images;
      sideBarView.render();
    },
    
    renderBookContent: function() {
      var editBookView = this;
      var bookContentView = new BookContentView();
      bookContentView.collection = editBookView.images;
      bookContentView.imageCategories = editBookView.categories;
      bookContentView.render();
    },

    loadExamples: function() {
      var editBookView = this;
      _.each(editBookView.categories.models, function(category) {
        var modalView = new ExampleModalView();
        modalView.model = category;
        var template = modalView.render();
        $("body").append(template.$el);
      });
    }
  });
  return EditBookView;
});
