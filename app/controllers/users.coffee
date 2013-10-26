User = require '../models/user'
passport = require('passport')
LocalStrategy = require('passport-local').Strategy

class Users
	app = null

	constructor: (app) ->
		@app = app
		@_configure_authetication()
		@routes()
		@

	routes: ->
		app = @app
		_self = @

		app.namespace '/login', ->
			app.get '/', (req, res) ->
				_self.login_view(req, res)

			app.post '/', passport.authenticate 'local', 
				successRedirect: '/',
				failureRedirect: '/login'
				failureFlash: true

	login_view: (req, res) ->
		res.render 'users/login',
			title: 'Login'

	_configure_authetication: ->
		strategy = new LocalStrategy (username, password, done) ->
			User.authenticate username, passport, (err, user) ->
				done(err, user)

		passport.use strategy

		passport.serializeUser (user, done) ->
			done(null, user.id)

		passport.deserializeUser (id, done) ->
			User.get_by_id id, (err, user) ->
				done err, user

module.exports = Users