exports.config =
  conventions:
    assets:  /^app[\/\\]+assets[\/\\]+/
    ignored: /^(app[\/\\]+styles[\/\\]+overrides|(.*?[\/\\]+)?[_]\w*)/
  modules:
    definition: false
    wrapper: false
  paths:
    'public': '_public'
  files:
    javascripts:
      joinTo:
        'js/app.js': /^app/
        'js/vendor.js': /^bower_components/
        
    stylesheets:
      joinTo:
        'css/app_dark.css': /^(app[\/\\]styles[\/\\]dark)/
        'css/app_light.css': /^(app[\/\\]styles[\/\\]light)/
  plugins:
    jade:
      pretty: yes # Adds pretty-indentation whitespaces to output (false by default)
    assetsmanager:
      copyTo:
        'js/ace': ['bower_components/ace-builds/src-min-noconflict/worker*']