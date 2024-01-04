#!jinja|yaml|gpg
{%- from 'role/common/gitlab_runner/macros.jinja' import runner -%}

profile:
  gitlab_runner:
    config:
      runners:
        {{ runner() }}
        {%- if salt['grains.get']('include_secrets', True) %}
          token: |
            -----BEGIN PGP MESSAGE-----

            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
            Fn0L
            =jygY
            -----END PGP MESSAGE-----
        {%- endif %}
