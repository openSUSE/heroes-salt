[![openSUSE Heroes](https://img.shields.io/badge/openSUSE-Heroes-brightgreen.svg?logo=data%3Aimage%2Fpng%3Bbase64%2CiVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAMAAAAoLQ9TAAAAk1BMVEUAAABmmQCR0AdmmQB7tAOR0Ad0qwKR0AdmmQB7tAOGwgWR0AeR0AdmmQB0qwKR0AdmmQBmmQBwpgF2rQJ7tAOR0AdvpQF5sQOR0AdyqQKIxQWR0Ad1rQKR0Ad0qwJ3rwKJxgWR0Ad5sgN9tgN%2BuASR0Ad%2FugSLyAaR0Ad7tAN%2BtwOAuwSGwgWIxQWLyQaOzAaR0Ac0QkqCAAAAKXRSTlMADw8fHx8vLz8%2FPz9PX19fb39%2Ff39%2Fj4%2BPn5%2Bfr6%2B%2Fv7%2B%2Fz8%2Ff3%2B%2Fv7%2FtiEuIAAACOSURBVBgZbcHbFkJAAAXQQ8kUJRXRGKHblKHz%2F19XLq3Vg70xSUaejX%2F8uknfRs%2BW%2FJEuAEdzYLL4Sh%2BQHLSLSK0uGuDo5PGp5gzAUbIkC4cK7LwbajfNhSTB3qZqdRKVpMGDHeWsz7UxdS5w4ED5lhCzoIBVcaTLUps9YMX3hj3zSgU6lgh32THcCkz5AIT0Glg8M2spAAAAAElFTkSuQmCC)](https://en.opensuse.org/openSUSE:Heroes) [![pipeline status](https://gitlab.infra.opensuse.org/infra/salt/badges/production/pipeline.svg)](https://gitlab.infra.opensuse.org/infra/salt/commits/production)

```
   _____       ____  _____ __             __
  / ___/____ _/ / /_/ ___// /_____ ______/ /__
  \__ \/ __ `/ / __/\__ \/ __/ __ `/ ___/ //_/
 ___/ / /_/ / / /_ ___/ / /_/ /_/ / /__/ ,<
/____/\__,_/_/\__//____/\__/\__,_/\___/_/|_|
```

Authoritative source of this repository is https://gitlab.infra.opensuse.org/infra/salt. Merge requests can be filed there, but access requires the openSUSE Heroes VPN.

Read-only mirrors are available at https://code.opensuse.org/heroes/salt and https://github.com/openSUSE/heroes-salt.

Documentation can be found in the [openSUSE admin wiki](https://progress.opensuse.org/projects/opensuse-admin-wiki/wiki).

States can be applied from the master:

`salt <target> state.apply`

Debugging Salt on a client (i.e. a machine running the salt-minion) is possible using:

`salt-call state.apply -l debug test=True`

Remember to have a lot of fun! :-)

Formulas
-------------------

In addition to the Salt states in this repository various reusable states ("formulas") are in use.

Our formulas (installed from packages):
- https://github.com/openSUSE/salt-formulas (authoritative) or https://code.opensuse.org/heroes/salt-formulas (mirror)

Upstream formulas and forks (installed from Git submodules):
- https://gitlab.infra.opensuse.org/infra/salt-formulas-git (authoritative) or https://code.opensuse.org/heroes/salt-formulas-git (mirror)

Tests
-------------------

Merge requests to the repository trigger a test suite:

- `lint`: Linting of .jinja, .py, .sh, .sls, .yaml files
- `validate`:
  - Schema validation of data in pillar/infra/
  - File header and suffix check
  - Empty files check
  - PGP secrets check
  - Profiles check
  - Roles check
- `show_highstate`: Salt `state.show_highstate` for every country
   with all roles enabled - finds basic pillar/state template errors
- `test_haproxy`: Validates the HAProxy configuration for all
  proxy clusters - finds pillar and HAProxy syntax errors
- `test_nginx`: Validates the NGINX configuration for all roles
  using NGINX - finds pillar and NGINX syntax errors
- `test_highstate`: Salt `state.test` for every role - finds most
  pillar/state errors
- `test_nftables`: Lints and validates the nftables configuration
  under salt/files/nftables/ - finds cosmetic and syntax issues
- `test_prometheus`: Validates the Prometheus and Alertmanager
  configurations as well as the alerting rules under
  salt/files/prometheus/ - finds monitoring pillar and configuration
  issues including invalid rules

If the pipeline succeeds and the merge request gets merged, the new
data will be copied to all Salt Masters.

Rules and workflows
-------------------

The general workflow should be to create a branch (either directly in this repository or in a clone/fork), do your changes, commit and create a merge request for review. This gives other team members the possibility to notice and review your changes. It even sends out Emails, so other team members become aware of them.

On the other side, we do not want to block anyone from being productive. So here are the general rules:

* **Always use merge requests.** 
* We allow to merge those requests on your own - but we want to make use of the benefits of merge requests (notifications, tests, visibility).


Merge requests that **require a review**:

* changes that might affect a bigger amount of machines - especially, if this affects machines maintained by others
* potentially dangerous stuff that might break existing setups

Merge requests that **could be self-merged**:

* emergency updates repairing something that is already broken (think about a new gateway IP address as an example)
* typo fixes (includes whitespace fixes)
* changes which only affect machines maintained by the requester themselves
* changes which nobody reviewed / which did not receive any input for more than one week
