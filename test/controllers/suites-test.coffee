Suites 		= require '../../app/controllers/suites'
Suite 		= require '../../app/models/suite'
User 		= require '../../app/models/user'
UserFacotry = require '../factories/user_factory'

user = 
	username:'foo'
	password: 'foo'

login_user = (callback) ->
	request_agent.post("#{url}/login")
		.send(user)
		.end (err, res) ->
			callback()

logout_user = (callback) ->
	request_agent
		.get("#{url}/logout")
		.end (err, res) ->
			callback()

describe "Suites", ->

	before (done) ->
		UserFacotry.createOne {name: user.username, password: user.password}, done

	describe "GET /", ->
		response = null
		before (done) ->
			options =
				uri: "#{url}/"
			request options, (err, _response, _body) ->
				response = _response
				done()

		it "redirect to suites", ->
			assert.equal response.req.path, '/suites'

	describe "GET /suites", ->
		body = null
		before (done) ->
			options =
				uri: "#{url}/suites"
			request options, (err, response, _body) ->
				body = _body
				done()

		it "has title", ->
			assert.hasTag body, '//head/title', 'Suites'


	describe "GET /suites/:name", ->
		redirects = null
		body = null
		make_request = (callback) ->
			request_agent.get "#{url}/suites/network", (response) ->
				body = response.text
				redirects = response.redirects[0]
				callback()

		it "redirect to login without login - session", (done) ->
			make_request ->
				assert.equal redirects, "#{url}/login"
				done()

		it "has title", (done) ->
			login_user ->
				make_request ->
					assert.hasTag body, '//head/title', 'Suites - Network'
					logout_user done
			

	describe "POST /suites/:name/edit", ->
		redirects = null
		suite = null

		make_request = (callback) ->
			data =
				network_offset:
					img: 1
					css: 2
					js: 3
			request_agent.post("#{url}/suites/network/edit")
				.send(data)
				.end (err, _response) ->
					redirects = _response.redirects[0]
					callback()

		it "redirect to login without login - session", (done) ->
			make_request ->
				assert.equal redirects, "#{url}/login"
				done()

		it "redirect to view", (done) ->
			login_user ->
				make_request ->
					assert.equal redirects, "#{url}/suites/network"
					logout_user done

	describe "GET /load_suite/network", ->
		body = null
		before (done) ->
			options =
				uri: "#{url}/load_suite/network"
			request options, (err, response, _body) ->
				body = _body
				done()

		it "has title", ->
			assert.hasTag body, '//head/title', 'Test Suite - Network'

	describe "GET /load_suite/render", ->
		body = null
		before (done) ->
			options =
				uri: "#{url}/load_suite/render"
			request options, (err, response, _body) ->
				body = _body
				done()

		it "has title", ->
			assert.hasTag body, '//head/title', 'Test Suite - Render'

	describe "GET /suites/network/change_branch/master", ->
		redirects = null

		make_request = (callback) ->
			request_agent.get "#{url}/suites/network/change_branch/master", (response) ->
				redirects = response.redirects[0]
				callback()

		it "redirect to network", (done) ->
			login_user ->
				make_request ->
					assert.equal redirects, "#{url}/suites/network"
					logout_user done

		it "redirect to login without login - session", (done) ->
			make_request ->
				assert.equal redirects, "#{url}/login"
				logout_user done


	after (done) ->
		User.get_by_id user.username, (err, user) ->
			user.destroy done



