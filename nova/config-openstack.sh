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

# Setting up - Glance
echo "Create Nova User"
openstack user delete ${NOVA_USER} || true
openstack user create --domain default --password ${NOVA_PASS} ${NOVA_USER}

echo "Create Nova Role"
openstack role add --project service --user ${NOVA_USER} ${OPENSTACK_ADMIN_ROLE}

echo "Create Nova Service"
openstack service delete compute || true
openstack service create --name nova --description "OpenStack Image Service" compute

echo "Create Nova Endpoint"
openstack endpoint show compute || \
openstack endpoint create --region ${REGION_ID} compute public ${NOVA_PUBLIC_ENDPOINT} && \
openstack endpoint create --region ${REGION_ID} compute internal ${NOVA_INTERNAL_ENDPOINT} && \
openstack endpoint create --region ${REGION_ID} compute admin ${NOVA_ADMIN_ENDPOINT}
