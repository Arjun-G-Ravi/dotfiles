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

    # Setting path
    set -Ux fish_user_paths $fish_user_paths /home/arjun/.local/bin

    # My custom things
    alias ai 'code --ozone-platform-hint=wayland /home/arjun/dev/artificial-intelligence-notes && q'
    alias cs 'code --ozone-platform-hint=wayland /home/arjun/dev/computer-science-notes && q'
    alias ls 'ls -al'
    alias bye 'echo "Goodbye" && shutdown now'
    alias q 'exit'
    alias rm 'trash'
    # alias cd 'z'
    alias cdi 'zi'
    # alias c 'code --ozone-platform-hint=wayland .'
    alias activate_ai_env '. ~/Desktop/AI_ENV/bin/activate.fish'
    alias activate_kaggle_env '. ~/kaggle_env/bin/activate.fish'
    alias logout 'sudo pkill -u arjun' # my username
    
    function cd
        if test -z "$argv"
            builtin cd ~
            return
        end

        # If a matching folder exists in current directory, use it
        if test -d "$argv"
            builtin cd "$argv"
            return
        end

        # Otherwise try zoxide
        set matches (zoxide query --list $argv 2>/dev/null)
        switch (count $matches)
            case 0
                echo "No match found for: $argv"
            case 1
                builtin cd $matches[1]
            case '*'
                set target (zoxide query --interactive $argv)
                if test -n "$target"
                    builtin cd "$target"
                end
        end
    end

    # Merge normal directory completions + zoxide completions
    complete -c cd -a "(
        # Normal directory completions
        __fish_complete_directories (commandline -ct) '' \
        # Plus zoxide completions
        ; zoxide query --list (commandline -ct)
    )"

    function code
        if test -e "$argv"
            command code --ozone-platform-hint=wayland "$argv"
            exit
        end

        set matches (zoxide query --list $argv | wc -l)
        if test $matches -eq 1
            command code --ozone-platform-hint=wayland (zoxide query $argv)
            exit
        else
            set selected_path (zoxide query --interactive $argv)
            if test -n "$selected_path"
                command code --ozone-platform-hint=wayland "$selected_path"
                exit
            end
        end
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

    function gpu-low
        # Lower power limit
        sudo nvidia-smi -pl 100

        # Check if GPU is driving a display
        set processes (nvidia-smi --query-compute-apps=pid --format=csv,noheader | string trim)
        

        if test -z "$processes"
            echo "No active compute processes found. Attempting full GPU reset..."
            # Reset GPU (only works if not driving a monitor)
            sudo nvidia-smi --gpu-reset -i 0
            if test $status -eq 0
                echo "GPU fully reset and in ultra-low power mode"
            else
                echo "GPU reset failed — possibly driving a display"
            end
        else
            echo "GPU in use — Cannot set when to very low power when GPU is in use."
        end

        echo "GPU set to low-power mode (100W limit)"
    end


    function gpu-high
        # Restore default power limit automatically
        set default_limit (nvidia-smi --query-gpu=power.default_limit --format=csv,noheader,nounits) # 390
        sudo nvidia-smi -pl $default_limit

        echo "GPU set to high-performance mode ($default_limit W limit)"
    end


end
