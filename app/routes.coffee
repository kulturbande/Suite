suites_controller = new require('./controllers/suites')

routes = (app) ->
	suites = new suites_controller app

module.exports = routes