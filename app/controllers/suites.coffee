Suite = require '../models/suite'

class Suites
	app = null
	main_menu = ['network', 'render']

	constructor: (app) ->
		@app = app
		Suite.synchronize ->
			console.log 'Suites synchronized!'
		@routes()
		@

	routes: ->
		app = @app
		_self = @
		app.get '/', (req, res) ->
			res.redirect '/suites'

		app.namespace '/suites', ->
			app.get '/', (req, res) ->
				_self.index(req, res)

			app.get '/:name', (req, res) ->
				_self.view(req, res)

			app.get '/:name/load', (req, res) ->
				_self.load(req, res)

	view: (req, res) ->
		Suite.all (err, items) ->
	 		res.render 'suites/view',
				title: req.params.name
				main_menu: items
				name: req.params.name

	load: (req, res) ->
		@app.engine('html', require('ejs').renderFile);
		res.render "../../suites/#{req.params.name}/index.html"

	index: (req, res) ->
		Suite.all (err, items) ->
			res.render 'suites/index',
	 			main_menu: items

module.exports = Suites