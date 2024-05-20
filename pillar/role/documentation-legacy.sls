{%- set website = 'doc.opensuse.org' %}
apache_httpd:
  vhosts:
    doc:
      listen: '{{ grains['fqdn_ip6'][0] }}:8080'
      ServerName: {{ website }}
      ServerAdmin: webmaster@opensuse.org
      Documentroot: /srv/www/vhosts-legacy/doc-htdocs
      Directory:
        /srv/www/vhosts-legacy/doc-htdocs:
          Options: FollowSymLinks
          AllowOverride: All
          Require: all granted
      RedirectMatch:
        ^(/products/other/WebYaST/webyast-(vendor|user))$: https://doc.opensuse.org/$1_sd/
        ^(/products/other/WebYaST/webyast-(vendor|user))/(.*)$: https://doc.opensuse.org/$1_sd/$3
        ^/products/opensuse/(openSUSE[^/]*/.*): https://doc.opensuse.org/documentation/html/$1
        ^/documentation/.*/openSUSE/(opensuse-|book\.)tuning: https://doc.opensuse.org/book/opensuse-system-analysis-and-tuning-guide
        ^/documentation/.*/openSUSE/(opensuse-|book\.)kvm: https://doc.opensuse.org/book/opensuse-virtualization-with-kvm
        ^/documentation/.*/openSUSE/(opensuse-|book\.)security: https://doc.opensuse.org/book/opensuse-security-guide
        ^/documentation/.*/openSUSE/(opensuse-|book\.opensuse\.)reference: https://doc.opensuse.org/book/opensuse-reference
        ^/documentation/.*/openSUSE/(opensuse-|book\.opensuse\.)startup: https://doc.opensuse.org/book/opensuse-start-up
