# Infrastructure pillar

This pillar directory manages virtual machine and network resources as well as parts of the virtualization clusters hosting them.

## `hosts.yaml`

This is to configure virtual machines and their network connectivity.

Example, values enclosed in `< >` are to be substituted:

```
<hostname>:                       # short hostname, will turn into <hostname>.infra.opensuse.org
  cluster: <cluster>              # hypervisor cluster, needs to exist in clusters.yaml
  ram: 1024MB                     # memory, currently requires MB for min/max calculations
  vcpu: 1                         # CPU cores

  interfaces:

    # all possible interface options
    <interface name>:             # interface name inside the VM - should be "eth0" if there is only one
      type: <interface tye>       # "direct" (MacVTap) by default, "bridge" is possible for legacy bridges
      mode: <interface mode>      # "bridge" by default, "private" or "vepa" possible for the future
      source: <interface name>    # interface on the hypervisor to link with
      mac: '<MAC address>'        # unique MAC address for use inside the VM
      ip4: <IPv4 address>/<CIDR>  # IPv4 address
      ip6: <IPv6 address/<prefix> # IPv6 address

    # generic example for everyday VM's
    eth0:
      source: x-os-internal       # usually the name of a VLAN interface on the hypervisor
      mac: 'ff:ff:ff:ff:ff:fb'    # a unique MAC address - maybe we will add a script to generate one
      ip4: 192.0.2.2/24           # a free IPv4 address in said VLAN
      ip6: 2001:db8::b/32         # a free IPv6 address in said VLAN

  disks:

    # every VM should have at least a "root" disk
    root: 15G

    # further disks should be named "data$i"
    data0: 20G

  # the base OS image to apply - the "admin-minimal-xx_x" images should link to the latest build
  image: admin-minimal-15_5
```
