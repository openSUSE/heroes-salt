grains:
  city: prague
  country: cz
  hostusage:
    - news.o.o
    - planet.o.o
  reboot_safe: yes

  aliases: []
  description: Webserver running jekyll-managed websites like news.o.o and planet.o.o
  documentation: []
  responsible:
    - hellcp
  partners: []
  weburls:
    - https://news.opensuse.org
    - https://planet.opensuse.org
roles:
  - jekyll_master
  - web_jekyll
