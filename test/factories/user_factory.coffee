User = require '../../app/models/user'

UserFactory =

	createSeveral: (callback) ->
		fooUser =
			name: 'foo'
			password: '123'
		barUser =
			name: 'bar'
			password: '123'
		testUser =
			name: 'test'
			password: '123'
		userAttributes = [fooUser, barUser, testUser]
		createOne = @createOne
		runSequentially = (item, otherItems...) ->
			createOne item, ->
				if otherItems.length
					runSequentially otherItems...
				else
					callback()
		runSequentially userAttributes...

	createOne: (attributes, callback) ->
		user = new User(attributes)
		user.save (err, _user) ->
			callback err, _user

module.exports = UserFactory