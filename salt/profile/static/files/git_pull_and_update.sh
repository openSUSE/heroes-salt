#!/bin/bash

# managed by salt - do not edit

BASEDIR=/home/web_static/git

SERVERS='{% for server in server_list %}
    {{ server }}
{%- endfor %}'

GIT_DIRS='{% for dir in git_dirs.keys() %}
    {{ dir }}
{%- endfor %}'

EXPECTED_GITMODULES="$(echo '{%- for file in expected_gitmodules.keys() %}
{{ file }}
{%- endfor %}' | grep .)"

EXPECTED_SHA256="$(echo '{%- for file, sha256 in expected_gitmodules.items() %}
{{ sha256 }}  {{ file }}
{%- endfor %}' | grep .)"

# update all git repos, exit if one of them fails (better outdated than inconsistent)
cd "$BASEDIR" || exit 1
for dir in $GIT_DIRS ; do
    cd "$BASEDIR/$dir" && git pull -q || exit 1
done

# check if any .gitmodules appeared or disappeared
cd "$BASEDIR" || exit 1
test "$(find -name .gitmodules | LANG=C sort)" == "$EXPECTED_GITMODULES" || {
    echo ".gitmodules added or removed, please check manually" >&2
    exit 1
}

# check if content of .gitmodules matches the known ones
cd "$BASEDIR" || exit 1
echo "$EXPECTED_SHA256" | sha256sum -c --quiet --strict || {
    echo ".gitmodules were modified, please check manually" >&2
    exit 1
}

# sync to all servers
cd $BASEDIR || exit 1
for dir in *.opensuse.org ; do
    for server in $SERVERS ; do
        rsync -az --exclude '.git' --delete-after "$@" -e ssh "$BASEDIR/$dir/" "web_static@$server:/srv/www/vhosts/$dir/"
    done
done

# vim: ts=4 expandtab
