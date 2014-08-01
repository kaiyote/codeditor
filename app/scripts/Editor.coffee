Editor =
  view: (ctrl) ->
    m '#editor', config: (element, isInit) -> ctrl.init element, isInit
    
  controller: class
    constructor: ->
      
    init: (element, isInit) ->
      unless isInit
        @editor = ace.edit element
        @editor.setTheme 'ace/theme/tomorrow_night'