//Question view.
define([
  'jquery',
  'underscore',
  'backbone',
  'text!/javascripts/templates/question.html'
], function($, _, Backbone, questionTemplate) {
  var QuestionView = Backbone.View.extend({
    //div.
    tagName:  "div",

    // Render the question
    render: function() {
      var compiledTemplate = _.template( questionTemplate, {question: this.model});
      this.$el.html(compiledTemplate);
      return this;
    }
  });
  return QuestionView;
});
