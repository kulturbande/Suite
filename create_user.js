require('coffee-script');

if (process.argv.length == 5) {
	var args = process.argv;
	var User = require('./app/models/user');
	process.env.NODE_ENV = args[4];

	var user = new User({name: args[2].trim(), password: args[3].trim()});
	user.save(function() {
		console.log("Created the user " + user.name + "!\n");
		process.exit(0);
	});
} else {
	console.log("You need to have a username, a password, and the environment to create a new user.");
	console.log("Example:\tnode create_user.js username password development\n");
}