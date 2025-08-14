#!/bin/bash
# Ensure hyprpaper is running
if ! pgrep -x "hyprpaper" > /dev/null; then
    echo "Starting hyprpaper..."
    hyprpaper &
    sleep 1 # Give hyprpaper time to start
fi

while true; do
    # Define directories
    MORNING_DIR="$HOME/.config/backgrounds/morning"
    EVENING_DIR="$HOME/.config/backgrounds/evening"
    NIGHT_DIR="$HOME/.config/backgrounds/night"

    # Get current hour in 24-hour format
    HOUR=$(date +%H)

    # Determine time period
    if [ "$HOUR" -ge 6 ] && [ "$HOUR" -lt 12 ]; then
        WALLPAPER_DIR="$MORNING_DIR"
    elif [ "$HOUR" -ge 12 ] && [ "$HOUR" -lt 18 ]; then
        WALLPAPER_DIR="$EVENING_DIR"
    else
        WALLPAPER_DIR="$NIGHT_DIR"
    fi

    # Check if directory exists and has images
    if [ -d "$WALLPAPER_DIR" ] && [ "$(ls -A "$WALLPAPER_DIR"/*.{png,jpg} 2>/dev/null)" ]; then
        # Select a random wallpaper from the directory (supports .png and .jpg files)
        WALLPAPER=$(find "$WALLPAPER_DIR" -type f \( -name "*.png" -o -name "*.jpg" \) | shuf -n 1)
       
        # Log selected wallpaper
        echo "Selected wallpaper: $WALLPAPER"

        # Update hyprpaper.conf
        echo "preload = $WALLPAPER" > ~/.config/hypr/hyprpaper.conf
        echo "wallpaper = ,$WALLPAPER" >> ~/.config/hypr/hyprpaper.conf

        # Update hyprlock.conf with the same wallpaper
        sed -i "s|path = .*|path = $WALLPAPER|" ~/.config/hypr/hyprlock.conf

        # Restart hyprpaper to apply changes
        pkill -x hyprpaper
        hyprpaper &
        if [ $? -eq 0 ]; then
            echo "hyprpaper restarted successfully."
        else
            echo "Failed to restart hyprpaper."
        fi
    else
        echo "No wallpapers found in $WALLPAPER_DIR or directory does not exist."
    fi

    # Sleep for 1 hour (3600 seconds)
    sleep 3600
done