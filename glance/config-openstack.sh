#!/usr/bin/env bash

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

# Setting up - Service Project
echo "Create Service Project"
openstack project create --domain default --description "Service Project" service

# Setting up - Glance
echo "Create Glance User"
openstack user create --domain default --password ${GLANCE_PASS} ${GLANCE_USER}

echo "Create Glance Role"
openstack role add --project service --user ${GLANCE_USER} ${OPENSTACK_ADMIN_ROLE}

echo "Create Glance Service"
openstack service create --name glance --description "OpenStack Image Service" image

echo "Create Glance Endpoint Public"
openstack endpoint create --region ${REGION_ID} image public ${GLANCE_PUBLIC_ENDPOINT}
echo "Create Glance Endpoint Internal"
openstack endpoint create --region ${REGION_ID} image internal ${GLANCE_INTERNAL_ENDPOINT}
echo "Create Glance Endpoint Admin"
openstack endpoint create --region ${REGION_ID} image admin ${GLANCE_ADMIN_ENDPOINT}
