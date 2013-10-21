suites_controller = new require('./controllers/suites')

routes = (app) ->
	request_helper = require('./helpers/request_helper')(app)

	# offset middleware
	app.use '/load_suite', request_helper.offset

	suites = new suites_controller app

module.exports = routes