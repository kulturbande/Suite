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

	view: (req, res) ->
		Suite.all (err, items) ->
			Suite.get_by_id req.params.id, (err, item) ->
				branches = []
				current_branch = ''
				for value, key in item.branches
					if value.current
						current_branch = value.name
					branches[key] = value.name

				res.render 'suites/view',
					title: item.name
					main_menu: items
					item: item
					logged_in: !!req.user
					branch:
						current_branch: current_branch
						branches: branches

	edit: (req, res) ->
		url = "/suites/#{req.params.id}"
		Suite.get_by_id req.params.id, (err, item) ->
			if (req.body)
				_.each req.body, (value, key) ->
					item[key] = value

				item.save ->
					if item.branch && item.branch != item.current_branch()
						item.change_branch item.branch, ->
							req.flash 'success', 'Successfully saved settings and change branch.'
							res.redirect url
					else
						req.flash 'success', 'Successfully saved settings.'
						res.redirect url
			else
				res.redirect url

	load: (req, res) ->
		app = @app
		Suite.get_by_id req.params.id, (err, item) ->
			app.set 'network_offset', item.network_offset
			app.disable 'view cache',
			app.engine('html', require('ejs').renderFile);
			res.render "../../suites/#{item.path_name}/#{item.file_name}"

	index: (req, res) ->
		Suite.all (err, items) ->
			res.render 'suites/index',
				logged_in: !!req.user
				main_menu: items

module.exports = Suites