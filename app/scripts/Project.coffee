Project =
  view: (ctrl) -> [
    m 'span', 'Project'
    m 'input#directory.hidden[type=file]', nwdirectory: yes
  ]
  
  controller: class
    constructor: ->
      @app = Application.Emitter
      @project = new Project.Project
      
      @app.on 'project:addDirectory', =>
        directory = document.querySelector 'input#directory'
        console.log 'got element'
        directory.onchange = =>
          @project.addDirectory directory.value
        console.log 'set onchange and attempting click'
        do directory.click
        return
        
      @app.on 'project:removeDirectories', =>
        alert 'removing directories'
        
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
      console.log do @directories