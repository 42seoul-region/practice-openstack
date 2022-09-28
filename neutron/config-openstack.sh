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

# Setting up - Nova
echo "Check Neutron User..."
openstack user delete ${NEUTRON_USER} || true
echo "Create Neutron User..."
openstack user create --domain default --password ${NEUTRON_PASS} ${NEUTRON_USER}

echo "Check Neutron Role..."
if [ $(openstack role assignment list --names | grep ${NEUTRON_USER} | wc -l) -eq 0 ];then
	echo "Create Neutron Role..."
	openstack role add --project service --user ${NEUTRON_USER} ${OPENSTACK_ADMIN_ROLE}
fi

echo "Check Neutron Service..."
openstack service delete network || true
echo "Create Neutron Service..."
openstack service create --name neutron --description "OpenStack Network Service" network

echo "Check Neutron Endpoint..."
if [ $(openstack endpoint list --service network | grep network | wc -l) -eq 0 ];then
	echo "Create Neutron Endpoint..."
	openstack endpoint create --region ${REGION_ID} network public ${NEUTRON_PUBLIC_ENDPOINT}
	openstack endpoint create --region ${REGION_ID} network internal ${NEUTRON_INTERNAL_ENDPOINT}
	openstack endpoint create --region ${REGION_ID} network admin ${NEUTRON_ADMIN_ENDPOINT}
fi
