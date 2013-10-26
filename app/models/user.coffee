redis = require('redis').createClient()

class User
	@key: ->
		"User:#{process.env.NODE_ENV}"

	@get_by_id: (id, callback) ->
		redis.hget User.key(), id, (err, json) ->
			if json is null
				callback new Error("User '#{id}' could not be found.")
				return
			user = new User JSON.parse(json)
			callback null, user

	@all: (callback) ->
		redis.hgetall User.key(), (err, objects) ->
			users = []
			for key, value of objects
				user = new User JSON.parse(value)
				users.push user
			callback null, users

	@authenticate: (name, password, callback) ->
		User.get_by_id name, (err, user) ->
			callback null, user

	constructor: (attributes) ->
		@[key] = value for key, value of attributes
		unless @name
			throw new Error("You need to provide a name!")
		unless @password
			throw new Error("You need to provide a password!")

		unless @id
			@id = @name.replace /\s/g, '-'
		@

	save: (callback) ->
		redis.hset User.key(), @id, JSON.stringify(@), (err, responseCode) =>
			callback null, @

	destroy: (callback) ->
		redis.hdel User.key(), @id, (err) ->
			callback err if callback

module.exports = User