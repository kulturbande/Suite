suites_controller = new require('./controllers/suites')

routes = (app) ->
	# offset middleware
	# app.use (req, res, next) ->
	# 	if (req.method == 'GET' && req.url == '/img/test.jpg')
	# 		setTimeout(next, 5000)
	# 	else
	# 		next()

	suites = new suites_controller app

module.exports = routes