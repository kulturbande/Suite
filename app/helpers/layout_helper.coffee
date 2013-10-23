layout_helper = (req) ->
	capitalize: (name) ->
		name.slice(0,1).toUpperCase() + name.slice(1)

	messages: () ->
		messages = req.session.messages
		req.session.messages = []
		messages


module.exports = layout_helper