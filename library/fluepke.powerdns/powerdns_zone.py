#!/usr/bin/env python
# -*- coding: utf-8 -*-

DOCUMENTATION = '''
---
module: powerdns_zone
status: preview
short_description: Manage PowerDNS Zones
description:
  - Create, update or delete a PowerDNS zone using API
requirements:
  - python-powerdns (0.2.1)
seealso
  - "https://doc.powerdns.com/authoritative/http-api/zone.html#zone"
options:
  name:
    description:
      - Name for record set (e.g. “www.powerdns.com.”)
    required: true
  kind:
    description:
      - Zone kind, one of 'Native', 'Master', 'Slave'
    required: false
    choices: ['Native', 'Master', 'Slave']
    default: Master
  masters:
    description:
      - List of IP addresses configured as a master for this zone (“Slave” type zones only)
    type: list
    required: false
    default: []
  dnssec:
    description:
      - Whether or not this zone is DNSSEC signed.
      - (inferred from presigned being true XOR presence of at least one cryptokey with active being true)
    required: false
    default: false
  api_rectify:
    description:
      - Whether or not the zone will be rectified on data changes via the API
    required: false
    default: true
  state:
    description:
      - Status of the RRset
    choices: ['present', 'absent']
    required: false
    default: present
  pdns_api_url:
    description:
      - URL of the PowerDNS API
    required: false
    default: http://127.0.0.1:8001/api/v1
  pdns_api_key:
    description:
      - API Key to authenticate through PowerDNS API
    required: true
  strict_ssl_checking:
    description:
      - Disable strict certificate checking
    required: false
    default: true
  server_id:
    description:
      - The id of the server to retrieve
    required: false
    default: 0
author:
  - "Thomas Krahn (@nosmoht)"
  - "Fabian Lüpke (@fluepke)"
'''

EXAMPLES = '''
- powerdns_zone:
    name: host01.internal.example.com
    kind: master
    dnssec: true
    state: present
    pdns_api_url: 'https://127.0.0.1:1234/api/v1'
    pdns_api_key: topsecret
    strict_ssl_checking: false
'''

from ansible.module_utils.basic import AnsibleModule
try:
  # TODO: write own powerdns api implementation that does *not* suck
    import powerdns
except ImportError:
    raise Exception('powerdns_record requires "python-powerdns" install with "pip install python-powerdns"')

def run_module():
    module_args = dict(
        name = dict(type='str', required=True),
        kind = dict(type='str', required=False, choices=['Native', 'Master', 'Slave'], default='Master'),
        masters = dict(type='list', required=False, default=[]),
        dnssec = dict(type='bool', required=False, default=True),
        api_rectify = dict(type='bool', required=False, default=True),
        state = dict(type='str', required=False, choices=['present', 'absent'], default='present'),
        pdns_api_url = dict(type='str', required=False, default='http://127.0.0.1:8001/api/v1'),
        pdns_api_key = dict(type='str', required=True),
        strict_ssl_checking = dict(type='bool', required=False, default=True),
        server_id = dict(type='int', required=False, default=0)
    )
    module = AnsibleModule(
        argument_spec = module_args,
        supports_check_mode = True
    )
    result = dict(
        changed = False,
        reponse = ''
    )
    api_client = powerdns.PDNSApiClient(
        api_endpoint = module.params['pdns_api_url'],
        api_key = module.params['pdns_api_key'],
        verify = module.params['strict_ssl_checking']
    )
    api = powerdns.PDNSEndpoint(api_client)
    api_server = api.servers[module.params['server_id']]
    zone = api_server.get_zone(module.params['name'])

    if module.params['state'] == 'present' and zone == None:
      result['changed'] = True
    elif module.params['state'] == 'present' and zone != None:
      result['changed'] = not (zone.details['kind'] == module.params['kind']
        and set(zone.details['masters']) == set(module.params['masters'])
        and zone.details['dnssec'] == module.params['dnssec']
        and zone.details['api_rectify'] == module.params['api_rectify'])
    else:
      result['changed'] = zone != None

    if module.check_mode:
        return result
    if module.params['state'] == 'present':
        if zone != None:
          api_server.delete_zone(module.params['name'])  # *sigh*
        api_server.create_zone(
          name = module.params['name'],
          kind = module.params['kind'],
          nameservers = [],
          masters = module.params['masters']
          )
    elif module.params['state'] == 'absent' and zone != None:
        api_server.delete_zone(module.params['name'])

    module.exit_json(**result)

def main():
    run_module()

if __name__ == '__main__':
    main()
