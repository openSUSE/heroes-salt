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
            8kA=
            =4Te2
            -----END PGP MESSAGE-----
        {%- endif %}
