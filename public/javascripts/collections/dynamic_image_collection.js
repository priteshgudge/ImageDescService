// Image Collection
// ---------------
define([
  'underscore',
  'backbone',
  '/javascripts/models/dynamic_image.js'
], function(_, Backbone, DynamicImage){
  var DynamicImageCollection = Backbone.Collection.extend({
    // Reference to this collection's model.
	  model: DynamicImage,

	  // load the images.
	  url: '/edit_book/book_images'
  });
  return DynamicImageCollection;
});
