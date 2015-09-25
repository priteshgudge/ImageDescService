//Edit Image.
define([
  'jquery',
  'underscore',
  'backbone',
  'MathJax',
  'ckeditor',
  'bootstrap/modal',
  'bootstrap/tab',
  'bootstrap/popover',
  'mespeak',
  'scrollTo',
  '/javascripts/models/dynamic_description.js',
  '/javascripts/models/alt.js',
  '/javascripts/models/equation.js',
  '/javascripts/models/mmlc_equation.js',
  '/javascripts/collections/mmlc_component_collection.js',
  'text!/javascripts/templates/edit_image_tabs.html'
], function($, _, Backbone, MathJax, ckeditor, modal, tab, popover, mespeak, scrollTo, DynamicDescription, Alt, Equation, MmlcEquation, MmlcComponents, tabsTemplate){
  var EditImageTabsView = Backbone.View.extend({
    
    //div.
    tagName:  "div",

    events: {
      "click .cancel": "cancelEditor",
      "click .save-text": "saveTextDescription",
      "click .save-math": "saveMath",
      "click .generate-math": "getMMLCEquation",  
      "click .edit": "showDynamicDescriptionForm",
      "click .preview": "showPreview",
      "click .additional-fields": "showAdditionalFields",
      "click .history_link": "showDescriptionHistory",
      "click .save-additional-fields": "saveAdditionalFields",
      "click .read-description": "readDescription",
      "click .tab-link": "clearMessages",
      "click .math-toggle": "setSelectedMathEditor",
      "click .jswaves-toggle": "showJSWaves",
      "click .image_description": "showEditor",
      "keyup .math-editor": "enableGenerateButton",
      "change .math-type": "clearMathEditor",
      "keyup .math-text-description": "enableSaveMathButton",
      "click .open-editor": "showEditor"
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
      var compiledTemplate = _.template( tabsTemplate, 
        { 
          image: editImage.model, 
          can_edit_content: $("#can_edit_content").val(),
          use_mmlc: $("#use_mmlc").val()
        });
      this.$el.html(compiledTemplate);
      this.$(".help").popover();
      this.initCKEditor();
      return this;
    },

    showDynamicDescriptionForm: function(e) {
      var buttonClicked = $(e.currentTarget);
      var editView = this;
      editView.clearMessages();
      editView.initCKEditor();
      var textarea = editView.$(".dynamic-description");

      editView.model.fetch({
        success: function() {
          var currentDescription = editView.model.has("dynamic_description") ? editView.model.get("dynamic_description")["body"] : "";
          textarea.val(currentDescription);
          var name = textarea.attr("name");
          CKEDITOR.instances[name].on('focus', function(e) { 
            e.editor.document.getBody().setHtml(currentDescription); 
          });  
          //Show edit tab.
          $("#edit-tab-" + editView.model["id"]).tab('show');  
            
          //Make sure that fields that can't be used yet are disabled.
          if (currentDescription == "") {
            editView.$("#additional-fields-" + editView.model.get("id") + " :input").prop("disabled", true);
          }
        }    
      });
    },

    initCKEditor: function() {
      var editView = this;
      var textarea = editView.$(".dynamic-description");
      textarea.ckeditor(editView.ckeditorConfig);
    },

    cancelEditor: function(e) {
      e.preventDefault();
      this.$(".preview").trigger("click");
    },

    showPreview: function(e) {
      var editView = this;
      editView.$(".preview-tab").show();
      editView.model.fetch({
        success: function (image, response, options) {
          if (image.has("dynamic_description")) {
            editView.$(".image_description").html(image.has("dynamic_description") ? image.get("dynamic_description")["body"] : "");
            editView.$(".author").html(image.get("author"));  
            editView.$(".image_description").show();
          }
          if (image.get("image_category_id") == $("#math_category").val() && image.has("current_equation")) {
            editView.$(".current-equation").html(image.get("current_equation").element);
            MathJax.Hub.Queue(["Typeset",MathJax.Hub, "image-description-" + editView.model.get("id")]);
            editView.$(".current-equation").show();
            if ($("#math_replacement_mode").val() != "") {
              editView.$(".current-description").html(image.get("current_equation").description);
              editView.$(".current-description").show();
            } else {
              editView.$(".current-description").hide();
            }
          }
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
            editView.$(".preview").trigger("click");
            $("#right").scrollTo($("#edit-image-" + editView.model.get("id")));
          },
          error: function (model, response) {
            editView.$(".text-danger").html("There was an error saving this description.");
          }
        }
      );
      if ($("#show_additional_fields").val() == "true") {
        editView.$(".summary").prop("disabled", false);
        editView.$(".simplified-language-description").prop("disabled", false);
        var summaryEditorName = editView.$(".summary").attr("name");
        var simplifiedLanguageDescriptionName = editView.$(".simplified-language-description").attr("name");
        editView.$("#additional-fields-" + editView.model.get("id") + " :input").prop("disabled", false);
        if (CKEDITOR.instances[summaryEditorName]) {
          CKEDITOR.instances[summaryEditorName].setReadOnly(false);
          CKEDITOR.instances[simplifiedLanguageDescriptionName].setReadOnly(false);
        }
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
      if (editView.mmlcEquation) {
        editView.saveEquation();  
      }
      if ($("#math_replacement_mode").val() == "") {
        editView.saveDescription(editView.$(".math-text-description").val());
      } else {
        editView.$(".preview").trigger("click");
        //disable alt.
        $("#edit-image-" + editView.model.get("id") + " .alt").prop("disabled", "disabled").val("replaced with auto-generated description");
        $("#edit-image-" + editView.model.get("id") + " .altButton").hide();
      }
    },

    getMMLCEquation: function(e) {
      var editView = this;
      e.preventDefault();
      if(editView.warnUser) {
        if (!confirm("You have manually modified the text description. If you generate the description again, your modifications will be lost.\n\n Are you sure you want to generate a new description?")) {
          return false;
        }
      }
      //get mathml.
      var equation = new MmlcEquation();
      equation.save({math: editView.$(".math-editor").val(), math_type: editView.$(".math-type:checked").val()},
        {
          success: function(model, response, options) {
            var components = new MmlcComponents(model.get("components"));
            var description = components.findWhere({format: "description"});
            var mml = components.findWhere({format: "mml"});
            editView.$(".math-text-description").val(description.get("source"));
            editView.$(".typeset-math").html(mml.get("source"));
            editView.$(".description-preview").show();
            MathJax.Hub.Queue(["Typeset",MathJax.Hub,"typeset-math-" + editView.model.get("id")]);
            editView.mmlcEquation = model;
            editView.$(".equation-preview").show();
            editView.$(".save-math").prop("disabled", false);
          }
        }
      );
    },

    showDescriptionHistory: function(e) {
      e.preventDefault();
      var historyLink = $(e.currentTarget);
      $("#descriptionHistoryBody").load(historyLink.attr("href") + " #descriptionHistory", function() {
        $("#descriptionHistoryModal").modal("show");
      });
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

    saveEquation: function() {
      $("#waves-toolbar").hide();
      var editView = this;
      var components = new MmlcComponents(editView.mmlcEquation.get("components"));
      var mathML = components.findWhere({format: "mml"}).get("source");
      var description = components.findWhere({format: "description"}).get("source");
      var described_at = editView.mmlcEquation.get("cloudUrl");
      var math_type = editView.mmlcEquation.get("mathType");
      var equation = new Equation();
      equation.save(
        {
          "dynamic_image_id": editView.model.get("id"),
          "element": mathML,
          "source": editView.$(".math-editor").val(),
          "described_at": described_at,
          "description": description,
          "math_type": math_type
        },
        {
          success: function () {
            if ($("#math_replacement_mode").val() != "") {
              editView.$(".text-success").html("Your equation has been created.");
              editView.$(".preview").trigger("click");  
              $("#right").scrollTo($("#edit-image-" + editView.model.get("id")));
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
      var speak = "";
      if (this.model.get("image_category_id") === $("#math_category").val() && this.model.has("current_equation")) {
        speak = this.model.get("current_equation").description;
      } else {
        speak = this.$(".image_description").text();
      }
      meSpeak.speak(speak);
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
    },

    enableGenerateButton: function(e) {
      this.$(".generate-math").prop("disabled", false);
    },

    clearMathEditor: function() {
      this.$(".math-editor").val("");
      this.$(".equation-preview").hide();
    },

    enableSaveMathButton: function() {
      this.$(".save-math").prop("disabled", false);
      this.warnUser = true;
    },

    showEditor: function(e) {
      e.preventDefault();
      var editImage = this;
      if (editImage.model.get("image_category_id") == $("#math_category").val()) {
        //Show math tab.
        console.log(editImage.$("#math-tab-" + editImage.model.get("id")));
        editImage.$("#math-tab-" + editImage.model.get("id")).tab('show');  
      } else {
        editImage.$(".edit").trigger("click");
      }
    }

  });
  return EditImageTabsView;
});
