_ = require 'underscore'
URI = require 'URIjs'

request_helper = (app) ->

	expire_header: (req, res, next) ->
		if req.method == 'GET'
			switch app.get('expire_headers')
				when 'one_year' then age = 31536000
				when 'one_month' then age = 2592000
				when 'one_day' then age = 86400
				else age = 0
			res.setHeader "Cache-Control", "public, max-age=" + age
			next()
		else
			next()

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