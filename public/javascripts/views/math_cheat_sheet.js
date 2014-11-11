//Math Cheat Sheet.
define([
  'jquery',
  'underscore',
  'backbone',
  'bootstrap/modal',
  'text!/javascripts/templates/math_cheat_sheet_modal.html'
], function($, _, Backbone, modal, mathCheatSheetTemplate) {
  var MathCheatSheetView = Backbone.View.extend({
    //div.
    tagName:  "div",

    // The DOM events specific to an item.
    events: {
      "click .symbol" : "chooseSymbol"
    },
    
    // Render the recommendation.
    render: function() {
      var compiledTemplate = _.template( mathCheatSheetTemplate);
      this.$el.html(compiledTemplate);
      this.$(this.$("table.ascii-math td:first-child")).wrapInner("<a class='symbol' data-dismiss='modal' href='#'></a>");
      return this;
    },

    chooseSymbol: function(e) {
      e.preventDefault();
      var selectedEditorId = "#" + $(".selectedMathEditor").attr("id");
      $(selectedEditorId).val($(selectedEditorId).val() + " "  + $(e.currentTarget).text());
      $(selectedEditorId).removeClass("selectedMathEditor");
      $(selectedEditorId).trigger("keyup");
      setTimeout(function() {
        $(selectedEditorId).focus();
        $(selectedEditorId).focus();
      }, 500);
    }
  });
  return MathCheatSheetView;
});
