if status is-interactive
  # Commands to run in interactive sessions can go here
  function l
    exa -l $argv
  end
  function z
    zoxide $argv
  end
  function c
    set curr_win_idx $(tmux display-message -p '#I')
    clear
    tmux clear-history -t $curr_win_idx
  end
  function v
    nvim $argv
  end
  function v.
    nvim . $argv
  end
  function tks
    tmux kill-server $argv
  end
  function ta
    tmux attach $argv
  end
  function tat
    tmux attach -t $argv
  end
  function zd
    set HOME_REPLACER "s|^$HOME/|~/|"
    set result (zoxide query -l | sed -e "$HOME_REPLACER" | fzf)
    set result (echo $result | sed 's/~/\/home\/jorge/')
    cd $result
  end
  function g
    git $argv
  end
  function n
    npm $argv
  end
  function y
    yarn $argv
  end
  function pn
    pnpm $argv
  end
  function p
    python $argv
  end
  function gconf
    nvim ~/.gitconfig $argv
  end
  function gc
    google-chrome $argv
  end
  function e
    exit
  end

  # Abbreviation
  abbr -a tls 'tmux ls'
  abbr -a tn 'tmux new-session -s (pwd | sed \'s/.*\///g\')'
  abbr -a .t 'touch .t && chmod +x .t && echo -e "#!/usr/bin/env bash\n" > .t && nvim .t'
  abbr -a gd 'git diff'
  abbr -a gcm 'git commit -m'
  abbr -a gca 'git commit --amend'
  abbr -a gco 'git checkout'
  abbr -a ga 'git add'
  abbr -a gap 'git add --patch'

  # Directories
  abbr -a cdoc 'cd ~/Documents/'
  abbr -a cdocs 'cd ~/Documents/'
  abbr -a crepos 'cd ~/repos/'

  function nt
    if set -q argv[1]
      set num_tabs (math $argv[1] - 1)
    else
      set num_tabs 1
    end

    set orig_win_idx $(tmux display-message -p '#I')
    for i in (seq 1 $num_tabs)
      tmux new-window
    end
    tmux select-window -t $orig_win_idx
  end

  function c.
    cd $(fd --type directory -H --max-depth 1 | fzf) || exit
  end

  function c..
    cd ..
    set dir "$(fd --type directory -H --max-depth 1 .. | fzf)"
    cd $dir || exit
  end

  function cproj
    set dir "$HOME/repos/$(fd --type directory --max-depth 1 --base-directory $HOME/repos | fzf | sed 's/\.\///')"
    set repo (echo $dir | sed 's/.*\///g')

    if set -q argv[1]
      set command "nt $argv[1]"
    end

    t $dir --command "$command"
  end

  function v.f
    set file "$(fd --type file | fzf)"
    nvim $file
  end

  function v.d
    set dir "$(fd --type directory | fzf)"
    cd $dir || exit
    nvim .
  end

  function ip
    set repo "$HOME/repos/$(fd --type directory --max-depth 1 --base-directory $HOME/repos | fzf)"
    idea $repo > /dev/null 2>&1 &
  end

  function vp
    set dir "$HOME/repos/$(fd --type directory --max-depth 1 --base-directory $HOME/repos | fzf | sed 's/\.\///')"
    set repo (echo $dir | sed 's/.*\///g')

    if [ "$(tmux list-sessions | grep $repo | wc -l)" = "0" ] # session does not yet exist
      if set -q argv[1]
        set command "nt $argv[1] && nvim"
      else
        set command "nt && nvim"
      end
    end

    t $dir --command "$command"
  end

  function vp.
    set dir "$HOME/repos/$(fd --type directory --max-depth 1 --base-directory $HOME/repos | fzf | sed 's/\.\///')"
    set repo (echo $dir | sed 's/.*\///g')

    if [ "$(tmux list-sessions | grep $repo | wc -l)" = "0" ] # session does not yet exist
      if set -q argv[1]
        set command "nt $argv[1] && nvim ."
      else
        set command "nt && nvim ."
      end
    end

    t $dir --command "$command"
  end

  function tnotes
    if [ $(tmux list-sessions | grep 'Documents' | wc -l) -eq 0 ]
      t $HOME/Documents/ --command "tmux rename-window -t 0 'notes' && nvim notes.md"
    else
      t $HOME/Documents/
    end
  end


  # Config files
  function vconf
    if [ "$(tmux list-sessions | grep 'nvim' | wc -l)" = "0" ] # session does not yet exist
      set command "nt && nvim"
    end

    t $HOME/.config/nvim --command "$command"
  end

  function nconf
    if [ "$(tmux list-sessions | grep 'nvim' | wc -l)" = "0" ] # session does not yet exist
      set command "nt && nvim"
    end

    t $HOME/.config/nvim --command "$command"
  end

  abbr -a tconf 'nvim ~/.tmux.conf'
  abbr -a gconf 'nvim ~/.gitconfig'

  function fconf
    if [ "$(tmux list-sessions | grep 'fish' | wc -l)" = "0" ] # session does not yet exist
      set command "nt && nvim config.fish"
    end

    t /home/jorge/.config/fish/ --command "$command"
  end

  # zoxide
  abbr -a za 'zoxide add'

  abbr -a zq 'zoxide query'
  abbr -a zqi 'zoxide query -i'

  abbr -a zr 'zoxide remove'

  function _z_cd
      cd $argv
      or return $status

      commandline -f repaint

      if test "$_ZO_ECHO" = "1"
          echo $PWD
      end
  end

  function z
      set argc (count $argv)

      if test $argc -eq 0
          _z_cd $HOME
      else if begin; test $argc -eq 1; and test $argv[1] = '-'; end
          _z_cd -
      else
          set -l _zoxide_result (zoxide query -- $argv)
          and _z_cd $_zoxide_result
      end
  end

  function zi
      set -l _zoxide_result (zoxide query -i -- $argv)
      and _z_cd $_zoxide_result
  end


  function zri
      set -l _zoxide_result (zoxide query -i -- $argv)
      and zoxide remove $_zoxide_result
  end

  function _zoxide_hook --on-variable PWD
      zoxide add (pwd -L)
  end
end

fish_add_path $HOME/.local/bin/
fish_add_path $HOME/.tmux/plugins/t-smart-tmux-session-manager/bin/
fish_add_path /opt/idea-IC-232.10227.8/bin

bind -M insert \ek kill-line
bind -M insert \eu backward-kill-line
bind -M insert \ec kill-whole-line
bind -M visual -m default y 'fish_clipboard_copy; commandline -f end-selection repaint-mode'

set -gx COLORTERM truecolor
set -gx EDITOR nvim
set -g theme_display_ruby yes
set -g theme_display_virtualenv yes
set -g theme_display_vagrant no
set -g theme_display_vi yes
set -g theme_display_k8s_context no # yes
set -g theme_display_user yes
set -g theme_display_hostname yes
set -g theme_show_exit_status yes
set -g theme_git_worktree_support yes
set -g theme_display_git yes
set -g theme_display_git_dirty yes
set -g theme_display_git_untracked yes
set -g theme_display_git_ahead_verbose yes
set -g theme_display_git_dirty_verbose yes
set -g theme_display_git_master_branch yes
set -g theme_display_date yes
set -g theme_display_cmd_duration yes
set -g theme_powerline_fonts yes
set -g theme_nerd_fonts yes

# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
if test -f /home/jorge/anaconda3/bin/conda
    eval /home/jorge/anaconda3/bin/conda "shell.fish" "hook" $argv | source
end
# <<< conda initialize <<<

