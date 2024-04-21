{%- set website = 'doc.opensuse.org' %}
apache:
  vhosts:
    doc:
      listen: '{{ grains['fqdn_ip6'][0] }}:8080'
      ServerName: {{ website }}
      ServerAlias: >-
        rtfm.opensuse.org
        docs.opensuse.org
        activedoc.opensuse.org
        www.activedoc.opensuse.org
      ServerAdmin: webmaster@opensuse.org
      Documentroot: /srv/www/vhosts-legacy/doc-htdocs
      Alias:
        /release-notes: /srv/www/vhosts-legacy/release-notes-htdocs
      Directory:
        /srv/www/vhosts-legacy/doc-htdocs:
          Options: FollowSymLinks
          AllowOverride: All
          Require: all granted
        /srv/www/vhosts-legacy/release-notes-htdocs:
          Options: >-
            Indexes
            MultiViews
          AllowOverride: None
          Require: all granted
      Rewrite: |
        RewriteCond %{SERVER_NAME} ^(docs|(www\.)?activedoc|rtfm)\.opensuse\.org$
        RewriteRule ^/(.*)$ https://doc.opensuse.org/$1 [R=seeother,L]
      RedirectMatch:
        ^(/products/other/WebYaST/webyast-(vendor|user))$: https://doc.opensuse.org/$1_sd/
        ^(/products/other/WebYaST/webyast-(vendor|user))/(.*)$: https://doc.opensuse.org/$1_sd/$3
        ^/products/opensuse/(openSUSE[^/]*/.*): https://doc.opensuse.org/documentation/html/$1
        ^/documentation/.*/openSUSE/(opensuse-|book\.)tuning: https://doc.opensuse.org/book/opensuse-system-analysis-and-tuning-guide
        ^/documentation/.*/openSUSE/(opensuse-|book\.)kvm: https://doc.opensuse.org/book/opensuse-virtualization-with-kvm
        ^/documentation/.*/openSUSE/(opensuse-|book\.)security: https://doc.opensuse.org/book/opensuse-security-guide
        ^/documentation/.*/openSUSE/(opensuse-|book\.opensuse\.)reference: https://doc.opensuse.org/book/opensuse-reference
        ^/documentation/.*/openSUSE/(opensuse-|book\.opensuse\.)startup: https://doc.opensuse.org/book/opensuse-start-up
