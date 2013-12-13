suites_controller = new require('./controllers/suites')
users_controller = new require('./controllers/users')

routes = (app) ->
	request_helper = require('./helpers/request_helper')(app)

	# offset middleware
	app.use '/load_suite', request_helper.offset
	app.use '/load_suite', request_helper.expire_header

	suites = new suites_controller app
	users = new users_controller app

module.exports = routes