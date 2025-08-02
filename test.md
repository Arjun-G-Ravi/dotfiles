set $mod Mod4

# Font for window titles. Will also be used by the bar unless a different font
# is used in the bar {} block below.
font pango:System San Fransisco Display 8

# This font is widely installed, provides lots of unicode glyphs, right-to-left
# text rendering and scalability on retina/hidpi displays (thanks to pango).
#font pango:DejaVu Sans Mono 8

# Start XDG autostart .desktop files using dex. See also
# https://wiki.archlinux.org/index.php/XDG_Autostart
exec --no-startup-id dex --autostart --environment i3

# The combination of xss-lock, nm-applet and pactl is a popular choice, so
# they are included here as an example. Modify as you see fit.

# xss-lock grabs a logind suspend inhibit lock and will use i3lock to lock the
# screen before suspend. Use loginctl lock-session to lock your screen.
exec --no-startup-id xss-lock --transfer-sleep-lock -- i3lock --nofork

# NetworkManager is the most popular way to manage wireless networks on Linux,
# and nm-applet is a desktop environment-independent system tray GUI for it.
exec --no-startup-id nm-applet

# Use pactl to adjust volume in PulseAudio.
set $refresh_i3status killall -SIGUSR1 i3status
bindsym XF86AudioRaiseVolume exec --no-startup-id pactl set-sink-volume @DEFAULT_SINK@ +10% && $refresh_i3status
bindsym XF86AudioLowerVolume exec --no-startup-id pactl set-sink-volume @DEFAULT_SINK@ -10% && $refresh_i3status
bindsym XF86AudioMute exec --no-startup-id pactl set-sink-mute @DEFAULT_SINK@ toggle && $refresh_i3status
bindsym XF86AudioMicMute exec --no-startup-id pactl set-source-mute @DEFAULT_SOURCE@ toggle && $refresh_i3status

# Use Mouse+$mod to drag floating windows to their wanted positione
floating_modifier $mod

# start a terminal
bindsym $mod+Return exec alacritty #i3-sensible-terminal
# kill focused window
# bindsym $mod+Shift+q kill

# change focus
bindsym $mod+j focus left
bindsym $mod+k focus down
bindsym $mod+l focus up
bindsym $mod+semicolon focus right

# alternatively, you can use the cursor keys:
bindsym $mod+Left focus left
bindsym $mod+Down focus down
bindsym $mod+Up focus up
bindsym $mod+Right focus right

# move focused window
# bindsym $mod+Shift+h move left
bindsym $mod+Shift+j move down
bindsym $mod+Shift+k move up
bindsym $mod+Shift+l move right

# alternatively, you can use the cursor keys:
bindsym $mod+Shift+Left move left
bindsym $mod+Shift+Down move down
bindsym $mod+Shift+Up move up
bindsym $mod+Shift+Right move right

# split in horizontal orientation
bindsym $mod+Shift+h split h

# split in vertical orientation
bindsym $mod+Shift+v split v

# enter fullscreen mode for the focused container
bindsym $mod+f fullscreen toggle

# change container layout (stacked, tabbed, toggle split)
bindsym $mod+s layout stacking
# bindsym $mod+Shift+s layout tabbed
bindsym $mod+Shift+s layout toggle split

# toggle tiling / floating
bindsym $mod+Shift+space floating toggle

# change focus between tiling / floating windows
bindsym $mod+space focus mode_toggle

# focus the parent container
bindsym $mod+a focus parent

# focus the child container
#bindsym $mod+d focus child

# Define names for default workspaces for which we configure key bindings later on.
# We use variables to avoid repeating the names in multiple places.

set $ws1 "1: 🖥️"
set $ws2 "2: 👨‍💻"
set $ws3 "3: 🌐"
set $ws4 "4: 🌐"
set $ws5 "5: 🤖"
set $ws6 "6: 📞"
set $ws7 "7: 7 "
set $ws8 "8: 8"
set $ws9 "9: 📹"
set $ws10 "10 🗑️"


# switch to workspace
bindsym $mod+1 workspace number $ws1
bindsym $mod+2 workspace number $ws2
bindsym $mod+3 workspace number $ws3
bindsym $mod+4 workspace number $ws4
bindsym $mod+5 workspace number $ws5
bindsym $mod+6 workspace number $ws6
bindsym $mod+7 workspace number $ws7
bindsym $mod+8 workspace number $ws8
bindsym $mod+9 workspace number $ws9
bindsym $mod+0 workspace number $ws10

# move focused container to workspace
bindsym $mod+Shift+1 move container to workspace number $ws1
bindsym $mod+Shift+2 move container to workspace number $ws2
bindsym $mod+Shift+3 move container to workspace number $ws3
bindsym $mod+Shift+4 move container to workspace number $ws4
bindsym $mod+Shift+5 move container to workspace number $ws5
bindsym $mod+Shift+6 move container to workspace number $ws6
bindsym $mod+Shift+7 move container to workspace number $ws7
bindsym $mod+Shift+8 move container to workspace number $ws8
bindsym $mod+Shift+9 move container to workspace number $ws9
bindsym $mod+Shift+0 move container to workspace number $ws10


# reload the configuration file
bindsym $mod+Shift+c reload
# restart i3 inplace (preserves your layout/session, can be used to upgrade i3)
bindsym $mod+Shift+r restart
# exit i3 (logs you out of your X session)
bindsym $mod+Shift+e exec "i3-nagbar -t warning -m 'Do you really want to exit i3?' -B 'Yes, exit i3' 'i3-msg exit'"

