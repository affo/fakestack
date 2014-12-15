# DevStack Playground
### This project is in __PRE-ALPHA__ state! Do not use it by now!

This repo contains settings for our DevStack playground.

First of all you need [Docker](https://www.docker.com/) to start containers. 
To have a full OpenStack environment, you have to pull the two nodes.  
You can run as many compute nodes as you need!

### Pull

```
	$ docker pull affear/os_controller:latest
	$ docker pull affear/os_compute:latest
```

### Install
In this project dir:

```
	$ ./scripts/run_stack.sh affear/os_controller:latest
	$ ./scripts/run_stack.sh affear/os_compute:latest
```

This command will install OpenStack on the given image (some time is required).

### Configure IPs
Our configuration works with fixed IPs, so:

Install pipework:

```
	$ git clone git@github.com:jpetazzo/pipework.git
	$ mv pipework/ pipework_dir
	$ mv pipework_dir/pipework .
	$ rm -rf pipework_dir/
```

Create your own bridge as described in [Docker doc](https://docs.docker.com/articles/networking/#building-your-own-bridge).

Pay attention to add the correct CIDR to the bridge:

```
	$ sudo ip addr add 42.42.0.1/16 dev <BRIDGE_NAME>
```

### Run
Use pipework for the controller:

```
	$ HANDLER=$(docker run -d affear/os_controller:latest)
	$ ./pipework <BRIDGE_NAME> $HANDLER 42.42.255.254/16
```

No need to use pipework for compute nodes:

```
	$ docker run -d affear/os_compute:latest
	$ docker run -d affear/os_compute:latest
	$ docker run -d affear/os_compute:latest
	$ docker run -d affear/os_compute:latest
	$ docker run -d affear/os_compute:latest
	... # as many as you want(can)
```

And here it is, your OpenStack testing environment!