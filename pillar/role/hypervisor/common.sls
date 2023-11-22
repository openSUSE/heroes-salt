{%- set kvmdir = '/data0/kvm' %}

include:
  - infra

infrastructure:
  kvm_topdir: {{ kvmdir }}
  libvirt_domaindir: {{ kvmdir }}/domains

os-update:
  ignore_services_from_restart:
    - virtlockd
    - virtlogd

zypper:
  packages:
    python3-libvirt-python: {}
