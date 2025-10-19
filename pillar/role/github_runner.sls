{%- if salt['grains.get']('include_secrets', True) %}
include:
  - secrets.role.github_runner
{%- endif %}

firewalld:
  enabled: true
  zones:
    fire:
      description: Fireactions traffic forwarding
      interfaces:
        - fireactions-br0
      forward: true

sysctl:
  params:
    net.ipv6.conf.all.forwarding: 1  # does it really need to be all?

zypper:
  packages:
    cni-plugins: {}
    cni: {}
    containerd-ctr: {}
    containerd: {}
    fireactions: {}
    firecracker: {}
    firectl: {}
    tc-redirect-tap: {}
  repositories:
    openSUSE:infrastructure:fireactions:
      baseurl: http://$mirror_int/repositories/openSUSE:/infrastructure:/fireactions/$releasever/
      gpgcheck: 1
      priority: 105
      refresh: true
