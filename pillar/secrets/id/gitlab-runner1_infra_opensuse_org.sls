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
            Hf1TeM2a3nil3RZ97fVnBGL1
            =qfax
            -----END PGP MESSAGE-----
        {%- endif %}
