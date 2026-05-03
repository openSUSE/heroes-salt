include:
  - .

profile:
  forgejo:
    runner:
      config:
        server:
          connections:
            forgejo-internal:
              url: https://git.infra.opensuse.org
