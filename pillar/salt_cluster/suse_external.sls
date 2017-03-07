salt:
  master:
    ext_pillar:
      - git:
          - production gitlab@mickey.opensuse.org:suse/salt_external.git:
              - env: production
              - root: pillar
              - privkey: /srv/salt/.ssh/salt_gitlab_oo_infra_salt
              - pubkey: /srv/salt/.ssh/salt_gitlab_oo_infra_salt.pub
  minion:
    master: kovu.opensuse.org
