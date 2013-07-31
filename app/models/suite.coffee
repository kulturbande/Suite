path = require 'path'
class Suite

	constructor: (attributes) ->
		@[key] = value for key, value of attributes
		if @path_name 
			unless @name
				@name = @path_name.slice(0,1).toUpperCase() + @path_name.slice(1)
			unless @id
				@id = @path_name.replace /\s/g, '-'
			@path = path.join(__dirname, '../../suites', @path_name)
		@

module.exports = Suite