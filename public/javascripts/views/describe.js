//Describe view.
define([
  'jquery',
  'underscore',
  'backbone',
  'text!/javascripts/templates/describe.html'
], function($, _, Backbone, describeTemplate) {
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
      $("#questionnaire").dialog("close");
    }
  });
  return DescribeView;
});
