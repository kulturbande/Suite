string_helper = () ->

	capitalize: (name) ->
		name.slice(0,1).toUpperCase() + name.slice(1)

module.exports = string_helper