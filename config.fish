# Start in tmux
if status is-interactive && not set -q TMUX
    exec tmux
end

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
  function t
    tmux $argv
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
  abbr -a gcm 'git commit -m'
  abbr -a gca 'git commit --amend'
  abbr -a gco 'git checkout'
  abbr -a ga 'git add'
  abbr -a gap 'git add --patch'

  # Directories
  abbr -a doc 'cd ~/Documents/'
  abbr -a docs 'cd ~/Documents/'
  abbr -a repos 'cd ~/repos/'

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

  function ns
    if set -q argv[1]
      set num_sessions (math $argv[1] - 1)
    else
      set num_sessions 1
    end

    for i in $(seq 1 $num_sessions)
      tmux new-session -d
    end
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
    cd $HOME/repos/ || return
    set dir "$HOME/repos/$(fd --type directory --max-depth 1 | fzf)"
    cd $dir || exit
    if set -q argv[1]
      nt $argv[1]
    end
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

  function vp
    cd $HOME/repos/ || return
    set dir "$HOME/repos/$(fd --type directory --max-depth 1 | fzf)"
    cd $dir || exit

    if set -q argv[1]
      nt $argv[1]
    else
      nt
    end

    nvim
  end

  function vp.
    cd $HOME/repos/ || return
    set dir "$HOME/repos/$(fd --type directory --max-depth 1 | fzf)"
    cd $dir || exit

    if set -q argv[1]
      nt $argv[1]
    else
      nt
    end

    nvim .
  end

  function vrepos
    if set -q argv[1]
      set path $argv[1]
    else
      set path ""
    end

    cd $HOME/repos/$path || return
    nvim .
  end

  function vnotes
    cd $HOME/Documents/ || return
    nvim notes.md
  end

  # Config files
  function vconf
    if set -q argv[1]
      set path $argv[1]
    else
      set path ""
    end

    cd $HOME/.config/nvim || return
    nvim $path
  end

  function nconf
    if set -q argv[1]
      set path $argv[1]
    else
      set path ""
    end

    cd $HOME/.config/nvim || return
    nvim $path
  end

  abbr -a tconf 'nvim ~/.tmux.conf'
  abbr -a gconf 'nvim ~/.gitconfig'

  function fconf
    cd $HOME/.config/fish
    nvim config.fish
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

