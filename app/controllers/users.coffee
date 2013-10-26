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
		app = @app
		app.configure ->
			app.use passport.initialize()
			app.use passport.session()

		strategy = new LocalStrategy (username, password, done) ->
			console.log(username+" "+password)
			user = {
				id: username,
				name: username
			}
			done(null, user)

		passport.use strategy

		passport.serializeUser (user, done) ->
			done(null, user.id)

		passport.deserializeUser (id, done) ->
			# User.findById(id, function(err, user) {
			# 	done(err, user);
			# });

module.exports = Users