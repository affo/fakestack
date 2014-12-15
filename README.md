# DevStack Playground
### This project is in __PRE-ALPHA__ state! Do not use it by now!

This repo contains settings for our DevStack playground.

First of all you need [Docker](https://www.docker.com/) to start LXCs. 
To have a full OpenStack environment, you have to pull the two nodes.  
You can run as many compute nodes as you need! 

### To build
Thanks to https://github.com/docker/docker/issues/6094

```
	$ cd controller # or compute
	$	tar -czh . | docker build - # tar follows `shared` symlink
``` 

### To fetch

```
	$ sudo docker pull affear/os_controller
	$ sudo docker pull affear/os_compute
	$ sudo docker run affear/os_controller
	$ sudo docker run affear/os_compute
	$ sudo docker run affear/os_compute
	$ sudo docker run affear/os_compute
	$ sudo docker run affear/os_compute
	...
```

And here it is, your OpenStack testing environment!

Install pipework:

```
	$ git clone git@github.com:jpetazzo/pipework.git
	$ mv pipework/ pipework_dir
	$ mv pipework_dir/pipework .
	$ rm -rf pipework_dir/
```

If needed, create your own bridge (in our case `osbr`) as described in [Docker doc](https://docs.docker.com/articles/networking/#building-your-own-bridge)

Use pipework:

```
	$ HANDLER=$(docker run -d affear/os_controller:test)
	$ ./pipework osbr $HANDLER 42.42.255.254/16
```