# -*- coding: utf-8 -*-
# Copyright (C) 1998-2016 by the Free Software Foundation, Inc.
#
# This file is part of Mailman Suite.
#
# Mailman Suite is free sofware: you can redistribute it and/or modify it
# under the terms of the GNU General Public License as published by the Free
# Software Foundation, either version 3 of the License, or (at your option)
# any later version.
#
# Mailman Suite is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
# or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
# for more details.

# You should have received a copy of the GNU General Public License along
# with Mailman Suite.  If not, see <http://www.gnu.org/licenses/>.
"""
Django Settings for Mailman Suite (hyperkitty + postorius)

For more information on this file, see
https://docs.djangoproject.com/en/1.8/topics/settings/

For the full list of settings and their values, see
https://docs.djangoproject.com/en/1.8/ref/settings/
"""

import os
from mailman_web.settings.base import *
from mailman_web.settings.mailman import *

# SECURITY WARNING: keep the secret key used in production secret!
SECRET_KEY = '{{ pillar['profile']['mailman3']['secret_key'] }}'

ADMINS = (
     ('openSUSE Mailing Lists Admins', 'ml-admin@opensuse.org'),
)

SITE_ID = 1

ALLOWED_HOSTS = [
    "localhost",  # Archiving API from Mailman, keep it.
    {%- for server in pillar['profile']['mailman3']['server_list'] %}
    "{{server}}",
    {%- endfor %}
]

POSTORIUS_TEMPLATE_BASE_URL='0.0.0.0:8000'

# Mailman API credentials
MAILMAN_REST_API_USER = '{{ pillar['profile']['mailman3']['admin_user'] }}'
MAILMAN_REST_API_PASS = '{{ pillar['profile']['mailman3']['admin_pass'] }}'
MAILMAN_ARCHIVER_KEY = '{{ pillar['profile']['mailman3']['archiver_key'] }}'

ROOT_URLCONF = 'urls'

TEMPLATES = [
    {
        'BACKEND': 'django.template.backends.django.DjangoTemplates',
        'DIRS': [
            os.path.join(BASE_DIR, 'templates/'),
        ],
        'OPTIONS': {
            'loaders': [
                ('django.template.loaders.cached.Loader', [
                    'django.template.loaders.filesystem.Loader',
                    'django.template.loaders.app_directories.Loader',
                ]),
            ],
            'context_processors': [
                'django.template.context_processors.debug',
                'django.template.context_processors.i18n',
                'django.template.context_processors.media',
                'django.template.context_processors.static',
                'django.template.context_processors.tz',
                'django.template.context_processors.csrf',
                'django.template.context_processors.request',
                'django.contrib.auth.context_processors.auth',
                'django.contrib.messages.context_processors.messages',
                'django_mailman3.context_processors.common',
                'hyperkitty.context_processors.common',
                'postorius.context_processors.postorius',
            ],
        },
    },
]

WSGI_APPLICATION = 'wsgi.application'

INSTALLED_APPS = [
    'hyperkitty',
    'postorius',
    'django_mailman3',
    'django.contrib.admin',
    'django.contrib.auth',
    'django.contrib.contenttypes',
    'django.contrib.humanize',
    'django.contrib.sessions',
    'django.contrib.sites',
    'django.contrib.messages',
    'django.contrib.staticfiles',
    'rest_framework',
    'django_gravatar',
    'compressor',
    'haystack',
    'django_extensions',
    'django_q',
    'allauth',
    'allauth.account',
    'allauth.socialaccount',
    'allauth.socialaccount.providers.openid',
    'allauth.socialaccount.providers.github',
    'allauth.socialaccount.providers.gitlab',
    'allauth.socialaccount.providers.stackexchange',
    'allauth.socialaccount.providers.google',
]

SOCIALACCOUNT_PROVIDERS = {
    'openid': {
        'SERVERS': [
            dict(id='opensuse',
                 name='openSUSE',
                 openid_url='https://www.opensuse.org/openid/'),
            ]
    }
}

# Database
# https://docs.djangoproject.com/en/1.8/ref/settings/#databases
#
DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.postgresql_psycopg2',
        'NAME': 'mailman_frontend',
        'USER': '{{ pillar['profile']['mailman3']['database_user'] }}',
        'PASSWORD': '{{ pillar['postgres']['users']['mailman3']['password'] }}',
        'HOST': '{{ pillar['profile']['mailman3']['database_host'] }}',
    }
}


