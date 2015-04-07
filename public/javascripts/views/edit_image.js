//Edit Image.
define([
  'jquery',
  'underscore',
  'backbone',
  'bootstrap/modal',
  'bootstrap/tab',
  'bootstrap/popover',
  'scrollTo',
  '/javascripts/models/dynamic_description.js',
  '/javascripts/models/alt.js',
  '/javascripts/views/edit_image_tabs.js',
  'text!/javascripts/templates/edit_image.html'
], function($, _, Backbone, modal, tab, popover, scrollTo, DynamicDescription, Alt, EditImageTabsView, editImageTemplate){
  var EditImageView = Backbone.View.extend({
    
    //div.
    tagName:  "div",

    events: {
      "change .should_be_described": "saveNeedsDescription",
      "change .image_category": "saveImageCategory",
      "click .open-edit-view": "openEditor",
      "click .view_sample": "showSample",
      "click .altButton": "saveAlt",
      "click .arrow": "scrollToImage"
    },

    render: function() {
      var editImage = this;
      var compiledTemplate = _.template( editImageTemplate, 
        { 
          image: editImage.model, 
          image_categories: App.categories.models, 
          previousImage: editImage.previousImage,
          nextImage: editImage.nextImage,
          can_edit_content: $("#can_edit_content").val(),
          use_mmlc: $("#use_mmlc").val()
        });
      if (editImage.model.has("image_category_id") && $("#exampleModalBody" + editImage.model.get("image_category_id")).html().length > 0) {
        editImage.$(".view_sample").show();
      } else {
        editImage.$(".view_sample").hide();
      }
      this.$el.html(compiledTemplate);
      //output tabs.
      if (editImage.model.has("image_category_id")) {
        editImage.openEditor();
      }
      this.$(".help").popover();
      return this;
    },

    saveImageCategory: function(e) {
      var imageView = this;
      var imageCategory = $(e.currentTarget).val();
      //Save.
      imageView.model.save({"image_category_id": imageCategory});
      if (!$("#exampleModalBody" + imageCategory).html().length > 0) {
        imageView.$(".view_sample").hide();
      } else {
        imageView.$(".view_sample").show();
      }
      if (imageCategory == "10") {
        imageView.$(".math-tab").show();
        imageView.$(".edit-tab").hide();
      } else {
        imageView.$(".math-tab").hide();
        imageView.$(".edit-tab").show();
      }
      imageView.openEditor();
    },

    saveNeedsDescription: function(e) {
      var shouldBeDescribed = $(e.currentTarget).val();
      //First, update the image.
      this.model.save({"should_be_described": shouldBeDescribed});
      if (shouldBeDescribed == "true") {
        this.$(".image-category").show();
      }
    },

    openEditor: function() {
      var editImage = this;
      if (editImage.tabs) {
        //avoid memory leaks.
        editImage.tabs.remove();
      }
      editImage.tabs = new EditImageTabsView({model: editImage.model});
      editImage.$(".editor").html(editImage.tabs.render().el);
      editImage.$(".editor").show();
    },

    showSample: function(e) {
      e.preventDefault();
      $("#exampleModal" + this.$(".image_category").val()).modal("show");
    },

    saveAlt: function(e) {
      e.preventDefault();
      var editView = this;
      if (editView.sourceAlt) {
        editView.sourceAlt.save();
        delete editView.sourceAlt;
      }
      var alt = new Alt();
      alt.save(
        {
          "dynamic_image_id": editView.model.get("id"),
          "alt": editView.$(".alt").val(),
          "from_source": false
        }, 
        {
          success: function () {
            editView.$(".altButton").text("Saved!");
            editView.$("#alt-group").addClass("has-success");
            setTimeout(function() {
              editView.$(".altButton").text("Update");
              editView.$("#alt-group").removeClass("has-success")
            }, 500);
          },
          error: function (model, response) {
            editView.$(".text-danger").html("There was an error saving this description.");
          }
        }
      );
    },

    scrollToImage: function(e) {
      e.preventDefault();
      $("#right").scrollTo($(e.currentTarget).attr("href"));
    }

  });
  return EditImageView;
});
