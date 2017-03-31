limits:
  users:
    '*':
      - limit_type: hard
        limit_item: nofile
        limit_value: 8192
      - limit_type: soft
        limit_item: nofile
        limit_value: 8192
