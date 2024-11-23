include:
  - .common

{%- set kvmdir = '/data0/kvm' %}
infrastructure:
  image_type: qcow2
  kvm_topdir: {{ kvmdir }}
  libvirt_domaindir: {{ kvmdir }}/domains

libvirt:
  guests:
    on_boot: start
    on_shutdown: shutdown
    parallel_shutdown: 4
    start_delay: 2