# If you're behind a proxy, use the X-Forwarded-Host header
# See https://docs.djangoproject.com/en/1.8/ref/settings/#use-x-forwarded-host
USE_X_FORWARDED_HOST = True

# And if your proxy does your SSL encoding for you, set SECURE_PROXY_SSL_HEADER
# https://docs.djangoproject.com/en/1.8/ref/settings/#secure-proxy-ssl-header
# SECURE_PROXY_SSL_HEADER = ('HTTP_X_FORWARDED_PROTO', 'https')
SECURE_PROXY_SSL_HEADER = ('HTTP_X_FORWARDED_SCHEME', 'https')

# Other security settings
# SECURE_SSL_REDIRECT = True
# If you set SECURE_SSL_REDIRECT to True, make sure the SECURE_REDIRECT_EXEMPT
# contains at least this line:
# SECURE_REDIRECT_EXEMPT = [
#     "archives/api/mailman/.*",  # Request from Mailman.
#     ]
SESSION_COOKIE_SECURE = True
SECURE_CONTENT_TYPE_NOSNIFF = True
SECURE_BROWSER_XSS_FILTER = True
CSRF_COOKIE_SECURE = True
CSRF_COOKIE_HTTPONLY = True
X_FRAME_OPTIONS = 'DENY'


# Static files (CSS, JavaScript, Images)
# https://docs.djangoproject.com/en/1.8/howto/static-files/

# Additional locations of static files
STATICFILES_DIRS = (
    # Put strings here, like "/home/html/static" or "C:/www/django/static".
    # Always use forward slashes, even on Windows.
    # Don't forget to use absolute paths, not relative paths.
    os.path.join(BASE_DIR, 'static-openSUSE/'),
)

# If you enable internal authentication, this is the address that the emails
# will appear to be coming from. Make sure you set a valid domain name,
# otherwise the emails may get rejected.
# https://docs.djangoproject.com/en/1.8/ref/settings/#default-from-email
# DEFAULT_FROM_EMAIL = "mailing-lists@you-domain.org"
DEFAULT_FROM_EMAIL = 'mailing-lists@opensuse.org'

# If you enable email reporting for error messages, this is where those emails
# will appear to be coming from. Make sure you set a valid domain name,
# otherwise the emails may get rejected.
# https://docs.djangoproject.com/en/1.8/ref/settings/#std:setting-SERVER_EMAIL
# SERVER_EMAIL = 'root@your-domain.org'
SERVER_EMAIL = 'admin@opensuse.org'

EMAIL_BACKEND = 'django.core.mail.backends.smtp.EmailBackend'
EMAIL_HOST = 'localhost'
EMAIL_PORT = 25

# Disable local signup
ACCOUNT_ADAPTER = "django_fedora_nosignup.NoLocalSignUpAdapter"
SOCIALACCOUNT_ADAPTER = "django_fedora_nosignup.SignUpEnabledSocialAdapter"


#
# Gravatar
#
GRAVATAR_URL = 'http://cdn.libravatar.org/'
GRAVATAR_SECURE_URL = 'https://seccdn.libravatar.org/'
GRAVATAR_DEFAULT_SIZE = '80'
GRAVATAR_DEFAULT_IMAGE = 'mm'
GRAVATAR_DEFAULT_RATING = 'g'
GRAVATAR_DEFAULT_SECURE = True

#
# Full-text search engine
#
HAYSTACK_CONNECTIONS = {
    'default': {
        'ENGINE': 'haystack.backends.solr_backend.SolrEngine',
        'URL': 'http://localhost:8983/solr/mailman',
        'ADMIN_URL': 'http://localhost:8983/solr/admin/cores',
        'TIMEOUT': 60 * 5,
        'INCLUDE_SPELLING': True,
        'BATCH_SIZE': 100,
    }
}

# Using the cache infrastructure can significantly improve performance on a
# production setup. This is an example with a local Memcached server.
CACHES = {
    'default': {
        'BACKEND': 'django.core.cache.backends.memcached.PyLibMCCache',
        'LOCATION': 'unix:/run/memcached/memcached.sock',
    }
}

USE_L10N = False
TIME_FORMAT = 'H:i'
