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

    // The DOM events specific to an item.
    events: {
      "click #play_again_button" : "closeDecisionTree"
    },
    
    // Render the recommendation.
    render: function() {
      var compiledTemplate = _.template( describeTemplate, {answer: this.model});
      this.$el.html(compiledTemplate);
      return this;
    },

    closeDecisionTree: function() {
      $("#questionnaire").modal("hide");
    }
  });
  return DescribeView;
});
