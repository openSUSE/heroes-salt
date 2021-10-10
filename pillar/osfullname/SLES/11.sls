{% set osminorrelease = salt['grains.get']('osrelease_info')[1]|string %}

zypper:
  repositories:
    SLE-SDK:
      baseurl: http://smt-internal.infra.opensuse.org/repo/$RCE/SLE11-SDK-SP{{ osminorrelease }}-Pool/sle-11-x86_64/
      priority: 99
      refresh: False
    SLE-SDK-Update:
      baseurl: http://smt-internal.infra.opensuse.org/repo/$RCE/SLE11-SDK-SP{{ osminorrelease }}-Updates/sle-11-x86_64/
      priority: 99
      refresh: True
    SLE-SERVER:
      baseurl: http://smt-internal.infra.opensuse.org/repo/$RCE/SLES11-SP{{ osminorrelease }}-Pool/sle-11-x86_64/
      priority: 99
      refresh: False
    SLE-SERVER-Update:
      baseurl: http://smt-internal.infra.opensuse.org/repo/$RCE/SLES11-SP{{ osminorrelease }}-Updates/sle-11-x86_64/
      priority: 99
      refresh: True
