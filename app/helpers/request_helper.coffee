_ = require 'underscore'
URI = require 'URIjs'

request_helper = (app) ->

	expire_header: (req, res, next) ->
		if req.method == 'GET'
			switch app.get('expire_headers')
				when 'one_year' then age = 31536000
				when 'one_month' then age = 2592000
				when 'one_day' then age = 86400
				when 'one_minute' then age = 60
				else age = 0
			res.setHeader "Cache-Control", "public, max-age=" + age
			res.setHeader "Expires", new Date(Date.now() + age * 1000).toUTCString()
			next()
		else
			next()

	offset: (req, res, next) ->
		if req.method == 'GET'
			network_offset = app.get('network_offset')					# get network offset - settings
			suffix = URI(req.url).suffix()								# get the suffix
			switch suffix												# get type from suffix
				when 'png', 'jpg', 'gif' then type = 'img'
				when 'ttf', 'woff', 'eof', 'svg' then type = 'font'
				else type = suffix
			offset = _.find network_offset, (value, key) -> key == type # extract the offset of the current type

			if offset
				setTimeout(next, offset)
			else
				next()
		else
			next()

module.exports = request_helper