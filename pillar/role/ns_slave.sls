zypper:
  packages:
    pdns-backend-sqlite3: {}
    sqlite3: {}
  repositories:
    server:dns:
      baseurl: https://download.opensuse.org/repositories/server:/dns/openSUSE_42.2
      gpgautoimport: True
      priority: 101
      refresh: True
