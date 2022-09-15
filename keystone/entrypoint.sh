#!/usr/bin/env bash

configure() {
  echo "First configurating keystone"

  echo "configure keystone.conf..."
  sed -i "/connection = sqlite/c\connection = mysql+pymysql://${KEYSTONE_DATABASE_USER}:${KEYSTONE_DATABASE_PASSWORD}@${KEYSTONE_DATABASE_HOST}:${KEYSTONE_DATABASE_PORT}/${KEYSTONE_DATABASE_SCHEME}" /etc/keystone/keystone.conf
  sed -i "/#provider = /c\provider = fernet" /etc/keystone/keystone.conf

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
    --bootstrap-project-name ${KEYSTONE_ADMIN_PROJECT} \
    --bootstrap-role-name admin \
    --bootstrap-service-name keystone \
    --bootstrap-admin-url ${KEYSTONE_HTTP_SCHEME}://${KEYSTONE_HOST}:${KEYSTONE_PORT}/v3/ \
    --bootstrap-internal-url ${KEYSTONE_HTTP_SCHEME}://${KEYSTONE_HOST}:${KEYSTONE_PORT}/v3/ \
    --bootstrap-public-url ${KEYSTONE_HTTP_SCHEME}://${KEYSTONE_HOST}:${KEYSTONE_PORT}/v3/ \
    --bootstrap-region-id ${REGION_ID}

  echo "configure apache2..."
  echo "ServerName ${KEYSTONE_HOST}" >> /etc/apache2/apache2.conf

  echo "done!"
  touch /root/.keystone_configured
}

if [ ! -f /root/.keystone_configured ]; then
  configure
fi

echo "Starting keystone apache2..."
apache2ctl -D FOREGROUND
