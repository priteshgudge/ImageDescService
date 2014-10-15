// Filename: app.js
define([
  'jquery',
  'underscore',
  'backbone',
  '/javascripts/views/edit_book.js'
], function($, _, Backbone, EditBookView) {

  var editBook;
  
  var initialize = function() {
    //Kick off the whole page. 
    this.editBook = new EditBookView();
    this.editBook.render();
  }
  
  return App = {
    initialize: initialize,
    editBook: editBook
  };
});
