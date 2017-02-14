// Filename: models/mml_equation
define([
  'underscore',
  'backbone'
], function(_, Backbone){
  var MmlcEquation = Backbone.Model.extend({
    urlRoot : '/mmlc/equation'

  });
  return MmlcEquation;
});
