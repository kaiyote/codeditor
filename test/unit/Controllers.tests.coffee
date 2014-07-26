m = require '../../bower_components/mithril/mithril.js'
Controllers = require '../../app/scripts/controllers.coffee'

exports['Stub Controller Tests'] =
  'Ctrl1 Behaves Like Expected': (test) ->
    test.ok Controllers, 'require worked'
    test.ok Controllers.Ctrl1, 'require behaved'
    test.ok new Controllers.Ctrl1.controller, 'the object is as we expect'
    test.equal 2, (new Controllers.Ctrl1.controller).onePlusOne, 'the object behaved'
    do test.done
    
  'Ctrl2 Is a Thing': (test) ->
    test.ok new Controllers.Ctrl2.controller, 'the object is a thing'
    do test.done
    
exports['Todo Controller Tests'] =
  setUp: (callback) ->
    @todoCtrl = new Controllers.TodoCtrl.controller
    do callback
    
  'Base status of TodoCtrl is as expected': (test) ->
    test.equal 2, @todoCtrl.todos.length, 'we have the default 2 objects'
    test.equal '', do @todoCtrl.todoText, 'todoText is blank by default'
    do test.done
    
  'Can add new Todo': (test) ->
    @todoCtrl.todoText 'test'
    do @todoCtrl.addTodo
    test.equal 3, @todoCtrl.todos.length, 'we successfully added a todo'
    test.equal 'test', @todoCtrl.todos[2].text, 'the todo we added is the todo we got back'
    do test.done
    
  'Given Default status, Remaining is correct': (test) ->
    test.ok do @todoCtrl.todos[0].done, 'the first default todo is done'
    test.ok !(do @todoCtrl.todos[1].done), 'the second default todo is not done'
    test.equal 1, do @todoCtrl.remaining, 'there is only 1 remaining to be done'
    do test.done
    
  'Remaining is Still Correct after Adding new Todo': (test) ->
    @todoCtrl.todoText 'test'
    do @todoCtrl.addTodo
    test.equal 2, do @todoCtrl.remaining, 'there should be 2 remaining'
    do test.done
    
  'Cannot Add Todo without Text': (test) ->
    do @todoCtrl.addTodo
    test.equal 2, @todoCtrl.todos.length, 'it should not have added anything'
    do test.done
    
  'Archiving Default State should leave 1 todo': (test) ->
    do @todoCtrl.archive
    test.equal 1, @todoCtrl.todos.length, 'there should be one left'
    test.equal 1, do @todoCtrl.remaining, 'there should be one remaining'
    do test.done
    
exports['App Controller Tests'] =
  setUp: (callback) ->
    m.route = -> '/todo'
    @appCtrl = new Controllers.AppCtrl.controller
    do callback
    
  'Todo link should be active': (test) ->
    test.equal 'active', @appCtrl.getClass '/todo'
    do test.done
    
  'Other link should get empty string': (test) ->
    test.equal '', @appCtrl.getClass '/route1'
    do test.done