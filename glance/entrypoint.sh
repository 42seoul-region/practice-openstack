#!/usr/bin/env bash

set -e

echo "Params"
echo "$@"

configure() {
  echo "First configurating glance"

  echo "configure glance-api.conf..."
  ./config-glance-api.py

  echo "configure glance-registry.conf..."
  ./config-glance-registry.py

  su -s /bin/sh -c "glance-manage db_sync" ${GLANCE_DATABASE_SCHEME}

  echo "configure openstack..."
  ./config-openstack.sh

  echo "done!"
  touch /root/.glance_configured
}

if [ ! -f /root/.glance_configured ]; then
  configure
fi

echo "Starting service..."
exec "$@"
