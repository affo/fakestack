FROM phusion/baseimage:latest
MAINTAINER affearteam

# Enable insecure key for ssh
RUN /usr/sbin/enable_insecure_key

# Updat and install git, sudo
RUN apt-get update && apt-get install -y git sudo

# Avoid prompt to acept key
RUN ssh -oStrictHostKeyChecking=no github.com uptime

# Determine container auto-assigned IP
RUN export MY_IP=$(/sbin/ifconfig eth0 | grep 'inet addr:' | cut -d: -f2 | awk '{ print $1}')

# Create stack user add to stack gruop and sudo
RUN groupadd stack
RUN useradd -g stack -s /bin/bash -d /opt/stack -m stack
RUN echo "stack ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
RUN su - stack

# Clone DevStack
RUN git clone https://github.com/openstack-dev/devstack.git

WORKDIR devstack

ADD localrc .
