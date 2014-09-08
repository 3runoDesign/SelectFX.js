module.exports = (grunt) ->
  require("load-grunt-tasks") grunt
  require("time-grunt") grunt

  config =
    app: 'app'
    dist: 'dist'
    tmp: '.tmp'
    bower: 'app/components'
    banner: "/*<%= pkg.name %> v<%= pkg.version %> - <%= pkg.description %>\n
    Copyright (c) <%= grunt.template.today('yyyy') %> <%= pkg.authors %> - <%= pkg.homepage %>\n
    License: <%= pkg.license %>*/\n\n"

  grunt.initConfig
    config: config

    pkg: grunt.file.readJSON('package.json')

    # Build compile ==========
    # Template Engine(Jade)
    jade:
      dist:
        files: [
          expand: true
          cwd: "<%= config.app %>/jade"
          src: [
            "{,*/}*.jade"
            "!**/_*"
          ]
          dest: "<%= config.tmp %>/"
          ext: ".html"
        ]
        options:
          client: false
          pretty: true
          basedir: "<%= config.app %>/jade"
          data: (dest, src) ->
            page = src[0].replace(/app\/jade\/(.*)\/*.jade/, "$1")
            page = "index"  if page is src[0]
            page: page

    # SASS(scss)
    sass:
      options:
        loadPath: require('node-neat').includePaths

      dist:
        files: [
          expand: true
          cwd: "<%= config.app %>/scss"
          src: [
            "{,themes/}*.scss"
          ]
          dest: "<%= config.tmp %>/"
          ext: ".css"
        ]

    # CoffeeScript(js)
    coffee:
      options:
        bare: true
      dist:
        files: [
          expand: true
          cwd: '<%= config.app %>/coffee'
          src: '{,*/}*.{coffee,litcoffee,coffee.md}'
          dest: '<%= config.tmp %>'
          ext: '.js'
        ]

    # Rigger
    rig:
      options:
        banner: "<%= config.banner %>"
        bare: true
      dist:
        files:
          "<%= config.tmp %>/<%= pkg.name %>" : ["<%= config.app %>/coffee/selectfx.coffee"]
          "<%= config.tmp %>/query_<%= pkg.name %>" : ["<%= config.app %>/coffee/modules/QuerySelectFx.coffee"]

    # Minification (Images and SVG)
    imagemin:
      dist:
        files: [
          expand: true
          cwd: "<%= config.app %>/images"
          src: "{,*/}*.{gif,jpeg,jpg,png}"
          dest: "<%= config.tmp %>/images"
        ]

    svgmin:
      dist:
        files: [
          expand: true
          cwd: "<%= config.app %>/images"
          src: "{,*/}*.svg"
          dest: "<%= config.tmp %>/images"
        ]

    # Minifications ==========
    uglify:
      options:
        mangle: false
        banner: "<%= config.banner %>"
      dist:
        files: [
          expand: true
          cwd: "<%= config.dist %>"
          src: [
            "{,**/}*.js"
          ]
          dest: "<%= config.dist %>/"
          ext: ".min.js"
        ]

    cssmin:
      options:
        banner: "<%= config.banner %>"
      dist:
        files: [
          expand: true
          cwd: "<%= config.dist %>"
          src: [
            "{,**/}*.css"
            "!*.min.css"
          ]
          dest: "<%= config.dist %>/"
          ext: ".min.css"
        ]

    concat:
      options:
        banner: "<%= config.banner %>"

    # Wiredep
    wiredep:
      build:
        src: ["<%= config.tmp %>{,**/}*.html"]
        cwd: ""
        dependencies: true
        devDependencies: false
        exclude: []
        fileTypes: {}
        ignorePath: ""
        overrides: {}

    # Usemin
    useminPrepare:
      options:
        dest: "<%= config.tmp %>"

      html: "<%= config.tmp %>/{,*/}*.html"

    usemin:
      options:
        assetsDirs: [
          "<%= config.tmp %>"
          "<%= config.tmp %>/images"
        ]

      html: ["<%= config.tmp %>/{,**/}*.html"]
      css: ["<%= config.tmp %>/{,*/}*.css"]

    # Clean
    clean:
      dist:
        files: [
          dot: true
          src: [
            ".tmp"
            "<%= config.dist %>"
          ]
        ]

    # Copy
    copy:
      dist_js:
        files: [
          expand: true
          dot: true
          cwd: "<%= config.tmp %>"
          dest: "<%= config.dist %>/js"
          src: [

            "*.js"
          ]
        ]
      dist_css:
        files: [
          expand: true
          dot: true
          cwd: "<%= config.tmp %>"
          dest: "<%= config.dist %>/css"
          src: [
            "{,**/}*.css"
            "!layout.css"
          ]
        ]
    # Taks
    concurrent:
      buildAll:[
        'clean'
        'sass'
        'coffee'
        'imagemin'
        'svgmin'
        'rig'
      ]

      buildHTML:[
        'jade'
      ]
      buildCSS:[
        'sass'
        # 'sass:themes'
      ]
      buildJS:[
        'coffee'
        'rig'
      ]

    # Connect
    connect:
      options:
        port: 9000
        open: true
        livereload: 35729

        # Change this to '0.0.0.0' to access the server from outside
        hostname: "localhost"

      livereload:
        options:
          middleware: (connect) ->
            [
              connect.static(".tmp")
              connect().use("/#{config.bower}", connect.static("./#{config.bower}"))
            ]

    # Watch
    watch:
      coffee:
        files: ['<%= config.app %>/coffee/{,**/}*.coffee']
        tasks: [
          'concurrent:buildJS'
        ]

      scss:
        files: ['<%= config.app %>/scss/{,**/}*.scss']
        tasks: [
          'concurrent:buildCSS'
        ]

      jade:
        files: ['<%= config.app %>/jade/{,**/}*.jade']
        tasks: [
          'concurrent:buildHTML'
          'wiredep'
        ]

      images:
        files: [
          "<%= config.app %>/images/{,**/}..{gif,jpeg,jpg,png,svg}"
        ]
        tasks: [
          'imagemin'
          'svgmin'
        ]

      livereload:
        options:
          livereload: "<%= connect.options.livereload %>"

        files: [
          "<%= config.tmp %>{,**/}*.html"
          "<%= config.tmp %>{,**/}*.css"
          "<%= config.tmp %>{,**/}*.js"
          "<%= config.app %>/images/{,*/}*"
        ]

    # RegisterTask
    grunt.registerTask 'default', ()->
      grunt.task.run [
        'concurrent:buildAll'
        'copy:dist_js'
        'copy:dist_css'
        'cssmin'
      ]

    grunt.registerTask 'serve', ()->
      grunt.task.run [
        'concurrent:buildAll'
        'jade'
        'wiredep'
        'connect'
        'watch'
      ]
