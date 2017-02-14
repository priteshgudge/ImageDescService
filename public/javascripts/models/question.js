// Filename: models/answer
define([
  'underscore',
  'backbone'
], function(_, Backbone){
  var Question = Backbone.Model.extend({

  	findAnswerById: function(answer_id) {
    	var answers = this.get("answers");
    	return _.findWhere(answers, {"answer_id":answer_id.toString()});
    }
  });
  // Return the model for the module
  return Question;
});
