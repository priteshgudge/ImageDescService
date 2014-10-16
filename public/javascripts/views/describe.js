//Describe view.
define([
  'jquery',
  'underscore',
  'backbone',
  'bootstrap',
  'text!/javascripts/templates/describe.html'
], function($, _, Backbone, bootstrap, describeTemplate) {
  var DescribeView = Backbone.View.extend({
    //div.
    tagName:  "div",
    
    // Render the recommendation.
    render: function() {
      var compiledTemplate = _.template( describeTemplate, {answer: this.model});
      this.$el.html(compiledTemplate);
      return this;
    }
    
  });
  return DescribeView;
});
