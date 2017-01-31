zypper:
  repositories:
    openSUSE:infrastructure:
      baseurl: http://download.opensuse.org/repositories/openSUSE:/infrastructure/SLE_12_SP2
      gpgcheck: 0
      priority: 100
      refresh: True
    SLE-Module-Adv-Systems-Management:
      baseurl: http://smt-internal.opensuse.org/repo/$RCE/SUSE/Products/SLE-Module-Adv-Systems-Management/12/x86_64/product
      priority: 99
      refresh: True
    SLE-Module-Adv-Systems-Management-Update:
      baseurl: http://smt-internal.opensuse.org/repo/$RCE/SUSE/Updates/SLE-Module-Adv-Systems-Management/12/x86_64/update
      priority: 99
      refresh: True
    SLE-Module-Web-Scripting:
      baseurl: http://smt-internal.opensuse.org/repo/$RCE/SUSE/Products/SLE-Module-Web-Scripting/12/x86_64/product
      priority: 99
      refresh: True
    SLE-Module-Web-Scripting-Update:
      baseurl: http://smt-internal.opensuse.org/repo/$RCE/SUSE/Updates/SLE-Module-Web-Scripting/12/x86_64/update
      priority: 99
      refresh: True
    SLE-SDK:
      baseurl: http://smt-internal.opensuse.org/repo/$RCE/SUSE/Products/SLE-SDK/12-SP2/x86_64/product
      priority: 99
      refresh: True
    SLE-SDK-Update:
      baseurl: http://smt-internal.opensuse.org/repo/$RCE/SUSE/Updates/SLE-SDK/12-SP2/x86_64/update
      priority: 99
      refresh: True
    SLE-SERVER:
      baseurl: http://smt-internal.opensuse.org/repo/$RCE/SUSE/Products/SLE-SERVER/12-SP2/x86_64/product
      priority: 99
      refresh: True
    SLE-SERVER-Update:
      baseurl: http://smt-internal.opensuse.org/repo/$RCE/SUSE/Updates/SLE-SERVER/12-SP2/x86_64/update
      priority: 99
      refresh: True
