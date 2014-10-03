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
    bootstrap: {
      deps: ["jquery"],
      exports: "bootstrap"
    },
    fancybox: {
      deps: ["jquery"],
      exports: "fancybox"
    },
    pretty_loader: {
      deps: ["jquery"],
      exports: "pretty-loader"
    },
    pretty_photo: {
      deps: ["jquery", "pretty-loader"],
      exports: "pretty-photo"
    },
    zoomer: {
      deps: ["jquery", "pretty-loader", "pretty-photo"],
      exports: "zoomer"
    }
  },
  paths: {
    'jquery': 'jquery.min',
    'underscore': 'libs/underscore-min',
    'backbone': 'libs/backbone-min',
    'text': 'libs/text',
    'ckeditor_core': 'libs/ckeditor/ckeditor',
    'ckeditor': 'libs/ckeditor/adapters/jquery',
    'bootstrap': 'libs/bootstrap.min',
    'fancybox': 'libs/fancybox/jquery.fancybox',
    'pretty-loader': 'libs/zoomer/assets/prettyLoader/js/jquery.prettyLoader',
    'pretty-photo': 'libs/zoomer/assets/prettyPhoto/js/jquery.prettyPhoto',
    'zoomer': 'libs/zoomer/assets/jquery.zoomer',
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
