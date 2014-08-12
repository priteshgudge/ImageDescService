jQuery(function($) {

	//hide all questions other than the first one. 
	$(".question").not(":first").hide();
	$("#prev").hide();

	//Bind next button.
	$("#next").click(function(evt) {
		//what question are we on?
		var question_num = $("#question_num").val();
		//This needs to be extracted from json.
		var next = parseInt(question_num) + 1; 
		$("#question" + question_num).hide();
		$("#question" + next).show();
		$("#question_num").val(next);
		$("#prev").show();
	});
});