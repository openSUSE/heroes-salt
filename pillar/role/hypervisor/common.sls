{%- set kvmdir = '/data0/kvm' %}

include:
  - infra

infrastructure:
  kvm_topdir: {{ kvmdir }}
  libvirt_domaindir: {{ kvmdir }}/domains
