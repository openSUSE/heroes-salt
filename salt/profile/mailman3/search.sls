include:
  - profile.solr

{%- set coredir = '/var/opt/solr/mailman' %}

mailman_solr_core_directory:
  file.directory:
    - name: {{ coredir }}
    - mode: '0755'
    - user: solr
    - group: solr
    - require:
        - pkg: solr_package

mailman_solr_core_properties:
  file.managed:
    - name: {{ coredir }}/core.properties
    - user: solr
    - group: solr
    - mode: '0644'
    - contents:
        - {{ pillar['managed_by_salt'] | yaml_encode }}
        - config=solrconfig.xml
        - dataDir=data
        - name=mailman
        - schema=schema.xml
    - require:
        - pkg: solr_package

{%- set coredir = coredir ~ '/conf' %}

mailman_solr_core_sample_config:
  file.copy:
    - user: solr
    - group: solr
    - mode: '0644'
    - dir_mode: '0755'
    - names:
        {%- set samples = '/opt/solr/server/solr/configsets/' %}
        - {{ coredir }}/lang:
            - source: {{ samples }}_default/conf/lang
        {%- for file in ['protwords', 'stopwords', 'synonyms'] %}
        - {{ coredir }}/{{ file }}.txt:
            - source: {{ samples }}_default/conf/{{ file }}.txt
        {%- endfor %}
        {%- for file in ['currency', 'elevate'] %}
        - {{ coredir }}/{{ file }}.xml:
            - source: {{ samples }}sample_techproducts_configs/conf/{{ file }}.xml
        {%- endfor %}
    - require:
        - pkg: solr_package

{#- these were generated with `manage.py build_solr_schema -u default_new -c /tmp/stage-core/ -v3` but adjusted to work with Solr 9
    (as of django-haystack 3.2.1, the generated files use deprecated class names) #}
mailman_solr_core_custom_config:
  file.managed:
    - user: solr
    - group: solr
    - mode: '0640'
    - template: jinja
    - names:
        {%- for file in ['schema', 'solrconfig'] %}
        - {{ coredir }}/{{ file }}.xml:
            - source: salt://{{ slspath }}/files/solr/{{ file }}.xml.jinja
        {%- endfor %}
    - require:
        - pkg: solr_package
