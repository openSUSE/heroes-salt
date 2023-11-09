haproxy:
  frontends:
    http-ext-in:
      acls:
        - no_x-frame-option var(txn.host) -m str meet.opensuse.org
        - no_x-frame-option var(txn.host) -m str metrics.opensuse.org
        - is_ssl                 fc_rcvd_proxy
        - path_dot_scm           path_beg      /.git/
        - path_dot_scm           path_beg      /.svn/
        - path_dot_scm           path_beg      /.bzr/
        - path_security          path_end      /.well-known/security.txt
        - path_favicon           path          /favicon.ico
        - is_www                 hdr(host)     -i www.opensuse.org
        - is_apparmor            hdr(host)     -i apparmor.opensuse.org
        - is_bar                 hdr(host)     -i bar.opensuse.org
        - is_bugs                hdr(host)     -i bugs.opensuse.org
        - is_redirect_events     hdr(host)     -i summit.opensuse.org
        - is_redirect_events     hdr(host)     -i conference.opensuse.org
        - is_redirect_events     hdr(host)     -i party.opensuse.org
        - is_redirect_events     hdr(host)     -i events-test.opensuse.org
        - is_tube                hdr(host)     -i tube.opensuse.org
        - is_jenkins             hdr(host)     -i ci.opensuse.org
        - is_education           hdr(host)     -i education.opensuse.org
        - is_coc                 hdr(host)     -i coc.opensuse.org
        - is_conncheck           hdr(host)     -i conncheck.opensuse.org
        - is_freeipa             hdr(host)     -i freeipa.infra.opensuse.org
        - is_gitlab              hdr(host)     -i gitlab.infra.opensuse.org
        - is_gitlab              hdr(host)     -i gitlab.opensuse.org
        - is_hackweeksc          hdr(host)     -i hackweek.suse.com  # unused
        - is_ignite_stage        hdr(host)     -i ignite-stage.opensuse.org
        - is_ignite              hdr(host)     -i ignite.opensuse.org
        - is_help                hdr(host)     -i help.opensuse.org
        {%- for host_hydra in ['hydra', 'anna', 'elsa', 'proxy-ipx1'] %}
        - is_hydra               hdr(host)     -i {{ host_hydra }}.opensuse.org
        {%- endfor %}
        - is_license             hdr(host)     -i license.opensuse.org
        - is_metrics             hdr(host)     -i metrics.opensuse.org
        - is_mirrorlist          hdr(host)     -i mirror.opensuse.org
        - is_mirrorlist          hdr(host)     -i mirrors.opensuse.org
        - is_mirrorlist          hdr(host)     -i mirrordb.opensuse.org
        - is_mirrorcache         hdr(host)     -i mirrorcache.opensuse.org
        - is_mirrorcache_eu      hdr(host)     -i mirrorcache-eu.opensuse.org
        - is_download_o_o        hdr(host)     -i download.opensuse.org
        - is_graylog             hdr(host)     -i graylog.opensuse.org
        - is_obsreview           hdr(host)     -i obs-reviewlab.opensuse.org
        - is_openqa              hdr(host)     -i openqa.opensuse.org
        - is_openqa              hdr(host)     -i devel.openqa.opensuse.org
        - is_board               hdr(host)     -i board.opensuse.org
        - is_redirect_itsself    hdr(host)     -i redirector.opensuse.org
        - is_rpmlint             hdr(host)     -i rpmlint.opensuse.org
        - is_susestudio          hdr_reg(host) -i (.*\.)?susestudio.com
        - is_svn                 hdr(host)     -i svn.opensuse.org
        - is_redirect_git        hdr(host)     -i git.opensuse.org
        - is_svn                 hdr(host)     -i kernel.opensuse.org
        - is_upgrade             hdr(host)     -i upgrade.opensuse.org
        - is_test_wiki           hdr(host)     -i en-test.opensuse.org
        - is_wiki                hdr(host)     -i wiki.opensuse.org
        - is_dewiki              hdr(host)     -i dewiki.opensuse.org
        - is_mediawiki_cz        hdr(host)     -i cz.opensuse.org
        - is_mediawiki_cn        hdr(host)     -i cz.opensuse.org
        - is_wiki_gone           hdr(host)     -i fi.opensuse.org
        - is_wiki_gone           hdr(host)     -i is.opensuse.org
        - is_wiki_gone           hdr(host)     -i vi.opensuse.org

      redirects:
        - scheme https code 301  if !is_ssl !is_conncheck !is_mirrorcache !is_mirrorcache_eu !is_download_o_o
        - code 301 location https://static.opensuse.org/favicon.ico code 302 if path_favicon is_www
        - code 301 prefix   https://events.opensuse.org if is_redirect_events
        - code 301 location https://www.youtube.com/user/opensusetv if is_tube
        - code 301 location https://gitlab.com/apparmor/apparmor/wikis/home if is_apparmor
        - code 301 location https://progress.opensuse.org/projects/opensuse-board if is_board
        - code 301 location https://en.opensuse.org/Portal:Support if is_help
        - code 301 location https://en.opensuse.org/openSUSE:Submitting_bug_reports if is_bugs
        - code 301 location https://en.opensuse.org/Upgrade if is_upgrade
        - code 301 location https://github.com/openSUSE/obs-service-format_spec_file/blob/master/README.md if is_license
        - code 301 prefix   https://en.opensuse.org if is_wiki
        - code 301 prefix   https://de.opensuse.org if is_dewiki
        - code 301 prefix   https://cs.opensuse.org if is_mediawiki_cz
        - code 301 prefix   https://languages.opensuse.org if is_wiki_gone
        - code 301 location https://studioexpress.opensuse.org if is_susestudio
        - code 301 location https://www.opensuse.org if is_redirect_itsself
        - code 301 location https://en.opensuse.org/Portal:Education if is_education
        - code 301 location https://en.opensuse.org/Git if is_redirect_git
        - code 302 location https://opensuse.github.io/fuel-ignition/ if is_ignite
        - code 302 location https://opensuse.github.io/fuel-ignition/ if is_ignite_stage
        - code 302 location https://en.opensuse.org/Code_of_Conduct if is_coc
        - code 302 location https://meet.opensuse.org/bar if is_bar

      default_backend: redirect_www_o_o
      use_backends:
        - error_403        if path_dot_scm
        - security_txt     if path_security
        - jenkins          if is_jenkins
        - conncheck        if is_conncheck
        - freeipa          if is_freeipa
        - mickey           if is_gitlab
        - hydra            if is_hydra is_ssl
        - metrics          if is_metrics
        - mirrorlist       if is_mirrorlist
        - mirrorcache      if is_mirrorcache
        - mirrorcache      if is_download_o_o
        - mirrorcache-eu   if is_mirrorcache_eu
        - obsreview        if is_obsreview
        - openqa           if is_openqa
        - rpmlint          if is_rpmlint
        - svn              if is_svn
