_ = require 'underscore'
URI = require 'URIjs'

request_helper = (app) ->

	offset: (req, res, next) ->
		if req.method == 'GET'
			network_offset = app.get('network_offset')					# get network offset - settings
			type = URI(req.url).directory().replace(/^\//, '')			# get the directory which is named by the type of the document
			offset = _.find network_offset, (value, key) -> key == type # extract the offset of the current type

			if offset
				setTimeout(next, offset)
			else
				next()
		else
			next()

module.exports = request_helper