'use strict'

TodoCtrl =
  controller: class
    constructor: ->
      @todos = [
        text: 'learn Mithril'
        done: m.prop yes
      ,
        text: 'build a Mithril app'
        done: m.prop no
      ]
      @todoText = m.prop ''
      
    addTodo: (evt) ->
      unless do @todoText is ''
        @todos.push
          text: do @todoText
          done: m.prop no
        @todoText ''
      do evt?.preventDefault
      do evt?.stopPropagation
      return
      
    remaining: ->
      count = 0
      for todo in @todos
        if !(do todo.done) then count++
      count
      
    archive: ->
      oldTodos = @todos
      @todos = []
      for todo in oldTodos
        @todos.push todo unless do todo.done
      return
      
  view: (ctrl) -> [
    m 'h2', 'Todo'
    m 'span', do ctrl.remaining + ' of ' + ctrl.todos.length + ' remaining [ '
    m 'a',
      onclick: -> do ctrl.archive
    , 'archive'
    m 'span', ' ]'
    m 'ul.list-unstyled', ctrl.todos.map (todo) ->
      m 'li', m 'label.checkbox.inline', [
        m 'input',
          type: 'checkbox'
          onchange: m.withAttr 'checked', todo.done
          checked: do todo.done
        m "span.done#{do todo.done}", todo.text
      ]
    m 'form.form-inline', m 'p', [
      m 'input',
        type: 'text'
        size: 30
        placeholder: 'add new todo here'
        onchange: m.withAttr 'value', ctrl.todoText
        value: do ctrl.todoText
      m 'input.btn.btn-primary',
        type: 'submit'
        value: 'add'
        onclick: (evt) -> ctrl.addTodo evt
    ]
  ]
  
Ctrl1 =
  controller: ->
    onePlusOne: 2
  view: (ctrl) ->
    m 'p', 'This is the partial for view 1.'
    
Ctrl2 =
  controller: ->
  view: (ctrl) ->
    m 'p', 'This is the partial for view 2.'

AppCtrl =
  controller: class
    constructor: ->
      m.route.mode = 'hash'
      
    init: (elm, isInit, context) ->
      return if isInit
      m.route elm, '/todo',
        '/todo': TodoCtrl
        '/route1': Ctrl1
        '/route2': Ctrl2
      
    getClass: (route) ->
      return 'active' if do m.route is route
      return ''
    
  view: (ctrl) -> [
    m 'nav.navbar.navbar-default', m '.container', [
      m '.navbar-header', [
        m 'button.navbar-toggle',
          'data-toggle': 'collapse'
          'data-target': '#bs-example-navbar-collapse-1'
        , [
            m 'span.sr-only', 'Toggle navigation'
            m 'span.icon-bar'
            m 'span.icon-bar'
            m 'span.icon-bar'
        ]
        m 'a.navbar-brand',
          href: '#'
        , 'Node Webkit Stylish Seed'
      ]
      m '.collapse.navbar-collapse#bs-example-navbar-collapse-1', m 'ul.nav.navbar-nav', [
        m "li",
          'class': ctrl.getClass '/todo'
        , m 'a',
          onclick: -> m.route '/todo'
        , 'todo'
        m "li",
          'class': ctrl.getClass '/route1'
        , m 'a',
          onclick: -> m.route '/route1'
        , 'view1'
        m "li",
          'class': ctrl.getClass '/route2'
        , m 'a',
          onclick: -> m.route '/route2'
        , 'view2'
      ]
    ]
    m '.container', m '#routeHolder', config: ctrl.init
    m 'footer.footer', m '.container', m 'p', m 'small', m 'a',
      href: 'https://github.com/kaiyote/node-webkit-stylish-seed'
    , 'node-webkit-stylish-seed | source'
  ]

# expose the controllers to Node for testing with node-unit
if typeof module isnt 'undefined'
  module.exports =
    Ctrl1: Ctrl1
    Ctrl2: Ctrl2
    TodoCtrl: TodoCtrl
    AppCtrl: AppCtrl