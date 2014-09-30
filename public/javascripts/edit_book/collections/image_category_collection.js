// Image Collection
// ---------------
define([
  'underscore',
  'backbone',
  '/javascripts/edit_book/models/image_category.js'
], function(_, Backbone, ImageCategory){
  var ImageCategoryCollection = Backbone.Collection.extend({
    // Reference to this collection's model.
	model: ImageCategory,

	// load the images.
	url: '/edit_book/image_categories'
  });
  return ImageCategoryCollection;
});
