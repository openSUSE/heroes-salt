rsync:
  defaults:
    'gid': 'users'
    'read only': 'true'
    'use chroot': 'true'
    'transfer logging': 'true'
    'log format': '%h %o %f %l %b'
    'log file': '/var/log/rsyncd.log'
    'pid file': '/var/run/rsyncd.pid'
    # 'hosts allow': 'trusted.hosts'
    'slp refresh': '300'
    'use slp': 'false'