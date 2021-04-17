# vBulletin 5 Setup for openSUSE Forums

Brief setup instructions:

 1. Prepare the binaries as instructed in [init.sls](init.sls).
 1. ``salt-call state.apply grains``
 1. ``salt-call state.apply pillar='{"vbulletin":{"tools":"yes"}}'``
 1. ``cd /srv/www/vhosts/forums/``
 1. ``(cd htdocs/core/install; sudo -u nginx php -f upgrade.php)``
 1. `` mysql webforums <db-tweaks.sql``
 1. ``(cd htdocs/core/install; sudo -u nginx php -f upgrade.php)``
 1. ``salt-call state.apply``

## vBulletin setup tools

If the pillar ``vbulletin.tools`` is truthy, the extra files described below
are available to aid with setup of vBulletin.

**It is important to disable the ``vbulletin.tools`` pillar and running
``highstate`` again to remove the files before production use.**

### ``/srv/www/vhosts/forums/db-tweak.sql``

Running this SQL script on the vBulletin database will:

  * Set up the correct grants for the database user.
  * Define the site URL correctly for template setup
  * Adjust various other vBulletin settings

After running the script, run ``core/install/upgrade.php`` again to make sure
the templates are set up correctly.

### ``/srv/www/vhosts/forums/htdocs/vb_test.php``

A tool for checking that vBulletin is installed correctly, including all
dependencies, as well as verifying that it is possible to connect to the
database.

### ``/srv/www/vhosts/forums/htdocs/info.php``

Shows ``phpinfo()`` for the forum server.

## Styling

These steps achieve a minimal styling suitable for openSUSE Forums.

Enable the _Default vB5 Style_, then customize these style variables:

 * ``global_palette_accent_02`` = #73ba25
 * ``global_palette_text_04`` = #5a911d

Finally, change the [site logo](files/logo-color-90.png).

