Suite = require '../models/suite'

class Suites
	app = null

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

			app.get '/:id', (req, res) ->
				_self.view(req, res)

			app.get '/:id/load', (req, res) ->
				_self.load(req, res)

	view: (req, res) ->
		Suite.all (err, items) ->
			Suite.getById req.params.id, (err, item) ->
		 		res.render 'suites/view',
					title: item.name
					main_menu: items
					item: item

	load: (req, res) ->
		@app.engine('html', require('ejs').renderFile);
		res.render "../../suites/#{req.params.id}/index.html"

	index: (req, res) ->
		Suite.all (err, items) ->
			res.render 'suites/index',
	 			main_menu: items

module.exports = Suites