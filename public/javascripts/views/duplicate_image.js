//Side bar navigation.
define([
  'jquery',
  'underscore',
  'backbone',
  'text!/javascripts/templates/duplicate_image.html'
], function($, _, Backbone, duplicateImageTemplate) {
  var DuplicateImageView = Backbone.View.extend({
    
    tagName: "div",

    render: function() {
      var compiledTemplate = _.template( duplicateImageTemplate );
      this.$el.html(compiledTemplate);
      return this;
    }
  });
  return DuplicateImageView;
});
