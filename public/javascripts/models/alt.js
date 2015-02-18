// Filename: models/alt
define([
  'underscore',
  'backbone'
], function(_, Backbone){
  var Alt = Backbone.Model.extend({
    urlRoot : '/alt'

  });
  return Alt;
});
