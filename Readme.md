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

## Create new suite

### Clone a given example


	git clone https://github.com/kulturbande/TestCase-Network.git suites/network


## Create User

The application has a dead simple login management and need at least one user to be usable:


	node create_user.js username password


