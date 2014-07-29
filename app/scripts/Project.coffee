Project =
  view: (ctrl) -> [
    m 'ul.unstyled', ctrl.project().directories().map (element) ->
      m 'li.root', element
  ]
  
  controller: class
    constructor: ->
      @app = Application.Emitter
      @path = require 'path'
      @fs = require 'fs'
      @project = m.prop new Project.Project
      
      @app.on 'project:addDirectory', =>
        directory = document.querySelector 'input#directory'
        directory.onchange = =>
          @project().addDirectory directory.value
        do directory.click
        
      @app.on 'project:removeDirectories', =>
        do @project().removeDirectories
        
      @app.on 'project:saveProject', =>
        alert 'saving project'
        
      @app.on 'project:openProject', =>
        alert 'opening project'
        
      @app.on 'project:closeProject', =>
        alert 'closing project'
        
  Project: class
    constructor: ->
      @directories = m.prop []
      
    addDirectory: (path) ->
      @directories().push path if !_.contains @directories(), path
      do m.redraw
      
    removeDirectories: ->
      @directories do @directories().splice
      do m.redraw