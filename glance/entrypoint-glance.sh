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

  echo "Create Glance User . . ."
  openstack user delete ${GLANCE_USER} || true
  openstack user create --domain default --password ${GLANCE_PASS} ${GLANCE_USER}

  echo "Check Glance Role"
  if [ $(openstack role assignment list --names | grep ${GLANCE_USER} | wc -l) -eq 0 ]; then
    echo "Create Glance Role . . ."
    openstack role add --project service --user ${GLANCE_USER} ${OPENSTACK_ADMIN_ROLE}
  fi

  echo "Create Glance Service . . ."
  openstack service delete image || true
  openstack service create --name glance --description "OpenStack Image Service" image

  echo "Check Glance Endpoint"
  if [ $(openstack endpoint list --service image | grep image | wc -l) -eq 0 ]; then
    echo "Create Glance Endpoint . . ."
    openstack endpoint create --region ${REGION_ID} image public ${GLANCE_PUBLIC_ENDPOINT}
    openstack endpoint create --region ${REGION_ID} image internal ${GLANCE_INTERNAL_ENDPOINT}
    openstack endpoint create --region ${REGION_ID} image admin ${GLANCE_ADMIN_ENDPOINT}
  fi
}

configure() {
  echo "Begin configure glance"

  # Create service credential by OpenStack-Client
  echo "Run OpenStack-Client in subshell"
  (
    echo "BEGIN . . ."
    openstack_make_service_credential
    echo "END . . ."
  )

  # Edit /etc/glance/glance-*.conf file
  echo "Edit conf file . . ."
  ./config.py

  # Database sync as user 'glance'
  echo "Database synchronize . . ."
  su -s /bin/sh -c "glance-manage db sync" glance

  echo "Done ! !"
}

if [ -f /root/.glance_configured ]; then
  echo "Configure file detected ! !"
else
  echo "Configure file not detected . . ."
  configure
  touch /root/.glance_configured
fi

echo
echo "Starting service . . ."
exec "$@"
