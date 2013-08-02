assert 			= require 'assert'
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
			it "replace whitespace", ->
				suite = new Suite {path_name: 'network 123'}
				assert.equal suite.id, 'network-123'

	describe 'persistence', ->
		it 'builds a key for redis', ->
			assert.equal Suite.key(), 'Suite:test'

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

