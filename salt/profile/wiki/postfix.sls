# just a simple setup for outgoing mails (watchlist notifications etc.)
postfix:
  pkg.installed:
    - pkgs:
      - postfix
  service.running:
    - enable: True
