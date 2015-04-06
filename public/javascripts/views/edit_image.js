//Edit Image.
define([
  'jquery',
  'underscore',
  'backbone',
  'MathJax',
  'ckeditor',
  'bootstrap/modal',
  'bootstrap/tab',
  'mespeak',
  'scrollTo',
  '/javascripts/models/dynamic_image.js',
  '/javascripts/models/dynamic_description.js',
  '/javascripts/models/alt.js',
  '/javascripts/models/equation.js',
  '/javascripts/models/mmlc_equation.js',
  '/javascripts/collections/mmlc_component_collection.js',
  'text!/javascripts/templates/edit_image.html'
], function($, _, Backbone, MathJax, ckeditor, modal, tab, mespeak, scrollTo, DynamicImage, DynamicDescription, Alt, Equation, MmlcEquation, MmlcComponents, editImageTemplate){
  var EditImageView = Backbone.View.extend({
    
    //div.
    tagName:  "div",

    events: {
      "change .should_be_described": "saveNeedsDescription",
      "change .image_category": "saveImageCategory",
      "click .open-edit-view": "openEditor",
      "click .cancel": "cancelEditor",
      "click .save-text": "saveTextDescription",
      "click .save-math": "saveMath",
      "click .generate-math": "getMMLCEquation",  
      "click .edit": "showDynamicDescriptionForm",
      "click .preview": "showPreview",
      "click .additional-fields": "showAdditionalFields",
      "click .view_sample": "showSample",
      "click .history_link": "showDescriptionHistory",
      "click .math-tab a": "toggleDescriptionMathML",
      "click .save-as-replacement": "getEquation",
      "click .save-additional-fields": "saveAdditionalFields",
      "click .read-description": "readDescription",
      "click .add-description-button": "hideAddButton",
      "click .tab-link": "clearMessages",
      "click .math-toggle": "setSelectedMathEditor",
      "click .jswaves-toggle": "showJSWaves",
      "click .image_description": "showDynamicDescriptionForm",
      "click .altButton": "saveAlt",
      "click .arrow": "scrollToImage"
    },

    jax: {},

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
      return this;
    },

    saveImageCategory: function(e) {
      var imageView = this;
      var imageCategory = $(e.currentTarget).val();
      //Save.
      imageView.model.save({"image_category_id": imageCategory});
      this.showDynamicDescriptionForm(e);
      if (!$("#exampleModalBody" + imageCategory).html().length > 0) {
        imageView.$(".view_sample").hide();
      } else {
        imageView.$(".view_sample").show();
      }
      if (imageCategory == "10") {
        imageView.$(".math-tab").show();
      } else {
        imageView.$(".math-tab").hide();
      }
      imageView.$(".add-description-button").hide();
    },

    saveNeedsDescription: function(e) {
      var shouldBeDescribed = $(e.currentTarget).val();
      //First, update the image.
      this.model.save({"should_be_described": shouldBeDescribed});
      if (shouldBeDescribed == "true") {
        this.$(".image-category").show();
      }
    },

    openEditor: function(e) {
      e.preventDefault(e);
      this.showDynamicDescriptionForm(e);
    },

    hideAddButton: function(e) {
      $(e.currentTarget).hide();
    },

    showDynamicDescriptionForm: function(e) {
      var buttonClicked = $(e.currentTarget);
      var editView = this;
      editView.clearMessages();
      
      var longDescription = editView.$(".long-description");
      var textarea = $(".dynamic-description", $(longDescription));
      textarea.ckeditor(editView.ckeditorConfig);

      editView.model.fetch({
        success: function() {
          var currentDescription = editView.model.has("dynamic_description") ? editView.model.get("dynamic_description")["body"] : "";
          //If current description has mathml, don't output it here and display a message
          //to use the mathML editor for mathML.
          var hasMathML = editView.hasMathML(currentDescription);
          var latestDescription = hasMathML ? "" : currentDescription;
          textarea.val(latestDescription);
          var name = textarea.attr("name");
          CKEDITOR.instances[name].on('focus', function(e) { 
            e.editor.document.getBody().setHtml(latestDescription); 
          });  
          if (hasMathML) {
            editView.$(".text-danger").html("Please use the Math Editor tab to edit MathML.");
          }
          
          //make sure that the description is up to date.
          longDescription.show();
          if ($(buttonClicked).hasClass("edit-mathml")) {
            //Show edit tab.
            $(".math-tab a").tab('show');  
          } else {
            //Show edit tab.
            $("#edit-tab-" + editView.model["id"]).tab('show');  
            //hide math tab for non-math equations.
            if (editView.$(".image_category").val() != "10") {
              editView.$(".math-tab").hide();
            }
          }
          //Make sure that fields that can't be used yet are disabled.
          if (currentDescription == "") {
            editView.$("#additional-fields-" + editView.model.get("id") + " :input").prop("disabled", true);
          }
        }    
      });
    },

    hasMathML: function(description) {
      return description.indexOf('xmlns="http://www.w3.org/1998/Math/MathML"') != -1;
    },

    cancelEditor: function(e) {
      e.preventDefault();
      this.$(".preview").trigger("click");
    },

    showPreview: function(e) {
      var editView = this;
      editView.model.fetch({
        success: function (image, response, options) {
          editView.$(".image_description").html(image.has("dynamic_description") ? image.get("dynamic_description")["body"] : "");
          editView.$(".author").html(image.get("author"));
        }
      });
      
    },

    saveDescription: function(description) {
      var editView = this;
      var hasDescription = editView.model.has("dynamic_description");
      var dynamicDescription = new DynamicDescription();
      dynamicDescription.save(
        {
          "book_id": $("#book_id").val(), 
          "dynamic_description": description, 
          "dynamic_image_id": editView.model.get("id")
        }, 
        {
          success: function () {
            editView.$(".image_description").html(description);
            editView.$(".text-success").html("Your image description has been " + (hasDescription ? "updated" : "created") + ".");
            editView.$(".preview-tab").show();
            editView.$(".preview").trigger("click");
            $("#right").scrollTo(editView.$("#edit-image-" + editView.model.get("id")));
          },
          error: function (model, response) {
            editView.$(".text-danger").html("There was an error saving this description.");
          }
        }
      );
      if ($("#show_additional_fields").val() == "true") {
        var summaryEditorName = editView.$(".summary").attr("name");
        var simplifiedLanguageDescriptionName = editView.$(".simplified-language-description").attr("name");
        editView.$("#additional-fields-" + editView.model.get("id") + " :input").prop("disabled", false);
        CKEDITOR.instances[summaryEditorName].setReadOnly(false);
        CKEDITOR.instances[simplifiedLanguageDescriptionName].setReadOnly(false);
      }
    },

    saveTextDescription: function(e) {
      var editView = this;
      e.preventDefault();
      //Create a new description.
      var dynamicDescription = new DynamicDescription();
      //Get value from ckeditor.
      editView.$("textarea.dynamic-description").ckeditor(function(textarea){
        editView.saveDescription($(textarea).val());
      });
    },

    saveMath: function(e) {
      var editView = this;
      e.preventDefault();
      editView.saveEquation();
      if ($("#math_replacement_mode").val() == "") {
        editView.saveDescription(editView.$(".math-text-description").val());
      }
    },

    getMMLCEquation: function(e) {
      var editView = this;
      e.preventDefault();
      //get mathml.
      var equation = new MmlcEquation();
      equation.save({math: editView.$(".math-editor").val()},
        {
          success: function(model, response, options) {
            var components = new MmlcComponents(model.get("components"));
            var description = components.findWhere({format: "description"});
            editView.$(".math-text-description").html(description.get("source"));
            editView.$(".description-preview").show();
            editView.mmlcEquation = model;
          }
        }
      );
    },

    showSample: function(e) {
      e.preventDefault();
      $("#exampleModal" + this.$(".image_category").val()).modal("show");
    },

    showDescriptionHistory: function(e) {
      e.preventDefault();
      var historyLink = $(e.currentTarget);
      $("#descriptionHistoryBody").load(historyLink.attr("href") + " #descriptionHistory", function() {
        $("#descriptionHistoryModal").modal("show");
      });
    },

    toggleDescriptionMathML: function(e) {
      var editImage = this;
      editImage.$(".text-success").html("");
    },

    showAdditionalFields: function(e) {
      //add wysisyg editors to summary and simplified language description.
      var editView = this;
      editView.$(".summary").ckeditor(editView.ckeditorConfig);
      editView.$(".simplified-language-description").ckeditor(editView.ckeditorConfig);
    },

    saveAdditionalFields: function(e) {
      e.preventDefault();
      var editView = this;
      var dynamicDescription = new DynamicDescription();
      //Get summary and simplified language description values from ckeditor.
      var summary, simplifiedLanguageDescription;
      editView.$("textarea.summary").ckeditor(function(textarea){
        summary = $(textarea).val();
      });
      editView.$("textarea.simplified-language-description").ckeditor(function(textarea){
        simplifiedLanguageDescription = $(textarea).val();
      });
      dynamicDescription.save(
        {
          "book_id": $("#book_id").val(), 
          "dynamic_image_id": editView.model.get("id"),
          "summary": summary,
          "annotation": editView.$(".annotation").val(),
          "simplified_language_description": simplifiedLanguageDescription,
          "target_age_start": editView.$(".from-age").val(),
          "target_age_end": editView.$(".to-age").val(),
          "target_grade_start": editView.$(".from-grade").val(),
          "target_grade_end": editView.$(".to-grade").val(),
          "tactile_src": editView.$(".tactile-source").val(),
          "tactile_tour": editView.$(".tactile-tour").val(),
          "dynamic_description": editView.model.get("dynamic_description")["body"]
        }, 
        {
          success: function () {
            editView.$(".text-success").html("The description has been saved.");
            editView.$(".preview").trigger("click");
            $("#right").scrollTo(editView.$("#edit-image-" + editView.model.get("id")));
          },
          error: function (model, response) {
            editView.$(".text-danger").html("There was an error saving this description.");
          }
        }
      );
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

    getEquation: function(e) {
      e.preventDefault();
      var editView = this;
      var mmlcEquation = new MmlcEquation();
      mmlcEquation.save({math: editView.$(".math-editor").val()},
        {
          success: function(model, response, options) {
            var components = new MmlcComponents(model.get("components"));
            var mathML = components.findWhere({format: "mml"});
            editView.saveEquation(mathML.get("source"), model.get("cloud_url"));
          }
        }
      );
    },

    saveEquation: function() {
      var editView = this;
      var components = new MmlcComponents(editView.mmlcEquation.get("components"));
      var mathML = components.findWhere({format: "mml"}).get("source");
      var description = components.findWhere({format: "description"}).get("source");
      var described_at = editView.mmlcEquation.get("cloudUrl");
      var equation = new Equation();
      equation.save(
        {
          "dynamic_image_id": editView.model.get("id"),
          "element": mathML,
          "source": editView.$(".math-editor").val(),
          "described_at": described_at,
          "description": description
        },
        {
          success: function () {
            if ($("#math_replacement_mode").val() != "") {
              editView.$(".equation-updated").html("Your equation has been created and will replace the image when you update your book.");
              editView.$(".alt").prop("disabled", "disabled").val("replaced with auto-generated description");
              editView.$(".altButton").prop("disabled", "disabled");
            }
          },
          error: function (model, response) {
            editView.$(".text-danger").html("There was an error saving this description.");
          }
        }
      );
    },

    clearMessages: function() {
      this.$(".update-message").html("");
    },

    readDescription: function(e) {
      e.preventDefault();
      meSpeak.speak(this.$(".image_description").text());
    },

    setSelectedMathEditor: function(e) {
      e.preventDefault();
      this.$(".math-editor").addClass("selectedMathEditor");
    },

    showJSWaves: function(e) {
      e.preventDefault();
      $("#waves-toolbar").show();
      var editImage = this;
      $("#waves-done").on("click", function(e) {
        setTimeout( function () {
          editImage.$(".math-editor").val($(".waves-input").html());
          editImage.$(".math-editor").trigger("keyup");
        }, 200);
      });
    },

    scrollToImage: function(e) {
      e.preventDefault();
      $("#right").scrollTo($(e.currentTarget).attr("href"));
    }

  });
  return EditImageView;
});
