#!jinja|yaml|gpg
{%- from 'role/common/gitlab_runner/macros.jinja' import runner %}

profile:
  gitlab_runner:
    config:
      runners:
        {{ runner() }}
        {%- if salt['grains.get']('include_secrets', True) %}
          token: |
            -----BEGIN PGP MESSAGE-----

            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
            gjM=
            =4w12
            -----END PGP MESSAGE-----
        {%- endif %}
