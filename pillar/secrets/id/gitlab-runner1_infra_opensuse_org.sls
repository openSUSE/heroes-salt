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
            69hEfeewohMPXtwVvJc8Rk4f
            =4Pu6
            -----END PGP MESSAGE-----
        {%- endif %}
