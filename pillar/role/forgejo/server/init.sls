profile:
  forgejo:
    server:
      config:
        server:
          enable_gzip: true
          ssh_create_authorized_keys_file: false
          ssh_create_authorized_principals_file: false
        security:
          disable_webhooks: true
          login_remember_days: 14
        service:
          allow_only_external_registration: true
          allowed_user_visibility_modes: public
          default_org_member_visible: true
          enable_basic_authentication: false
          enable_internal_signin: false
          enable_notify_mail: true
          show_registration_button: false
          valid_site_url_schemes: https
        badges:
          enabled: false
        repository.upload:
          enabled: false
        ui:
          default_theme: forgejo-dark-tritanopia
          issue_paging_num: 30
        ssh.minimum_key_sizes:
          rsa: 4095
        admin:
          default_email_notifications: true
          external_user_disabled_features:
            - deletion
            - manage_ssh_keys
        oauth2_client:
          account_linking: disabled
          enable_auto_registration: true
          openid_connect_scopes: openid email profile ssh_publickeys
          register_email_confirm: false
          update_avatar: true
        mailer:
          enabled: true
          protocol: smtp
          smtp_addr: localhost
        session:
          same_site: strict
        picture:
          disable_gravatar: true
        packages:
          enabled: false
