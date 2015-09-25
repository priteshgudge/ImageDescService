// Components
// ---------------
define([
  'underscore',
  'backbone',
  '/javascripts/models/mmlc_component.js'
], function(_, Backbone, MmlcComponent){
  var MmlcComponentCollection = Backbone.Collection.extend({
    // Reference to this collection's model.
    model: MmlcComponent

  });
  return MmlcComponentCollection;
});
