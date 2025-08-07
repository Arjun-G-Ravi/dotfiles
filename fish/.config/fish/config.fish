if status is-interactive
    fish_add_path /opt/cuda/bin
    if test "$TERMINAL" = "alacritty" -o "$TERM" = "alacritty"
        starship init fish | source
    end
    zoxide init fish | source 
	set -g fish_greeting ""
    # Commands to run in interactive sessions can go here
    bind \t forward-char
    bind \cv fish_clipboard_paste
    bind \cH backward-kill-word

    # important for fzf; dont change
    # set -g FZF_CTRL_T_COMMAND "command find -L \$dir -type f 2> /dev/null | sed '1d; s#^\./##'"

    # Setting path
    set -Ux fish_user_paths $fish_user_paths /home/arjun/.local/bin

    # My custom things
    alias ai 'code /home/arjun/dev/artificial-intelligence-notes && q'
    alias cs 'code /home/arjun/dev/computer-science-notes && q'
    alias ls 'ls -al'
    alias bye 'echo "Goodbye" && shutdown now'
    alias q 'exit'
    alias rm 'trash'
    alias cd 'z'
    alias cdi 'zi'
    # alias c 'code .'
    alias activate_ai_env '. ~/Desktop/AI_ENV/bin/activate.fish'
    alias activate_kaggle_env '. ~/kaggle_env/bin/activate.fish'
    alias logout 'sudo pkill -u arjun' # my username
    
    # function zapp
    #     $argv[1] (zi $argv[2])
    # end

    function c
        code --ozone-platform-hint=wayland (zi $argv) && q
    end


    function cow
        set inp $argv
        if test -z "$argv"
            git add .; and git commit -m "Patch"; and git push
        else
            git add .; and git commit -m "$argv"; and git push
        end
    end

    function push_obsidian 
        cd /home/arjun/Documents/general/_obsidian-backup;git add .; and git commit -m "Added more to obsidian"; and git push
    end

    function pull_obsidian
    cd /home/arjun/Documents/general/_obsidian-backup; git pull
    end

    function nuke
        if test -z $argv
            echo "Usage: newkill <pattern>"
            return 1
        end
        set pattern $argv[1]
        set -l processes (pgrep -l $pattern)

        if test -z "$processes"
            echo "No processes found matching the pattern: $pattern"
            return 1
        else
            echo "Processes matching the pattern '$pattern':"
            for line in $processes
                echo $line
            end
        end
        echo "Do you want to kill these processes? (y/n)"
        set confirm (read)
        if test "$confirm" = "y"
            sudo pkill -9 $pattern
            echo "Processes killed."
        else
            echo "Action aborted."
        end
    end

end
