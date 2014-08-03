Application =
  view: (ctrl) -> [
    m '.menubar', MenuBar.view ctrl.menuCtrl
    m '.mainContainer', [
      m '.project', Project.view ctrl.projCtrl
      m '.editor', Editor.view ctrl.editorCtrl
    ]
    m '.statusbar', StatusBar.view ctrl.statusCtrl
  ]
  
  controller: class
    constructor: ->
      gui = require 'nw.gui'
      @app = Application.Emitter
      @window = do gui.Window.get
      @menuCtrl = new MenuBar.controller
      @projCtrl = new Project.controller
      @editorCtrl = new Editor.controller
      @statusCtrl = new StatusBar.controller
      
      if DataStore.get 'project'
        Application.Emitter.emit 'project:openProject', yes
      
      @app.on 'app:close', =>
        do @window.close
        
      @app.on 'app:reload', =>
        do @window.reloadIgnoringCache
        
      @app.on 'app:devTools', =>
        do @window.showDevTools
        
  Emitter: require('nw.gui').App