#!/usr/bin/env bash

set -e

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

# Setting up - Placement Service
echo "Create Placement User"
openstack user delete ${PLACEMENT_API_USER} || true
openstack user create --domain default --password ${PLACEMENT_API_PASS} ${PLACEMENT_API_USER}

echo "Create Placement Role"
openstack role add --project service --user ${PLACEMENT_API_USER} ${OPENSTACK_ADMIN_ROLE}

echo "Create Placement Service"
openstack service delete placement || true
openstack service create --name placement --description "OpenStack Placement Service" placement

echo "Create Placement Endpoint"
openstack endpoint show placement || \
openstack endpoint create --region ${REGION_ID} placement public ${PLACEMENT_API_PUBLIC_ENDPOINT} && \
openstack endpoint create --region ${REGION_ID} placement internal ${PLACEMENT_API_INTERNAL_ENDPOINT} && \
openstack endpoint create --region ${REGION_ID} placement admin ${PLACEMENT_API_ADMIN_ENDPOINT}
