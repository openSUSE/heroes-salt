<?php

$wgCacheDirectory = "/srv/www/{{ wiki }}.opensuse.org/cache";

$wgLanguageCode = "{{ data.get('lang', wiki) }}";
$bento_lang = '{{ data.get('bento_lang', wiki) }}';

$wgDBserver   = '{{ mysql_server }}';
$wgDBname     = 'wiki_{{ wiki|replace('-', '_') }}';
$wgDBuser     = 'wiki_{{ wiki|replace('-', '_') }}';
# $wgDBpassword = '{{ data.dbpass }}';

require_once('secrets.php'); # sets $wgDBpassword and $wgSecretKey

$elasticsearch_server = '{{ elasticsearch_server }}';

$google_maps_key = 'AIzaSyAOBuW9Pg5cYQqjQjAqlczBWJhAtcCNeSg'; # key created by cboltz

{% if 'site_notice' in data %}
$wgSiteNotice = '{{ data.site_notice }}';
{% endif %}

{% if 'readonly_msg' in data %}
$wgReadOnly = '{{ data.readonly_msg }}';
$wgIgnoreImageErrors=true;  # avoid error message for thumbnails, see https://www.mediawiki.org/wiki/Manual:$wgReadOnly
{% endif %}

{%- if 'dbmysql5' in data and not data.get('dbmysql5') %}
$wgDBmysql5 = false;  # old-en and old-de don't work with utf8 DB connection
{%- else %}
$wgDBmysql5 = true;
{%- endif %}

$wgDefaultSkin = "{{ data.get('skin', 'bento') }}";
{%- if 'skin' in data %}
wfLoadSkin('Chameleon');
{%- endif %}
