redis = require('redis').createClient()
path = require 'path'
fs = require 'fs'
async = require 'async'
_ = require 'underscore'
Repo = require('git').Repo
class Suite
	@key: ->
		"Suite:#{process.env.NODE_ENV}"

	@main_folder: ->
		path.join(__dirname, '../../suites')

	@getById: (id, callback) ->
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
			synchronized_suites = []
			Suite.all (err, suites_in_db) ->
				# read database entries
				suites_in_db.forEach (suite) ->
					key = _.indexOf(folders, suite.path_name)
					if key == -1
						suite.destroy()
					else
						folders.splice(key, 1)
				# include
				if folders.length
					async.each folders,((folder, _callback) ->
						suite = new Suite {path_name: folder}
						suite.save (err, item) ->
							synchronized_suites.push(item)
							_callback()
					), (err) ->
						callback null, synchronized_suites
				else
					callback null, synchronized_suites

	@get_branches: (id, callback) ->
		_self = @
		@getById id, (err, suite) ->
			repo = new Repo suite.path, {is_bare: true}, (err, repo) ->
				callback(null, null)

	constructor: (attributes) ->
		@[key] = value for key, value of attributes
		unless @path_name 
			throw new Error("You need to provide a path_name!")
		unless @name
			@name = @path_name.slice(0,1).toUpperCase() + @path_name.slice(1)
		unless @id
			@id = @path_name.replace /\s/g, '-'

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
			throw new Error "Can't find or read that folder"

	read_respository: (callback) ->
		try 
			stats = fs.statSync(@path)
			unless stats.isDirectory()
				callback "This isn't a folder"
			repo = new Repo @path, {is_bare: true}, (err, repo) ->
				repo.heads (err, heads) ->
					console.log heads
					callback(err, folder)
		catch error
			callback "Can't find or read that folder"

module.exports = Suite