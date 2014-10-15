//Decision Tree.
define([
  'jquery',
  'underscore',
  'backbone',
  'fancybox',
  '/javascripts/models/answer.js',
  '/javascripts/collections/question_collection.js',
  '/javascripts/views/question.js',
  '/javascripts/views/summary.js',
  '/javascripts/views/describe.js',
  '/javascripts/views/image.js'
], function($, _, Backbone, fancybox, Answer, QuestionCollection, QuestionView, SummaryView, DescribeView, ImageView) {
  var DecisionTreeView = Backbone.View.extend({
    lastImage: -1,

    selectedImage: -1,

    el: $("#questionnaire"),

    // The DOM events specific to an item.
    events: {
      "click #prev"     : "goBack",
      "click #next"     : "getNextQuestion"
    },

    initialize: function() {
      this.collection = new QuestionCollection();
      this.question = new QuestionView();
    },

    render: function() {
      this.loadImage();
      this.loadQuestion(this.collection.first().get("question_id"));
    },

    goBack: function() {
      this.loadQuestion(this.collection.get(this.question.model.cid).get("last_question_id"));
    },

    getNextQuestion: function() {
      this.setAnswer();
      var currentQuestion = this.collection.findWhere({"question_id":this.question.model.get("question_id")});
      if ((currentQuestion.has("answer") && this.verifyOther(currentQuestion.get("answer")["answer_id"])) || currentQuestion.has("freeform_answer")) {
        var answer = new Answer(currentQuestion.get("answer"));
        //Where should we go?
        if (answer.has("describe") || currentQuestion.has("freeform_answer")) {
          if (currentQuestion.has("freeform_answer")) {
            answer.set({comments: currentQuestion.get("comments")});
          }
          this.outputDecision(answer);
        } else {
          $("#prev").show();
          var next = answer.get("next");
          var currentQuestionId = this.question.model.get("question_id");
          this.loadQuestion(next);
          this.setLastQuestion(this.question.model, currentQuestionId);
          var inputField = $("#answers").find("input[type=radio]").eq(0).select();
          inputField.focus();
        }
      } else {
        alert("Answer is required.");
      }
    },

    loadImage: function() {
      var decisionTree = this;
      var imageView = new ImageView();
      imageView.model = decisionTree.selectedImage;
      $("#zoomerImage").html(imageView.render().el);
    },

    loadQuestion: function(question_id) {
      var nextQuestion = this.collection.findWhere({"question_id":question_id});
      var decisionTree = this;
      decisionTree.question.model = nextQuestion;
      $("#question").html(decisionTree.question.render().el);
      if (question_id == "1") {
        $("#prev").hide();
      }
      decisionTree.$('input[type!=hidden]:first').focus();
      decisionTree.question.delegateEvents();
    },

    setLastQuestion: function(currentQuestion, last_question_id) {
      this.collection.get(currentQuestion.cid).set({"last_question_id": last_question_id});
    },

    verifyOther: function(answer_id) {
      return answer_id != $("input[name='answer']").last().val() || ($("#other").length == 0 || $("#other").val() != "");
    },

    outputDecision: function(answer) {
      //Display summary.
      var summary = new SummaryView();
      summary.collection = this.collection;
      $("#summary").html(summary.render().el);  

      //Display recommendation
      var describe = new DescribeView();
      describe.model = answer;
      $("#describe").html(describe.render().el);
      describe.delegateEvents();
      
      $("#comments").html("<h3>Comments From the Experts:</h3>" + this.selectedImage.get("comments"));
      $("#buttons").hide();
      $("#question").html("");
    },

    setAnswer: function(evt) {
      var decisionTree = this;
      var answer = $("input[name='answer']:checked");
      if (answer.length > 0) {
        var answerId = $(answer).attr("id");
        var other = $("#other").length > 0 && $("#other").val() != "" ? $("#other").val() : "";
        decisionTree.collection.findWhere({"question_id":decisionTree.question.model.get("question_id")}).set({
          "answer": decisionTree.question.model.findAnswerById(answerId),
          "other": other
        });
      } else if ($("#freeform").length > 0 && $("#freeform").val() !="") {
        decisionTree.collection.findWhere({"question_id":decisionTree.question.model.get("question_id")}).set({
          "freeform_answer": $("#freeform").val()
        });
      }
    }
  });
  return DecisionTreeView;
});
