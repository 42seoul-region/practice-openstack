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

  echo "Create Cinder User . . ."
  openstack user delete ${CINDER_USER} || true
  openstack user create --domain default --password ${CINDER_PASSWORD} ${CINDER_USER}

  echo "Check Cinder Role"
  if [ $(openstack role assignment list --names | grep ${CINDER_USER} | wc -l) -eq 0 ]; then
    echo "Create Cinder Role . . ."
    openstack role add --project service --user ${CINDER_USER} ${OPENSTACK_ADMIN_ROLE}
  fi

  echo "Create Cinder Service . . ."
  openstack service delete volumev3 || true
  openstack service create --name cinderv3 --description "OpenStack Block Storage" volumev3

  echo "Check Cinder Endpoint"
  if [ $(openstack endpoint list --service volumev3 | grep volumev3 | wc -l) -eq 0 ]; then
    echo "Create Cinder Endpoint . . ."
    openstack endpoint create --region ${REGION_ID} volumev3 public ${CINDER_PUBLIC_ENDPOINT}/%\(project_id\)s
    openstack endpoint create --region ${REGION_ID} volumev3 internal ${CINDER_INTERNAL_ENDPOINT}/%\(project_id\)s
    openstack endpoint create --region ${REGION_ID} volumev3 admin ${CINDER_ADMIN_ENDPOINT}/%\(project_id\)s
  fi
}

configure() {
  echo "Begin configure cinder"

  # Create service credential by OpenStack-Client
  echo "Run OpenStack-Client in subshell"
  (
    echo "BEGIN . . ."
    openstack_make_service_credential
    echo "END . . ."
  )

  # Edit /etc/cinder/cinder-*.conf file
  echo "Edit conf file . . ."
  ./config.py

  # Database sync as user 'glance'
  echo "Database synchronize . . ."
  su -s /bin/sh -c "cinder-manage db sync" cinder

  echo "Done ! !"
}

if [ -f /root/.glance_configured ]; then
  echo "Configure file detected ! !"
else
  echo "Configure file not detected . . ."
  configure
  touch /root/.cinder_configured
fi

echo
echo "Starting service . . ."
exec "$@"
