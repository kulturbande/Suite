describe "Suites", ->

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
