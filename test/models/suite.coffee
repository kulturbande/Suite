assert 			= require 'assert'
fs 				= require 'fs'
path 			= require 'path'
_ 				= require 'underscore'
redis			= require('redis').createClient()
Suite 			= require '../../app/models/suite'
SuiteFacotry 	= require '../factories/suite_factory'
Git 			= require '../../app/libs/git'

describe 'Suite', ->

	describe 'create', ->
		suite = null
		before (done) ->
			suite = new Suite {path_name: 'network'}
			done()
		it "sets name", ->
			assert.equal suite.name, 'Network'
		it "sets path", ->
			assert.match suite.path, '\/suites\/network'
		it "sets git repository", ->
			assert.isNotNull suite.repository
		it "sets network_offset - value", ->
			assert.equal suite.network_offset.img, 0
			assert.equal suite.network_offset.css, 0
			assert.equal suite.network_offset.js, 0

		describe "generate id", ->
			it "default Id", ->
				assert.equal suite.id, 'network'

	describe 'persistence', ->
		it 'builds a key for redis', ->
			assert.equal Suite.key(), 'Suite:test'

		it 'has a main folder', ->
			assert.match Suite.main_folder(), '\/suites'

		describe 'read folder', ->
			file = path.join(Suite.main_folder(), 'bar')
			folder = path.join(Suite.main_folder(), 'foo_bar')
			before (done) ->
				fs.writeFile file, 'bar', (err) ->
					fs.mkdir folder, (err) ->
						done()
			it 'throws an expetion if no file/folder is available', ->
				assert.throws (->
					new Suite {'path_name': 'foo'}
				), Error
			it 'throws an expetion if no folder is available', ->
				assert.throws (->
					new Suite {'path_name': 'bar'}
				), Error
			after (done) ->
				fs.unlink file, (err) ->
					fs.rmdir folder, (err) ->
						done()

		describe 'save', ->
			suite = null
			before (done) ->
				suite = new Suite
					path_name: 'render'
					network_offset:
						foo: 300
						bar: 200
				suite.save ->
					done()
			it 'returns a Suite - object', ->
				assert.instanceOf suite, Suite
			it 'has the correct network offset', ->
				assert.equal suite.network_offset.foo, 300
				assert.equal suite.network_offset.bar, 200

		describe 'get one', ->
			describe 'existing record', ->
				suite = null
				before (done) ->
					SuiteFacotry.createOne {path_name: 'render'}, () ->
						Suite.get_by_id 'render', (err, _suite) ->
							suite = _suite
							done()
				it 'returns a Suite - object', ->
					assert.instanceOf suite, Suite
				it 'fetches the correct object', ->
					assert.equal suite.name, 'Render'

			describe 'non-existing record', ->
				it 'returns an error', (done) ->
					Suite.get_by_id 'network', (err, json) ->
						assert.equal err.message, "Suite 'network' could not be found."
						done()

		describe 'get all', ->
			suites = null
			before (done) ->
				SuiteFacotry.createSeveral ->
					Suite.all (err, _suites) ->
						suites = _suites
						done();
			it 'retrieves all suites', ->
				assert.equal suites.length, 3

		describe 'delete', ->
			before (done) ->
				SuiteFacotry.createOne {path_name:'render'}, done
			it 'is removed from the database', (done) ->
				Suite.get_by_id 'render', (err, suite) ->
					suite.destroy (err) ->
						Suite.get_by_id 'render', (err) ->
							assert.equal err.message, "Suite 'render' could not be found."
							done()

		afterEach ->
			redis.del Suite.key()

	describe 'validation', ->
		it 'requires a path_name', ->
			assert.throws (->
				new Suite()
			), /provide a path_name/

		it 'requires a valid folder name', ->
			assert.throws (->
				new Suite {'path_name': 'foo'}
			), /Can\'t find or read [\w\/]*suites\/foo folder/

	describe 'synchronize', ->
		describe 'without database entries', ->
			synchronized_entries = []
			before (done) ->
				Suite.synchronize (err, _entries) ->
					synchronized_entries = _entries
					done()
			it 'has three entries', (done) ->
				Suite.all (err, suites) ->
					assert.equal suites.length, 3
					done()
			it 'should find three suites', ->
				assert.equal synchronized_entries.length, 3

		describe 'with one database entry', ->
			beforeEach (done) ->
				SuiteFacotry.createOne {path_name: 'render'}, done
			it 'should find one previous suite', (done) ->
				Suite.all (err, suites) ->
					assert.equal suites.length, 1
					assert.equal suites[0].path_name, 'render'
					done()
			it 'should find another suite', (done) ->
				Suite.synchronize (err, entries) ->
					assert.equal entries.length, 2
					assert.equal entries[0].path_name, 'compute'
					Suite.all (err, suites) ->
						assert.equal suites.length, 3
						done()

		describe 'with all entries', ->
			suites = []
			before (done) ->
				SuiteFacotry.createSeveral ->
					Suite.all (err, _suites) ->
						suites = _suites
						done()
			it 'has nothing to do', (done) ->
				Suite.synchronize (err, entries) ->
					assert.equal entries.length, 0
					done()
			it 'has three entries', ->
				assert.equal suites.length, 3

			it 'should update the repository', ->
				assert.equal suites.length, 3

		afterEach ->
			redis.del Suite.key()

	describe 'git', ->
		suite = null
		before (done) ->
			Suite.synchronize (err, _entries) ->
				Suite.get_by_id 'network', (err, _suite) ->
					suite = _suite
					done()

		describe 'branches', ->
			it 'should have branches', ->
				assert.equal suite.branches.length > 1, true

			it 'should change branch to master', (done) ->
				suite.change_branch 'master', ->
					current_branch = _.find suite.branches, (entry) -> entry.current
					assert.equal current_branch.name, 'master'
					done()

			it 'current branch is master', ->
				assert.equal suite.current_branch(), 'master'

			it 'should change branch to develop', (done) ->
				suite.change_branch 'develop', ->
					current_branch = _.find suite.branches, (entry) -> entry.current
					assert.equal current_branch.name, 'develop'
					done()

			it 'current branch is develop', ->
				assert.equal suite.current_branch(), 'develop'
