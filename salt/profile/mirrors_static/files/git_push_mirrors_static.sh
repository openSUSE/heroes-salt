#!/usr/bin/bash

# managed by salt - do not edit

set -e

MIRRORS_DIR='download.opensuse.org'
MIRRORS_URL="https://$MIRRORS_DIR/report/mirrors/"
DATE=$(date +"%Y-%m-%d %H:%M")
SSH_KEYFILE='/home/mirrors_static/.ssh/id_rsa'
SSH_HOSTSFILE='/home/mirrors_static/.ssh/known_hosts'
WGET_DIR='/home/mirrors_static/wget'
GIT_DIR='/home/mirrors_static/git'
LOGFILE='/home/mirrors_static/update_mirrors.log'

# start the work
echo "$(basename $0) started at $DATE" >> "$LOGFILE"

# get a copy
rm -rf "$WGET_DIR/$MIRRORS_DIR" 2>/dev/null
cd "$WGET_DIR"
wget \
	--quiet \
	--page-requisites \
	--adjust-extension \
	--convert-links \
	--no-parent \
	--level 0 \
	"$MIRRORS_URL"

# adjust if downloading directly from MirrorCache route /report/mirrors
mv "$WGET_DIR/$MIRRORS_DIR/report/mirrors/index.html" "$WGET_DIR/$MIRRORS_DIR/" 2>/dev/null ||:
rm -rf "$WGET_DIR/$MIRRORS_DIR/report"
rm -rf "$WGET_DIR/$MIRRORS_DIR/robots.txt"
sed -i 's,\.\./\.\./,,g' "$WGET_DIR/$MIRRORS_DIR/index.html"

# copy that to the directory containing the git repo
rsync -az --exclude={'.git','README.md'} --delete-after \
	"$WGET_DIR/$MIRRORS_DIR/" \
	"$GIT_DIR/mirrors_static/"

# make some adjustments for the static content:
cd "$GIT_DIR/mirrors_static/"
sed -i '/meta name="csrf-token"/d ; /meta name="csrf-param"/d' index.html 

# push into the GIT repository
export GIT_SSH_COMMAND="ssh -o StrictHostKeyChecking=yes -o UserKnownHostsFile=$SSH_HOSTSFILE -i $SSH_KEYFILE"
git add . >> "$LOGFILE" 2>&1
git commit -m "Update via cronjob at $DATE" -a >> "$LOGFILE" 2>&1
git push >> "$LOGFILE" 2>&1
