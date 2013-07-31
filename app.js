
/**
 * Module dependencies.
 */

require('coffee-script');
require('express-namespace');


var express = require('express')
  , http = require('http')
  , path = require('path');

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

// Helpers
app.use(function(req, res, next){
  res.locals = require('./app/helpers/string_helper')();
  next();
});

app.use(app.router);
app.use(express.static(path.join(__dirname, 'public')));
app.set('root_folder', __dirname);

// development only
if ('development' == app.get('env')) {
  app.use(express.errorHandler());
}

if ('test' == app.get('env')) {
  app.set('port', 3001);
}

// Routes
require('./app/controllers/suites')(app);

http.createServer(app).listen(app.get('port'), function(){
  console.log('Express server listening on port ' + app.get('port'));
});
