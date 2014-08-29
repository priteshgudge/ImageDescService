// Load the application once the DOM is ready, using `jQuery.ready`:
$(function(){

  _.templateSettings = {
    interpolate: /\{\{\=(.+?)\}\}/g,
    evaluate: /\{\{(.+?)\}\}/g
  };	
  
  // Decision Tree Models
  // ----------
  var Answer = Backbone.Model.extend({

  });

  var Question = Backbone.Model.extend({

    findAnswerById: function(answer_id) {
    	var answers = this.get("answers");
    	return _.findWhere(answers, {"answer_id":answer_id});
    }
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
  // Create our global view for question.
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
      $("#questionnaire").dialog("close");
    }

  });
  // Create our global view for recommendation.
  var describe = new DescribeView;

  // The Decision Tree
  // ---------------
  var DecisionTreeView = Backbone.View.extend({
    
    lastImage: -1,

    el: $("#questionnaire"),

    // The DOM events specific to an item.
    events: {
      "click #prev"     : "goBack",
      "click #next"     : "getNextQuestion",
      "click .answer"	  : "setAnswer"
    },

    initialize: function() {
      $(".fancybox").fancybox({aspectRatio: true});
    	var q = questions.fetch();
    	var decisionTree = this;
    	q.done(function() {
        decisionTree.loadQuestion(questions.first().get("question_id"));
    	});
    },

    goBack: function() {
    	DecisionTreeView.loadQuestion(questions.get(question.model.cid).get("last_question_id"));
    },

    getNextQuestion: function() {
    	var answer_id = questions.get(question.model.cid).get("answer_id");
    	if (typeof(answer_id) !== 'undefined' && DecisionTreeView.verifyOther(answer_id)) {
    		//Where should we go?
    		var answer = question.model.findAnswerById(answer_id);
    		if (answer["describe"]) {
    			describe.model = new Answer(answer);
    			$("#describe").html(describe.render().el);
    			describe.delegateEvents();
    			$("#buttons").hide();
    			$("#question").html("");
    		} else {
    			$("#prev").show();
    			var next = answer["next"];
    			var currentQuestionId = question.model.get("question_id");
    			DecisionTreeView.loadQuestion(next);
    			DecisionTreeView.setLastQuestion(question.model, currentQuestionId);
    		}
    	} else {
    		alert("Answer is required.");
    	}
    },

    loadQuestion: function(question_id) {
    	var nextQuestion = questions.findWhere({"question_id":question_id});
    	question.model = nextQuestion;
		  $("#question").html(question.render().el);
      if (question_id == "1") {
        $("#prev").hide();
      }
		  question.delegateEvents();
    },

    setAnswer: function(evt) {
    	var answer = $(evt.currentTarget).attr("id");
    	questions.get(question.model.cid).set({"answer_id": answer});
    },

    setLastQuestion: function(currentQuestion, last_question_id) {
    	questions.get(currentQuestion.cid).set({"last_question_id": last_question_id});
    },

    verifyOther: function(answer_id) {
      return answer_id != $("input[name='answer']").last().val() || ($("#other").length == 0 || $("#other").val() != "");
    }

  });

  // Finally, we kick things off by creating the **App**.
  var DecisionTreeView = new DecisionTreeView;

  //Image gallery.
  //--------------
  var ImageGalleryView = Backbone.View.extend({
    el: $("#imageGallery"),

    // The DOM events specific to an item.
    events: {
      "click .toDescribe" : "startDecisionTreeForImage"
    },

    initialize: function() {
      //Preload regular size images.
      for (var i=0; i<=7; i++) {
        var newImage = new Image();
        newImage.src = "/images/decision_tree/" + i + ".jpg";
      }
    },

    startDecisionTreeForImage: function(evt) {
      evt.preventDefault();
      var mainImage = $(evt.currentTarget).attr("href");
      $("#questionnaireImage").attr('src','/javascripts/fancybox/fancybox_loading.gif');
      $("#questionnaireImage").attr("src", mainImage);
      $("#lightboxTrigger").attr("href", mainImage);
      var wWidth = $(window).width();
      var dialog = $("#questionnaire").dialog({
        autoOpen: false,
        modal: true,
        width: wWidth * 0.50,
        minHeight: "50%",
        minWidth: "50%",
        open: function() {
          DecisionTreeView.initialize();
        }
      });
      dialog.dialog("open");
    }

  });
  // Create our global view for recommendation.
  var images = new ImageGalleryView;

});
