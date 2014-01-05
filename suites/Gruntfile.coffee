module.exports = (grunt) ->

	cdn_files = (folder) ->
		[
			src: 'network/build/suite.min.css'
			dest: folder + '/suite.min.css'
		,
			src: 'network/build/suite.min.js'
			dest: folder + '/suite.min.js'
		,
			cwd: 'network/build/img/'
			src: ['**']
			dest: folder + '/img/'
			expand: true
		,
			cwd: 'network/fonts/vendors/'
			src: ['side.*']
			dest: folder + '/fonts/vendors/'
			expand: true
		,
			src: 'network/build/fonts/vendors/Ubuntu-Regular.ttf'
			dest: folder + '/fonts/vendors/Ubuntu-Regular.ttf'
		]

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
		uglify:
			options:
				report: 'min'
			minify:
				src: ['network/build/suite.js']
				dest: 'network/build/suite.min.js'
				options:
					mangle: false
			obfuscate:
				src: ['network/build/suite.js']
				dest: 'network/build/suite.min.js'
		cssmin:
			minify:
				options:
					keepSpecialComments: false
					report: 'min'
				src: ['network/build/suite.css']
				dest: 'network/build/suite.min.css'

		pngmin:
			src: ['network/img/*.png']
			dest: 'network/build'

		gifmin:
			src: ['network/img/*.gif']
			dest: 'network/build'

		jpgmin:
			src: [
				'network/img/*.jpg'
				'network/img/responsive/*.jpg'
			]
			dest: 'network/build'
			quality: 80

		font_optimizer:
			options:
				chars: '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz'
				includeFeatures: ['kern']
			ttf:
				files:
					'network/build/fonts/vendors/Ubuntu-Regular.ttf': ['network/fonts/vendors/Ubuntu-Regular.ttf']

		htmlmin:
			index:
				options:
					removeComments: true
					collapseWhitespace: true
					collapseBooleanAttributes: true
					removeAttributeQuotes: true
					removeRedundantAttributes: true
					removeEmptyAttributes: true
					removeOptionalTags: true
				files:
					'network/index.min.html': 'network/index.html'

		compress:
			prepare_master_cdn_files:
				options:
					mode: 'gzip'
					level: 9
				files: [
					src: ['network/build/suite.min.js'], dest: 'network/gzip/suite.min.gz.js', ext: '.gz.js'
				,
					src: ['network/build/suite.min.css'], dest: 'network/gzip/suite.min.gz.css', ext: '.gz.css'
				,
					src: ['network/build/fonts/vendors/Ubuntu-Regular.ttf'], dest: 'network/gzip/Ubuntu-Regular.gz.ttf', ext: '.gz.ttf'
				,
					src: ['network/fonts/vendors/side.ttf'], dest: 'network/gzip/side.gz.ttf', ext: '.gz.ttf'
				]

		aws: grunt.file.readJSON 'aws.json'
		aws_s3:
			options:
				accessKeyId: '<%= aws.key %>'
				secretAccessKey: '<%= aws.secret %>'
				bucket: '<%= aws.bucket %>'
				access: 'public-read'
				region: '<%= aws.region %>'

			cdn_single:
				files: cdn_files('single')

			cdn_several:
				files: cdn_files('several')

			cdn_all:
				files: cdn_files('all')

			cdn_gzip_compressed:
				options:
					params:
						CacheControl: 'public, max-age=31536000'
						ContentEncoding: 'gzip'
				files: [
					cwd: 'network/gzip/', src: ['*.gz.*'], dest: 'compress', expand: true
				]
			img:
				options:
					bucket: '<%= aws.images_bucket %>'
				files: [
					cwd: 'network/build/img/'
					src: ['**']
					dest: ''
					expand: true
				]
			img_master:
				options:
					bucket: '<%= aws.images_bucket %>'
					params:
						CacheControl: 'public, max-age=31536000'
				files: [
					cwd: 'network/build/img/'
					src: ['**']
					dest: 'compressed'
					expand: true
				]
			js:
				files: [
					src: 'network/build/suite.min.js'
					dest: 'suite.min.js'
					bucket: '<%= aws.javascripts_bucket %>'
				]
			font:
				options:
					bucket: '<%= aws.fonts_bucket %>'
				files: [
					cwd: 'network/fonts/vendors/'
					src: ['side.*']
					dest: ''
					expand: true
				,
					src: 'network/build/fonts/vendors/Ubuntu-Regular.ttf'
					dest: 'Ubuntu-Regular.ttf'
				]

		responsive_images:
			slider:
				options:
					sizes: [
						name: '240'
						width: 240
					,
						name: '240'
						width: 480
						suffix: '-x2'
					,
						name: '480'
						width: 480
					,
						name: '480'
						width: 960
						suffix: '-x2'
					,
						name: '640'
						width: 640
					,
						name: '640'
						width: 1280
						suffix: '-x2'
					,
						name: '720'
						width: 720
					,
						name: '720'
						width: 1440
						suffix: '-x2'
					,
						name: '940'
						width: 940
					,
						name: '940'
						width: 1880
						suffix: '-x2'
					,
						name: '1140'
						width: 1140
					,
						name: '1140'
						width: 2280
						suffix: '-x2'
					]
				files: [
					cwd: 'network/img/'
					src: ['slider_*']
					dest: 'network/img/responsive/'
					expand: true

				]
			article:
				options:
					sizes: [
						name: '117'
						width: 117
					,
						name: '117'
						width: 234
						suffix: '-x2'
					,
						name: '194'
						width: 194
					,
						name: '194'
						width: 388
						suffix: '-x2'
					,
						name: '236'
						width: 236
					,
						name: '236'
						width: 472
						suffix: '-x2'
					]
				files: [
					cwd: 'network/img/'
					src: ['article_1.jpg', 'article_2.jpg']
					dest: 'network/img/responsive/'
					expand: true

				]

	grunt.loadNpmTasks 'grunt-responsive-images'
	grunt.loadNpmTasks 'grunt-aws-s3'
	grunt.loadNpmTasks 'grunt-contrib-htmlmin'
	grunt.loadNpmTasks 'grunt-font-optimizer'
	grunt.loadNpmTasks 'grunt-imagine'
	grunt.loadNpmTasks 'grunt-contrib-cssmin'
	grunt.loadNpmTasks 'grunt-contrib-uglify'
	grunt.loadNpmTasks 'grunt-contrib-concat'
	grunt.loadNpmTasks 'grunt-contrib-compress'
	grunt.loadNpmTasks 'grunt-image-embed'

	grunt.registerTask 'embed-images-in-css', ['imageEmbed:side', 'imageEmbed:layout']
	grunt.registerTask 'embed-images-in-html', ['imageEmbed:inline']

	grunt.registerTask 'default', ['concat', 'uglify:obfuscate', 'cssmin', 'pngmin', 'gifmin', 'jpgmin', 'font_optimizer', 'htmlmin']
	grunt.registerTask 'minimize', ['concat', 'uglify:obfuscate', 'cssmin', 'htmlmin']

	grunt.registerTask 'deploy_master', ['compress', 'aws_s3:cdn_gzip_compressed', 'aws_s3:img_master']
