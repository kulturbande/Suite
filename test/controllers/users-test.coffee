Users 			= require '../../app/controllers/users'
user 			= require '../../app/models/user'
UserFacotry 	= require '../factories/user_factory'

describe "Users", ->
	describe "GET /login", ->
		body = null
		before (done) ->
			options =
				uri: "#{url}/login"
			request options, (err, _response, _body) ->
				body = _body
				done()

		it "has title", ->
			assert.hasTag body, '//head/title', 'Suites - Login'

	describe "POST /login", ->
		options = null
		before (done) ->
			options =
				uri: "#{url}/login"
				method: "POST"
				data:
					username: 'foo'
					password: '123'
			UserFacotry.createOne {name:'foo', password: 'foo'}, done

		it "redirect to login with wrong credentials", (done) ->
			request_agent.post(options.uri)
				.send(options.data)
				.end (err, response) ->
					assert.equal response.redirects[0], url + '/login'
					done()

		it "redirect to / with correct credentials", (done) ->
			options.data.password = 'foo'
			request_agent.post(options.uri)
				.send(options.data)
				.end (err, response) ->
					assert.equal response.redirects[0], url + '/'
					done()