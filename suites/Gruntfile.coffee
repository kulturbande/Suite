module.exports = (grunt) ->

	grunt.initConfig
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

			inline: 
				src: [ "network/css/inline.css" ]
				dest: "network/css/output/inline.css"
				options:
					deleteAfterEncoding : false
		concat:
			javascript:
				src: ['network/js/**/jquery*.js','network/js/**/bootstrap.js', 'network/js/*.js']
				dest: 'network/build/suite.js'
			css:
				src: ['network/css/vendors/*.css', 'network/css/*.css']
				dest: 'network/build/suite.css'

	grunt.loadNpmTasks 'grunt-contrib-concat'
	grunt.loadNpmTasks 'grunt-image-embed'
	
	grunt.registerTask 'embed-images-in-css', ['imageEmbed:side', 'imageEmbed:layout']
	grunt.registerTask 'embed-images-in-html', ['imageEmbed:inline']
