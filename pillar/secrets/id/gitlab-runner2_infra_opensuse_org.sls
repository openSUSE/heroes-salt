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
            opTh
            =N3cg
            -----END PGP MESSAGE-----
        {%- endif %}
