suites_controller = new require('./controllers/suites')
users_controller = new require('./controllers/users')

routes = (app) ->
	suites = new suites_controller app
	users = new users_controller app

module.exports = routes