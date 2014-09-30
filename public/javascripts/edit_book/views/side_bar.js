//Side bar navigation.
define([
  'jquery',
  'underscore',
  'backbone',
  '/javascripts/edit_book/collections/dynamic_image_collection.js',
  'text!/javascripts/edit_book/templates/side_bar.html'
], function($, _, Backbone, DynamicImageCollection, sideBarTemplate){
  var SideBarView = Backbone.View.extend({
    el: $('#left'),

    events: {
      "click #close-nav": "closeNav",
      "click #expand": "openNav"
    },

    render: function() {
      var compiledTemplate = _.template( sideBarTemplate, { images: this.collection.models } );
      $("#side_bar").append(compiledTemplate);
      $("#num_images").html("(" + this.collection.models.length + ")");
    },

    closeNav: function() {
      $("#left").removeClass("col-md-3");
      $("#right").removeClass("col-md-9");
      $("#right").addClass("col-md-12");
      $(".offcanvas").hide();
      $("#close-nav").hide();
      $("#expand").show();
      $("#left").css("background-color", "#D4D4D4");
    },

    openNav: function() {
      $("#left").addClass("col-md-3");
      $("#right").addClass("col-md-9");
      $("#right").removeClass("col-md-12");
      $(".offcanvas").show();
      $("#expand").hide();
      $("#close-nav").show();
      $("#left").css("background-color", "#FFFFFF");
    }

  });
  return SideBarView;
});
