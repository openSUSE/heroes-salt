{%- set kvmdir = '/data0/kvm' %}

infrastructure:
  kvm_topdir: {{ kvmdir }}
  libvirt_domaindir: {{ kvmdir }}/domains
