redis = require('redis').createClient()
path = require 'path'
fs = require 'fs'
async = require 'async'
_ = require 'underscore'
Git = require '../libs/git'

class Suite
	@key: ->
		"Suite:#{process.env.NODE_ENV}"

	@main_folder: ->
		path.join(__dirname, '../../suites')

	@get_by_id: (id, callback) ->
		redis.hget Suite.key(), id, (err, json) ->
			if json is null
				callback new Error("Suite '#{id}' could not be found.")
				return
			suite = new Suite JSON.parse(json)
			callback null, suite

	@all: (callback) ->
		redis.hgetall Suite.key(), (err, objects) ->
			suites = []
			for key, value of objects
				suite = new Suite JSON.parse(value)
				suites.push suite
			callback null, suites

	@synchronize: (callback) ->
		fs.readdir Suite.main_folder(), (err, folders) ->
			# remove node_modules - folder
			folders = folders.filter((folder) -> folder != 'node_modules')

			synchronized_suites = []
			Suite.all (err, suites_in_db) ->
				# read database entries
				suites_in_db.forEach (suite) ->
					key = _.indexOf(folders, suite.path_name)
					if key == -1
						suite.destroy()
					else
						# console.log suite
						suite.read_repository (_suite) ->
							_suite.save (err, item) ->

						folders.splice(key, 1)

				# include
				if folders.length
					async.each folders,((folder, _callback) ->
						folder_path = path.join(Suite.main_folder(), folder)
						if fs.lstatSync(folder_path).isDirectory()
							suite = new Suite {path_name: folder}
							suite.read_repository (suite) ->
								suite.save (err, item) ->
									synchronized_suites.push(item)
									_callback()
						else
							_callback()
					), (err) ->
						callback null, synchronized_suites
				else
					callback null, synchronized_suites

	constructor: (attributes) ->
		@[key] = value for key, value of attributes
		unless @path_name
			throw new Error("You need to provide a path_name!")
		unless @name
			@name = @path_name.slice(0,1).toUpperCase() + @path_name.slice(1)
		unless @id
			@id = @path_name.replace /\s/g, '-'
		unless @network_offset
			@network_offset =
				img: 0
				css: 0
				js: 0
		unless @file_name
			@file_name = 'index.html'

		unless @compression
			@compression = 'disabled'

		unless @expire_headers
			@expire_headers = 'none'

		unless @branch_data
			@branch_data = {}

		@path = path.join(Suite.main_folder(), @path_name)
		@read_path() # validate path
		@

	save: (callback) ->
		redis.hset Suite.key(), @id, JSON.stringify(@), (err, responseCode) =>
			callback null, @

	destroy: (callback) ->
		redis.hdel Suite.key(), @id, (err) ->
			callback err if callback

	read_path: ->
		try
			stats = fs.statSync(@path)
			unless stats.isDirectory()
				throw new Error "This isn't a folder"
		catch error
			throw new Error "Can't find or read #{@path} folder"

	read_repository: (callback = ->) ->
		_self = @
		repository = new Git @path
		repository.branch (branches) ->
			_self.branches = branches
			callback _self

	find_index_file: (callback = ->) ->
		_self = @
		@file_name = 'index.html'
		fs.readdir _self.path, (err, files) ->
			if _.find(files, (file) -> file == 'index.min.html')
				_self.file_name = 'index.min.html'
				callback _self
			else
				callback _self

	change_branch: (name, callback = ->) ->
		_self = @
		repository = new Git @path
		repository.checkout name, ->
			_self.read_repository ->
				_self.find_index_file ->
					_self.save ->
						callback()

	current_branch: ->
		current_branch = ''
		branch = _.find @branches, (entry) -> entry.current
		if branch
			current_branch = branch.name
		current_branch

	add_branch_data: (data) ->
		current_branch = @current_branch()
		if typeof @['branch_data'][current_branch] == "undefined"
			@['branch_data'][current_branch] = []

		@['branch_data'][current_branch].push data

	get_branch_data: ->
		current_branch = @current_branch()
		if typeof @['branch_data'][current_branch] == "undefined"
			@['branch_data'][current_branch] = []
		@['branch_data'][current_branch]

	remove_branch_data: (callback) ->
		@['branch_data'][@current_branch()] = []
		@save callback

module.exports = Suite