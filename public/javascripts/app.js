// Filename: app.js
define([
  'jquery',
  'underscore',
  'backbone',
  'mespeak',
  '/javascripts/views/edit_book.js'
], function($, _, Backbone, mespeak, EditBookView) {

  var editBook;
  
  var initialize = function() {
    //Kick off the whole page. 
    this.editBook = new EditBookView();
    this.editBook.render();
    //initialize meSpeak
    meSpeak.loadConfig("/javascripts/libs/mespeak/mespeak_config.json"); 
    meSpeak.loadVoice('/javascripts/libs/mespeak/voices/en/en-us.json'); 
  }
  
  return App = {
    initialize: initialize,
    editBook: editBook
  };
});
