include:
  - secrets.include_id

profile:
  forgejo:
    runner:
      config:
        log:
          level: info
          job_level: info
        runner:
          capacity: 25
          timeout: 1h
          shutdown_timeout: 15m
          fetch_timeout: 20s
          fetch_interval: 3s
          report_interval: 2s
          labels:
            - normal:docker://registry.opensuse.org/opensuse/leap:16.0
        container:
          enable_ipv6: true
          privileged: true
          workdir_parent: /srv/work
