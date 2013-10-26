assert 			= require 'assert'
redis			= require('redis').createClient()
User 			= require '../../app/models/user'
UserFacotry 	= require '../factories/user_factory'

describe 'User', ->

	describe 'create', ->
		user = null
		before (done) ->
			user = new User {name: 'foo', password: 'test'}
			done()
		it "sets name", ->
			assert.equal user.name, 'foo'

		describe "generate id", ->
			it "default Id", ->
				assert.equal user.id, 'foo'

	describe 'persistence', ->
		it 'builds a key for redis', ->
			assert.equal User.key(), 'User:test'

		describe 'save', ->
			user = null
			before (done) ->
				user = new User 
					name: 'foo'
					password: 'foo'
				user.save ->
					done()
			it 'returns an User - object', ->
				assert.instanceOf user, User

			it 'should not store the password as plain - text', ->
				assert.notEqual user.password, 'foo'

		describe 'get one', ->
			describe 'existing record', ->
				user = null
				before (done) ->
					UserFacotry.createOne {name: 'foo', password: 'test'}, () ->
						User.get_by_id 'foo', (err, _user) ->
							user = _user
							done()
				it 'returns an User - object', ->
					console.log user
					assert.instanceOf user, User
				it 'fetches the correct object', ->
					assert.equal user.name, 'foo'

			describe 'non-existing record', ->
				it 'returns an error', (done) ->
					User.get_by_id 'network', (err, json) ->
						assert.equal err.message, "User 'network' could not be found."
						done()

		describe 'get all', ->
			users = null
			before (done) ->
				UserFacotry.createSeveral ->
					User.all (err, _users) ->
						users = _users
						done();
			it 'retrieves all users', ->
				assert.equal users.length, 3

		describe 'delete', ->
			before (done) ->
				UserFacotry.createOne {name:'foo', password: 'foo'}, done
			it 'is removed from the database', (done) ->
				User.get_by_id 'foo', (err, user) ->
					user.destroy (err) ->
						User.get_by_id 'foo', (err) ->
							assert.equal err.message, "User 'foo' could not be found."
							done()

		afterEach ->
			redis.del User.key()

	describe 'validation', ->
		it 'requires a name', ->
			assert.throws (->
				new User()
			), /provide a name/

		it 'requires a password', ->
			assert.throws (->
				new User({name: 'foo'})
			), /provide a password/
