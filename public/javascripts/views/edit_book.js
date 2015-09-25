//Side bar navigation.
define([
  'jquery',
  'underscore',
  'backbone',
  'mespeak',
  'MathJax',
  'JSWAVES',
  '/javascripts/views/side_bar.js',
  '/javascripts/views/book_content.js',
  '/javascripts/views/example_modal.js',
  '/javascripts/views/math_cheat_sheet.js',
  '/javascripts/models/image_category.js',
  '/javascripts/collections/dynamic_image_collection.js',
  '/javascripts/collections/image_category_collection.js'
], function($, _, Backbone, mespeak, MathJax, JSWAVES, SideBarView, BookContentView, ExampleModalView, MathCheatSheetView, Category, DynamicImageCollection, ImageCategoryCollection) {
  var EditBookView = Backbone.View.extend({
    
    el: $('#edit_book'),

    initialize: function() {
      //initialize meSpeak
      meSpeak.loadConfig("/javascripts/libs/mespeak/mespeak_config.json"); 
      meSpeak.loadVoice('/javascripts/libs/mespeak/voices/en/en-us.json'); 
    },

    render: function() {
      var editBookView = this;
      editBookView.images = new DynamicImageCollection();
      editBookView.images.fetch({
        data: {book_id: $("#book_id").val(), book_fragment_id: $("#book_fragment_id").val()},
        success: function(images, response, options) {
          editBookView.renderSideBar();
          editBookView.renderBookContent();
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
      bookContentView.render();
    }
  });
  return EditBookView;
});
