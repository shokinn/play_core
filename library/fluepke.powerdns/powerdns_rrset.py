#!/usr/bin/env python
# -*- coding: utf-8 -*-

DOCUMENTATION = '''
---
module: powerdns_rrset
status: preview
short_description: Manage PowerDNS RRsets
description:
  - Create, update or delete a PowerDNS records using API
requirements:
  - python-powerdns (0.2.1)
seealso
  - "https://doc.powerdns.com/authoritative/http-api/zone.html#rrset"
options:
  name:
    description:
      - Name for record set (e.g. “www.powerdns.com.”)
    required: true
  type:
    description:
      - Type of this record (e.g. “A”, “PTR”, “MX”)
    required: false
    choices: ['A', 'AAAA', 'AFSDB', 'ALIAS', 'CAA', 'CERT', 'CDNSKEY', 'CDS', 'CNAME', 'DNSKEY', 'DNAME', 'DS', 'HINFO', 'KEY', 'LOC', 'MX', 'NAPTR', 'NS', 'NSEC', 'NSEC3', 'NSEC3PARAM', 'OPENPGPKEY', 'PTR', 'RP', 'RRSIG', 'SOA', 'SPF', 'SSHFP', 'SRV', 'TKEY', 'TSIG', 'TLSA', 'SMIMEA', 'TXT', 'URI']
    default: None
  ttl:
    description:
      - DNS TTL of the records, in seconds.
    required: false
    default: 86400
  state:
    description:
      - Status of the RRset
    choices: ['present', 'absent']
    required: false
    default: present
  records:
    description:
      – All records in this RRSet
    type: list
  zone:
    description:
      - Zone name (canonical)
    required: true
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
- powerdns_record:
    name: host01.internal.example.com
    type: A
    ttl: 3600
    state: present
    records:
      - 192.168.1.23
      - 192.168.4.56
    zone: internal.example.com
    pdns_api_url: 'https://127.0.0.1:1234/api/v1'
    pdns_api_key: topsecret
    strict_ssl_checking: false
'''

from ansible.module_utils.basic import AnsibleModule
try:
    import powerdns
except ImportError:
    raise Exception('powerdns_record requires "python-powerdns" install with "pip install python-powerdns"')

def run_module():
    module_args = dict(
        name = dict(type='str', required=True),
        type = dict(type='str', required=True, choices=['A', 'AAAA', 'AFSDB', 'ALIAS', 'CAA', 'CERT', 'CDNSKEY', 'CDS', 'CNAME', 'DNSKEY', 'DNAME', 'DS', 'HINFO', 'KEY', 'LOC', 'MX', 'NAPTR', 'NS', 'NSEC', 'NSEC3', 'NSEC3PARAM', 'OPENPGPKEY', 'PTR', 'RP', 'RRSIG', 'SOA', 'SPF', 'SSHFP', 'SRV', 'TKEY', 'TSIG', 'TLSA', 'SMIMEA', 'TXT', 'URI']),
        ttl = dict(type='int', required=False, default=86400),
        state = dict(type='str', required=False, choices=['present', 'absent'], default='present'),
        records = dict(type='list', required=True),
        zone = dict(type='str', required=True),
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
        changed=False,
        reponse=''
    )
    api_client = powerdns.PDNSApiClient(
        api_endpoint = module.params['pdns_api_url'],
        api_key = module.params['pdns_api_key'],
        verify = module.params['strict_ssl_checking']
    )
    api = powerdns.PDNSEndpoint(api_client)
    api_server = api.servers[module.params['server_id']]
    zone = api_server.get_zone(module.params['zone'])
    rrset = powerdns.RRSet(
        name = module.params['name'],
        rtype = module.params['type'],
        records = module.params['records'],
        ttl = module.params['ttl']
    )

    rrset_present = is_rrset_present(zone, rrset)
    result['changed'] = ((module.params['state'] == 'present' and not rrset_present) or
        (module.params['state'] == 'absent' and rrset_present))

    if module.check_mode:
        return result
    if module.params['state'] == 'present':
        result['response'] = zone.create_records([rrset])
    else:
        result['response'] = zone.delete_record([rrset])

    module.exit_json(**result)


def is_rrset_present(zone, rrset):
    """Checks if a given rrset is present in a zone

    :param powerdns.Zone zone Zone to check for
    :param powerdns.RRSet rrset RRSet to check for
    """
    for present_rrset in zone.records:  # sic! zone.records should be rrsets to conform with pdns naming scheme ...
        if (present_rrset['name'] == rrset['name']
            and present_rrset['type'] == rrset['type']
            and present_rrset['ttl'] == rrset['ttl']
            and set([item['content'] for item in present_rrset['records']]) ==
                set([item['content'] for item in rrset['records']])):
            return True
    return False

def main():
    run_module()

if __name__ == '__main__':
    main()