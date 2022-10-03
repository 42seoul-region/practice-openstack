#!/usr/bin/env python3

import os
import configparser
import socket

config = configparser.ConfigParser()
config.read('/etc/neutron/metadata_agent.ini')

config['DEFAULT']['nova_metadata_host'] = os.environ['HOST_INTERNAL_NOVA']
config['DEFAULT']['metadata_proxy_shared_secret'] = os.environ['METADATA_SECRET']

with open('/etc/neutron/metadata_agent.ini', 'w') as configfile:
    config.write(configfile)
