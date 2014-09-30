//Edit Image.
define([
  'jquery',
  'underscore',
  'backbone',
  '/javascripts/libs/ckeditor/ckeditor.js',
  '/javascripts/libs/ckeditor/adapters/jquery.js',
  '/javascripts/edit_book/models/dynamic_image.js',
  'text!/javascripts/edit_book/templates/edit_image.html'
], function($, _, Backbone, ckeditorCore, ckeditorJquery, DynamicImage, editImageTemplate){
  var EditImageView = Backbone.View.extend({
    
    //div.
    tagName:  "div",

    events: {
      "change select": "toggleEditor",
      "click .cancel": "cancelEditor",
      "click .save": "saveDescription"
    },

    ckeditorConfig: {
        extraPlugins: 'onchange',
        minimumChangeMilliseconds: 100,
        scayt_autoStartup:true,
        toolbar :
        [
            { name: 'basicstyles', items : [ 'Bold','Italic','Underline' ] },
            { name: 'paragraph', items : [ 'NumberedList','BulletedList' ] },
            { name: 'editing', items : ['Scayt' ] },
            { name: 'styles', items : [ 'Format' ] },
            { name: 'insert', items : [ 'Table','Link','Unlink' ] },
            { name: 'tools', items : [ 'Undo', 'Redo', '-', 'Source','Maximize' ] }
        ]
    },

    render: function() {
      var compiledTemplate = _.template( editImageTemplate, { image: this.model, image_categories: this.imageCategories.models} );
      this.$el.html(compiledTemplate);
      return this;
    },

    toggleEditor: function(e) {
      var editView = this;
      if ($(e.currentTarget).val() == "true") {
        var longDescription = editView.$(".long-description");
        $("textarea", $(longDescription)).ckeditor(editView.ckeditorConfig);
        longDescription.show();
      }
    },

    cancelEditor: function(e) {
      console.log(e);
      e.preventDefault();
      this.$(".long-description").hide();
    },

    saveDescription: function(e) {

    }


  });
  return EditImageView;
});
