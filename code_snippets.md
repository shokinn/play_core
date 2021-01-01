# Code snippets

## Docker

### Create a docker network (for e.g. static IPs)

```
vars:
  docker_network_name: "misc_net"

- name: Create container network
  docker_network:
    name: "{{ docker_network_name }}"
    driver: bridge
    driver_options:
      com.docker.network.bridge.name: 'docker1'
      com.docker.network.bridge.enable_ip_masquerade: true
      com.docker.network.bridge.enable_icc: true
      com.docker.network.bridge.host_binding_ipv4: '0.0.0.0'
      com.docker.network.driver.mtu: '1500'
    ipam_options: 
      subnet: '172.23.0.0/16'
      gateway: '172.23.0.1'
      iprange: '172.23.42.0/24'
```