//Main Book Content.
define([
  'jquery',
  'underscore',
  'backbone',
  '/javascripts/views/edit_image.js',
  '/javascripts/views/duplicate_image.js'
], function($, _, Backbone, EditImageView, DuplicateImageView){
  var BookContentView = Backbone.View.extend({
    el: $('#book_content'),

    render: function() {
      var contentView = this;
      var bookUrl = "/edit_book/content?book_id=" + $("#book_id").val() + "&book_fragment_id=" + $("#book_fragment_id").val();
      $.get(bookUrl, function(html) {
        var book = $('<html />').html(html);
        var stylesheets = $(book).find("link").clone();
        $("head").prepend(stylesheets);
        $(book).find("link").remove();
        $(book).find("img").attr("src", "");
        // .html strips illegal elements out (html, head, etc)
        contentView.$el.html(book.html());
        contentView.renderImages();
      });
    },

    renderImages: function() {
      var contentView = this;
      _.each(contentView.collection.models, function(image, i) {

        //Output form for first instance of image.
        contentView.outputEditForm(image, i);

        //handle all duplicates.
        contentView.renderDuplicates(image);
      });
    },

    outputEditForm: function(image, i) {
      var contentView = this;
      var editImage = new EditImageView();
      editImage.imageCategories = contentView.imageCategories;
      editImage.model = image;
      editImage.previousImage = contentView.collection.models[i-1];
      editImage.nextImage = contentView.collection.models[i+1];

      //Handle the first one.
      var domImage = $("img[img-id='" + image.get("id") + "']:first");
      domImage.attr("src", image.get("image_source"));
      var newImage = domImage.clone();
      var editDiv = editImage.render();
      $(".domImage", editDiv.el).append(newImage);
      $(".altText", editDiv.el).html(newImage.attr("alt"));
      domImage.replaceWith(editDiv.el);
    },

    renderDuplicates: function(image) {
      var dupeImage = new DuplicateImageView();
      var template = dupeImage.render();
      var duplicates = $("img[img-id='" + image.get("id") + "']:not(:eq(0))");
      duplicates.each(function() {
        var domImage = $(this);
        domImage.attr("src", image.get("image_source"));
        $(".duplicate-container", dupeImage.el).prepend(domImage.clone());
        domImage.replaceWith(dupeImage.el);
      });
    }

  });
  return BookContentView;
});
