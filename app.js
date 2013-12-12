
/**
 * Module dependencies.
 */

require('coffee-script');
require('express-namespace');


var express = require('express')
  , http = require('http')
  , path = require('path')
  , passport = require('passport');

var app = module.exports = express();

// all environments
app.set('port', process.env.PORT || 3000);
app.set('views', __dirname + '/app/views');
app.set('view engine', 'jade');
app.use(express.favicon());
app.use(express.logger('dev'));
app.use(express.bodyParser());
app.use(express.methodOverride());
app.use(require('connect-assets')());

app.use(express.cookieParser('5u1te'));
app.use(express.session({ cookie: { maxAge: 600000 }})); // 10 minutes
app.use(passport.initialize());
app.use(passport.session());

// Helpers
app.use(function(req, res, next){
	var session = req.session;
	var messages = session.messages || (session.messages = []);

	req.flash = function(level, message) {
		messages.push([level, message]);
	}
	res.locals = require('./app/helpers/layout_helper')(req);
	next();
});

app.use(app.router);

app.use(express.static(path.join(__dirname, 'public')));
app.set('root_folder', __dirname);

if (!app.get('env')) {
	app.set('env', 'development');
}

// development only
if ('development' == app.get('env')) {
  app.use(express.errorHandler());
}

if ('test' == app.get('env')) {
  app.set('port', 3001);
}

// Routes
require('./app/routes')(app);

app_server = http.createServer(app).listen(app.get('port'), function(){
  console.log('Express server listening on port ' + app.get('port'));
});
