FROM phusion/baseimage:latest
MAINTAINER affear

ENV HOME /root

# Regenerate SSH host keys.
RUN /etc/my_init.d/00_regen_ssh_host_keys.sh

# build instructions
RUN apt-get update
RUN apt-get install -y git

# cloning devstack
RUN git clone git@github.com:openstack-dev/devstack.git

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

# Use baseimage-docker's init system.
CMD ["/sbin/my_init"]

# Clean up APT when done.
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*