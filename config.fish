if status is-interactive
    # TODO: Add bitwig cloud sync script -> search and copy folders from google drive to bitwig folder

    # General/utility
    abbr -a l 'eza --color=always --long --git --no-time'
    abbr -a e exit
    abbr -a slp 'sudo shutdown -s now'
    abbr -a icat 'kitten icat'


    # Programs
    abbr -a s sudo
    abbr -a c 'set curr_win_idx $(tmux display-message -p \'#I\') && clear && tmux clear-history -t $curr_win_idx'
    abbr -a n npm
    # abbr -a y yarn
    abbr -a y y
    abbr -a pn pnpm
    abbr -a p python
    abbr -a ws 'webstorm . >/dev/null 2>&1 &'
    abbr -a pc 'pycharm . >/dev/null 2>&1 &'
    abbr -a gl 'goland . >/dev/null 2>&1 &'
    abbr -a rr 'rustrover . >/dev/null 2>&1 &'
    abbr -a cl 'clion . >/dev/null 2>&1 &'
    abbr -a dg 'datagrip . >/dev/null 2>&1 &'
    abbr -a lg lazygit
    abbr -a ghcs 'gh copilot suggest'
    abbr -a ghce 'gh copilot explain'

    # Yazi
    function y
        set tmp (mktemp -t "yazi-cwd.XXXXXX")
        yazi $argv --cwd-file="$tmp"
        if set cwd (command cat -- "$tmp"); and [ -n "$cwd" ]; and [ "$cwd" != "$PWD" ]
            builtin cd -- "$cwd"
        end
        rm -f -- "$tmp"
    end

    # thefuck
    function fk -d "Correct your previous console command"
        set -l fucked_up_command $history[1]
        env TF_SHELL=fish TF_ALIAS=fuck PYTHONIOENCODING=utf-8 thefuck $fucked_up_command THEFUCK_ARGUMENT_PLACEHOLDER $argv | read -l unfucked_command
        if [ "$unfucked_command" != "" ]
            eval $unfucked_command
            builtin history delete --exact --case-sensitive -- $fucked_up_command
            builtin history merge
        end
    end

    # Directories
    function c.
        cd $(fd --type directory -H --max-depth 1 | fzf) || return
    end

    function c..
        cd ..
        set dir "$(fd --type directory -H --max-depth 1 .. | fzf)"
        cd $dir || return
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
            touch .t && chmod +x .t && echo -e "#!/usr/bin/env bash\n" >.t && nvim .t
        else
            echo ".t already exists"
        end
    end

    abbr -a tconf 'nvim ~/.tmux.conf'
    abbr -a tn 'tmux new-session -s (pwd | sed \'s/.*\///g\')' # TODO: Fix sed \'s/.*\///g\' from being entered
    abbr -a t tmux
    abbr -a ta 'tmux attach'
    abbr -a tls 'tmux ls'
    abbr -a tks 'tmux kill-server'


    # Git
    abbr -a gconf 'nvim ~/.gitconfig'
    abbr -a g git
    abbr -a gd 'git diff'
    abbr -a gcm 'git commit -m'
    abbr -a gca 'git commit --amend'
    abbr -a gco 'git checkout $(git branch | fzf | tr -d ‘[:space:]’)'
    abbr -a ga 'git add'
    abbr -a gap 'git add --patch'


    # Neovim
    abbr -a v nvim
    abbr -a v. 'nvim .'
    abbr -a v.f 'nvim $(fd --type file | fzf)'
    abbr -a v.d 'cd $(fd --type directory | fzf) && nvim .'


    # Config files
    abbr -a tconf 'nvim ~/.tmux.conf'
    abbr -a gconf 'nvim ~/.gitconfig'


    # Git worktrees
    function gwt
        # TODO: Add support for remote branches
        switch $(pwd)
            case "$HOME/repos/*"
                if test -d $repo_dir/worktrees
                    set repo_dir "$HOME/repos/$(pwd | sed 's/\/home\/jorge\/repos\///' | sed 's/\/.*//')"
                end
        end
        if not set -q repo_dir
            set repo_candidates $(fd --type directory --max-depth 1 --base-directory $HOME/repos | string trim -c '/')
            for repo in $repo_candidates
                if test -d $HOME/repos/$repo/worktrees
                    set -a worktree_repos $repo
                end
            end
            set repo_name $(printf "%s\n" $worktree_repos | fzf --header "repos" | string trim -c '/' \
                          | sed 's/\/home\/jorge\/repos\///' | sed 's/\/.*//')
            set repo_dir "$HOME/repos/$repo_name"
        end

        if not set -q repo_dir || test $repo_dir = "$HOME/repos/" || test -z $repo_dir
            return
        end
        if test -z $repo_name
            set repo_name $(pwd | sed 's/\/home\/jorge\/repos\///' | sed 's/\/.*//')
        end

        if set -q argv[1]
            set branch $(echo $argv[1] | xargs)
            set branch_search_result $(git -C $repo_dir branch | string trim -c '+* ' | rg ^$branch\$)
            if test -z "$branch_search_result"
                return
            end
        else
            set branch $(git -C $repo_dir branch | fzf --header "branches" | tr -d '[:space:]' \
                        | tr -d " \t\n\r" | string trim -c '+*' | xargs)
        end

        if test -z "$branch"
            return
        end

        set worktree_search_result $(git -C $repo_dir worktree list | tail -n +2 | awk '{print $1}' \
                                    | sed 's/\/home\/jorge\/repos\/'"$repo_name"'\///' \
                                    | rg ^$branch\$)
        if test -z $worktree_search_result
            set original_dir $(pwd)
            cd $repo_dir
            gwta $branch &>/dev/null
            cd $original_dir
            set worktree_dir "$repo_dir/$branch"
            set -g init_cmd "$(~/.config/fish/worktree-create-cmds $worktree_dir)"
        end
        if not test -z $repo_dir && not test -z $branch
            set worktree_dir "$repo_dir/$branch"
            echo "$worktree_dir"
        end
    end

    function wgwt
        set worktree_dir $(gwt)
        if test -z $worktree_dir
            return
        end
        sudo webstorm $worktree_dir
        sesh connect $worktree_dir

        if set -q init_cmd && not test -z $init_cmd
            set session_name (echo $worktree_dir | sed 's/.*\///g')
            sleep 0.5
            tmux send-keys -t $session_name "$init_cmd" Enter
        end
    end

    function ggwt
        set worktree_dir $(gwt)
        if test -z $worktree_dir
            return
        end
        sudo goland $worktree_dir
        sesh connect $worktree_dir

        if set -q init_cmd && not test -z $init_cmd
            set session_name (echo $worktree_dir | sed 's/.*\///g')
            sleep 0.5
            tmux send-keys -t $session_name "$init_cmd" Enter
        end
    end

    function pgwt
        set worktree_dir $(gwt)
        if test -z $worktree_dir
            return
        end
        sudo pycharm $worktree_dir
        sesh connect $worktree_dir

        if set -q init_cmd && not test -z $init_cmd
            set session_name (echo $worktree_dir | sed 's/.*\///g')
            sleep 0.5
            tmux send-keys -t $session_name "$init_cmd" Enter
        end
    end

    function rgwt
        set worktree_dir $(gwt)
        if test -z $worktree_dir
            return
        end
        sudo rustrover $worktree_dir
        sesh connect $worktree_dir

        if set -q init_cmd && not test -z $init_cmd
            set session_name (echo $worktree_dir | sed 's/.*\///g')
            sleep 0.5
            tmux send-keys -t $session_name "$init_cmd" Enter
        end
    end

    function cgwt
        set worktree_dir $(gwt)
        if test -z $worktree_dir
            return
        end
        sudo clion $worktree_dir
        sesh connect $worktree_dir

        if set -q init_cmd && not test -z $init_cmd
            set session_name (echo $worktree_dir | sed 's/.*\///g')
            sleep 0.5
            tmux send-keys -t $session_name "$init_cmd" Enter
        end
    end

    function dgwt
        set worktree_dir $(gwt)
        if test -z $worktree_dir
            return
        end
        sudo datagrip $worktree_dir
        sesh connect $worktree_dir

        if set -q init_cmd && not test -z $init_cmd
            set session_name (echo $worktree_dir | sed 's/.*\///g')
            sleep 0.5
            tmux send-keys -t $session_name "$init_cmd" Enter
        end
    end

    function gwta
        set branch $argv[1]

        if test $(git rev-parse --is-inside-work-tree) != true && not test -d ./worktrees
            echo "Not inside a git work-tree"
            return
        end

        set repo_name $(pwd | sed 's/\/home\/jorge\/repos\///' | sed 's/\/.*//')

        if test -z "$branch"
            # NOTE: fzf doesn't show remote branches
            for b in $(git branch)
                if test -z $(echo $b | string match -r '^\+|\*')
                    set -a branches $(echo $b | string trim -c '+* ')
                end
            end

            if not set -q branches
                echo "No branches available"
                return
            end
            set branch $(printf "%s\n" $branches | fzf --header "branches" | xargs)
        end

        if test -z "$branch"
            return
        end

        set branch $(echo $branch | string trim -c '+* ' | xargs)
        set worktree_dir "$HOME/repos/$repo_name/$branch"
        set branch_search_result $(git branch | string trim -c '+* ' | rg ^$branch\$)
        if not test -z "$branch_search_result"
            set worktree_search_result $(git worktree list | tail -n +2 | awk '{print $1}' \
                                        | sed 's/\/home\/jorge\/repos\/'"$repo_name"'\///' \
                                        | rg ^$branch\$)
            if not test -z "$worktree_search_result"
                echo "Work-tree already exists"
            else
                git worktree add $worktree_dir --checkout $branch &>/dev/null
                echo "$worktree_dir"
            end
        else
            git fetch origin $branch:$branch &>/dev/null
            if test $status -eq 0
                git worktree add $worktree_dir --checkout $branch &>/dev/null
                echo "$worktree_dir"
            else
                git worktree add $worktree_dir -b $branch &>/dev/null
                echo "$worktree_dir"
            end
        end
    end

    function wgwta
        set worktree_dir $(gwta $argv[1])
        if test -z $worktree_dir
            return
        end
        if test $worktree_dir = "Work-tree already exists"
            echo "$worktree_dir"
            return
        end
        sudo webstorm $worktree_dir
        sesh connect $worktree_dir

        set init_cmd $(~/.config/fish/worktree-create-cmds $worktree_dir)
        if test -z "$init_cmd"
            return
        else
            set session_name (echo $worktree_dir | sed 's/.*\///g')
            sleep 0.5
            tmux send-keys -t $session_name "$init_cmd" Enter
        end
    end

    function ggwta
        set worktree_dir $(gwta $argv[1])
        if test -z $worktree_dir
            return
        end
        if test $worktree_dir = "Work-tree already exists"
            echo "$worktree_dir"
            return
        end
        sudo goland $worktree_dir
        sesh connect $worktree_dir

        set init_cmd $(~/.config/fish/worktree-create-cmds $worktree_dir)
        if test -z "$init_cmd"
            return
        else
            set session_name (echo $worktree_dir | sed 's/.*\///g')
            sleep 0.5
            tmux send-keys -t $session_name "$init_cmd" Enter
        end
    end

    function pgwta
        set worktree_dir $(gwta $argv[1])
        if test -z $worktree_dir
            return
        end
        if test $worktree_dir = "Work-tree already exists"
            echo "$worktree_dir"
            return
        end
        sudo pycharm $worktree_dir
        sesh connect $worktree_dir

        set init_cmd $(~/.config/fish/worktree-create-cmds $worktree_dir)
        if test -z "$init_cmd"
            return
        else
            set session_name (echo $worktree_dir | sed 's/.*\///g')
            sleep 0.5
            tmux send-keys -t $session_name "$init_cmd" Enter
        end
    end

    function rgwta
        set worktree_dir $(gwta $argv[1])
        if test -z $worktree_dir
            return
        end
        if test $worktree_dir = "Work-tree already exists"
            echo "$worktree_dir"
            return
        end
        sudo rustrover $worktree_dir
        sesh connect $worktree_dir

        set init_cmd $(~/.config/fish/worktree-create-cmds $worktree_dir)
        if test -z "$init_cmd"
            return
        else
            set session_name (echo $worktree_dir | sed 's/.*\///g')
            sleep 0.5
            tmux send-keys -t $session_name "$init_cmd" Enter
        end
    end

    function cgwta
        set worktree_dir $(gwta $argv[1])
        if test -z $worktree_dir
            return
        end
        if test $worktree_dir = "Work-tree already exists"
            echo "$worktree_dir"
            return
        end
        sudo clion $worktree_dir
        sesh connect $worktree_dir

        set init_cmd $(~/.config/fish/worktree-create-cmds $worktree_dir)
        if test -z "$init_cmd"
            return
        else
            set session_name (echo $worktree_dir | sed 's/.*\///g')
            sleep 0.5
            tmux send-keys -t $session_name "$init_cmd" Enter
        end
    end

    function dgwta
        set worktree_dir $(gwta $argv[1])
        if test -z $worktree_dir
            return
        end
        if test $worktree_dir = "Work-tree already exists"
            echo "$worktree_dir"
            return
        end
        sudo datagrip $worktree_dir
        sesh connect $worktree_dir

        set init_cmd $(~/.config/fish/worktree-create-cmds $worktree_dir)
        if test -z "$init_cmd"
            return
        else
            set session_name (echo $worktree_dir | sed 's/.*\///g')
            sleep 0.5
            tmux send-keys -t $session_name "$init_cmd" Enter
        end
    end

    # TODO: Prompt user to confirm branch deletion after removing work-tree w/ huh cli
    function gwtrm
        set branch $argv[1]

        if test $(git rev-parse --is-inside-work-tree) != true && not test -d ./worktrees
            echo "Not inside a git work-tree"
            return
        end

        set repo_name $(pwd | sed 's/\/home\/jorge\/repos\///' | sed 's/\/.*//')

        if test -z "$branch"
            for b in $(git branch)
                if not test -z $(echo $b | string match -r '^\+|\*')
                    set -a branches $(echo $b)
                end
            end

            if not set -q branches
                echo "No branches available"
                return
            end
            set branch $(printf "%s\n" $branches | fzf --header "worktrees" | string trim -c '+* ' | xargs)
        end

        if test -z "$branch"
            return
        end

        set branch $(echo $branch | string trim -c '+* ' | xargs)
        set worktree_dir "$HOME/repos/$repo_name/$branch"
        set branch_search_result $(git branch | string trim -c '+* ' | rg ^$branch\$)
        if not test -z "$branch_search_result"
            git worktree remove -f $worktree_dir
            echo "Removed work-tree for branch \"$branch\""
        else
            echo "No work-tree exists for branch \"$branch\""
        end
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

        if test "$_ZO_ECHO" = 1
            echo $PWD
        end
    end

    function z
        set argc (count $argv)

        if test $argc -eq 0
            _z_cd $HOME
        else if begin
                test $argc -eq 1; and test $argv[1] = -
            end
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


