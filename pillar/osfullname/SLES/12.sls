{%- from slspath ~ '/map.j2' import version -%}

zypper:
  repositories:
    SLE-HA:
      baseurl: http://smt-internal.infra.opensuse.org/repo/$RCE/SUSE/Products/SLE-HA/{{ version }}/x86_64/product/
      priority: 99
      refresh: False
    SLE-HA-Update:
      baseurl: http://smt-internal.infra.opensuse.org/repo/$RCE/SUSE/Updates/SLE-HA/{{ version }}/x86_64/update/
      priority: 99
      refresh: True
    SLE-Module-Adv-Systems-Management:
      baseurl: http://smt-internal.infra.opensuse.org/repo/$RCE/SUSE/Products/SLE-Module-Adv-Systems-Management/12/x86_64/product/
      priority: 99
      refresh: False
    SLE-Module-Adv-Systems-Management-Update:
      baseurl: http://smt-internal.infra.opensuse.org/repo/$RCE/SUSE/Updates/SLE-Module-Adv-Systems-Management/12/x86_64/update/
      priority: 99
      refresh: True
    SLE-Module-Web-Scripting:
      baseurl: http://smt-internal.infra.opensuse.org/repo/$RCE/SUSE/Products/SLE-Module-Web-Scripting/12/x86_64/product/
      priority: 99
      refresh: False
    SLE-Module-Web-Scripting-Update:
      baseurl: http://smt-internal.infra.opensuse.org/repo/$RCE/SUSE/Updates/SLE-Module-Web-Scripting/12/x86_64/update/
      priority: 99
      refresh: True
    SLE-SDK:
      baseurl: http://smt-internal.infra.opensuse.org/repo/$RCE/SUSE/Products/SLE-SDK/{{ version }}/x86_64/product/
      priority: 99
      refresh: False
    SLE-SDK-Update:
      baseurl: http://smt-internal.infra.opensuse.org/repo/$RCE/SUSE/Updates/SLE-SDK/{{ version }}/x86_64/update/
      priority: 99
      refresh: True
    SLE-SERVER:
      baseurl: http://smt-internal.infra.opensuse.org/repo/$RCE/SUSE/Products/SLE-SERVER/{{ version }}/x86_64/product/
      priority: 99
      refresh: False
    SLE-SERVER-Update:
      baseurl: http://smt-internal.infra.opensuse.org/repo/$RCE/SUSE/Updates/SLE-SERVER/{{ version }}/x86_64/update/
      priority: 99
      refresh: True
