Editor =
  view: (ctrl) ->
    m '#editor', config: (element, isInit) -> ctrl.init element, isInit
    
  controller: class
    constructor: ->
      @app = Application.Emitter
      ace.config.set 'workerPath', 'js/ace'
      
    init: (element, isInit) ->
      unless isInit
        @editor = ace.edit element
        @editor.setTheme 'ace/theme/tomorrow_night'
        
        @editor.getSelection().on 'changeCursor', =>
          Application.Emitter.emit 'status:cursor', do @editor.getCursorPosition
          
        @app.on 'editor:changeTheme', (theme) =>
          @editor.setTheme theme
          
        @app.on 'editor:changeMode', (mode) =>
          @editor.getSession().setMode mode
          
        @app.emit 'status:setTheme', do @editor.getTheme
        @app.emit 'status:setMode', @editor.getSession().getMode().$id