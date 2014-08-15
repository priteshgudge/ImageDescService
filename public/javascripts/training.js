// Load the application once the DOM is ready, using `jQuery.ready`:
$(function(){

  _.templateSettings = {
    interpolate: /\{\{\=(.+?)\}\}/g,
    evaluate: /\{\{(.+?)\}\}/g
  };	

  // Decision Tree Model
  // ----------
  var Question = Backbone.Model.extend({
    findAnswerById: function(answer_id) {
    	var answers = this.get("answers");
    	return _.findWhere(answers, {"answer_id":answer_id});
    }
  });

  var Answer = Backbone.Model.extend({

  });

  // Decision Tree Questions Collection
  // ---------------
  var QuestionList = Backbone.Collection.extend({

    // Reference to this collection's model.
    model: Question,

    // load the questions.
    url: '/training/questionnaire'

  });
  // Create our global collection of questions.
  var questions = new QuestionList;


  // Decision Tree View
  // --------------

  // The DOM element for a question item...
  var QuestionView = Backbone.View.extend({

    //div.
    tagName:  "div",

    // Cache the template function for a single item.
    template: _.template($('#question-template').html()),

    // Render the question
    render: function() {
      this.$el.html(this.template(this.model.toJSON()));
      return this;
    }

  });
  // Create our global view for decision.
  var question = new QuestionView;

  // The DOM element for the decision.
  var DescribeView = Backbone.View.extend({

    //div.
    tagName:  "div",

    // The DOM events specific to an item.
    events: {
      "click #play_again_button" : "resetDecisionTree"
    },

    // Cache the template function for a single item.
    template: _.template($('#describe-template').html()),
    
    // Render the recommendation.
    render: function() {
      this.$el.html(this.template(this.model.toJSON()));
      return this;
    },

    resetDecisionTree: function() {
    	$("#describe").html("");
    	$("#question").show();
    	$("#buttons").show();
    	DecisionTreeView.initialize();
    }

  });
  // Create our global view for recommendation.
  var describe = new DescribeView;

  // The Decision Tree
  // ---------------
  var DecisionTreeView = Backbone.View.extend({
    
    //Defaults.
  	lastQuestion: "1",

  	lastImage: -1,

    el: $("#questionnaire"),

    // The DOM events specific to an item.
    events: {
      "click #prev"     : "goBack",
      "click #next"     : "getNextQuestion"
    },

    initialize: function() {
    	var q = questions.fetch();
    	this.lastImage = this.lastImage != 8 ? this.lastImage + 1 : 0;
    	$("#questionnaireImage").attr("src", "/images/decision_tree/" + this.lastImage + ".jpg");
    	q.done(function() {
    	  question.model = questions.first();
		  $("#question").html(question.render().el);
    	});
    },

    goBack: function() {
    	if (parseInt(this.lastQuestion) == 1) {
    		$("#prev").hide();
    	}
    	DecisionTreeView.loadQuestion(this.lastQuestion);
    	DecisionTreeView.lastQuestion = question.model.get("question_id");
    },

    getNextQuestion: function() {
    	DecisionTreeView.lastQuestion = question.model.get("question_id");
    	var selectedAnswer = $("input[type='radio']:checked");
    	if (selectedAnswer.length > 0) {
    		//Where should we go?
    		var answer = question.model.findAnswerById(selectedAnswer.val());
    		if (answer["describe"]) {
    			describe.model = new Answer(answer);
    			$("#describe").html(describe.render().el);
    			describe.delegateEvents();
    			$("#buttons").hide();
    			$("#question").html("");
    		} else {
    			var next = answer["next"];
    			DecisionTreeView.loadQuestion(next);
    		}
    	} else {
    		alert("Answer is required.");
    	}
    },

    loadQuestion: function(question_id) {
    	var nextQuestion = questions.findWhere({"question_id":question_id});
		question.model = nextQuestion;
		$("#question").html(question.render().el);
    }

  });

  // Finally, we kick things off by creating the **App**.
  var DecisionTreeView = new DecisionTreeView;

});
