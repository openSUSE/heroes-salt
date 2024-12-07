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
