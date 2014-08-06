MenuBar =
  view: (ctrl) ->
    m 'ul.unstyled', _.map ctrl.menus, (value, key) ->
      m 'li.root', [
        m 'span',
          onclick: ctrl.toggleMenu
          onmouseover: ctrl.showMouseover
        , key
        m 'ul.menu.unstyled.hidden', _.map value, (subValue, key) ->
          ctrl.registerShortCut subValue.keys, subValue.command, subValue.argument if subValue and subValue.command isnt 'editor:aceCommand'
          m 'li.menuitem',
            class: if key.match /^-+$/ then 'separator' else ''
            onclick: -> ctrl.app.emit subValue.command, subValue.argument if subValue
          , if key.match /^-+$/ then m 'hr' else [
            m 'span', key
            m 'span.keys', ctrl.getKeyText subValue.keys, subValue.argument
          ]
      ]
      
  controller: class
    constructor: ->
      @gui = require('nw.gui')
      @app = Application.Emitter
      @app.on 'menu:commandHash', (hash) =>
        @commands = hash
      @events = []
      do m.startComputation
      require('fs').readFile 'settings/menu.json', encoding: 'utf8', (err, data) =>
        @menus = JSON.parse data unless err
        window.menus = @menus or err
        do m.endComputation
        
      document.querySelector('.wrapper').onclick = =>
        for element in document.querySelectorAll('.menu')
          element.classList.add 'hidden'
        @mouseOver = no
        
      #mostly for debugging purposes
      @gui.Window.get().on 'loading', =>
        do @app.removeAllListeners
        do @listener.reset
        
      @listener = new window.keypress.Listener null,
        is_exclusive: yes
        is_solitary: yes
        prevent_repeat: yes
        
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
        
    getKeyText: (keyString, argString) =>
      isMac = /darwin/.test process.platform
      metaRpl = if isMac then 'Command' else 'Ctrl'
      return keyString.split(' ').map((word) -> word.replace word[0], do word[0].toUpperCase).join('-').replace('Meta', metaRpl) if keyString
      return _.last((@commands[argString].bindKey[if isMac then 'mac' else 'win'] or '').split('|')) if argString
      
    registerShortCut: (keyCombo, command, argument) ->
      @listener.register_combo
        keys: keyCombo
        on_keyup: ->
          @app.emit command, argument
        this: @