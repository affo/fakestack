#!/bin/sh
docker run \
--privileged=true \
$1 /bin/sh -c \
"sudo service rabbitmq-server start && sudo service mysql start && ./stack.sh"