# # Path
# fish_add_path $HOME/.local/bin/
# fish_add_path /usr/local/bin
# fish_add_path $HOME/.local/share/nvm/v22.12.0/bin/node
# fish_add_path $HOME/.local/share/nvm/v22.12.0/bin/
# fish_add_path $HOME/Applications/
# fish_add_path $HOME/.tmux/plugins/t-smart-tmux-session-manager/bin/
# fish_add_path /opt/idea-IC-232.10227.8/bin/
# fish_add_path $HOME/bin/gcc-arm-none-eabi-10.3-2021.10/
# fish_add_path $HOME/go/bin/
# fish_add_path $ANDROID_HOME/cmdline-tools/latest/bin
# fish_add_path $ANDROID_HOME/emulator/
# fish_add_path $ANDROID_HOME/platform-tools/
# fish_add_path $HOME/anaconda3/bin
# fish_add_path $HOME/.tmux/plugins/tmux-harpoon

# Key bindings
bind -M insert \ek kill-line
bind -M insert \eu backward-kill-line
bind -M insert \ec kil-whole-line
bind -M insert \cy 'y && tmux send-keys Enter'
bind -M default \cy 'y && tmux send-keys Enter'
bind -M insert \cd ''
# bind -M insert \co 'tmux send-keys prevd Enter'
# bind -M default \co 'tmux send-keys prevd Enter'
# bind -M insert \ci 'tmux send-keys nextd Enter'
# bind -M default \ci 'tmux send-keys nextd Enter'
bind -M visual -m default y 'fish_clipboard_copy; commandline -f end-selection repaint-mode'


