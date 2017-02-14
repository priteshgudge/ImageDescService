// Filename: app.js
define([
  'module',
  'jquery',
  'underscore',
  'backbone',
  '/javascripts/views/edit_book.js',
  '/javascripts/views/example_modal.js',
  '/javascripts/collections/image_category_collection.js',
  '/javascripts/models/image_category.js'
], function(module, $, _, Backbone, EditBookView, ExampleModalView, ImageCategories, Category) {

  var editBook;
  var categories;
  
  var initialize = function() {
    this.categories = new ImageCategories(module.config().categories);
    //Start loading examples
    _.each(this.categories.models, function(category) {
      var modalView = new ExampleModalView();
      modalView.model = new Category(category);
      var template = modalView.render();
      $("body").append(template.$el);
    });

    //Kick off the whole page. 
    this.editBook = new EditBookView();
    this.editBook.render();
  }
  
  return App = {
    initialize: initialize,
    editBook: editBook,
    categories: categories
  };
});
