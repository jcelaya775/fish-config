function fish_user_key_bindings
  fish_default_key_bindings -M insert

  # fzf_key_bindings
  fish_vi_key_bindings --no-erase insert
end

