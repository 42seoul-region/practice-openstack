#!/usr/bin/env python3

import os
import configparser

config = configparser.ConfigParser()
config.read('/etc/glance/glance-registry.conf')

config['DEFAULT']['debug'] = os.environ['OPENSTACK_DEBUG']

with open('/etc/glance/glance-registry.conf', 'w') as configfile:
    config.write(configfile)
