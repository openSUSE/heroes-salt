limits:
  users:
    '*':
      - limit_type: hard
        limit_item: nproc
        limit_value: 1700
      - limit_type: soft
        limit_item: nproc
        limit_value: 1200
    root:
      - limit_type: hard
        limit_item: nproc
        limit_value: 3000
      - limit_type: soft
        limit_item: nproc
        limit_value: 1850
