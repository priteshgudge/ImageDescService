// Filename: training.js
require.config({
  baseUrl: "/javascripts/",
  shim: {
    jquery: {
      exports: '$' 
    },
    jquery_ui: {
      deps: ["jquery"],
      exports: "jquery-ui"
    },
    underscore: {
      exports: '_'
    },
    ckeditor_core: {
      deps: ["jquery"],
      exports: "ckeditor_core"
    },
    ckeditor: {
      deps: ["jquery", "ckeditor_core"],
      exports: "ckeditor"
    },
    'bootstrap/modal': { 
      deps: ['jquery'], 
      exports: '$.fn.modal' 
    },
    fancybox: {
      deps: ["jquery"],
      exports: "fancybox"
    }
  },
  paths: {
    'jquery': 'jquery.min',
    'jquery-ui': 'jquery-ui.min',
    'underscore': 'libs/underscore-min',
    'backbone': 'libs/backbone-min',
    'text': 'libs/text',
    'ckeditor_core': 'libs/ckeditor/ckeditor',
    'ckeditor': 'libs/ckeditor/adapters/jquery',
    'bootstrap': 'libs/bootstrap',
    'fancybox': 'libs/fancybox/jquery.fancybox'
  },
  urlArgs: "bust=" + (new Date()).getTime(),
  mainConfigFile: '/javascripts/training.js'

});

require([
  // Load our app module and pass it to our definition function
  'training_app',
], function(App){
  App.initialize();
});
