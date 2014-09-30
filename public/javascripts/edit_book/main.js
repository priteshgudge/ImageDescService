// Filename: main.js

// Require.js allows us to configure shortcut alias
// There usage will become more apparent further along in the tutorial.
require.config({
  baseUrl: "/javascripts/",
  shim: {
    'ckeditor-jquery': {
      deps:['jquery', 'ckeditor-core']
    }
  },
  paths: {
    'jquery': 'libs/jquery.min',
    'underscore': 'libs/underscore-min',
    'backbone': 'libs/backbone-min',
    'text': 'libs/text',
    'lazyload': 'libs/jquery.lazyload.min',
    'ckeditor-core': 'libs/ckeditor/ckeditor',
    'ckeditor': 'libs/ckeditor/adapters/jquery'
  },
  urlArgs: "bust=" + (new Date()).getTime()

});

require([
  // Load our app module and pass it to our definition function
  'edit_book/app',
], function(App){
  console.log(requirejs.s.contexts._.config);
  // The "app" dependency is passed in as "App"
  App.initialize();
});