# resize window (you can also use the mouse for that)
mode "resize" {
        # These bindings trigger as soon as you enter the resize mode

        # Pressing left will shrink the window’s width.
        # Pressing right will grow the window’s width.
        # Pressing up will shrink the window’s height.
        # Pressing down will grow the window’s height.
        bindsym j resize shrink width 10 px or 10 ppt
        bindsym k resize grow height 10 px or 10 ppt
        bindsym l resize shrink height 10 px or 10 ppt
        bindsym semicolon resize grow width 10 px or 10 ppt

        # same bindings, but for the arrow keys
        bindsym Left resize shrink width 10 px or 10 ppt
        bindsym Down resize grow height 10 px or 10 ppt
        bindsym Up resize shrink height 10 px or 10 ppt
        bindsym Right resize grow width 10 px or 10 ppt

        # back to normal: Enter or Escape or $mod+r
        bindsym Return mode "default"
        bindsym Escape mode "default"
        bindsym $mod+r mode "default"
}

bindsym $mod+r mode "resize"

#----------------------------------------------------------------------- Additional things starts here
focus_follows_mouse no
# exec --no-startup-id compton -b & # run compton in the background
assign [class = "Obsidian"] $ws1
exec_always --no-startup-id picom # set up picom
exec_always --no-startup-id feh --no-fehbg --bg-scale ~/Desktop/wallpaper-moon.jpg # Set wallpaper
# exec --no-startup-id nitrogen --set-scaled ~/Desktop/wallpaper-moon.jpg
for_window [class="^.*"] border pixel 1 # set border pixels
exec_always /home/arjun/Desktop/AI_ENV/bin/python3.10 /home/arjun/.config/i3/workspaces/switch-wallpaper.py

set $bg-color 	         #7f8181
set $inactive-bg-color   #2f343f
set $text-color          #ffffff
set $inactive-text-color #676E7D
set $urgent-bg-color     #E53935


# window colors
#                       border              background         text                 indicator
client.focused          #0249ed           #00af00         $text-color          #00ff00
client.unfocused        $inactive-bg-color $inactive-bg-color $inactive-text-color #00ff00
client.focused_inactive $inactive-bg-color $inactive-bg-color $inactive-text-color #00ff00
client.urgent           $urgent-bg-color    $urgent-bg-color   $text-color          #00ff00
# hide_edge_borders both

# Change default quit shortcut to '$mod+q'
bindsym $mod+q kill

# Window + Tab to move through panes
bindsym Mod4+Tab focus prev
bindsym Mod1+Tab workspace back_and_forth

# Bindings
bindsym Mod4+g exec google-chrome  --password-store=gnome --profile-directory='Default'
bindsym Mod4+Shift+g exec google-chrome --password-store=gnome --profile-directory='Profile 1'
bindsym Mod4+w exec firefox --password-store=gnome
bindsym Mod4+c exec code
bindsym Mod4+e exec open ~
bindsym Mod4+n exec notion-snap-reborn
bindsym Mod4+o exec ./Desktop/software/Obsidian-1.7.7.AppImage --enable-accelerated-2d-canvas --enable-gpu-rasterization --ignore-gpu-blacklist --enable-zero-copy --use-gl=desktop --enable-features=VaapiVideoDecoder
bindsym Mod4+m exec /home/arjun/Desktop/software/mendeley-reference-manager-2.128.0-x86_64.AppImage
bindsym $mod+d exec --no-startup-id rofi -show drun
bindsym $mod+Shift+d exec --no-startup-id rofi -show run
bindsym $mod+Shift+Return exec alacritty -e ~/scripts/fzf-code.fish # code to open terminal in fzf mode with Desktop as the default location
bindsym $mod+h exec bluetoothctl connect AB:CD:EF:01:12:22
bindsym Print exec --no-startup-id flameshot gui
exec --no-startup-id /usr/bin/gnome-keyring-daemon --start --components=secrets

# i3 status bar config
bar {
  	status_command i3blocks -c /home/arjun/.config/i3/i3blocks.conf
	colors {
		background #2e3436
        statusline #d3d7cf
        separator  #888a85
        
		#                  border background  text
        focused_workspace  #0249ed #2e3436 #ffffff
        active_workspace   #4e9a06 #2e3436 #d3d7cf
        inactive_workspace #888a85 #2e3436 #d3d7cf
        urgent_workspace   #cc0000 #2e3436 #ffffff
        binding_mode       #cc0000 #2e3436 #ffffff
	}
}

# Startup apps
exec google-chrome --password-store=gnome --app=https://github.com/copilot --profile-directory='Default'
# exec google-chrome --password-store=gnome --app=https://grok.com/ --profile-directory='Default'
exec i3-msg 'workspace $ws5; append_layout ~/.config/i3/workspaces/ws5.json'
exec --no-startup-id i3-msg 'workspace $ws1; exec ~/Desktop/software/Obsidian-1.7.7.AppImage'
exec firefox
exec cd ~/Desktop/daily-tracker && /home/arjun/Desktop/AI_ENV/bin/python3.10 /home/arjun/Desktop/daily-tracker/main.py

# Move apps to different workspaces
for_window [class="obsidian"] move to workspace $ws1
assign [class = "Mendeley Reference Manager"] $ws1
assign [class = "notion-snap-reborn"] $ws1
assign [class = "firefox"] $ws3
assign [class = "discord"] $ws6
assign [class = "obs"] $ws9
# assign [class = "evince"] $ws4
assign [class = "Evince"] $ws4
assign [class = "Code"] $ws2

# for_window [class="firefox"] move to workspace $ws3
# Others
exec --no-startup-id /usr/bin/gnome-keyring-daemon --start --components=secrets