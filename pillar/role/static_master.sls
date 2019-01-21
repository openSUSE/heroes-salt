{% if salt['grains.get']('include_secrets', True) %}
include:
  - secrets.role.static_master
{% endif %}

profile:
  web_static:
    expected_gitmodules:
      # expected .gitmodules files and their sha256sum
      # this ensures we notice .gitmodules changes and can update the salt code accordingly
      ./static.opensuse.org/.gitmodules: 19479ebe1afda2dd4ba774f572546ef6c549822c0ebd4983b644bf4ea8183930
      ./static.opensuse.org/hosts/www.o.o/.gitmodules: e2da74eed7fcfed7f08669f6bff9d89e0d5f2f02ee8f2c6ad43afe4996cc57f1
    git_repos:
      # branch defaults to 'master' if not specified
      html5test.opensuse.org:
        branch: opensuse
        repo: https://github.com/openSUSE/HTML5test.git
      shop.opensuse.org:
        repo: https://github.com/openSUSE/shop.o.o.git
      static.opensuse.org:
        repo: https://github.com/openSUSE/static.opensuse.org.git
      static.opensuse.org/hosts/www.o.o:
        repo: https://github.com/openSUSE/old-landing-page.git
      static.opensuse.org/login:
        repo: https://github.com/openSUSE/openSUSE-login
      static.opensuse.org/themes:
        repo: https://github.com/openSUSE/opensuse-themes
      static.opensuse.org/chameleon:
        repo: https://github.com/openSUSE/opensuse-theme-chameleon
      static.opensuse.org/hosts/www.o.o/searchPage:
        branch: gh-pages
        repo: https://github.com/opensuse/searchPage.git
      studioexpress.opensuse.org:
        repo: https://github.com/openSUSE/studioexpress-landing.git
    server_list:
      - narwal5.infra.opensuse.org
      - narwal6.infra.opensuse.org
    # ssh_known_hosts: use   ssh-keyscan 192.168.122.x,narwalX.infra.opensuse.org | grep nist
    ssh_known_hosts: |
        KNOWN_HOSTS_HERE - fill when narwal5 and narwal6 are available
    # ssh_private_key included from pillar/secrets/role/static_master.sls
    # ssh_pubkey (for authorized_keys) is in pillar/role/web_static.sls
