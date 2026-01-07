#!/bin/bash
# Ensure hyprpaper is running
if ! pgrep -x "hyprpaper" > /dev/null; then
    hyprpaper &
    sleep 1
fi

while true; do
    MORNING_DIR="$HOME/.config/backgrounds/morning"
    EVENING_DIR="$HOME/.config/backgrounds/evening"
    NIGHT_DIR="$HOME/.config/backgrounds/night"

    HOUR=$(date +%H)

    if [ "$HOUR" -ge 6 ] && [ "$HOUR" -lt 12 ]; then
        WALLPAPER_DIR="$MORNING_DIR"
    elif [ "$HOUR" -ge 12 ] && [ "$HOUR" -lt 18 ]; then
        WALLPAPER_DIR="$EVENING_DIR"
    else
        WALLPAPER_DIR="$NIGHT_DIR"
    fi

    if [ -d "$WALLPAPER_DIR" ]; then
        WALLPAPER=$(find "$WALLPAPER_DIR" -type f \( -name "*.png" -o -name "*.jpg" \) | shuf -n 1)
       
        # 1. Update hyprpaper.conf with NEW BLOCK SYNTAX
        # This fixes the "no target" error
        cat <<EOF > ~/.config/hypr/hyprpaper.conf
wallpaper {
    monitor = 
    path = $WALLPAPER
    fit_mode = cover
}
EOF

        # 2. Update hyprlock.conf
        sed -i "s|path = .*|path = $WALLPAPER|" ~/.config/hypr/hyprlock.conf

        # 3. Apply instantly without restarting
        # This tells the running hyprpaper to load the new file immediately
        hyprctl hyprpaper preload "$WALLPAPER"
        hyprctl hyprpaper wallpaper ",$WALLPAPER"

        echo "Wallpaper updated to: $WALLPAPER"
    fi

    sleep 3600
done