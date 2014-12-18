FROM ubuntu:latest
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
# 80 -> Apache2
EXPOSE 8777 8773 8774 8775

# solve errors on non interactive mode
# https://github.com/phusion/baseimage-docker/issues/58
RUN echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections

################################################
# From https://github.com/ewindisch/dockenstack/blob/openstack-ci/dockenstack/Dockerfile:
# Install requirements for devstack
#
# update, then install some utils
RUN apt-get update && apt-get install -y sed git socat curl sudo apt-transport-https vim wget net-tools python
# Extra requirements for pip-requirements
# (thanks to http://terriyu.info/blog/posts/2013/07/installing-devstack-ceilometer/, also)
RUN apt-get install -qqy libffi-dev libkrb5-dev \
		pkg-config libnspr4-dev libxml2-dev libxslt1-dev \
		libvirt-dev

WORKDIR /

# Install devstack scripts from our fork
RUN git clone https://github.com/affear/devstack.git /devstack

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
RUN wget https://raw.github.com/openstack/requirements/master/global-requirements.txt
# Remove marconi and zaqar client due to confilct in str opts.
RUN sed '/marconiclient/d' global-requirements.txt
RUN sed '/zaqarclient/d' global-requirements.txt
RUN pip install -r global-requirements.txt
RUN rm /global-requirements.txt
# be really sure that marconi and zaqar aren't installed
RUN pip uninstall -y python-marconiclient
RUN pip uninstall -y python-zaqarclient
# thanks to https://github.com/ewindisch/dockenstack/blob/openstack-ci/dockenstack/localrc
##############################################################

# add localrc to devstack's root dir
ADD local.conf /devstack/
# add script to reinstall a service (via ssh, hopefully).
# Something like:
#		docker-ssh <image-id> -c "/devstack/reinstall_service.sh nova"
ADD shared/reinstall_service.sh /devstack/
# add command
ADD shared/cmd.sh / 
# edit /etc/hosts
RUN echo "42.42.255.254 controller" >> /etc/hosts

######################################
# Brace yourself, ./stack.sh is coming:
# devstack user will be 'stack'
ENV STACK_USER stack
# devstack user home will be /devstack/
ENV DEST /devstack
ENV HOME /devstack
# create stack user using the script given by devstack
RUN /devstack/tools/create-stack-user.sh
# filename and content MUST match $STACK_USER
ADD shared/stack.sudo /etc/sudoers.d/stack
# change ownership of folders
RUN sudo chown -R $STACK_USER:$STACK_USER /devstack
# log as STACK_USER and cd to devstack/
USER $STACK_USER
WORKDIR devstack

CMD ["sudo /cmd.sh"]