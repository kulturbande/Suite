User = require '../../app/models/user'

UserFactory =

	createSeveral: (callback) ->
		fooUser =
			name: 'foo'
		barUser =
			name: 'bar'
		testUser =
			name: 'test'
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