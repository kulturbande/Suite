assert 	= require 'assert'
Suite 	= require '../../app/models/suite'

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
		it 'builds a key for redis'

		describe 'save', ->
			it 'returns a Suite - object'

		describe 'get one', ->
			describe 'existing record', ->
				it 'returns a Suite - object'
				it 'fetches the correct object'
			describe 'non-existing record', ->
				it 'returns an error'

		describe 'get all', ->
			it 'retrieves all pies'

		describe 'delete', ->
			it 'is removed from the database'

	describe 'validation', ->
		it 'requires a path_name'

