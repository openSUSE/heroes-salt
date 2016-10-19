zypper:
  repositories:
    openSUSE:infrastructure:
      baseurl: http://download.opensuse.org/repositories/openSUSE:/infrastructure/SLE_11_SP4
      priority: 100
      refresh: True
    SLE-SDK:
      baseurl: http://smt-internal.opensuse.org/repo/$RCE/SLE11-SDK-SP4-Pool/sle-11-x86_64
      priority: 99
      refresh: True
    SLE-SDK-Update:
      baseurl: http://smt-internal.opensuse.org/repo/$RCE/SLE11-SDK-SP4-Updates/sle-11-x86_64
      priority: 99
      refresh: True
    SLE-SERVER:
      baseurl: http://smt-internal.opensuse.org/repo/$RCE/SLES11-SP4-Pool/sle-11-x86_64
      priority: 99
      refresh: True
    SLE-SERVER-Update:
      baseurl: http://smt-internal.opensuse.org/repo/$RCE/SLES11-SP4-Updates/sle-11-x86_64
      priority: 99
      refresh: True
