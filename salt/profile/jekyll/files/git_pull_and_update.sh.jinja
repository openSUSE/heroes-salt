#!/bin/bash

# managed by salt - do not edit

BASEDIR=/home/web_jekyll/git
DESTDIR=/home/web_jekyll/jekyll
LOGDIR=/home/web_jekyll/log

SERVERS='{% for server in server_list %}
    {{ server }}
{%- endfor %}'

GIT_DIRS='{% for dir in git_dirs.keys() %}
    {{ dir }}
{%- endfor %}'


update_jekyll() {
    dir="$1"
    retval=0

    # update the git repo, abort if it fails (better outdated than inconsistent)
    cd "$BASEDIR/$dir" || return 3
    git pull -q || return 4

    # build the site
    current_md5=$(md5sum "Gemfile.lock" | cut -d " " -f1)
    [[ $(cat Gemfile.lock.md5) != $current_md5 ]] && rm -rf vendor
    bundle.ruby3.1 config set deployment 'true' || return 5
    bundle.ruby3.1 install || return 6
    [[ -f "Rakefile" ]] && bundle.ruby3.1 exec rake
    bundle.ruby3.1 exec jekyll build -d "$DESTDIR/$dir/" && echo $current_md5 > Gemfile.lock.md5 || return 7

    # sync to all servers
    cd $DESTDIR || return 10
    for server in $SERVERS ; do
        rsync -az --exclude '.git' --delete-after "$@" -e ssh "$DESTDIR/$dir/" "web_jekyll@$server:/srv/www/vhosts/$dir/" || retval=11
    done
    return $retval  # rsync failures for one server don't abort, but still get reported as error
}

failed=""

for dir in $GIT_DIRS ; do
    update_jekyll $dir &> "$LOGDIR/$dir.log" || { echo "Exitstatus: $?" >> "$LOGDIR/$dir.log"; failed="$failed $dir"; }
done


# if at least one build failed, write a report and mail it to root
if [ -n "$failed" ] ; then
    {
        echo "Jekyll build failed for"
        for dir in $failed ; do
            echo "- $dir"
        done

        echo
        echo "Famous last words^Wlog lines:"
        echo "(You can find the latest full logs in $LOGDIR.)"

        for dir in $failed ; do
            echo
            tail -n50 -v "$LOGDIR/$dir.log"
            echo
        done

    } > "$LOGDIR/_failures"

    mail -s "Jekyll failure" root < "$LOGDIR/_failures"
else
    echo "no failures" > "$LOGDIR/_failures"
fi

# vim: ts=4 expandtab
