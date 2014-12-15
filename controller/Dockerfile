FROM phusion/baseimage:latest
MAINTAINER affearteam

# expose ports for OpenStack services (default ports from guide):
# 5000, 35357 -> keystone
# 9292, 9191 -> glance
# 8777 -> ceilometer
# 8773, 8774, 8775 -> nova
# 8000, 8003, 8004 -> heat
#
# 3306 -> MySQL
# 5672 -> RabbitMQ
EXPOSE 5000 35357 9292 9191 8777 8773 8774 8775 8000 8003 8004 3306 5672

# Enable insecure key for ssh
RUN /usr/sbin/enable_insecure_key

# solve errors on non interactive mode
# https://github.com/phusion/baseimage-docker/issues/58
RUN echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections

# create dir for temporary files
RUN sudo mkdir /stack_temp

################################################
# From https://github.com/ewindisch/dockenstack/blob/openstack-ci/dockenstack/Dockerfile:
# Install requirements for devstack (easier to commit)
#
# update, then install some utils
RUN apt-get update && apt-get install -y sed git socat curl sudo apt-transport-https vim wget net-tools python
# Extra requirements for pip-requirements
# (thanks to http://terriyu.info/blog/posts/2013/07/installing-devstack-ceilometer/, also)
RUN apt-get install -qqy libffi-dev libkrb5-dev \
		pkg-config libnspr4-dev libxml2-dev libxslt1-dev \
		libvirt-dev

# Configure and install MySQL
RUN echo 'mysql-server mysql-server/root_password password pwstack' | debconf-set-selections; \
		echo 'mysql-server mysql-server/root_password_again password pwstack' | debconf-set-selections; \
		apt-get -qqy install mysql-server

# Install RabbitMQ
RUN apt-get -qqy install rabbitmq-server

# get images for glance
RUN mkdir -m 755 -p /opt/cirros_image
WORKDIR /opt/cirros_image
RUN umask 022; \
		wget --progress=dot:mega \
				 http://35d32e50e9d5a9dddd5f-7400ae4d3b198289837a7cdf652ffd5a.r94.cf1.rackcdn.com/cirros.img

WORKDIR /

# Install devstack scripts
RUN git clone https://github.com/openstack-dev/devstack /devstack

# Install prereq packages.
RUN /devstack/tools/install_prereqs.sh

# Install/configure dbus for libvirt (only needed if using libvirt drivers, not docker)
# creates symlink to /usr/bin due to bug in saucy's init script for dbus.
RUN apt-get install -q -y dbus; \
		ln -s /bin/dbus-daemon /usr/bin/dbus-daemon

# Mask python-six because the apt package can conflict with the pypi version.
RUN apt-get remove -q -y python-six

# python-pip just became collatoral damage.  reinstall it.
RUN apt-get install -q -y python-pip

# Install six from pip before getting from global-requirements (due to bugs...)
RUN pip install six

# Install all pip requirements
RUN wget https://raw.github.com/openstack/requirements/master/global-requirements.txt -O /stack_temp/global-requirements.txt
# Remove marconi and zaqar client due to confilct in str opts.
RUN sed '/marconiclient/d' /stack_temp/global-requirements.txt
RUN sed '/zaqarclient/d' /stack_temp/global-requirements.txt
RUN pip install -r /stack_temp/global-requirements.txt
# be really sure that marconi and zaqar aren't installed
RUN pip uninstall -y python-marconiclient
RUN pip uninstall -y python-zaqarclient
# thanks to https://github.com/ewindisch/dockenstack/blob/openstack-ci/dockenstack/localrc
##############################################################

# add localrc to devstack's root dir
ADD local.conf /devstack/

######################################
# Brace yourself, ./stack.sh is coming:
# devstack user will be 'stack'
ENV STACK_USER stack
# devstack user home will be /devstack/
ENV DEST /devstack
ENV HOME /devstack
# create stack user using the script given by devstack
RUN ./devstack/tools/create-stack-user.sh
# change ownership of folders
RUN sudo chown -R $STACK_USER:$STACK_USER /devstack
RUN sudo chown -R $STACK_USER:$STACK_USER /stack_temp
# log as STACK_USER and cd to devstack/
USER $STACK_USER
WORKDIR devstack

# copy all daemons scripts
RUN sudo mkdir /daemons
ADD lib /daemons
ADD shared/copy_script /stack_temp
RUN /bin/sh -c "/stack_temp/copy_script"

# edit /etc/hosts
RUN sudo echo "127.0.0.1 localhost" > /etc/hosts
RUN sudo echo "42.42.255.254 controller" >> /etc/hosts