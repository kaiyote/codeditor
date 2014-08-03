Editor =
  view: (ctrl) -> [
    m '#tabs', ctrl.tabs.map (tab) ->
      m 'span.tab',
        class: if tab.active then 'active' else ''
      , [
        m 'a.label',
          onclick: -> ctrl.switchSession tab
        , tab.name
        m 'a.status',
          onclick: -> ctrl.closeTab tab
        , 'x'
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
      currentTab = _.findWhere @tabs, {root: path}
      unless currentTab
        require('fs').readFile path, encoding: 'utf8', (err, data) =>
          unless err
            newMode = ace.require('ace/ext/modelist').getModeForPath(path).mode
            session = new ace.EditSession data, newMode
            tab = new Editor.Tab session, path
            @tabs.push tab
            @switchSession tab
      else
        @switchSession currentTab
        
    switchSession: (tab) ->
      @editor.setSession tab.session
      for tabb in @tabs
        tabb.active = if tabb.root is tab.root then yes else no
      @app.emit 'status:setMode', tab.session.getMode().$id
      do m.redraw
      
    closeTab: (tab) ->
      index = @tabs.indexOf tab
      oldTab = @tabs.splice index, 1
      @switchSession _.findWhere(@tabs, {active: yes}) or if index < @tabs.length then @tabs[index] else @tabs[@tabs.length - 1]
      
  Tab: class
    constructor: (@session, @root) ->
      @name = require('path').basename @root
      @active = no