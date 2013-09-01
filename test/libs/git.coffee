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
				done()

		it 'should more than one branch', ->
			assert.equal branches.length > 1, true
		it 'should get name and a current flag', ->
			branch = branches[0]
			assert.isNotNull branch.name
			assert.isSet branch.current

	describe 'checkout', ->
		git = null
		before (done) ->
			git = new Git path.join(__dirname, '../../suites/network')
			done()

		it 'should change the branch to develop', (done) ->
			git.checkout 'develop', ->
				git.branch (branches)->
					current_branch = _.find branches, (entry) -> entry.current
					assert.equal current_branch.name, 'develop'
					done()

		it 'should change the branch to master', (done) ->
			git.checkout 'master', ->
				git.branch (branches)->
					current_branch = _.find branches, (entry) -> entry.current
					assert.equal current_branch.name, 'master'
					done()