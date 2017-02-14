// Questions
// ---------------
define([
  'underscore',
  'backbone',
  '/javascripts/models/question.js'
], function(_, Backbone, Question){
  var QuestionCollection = Backbone.Collection.extend({
    // Reference to this collection's model.
    model: Question,

    // load the questions.
    url: '/training/questionnaire'

  });
  return QuestionCollection;
});
