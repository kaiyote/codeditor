baseurl = 'file:///' + require('path').join do process.cwd, '_public', 'index.html'

module.exports =
  setUp: (browser) ->
    browser
      .url baseurl
      .execute 'window.resizeTo(1024, 768);'
      
  'Should show File menu when "File" is clicked': (browser) ->
    browser
      .useXpath()
      .click '//span[text()="File"]'
      .pause 1000
      .assert.visible '//li[text()="New"]'
      .assert.visible '//li[text()="Close"]'
      
  'Should show Project menu when "Project" is clicked': (browser) ->
    browser
      .click '//span[text()="Project"]'
      .pause 1000
      .assert.visible '//li[text()="Add Directory"]'
      .assert.visible '//li[text()="Close Project"]'
      
  'Should show Project menu after "File" is clicked and mouse moves to "Project"': (browser) ->
    browser
      .click '//span[text()="File"]'
      .pause 1000
      .moveToElement '//span[text()="Project"]', 2, 2
      .pause 1000
      .assert.visible '//li[text()="Add Directory"]'
      .assert.hidden '//li[text()="New"]'
      
  'Should stop showing menu when something else is clicked': (browser) ->
    do browser
      .click '//span[text()="File"]'
      .pause 1000
      .useCss()
      .click '.mainContainer'
      .pause 1000
      .useXpath()
      .assert.hidden '//li[text()="New"]'
      .moveToElement '//span[text()="Project"]', 2, 2
      .pause 1000
      .assert.hidden '//li[text()="Add Directory"]'
      .useCss()
      .end