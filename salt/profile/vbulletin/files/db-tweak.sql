grant all on {{dbname}}.* to '{{username}}'@'{{host}}' identified by '{{password}}';

update vb_setting set value='{{bburl}}' where varname='bburl';
update vb_setting set value='{{frontendurl}}' where varname='frontendurl';

update vb_setting set value=1 where varname='bburl_basepath';
update vb_setting set value='/srv/www/vhosts/forums/sitemap' where varname='sitemap_path';

