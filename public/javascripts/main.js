// Filename: main.js
require.config({
  baseUrl: "/javascripts/",
  shim: {
    underscore: {
      exports: '_'
    },
    backbone: {
      deps: ["underscore", "jquery"],
      exports: "Backbone"
    },
    ckeditor_core: {
      deps: ["jquery"],
      exports: "ckeditor_core"
    },
    ckeditor: {
      deps: ["jquery", "ckeditor_core"],
      exports: "ckeditor"
    }
  },
  paths: {
    'jquery': 'libs/jquery.min',
    'underscore': 'libs/underscore-min',
    'backbone': 'libs/backbone-min',
    'text': 'libs/text',
    'ckeditor_core': 'libs/ckeditor/ckeditor',
    'ckeditor': 'libs/ckeditor/adapters/jquery'
  },
  urlArgs: "bust=" + (new Date()).getTime(),
  mainConfigFile: '/javascripts/main.js'

});

require([
  // Load our app module and pass it to our definition function
  'app',
], function(App){
  App.initialize();
});
