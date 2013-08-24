path = require 'path'
_ = require 'underscore'
Git = require '../../app/libs/git'

describe 'Git', ->

	describe 'branch', ->
		branches = null
		before (done) ->
			git = new Git path.join(__dirname, '../../suites/network')
			git.branch (_branches)->
				branches = _branches
				done();

		it 'should more than one branch', ->
			assert.equal branches.length > 1, true
		it 'should get name and a current flag', ->
			branch = branches[0]
			assert.equal branch.name != null, true
			assert.equal branch.current == true || branch.current == false, true