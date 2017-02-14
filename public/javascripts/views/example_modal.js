//Example modal.
define([
  'jquery',
  'underscore',
  'backbone',
  'text!/javascripts/templates/example_modal.html'
], function($, _, Backbone, exampleModalTemplate) {
  var ExampleModalView = Backbone.View.extend({
    
    // Render the modal.
    render: function() {
      var compiledTemplate = _.template( exampleModalTemplate, {category: this.model});
      this.$el.html(compiledTemplate);
      this.$(".modal-body").load("/dynamic_images_sample_html/" + this.model.get("id"));
      return this;
    }
  });
  return ExampleModalView;
});
