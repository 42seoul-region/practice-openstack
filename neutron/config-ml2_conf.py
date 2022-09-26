#!/usr/bin/env python3

import os
import configparser

config = configparser.ConfigParser()
config.read('/etc/neutron/plugins/ml2/ml2_conf.ini')

config['ml2']['type_drivers'] = 'flat,vlan,vxlan'
config['ml2']['tenant_network_types'] = 'vxlan'
config['ml2']['mechanism_drivers'] = 'linuxbridge,l2population'
config['ml2']['extension_drivers'] = 'port_security'

config['ml2_type_flat']['flat_networks'] = 'provider'

config['ml2_type_vxlan']['vni_ranges'] = '1:1000'

config['securitygroup']['enable_ipset'] = 'true'

with open('/etc/neutron/plugins/ml2/ml2_conf.ini', 'w') as configfile:
    config.write(configfile)
