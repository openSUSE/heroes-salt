{%- if salt['grains.get']('include_secrets', True) %}
include:
  - secrets.role.salt.syndic
{%- endif %}

salt:
  master:
    fileserver_backend:
      - roots
    file_roots:
      # consider changing back to __env__ after a solution for https://github.com/saltstack/salt/issues/62967
      production:
        - /srv/salt
        - /usr/share/salt-formulas/states
        - /srv/formulas
    pillar_merge_lists: True
    pillar_source_merging_strategy: smart
    pillar_roots:
      __env__:
        - /srv/pillar
    # TODO
    #syndic_master: seidr.infra.opensuse.org
    #syndic_user: salt
    top_file_merging_strategy: same

infrastructure:
  salt:
    formulas:
      {%- for formula in [
            'apache_httpd',
            'backupscript',
            'bootloader',
            'grains',
            'infrastructure',
            'juniper_junos',
            'libvirt',
            'lldpd',
            'lock',
            'lunmap',
            'mtail',
            'multipath',
            'network',
            'os_update',
            'php_fpm',
            'rebootmgr',
            'redis',
            'redmine',
            'rsync',
            'smartmontools',
            'status_mail',
            'suse_ha',
            'sysconfig',
            'tayga',
            'zypper',
          ]
      %}
      - {{ formula }}-formula
      {%- endfor %}
    git:
      formulas:
        repository: https://gitlab.infra.opensuse.org/infra/salt-formulas-git.git
    scriptconfig:
      ssh_key: /root/.ssh/salt-mm

rsync:
  modules:
    salt-push:
      path: /srv/salt-git/
      comment: /srv/salt-git/
      list: 'false'
      uid: root
      gid: salt
      auth users: saltpush
      name converter: /usr/local/bin/nameconvert.py
      numeric ids: false
      read only: false
      hosts allow:
        {%- if grains.get('site') in ['prg2', 'slc1'] %}
        - 2a07:de40:b27e:1203::126 # gitlab-runner1
        - 2a07:de40:b27e:1203::127 # gitlab-runner2
        {%- else %}
        - 172.16.164.126
        - 172.16.164.127
        {%- endif %}
