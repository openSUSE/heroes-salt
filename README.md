<a href="https://en.opensuse.org/openSUSE:Heroes"><img src="https://img.shields.io/badge/openSUSE-Heroes-brightgreen.svg?logo=data%3Aimage%2Fpng%3Bbase64%2CiVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAMAAAAoLQ9TAAAAk1BMVEUAAABmmQCR0AdmmQB7tAOR0Ad0qwKR0AdmmQB7tAOGwgWR0AeR0AdmmQB0qwKR0AdmmQBmmQBwpgF2rQJ7tAOR0AdvpQF5sQOR0AdyqQKIxQWR0Ad1rQKR0Ad0qwJ3rwKJxgWR0Ad5sgN9tgN%2BuASR0Ad%2FugSLyAaR0Ad7tAN%2BtwOAuwSGwgWIxQWLyQaOzAaR0Ac0QkqCAAAAKXRSTlMADw8fHx8vLz8%2FPz9PX19fb39%2Ff39%2Fj4%2BPn5%2Bfr6%2B%2Fv7%2B%2Fz8%2Ff3%2B%2Fv7%2FtiEuIAAACOSURBVBgZbcHbFkJAAAXQQ8kUJRXRGKHblKHz%2F19XLq3Vg70xSUaejX%2F8uknfRs%2BW%2FJEuAEdzYLL4Sh%2BQHLSLSK0uGuDo5PGp5gzAUbIkC4cK7LwbajfNhSTB3qZqdRKVpMGDHeWsz7UxdS5w4ED5lhCzoIBVcaTLUps9YMX3hj3zSgU6lgh32THcCkz5AIT0Glg8M2spAAAAAElFTkSuQmCC"/></a> [![pipeline status](https://gitlab.infra.opensuse.org/infra/salt/badges/production/pipeline.svg)](https://gitlab.infra.opensuse.org/infra/salt/commits/production)

Documentation at the [openSUSE-admin progress.o.o wiki](https://progress.opensuse.org/projects/opensuse-admin-wiki/wiki)

Debugging salt on your client (the machine running the salt-minion) via:

`salt-call state.apply -l debug test=True`

 ...and remember to have a lot of fun! :-)


```
   _____       ____  _____ __             __
  / ___/____ _/ / /_/ ___// /_____ ______/ /__
  \__ \/ __ `/ / __/\__ \/ __/ __ `/ ___/ //_/
 ___/ / /_/ / / /_ ___/ / /_/ /_/ / /__/ ,<
/____/\__,_/_/\__//____/\__/\__,_/\___/_/|_|
```


Rules and workflows
-------------------

The general workflow should be to create a branch (either directly in this repository or in another one), do your changes, recommit and create a merge request for review. This gives other team members the possibility to notice and review your changes. It even sends out Emails, so other team members get aware of changes.

On the other side, we do not want to block anyone from being productive. So here are the general rules:

Always try to use merge requests. We allow to merge those requests on your own - but we want to make use of the benefits of merge requests (notifications, tests, visibility).

Changes, that require a submit request and review:
* changes, that might affect a bigger amount of machines - especially, if this affects machines maintained by others
* potentially dangerous stuff, that might break existing setups

Changes, that could be self-merged:
* emergency updates fixing something that is already broken (think about a new Gateway IP as example)
* stuff that is interesting only for machines that the requester maintains
* stuff that nobody was able to review for more than 2 months
