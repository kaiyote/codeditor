MenuBar =
  controller: class
    constructor: ->
      @window = do require('nw.gui').Window.get
      @menus = {}
      require('fs').readFile 'menu.json',
        encoding: 'utf8'
      , (err, data) =>
        @menus = JSON.parse data
        do m.redraw
      
  view: (ctrl) ->
    m 'ul.menu', _.map ctrl.menus, (value, key) ->
      m 'li.root', [
        m 'span', key
        m 'ul', _.map value, (subValue, key) ->
          m 'li', key
      ]
      