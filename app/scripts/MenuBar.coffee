MenuBar =
  view: (ctrl) ->
    m 'ul', _.map ctrl.menus, (value, key) ->
      m 'li.root', [
        m 'span',
          onclick: ctrl.toggleMenu
          onmouseover: ctrl.showMouseover
        , key
        m 'ul.menu.hidden', _.map value, (subValue, key) ->
          m 'li.menuitem',
            class: if key is '-' then 'separator' else ''
            onclick: -> ctrl.app.emit subValue if subValue
          , if key isnt '-' then key else m 'hr'
      ]
      
  controller: class
    constructor: ->
      @gui = require('nw.gui')
      @app = Application.Emitter
      @events = []
      do m.startComputation
      require('fs').readFile 'settings/menu.json', encoding: 'utf8', (err, data) =>
        @menus = JSON.parse data
        do m.endComputation
        
      document.querySelector('.wrapper').onclick = =>
        for element in document.querySelectorAll('.menu')
          element.classList.add 'hidden'
        @mouseOver = no
        
      #mostly for debugging purposes
      @gui.Window.get().on 'loading', =>
        do @app.removeAllListeners
          
    showMenu: (target, isHidden) =>
      for element in document.querySelectorAll('.menu')
        element.classList.add 'hidden'
      if isHidden
        target.classList.remove 'hidden'
        @mouseOver = yes
      else
        @mouseOver = no
        
    toggleMenu: (event) =>
      target = event.target.nextSibling
      isHidden = target.classList.contains 'hidden'
      @showMenu target, isHidden
      do event.stopPropagation
      
    showMouseover: (event) =>
      if @mouseOver
        @showMenu event.target.nextSibling, yes