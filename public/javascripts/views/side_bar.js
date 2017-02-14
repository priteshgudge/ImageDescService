//Side bar navigation.
define([
  'jquery',
  'underscore',
  'backbone',
  'scrollTo',
  '/javascripts/collections/dynamic_image_collection.js',
  'text!/javascripts/templates/side_bar.html',
  '/javascripts/views/edit_book.js'
], function($, _, Backbone, scrollTo, DynamicImageCollection, sideBarTemplate, EditBookView){
  var SideBarView = Backbone.View.extend({
    el: $('#left'),

    events: {
      "click #close-nav": "closeNav",
      "click #expand": "openNav",
      "change #fragment": "loadFragment",
      "change #filter": "filterNavImages",
      "click .navLink": "scrollToImage",
      "click #goToImage": "goToImage",
      "submit #filterForm": "goToImage"
    },

    render: function() {
      var compiledTemplate = _.template( sideBarTemplate, { images: this.collection.models } );
      $("#side_bar").html(compiledTemplate);
      $("#num_images").html("(" + this.collection.models.length + ")");
    },

    goToImage: function(e) {
      e.preventDefault();
      var navLink = $("#go_to_" + $("#image_number").val());
      if (navLink.length > 0) {
        window.location.href = navLink.attr('href');
      } else {
        alert("That image is not in this section of the book");
      }
    },

    scrollToImage: function(e) {
      e.preventDefault();
      $("#right").scrollTo($(e.currentTarget).attr("href"));
    },

    closeNav: function(e) {
      e.preventDefault();
      $("#left").removeClass("col-md-2");
      $("#right").removeClass("col-md-10");
      $("#right").addClass("col-md-12");
      $("#right").css("right", "-15px");
      $(".offcanvas").hide();
      $("#close-nav").hide();
      $("#expand").show();
      $("#left").css("background-color", "#D4D4D4");
    },

    openNav: function(e) {
      e.preventDefault();
      $("#left").addClass("col-md-2");
      $("#right").addClass("col-md-10");
      $("#right").removeClass("col-md-12");
      $("#right").css("right", "0");
      $(".offcanvas").show();
      $("#expand").hide();
      $("#close-nav").show();
      $("#left").css("background-color", "#FFFFFF");
    },

    loadFragment: function(e) {
      $("#book_fragment_id").val($("#fragment").val());
      $("#part").html($("#fragment option:selected").text());
      $("#side_bar").html("");
      $("#book_content").html("<p>Please wait while book content loads...");
      App.editBook.render();
    },

    filterNavImages: function(e) {
      var sideBar = this;
      var images = new DynamicImageCollection();
      var q = images.fetch({ data: $.param({ book_id: $("#book_id").val(), book_fragment_id: $("#book_fragment_id").val(), filter: $("#filter").val()}) });
      q.done(function() {
        //Refresh.
        sideBar.collection = images;
        sideBar.render();
      });
    }

  });
  return SideBarView;
});
