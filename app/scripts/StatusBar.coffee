StatusBar =
  view: (ctrl) -> [
    m '.project-toggle',
      onclick: -> ctrl.app.emit 'project:toggle'
      class: if document.querySelector('.project.collapsed') then 'collapsed' else ''
    , [
      m 'div', '>'
      m 'div', '>'
    ]
    m 'span.cursor', "#{ctrl.cursor.row + 1}:#{ctrl.cursor.column}"
    m 'select#modes',
      onchange: (evt) -> ctrl.app.emit 'editor:changeMode', evt.target.value
    , ctrl.modes.map (mode) ->
      m 'option', value: mode.mode, mode.caption
    m 'select#themes',
      onchange: (evt) -> ctrl.app.emit 'editor:changeTheme', evt.target.value
    , ctrl.themes.map (theme) ->
      m 'option', value: theme.theme, theme.caption
  ]
    
  controller: class
    constructor: ->
      @app = Application.Emitter
      @modes = ace.require('ace/ext/modelist').modes
      @themes = ace.require('ace/ext/themelist').themes
      @cursor =
        row: 0
        column: 0
      
      @app.on 'status:cursor', (pos) =>
        @cursor = pos
        do m.redraw
        
      @app.on 'status:setTheme', (theme) =>
        document.querySelector('#themes').selectedIndex = do _.chain @themes
                                                            .map (myTheme) -> myTheme.theme
                                                            .indexOf theme
                                                            .value
                                                            
      @app.on 'status:setMode', (mode) =>
        document.querySelector('#modes').selectedIndex = do _.chain @modes
                                                            .map (myMode) -> myMode.mode
                                                            .indexOf mode
                                                            .value