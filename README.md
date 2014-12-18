# DevStack Playground
### This project is in __PRE-ALPHA__ state! Do not use it by now!

This repo contains settings for our DevStack playground.

First of all you need [Docker](https://www.docker.com/) to start containers. 
To have a full OpenStack environment, you have to pull the two nodes.  

### Pull

```
	$ docker pull affear/os_controller:latest
	$ docker pull affear/os_compute:latest
```

### Configure IPs
Our configuration works with fixed IPs, so:

Install pipework:

```
	$ git clone git@github.com:jpetazzo/pipework.git
	$ mv pipework/ pipework_dir
	$ mv pipework_dir/pipework scripts
	$ rm -rf pipework_dir/
```

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
Use pipework for the controller:

```
	$ HANDLER=$(docker run -d affear/os_controller:latest)
	$ ./scripts/pipework <BRIDGE_NAME> $HANDLER 42.42.255.254/16
```

No need to use pipework for compute nodes:

```
	$ docker run -privileged -t -i affear/os_compute:latest
	$ docker run -privileged -t -i affear/os_compute:latest
	$ docker run -privileged -t -i affear/os_compute:latest
	$ docker run -privileged -t -i affear/os_compute:latest
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