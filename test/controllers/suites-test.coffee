Suites = require '../../app/controllers/suites'
Suite = require '../../app/models/suite'
describe "Suites", ->
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
		body = null
		before (done) ->
			options =
				uri: "#{url}/suites/network"
			request options, (err, response, _body) ->
				body = _body
				done()

		it "has title", ->
			assert.hasTag body, '//head/title', 'Suites - Network'

	describe "POST /suites/:name/edit", ->
		response = null
		suite = null
		before (done) ->
			options =
				uri: "#{url}/suites/network/edit"
				method: "POST"
				data:
					network_offset:
						img: 1
						css: 2
						js: 3
			request options, (err, _response, _body) ->
				response = _response
				Suite.get_by_id 'network', (err, item) ->
					suite = item
					done()

		it "redirect to view", ->
			assert.equal response.headers.location, '/suites/network'

		# it "should have another network offset", ->
		# 	assert.equal suite.network_offset.img, 1

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
		response = null
		before (done) ->
			options =
				uri: "#{url}/suites/network/change_branch/master"
			request options, (err, _response, body) ->
				response = _response
				done()

		it "redirect to network", ->
			assert.equal response.req.path, '/suites/network'



