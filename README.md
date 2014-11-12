# DevStack Playground

This repo contains settings for our DevStack playground.

First of all you need [Vagrant](https://www.vagrantup.com/) to start VMs. 
Then, create a vagrant box:

```
	$ vagrant box add ubuntu/trusty64 --name ubuntu-14.04-x64
```

Then:

```
	$ git clone git@github.com:affear/devstack-playground.git
	$ cd devstack-playground
	$ vagrant up
```

And then enjoy!