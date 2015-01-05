# FakeStack
### This project is in __ALPHA__ state.

The aim of this project is to create an OpenStack testing environment.  
We used Docker containers instead of virtual machines to obtain more lightweight and reusable components.  
Our aim, in fact, is to have an environment with hundreds of compute nodes.  
We used `nova.virt.fake` because, for our purpose, we are not interested in spawning real virtual machines

### Getting started
First of all you need [Docker](https://www.docker.com/) to start containers. 
To have a full OpenStack environment, you have to run at least two nodes.  

### Configure IPs
Create your own bridge as described in [Docker doc](https://docs.docker.com/articles/networking/#building-your-own-bridge).

Or use the script provided:

```
	$ ./scripts/create_br.sh <BRIDGE_NAME>
```

Edit `/etc/default/docker` to have:

```
	DOCKER_OPTS="-b <BRIDGE_NAME>"
```

And then:

```
	$ sudo service docker restart
```

#### WARNING
It should be necessary to add:

```
	DOCKER_OPTS="-s devicemapper -b <BRIDGE_NAME>"
```

Because of problems with `mysql` service startup (see [this issue](https://github.com/docker/docker/issues/5430)).

We tried both (with or without `devicemapper`) on different servers:   
In one case (running __without__ `devicemapper`) we got `mysql` error on run, but no error on build.  
In the other case (running __with__ `devicemapper`) we got the `devicemapper` error:

```
	Error getting container ... # blablabla
```

on build, but no problem on run.

If you have to run your image, choose the best configuration being aware of this.

### Run
Controller:

```
	$ docker run --privileged=true -tid -h controller --name=ctrl affear/controller:latest
```

Compute nodes:

```
	$ docker run --privileged=true -tid affear/compute:latest
	$ docker run --privileged=true -tid affear/compute:latest
	$ docker run --privileged=true -tid affear/compute:latest
	$ docker run --privileged=true -tid affear/compute:latest
	... # as many as you want(can)
```

And here it is, your OpenStack testing environment!

To attach to a container, run:

```
	$ docker attach <CONTAINER_ID>
```

Remember to exit the shell via `CTRL-pq`. If not you will kill the process!

To run a command:

```
	$ docker exec <CONTAINER_ID> <COMMAND>
```

__NOTES__

* Be aware that the `CMD` in the `Dockerfile` will install OpenStack in the container, so it will take a lot of time to have the container up once you run it. So, avoid `-d` option if you want to see what it is happening.

* Compute containers can run in parallel, but it is important that you wait for the controller to finish OpenStack installation before running compute nodes.

### Build
(the example is for controller, but it is the same for compute).

```
	$ git clone https://github.com/affear/fakestack.git
	$ cd fakestack/controller
	$ tar -czh . | docker build -t <TAG> -
```

__Final note__: _almost all of the commands listed above are available running_ `source fakerc` _._
