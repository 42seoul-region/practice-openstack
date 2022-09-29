#!/usr/bin/env bash

set -e

echo "Params"
echo "$@"

configure() {
  echo "First configurating Horizon"

  echo "configure local_settings.sh..."
  ./config.sh

  #echo "configure openstack-dashboard.conf..."
  #echo "WSGIApplicationGroup %{GLOBAL}" >> /etc/apache2/conf-available/openstack-dashboard.conf

  echo "done!"
  touch /root/.horizon_configured
}

if [ ! -f /root/.horizon_configured ]; then
  configure
fi

echo "Starting service..."

exec "$@"
