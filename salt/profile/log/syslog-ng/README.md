# syslog-ng in the openSUSE infrastructure

## Common configuration structure

- /etc/syslog-ng/syslog-ng.conf:
  * This is the default configuration as shipped with the package. We do not modify it - it takes good care of the local log routing.

## Server configuration structure

- /etc/syslog-ng/conf.d/server.conf:
  * The first custom configuration loaded by syslog-ng. It enables the TCP listener (reliable, RFC3195) which other hosts on our network will connect to, and includes the following files.

- /etc/syslog-ng/conf.d/server.d/01_destination.conf:
  * Defines the file structure and permissions for logs from remote systems on the syslog server.

- /etc/syslog-ng/conf.d/server.d/02_filter.conf:
  * Defines filter rules which can then be applied to incoming logs.

- /etc/syslog-ng/conf.d/server.d/03_route.conf:
  * Defines which of the defined destinations to use for incoming logs based on the defined filter rules.

## Client configuration structure

- /etc/syslog-ng/conf.d/client.conf:
  * Defines the remote destination and routes for forwarding of local logs to the central logging server. The log sources in the default syslog-ng.conf are combined with custom, application specific, ones. The routing to local destinations defined in the default syslog-ng.conf (/var/log/messages, /var/log/mail, ...) is kept intact.
