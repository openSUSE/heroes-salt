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
            gYzTmUTTDyCdT7hV/Prm2WRB
            =OZIP
            -----END PGP MESSAGE-----
        {%- endif %}
