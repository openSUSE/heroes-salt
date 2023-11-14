include:
  - .common
  - firewalld
  - multipath
  - suse_ha
  - suse_ha.resources
  - infrastructure.suse_ha.resources
  - lunmap

{%- set nfs_server = salt['pillar.get']('role:hypervisor:cluster:nfs_server', None) %}
{%- if nfs_server is not none %}
kvm_mount:
  mount.fstab_present:
    - name: {{ nfs_server }}:/kvm
    - fs_file: /kvm
    - fs_vfstype: nfs4
    - not_change: true
{%- endif %}
