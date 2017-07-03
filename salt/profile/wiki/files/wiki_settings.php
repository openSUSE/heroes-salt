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

{% if data.has_key('site_notice') %}
$wgSiteNotice = '{{ data.site_notice }}';
{% endif %}

{% if data.has_key('readonly_msg') %}
$wgReadOnly = '{{ data.readonly_msg }}';
{% endif %}
