window.initDecisionTree = function() {

	//hide all questions other than the first one. 
	$(".question").not(":first").hide();
	$("#prev").hide();
	$("#last_question").val("1");

	//Bind next button.
	$("#next").click(function(evt) {
		//what question are we on?
		var question = $(".question:visible");
		//Find what checkbox is checked.
		var answer = question.find("input[type='radio']:checked");
		var id = question.find(".id").val();
		if (answer.length > 0) {
			//Where should we go next?
			var answer_id = answer.attr("id");
			var describe = $("#" + answer_id + "_describe").val();
			if (describe != "") {
				//Get more info.
				$("#_more_info").html($("#" + answer_id + "_more_info").val());
				question.hide();
				$("#buttons").hide();
				$("#describe").show();
				$("#"+describe).show();
			} else {
				$("#last_question").val(id);
				question.hide();
				var next = $("#" + answer_id + "_next").val();
				$("#question" + next).show();
			}
			$("#prev").show();
		} else {
			alert("Answer is required.");
		}
	});
	$("#prev").click(function(evt) {
		//what question are we on?
		var question = $(".question:visible");
		$("#question" + $("#last_question").val()).show();
		question.hide();
	});
}
jQuery(function($) {
	initDecisionTree();
});