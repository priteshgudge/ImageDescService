//Edit Image.
define([
  'jquery',
  'underscore',
  'backbone',
  'ckeditor',
  'bootstrap',
  '/javascripts/models/dynamic_image.js',
  '/javascripts/models/dynamic_description.js',
  'text!/javascripts/templates/edit_image.html',
  'text!/javascripts/templates/history_modal.html'
], function($, _, Backbone, ckeditor, bootstrap, DynamicImage, DynamicDescription, editImageTemplate, historyModalTemplate){
  var EditImageView = Backbone.View.extend({
    
    //div.
    tagName:  "div",

    events: {
      "change .should_be_described": "saveNeedsDescription",
      "change .image_category": "saveImageCategory",
      "click .cancel": "cancelEditor",
      "click .save": "saveDescription",
      "click .edit": "showDynamicDescriptionForm",
      "click .preview": "showPreview",
      "click .view_sample": "showSample",
      "click .history_link": "showDescriptionHistory"
    },

    ckeditorConfig: {
        extraPlugins: 'onchange',
        minimumChangeMilliseconds: 100,
        scayt_autoStartup:true,
        toolbar :
        [
            { name: 'basicstyles', items : [ 'Bold','Italic','Underline' ] },
            { name: 'paragraph', items : [ 'NumberedList','BulletedList' ] },
            { name: 'editing', items : ['Scayt' ] },
            { name: 'styles', items : [ 'Format' ] },
            { name: 'insert', items : [ 'Table','Link','Unlink' ] },
            { name: 'tools', items : [ 'Undo', 'Redo', '-', 'Source','Maximize' ] }
        ]
    },

    render: function() {
      var compiledTemplate = _.template( editImageTemplate, 
        { 
          image: this.model, 
          image_categories: this.imageCategories.models, 
          previousImage: this.previousImage,
          nextImage: this.nextImage
        });
      if (this.model.has("image_category_id") && $("#example-" + this.model.get("image_category_id")).html().length > 0) {
        this.$(".view_sample").show();
      } else {
        this.$(".view_sample").hide();
      }
      this.$el.html(compiledTemplate);
      return this;
    },

    saveImageCategory: function(e) {
      var imageCategory = $(e.currentTarget).val();
      //Save.
      this.model.save({"image_category_id": imageCategory});
      if (!$("#example-" + imageCategory).html().length > 0) {
        this.$(".view_sample").hide();
      } else {
        this.$(".view_sample").show();
      }
    },

    saveNeedsDescription: function(e) {
      var shouldBeDescribed = $(e.currentTarget).val();
      //First, update the image.
      this.model.save({"should_be_described": shouldBeDescribed});
      if (shouldBeDescribed == "true") {
        this.showDynamicDescriptionForm();
      }
    },

    showDynamicDescriptionForm: function() {
      var editView = this;
      editView.$(".update-message").html("");
      var longDescription = editView.$(".long-description");
      var textarea = $("textarea", $(longDescription));
      textarea.ckeditor(editView.ckeditorConfig);

      editView.model.fetch({
        success: function() {
          var latestDescription = editView.model.has("dynamic_description") ? editView.model.get("dynamic_description")["body"] : "";
          textarea.val(latestDescription);
          var name = textarea.attr("name");
          CKEDITOR.instances[name].setData(latestDescription);
          //make sure that the description is up to date.
          longDescription.show();
          //Show edit tab.
          $("#edit-tab-" + editView.model["id"]).tab('show');
        }    
      });
    },

    cancelEditor: function(e) {
      e.preventDefault();
      this.$(".long-description").hide();
    },

    showPreview: function(e) {
      var editView = this;
      editView.model.fetch({
        success: function() {
          editView.$(".image_description").html(editView.model.has("dynamic_description") ? 
            editView.model.get("dynamic_description")["body"] : "");
        }
      });
      
    },

    saveDescription: function(e) {
      var editView = this;
      e.preventDefault();
      //Create a new description.
      var dynamicDescription = new DynamicDescription();
      //Get value from ckeditor.
      editView.$("textarea").ckeditor(function(textarea){
        var dynamicDescription = new DynamicDescription();
        dynamicDescription.save(
          {
            "book_id": $("#book_id").val(), 
            "dynamic_description": $(textarea).val(), 
            "dynamic_image_id": editView.model.get("id")
          }, 
          {
            success: function () {
              editView.$(".image_description").html($(textarea).val());
              editView.$(".text-success").html("The description has been saved.");
            },
            error: function (model, response) {
              editView.$(".text-danger").html("There was an error saving this description.");
            }
          }
        );
      });
    },

    showSample: function(e) {
      var editImage = this;
      $(e.currentTarget).popover({
        html : true, 
        content: function() {
          var content = $('#example-' + editImage.$(".image_category").val()).clone();
          content.css("display", "block");
          return content;
        },
        title: function() {
          return "Guidelines";
        }
      });
      $(e.currentTarget).popover('show');
    },

    showDescriptionHistory: function(e) {
      e.preventDefault();
      var historyLink = $(e.currentTarget);
      var content = $.get(historyLink.attr("href"), function(d) {
        historyLink.popover({
          html : true, 
          content: function() {
            console.log($("#descriptionHistory", d));
            var content = $("#descriptionHistory", d);
            content.css("display", "block");
            return content;
          },
          title: function() {
            return "Description History";
          }
        });
        historyLink.popover('show');
      });
    }


  });
  return EditImageView;
});
