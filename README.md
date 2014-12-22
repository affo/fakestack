# DevStack Playground
### This project is in __PRE-ALPHA__ state! Do not use it by now!

This repo contains settings for our DevStack playground.

First of all you need [Docker](https://www.docker.com/) to start containers. 
To have a full OpenStack environment, you have to pull the two nodes.  

### Pull

```
	$ docker pull affear/controller:latest
	$ docker pull affear/compute:latest
```

### Configure IPs
Create your own bridge as described in [Docker doc](https://docs.docker.com/articles/networking/#building-your-own-bridge).

Or use the script provided:

```
	$ ./scripts/create_br.sh <BRIDGE_NAME>
```

Edit `/etc/default/docker` to have:

```
	DOCKER_OPTS="-s devicemapper -b <BRIDGE_NAME>"
```

And then:

```
	$ sudo service docker restart
```

### Run
Controller:

```
	$ docker run --privileged=true -t -i -h controller affear/controller:latest
```

Compute nodes:

```
	$ docker run --privileged=true -t -i affear/compute:latest
	$ docker run --privileged=true -t -i affear/compute:latest
	$ docker run --privileged=true -t -i affear/compute:latest
	$ docker run --privileged=true -t -i affear/compute:latest
	... # as many as you want(can)
```

And here it is, your OpenStack testing environment!

### Build
(the example is for controller, but it is the same for compute)

```
	$ git clone https://github.com/affear/fakestack.git
	$ cd fakestack/controller
	$ tar -czh . | docker build -t <TAG> -
```