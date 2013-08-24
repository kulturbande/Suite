async = require 'async'
child_process = require 'child_process'
GitParser = require './git/git_parser'

class Git

	constructor: (path) ->
		@path = path

	branch: (callback) ->
		@_git 'branch', (data) ->
			branches = GitParser.branch(data)
			callback(branches)

	_git: (command, callback)->
		command = 'git ' + command
		path = @path
		data =
			cwd: path
			maxBuffer: 1024 * 1024 * 10
		process = child_process.exec command, data, (error, stdout, stderr) ->
			if error
				throw new Error 'Could not process git command!'
			callback(stdout)


module.exports = Git