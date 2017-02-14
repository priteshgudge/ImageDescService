// Filename: models/dynamic_image
define([
  'underscore',
  'backbone'
], function(_, Backbone){
  var DynamicDescription = Backbone.Model.extend({
  	urlRoot : '/dynamic_descriptions'

  });
  // Return the model for the module
  return DynamicDescription;
});
