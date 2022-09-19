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

# Setting up - Service Project
echo "Create Service Project"
openstack project create --or-show --domain default --description "Service Project" ${OPENSTACK_SERVICE_PROJECT}

# Setting up - Glance
echo "Create Glance User"
openstack user delete ${GLANCE_USER} || true
openstack user create --domain default --password ${GLANCE_PASS} ${GLANCE_USER}

echo "Create Glance Role"
openstack role add --project service --user ${GLANCE_USER} ${OPENSTACK_ADMIN_ROLE}

echo "Create Glance Service"
openstack service delete image || true
openstack service create --name glance --description "OpenStack Image Service" image

echo "Create Glance Endpoint"
openstack endpoint show image || \
openstack endpoint create --region ${REGION_ID} image public ${GLANCE_PUBLIC_ENDPOINT} && \
openstack endpoint create --region ${REGION_ID} image internal ${GLANCE_INTERNAL_ENDPOINT} && \
openstack endpoint create --region ${REGION_ID} image admin ${GLANCE_ADMIN_ENDPOINT}
