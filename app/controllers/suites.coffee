Suite = require '../models/suite'
path = require 'path'
express = require 'express'
connect = require 'connect'
_ = require 'underscore'

class Suites
	app = null
	static_path = '/load_suite'
	compression_enabled = false

	constructor: (app) ->
		@app = app
		Suite.synchronize (err, _suites) ->
			Suite.all (err, suites) ->
				suites.forEach (suite) ->
					if suite.compression != 'disabled'
						enable_compression suite
					app.use static_path, connect.static(path.join(__dirname, "../../suites/#{suite.path_name}"))
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

		app.namespace '/load_suite/:id', ->
			app.get '/', (req, res) ->
				_self.load_suite(req, res)

			app.post '/add', (req, res) ->
				_self.add_data_to_suite(req, res)

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
					enable_compression item
					if item.branch && item.branch != item.current_branch()
						item.change_branch item.branch, ->
							req.flash 'success', 'Successfully saved settings and change branch.'
							res.redirect url
					else
						req.flash 'success', 'Successfully saved settings.'
						res.redirect url
			else
				res.redirect url

	load_suite: (req, res) ->
		app = @app

		Suite.get_by_id req.params.id, (err, item) ->
			if err
				res.redirect "/suites"
				return
			app.set 'network_offset', item.network_offset
			app.set 'expire_headers', item.expire_headers
			app.disable 'view cache',
			app.engine 'html', require('ejs').renderFile

			res.render "../../suites/#{item.path_name}/#{item.file_name}",
				branch_data: item.get_branch_data()

	add_data_to_suite: (req, res) ->
		result =
			success: false
			data: []

		Suite.get_by_id req.params.id, (err, item) ->
			if err
				res.json(500, result)
				return

			item.add_branch_data req.body
			item.save (err, data) ->
				result.success = true
				result.data = req.body
				res.json(result)

	index: (req, res) ->
		Suite.all (err, items) ->
			res.render 'suites/index',
				logged_in: !!req.user
				main_menu: items

	enable_compression = (suite) ->
		# add middleware on top of the app stack - this is more or less a hack!
		# normally you would add the 'app.use(connect.compress)' on top of the app.js
		if !compression_enabled && suite.compression == 'enabled'
			compression_enabled = true
			app.stack.splice(2, 0, {route: static_path, handle: connect.compress()})
		if compression_enabled && suite.compression == 'disabled'
			compression_enabled = false
			app.stack.splice(2, 1)


module.exports = Suites