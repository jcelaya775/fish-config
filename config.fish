if status is-interactive
    # TODO: Add bitwig cloud sync script -> search and copy folders from google drive to bitwig folder

    # General/utility
    function c
        # TODO: Only do tmux stuff if in a tmux session
        set curr_win_idx $(tmux display-message -p '#I')
        clear
        tmux clear-history -t $curr_win_idx
    end

    abbr -a s "sudo"
    abbr -a l "exa -l"
    abbr -a e 'exit'
    abbr -a ss 'systemctl suspend'


    # Programs
    abbr -a n 'npm'
    abbr -a y 'yarn'
    abbr -a pn 'pnpm'
    abbr -a p 'python3'


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
    abbr -a tn 'tmux new-session -s (pwd | sed \'s/.*\///g\')'
    abbr -a ta 'tmux attach'
    abbr -a tls 'tmux ls'
    abbr -a tks 'tmux kill-server'


    # Git
    abbr -a gconf 'nvim ~/.gitconfig'
    abbr -a g 'git'
    abbr -a gd 'git diff'
    abbr -a gcm 'git commit -m'
    abbr -a gca 'git commit --amend'
    abbr -a gco 'git checkout'
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
    function ip
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
        set result (echo $result | sed 's/~/\/home\/jorge/')
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


# Run configuration scripts (xinput stuff)
# for script in ~/scripts/*.sh
#   $script
# end


# Path
fish_add_path $HOME/.local/bin/
fish_add_path $HOME/.tmux/plugins/t-smart-tmux-session-manager/bin/
fish_add_path /opt/idea-IC-232.10227.8/bin
fish_add_path $HOME/bin/gcc-arm-none-eabi-10.3-2021.10/


# Key bindings
bind -M insert \ek kill-line
bind -M insert \eu backward-kill-line
bind -M insert \ec kill-whole-line
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
set -x T_REPOS_DIR $HOME/repos


# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
if test -f /home/jorge/anaconda3/bin/conda
    eval /home/jorge/anaconda3/bin/conda "shell.fish" "hook" $argv | source
end
# <<< conda initialize <<<
