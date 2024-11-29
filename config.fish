if status is-interactive
    # TODO: Add bitwig cloud sync script -> search and copy folders from google drive to bitwig folder

    # General/utility
    abbr -a l 'eza --long'
    abbr -a e 'exit'
    abbr -a slp 'sudo shutdown -s now'
    abbr -a icat 'kitten icat'


    # Programs
    abbr -a s 'sudo'
    abbr -a c 'set curr_win_idx $(tmux display-message -p \'#I\') && clear && tmux clear-history -t $curr_win_idx'
    abbr -a n 'npm'
    # abbr -a y 'yarn'
    abbr -a pn 'pnpm'
    abbr -a p 'python'
    abbr -a ws 'sudo webstorm'
    abbr -a pc 'sudo pycharm'
    abbr -a gl 'sudo goland'
    abbr -a rr 'sudo rustrover'
    abbr -a cl 'sudo clion'
    abbr -a dg 'sudo datagrip'

    # Yazi
    function y
      set tmp (mktemp -t "yazi-cwd.XXXXXX")
      yazi $argv --cwd-file="$tmp"
      if set cwd (command cat -- "$tmp"); and [ -n "$cwd" ]; and [ "$cwd" != "$PWD" ]
        builtin cd -- "$cwd"
      end
      rm -f -- "$tmp"
    end

    # Directories
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

    abbr -a cdoc 'cd ~/Documents/'
    abbr -a cdocs 'cd ~/Documents/'
    abbr -a crepos 'cd ~/repos/'


    # Tmux
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

    function .t
      if not test -e .t
        touch .t && chmod +x .t && echo -e "#!/usr/bin/env bash\n" > .t && nvim .t
      else
        echo ".t already exists"
      end
    end

    abbr -a tconf 'nvim ~/.tmux.conf'
    abbr -a tn 'tmux new-session -s (pwd | sed \'s/.*\///g\')' # TODO: Fix sed \'s/.*\///g\' from being entered
    abbr -a ta 'tmux attach'
    abbr -a tls 'tmux ls'
    abbr -a tks 'tmux kill-server'


    # Git
    abbr -a gconf 'nvim ~/.gitconfig'
    abbr -a g 'git'
    abbr -a gd 'git diff'
    abbr -a gcm 'git commit -m'
    abbr -a gca 'git commit --amend'
    abbr -a gco 'git checkout $(git branch | fzf | tr -d ‘[:space:]’)'
    abbr -a ga 'git add'
    abbr -a gap 'git add --patch'


    # Neovim
    abbr -a v 'nvim'
    abbr -a v. 'nvim .'
    abbr -a v.f 'nvim $(fd --type file | fzf)'
    abbr -a v.d 'cd $(fd --type directory | fzf) && nvim .'


    # Config files
    abbr -a tconf 'nvim ~/.tmux.conf'
    abbr -a gconf 'nvim ~/.gitconfig'


    # IntelliJ
    function iproj
        set repo "$HOME/repos/$(fd --type directory --max-depth 1 --base-directory $HOME/repos | fzf)"
        # TODO: Disown process after creating it
        # There are still jobs active:

        #    PID  Command
        #   9060  idea.sh $repo > /dev/null 2>&1 &

        # A second attempt to exit will terminate them.
        idea.sh $repo > /dev/null 2>&1 &
    end


    # Zoxide
    function zd
        set HOME_REPLACER "s|^$HOME/|~/|"
        set result (zoxide query -l | sed -e "$HOME_REPLACER" | fzf)
        set result (echo $result | sed 's/~/\/Users\/jorge/')
        cd $result
    end

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

    abbr -a za 'zoxide add'
    abbr -a zq 'zoxide query'
    abbr -a zqi 'zoxide query -i'
    abbr -a zr 'zoxide remove'
end


# Path
fish_add_path $HOME/.local/bin/
fish_add_path /usr/local/bin
fish_add_path $HOME/Applications/
fish_add_path $HOME/.tmux/plugins/t-smart-tmux-session-manager/bin/
fish_add_path /opt/idea-IC-232.10227.8/bin/
fish_add_path $HOME/bin/gcc-arm-none-eabi-10.3-2021.10/
fish_add_path $HOME/go/bin/
fish_add_path $ANDROID_HOME/tools/
fish_add_path $ANDROID_HOME/emulator/
fish_add_path $ANDROID_HOME/platform-tools/


# Key bindings
bind -M insert \ek 'kill-line'
bind -M insert \eu 'backward-kill-line'
bind -M insert \ec 'kill-whole-line'
bind -M insert \cy 'y && tmux send-keys Enter'
bind -M visual -m default y 'fish_clipboard_copy; commandline -f end-selection repaint-mode'


# Config
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

set -x T_REPOS_DIR $HOME/repos/
set -x YAZI_CONFIG_HOME $HOME/.config/yazi/
set -x DYLD_LIBRARY_PATH /opt/homebrew/lib/

# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
if test -f /opt/anaconda3/bin/conda
    eval /opt/anaconda3/bin/conda "shell.fish" "hook" $argv | source
else
    if test -f "/opt/anaconda3/etc/fish/conf.d/conda.fish"
        . "/opt/anaconda3/etc/fish/conf.d/conda.fish"
    else
        set -x PATH "/opt/anaconda3/bin" $PATH
    end
end
# <<< conda initialize <<<

# bun
set --export BUN_INSTALL "$HOME/.bun"
set --export PATH $BUN_INSTALL/bin $PATH

# pnpm
set -gx PNPM_HOME "/Users/jorge/Library/pnpm"
if not string match -q -- $PNPM_HOME $PATH
  set -gx PATH "$PNPM_HOME" $PATH
end
# pnpm end
