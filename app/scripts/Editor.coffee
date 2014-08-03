Editor =
  view: (ctrl) -> [
    m '#tabs', [
      m '.tab.active', [
        m 'span.label', 'this is a tab'
        m '.status', 'x'
      ]
      m '.tab', [
        m 'span.label', 'another tab'
        m '.status', 'o'
      ]
    ]
    m '#editor', config: (element, isInit) -> ctrl.init element, isInit
  ]
    
  controller: class
    constructor: ->
      @app = Application.Emitter
      @tabs = []
      ace.config.set 'workerPath', 'js/ace'
      
    init: (element, isInit) ->
      unless isInit
        @editor = ace.edit element
        @editor.setTheme DataStore.get('theme') or 'ace/theme/chrome'
        
        @editor.getSelection().on 'changeCursor', =>
          Application.Emitter.emit 'status:cursor', do @editor.getCursorPosition
          
        @app.on 'editor:changeTheme', (theme) =>
          @editor.setTheme theme
          DataStore.set 'theme', theme
          
        @app.on 'editor:changeMode', (mode) =>
          @editor.getSession().setMode mode
          
        @app.on 'editor:openFile', (file) =>
          unless file
            fileElm = document.querySelector 'input#file'
            fileElm.onchange = =>
              @openFile fileElm.value
              fileElm.value = ''
            do fileElm.click
          else
            @openFile file
          
        @app.emit 'status:setTheme', do @editor.getTheme
        @app.emit 'status:setMode', @editor.getSession().getMode().$id
        
    openFile: (path) ->
      require('fs').readFile path, encoding: 'utf8', (err, data) =>
        unless err
          @editor.setValue data, -1
          newMode = ace.require('ace/ext/modelist').getModeForPath(path).mode
          @editor.getSession().setMode newMode
          @app.emit 'status:setMode', newMode
          
  Tab: class
    constructor: (@session, @name) ->
      