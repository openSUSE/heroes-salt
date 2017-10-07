update_gitrepo_dvocc17:
  local.state.apply:
    - tgt: 'roles:dvocc17'
    - expr_form: grain
    - arg:
        - role.dvocc17
