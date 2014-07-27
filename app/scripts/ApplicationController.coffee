ApplicationController =
  controller: class
    createMenu = (menu, gui, root) ->
      for key, value of menu
        if _.isString value
          if key is '-' then root.append new gui.MenuItem type: 'separator'
          else
            root.append new gui.MenuItem
              label: key
              click: do ->
                # hack to deal with coffeescript's scoping insanity
                event = new String value
                -> gui.App.emit event
        else if _.isObject value
          subMenu = new gui.Menu
          root.append new gui.MenuItem
            label: key
            submenu: createMenu value, gui, subMenu
      root
      
    constructor: ->
      @nwgui = require 'nw.gui'
      @window = do @nwgui.Window.get
      require('fs').readFile 'menu.json',
        encoding: 'utf8'
      , (err, data) =>
        menu = JSON.parse data
        @window.menu = createMenu menu, @nwgui, new @nwgui.Menu type: 'menubar'
      
      @nwgui.App.on 'ce:close', =>
        do @window.close
        
      @nwgui.App.on 'ce:reload', =>
        do @window.reloadIgnoringCache
        
      @nwgui.App.on 'ce:devTools', =>
        do @window.showDevTools
        
  view: (ctrl) -> [
    m '.menubar', 'Menu Bar'
    m '.mainContainer', [
      m '.project', 'Project'
      m '.editor', 'Editor'
    ]
    m '.statusbar', 'Status Bar'
  ]