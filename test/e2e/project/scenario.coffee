baseurl = 'file:///' + require('path').join do process.cwd, '_public', 'index.html'

module.exports =
  'Should be able to add a directory': (browser) ->
    browser
      .url baseurl
      .execute 'window.resizeTo(1024, 768);'
      # prevent nw file inputs from spawning dialogs
      .execute 'document.querySelector("input#directory").click = function() {};'
      .execute 'document.querySelector("input#save").click = function() {};'
      .execute 'document.querySelector("input#file").click = function() {};'
      .useXpath()
      .click '//span[text()="Project"]'
      .pause 1000
      .click '//li[text()="Add Directory"]'
      .pause 1000
      .useCss()
      .setValue 'input#directory', require('path').resolve('.')
      .assert.containsText 'ul.root > li.directory > div:not(.expander)', 'codeditor'
      
  'Should have root directory expanded by default and child directories are as expected': (browser) ->
    browser
      .assert.cssClassNotPresent 'ul.root > li.directory > div.expander', 'collapsed'
      .assert.cssClassPresent 'ul.root > li.directory > ul > li.directory:first-child > div.expander', 'collapsed'
      .assert.containsText 'ul.root > li.directory > ul > li.directory:nth-child(2) > div:not(.expander)', '_public'
      
  'Should behave as expected when directory is clicked': (browser) ->
    browser
      .click 'ul.root > li.directory > div:not(.expander)'
      .pause 1000
      .assert.cssClassPresent 'ul.root > li.directory > div.expander', 'collapsed'
      .click 'ul.root > li.directory > div:not(.expander)'
      .pause 1000
      .assert.cssClassNotPresent 'ul.root > li.directory > div.expander', 'collapsed'
      .click 'ul.root > li.directory > ul > li.directory:nth-child(2) > div:not(.expander)'
      .pause 1000
      .assert.cssClassNotPresent 'ul.root > li.directory > ul > li.directory:nth-child(2) > div.expander', 'collapsed'
      .assert.containsText 'ul.root > li.directory > ul > li.directory:nth-child(2) > ul > li:last-child > div:not(.expander)', 'package.json'
      .assert.containsText 'ul.root > li.directory > ul > li.directory:nth-child(2) > ul > li:first-child > div:not(.expander)', 'css'
      .click 'ul.root > li.directory > div:not(.expander)'
      .pause 1000
      .assert.cssClassPresent 'ul.root > li.directory > div.expander', 'collapsed'
      .click 'ul.root > li.directory > div:not(.expander)'
      .assert.cssClassNotPresent 'ul.root > li.directory > div.expander', 'collapsed'
      .assert.cssClassNotPresent 'ul.root > li.directory > ul > li.directory:nth-child(2) > div.expander', 'collapsed'
      .assert.visible 'ul.root > li.directory > ul > li.directory:nth-child(2) > ul > li:last-child'
      
  'Should be able to add multiple directories, and remove them all at the same time': (browser) ->
    browser
      .setValue 'input#directory', require('path').resolve('./app')
      .assert.containsText 'ul.root > li.directory:first-child > div:not(.expander)', 'codeditor'
      .assert.containsText 'ul.root > li.directory:last-child > div:not(.expander)', 'app'
      .useXpath()
      .click '//span[text()="Project"]'
      .pause 1000
      .click '//li[text()="Remove All Directories"]'
      .pause 1000
      .useCss()
      .assert.elementNotPresent 'ul.root > li.directory'
      
  'Should be able to save project and have it load on startup': (browser) ->
    browser
      .useXpath()
      .click '//span[text()="Project"]'
      .pause 1000
      .click '//li[text()="Add Directory"]'
      .pause 1000
      .useCss()
      .setValue 'input#directory', require('path').resolve('.')
      .useXpath()
      .click '//span[text()="Project"]'
      .pause 1000
      .click '//li[text()="Save Project File"]'
      .pause 1000
      .useCss()
      .setValue 'input#save', require('path').resolve('project.nwproj')
      .pause 1000
      .useXpath()
      .click '//span[text()="Project"]'
      .pause 1000
      .click '//li[text()="Remove All Directories"]'
      .pause 1000
      .useCss()
      .url baseurl
      .assert.elementPresent 'ul.root > li.directory'
      
  'Should be able to close project and not have it load on startup': (browser) ->
    do browser
      .useXpath()
      .click '//span[text()="Project"]'
      .pause 1000
      .click '//li[text()="Close Project"]'
      .pause 1000
      .useCss()
      .assert.elementNotPresent 'ul.root > li.directory'
      .url baseurl
      .assert.elementNotPresent 'ul.root > li.directory'
      .end