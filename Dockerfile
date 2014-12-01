FROM ubuntu:latest
MAINTAINER affear

RUN apt-get update
RUN apt-get install -y python
RUN apt-get install -y python-pip
RUN pip install bottle
ADD hello_world.py .
RUN python hello_world.py