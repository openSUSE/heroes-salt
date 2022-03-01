#!/bin/bash

# managed by salt - do not edit

BASEDIR=/home/web_jekyll/git
DESTDIR=/home/web_jekyll/jekyll

SERVERS='{% for server in server_list %}
    {{ server }}
{%- endfor %}'

GIT_DIRS='{% for dir in git_dirs.keys() %}
    {{ dir }}
{%- endfor %}'

# update all git repos, exit if one of them fails (better outdated than inconsistent)
cd "$BASEDIR" || exit 1
for dir in $GIT_DIRS ; do
    cd "$BASEDIR/$dir" && git pull -q || exit 1
done

# build all of the sites
cd $BASEDIR || exit 1
for dir in $GIT_DIRS ; do
    cd "$BASEDIR/$dir" || exit 1
    current_md5=$(md5sum "Gemfile.lock" | cut -d " " -f1)
    [[ $(cat Gemfile.lock.md5) != $current_md5 ]] && rm -rf vendor
    bundle.ruby2.7 config set deployment 'true'
    bundle.ruby2.7 install || exit 1
    [[ -f "Rakefile" ]] && bundle.ruby2.7 exec rake
    bundle.ruby2.7 exec jekyll build -d "$DESTDIR/$dir/" && echo $current_md5 > Gemfile.lock.md5 || exit 1
done

# sync to all servers
cd $DESTDIR || exit 1
for dir in *.opensuse.org ; do
    for server in $SERVERS ; do
        rsync -az --exclude '.git' --delete-after "$@" -e ssh "$DESTDIR/$dir/" "web_jekyll@$server:/srv/www/vhosts/$dir/"
    done
done

# vim: ts=4 expandtab
