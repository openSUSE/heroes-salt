#!/bin/bash

# managed by salt - do not edit

BASEDIR=/home/web_jekyll/git
DESTDIR=/home/web_jekyll/jekyll

GIT_DIRS='{% for dir in git_dirs.keys() %}
    {{ dir }}
{%- endfor %}'

# update all git repos, exit if one of them fails (better outdated than inconsistent)
cd "$BASEDIR" || exit 1
for dir in $GIT_DIRS ; do
    cd "$BASEDIR/$dir" && git pull -q || exit 1
done

# sync to all servers
cd $BASEDIR || exit 1
for dir in $GIT_DIRS ; do
    cd "$BASEDIR/$dir" && rm -r vendor && bundle install --deployment && bundle exec jekyll build -d "$DESTDIR/$dir/" || exit 1
done

# sync to all servers
cd $DESTDIR || exit 1
for dir in *.opensuse.org ; do
    rsync -az --exclude '.git' --delete-after "$@" -e ssh "$DESTDIR/$dir/" "web_jekyll@jekyll.infra.opensuse.org:/srv/www/vhosts/$dir/"
done

# vim: ts=4 expandtab
