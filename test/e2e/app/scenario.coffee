path = require 'path'
baseurl = 'file:///' + path.join do process.cwd, '_public', 'index.html'

module.exports =
  setUp: (browser) ->
    browser
      .url baseurl
      .execute 'window.resizeTo(850, 850);'
  
  'Should auto-load the Todo view when no fragment is passed in': (browser) ->
    browser
      .assert.urlContains '#/todo'
      
  'Should navigate to /route1 when the "view1" link is clicked': (browser) ->
    browser
      .useXpath()
      .click "//a[text()='view1']"
      .pause 1000
      .useCss()
      .assert.urlContains '#/route1'
      
  'Todo: Should list 2 items': (browser) ->
    browser
      .elements 'css selector', '.list-unstyled li', (results) ->
        @assert.equal 2, results.value.length
          
  'Todo: Should display checked items with a line-through': (browser) ->
    browser
      .assert.cssClassPresent 'ul li input:checked + span', 'donetrue'
      
  'Todo: Should sync done status with checkbox state': (browser) ->
    browser
      .click 'ul li input:not(:checked)'
      .pause 1000
      .assert.cssClassPresent 'ul li input:focus + span', 'donetrue'
      .click 'ul li input:checked'
      .pause 1000
      .assert.cssClassPresent 'ul li input:focus + span', 'donefalse'
      
  'Todo: Should remove checked items when the archive link is clicked': (browser) ->
    browser
      .useXpath()
      .click "//a[text()='archive']"
      .pause 1000
      .useCss()
      .elements 'css selector', '.list-unstyled li', (results) ->
        @assert.equal 1, results.value.length
      
  'Todo: Should add a newly submitted item to the end of the list and empty the text input': (browser) ->
    newItemLabel = 'new todo item'
    
    browser
      .setValue 'input[type=text]', newItemLabel
      .click 'input[type=submit]'
      .pause 1000
      .elements 'css selector', '.list-unstyled li', (results) ->
        @assert.equal 3, results.value.length
      .assert.containsText '.list-unstyled li:nth-last-child(1) span', newItemLabel
      .assert.containsText 'input[type=text]', ''
      
  'View 1: Should render View 1 template when user navigates to view1': (browser) ->
    browser
      .useXpath()
      .click "//a[text()='view1']"
      .pause 1000
      .useCss()
      .assert.containsText 'p:first-child', 'This is the partial for view 1.'
      
  'View 2: Should render View 2 template when user navigates to view2': (browser) ->
    do browser
      .useXpath()
      .click "//a[text()='view2']"
      .pause 1000
      .useCss()
      .assert.urlContains '#/route2'
      .assert.containsText 'p:first-child', 'This is the partial for view 2.'
      .end