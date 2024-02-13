{#- version needs to match the build target in OBS _and_ the Kiwi image file name #}
{%- set version = '15.5' %}

{%- set topdir = salt['pillar.get']('infrastructure:kvm_topdir', '/kvm') %}
{%- set imagetype = salt['pillar.get']('infrastructure:image_type') %}

{#- there is a gpg module, but we don't want to install python-gnupg just for two states #}

infrastructure_repository_key:
  cmd.run:
    - name: gpg --import < <(curl -sS http://download.infra.opensuse.org/repositories/openSUSE%3A/infrastructure/{{ version }}/repodata/repomd.xml.key)
    - shell: /bin/bash
    - unless:
        - gpg --list-key 034EB7A6E7506D45DE9CCEC68E01781420F13AAC
        - '! gpg --list-key 034EB7A6E7506D45DE9CCEC68E01781420F13AAC | grep expired'

{%- if imagetype %}
{%- set suffix = {'qcow2': 'qcow.qcow2', 'raw': 'raw.raw.xz'} %}
{%- set image_directory = topdir ~ '/os-images/' %}

{%- set file = 'admin-openSUSE-Leap-' ~ version ~ '.x86_64-' ~ suffix[imagetype] %}
{%- set image_source_leap = 'http://download.infra.opensuse.org/repositories/openSUSE%3A/infrastructure%3A/Images%3A/' ~ version ~ '/images/' ~ file %}
{%- set image_destination_leap = image_directory ~ file %}

hypervisor_image_checksum_download:
  file.managed:
    - name: {{ image_destination_leap }}.sha256
    - source: {{ image_source_leap }}.sha256
    - skip_verify: True
    - use_etag: True

hypervisor_image_checksum_signature_download:
  file.managed:
    - name: {{ image_destination_leap }}.sha256.asc
    - source: {{ image_source_leap }}.sha256.asc
    - skip_verify: True
    {%- if salt['cp.is_cached'](image_source_leap ~ '.sha256.asc') %}
    - use_etag: True
    {%- endif %}

hypervisor_image_checksum_verify:
  cmd.run:
    - name: gpg --verify {{ image_destination_leap }}.sha256.asc
    - require:
        - cmd: infrastructure_repository_key
    - onchanges:
        - cmd: infrastructure_repository_key
        - file: hypervisor_image_checksum_download
        - file: hypervisor_image_checksum_signature_download

hypervisor_image_download:
  file.managed:
    - name: {{ image_destination_leap }}
    - source: {{ image_source_leap }}
    {#- test fails if target file does not yet exist, hence test with remote file but then apply with the PGP verified local one #}
    {%- if opts['test'] %}
    - source_hash: {{ image_source_leap }}.sha256
    {%- else %}
    - source_hash: file://{{ image_destination_leap }}.sha256
    {%- endif %}
    - require:
        - file: hypervisor_image_checksum_download
        - file: hypervisor_image_checksum_signature_download
        - cmd: hypervisor_image_checksum_verify

hypervisor_image_install:
  cmd.run:
    - name: |
        pushd {{ image_directory }} >/dev/null &&
        sha256sum -c {{ image_destination_leap }}.sha256 &&
        popd >/dev/null {%- if imagetype == 'raw' -%} &&
        unxz -fk {{ image_destination_leap }}
        {%- endif %}
    {%- if salt['file.file_exists'](image_destination_leap.rstrip('.xz')) %}
    - onchanges:
        - file: hypervisor_image_download
    {%- endif %}
    - require:
        - file: hypervisor_image_checksum_download
        - file: hypervisor_image_checksum_signature_download
        - cmd: hypervisor_image_checksum_verify
{%- endif %}
