# shellcheck shell=sh
# when using a container without systemd to run tests containing some irrelevant service.running states,
#  replace systemctl with a dummy which still matches the --version output expected by _systemd() in salt/grains/core.py
printf '#!/bin/sh\necho "systemd 257 (257.2)"\necho nothing\n' >| /usr/bin/systemctl
chmod +x /usr/bin/systemctl
