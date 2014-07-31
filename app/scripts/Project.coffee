Project =
  view: (ctrl) -> [
    m 'ul.unstyled.root', ctrl.project.directories.map (dir) ->
      Directory.view(new Directory.controller dir)
  ]
  
  controller: class
    constructor: ->
      @app = Application.Emitter
      @path = require 'path'
      @fs = require 'fs'
      @project = new Project.Project
      
      @app.on 'project:addDirectory', =>
        directory = document.querySelector 'input#directory'
        directory.onchange = =>
          @project.addDirectory directory.value
          directory.value = ''
        do directory.click
        
      @app.on 'project:removeDirectories', =>
        do @project.removeDirectories
        
      @app.on 'project:saveProject', =>
        file = document.querySelector 'input#save'
        file.onchange = =>
          @project.saveProject file.value
          file.value = ''
        do file.click
        
      @app.on 'project:openProject', (autoLoad) =>
        if _.isBoolean autoLoad and autoLoad is yes
          data = JSON.parse DataStore.Create('simple').get 'project'
          @project.loadProject data
        else
          file = document.querySelector 'input#file'
          file.onchange = =>
            require('fs').readFile file.value, encoding: 'utf8', (err, data) =>
              unless err
                data = JSON.parse data
                @project.loadProject data
          do file.click
          
      @app.on 'project:closeProject', =>
        do @project.closeProject
        
  Project: class
    constructor: ->
      @directories = []
      
    addDirectory: (path) ->
      if (!_.find @directories, (dir) -> dir.root is path)
        dir = new Directory.Directory path
        do dir.LoadChildren
        @directories.push dir
        do m.redraw
      
    removeDirectories: ->
      @directories = []
      do m.redraw
      
    saveProject: (path) ->
      project =
        dirs: @directories.map (dir) -> dir.root
      require('fs').writeFile path, JSON.stringify(project), (err) ->
        unless err
          DataStore.Create('simple').set 'project', JSON.stringify project
          
    loadProject: (data) ->
      @addDirectory dir for dir in data.dirs
      DataStore.Create('simple').set 'project', JSON.stringify data
      
    closeProject: ->
      @directories = []
      DataStore.Create('simple').delete 'project'
      
Directory =
  view: (ctrl) ->
    m 'li.directory', [
      m '.expander',
        class: if ctrl.root.loaded then '' else 'collapsed'
      , '>'
      m 'div',
        onclick: -> if ctrl.root.loaded then do ctrl.collapse else do ctrl.expand
      , ctrl.root.name
      m 'ul.unstyled',
        class: if ctrl.root.loaded then '' else 'collapsed'
      , [
        ctrl.root.directories.map (dir) -> Directory.view(new Directory.controller dir)
        ctrl.root.files.map (file) -> File.view(new File.controller file)
        m 'hr' unless ctrl.root.directories.length or ctrl.root.files.length
      ]
    ]
    
  controller: class
    constructor: (@root) ->
      
    expand: ->
      if @root.directories.length is 0 then do @root.LoadChildren else @root.loaded = yes
      do m.redraw
      
    collapse: ->
      @root.loaded = no
      do m.redraw
      
  Directory: class
    constructor: (@root) ->
      @files = []
      @directories = []
      @name = require('path').basename @root
      @loaded = no
      
    LoadChildren: ->
      d = do require('domain').create
      d.on 'error', (err) ->
      d.run =>
        require('fs').readdir @root, (err, files) =>
          if !err
            files = files.map (file) => require('path').join(@root, file)
            for file in files
              stat = require('fs').statSync file
              if do stat.isDirectory
                @directories.push new Directory.Directory file unless _.contains @directories, file
              else
                @files.push file unless _.contains @files, file
            @directories = _.sortBy @directories, (directory) -> do directory.root.toLowerCase
            @files = _.sortBy @files, (file) -> do file.toLowerCase
            @loaded = true
          do m.redraw
          
File =
  view: (ctrl) ->
    m 'li.file', m 'div', ctrl.name
    
  controller: class
    constructor: (@root) ->
      @name = require('path').basename @root