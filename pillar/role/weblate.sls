{% set osrelease = salt['grains.get']('osrelease') %}
{% if osrelease == '42.3' %}
monitoring:
  check_zypper:
    whitelist:
      - l10n_opensuse_org-installer
      - python-Django
      - python-django-crispy-forms
      - python-django_compressor
      - python-djangorestframework
      - python-rcssmin
      - python-rjsmin
      - python-siphashc3
      - python-social-auth-app-django
      - python-social-auth-core
      - weblate
{% endif %}
