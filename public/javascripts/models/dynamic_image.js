// Filename: models/dynamic_image
define([
  'underscore',
  'backbone'
], function(_, Backbone){
  var DynamicImage = Backbone.Model.extend({
  	urlRoot : '/dynamic_images'

  });
  // Return the model for the module
  return DynamicImage;
});
