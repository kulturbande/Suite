redis = require('redis').createClient()
path = require 'path'
class Suite
	@key: ->
		"Suite:#{process.env.NODE_ENV}"

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

	constructor: (attributes) ->
		@[key] = value for key, value of attributes
		unless @path_name 
			throw new Error("You need to provide a path_name!")
		unless @name
			@name = @path_name.slice(0,1).toUpperCase() + @path_name.slice(1)
		unless @id
			@id = @path_name.replace /\s/g, '-'
		@path = path.join(__dirname, '../../suites', @path_name)
		@

	save: (callback) ->
		redis.hset Suite.key(), @id, JSON.stringify(@), (err, responseCode) =>
			callback null, @

	destroy: (callback) ->
		redis.hdel Suite.key(), @id, (err) ->
			callback err if callback


module.exports = Suite