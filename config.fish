if status is-interactive
  # Commands to run in interactive sessions can go here
  function l
    exa -l $argv
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

  # Directories
  function cdoc
    cd ~/Documents/ $argv
  end
  function cdocs
    cd ~/Documents/ $argv
  end
  function cdown
    cd ~/Downloads/ $argv
  end
  function crepos
    cd ~/repos/ $argv
  end

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
  function gconf
    nvim "$HOME/.gitconfig"
  end

  function fconf
    nvim "$HOME/.config/fish/config.fish"
  end
end

# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
if test -f /home/jorge/anaconda3/bin/conda
    eval /home/jorge/anaconda3/bin/conda "shell.fish" "hook" $argv | source
end
# <<< conda initialize <<<

