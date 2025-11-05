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
    abbr -a gwta 'gwt add --sesh'
    abbr -a wgwta 'gwt add --sesh --webstorm'
    abbr -a ggwta 'gwt add --sesh --goland'
    abbr -a pgwta 'gwt add --sesh --pycharm'
    abbr -a gwtrm 'gwt remove'
    abbr -a gwtrmf 'gwt remove --force'
    abbr -a gwtls 'gwt list'

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

    function diff
      set file1 $(mktemp /tmp/diff1.XXXXXX)
      set file2 $(mktemp /tmp/diff2.XXXXXX)

      gum write --header "Enter first text" > "$file1"
      gum write --header "Enter second text" > "$file2"

      if cmp -s "$file1" "$file2"
        echo "The texts are identical."
      else
        delta "$file1" "$file2"
      end
      rm "$file1" "$file2"
    end
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
bind -M insert \cg 'lazygit'
bind -M default \cg 'lazygit'
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
set -Ux FZF_DEFAULT_OPTS '--cycle --layout=reverse --border --height=90% --preview-window=wrap --marker="*"'

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

# # pnpm
# set -gx PNPM_HOME "/home/jorge/.local/share/pnpm"
# if not string match -q -- $PNPM_HOME $PATH
#   set -gx PATH "$PNPM_HOME" $PATH
# end
# # pnpm end
