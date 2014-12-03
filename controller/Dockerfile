FROM phusion/baseimage:latest
MAINTAINER affearteam

#TODO rember to EXPOSE OpenStack services!!

# Enable insecure key for ssh
RUN /usr/sbin/enable_insecure_key

# Updat and install git, sudo
RUN apt-get update && apt-get install -y git sudo python

# Clone DevStack
RUN git clone https://github.com/openstack-dev/devstack.git
# add localrc
ADD local.conf devstack/

# create suitable devstack user
ENV STACK_USER stack
ENV DEST devstack
RUN ./devstack/tools/create-stack-user.sh
RUN chown -R $STACK_USER:$STACK_USER devstack
# log as STACK_USER and cd to devstack/
USER $STACK_USER
WORKDIR devstack

RUN ./stack.sh