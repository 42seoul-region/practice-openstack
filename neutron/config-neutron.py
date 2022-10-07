#!/usr/bin/env python3

import os
import configparser
import socket

conf_neutron = configparser.ConfigParser()
conf_neutron.read('/etc/neutron/neutron.conf')

conf_neutron['database']['connection'] = 'mysql+pymysql://{NEUTRON_DATABASE_USER}:{NEUTRON_DATABASE_PASSWORD}@{NEUTRON_DATABASE_HOST}:{NEUTRON_DATABASE_PORT}/{NEUTRON_DATABASE_SCHEME}'.format(
    **os.environ)

conf_neutron['DEFAULT']['transport_url'] = 'rabbit://openstack:{RABBIT_PASS}@{HOST_INTERNAL_RABBITMQ}:5672/'.format(
    **os.environ)
conf_neutron['DEFAULT']['core_plugin'] = 'ml2'
conf_neutron['DEFAULT']['service_plugins'] = 'router'
conf_neutron['DEFAULT']['allow_overlapping_ips'] = 'true'
conf_neutron['DEFAULT']['auth_strategy'] = 'keystone'
conf_neutron['DEFAULT']['notify_nova_on_port_status_changes'] = 'true'
conf_neutron['DEFAULT']['notify_nova_on_port_data_changes'] = 'true'

conf_neutron['keystone_authtoken']['www_authenticate_uri'] = '{KEYSTONE_PUBLIC_ENDPOINT}'.format(
    **os.environ)
conf_neutron['keystone_authtoken']['auth_url'] = '{KEYSTONE_INTERNAL_ENDPOINT}'.format(
    **os.environ)
conf_neutron['keystone_authtoken']['memcached_servers'] = '{HOST_INTERNAL_MEMCACHED}:11211'.format(
    **os.environ)
conf_neutron['keystone_authtoken']['auth_type'] = 'password'
conf_neutron['keystone_authtoken']['project_domain_name'] = 'Default'
conf_neutron['keystone_authtoken']['user_domain_name'] = 'Default'
conf_neutron['keystone_authtoken']['project_name'] = 'service'
conf_neutron['keystone_authtoken']['username'] = os.environ['NEUTRON_USER']
conf_neutron['keystone_authtoken']['password'] = os.environ['NEUTRON_PASS']

conf_neutron['nova']['auth_url'] = '{KEYSTONE_INTERNAL_ENDPOINT}'.format(
    **os.environ)
conf_neutron['nova']['auth_type'] = 'password'
conf_neutron['nova']['project_domain_name'] = 'default'
conf_neutron['nova']['user_domain_name'] = 'default'
conf_neutron['nova']['region_name'] = os.environ['REGION_ID']
conf_neutron['nova']['project_name'] = 'service'
conf_neutron['nova']['username'] = os.environ['NOVA_USER']
conf_neutron['nova']['password'] = os.environ['NOVA_PASS']

conf_neutron['oslo_concurrency']['lock_path'] = '/var/lib/neutron/tmp'

with open('/etc/neutron/neutron.conf', 'w') as f_conf_neutron:
    conf_neutron.write(f_conf_neutron)

    # metadata_agent
conf_neutron_agent = configparser.ConfigParser()
conf_neutron_agent.read('/etc/neutron/metadata_agent.ini')

conf_neutron_agent['DEFAULT']['nova_metadata_host'] = os.environ['HOST_INTERNAL_NOVA']
conf_neutron_agent['DEFAULT']['metadata_proxy_shared_secret'] = os.environ['METADATA_SECRET']

with open('/etc/neutron/metadata_agent.ini', 'w') as f_conf_neutron_agent:
    conf_neutron_agent.write(f_conf_neutron_agent)

    # dhcp_agent
conf_neutron_dhcp_agent = configparser.ConfigParser()
conf_neutron_dhcp_agent.read('/etc/neutron/dhcp_agent.ini')

conf_neutron_dhcp_agent['DEFAULT']['interface_driver'] = 'linuxbridge'
conf_neutron_dhcp_agent['DEFAULT']['dhcp_driver'] = 'neutron.agent.linux.dhcp.Dnsmasq'
conf_neutron_dhcp_agent['DEFAULT']['enable_isolated_metadata'] = 'true'

with open('/etc/neutron/dhcp_agent.ini', 'w') as f_conf_neutron_dhcp_agent:
    conf_neutron_dhcp_agent.write(f_conf_neutron_dhcp_agent)

    # l3_agent
conf_neutron_l3_agent = configparser.ConfigParser()
conf_neutron_l3_agent.read('/etc/neutron/l3_agent.ini')

conf_neutron_l3_agent['DEFAULT']['interface_driver'] = 'linuxbridge'

with open('/etc/neutron/l3_agent.ini', 'w') as f_conf_neutron_l3_agent:
    conf_neutron_l3_agent.write(f_conf_neutron_l3_agent)

    # linuxbridge_agent
conf_neutron_linuxbridge_agent = configparser.ConfigParser()
conf_neutron_linuxbridge_agent.read(
    '/etc/neutron/plugins/ml2/linuxbridge_agent.ini')

conf_neutron_linuxbridge_agent['linux_bridge']['physical_interface_mappings'] = 'provider:{PROVIDER_INTERFACE_NAME}'.format(
    **os.environ)

conf_neutron_linuxbridge_agent['vxlan']['enable_vxlan'] = 'true'
conf_neutron_linuxbridge_agent['vxlan']['local_ip'] = socket.gethostbyname(
    os.environ['HOST_VLAN_CONTROLLER'])
conf_neutron_linuxbridge_agent['vxlan']['l2_population'] = 'true'

conf_neutron_linuxbridge_agent['securitygroup']['enable_security_group'] = 'true'
conf_neutron_linuxbridge_agent['securitygroup']['firewall_driver'] = 'neutron.agent.linux.iptables_firewall.IptablesFirewallDriver'

with open('/etc/neutron/plugins/ml2/linuxbridge_agent.ini', 'w') as f_conf_neutron_linuxbridge_agent:
    conf_neutron_linuxbridge_agent.write(f_conf_neutron_linuxbridge_agent)

    # ml2_conf
conf_neutron_ml2_conf = configparser.ConfigParser()
conf_neutron_ml2_conf.read('/etc/neutron/plugins/ml2/ml2_conf.ini')

conf_neutron_ml2_conf['ml2']['type_drivers'] = 'flat,vlan,vxlan'
conf_neutron_ml2_conf['ml2']['tenant_network_types'] = 'vxlan'
conf_neutron_ml2_conf['ml2']['mechanism_drivers'] = 'linuxbridge,l2population'
conf_neutron_ml2_conf['ml2']['extension_drivers'] = 'port_security'

conf_neutron_ml2_conf['ml2_type_flat']['flat_networks'] = 'provider'

conf_neutron_ml2_conf['ml2_type_vxlan']['vni_ranges'] = '1:1000'

conf_neutron_ml2_conf['securitygroup']['enable_ipset'] = 'true'

with open('/etc/neutron/ml2/ml2_conf.ini', 'w') as f_conf_neutron_ml2_conf:
    conf_neutron_ml2_conf.write(f_conf_neutron_ml2_conf)
