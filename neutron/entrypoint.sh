#!/usr/bin/env bash

set -e

echo "Params"
echo "$@"

configure() {
  echo "First configurating Nova"

  echo "configure neutron.conf..."
  ./config-neutron.py

  echo "configure ml2_conf.ini..."
  ./config-ml2_conf.py

  echo "configure openstack..."
  ./config-openstack.sh

  su -s /bin/sh -c "neutron-db-manage --config-file /etc/neutron/neutron.conf \
  --config-file /etc/neutron/plugins/ml2/ml2_conf.ini upgrade head" neutron

  echo "done!"
  touch /root/.neutron_configured
}

if [ ! -f /root/.neutron_configured ]; then
  configure
fi

echo "Starting service..."

neutron-server &
#neutron-dhcp-agent &
#neutron-metadata-agent &
#neutron-l3-agent &

trap "service_down; exit" SIGKILL

function service_down() {
  echo "Terminating services..."
  killall -SIGKILL neutron-server
#  killall -SIGKILL neutron-dhcp-agent
#  killall -SIGKILL neutron-metadata-agent
#  killall -SIGKILL neutron-l3-agent
}

exec "$@"