# # Config
# set -Ux ANDROID_HOME $HOME/Android/Sdk
# set -Ux COLORTERM truecolor
# set -Ux EDITOR nvim
# set -Ux theme_display_ruby yes
# set -Ux theme_display_virtualenv yes
# set -Ux theme_display_vagrant no
# set -Ux theme_display_vi yes
# set -Ux theme_display_k8s_context no # yes
# set -Ux theme_display_user yes
# set -Ux theme_display_hostname yes
# set -Ux theme_show_exit_status yes
# set -Ux theme_git_worktree_support yes
# set -Ux theme_display_git yes
# set -Ux theme_display_git_dirty yes
# set -Ux theme_display_git_untracked yes
# set -Ux theme_display_git_ahead_verbose yes
# set -Ux theme_display_git_dirty_verbose yes
# set -Ux theme_display_git_master_branch yes
# set -Ux theme_display_date yes
# set -Ux theme_display_cmd_duration yes
# set -Ux theme_powerline_fonts yes
# set -Ux theme_nerd_fonts yes
# set -Ux FZF_DEFAULT_OPTS '--cycle --layout=reverse --border --height=90% --preview-window=wrap --marker="*"'

# set -Ux T_REPOS_DIR $HOME/repos/
# set -Ux YAZI_CONFIG_HOME $HOME/.config/yazi/

# # >>> conda initialize >>>
# # !! Contents within this block are managed by 'conda init' !!
# if test -f /home/jorge/anaconda3/bin/conda
#     eval /home/jorge/anaconda3/bin/conda "shell.fish" "hook" $argv | source
# else
#     if test -f "/home/jorge/anaconda3/etc/fish/conf.d/conda.fish"
#         . "/home/jorge/anaconda3/etc/fish/conf.d/conda.fish"
#     else
#         set -x PATH "/home/jorge/anaconda3/bin" $PATH
#     end
# end
# # <<< conda initialize <<<

# # bun
# set --export BUN_INSTALL "$HOME/.bun"
# set --export PATH $BUN_INSTALL/bin $PATH

# # pnpm
# set -gx PNPM_HOME /home/jorge/Library/pnpm
# if not string match -q -- $PNPM_HOME $PATH
#     set -gx PATH "$PNPM_HOME" $PATH
# end
# # pnpm end
