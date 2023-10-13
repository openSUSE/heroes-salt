haproxy:
  frontends:
    http-ext-in:
      acls:
        - no_x-frame-option var(txn.host) -m str etherpad.opensuse.org
        - no_x-frame-option var(txn.host) -m str meet.opensuse.org
        - no_x-frame-option var(txn.host) -m str chat.opensuse.org
        - no_x-frame-option var(txn.host) -m str dimension.opensuse.org
        - no_x-frame-option var(txn.host) -m str metrics.opensuse.org
        - is_ssl                 fc_rcvd_proxy
        - path_dot_scm           path_beg      /.git/
        - path_dot_scm           path_beg      /.svn/
        - path_dot_scm           path_beg      /.bzr/
        - path_security          path_end      /.well-known/security.txt
        - path_relnotes          path_beg      /release-notes/
        - path_grafana           path_beg      /grafana/
        - path_kubic_registry    path_beg      /v2/
        - path_openid            path_beg      -i /openid
        - path_openid            path_beg      -i /common/app/
        - path_openid            path_beg      -i /openid-ldap
        - path_openid            path_beg      -i /idp
        - path_searchpage        path_beg      -i /searchPage
        - path_slash             path          /
        - path_favicon           path          /favicon.ico
        - is_www                 hdr(host)     -i www.opensuse.org
        - is_apparmor            hdr(host)     -i apparmor.opensuse.org
        - is_bar                 hdr(host)     -i bar.opensuse.org
        - is_bugs                hdr(host)     -i bugs.opensuse.org
        - is_community2          hdr(host)     -i factory-dashboard.opensuse.org
        - is_redirect_events     hdr(host)     -i summit.opensuse.org
        - is_redirect_events     hdr(host)     -i conference.opensuse.org
        - is_redirect_events     hdr(host)     -i party.opensuse.org
        - is_redirect_events     hdr(host)     -i events-test.opensuse.org
        - is_tube                hdr(host)     -i tube.opensuse.org
        - is_jenkins             hdr(host)     -i ci.opensuse.org
        - is_community           hdr(host)     -i community.opensuse.org
        - is_counter             hdr_reg(host) -i count(er|down)\.opensuse\.org
        - is_contribute          hdr(host)     -i contribute.opensuse.org
        - is_doc                 hdr(host)     -i doc.opensuse.org
        - is_education           hdr(host)     -i education.opensuse.org
        - is_users               hdr(host)     -i users.opensuse.org
        - is_pmya                hdr(host)     -i pmya.opensuse.org
        - is_coc                 hdr(host)     -i coc.opensuse.org
        - is_conncheck           hdr(host)     -i conncheck.opensuse.org
        - is_redirect_doc        hdr_reg(host) -i (docs|activedoc|www\.activedoc|rtfm).opensuse.org
        - is_etherpad            hdr(host)     -i etherpad.opensuse.org
        - is_features            hdr(host)     -i fate.opensuse.org
        - is_features            hdr(host)     -i features.opensuse.org
        - is_redirect_features   hdr_reg(host) -i (idea|ideas).opensuse.org
        - is_forums              hdr(host)     -i forums.opensuse.org
        - is_freeipa             hdr(host)     -i freeipa.infra.opensuse.org
        - is_gcc                 hdr(host)     -i gcc.opensuse.org
        - is_gitlab              hdr(host)     -i gitlab.infra.opensuse.org
        - is_gitlab              hdr(host)     -i gitlab.opensuse.org
        - is_hackweek            hdr(host)     -i hackweek.opensuse.org
        - is_hackweeksc          hdr(host)     -i hackweek.suse.com
        - is_ignite_stage        hdr(host)     -i ignite-stage.opensuse.org
        - is_ignite              hdr(host)     -i ignite.opensuse.org
        - is_deadservice         hdr(host)     -i hellocf.opensuse.org
        - is_help                hdr(host)     -i help.opensuse.org
        {%- for host_hydra in ['hydra', 'anna', 'elsa', 'proxy-ipx1'] %}
        - is_hydra               hdr(host)     -i {{ host_hydra }}.opensuse.org
        {%- endfor %}
        - is_deadservice         hdr(host)     -i icc.opensuse.org
        - is_get_o_o             hdr(host)     -i get.opensuse.org
        {%- for host_jekyll in ['101', 'planet', 'news', 'news-test', 'search-test', 'search', 'universe', 'yast'] %}
        - is_jekyll              hdr(host)     -i {{ host_jekyll }}.opensuse.org
        {%- endfor %}
        - is_www_test            hdr(host)     -i www-test.opensuse.org
        - is_kubic               hdr(host)     -i kubic.opensuse.org
        - is_license             hdr(host)     -i license.opensuse.org
        - is_limesurvey          hdr(host)     -i survey.opensuse.org
        - is_mailman3            hdr(host)     -i lists.opensuse.org
        - is_mailman3            hdr(host)     -i lists-test.opensuse.org
        - is_mailman3            hdr(host)     -i lists.uyuni-project.org
        - is_lnt                 hdr(host)     -i lnt.opensuse.org
        - is_mainpage            hdr(host)     -i opensuse.org
        - is_man                 hdr(host)     -i man.opensuse.org
        - is_manpages            hdr(host)     -i manpages.opensuse.org
        - is_matrix              hdr(host)     -i matrix.opensuse.org
        {%- for host_chat in ['chat', 'dimension', 'webhook'] %}
        - is_chat                hdr(host)     -i {{ host_chat }}.opensuse.org
        {%- endfor %}
        - is_metrics             hdr(host)     -i metrics.opensuse.org
        - is_microos             hdr(host)     -i microos.opensuse.org
        - is_mirrorlist          hdr(host)     -i mirror.opensuse.org
        - is_mirrorlist          hdr(host)     -i mirrors.opensuse.org
        - is_mirrorlist          hdr(host)     -i mirrordb.opensuse.org
        - is_mirrorcache         hdr(host)     -i mirrorcache.opensuse.org
        - is_mirrorcache_eu      hdr(host)     -i mirrorcache-eu.opensuse.org
        - is_download_o_o        hdr(host)     -i download.opensuse.org
        - is_monitor             hdr(host)     -i monitor.opensuse.org
        - is_graylog             hdr(host)     -i graylog.opensuse.org
        - is_deadservice         hdr(host)     -i moodle.opensuse.org
        - is_opi_proxy           hdr(host)     -i opi-proxy.opensuse.org
        {%- for host_pagure in ['code', 'pages', 'ev', 'releases'] %}
        - is_pagure              hdr(host)     -i {{ host_pagure }}.opensuse.org
        {%- endfor %}
        - is_paste               hdr(host)     -i paste.opensuse.org
        - is_paste               hdr(host)     -i paste-test.opensuse.org
        - is_minio               hdr(host)     -i s3.opensuse-project.net
        - is_static_o_o          hdr(host)     -i static.opensuse.org
        {%- for host_static in ['fontinfo', 'people', 'lizards', 'html5test', 'shop', 'studioexpress', 'oom'] %}
        - is_staticpages         hdr(host)     -i {{ host_static }}.opensuse.org
        {%- endfor %}
        - is_obsreview           hdr(host)     -i obs-reviewlab.opensuse.org
        - is_osccollab           hdr(host)     -i osc-collab.opensuse.org
        - is_osccollab           hdr(host)     -i osc-collab-test.opensuse.org
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
        - is_nuka                hdr(host)     -i l10n.opensuse.org
        - is_nuka                hdr(host)     -i i18n.opensuse.org
        - is_test_wiki           hdr(host)     -i en-test.opensuse.org
        - is_wiki                hdr(host)     -i wiki.opensuse.org
        - is_dewiki              hdr(host)     -i dewiki.opensuse.org
        - is_mediawiki_cz        hdr(host)     -i cz.opensuse.org
        - is_mediawiki_cn        hdr(host)     -i cz.opensuse.org
        - is_wiki_gone           hdr(host)     -i fi.opensuse.org
        - is_wiki_gone           hdr(host)     -i is.opensuse.org
        - is_wiki_gone           hdr(host)     -i vi.opensuse.org

      redirects:
        - scheme https code 301  if !is_ssl !is_conncheck !is_static_o_o !is_mirrorcache !is_mirrorcache_eu !is_get_o_o !is_download_o_o !is_pagure
        - code 301 location https://static.opensuse.org/favicon.ico code 302 if path_favicon is_staticpages
        - code 301 location https://static.opensuse.org/favicon.ico code 302 if path_favicon is_www
        - code 301 location https://static.opensuse.org/favicon.ico code 302 if path_favicon is_mailman3
        - code 301 location https://search.opensuse.org if is_www path_searchpage
        - code 301 prefix   https://www.opensuse.org if is_mainpage !path_kubic_registry
        - code 301 prefix   https://events.opensuse.org if is_redirect_events
        - code 301 location https://www.youtube.com/user/opensusetv if is_tube
        - code 301 prefix   https://connect.opensuse.org if is_users
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
        - code 301 location https://doc.opensuse.org if is_redirect_doc
        - code 301 location https://features.opensuse.org if is_redirect_features
        - code 301 location https://en.opensuse.org/Portal:Education if is_education
        - code 301 location https://en.opensuse.org/Git if is_redirect_git
        - code 302 location https://manpages.opensuse.org if is_man
        - code 302 location https://opensuse.github.io/fuel-ignition/ if is_ignite
        - code 302 location https://opensuse.github.io/fuel-ignition/ if is_ignite_stage
        - code 302 location https://en.opensuse.org/Code_of_Conduct if is_coc
        - code 302 location https://meet.opensuse.org/bar if is_bar

      default_backend: redirect_www_o_o
      use_backends:
        - error_403        if path_dot_scm
        - security_txt     if path_security
        - jenkins          if is_jenkins
        - community        if is_community
        - pinot            if is_doc path_relnotes
        - community        if is_doc
        - community2       if is_community2
        - pinot            if is_counter
        - pinot            if is_contribute
        - pinot            if is_pmya
        - conncheck        if is_conncheck
        - deadservices     if is_features || is_deadservice
        - etherpad         if is_etherpad
        - forums           if is_forums
        - freeipa          if is_freeipa
        - gccstats         if is_gcc
        - mickey           if is_gitlab
        - hackweek         if is_hackweek
        - hydra            if is_hydra is_ssl
        - nuka             if is_nuka
        - jekyll           if is_jekyll || is_www_test || is_get_o_o
        - kubic            if is_kubic
        - kubic            if is_microos
        - kubic            if is_mainpage path_kubic_registry
        - limesurvey       if is_limesurvey
        - mailman3         if is_mailman3
        - lnt              if is_lnt
        - man              if is_manpages
        - matrix           if is_matrix
        - chat             if is_chat
        - metrics          if is_metrics
        - mirrorlist       if is_mirrorlist
        - mirrorcache      if is_mirrorcache
        - mirrorcache      if is_download_o_o
        - mirrorcache-eu   if is_mirrorcache_eu
        - jekyll           if path_slash is_monitor
        - monitor_grafana  if path_grafana is_monitor
        - monitor          if is_monitor
        - pagure           if is_pagure
        - opi_proxy        if is_opi_proxy
        - www_openid_ldap  if is_www path_openid
        - staticpages      if is_www || is_staticpages || is_static_o_o
        - osccollab        if is_osccollab
        - obsreview        if is_obsreview
        - openqa           if is_openqa
        - paste            if is_paste
        - minio            if is_minio
        - rpmlint          if is_rpmlint
        - svn              if is_svn
