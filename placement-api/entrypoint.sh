#!/usr/bin/env bash

set -e

echo "Params"
echo "$@"

configure() {
  echo "First configurating placement"

  echo "configure placement.conf..."
  ./config-placement.py

  echo "configure openstack..."
  ./config-openstack.sh

  su -s /bin/sh -c "placement-manage db sync" ${PLACEMENT_DATABASE_SCHEME}

  echo "configure apache2..."
  echo "ServerName $HOST_PLACEMENT_API" >> /etc/apache2/apache2.conf

  echo "done!"
  touch /root/.placement_configured
}

if [ ! -f /root/.placement_configured ]; then
  configure
fi

echo "Starting service..."
exec "$@"
