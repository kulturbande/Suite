Pie = require '../models/suite'
suites = (app) ->
	main_menu = ['network', 'render']

	# redirect to main route
	app.get '/', (req, res) ->
		res.redirect '/suites'

	app.namespace '/suites', ->
		app.get '/', (req, res) ->
			res.render 'suites/index',
				main_menu: main_menu

		app.get '/:name', (req, res) ->
			# git.repo "#{__dirname}/../../suites/#{req.params.name}/.git", (error, repository) ->
			# 	if error
			# 		throw error

				# git.tree repository.rawRepo
				# git.tree.walk()
				# app.on 'entry', (error, entry) ->
				# 	console.log entry
				# repository.branch 'master', (error, branch) ->
				# 	if error
				# 		throw error
				# 	console.log branch
			res.render 'suites/view',
				title: req.params.name
				main_menu: main_menu
				name: req.params.name

		app.get '/:name/load', (req, res) ->
			app.engine('html', require('ejs').renderFile);
			res.render "../../suites/#{req.params.name}/index.html"
module.exports = suites