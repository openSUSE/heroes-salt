{%- set kvmdir = '/data0/kvm' %}

include:
  - infra

infrastructure:
  kvm_topdir: {{ kvmdir }}
  libvirt_domaindir: {{ kvmdir }}/domains

zypper:
  packages:
    python3-libvirt-python: {}
