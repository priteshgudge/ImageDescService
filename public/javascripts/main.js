// Filename: main.js
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
    },
    'bootstrap/modal': { 
      deps: ['jquery'], 
      exports: '$.fn.modal' 
    },
    'bootstrap/tab': { 
      deps: ['jquery'], 
      exports: '$.fn.tab' 
    },
    'bootstrap/popover': { 
      deps: ['jquery'], 
      exports: '$.fn.popover' 
    },
    fancybox: {
      deps: ["jquery"],
      exports: "fancybox"
    },
    mespeak: {
      exports: "mespeak"
    },
    scrollTo: {
      deps: ['jquery'],
      exports: ['scrollTo']
    },
    MathJax: {
      exports: "MathJax",
      init: function() {
        MathJax.Hub.Config({
          jax: ["input/AsciiMath", "input/MathML", "input/TeX", "output/SVG", "output/NativeMML"],
          extensions: ["asciimath2jax.js", "tex2jax.js", "MathMenu.js", "MathZoom.js", "toMathML.js"],
          tex2jax: {
            inlineMath: [ ['$','$'], ["\\(","\\)"] ],
            displayMath: [ ['$$','$$'], ["\\[","\\]"] ],
            processEscapes: true
          }
        });
        MathJax.Hub.Startup.onload();
        return MathJax;
      }
    },
    JSWAVES: {
      deps: ["jquery", "MathJax"],
      exports: "JSWAVES"
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
    'fancybox': 'libs/fancybox/jquery.fancybox',
    'mespeak': 'libs/mespeak/mespeak.min',
    'scrollTo': 'libs/jquery/jquery.scrollTo.min',
    'MathJax': 'https://cdn.mathjax.org/mathjax/latest/MathJax.js?config=TeX-AMS-MML_HTMLorMML&amp;delayStartupUntil=configured',
    'JSWAVES': 'libs/JSWAVES/waves.js?config=/javascripts/libs/JSWAVES/defaults/config.json'
  },
  mainConfigFile: '/javascripts/main.js',
  waitSeconds: 120,
  urlArgs: "bust=" + (new Date()).getTime()
});

require([
  // Load our app module and pass it to our definition function
  'app',
], function(App){
  App.initialize();
});
