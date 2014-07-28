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