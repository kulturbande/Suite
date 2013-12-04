module.exports = (grunt) ->

	grunt.initConfig
		pkg: grunt.file.readJSON('package.json') # make package.json available
		base64:
			html:
				files: 
					'logo_header.b64': ['./img/logo_header.png']

		imageEmbed:
			side: 
				src: [ "network/css/side.css" ]
				dest: "network/css/output/side.css"
				options:
					deleteAfterEncoding : false
			layout: 
				src: [ "network/css/layout.css" ]
				dest: "network/css/output/layout.css"
				options:
					deleteAfterEncoding : false
		

	grunt.loadNpmTasks 'grunt-base64'
	grunt.loadNpmTasks 'grunt-image-embed'

	#grunt.registerTask 'default', ['uglify'] # default task