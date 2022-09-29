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

  echo "Create Placement User . . ."
  openstack user delete ${PLACEMENT_API_USER} || true
  openstack user create --domain default --password ${PLACEMENT_API_PASS} ${PLACEMENT_API_USER}

  echo "Check Placement Role"
  if [ $(openstack role assignment list --names | grep ${PLACEMENT_API_USER} | wc -l) -eq 0 ]; then
    echo "Create Placement Role . . ."
    openstack role add --project service --user ${PLACEMENT_API_USER} ${OPENSTACK_ADMIN_ROLE}
  fi

  echo "Create Placement Service . . ."
  openstack service delete placement || true
  openstack service create --name placement --description "OpenStack Placement Service" placement

  echo "Check Placement Endpoint"
  if [ $(openstack endpoint list --service placement | grep placement | wc -l) -eq 0 ]; then
  echo "Create Placement Endpoint . . ."
    openstack endpoint create --region ${REGION_ID} placement public ${PLACEMENT_API_PUBLIC_ENDPOINT}
    openstack endpoint create --region ${REGION_ID} placement internal ${PLACEMENT_API_INTERNAL_ENDPOINT}
    openstack endpoint create --region ${REGION_ID} placement admin ${PLACEMENT_API_ADMIN_ENDPOINT}
  fi
}

configure() {
  echo "Begin configure placement"

  # Create service credential by OpenStack-Client
  echo "Run OpenStack-Client in subshell"
  (
    echo "BEGIN . . ."
    openstack_make_service_credential
    echo "END . . ."
  )

  # Edit /etc/placement/placement.conf file
  echo "Edit conf file . . ."
  ./config.py

  # Database sync as user 'placement'
  echo "Database synchronize . . ."
  su -s /bin/sh -c "placement-manage db sync" placement

  # Set host name of HTTP service
  echo "Append \'ServerName\' to apache2.conf . . ."
  echo "ServerName $HOST_PLACEMENT_API" >> /etc/apache2/apache2.conf

  echo "Done ! !"
}

if [ -f /root/.placement_configured ]; then
  echo "Configure file detected ! !"
else
  echo "Configure file not detected . . ."
  configure
  touch /root/.placement_configured
fi

echo
echo "Starting service . . ."
exec "$@"
