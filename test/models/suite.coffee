assert 			= require 'assert'
fs 				= require 'fs'
path 			= require 'path'
redis			= require('redis').createClient()
Suite 			= require '../../app/models/suite'
SuiteFacotry 	= require '../factories/suite_factory'

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

		describe "generate id", ->
			it "default Id", ->
				assert.equal suite.id, 'network'

	describe 'persistence', ->
		it 'builds a key for redis', ->
			assert.equal Suite.key(), 'Suite:test'

		it 'has a main folder', ->
			assert.match Suite.main_folder(), '\/suites'

		describe 'read repository', ->
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
				suite = new Suite {path_name: 'render'}
				suite.save ->
					done()
			it 'returns a Suite - object', ->
				assert.instanceOf suite, Suite

		describe 'get one', ->
			describe 'existing record', ->
				suite = null
				before (done) ->
					SuiteFacotry.createOne {path_name: 'render'}, () ->
						Suite.getById 'render', (err, _suite) ->
							suite = _suite
							done()
				it 'returns a Suite - object', ->
					assert.instanceOf suite, Suite
				it 'fetches the correct object', ->
					assert.equal suite.name, 'Render'

			describe 'non-existing record', ->
				it 'returns an error', (done) ->
					Suite.getById 'network', (err, json) ->
						assert.equal err.message, "Suite 'network' could not be found."
						done()

		describe 'get all', ->
			suites = null
			before (done) ->
				SuiteFacotry.createSeveral ->
					Suite.all (err, _suites) ->
						suites = _suites
						done();
			it 'retrieves all pies', ->
				assert.equal suites.length, 2

		describe 'delete', -> 
			before (done) ->
				SuiteFacotry.createOne {path_name:'render'}, done
			it 'is removed from the database', (done) ->
				Suite.getById 'render', (err, suite) ->
					suite.destroy (err) ->
						Suite.getById 'render', (err) ->
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
			), /Can\'t find or read that folder/

	describe 'synchronize', ->
		describe 'without database entries', ->
			synchronized_entries = []
			before (done) ->
				Suite.synchronize (err, _entries) ->	
						synchronized_entries = _entries
						done()
			it 'has two entries', (done) ->
				Suite.all (err, suites) ->
					assert.equal suites.length, 2
					done()
			it 'should find two suites', ->
				assert.equal synchronized_entries.length, 2
			
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
					assert.equal entries.length, 1
					assert.equal entries[0].path_name, 'network'
					Suite.all (err, suites) ->
						assert.equal suites.length, 2
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
			it 'has two entries', ->
				assert.equal suites.length, 2

		afterEach ->
			redis.del Suite.key()
					


