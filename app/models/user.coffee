redis = require('redis').createClient()
sha1 = require('sha1')

class User
	@key: ->
		"User:#{process.env.NODE_ENV}"

	@get_by_id: (id, callback) ->
		redis.hget User.key(), id, (err, json) ->
			if json is null
				callback new Error("User '#{id}' could not be found."), false
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
			if user
				if user.password == 'sha1_' + sha1(password)
					callback null, user
				else
					callback null, false
			else
				callback null, false

	constructor: (attributes) ->
		@[key] = value for key, value of attributes
		unless @name
			throw new Error("You need to provide a name!")
		unless @password
			throw new Error("You need to provide a password!")
		else unless @password.match /^sha1\_/
			@password = 'sha1_' + sha1(@password) # encrypt password

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