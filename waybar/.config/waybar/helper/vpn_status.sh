#!/bin/bash

# 1. Get the active VPN connection name and Country Code
VPN_NAME=$(nmcli -t -f NAME,TYPE connection show --active | grep -i 'proton' | head -n1 | cut -d: -f1)

if [ -z "$VPN_NAME" ]; then
    echo "{\"text\": \"<span size='13000' foreground='#eba0ac'>🛡️❌</span>\", \"tooltip\": \"VPN Disconnected\"}"
    exit 0
fi

COUNTRY_CODE=$(echo "$VPN_NAME" | awk '{print $2}' | cut -d'-' -f1)

# 2. Dynamically find the VPN interface (instead of hardcoding proton0)
# This looks for any tun, tap, or proton interface currently active
DEV=$(ip route | grep -i 'tun\|proton\|tap' | awk '{print $3}' | head -n1)

# 3. Get Stats (if interface exists)
if [ -n "$DEV" ] && [ -d "/sys/class/net/$DEV" ]; then
    RX=$(cat /sys/class/net/"$DEV"/statistics/rx_bytes 2>/dev/null)
    TX=$(cat /sys/class/net/"$DEV"/statistics/tx_bytes 2>/dev/null)
    RX_MB=$(awk "BEGIN {printf \"%.2f\", $RX/1024/1024}")
    TX_MB=$(awk "BEGIN {printf \"%.2f\", $TX/1024/1024}")
else
    RX_MB="0.00"
    TX_MB="0.00"
fi

# 4. Map Country Code to Name
case "$COUNTRY_CODE" in 
    CA) COUNTRY='Canada';; JP) COUNTRY='Japan';; MX) COUNTRY='Mexico';; 
    NL) COUNTRY='Netherlands';; NO) COUNTRY='Norway';; PL) COUNTRY='Poland';; 
    RO) COUNTRY='Romania';; SG) COUNTRY='Singapore';; CH) COUNTRY='Switzerland';; 
    US) COUNTRY='United States';; *) COUNTRY='Unknown';; 
esac

echo "{\"text\": \"<span size='13000' foreground='#a6e3a1'>🛡️($COUNTRY)</span>\", \"tooltip\": \"$VPN_NAME\nInterface: $DEV\nRX: $RX_MB MB\nTX: $TX_MB MB\"}"