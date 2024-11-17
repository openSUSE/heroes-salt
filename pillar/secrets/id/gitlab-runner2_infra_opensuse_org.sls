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
            MaFgjOt5V7TB0DGGCg0Ph7o7
            =1TKs
            -----END PGP MESSAGE-----
        {%- endif %}
