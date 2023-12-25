{%- set virtual = grains['virtual'] %}
{%- set osfullname = grains['osfullname'] %}

{%- set supported_virtuals = ['kvm', 'physical'] %}
{%- set supported_osfullnames = ['Leap', 'openSUSE Tumbleweed', 'openSUSE Leap Micro'] %}

{%- if virtual in supported_virtuals and osfullname in supported_osfullnames %}
bootloader:

  {%- if grains['efi'] %}
  bootloader:
    config:
      {%- if virtual == 'physical' %}
      {#- not using secure boot due to shim preventing ESP on software RAID #}
      secure_boot: false
      {%- elif virtual == 'kvm' %}
      secure_boot: true
      {%- endif %}
      update_nvram: true
  {%- endif %}

  grub:
    config:

      {%- if virtual == 'physical' %}
      {%- set cmdline = 'console=ttyS0,15200 console=tty0 loglevel=4 mitigations=auto preempt=full' %}
      {#- to-do: facilitate crashkernel settings for kdump #}


      {%- if grains.get('fc_host') %}
      {#- raise maximum LUNs on machines with fiber channel storage #}
      {%- set cmdline = cmdline ~ ' lpfc.lpfc_max_luns=4095' %}
      {%- endif %}

      {%- elif virtual == 'kvm' %}
      {%- set cmdline = 'console=tty0 console=ttyS0,115200 loglevel=3' %}

      {%- endif %} {#- close virtual logic #}

      {%- if osfullname in ['Leap', 'openSUSE Tumbleweed'] %}
      {%- set cmdline = cmdline ~ ' security=apparmor' %}

      {%- elif osfullname == 'openSUSE Leap Micro' %}
      {%- set cmdline = cmdline ~ ' rd.timeout=60 security=selinux selinux=1' %}

      {%- endif %} {#- close osfullname logic #}

      grub_cmdline_linux_default: {{ cmdline }}
      grub_cmdline_linux: ''
      grub_disable_os_prober: true
      grub_terminal: console
      grub_timeout: 5
      grub_gfxmode: auto

{%- else %}
{#- machine is probably a container or some virtualization technology from the future #}
{%- do salt.log.debug('common.bootloader: unsupported system configuration, skipping bootloader configuration') %}
{%- endif %} {#- close supported_virtuals/supported_osfullnames check #}
