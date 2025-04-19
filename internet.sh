#!/bin/sh
meinInterface=$(ip link | grep -oP '(?<=: )wl[^:]*')
if [ -z "$meinInterface" ]; then
    echo "where did the wifi adapter go?"
    exit 1
fi
printf "enter the god damn SSID: "
read ssid
printf "enter the god damn password: "
read pw
ip link set "$meinInterface" up
iw "$meinInterface" scan | while read -r line; do
    if echo "$line" | grep -q "$ssid"; then
        break
    fi
done
wpa_passphrase "$ssid" "$pw" > wpa.conf
wpa_supplicant -B -i "$meinInterface" -c wpa.conf -D nl80211
sleep 2
if command -v dhclient >/dev/null 2>&1; then
    dhclient "$meinInterface"
elif command -v dhcpcd >/dev/null 2>&1; then
    dhcpcd "$meinInterface"
else
    echo "you dont have a wifi interface :trol:"
fi
