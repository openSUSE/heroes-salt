# NOTE:
# The vb5 binaries must be uploaded to the target host, and made available at
#
#     /root/vb5_connect.zip
#
# before running state.apply

include:
  - profile.vbulletin.php-fpm
{% if salt['file.file_exists']('/root/vb5_connect.zip') %}
  - profile.vbulletin.setup
  - profile.vbulletin.tools
{% endif %}
