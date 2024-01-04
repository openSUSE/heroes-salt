{% if salt['grains.get']('include_secrets', True) %}
include:
  - secrets.role.static_master
{% endif %}

profile:
  web_static:
    expected_gitmodules:
      # expected .gitmodules files and their sha256sum
      # this ensures we notice .gitmodules changes and can update the salt code accordingly
      ./static.opensuse.org/.gitmodules: 18c60f122666bed4d7c105a7a3150bb3828548f05110835ad206bbac13c58ba5
    git_repos:
      # branch defaults to 'master' if not specified
      html5test.opensuse.org:
        branch: opensuse
        repo: https://github.com/openSUSE/HTML5test.git
      people.opensuse.org:
        branch: gh-pages
        repo: https://github.com/openSUSE/people.git
      shop.opensuse.org:
        repo: https://github.com/openSUSE/shop.o.o.git
      static.opensuse.org:
        repo: https://github.com/openSUSE/static.opensuse.org.git
      static.opensuse.org/login:
        repo: https://github.com/openSUSE/openSUSE-login
      static.opensuse.org/themes:
        repo: https://github.com/openSUSE/opensuse-themes
      static.opensuse.org/chameleon:
        repo: https://github.com/openSUSE/chameleon.git
      static.opensuse.org/chameleon-2.0:
        branch: rel-2.0
        repo: https://github.com/openSUSE/chameleon.git
      static.opensuse.org/chameleon-3.0:
        branch: rel-3.0
        repo: https://github.com/openSUSE/chameleon.git
      studioexpress.opensuse.org:
        repo: https://github.com/openSUSE/studioexpress-landing.git
      lizards.opensuse.org:
        repo: https://github.com/openSUSE/lizards.git
      www.opensuse.org:
        repo: https://github.com/openSUSE/landing-page.git
        # www.o.o/openid/ is not handled by narwal*, haproxy forwards /openid/ to a different server
      community.opensuse.org/ebooks:
        repo: https://github.com/openSUSE/ebooks-archives.git
        branch: main
      community.opensuse.org/meetings:
        repo: https://github.com/openSUSE/meetings-archives.git
        branch: main
      ignite.opensuse.org:
        repo: https://github.com/openSUSE/fuel-ignition.git
        branch: gh-pages
      mirrors.opensuse.org:
        repo: https://github.com/openSUSE/mirrors-static.git
        branch: main
    server_list:
      - narwal4.infra.opensuse.org
      - narwal5.infra.opensuse.org
      - narwal6.infra.opensuse.org
      - narwal7.infra.opensuse.org
      - narwal8.infra.opensuse.org
    # ssh_known_hosts: use   ssh-keyscan 192.168.122.x,narwalX.infra.opensuse.org | grep nist
    ssh_known_hosts:
        - >-
          2a07:de40:b27e:64::c0a8:4305,narwal4.infra.opensuse.org
          ecdsa-sha2-nistp256
          AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBAHNjOSOrqerk0fuMkmdtOncz4P+s/7vfQdlolea47rf+HY9sE7dsmuyktV6D1/y+4p6iUJyF3k07chQ1eEjSD0=
        - >-
          2a07:de40:b27e:1203::e5,narwal5.infra.opensuse.org
          ecdsa-sha2-nistp256
          AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBCbQYnUEulrX3eOcDJB23gIlSUojFL1+s1ugd1t98EDgoc+fWGvT0qX5iMS3rDA6SRwsu20/lQMhLmsS8G0Gi3w=
        - >-
          2a07:de40:b27e:1203::e6,narwal6.infra.opensuse.org
          ecdsa-sha2-nistp256
          AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBOQE0iipddghKK64jQhTNzN+oUJrBDroWlA2QGZXGFm1qZtWyBdmtzU58bLJyceMW5urKBMLCPWCHZ1oyxtNtOA=
        - >-
          2a07:de40:b27e:1203::e7,narwal7.infra.opensuse.org
          ecdsa-sha2-nistp256
          AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBF210DU6QxFc4eelUjwJR8AnmdF/PjFmnRFU/A69LbGDqABql4sHWhl2n0pMJifrjBBCEyKeNt64apyIaTlDZ7M=
        - >-
          2a07:de40:b27e:1203::e8,narwal8.infra.opensuse.org
          ecdsa-sha2-nistp256
          AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBDXPM7fBjVlldCWjhswjJTa01QvCZLwtTv38pIAVpVpzyJCuj+ZCZdfx6GZp/FBqZabVnI7kufkrI9zcU8RpWp0=
    # ssh_private_key included from pillar/secrets/role/static_master.sls
    # ssh_pubkey (for authorized_keys) is in pillar/role/web_static.sls

zypper:
  packages:
    rsync: {}
