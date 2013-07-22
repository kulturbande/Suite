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

		it "has all suites", ->
			assert.hasTag body, '//div.suite-menu/ul/li/a', 'Network'

	describe "GET /suites/network", ->
		body = null
		before (done) ->
			options =
				uri: "#{url}/suites/network"
			request options, (err, response, _body) ->
				body = _body
				done()

		it "has title", ->
			assert.hasTag body, '//head/title', 'Test Suite - Network'
