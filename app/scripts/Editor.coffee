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
        prevFiles = DataStore.get('files') or ['untitled.txt']
        prevFiles.push 'untitled.txt' if prevFiles.length is 0
          
        @app.on 'editor:changeTheme', (theme) =>
          @editor.setTheme theme
          DataStore.set 'theme', theme
          
        @app.on 'editor:changeMode', (mode) =>
          @editor.getSession().setMode mode
          
        @app.on 'editor:openFile', (path) =>
          unless path
            file = document.querySelector 'input#file'
            file.onchange = =>
              @openFile file.value
              file.value = ''
            do file.click
          else
            @openFile path
            
        @app.on 'editor:newFile', => @openFile ''
        
        @openFile file for file in prevFiles
        
        @app.emit 'status:setTheme', do @editor.getTheme
        
    openFile: (path) ->
      currentTab = _.findWhere(@tabs, {root: path}) or _.findWhere @tabs, {root: 'untitled.txt', active: yes}
      unless currentTab
        require('fs').readFile path, encoding: 'utf8', (err, data) =>
          unless err
            tab = new Editor.Tab path, data, ace.require('ace/ext/modelist').getModeForPath(path).mode
            @tabs.push tab
            @switchSession tab
          else
            tab = new Editor.Tab 'untitled.txt', '', 'ace/mode/text'
            @tabs.push tab
            @switchSession tab
      else if currentTab.root is 'untitled.txt'
        require('fs').readFile path, encoding: 'utf8', (err, data) =>
          unless err
            tab = new Editor.Tab path, data, ace.require('ace/ext/modelist').getModeForPath(path).mode
            @tabs[@tabs.indexOf currentTab] = tab
            @switchSession tab
          else
            tab = new Editor.Tab 'untitled.txt', '', 'ace/mode/text'
            @tabs.push tab
            @switchSession tab
      else
        @switchSession currentTab
        
    switchSession: (tab) ->
      @editor.setSession tab.session
      for tabb in @tabs
        tabb.active = if tabb is tab then yes else no
      @app.emit 'status:setMode', tab.session.getMode().$id
      @app.emit 'status:cursor', do tab.session.getSelection().getCursor
      do m.redraw
      
    closeTab: (tab) ->
      index = @tabs.indexOf tab
      oldTab = @tabs.splice index, 1
      DataStore.set 'files', do _.chain(@tabs).filter((tab) -> tab.root isnt 'untitled.txt').map((tab) -> tab.root).value
      if @tabs.length is 0
        @openFile ''
      else
        @switchSession _.findWhere(@tabs, {active: yes}) or if index < @tabs.length then @tabs[index] else @tabs[@tabs.length - 1]
      
  Tab: class
    constructor: (@root, data, mode) ->
      @name = require('path').basename @root
      @active = no
      @session = new ace.EditSession data, mode
      @session.getSelection().on 'changeCursor', =>
          Application.Emitter.emit 'status:cursor', do @session.getSelection().getCursor
      unless @root is 'untitled.txt'
        files = DataStore.get('files') or []
        files.push @root unless -1 < files.indexOf @root
        DataStore.set 'files', files