#!/usr/bin/env bash

set -e

echo "PARAMS"
echo "$@"
echo

openstack_make_service_credential() {
  # Set Openstack Credential
  export OS_IDENTITY_API_VERSION=3
  export OS_PROJECT_DOMAIN_ID=default
  export OS_PROJECT_DOMAIN_NAME=Default
  export OS_USER_DOMAIN_ID=default
  export OS_USER_DOMAIN_NAME=Default
  export OS_PROJECT_NAME=${OPENSTACK_ADMIN_PROJECT}
  export OS_USERNAME=${KEYSTONE_ADMIN_USER}
  export OS_PASSWORD=${KEYSTONE_ADMIN_PASS}
  export OS_AUTH_URL=${KEYSTONE_INTERNAL_ENDPOINT}/v3
  export OS_INTERFACE=internal

  echo "Create Service Project If Absent . . ."
  openstack project create --or-show --domain default --description "Service Project" ${OPENSTACK_SERVICE_PROJECT}

  echo "Check Nova User . . ."
  openstack user delete ${NOVA_USER} || true
  openstack user create --domain default --password ${NOVA_PASS} ${NOVA_USER}

  echo "Check Nova Role"
  if [ $(openstack role assignment list --names | grep ${NOVA_USER} | wc -l) -eq 0 ]; then
    echo "Create Nova Role . . . "
    openstack role add --project service --user ${NOVA_USER} ${OPENSTACK_ADMIN_ROLE}
  fi

  echo "Create Nova Service . . ."
  openstack service delete compute || true
  openstack service create --name nova --description "OpenStack Image Service" compute

  echo "Check Nova Endpoint"
  if [ $(openstack endpoint list --service compute | grep compute | wc -l) -eq 0 ]; then
    echo "Create Nova Endpoint . . . "
    openstack endpoint create --region ${REGION_ID} compute public ${NOVA_PUBLIC_ENDPOINT}
    openstack endpoint create --region ${REGION_ID} compute internal ${NOVA_INTERNAL_ENDPOINT}
    openstack endpoint create --region ${REGION_ID} compute admin ${NOVA_ADMIN_ENDPOINT}
  fi
}

configure() {
  echo "Begin configure nova"

  # Create service credential by OpenStack-Client
  echo "Run OpenStack-Client in subshell"
  (
    echo "BEGIN . . ."
    openstack_make_service_credential
    echo "END . . ."
  )

  # Edit /etc/nova/nova.conf file
  echo "Edit conf file . . ."
  ./config.py

  # Management as user 'nova'
  ## Synchronize nova-api Database
  ## Register database `cell0`
  ## Create cell `cell1`
  ## Synchronize Database
  ## Finally, Show registered nova cells
  su -s /bin/sh -c "$(cat << EOF
nova-manage api_db sync
nova-manage cell_v2 map_cell0
nova-manage db sync
# nova-manage cell_v2 create_cell --name cell1 --database_connection mysql+pymysql://nova_compute:nova_database_password@192.168.42.3/nova_compute?charset=utf8 --transport-url rabbit://guest:guest@192.168.42.3:5672/
nova-manage cell_v2 list_cells
# see also 'nova-scheduler' and automatic discovery
nova-manage cell_v2 discover_hosts --verbose
EOF
)" nova

  echo "Done ! !"
}

if [ -f /root/.nova_configured ]; then
  echo "Configure file detected ! !"
else
  echo "Configure file not detected . . ."
  configure
  touch /root/.nova_configured
fi

echo
echo "Starting service . . ."

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

#TODO: 이게 이래버리면 트랩이 유지가 되나?
exec "$@"
