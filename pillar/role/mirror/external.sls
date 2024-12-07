include:
  - .

firewalld:
  enabled: true
  services:
    rsync-mirror:
      description: openSUSE pull/push rsync mirror
      ports:
        tcp:
          - 873
          - 874
  zones:
    backchannel:
      interfaces:
        - os-mirror-bc
      services:
        - nfs
    internal:
      interfaces:
        - os-mirror
      services:
        - http
        - rsync-mirror

nfs:
  server:
    exports:
      /srv/ftp/pub:
        # SLC1 os-mirror-bc
        #   can be conditionalized for other locations when needed
        fd4d:665a:d688:1708::/64:
          - fsid=0
          - no_subtree_check
          - ro
