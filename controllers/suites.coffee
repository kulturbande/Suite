suites = (app) ->

	app.namespace '/suites', ->
		app.get '/', (req, res) ->
			res.render 'suites/index',
				title: 'Suite'
module.exports = suites