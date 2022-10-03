#!/usr/bin/env bash

set -e

echo "PARAMS"
echo "$@"
echo

configure() {
  echo "Begin configure keystone"

  # Edit /etc/keystone/keystone.conf file
  echo "Edit conf file . . ."
  ./config.py

  # Database sync as user 'keystone'
  echo "Database synchronize . . ."
  su -s /bin/sh -c "keystone-manage db_sync" keystone

  # Fernet is credential provider via encryption key
  # Set-up fernet and credential
  echo "Set-up fernet . . ."
  keystone-manage fernet_setup --keystone-user keystone --keystone-group keystone
  keystone-manage credential_setup --keystone-user keystone --keystone-group keystone

  # Bootstrap
  echo "Bootstrap Keystone . . ."
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

  # Set host name of HTTP service
  echo "Append \'ServerName\' to apache2.conf . . ."
  echo "ServerName $HOST_INTERNAL_KEYSTONE" >> /etc/apache2/apache2.conf

  echo "Done ! !"
}

if [ -f /root/.keystone_configured ]; then
  echo "Configure file detected ! !"
else
  echo "Configure file not detected . . ."
  configure
  touch /root/.keystone_configured
fi

echo
echo "Starting service . . ."
exec "$@"
