FROM phusion/baseimage:latest
MAINTAINER affearteam

RUN /usr/sbin/enable_insecure_key

RUN apt-get update && apt-get install -y git

RUN ssh -oStrictHostKeyChecking=no github.com uptime

RUN git clone https://github.com/openstack-dev/devstack.git

WORKDIR devstack