FROM phusion/baseimage:latest
MAINTAINER affear_team

# Regenerate SSH host keys.
RUN /etc/my_init.d/00_regen_ssh_host_keys.sh

# expose services ports
EXPOSE 80 5000 8773 8774 8776 9292

RUN apt-get update

# BEGIN THANKS TO
# https://github.com/ewindisch/dockenstack
# Install utilities
RUN apt-get -qqy install git socat curl sudo apt-transport-https vim wget net-tools

# Install apparmor
RUN apt-get -qqy install apparmor

# Extra requirements for pip-requirements
RUN apt-get install -qqy libffi-dev libkrb5-dev

# Configure and install MySQL
RUN echo 'mysql-server mysql-server/root_password password devstack' | debconf-set-selections; \
    echo 'mysql-server mysql-server/root_password_again password devstack' | debconf-set-selections; \
    apt-get -qqy install mysql-server

# Install RabbitMQ
RUN apt-get -qqy install rabbitmq-server

# cloning devstack
RUN git clone git@github.com:openstack-dev/devstack.git /devstack

# thanks to https://github.com/ewindisch/dockenstack
# Install prereq packages.
RUN /devstack/tools/install_prereqs.sh

# Pre-download all "NOPRIME" packages
RUN /bin/bash /opt/dockenstack/bin/apt-cache-devstack

# Mask python-six because the apt package can conflict with the pypi version.
RUN apt-get remove -q -y python-six

# python-pip just became collatoral damage.  reinstall it.
RUN apt-get install -q -y python-pip

# Install six from pip before getting from global-requirements (due to bugs...)
RUN pip install six

# Install all pip requirements
RUN pip install -r https://raw.github.com/openstack/requirements/master/global-requirements.txt
RUN pip install -r https://raw2.github.com/openstack/tempest/master/requirements.txt
# END THANKS TO

# ADDING SERVICES:
# <os_service>.sh content:
#####
# #!/bin/sh
# exec /sbin/setuser <os_service> /usr/bin/<os_service> >>/var/log/<os_service>.log 2>&1
#####
# In this Dockerfile:
#####
# RUN mkdir /etc/service/<os_service>
# ADD <os_service>.sh /etc/service/<os_service>/run

# copying localrc file
ADD localrc devstack/
# install devstack
RUN /bin/bash /devstack/stack.sh

# Use baseimage-docker's init system.
CMD ["/sbin/my_init"]

# Clean up APT when done.
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*