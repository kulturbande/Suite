# Suite

A performance suite - compare different revisions of your web page

## Installation

Following instruction show the installation with Ubuntu. It should fairly easy to install the package on other operation systems.

### Necessary Packages

There core technologies are necessary to install the application. Node.js as the runtime environment, Redis as Storage and Git to use the suite - submodules. It is fairly easy to install redis and git in a not to old version with ```apt-get```.


	sudo apt-get install git
	sudo apt-get install redis-server


The ```nodejs``` package use the old 0.6.x version that fits not to the requirement of that application. So it is necessary to use an other [approach](https://github.com/joyent/node/wiki/Installing-Node.js-via-package-manager):

	sudo apt-get update
	sudo apt-get install -y python-software-properties python g++ make
	sudo add-apt-repository -y ppa:chris-lea/node.js
	sudo apt-get update
	sudo apt-get install nodejs

### Setup Application

All necessary packages are prepared now and the application itself needs to install on the server. For that you need to clone the git repository, install all submodules, and run npm to install all node.js - packages:

	git clone git@github.com:kulturbande/Suite.git
	cd Suite
	git submodule update
	npm install

Copy the _aws.json to aws.json if you want to use Amazon S3

	cp suites/_aws.json suites/aws.json

### Start Server

The redis - server needs to be started first. This can be easily done by running ```redis-server /path/to/redis.conf```. In case of Ubuntu it should be:

	redis-server /etc/redis/redis.conf

To run the node.js server only use:

	npm start

The suite should now run on the port 3000. This is not always desired and you cal also start the application with another port:

	PORT=80 node app.js

Please keep in mind that other applications maybe listen to that port and it will cause conflicts. It is also not that desirable to have the node.js process open the whole time. You can use ```screen``` to place the node.js - process into a screen - session:

	screen
	npm start

Press ```ctrl + A + D``` to go back to the parent window. The application should now run in a screen session.

### Create User

The application has a dead simple login management and need at least one user to be usable:

	node create_user.js username password environment

If you run ```npm start``` the environment is _production_ and if you use the ```bin/devserver``` bash script it is _development_.

### Setup production environment

The current application isn't created to run permanent in a production - environement. There are several ways to run node.js through *nginx* or *apache*. At the moment the current approch is still the default node.js - server:

	sudo PORT=80 ENV=production node app.js

*If you run the application on an UNIX environment you need to run it as 'root' if your port is under 1024*

## Create new suite

Add you own suite to the *suites* - folder. It needs to be a git submodule to work smoothly with these application. If you project is hosted on a public available service you can clone your repository to the project:

	git clone <url_of_your_git_repository> suites/<folder_name>

## License

The MIT License (MIT)

Copyright (c) 2014 Sascha Karnatz

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.





