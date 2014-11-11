// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

// Create a way to toggle between DIVs

jQuery(function($) {
	var toggleLoading = function() { $("#loading").toggle() };

	  $(".book-link-ajax")
	  	.bind("ajax:success", function(event, data, status, xhr) {
				var actionDiv = $(this).parents('.action');
				actionDiv.text("success");
				actionDiv.css('fontWeight', "bold");
		    actionDiv.css('color', "orange");
	    }) 
	  .bind("ajax:failure", function(event, data, status, xhr) {
				var actionDiv = $(this).parents('.action');
				actionDiv.text("failure");
				actionDiv.css('fontWeight', "bold");
		    actionDiv.css('color', "red");
	    });
	
  function bookToggleOnElement(element) {
    var selectorForOnElement = $(element).attr('data-related-on');
    return $(selectorForOnElement, $(element).parents());
  }
  function bookToggleOffElement(element) {
    var selectorForOffElement = $(element).attr('data-related-off');
    return $(selectorForOffElement, $(element).parents());
  }
  function htmlDecode(value){ 
    return $('<div/>').html(value).text(); 
  }
  
  function handleSubmitResponse(responseText, responseStatus) {
      var notification = document.getElementById("messageBox")
      if(responseStatus == "success")  {
          notification.innerHTML = "<%=t '.success' %>"
          notification.style.fontWeight = "bold"
          notification.style.color = "green"
      }
      else {
          notification.innerHTML = "<%=t '.update_error' %>"
          notification.style.fontWeight = "bold"
          notification.style.color = "red"
      }
  }
  
  $(".book-toggle").each(function() {
    if($(this).attr('checked')) {
      bookToggleOffElement(this).hide();
      bookToggleOnElement(this).show();
    }
    else {
      bookToggleOffElement(this).show();
      bookToggleOnElement(this).hide();
    }
   });
  
  $(".book-toggle")
    .click(function() {
      bookToggleOffElement(this).toggle();
      bookToggleOnElement(this).toggle();
    });

    $(".dropdown").on('shown.bs.dropdown', function() {
      $("li a:first", this).first().focus();
    });

  window.Poet = {
    imageCategoryPostSave: function(imageId, categoryId) {
      return function(data, status) {
        for (var i = 0; i < window.top.frames.length; i++) {

          var win = window.top.frames[i];
          var el = $(win.document).find('#dynamic_image_image_category_id_' + imageId);

          if (el.val() != categoryId) {
            el.val(categoryId);
          }
          el.find('option[value=""]').remove();

          // update help text if available
          if (win.name == "content") {
            var helpText = win.imageCategoryContent[categoryId];
            el.parents('table.outer-table-wrapper').find('div.category_description').html(helpText);
          }
        }
      }
    }
  };
});