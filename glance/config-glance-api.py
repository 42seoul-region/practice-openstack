#!/usr/bin/env python3

import os
import configparser

config = configparser.ConfigParser()
config.read('/etc/glance/glance-api.conf')

config['DEFAULT']['debug'] = os.environ['OPENSTACK_DEBUG']
config['keystone_authtoken']['www_authenticate_uri'] = '{KEYSTONE_PUBLIC_ENDPOINT}/v3/'.format(**os.environ)
config['database']['connection'] = 'mysql+pymysql://{GLANCE_DATABASE_USER}:{GLANCE_DATABASE_PASSWORD}@{GLANCE_DATABASE_HOST}:{GLANCE_DATABASE_PORT}/{GLANCE_DATABASE_SCHEME}'.format(**os.environ)
config['keystone_authtoken']['auth_url'] = '{KEYSTONE_INTERNAL_ENDPOINT}/v3/'.format(**os.environ)
config['keystone_authtoken']['auth_type'] = 'password'
config['keystone_authtoken']['project_domain_name'] = 'Default'
config['keystone_authtoken']['user_domain_name'] = 'Default'
config['keystone_authtoken']['project_name'] = 'service'
config['keystone_authtoken']['username'] = os.environ['GLANCE_USER']
config['keystone_authtoken']['password'] = os.environ['GLANCE_PASS']
config['paste_deploy']['flavor'] = 'keystone'
config['glance_store']['stores'] = 'file,http'

# file, filesystem, http, https, swift, swift+http, swift+https, swift+config, rbd, cinder, vsphere, s3
config['glance_store']['default_store'] = 'filesystem'
config['glance_store']['filesystem_store_datadir'] = '/var/lib/glance/images/'

# oslo_limit (not sure)
# https://docs.openstack.org/oslo.limit/latest/reference/opts.html
if not ('oslo_limit' in config):
    config['oslo_limit'] = {}
config['oslo_limit']['auth_url'] = '{KEYSTONE_INTERNAL_ENDPOINT}/v3/'.format(**os.environ)
config['oslo_limit']['auth_type'] = 'password'
config['oslo_limit']['user_domain_id'] = 'default'
config['oslo_limit']['username'] = os.environ['GLANCE_USER']
config['oslo_limit']['password'] = os.environ['GLANCE_PASS']
config['oslo_limit']['system_scope'] = 'all'
config['oslo_limit']['endpoint_id'] = '0' # ?
config['oslo_limit']['region_name'] = os.environ['REGION_ID']

with open('/etc/glance/glance-api.conf', 'w') as configfile:
    config.write(configfile)
