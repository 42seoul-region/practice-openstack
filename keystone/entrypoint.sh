#!/usr/bin/env bash

set -e

echo "Params"
echo "$@"

configure() {
  echo "First configurating keystone"

  echo "configure keystone.conf..."
  ./config-keystone.py

  echo "configure keystone db..."
  su -s /bin/sh -c "keystone-manage db_sync" ${KEYSTONE_DATABASE_SCHEME}

  echo "configure keystone fernet..."
  keystone-manage fernet_setup --keystone-user keystone --keystone-group keystone

  echo "configure keystone credential..."
  keystone-manage credential_setup --keystone-user keystone --keystone-group keystone

  echo "configure keystone bootstrap..."
  keystone-manage bootstrap \
    --bootstrap-username ${KEYSTONE_ADMIN_USER} \
    --bootstrap-password ${KEYSTONE_ADMIN_PASS} \
    --bootstrap-project-name ${OPENSTACK_ADMIN_PROJECT} \
    --bootstrap-role-name ${OPENSTACK_ADMIN_ROLE} \
    --bootstrap-service-name keystone \
    --bootstrap-admin-url ${KEYSTONE_ADMIN_ENDPOINT}/v3/ \
    --bootstrap-internal-url ${KEYSTONE_INTERNAL_ENDPOINT}/v3/ \
    --bootstrap-public-url ${KEYSTONE_PUBLIC_ENDPOINT}/v3/ \
    --bootstrap-region-id ${REGION_ID}

  echo "configure apache2..."
  echo "ServerName $HOST_KEYSTONE" >> /etc/apache2/apache2.conf

  echo "done!"
  touch /root/.keystone_configured
}

if [ ! -f /root/.keystone_configured ]; then
  configure
fi

echo "Starting service..."
exec "$@"
