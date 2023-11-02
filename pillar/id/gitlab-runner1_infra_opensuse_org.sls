grains:
  city: prague
  country: cz
  hostusage:
    - gitlab runner
  reboot_safe: yes
  salt_cluster: opensuse
  virt_cluster: falkor

  aliases: []
  description: GitLab Runner
  documentation: 
    - https://docs.gitlab.com/runner/
  responsible:
    - lrupp
  partners: 
    - gitlab-runner2.infra.opensuse.org
  weburls: []
roles:
  - gitlab_runner
