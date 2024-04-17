nfs:
  mount:
    {{ grains['host'] }}:
      location: backup:/
      mountpoint: /backup
      opts:
        - _netdev
        - defaults
        - nofail
