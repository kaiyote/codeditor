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
        ace.require 'ace/ext/language_tools'
        @editor = ace.edit element
        @app.emit 'menu:commandHash', @editor.commands.byName
        @editor.setTheme DataStore.get('theme') or 'ace/theme/chrome'
        
        settings = DataStore.get 'settings'
        if settings
          @applySettings settings
        else
          require('fs').readFile 'settings/options.json', encoding: 'utf8', (err, data) =>
            unless err
              data = JSON.parse data
              DataStore.set 'settings', data
              @applySettings data
              
        prevFiles = DataStore.get('files') or ['untitled.txt']
        prevFiles.push 'untitled.txt' if prevFiles.length is 0
          
        @app.on 'editor:changeTheme', (theme) =>
          @editor.setTheme theme
          @applyTheme theme
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
        
        @app.on 'editor:saveFile', =>
          tab = _.findWhere @tabs, active: yes
          @saveFile tab.root, do tab.session.getValue
          
        @app.on 'editor:saveFileAs', =>
          tab = _.findWhere @tabs, active: yes
          @saveFileAs do tab.session.getValue
          
        @app.on 'editor:aceCommand', (command) =>
          @editor.execCommand command
          
        @app.on 'editor:nextTab', =>
          currentIndex = _.indexOf @tabs, _.findWhere @tabs, active: yes
          newTab = @tabs[currentIndex + 1] or @tabs[0]
          @switchSession newTab
          
        @app.on 'editor:previousTab', =>
          currentIndex = _.indexOf @tabs, _.findWhere @tabs, active: yes
          newTab = @tabs[currentIndex - 1] or @tabs[@tabs.length - 1]
          @switchSession newTab
          
        @app.on 'settings:edit', =>
          tab = new Editor.Tab '__/settings', JSON.stringify(DataStore.get('settings'), null, 2), 'ace/mode/json'
          @tabs.push tab
          @switchSession tab
          
        @openFile file for file in prevFiles
        
        @applyTheme do @editor.getTheme
        @app.emit 'status:setTheme', do @editor.getTheme
        
        @editor.on 'input', =>
          if @editor.getSession().getUndoManager().hasUndo()
            document.querySelector('.tab.active .status').classList.add('dirty')
          else
            document.querySelector('.tab.active .status').classList.remove('dirty')
            
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
        
    saveFile: (path, content) ->
      if path is '__/settings'
        @saveAndApplySettings content
      else unless path is 'untitled.txt'
        require('fs').writeFile path, content, (err) =>
          if err
            m.render document.querySelector('#dialog'), Dialog 'Save Error', m 'span', err
            do document.querySelector('#dialog').showModal
          else
            document.querySelector('.tab.active .status').classList.remove('dirty')
      else
        @saveFileAs content
        
    saveFileAs: (content) ->
      currentTab = _.findWhere @tabs, active: yes
      if currentTab.root is '__/settings'
        @saveAndApplySettings content
      else
        file = document.querySelector 'input#save'
        file.onchange = =>
          path = file.value
          require('fs').writeFile file.value, content, (err) =>
            if err
              m.render document.querySelector('#dialog'), Dialog 'Save Error', m 'span', err
              do document.querySelector('#dialog').showModal
            else
              tab = new Editor.Tab path, content, ace.require('ace/ext/modelist').getModeForPath(path).mode
              @tabs[@tabs.indexOf currentTab] = tab
              @switchSession tab
              document.querySelector('.tab.active .status').classList.remove('dirty')
          file.value = ''
        do file.click
      
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
        
    applySettings: (settings) ->
      @editor.setOptions settings.editor
      @editor.renderer.setOptions settings.renderer
      
    saveAndApplySettings: (settingsString) ->
      settings = JSON.parse settingsString
      DataStore.set 'settings', settings
      @applySettings settings
      tab.session.setOptions settings.session for tab in @tabs
      document.querySelector('.tab.active .status').classList.remove 'dirty'
      
    applyTheme: (theme) ->
      theme = _.last theme.split '/'
      dark = ace.require('ace/ext/themelist').themesByName[theme].isDark
      document.querySelector('link[rel="stylesheet"]').href = "css/app_#{if dark then 'dark' else 'light'}.css"
      
  Tab: class
    constructor: (@root, data, mode) ->
      @name = require('path').basename @root
      @active = no
      @session = ace.createEditSession data, mode
      @session.getSelection().on 'changeCursor', =>
        Application.Emitter.emit 'status:cursor', do @session.getSelection().getCursor
      @session.setOptions DataStore.get('settings').session
      unless @root is 'untitled.txt' or @root is '__/settings'
        files = DataStore.get('files') or []
        files.push @root unless -1 < files.indexOf @root
        DataStore.set 'files', files