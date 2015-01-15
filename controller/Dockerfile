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
EXPOSE 5000 35357 9292 9191 8777 8773 8774 8775 8000 8003 8004 3306 5672 80

# solve errors on non interactive mode
ENV DEBIAN_FRONTEND noninteractive

# update, then install some utils
RUN apt-get update && apt-get install -y sed git socat curl sudo apt-transport-https vim wget net-tools python uuid-runtime
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

# Install devstack scripts from our fork
RUN git clone https://github.com/affear/devstack.git /devstack
# add devstack's official upstream
RUN git -C /devstack remote add official https://github.com/openstack-dev/devstack.git
# update devstack
RUN git -C /devstack fetch official
RUN git -C /devstack rebase official/master
RUN git -C /devstack pull origin master

# Install prereq packages.
RUN /devstack/tools/install_prereqs.sh

# add localrc to devstack's root dir
ADD local.conf /devstack/
# add script to reinstall a service.
ADD shared/reinstall_service.sh /devstack/
# add command
ADD shared/cmd.sh / 

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
WORKDIR /devstack

CMD sudo /cmd.sh