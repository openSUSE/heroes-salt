include:
  - keepalived
  - .keepalived-scripts

profile_ha_kmod_nf_conntrack:
  kmod.present:
    - name: nf_conntrack
    - persist: true
    - order: 1
