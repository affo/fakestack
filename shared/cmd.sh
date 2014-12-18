#!/bin/bash

service mysql start
service rabbitmq-server start
su stack -c '/devstack/stack.sh'