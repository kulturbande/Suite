
class GitParser

	@branch: (text) ->
		branches = []
		text.split('\n').forEach (entry) ->
			if entry.trim() == ''
				return
			branch =
				name: entry.slice(2)
				current: entry[0] == '*'
			branches.push branch
		branches

module.exports = GitParser