#!/usr/bin/env python3

import os
import configparser

conf_glance_api = configparser.ConfigParser()
conf_glance_api.read('/etc/glance/glance-api.conf')

# [DEFAULT]
conf_glance_api['DEFAULT']['debug'] = os.environ['OPENSTACK_DEBUG']

# [database]
conf_glance_api['database']['connection'] = 'mysql+pymysql://{GLANCE_DATABASE_USER}:{GLANCE_DATABASE_PASSWORD}@{GLANCE_DATABASE_HOST}:{GLANCE_DATABASE_PORT}/{GLANCE_DATABASE_SCHEME}'.format(**os.environ)

# [keystone_authtoken]
conf_glance_api['keystone_authtoken']['www_authenticate_uri'] = '{KEYSTONE_PUBLIC_ENDPOINT}/v3/'.format(**os.environ)
conf_glance_api['keystone_authtoken']['auth_url'] = '{KEYSTONE_INTERNAL_ENDPOINT}/v3/'.format(**os.environ)
# see also memcached_servers
conf_glance_api['keystone_authtoken']['auth_type'] = 'password'
conf_glance_api['keystone_authtoken']['project_domain_name'] = 'Default'
conf_glance_api['keystone_authtoken']['user_domain_name'] = 'Default'
conf_glance_api['keystone_authtoken']['project_name'] = 'service'
conf_glance_api['keystone_authtoken']['username'] = os.environ['GLANCE_USER']
conf_glance_api['keystone_authtoken']['password'] = os.environ['GLANCE_PASS']

# [paste_deploy]
conf_glance_api['paste_deploy']['flavor'] = 'keystone'

# [glance_store]
conf_glance_api['glance_store']['stores'] = 'file,http'
## file, filesystem, http, https, swift, swift+http, swift+https, swift+conf_glance_api, rbd, cinder, vsphere, s3
conf_glance_api['glance_store']['default_store'] = 'file'
conf_glance_api['glance_store']['filesystem_store_datadir'] = '/var/lib/glance/images/'

# [oslo_limit]
# configuring the unified limits client: https://docs.openstack.org/oslo.limit/latest/user/usage.html#configuration
# insert if absent
if 'oslo_limit' not in conf_glance_api:
    conf_glance_api['oslo_limit'] = {}
conf_glance_api['oslo_limit']['auth_url'] = '{KEYSTONE_INTERNAL_ENDPOINT}/v3/'.format(**os.environ)
conf_glance_api['oslo_limit']['auth_type'] = 'password'
conf_glance_api['oslo_limit']['user_domain_id'] = 'default'
conf_glance_api['oslo_limit']['username'] = os.environ['GLANCE_USER']
conf_glance_api['oslo_limit']['system_scope'] = 'all'
conf_glance_api['oslo_limit']['password'] = os.environ['GLANCE_PASS']
conf_glance_api['oslo_limit']['endpoint_id'] = '0' # ?
conf_glance_api['oslo_limit']['region_name'] = os.environ['REGION_ID']

with open('/etc/glance/glance-api.conf', 'w') as f1:
    conf_glance_api.write(f1)

conf_glance_registry = configparser.ConfigParser()
conf_glance_registry.read('/etc/glance/glance-registry.conf')

# [DEFAULT]
conf_glance_registry['DEFAULT']['debug'] = os.environ['OPENSTACK_DEBUG']

with open('/etc/glance/glance-registry.conf', 'w') as f2:
    conf_glance_registry.write(f2)
