{%- from slspath ~ '/map.j2' import version, osarch -%}

zypper:
  repositories:
    SLE-Module-Basesystem-POOL:
      baseurl: http://smt-internal.infra.opensuse.org/repo/$RCE/SUSE/Products/SLE-Module-Basesystem/{{ version }}/{{ osarch }}/product/
      priority: 99
      refresh: False
    SLE-Module-Basesystem-UPDATES:
      baseurl: http://smt-internal.infra.opensuse.org/repo/$RCE/SUSE/Updates/SLE-Module-Basesystem/{{ version }}/{{ osarch }}/update/
      priority: 99
      refresh: True
    SLE-Product-SLES-POOL:
      baseurl: http://smt-internal.infra.opensuse.org/repo/$RCE/SUSE/Products/SLE-Product-SLES/{{ version }}/{{ osarch }}/product/
      priority: 99
      refresh: False
    SLE-Product-SLES-UPDATES:
      baseurl: http://smt-internal.infra.opensuse.org/repo/$RCE/SUSE/Updates/SLE-Product-SLES/{{ version }}/{{ osarch }}/update/
      priority: 99
      refresh: True
