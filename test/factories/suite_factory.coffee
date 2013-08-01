Suite = require '../../app/models/suite'

SuiteFactory =

	createSeveral: (callback) ->
		networkSuite =
			path_name: 'network'
		renderSuite =
			path_name: 'render'
		suiteAttributes = [networkSuite, renderSuite]
		createOne = @createOne
		runSequentially = (item, otherItems...) ->
			createOne item, ->
				if otherItems.length
					runSequentially otherItems...
				else
					callback()
		runSequentially suiteAttributes...

	createOne: (attributes, callback) ->
		suite = new Suite(attributes)
		suite.save (err, suite) ->
			callback err, suite

module.exports = SuiteFactory