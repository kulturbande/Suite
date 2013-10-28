Suite = require '../models/suite'
path = require 'path'
express = require 'express'
_ = require 'underscore'

class Suites
	app = null

	constructor: (app) ->
		@app = app
		Suite.synchronize (err, _suites) ->
			Suite.all (err, suites) ->
				suites.forEach (suite) ->
					app.use '/load_suite', express.static(path.join(__dirname, "../../suites/#{suite.path_name}"))
			console.log 'Suites synchronized!'
		@routes()
		@

	routes: ->
		app = @app
		_self = @
		app.get '/', (req, res) ->
			res.redirect '/suites'

		app.all '/suites/*', (req, res, next)->
			if req.user
				next()
			else
				res.redirect '/login'

		app.get '/load_suite/:id', (req, res) ->
			_self.load(req, res)

		app.namespace '/suites', ->
			app.get '/', (req, res) ->
				_self.index(req, res)

			app.namespace '/:id', ->
				app.get '/', (req, res) ->
					_self.view(req, res)

				app.post '/edit', (req, res) ->
					_self.edit(req, res)

				app.get '/change_branch/:name', (req, res) ->
					_self.change_branch(req, res)

	view: (req, res) ->
		Suite.all (err, items) ->
			Suite.get_by_id req.params.id, (err, item) ->
				branches = []
				current_branch = ''
				for value, key in item.branches
					if value.current
						current_branch = value.name
					branches[key]=
						name: value.name
						url: "/suites/#{item.id}/change_branch/#{value.name}"

				res.render 'suites/view',
					title: item.name
					main_menu: items
					item: item
					logged_in: !!req.user
					dropdown:
						branch:
							title: current_branch
							items: branches

	edit: (req, res) ->
		url = "/suites/#{req.params.id}"
		Suite.get_by_id req.params.id, (err, item) ->
			if (req.body)
				_.each req.body, (value, key) ->
					item[key] = value

				item.save ->
					req.flash 'success', 'Successfully saved settings.'
					res.redirect url
			else
				res.redirect url

	load: (req, res) ->
		app = @app
		Suite.get_by_id req.params.id, (err, item) ->
			app.set 'network_offset', item.network_offset
			app.engine('html', require('ejs').renderFile);
			res.render "../../suites/#{req.params.id}/index.html"

	index: (req, res) ->
		Suite.all (err, items) ->
			res.render 'suites/index',
				logged_in: !!req.user
				main_menu: items

	change_branch: (req, res) ->
		Suite.get_by_id req.params.id, (err, suite) ->
			suite.change_branch req.params.name, ->
				res.redirect "/suites/#{req.params.id}"

module.exports = Suites