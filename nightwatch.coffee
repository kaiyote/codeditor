path = require 'path'
fs = require 'fs'
async = require 'async'
dest = path.join do process.cwd, 'test'

getChromeDriverUrl = ->
  urlBase = 'http://chromedriver.storage.googleapis.com/2.10/chromedriver_'
  return urlBase + 'mac32.zip' if process.platform is 'darwin'
  return urlBase + 'win32.zip' if process.platform is 'win32'
  return urlBase + 'linux32.zip' if process.arch is 'ia32'
  return urlBase + 'linux64.zip' if process.arch is 'x64'
    
download = (target, url, dest, options, done, error) ->
  dl = require 'download'
  progressBar = require 'progress'
  bar = undefined
  d = dl url, dest, options
  
  d.on 'response', (res) ->
    total = parseInt res.headers['content-length'], 10
    bar = new progressBar "downloading #{target} [:bar] :percent :etas",
      complete: '='
      incomplete: '-'
      width: 20
      total: total
    
  d.on 'data', (data) ->
    bar.tick data.length
    console.log 'Extracting...' if bar.complete
        
  d.on 'error', (err) -> error err
    
  d.on 'close', -> process.nextTick -> do done

getChromeDriver = (done) ->
  exename = 'chromedriver' + if process.platform is 'win32' then '.exe' else ''
  fs.stat path.join(dest, exename), (err) ->
    if err
      url = do getChromeDriverUrl
      if url
        download 'chromedriver', url, dest,
          extract: yes
          strip: 1
        , ->
          fs.chmod path.join(dest, exename), 0o755, ->
            do done
        , (error) ->
          done error
      else
        done 'Could not determine host architecture...'
    else
      do done
      
getSelenium = (done) ->
  fs.stat path.join(dest, 'selenium-server-standalone-2.42.2.jar'), (err) ->
    if err
      url = 'http://selenium-release.storage.googleapis.com/2.42/selenium-server-standalone-2.42.2.jar'
      download 'selenium', url, dest,
        extract: no
        strip: 1
      , done
      , (error) ->
        done error
    else
      do done
      
adjustNightwatchForOS = (done) ->
  fs.readFile 'nightwatch.json',
    encoding: 'utf8'
  , (err, data) ->
    if err
      done err
    config = JSON.parse data
    if process.platform is 'win32' and config.selenium.cli_args['webdriver.chrome.driver'] isnt 'test/chromedriver.exe'
      config.selenium.cli_args['webdriver.chrome.driver'] = 'test/chromedriver.exe'
      config.test_settings.default.desiredCapabilities.chromeOptions.binary = 'node_modules/nodewebkit/nodewebkit/nw.exe'
      fs.writeFile 'nightwatch.json', JSON.stringify(config, null, 2), (err) ->
        done err if err
        do done
    else if process.platform isnt 'win32' and config.selenium.cli_args['webdriver.chrome.driver'] is 'test/chromedriver.exe'
      config.selenium.cli_args['webdriver.chrome.driver'] = 'test/chromedriver'
      config.test_settings.default.desiredCapabilities.chromeOptions.binary = 'node_modules/nodewebkit/nodewebkit/nw'
      fs.writeFile 'nightwatch.json', JSON.stringify(config, null, 2), (err) ->
        done err if err
        do done
    else
      do done
      
async.waterfall [
  getChromeDriver
  getSelenium
  adjustNightwatchForOS
], -> require 'nightwatch/bin/runner.js'