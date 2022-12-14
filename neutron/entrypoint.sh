#!/usr/bin/env bash

set -e

echo "Params"
echo "$@"

configure() {
  echo "First configurating Nova"

  export PROVIDER_INTERFACE_NAME=$(ip -o -4 route show to default | awk '{print $5}')

  echo "configure neutron.conf..."
  ./config-neutron.py

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
PID_NEUTRON=$!

neutron-linuxbridge-agent &
PID_NEUTRON_LB=$!

neutron-dhcp-agent &
PID_DHCP=$!

neutron-metadata-agent &
PID_METADATA=$!

neutron-l3-agent &
PID_L3=$!

trap "service_down; exit" SIGTERM

function service_down() {
  echo "Terminating services..."
  kill -TERM $PID_NEUTRON
  kill -TERM $PID_NEUTRON_LB
  kill -TERM $PID_DHCP
  kill -TERM $PID_METADATA
  kill -TERM $PID_L3
  apache2ctl -k graceful-stop
}

exec "$@"
