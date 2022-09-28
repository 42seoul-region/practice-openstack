#!/usr/bin/env bash

set -e

echo "Params"
echo "$@"

configure() {
  echo "First configurating Nova"

  echo "configure nova.conf..."
  ./config-nova.py

  echo "configure openstack..."
  ./config-openstack.sh

  su -s /bin/sh -c "nova-manage api_db sync" ${NOVA_DATABASE_SCHEME}

  su -s /bin/sh -c "nova-manage cell_v2 map_cell0" ${NOVA_DATABASE_SCHEME}

  su -s /bin/sh -c "nova-manage cell_v2 create_cell --name=cell1 --verbose" ${NOVA_DATABASE_SCHEME} || true

  su -s /bin/sh -c "nova-manage db sync" ${NOVA_DATABASE_SCHEME}

  su -s /bin/sh -c "nova-manage cell_v2 list_cells" ${NOVA_DATABASE_SCHEME}

  su -s /bin/sh -c "nova-manage cell_v2 discover_hosts --verbose" nova

  echo "done!"
  touch /root/.nova_configured
}

if [ ! -f /root/.nova_configured ]; then
  configure
fi

echo "Starting service..."

nova-api &
nova-scheduler &
nova-conductor &
nova-novncproxy &

trap "service_down; exit" SIGKILL

function service_down() {
  echo "Terminating services..."
  killall -SIGKILL nova-api
  killall -SIGKILL nova-scheduler
  killall -SIGKILL nova-conductor
  killall -SIGKILL nova-novncproxy
}

exec "$@"
