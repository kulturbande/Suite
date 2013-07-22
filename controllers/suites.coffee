suites = (app) ->
	# redirect to main route
	app.get '/', (req, res) ->
		res.redirect '/suites'

	app.namespace '/suites', ->
		app.get '/', (req, res) ->
			res.render 'suites/index',
				title: 'Suites'

		app.get '/:name', (req, res) ->
			app.engine('html', require('ejs').renderFile);
			res.render "../suites/#{req.params.name}/index.html"
module.exports = suites