Application =
  controller: class
    constructor: ->
      @app = require('nw.gui').App
      @window = do require('nw.gui').Window.get
      @menuCtrl = new MenuBar.controller
      
      @app.on 'ce:close', =>
        do @window.close
        
      @app.on 'ce:reload', =>
        do @window.reloadIgnoringCache
        
      @app.on 'ce:devTools', =>
        do @window.showDevTools
        
  view: (ctrl) -> [
    m '.menubar', MenuBar.view ctrl.menuCtrl
    m '.mainContainer', [
      m '.project', 'Project'
      m '.editor', 'Editor'
    ]
    m '.statusbar', 'Status Bar'
  ]