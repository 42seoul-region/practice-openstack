#!/bin/sh

rabbitmq-server &

pid=$!

while :
do
	rabbitmq-diagnostics -q ping
	if [ $? -eq 0 ]; then
		break
	fi
	sleep 1
done

rabbitmqctl start_app
rabbitmqctl add_user openstack $RABBIT_PASS
rabbitmqctl set_permissions openstack ".*" ".*" ".*"

kill -TERM $pid