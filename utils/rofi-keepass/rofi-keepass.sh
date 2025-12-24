#!/bin/sh

PASSWORD_DATABASE="$1"

KEY_DESC="keepassxc:$(printf "%s" "$PASSWORD_DATABASE" | sha256sum)"
KEY_ID=$(keyctl search @s user "$KEY_DESC" 2> /dev/null)

if [ $? -ne 0 ]; then
	KEY_ID=$(rofi -dmenu -i -p "Enter database password" -l 0 -password -width 500 | keyctl padd user "$KEY_DESC" @s)
fi

keyctl pipe "$KEY_ID" | keepassxc-cli db-info -q "$PASSWORD_DATABASE"
if [ $? -eq 1 ]; then
	rofi -e "Password invalid"
	keyctl revoke "$KEY_ID"
	exit
fi

PASS_ID=$(keyctl pipe "$KEY_ID" | keepassxc-cli ls -qRf "$PASSWORD_DATABASE" | rofi -dmenu -i -p "Select Password")

if [ -z "$PASS_ID" ]; then
	exit 1
fi

{
	keyctl pipe "$KEY_ID" | keepassxc-cli clip -q "$PASSWORD_DATABASE" "$PASS_ID" 10
} & _bgtask=$!

USERNAME=$(keyctl pipe "$KEY_ID" | keepassxc-cli show -qa UserName "$PASSWORD_DATABASE" "$PASS_ID" 2>/dev/null)
notify-send -t 5000 "$PASS_ID: $USERNAME" "Das Passwort wurde für 10 Sekunden in der Zwischenablage gespeichert"

TOTP=$(keyctl pipe "$KEY_ID" | keepassxc-cli show -qt "$PASSWORD_DATABASE" "$PASS_ID" 2>/dev/null)
if [ $? -eq 0 ]; then
	notify-send -t 10000 "$PASS_ID: $USERNAME" "Der TOTP-Token lautet <b>$TOTP</b>"
fi

wait $_bgtask
