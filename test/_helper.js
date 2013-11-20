process.env.NODE_ENV = 'test';

require('coffee-script');
require(__dirname + '/assert-extra');

assert 	= require('assert');
request = require('request');
request_agent = (require('superagent')).agent();
app 	= require('../app');

// global variables
url 	= "http://localhost:"+app.get('port');