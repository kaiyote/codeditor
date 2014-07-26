ApplicationController =
  controller: class
    createMenu = (gui, root, menu) ->
      menuObj = menu or require('cson').parseFileSync 'menu.cson'
      for key, value of menuObj
        if _.isString value
          if key is '-' then root.append new gui.MenuItem type: 'separator'
          else
            root.append new gui.MenuItem
              label: key
              click: -> window.Emitter.emit value
        else if _.isObject value
          subMenu = new gui.Menu
          root.append new gui.MenuItem
            label: key
            submenu: createMenu gui, subMenu, value
      root
      
    constructor: ->
      @nwgui = require 'nw.gui'
      @window = do @nwgui.Window.get
      @window.menu = createMenu @nwgui, new @nwgui.Menu type: 'menubar'
      
      window.Emitter.on 'nw:close', =>
        do @window.close
      
  view: (ctrl) -> []