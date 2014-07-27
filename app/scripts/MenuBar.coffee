MenuBar =
  controller: class
    constructor: ->
      @window = do require('nw.gui').Window.get
      do m.startComputation
      require('fs').readFile 'menu.json', encoding: 'utf8', (err, data) =>
        @menus = JSON.parse data
        do m.endComputation
        
      document.onclick = =>
        for element in document.querySelectorAll('.menu')
          element.classList.add 'hidden'
        @mouseOver = no
          
    showMenu: (target, isHidden) =>
      for element in document.querySelectorAll('.menu')
        element.classList.add 'hidden'
      if isHidden
        target.classList.remove 'hidden'
        @mouseOver = yes
      else
        @mouseOver = no
        
    toggleMenu: (event) =>
      isHidden = event.target.nextSibling.classList.contains 'hidden'
      @showMenu event.target.nextSibling, isHidden
      do event.stopPropagation
      
    showMouseover: (event) =>
      if @mouseOver
        @showMenu event.target.nextSibling, yes
      
  view: (ctrl) ->
    m 'ul', _.map ctrl.menus, (value, key) ->
      m 'li.root', [
        m 'span',
          onclick: ctrl.toggleMenu
          onmouseover: ctrl.showMouseover
        , key
        m 'ul.menu.hidden', _.map value, (subValue, key) ->
          m 'li.menuitem', key
      ]