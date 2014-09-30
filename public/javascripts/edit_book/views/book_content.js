//Side bar navigation.
define([
  'jquery',
  'underscore',
  'backbone',
  'lazyload',
  '/javascripts/libs/ckeditor/ckeditor.js',
  '/javascripts/edit_book/views/edit_image.js'
], function($, _, Backbone, lazyload, ckeditor, EditImageView){
  var BookContentView = Backbone.View.extend({
    el: $('#book_content'),

    render: function() {
      var contentView = this;
      var bookUrl = "/edit_book/content?book_id=" + $("#book_id").val() + "&book_fragment_id=" + $("#book_fragment_id").val();
      $.get(bookUrl, function(html) {
        var book = $('<html />').html(html)
        var stylesheets = $(book).find("link").clone();
        $("head").prepend(stylesheets);
        $(book).find("link").remove();
        contentView.lazyLoadImages(book);
        // .html strips illegal elements out (html, head, etc)
        contentView.$el.html(book.html());
        contentView.renderImages();
      });
    },

    lazyLoadImages: function(book) {
      _.each(this.collection.models, function(image) {
        //find the image in the book.
        var currentImageNode = $("img[img-id='" + image.get("id") + "']", book);
        currentImageNode.attr("src", image.get("image_source"));
      });
    },

    renderImages: function() {
      var contentView = this;
      _.each(contentView.collection.models, function(image) {
        var editImage = new EditImageView();
        editImage.imageCategories = contentView.imageCategories;
        editImage.model = image;
        var domImage = $("img[img-id='" + image.get("id") + "']");
        var newImage = domImage.clone();
        var editDiv = editImage.render();
        newImage.lazyload({
          threshold : 100
        });
        $(".domImage", editDiv.el).append(newImage);
        $(".altText", editDiv.el).html(newImage.attr("alt"));
        domImage.replaceWith(editDiv.el);
      });
    }
  });
  return BookContentView;
});
