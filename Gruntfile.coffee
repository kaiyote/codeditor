module.exports = (grunt) ->
  grunt.initConfig
    pkg: grunt.file.readJSON '_public/package.json'
    nodeunit:
      unit: ['test/unit/**/*.tests.coffee']
      options:
        reporter: 'nested'
    nodewebkit:
      options:
        version: "0.9.2"
        build_dir: './dist'
        # specifiy what to build
        mac: false
        win: true
        linux32: false
        linux64: false
      src: './_public/**/*'
    coffee:
      test:
        options:
          bare: yes
          sourceMap: no
        expand: yes
        src: ['test/e2e/**/*.coffee']
        ext: '.js'
    clean:
      test:
        src: ['test/e2e/**/*.js', 'settings', 'fonts']
    copy:
      test:
        files: [
          expand: yes
          cwd: 'app/assets/fonts/'
          src: ['**']
          dest: 'fonts/'
        ,
          expand: yes
          cwd: 'app/assets/settings/'
          src: ['**']
          dest: 'settings/'
        ]
        
  grunt.loadNpmTasks 'grunt-node-webkit-builder'
  grunt.loadNpmTasks 'grunt-contrib-nodeunit'
  grunt.loadNpmTasks 'grunt-contrib-coffee'
  grunt.loadNpmTasks 'grunt-contrib-clean'
  grunt.loadNpmTasks 'grunt-contrib-copy'
  grunt.registerTask 'default', ['nodewebkit']
  grunt.registerTask 'ace', ->
    try
      path = require 'path'
      config = grunt.file.readJSON 'bower_components/ace-builds/.bower.json'
      unless config.main
        files = []
        grunt.file.recurse 'bower_components/ace-builds/src-noconflict', (abspath, rootdir, subdir, filename) ->
          if filename.indexOf('worker') is -1 and subdir is undefined
            files.push path.join 'src-noconflict', filename
        config.main = files
        grunt.file.write 'bower_components/ace-builds/.bower.json', JSON.stringify config, null, 2
      return true
    catch e
      grunt.log.error "Error reading ace-builds' bower.json.  Check to make sure you've installed the bower packages.\n" + e
      return false