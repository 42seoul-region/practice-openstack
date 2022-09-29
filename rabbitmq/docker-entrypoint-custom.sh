#!/usr/bin/env bash

configure() {
    echo "running temporary server..."
    rabbitmq-server &

    until rabbitmq-diagnostics -q ping
    do
        echo ...
        sleep 1
    done

    set -e

    echo "await startup..."
    rabbitmqctl await_startup

    echo "add openstack user"
    rabbitmqctl add_user openstack $RABBIT_PASS

    echo "add permission"
    rabbitmqctl set_permissions openstack ".*" ".*" ".*"

    touch /root/.rabbitmq_configured

    echo "test"
    rabbitmqctl list_users
    rabbitmqctl authenticate_user openstack rabbitmq_password

    echo "kill temporary server"
    rabbitmqctl shutdown
}

if [ ! -f /root/.rabbitmq_configured ]; then
  configure
fi

exec "$@"
