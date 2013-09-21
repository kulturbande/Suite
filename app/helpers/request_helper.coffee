request_helper = () ->

	offset: (req, res, next) ->
		
		if (req.method == 'GET' && req.url == '/img/test.jpg')
			setTimeout(next, 5000)
		else
			next()

module.exports = request_helper