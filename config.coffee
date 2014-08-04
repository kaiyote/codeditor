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
        'css/app.css': /^(app|vendor|bower_components)/
      order:
        # make sure custom css comes after bootstrap, etc
        after: [
          'app/styles/app.styl'
        ]
  plugins:
    jade:
      pretty: yes # Adds pretty-indentation whitespaces to output (false by default)
    assetsmanager:
      copyTo:
        'js/ace': ['bower_components/ace-builds/src-min-noconflict/worker*']