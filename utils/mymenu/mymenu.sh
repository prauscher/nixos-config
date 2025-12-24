#!/bin/sh

INPUT=$(rofi -dmenu -p "Menu" <<EOT
run
keepass
thwkeepass
chat
lock
suspend
EOT
)
[ $? -ne 0 ] && exit

OPTION=$(echo "$INPUT" | awk '{ print $1 }')

case "$OPTION" in
run) exec sh -c "rofi -show drun" ;;
keepass) exec sh -c "rofi-keepass /home/prauscher/Nextcloud/Passwords.kdbx" ;;
thwkeepass) exec sh -c "rofi-keepass /home/prauscher/THW/Nextcloud/3.\ Gruppen/OV-Führung/Passwörter.kdbx" ;;
chat) exec sh -c "alacritty -e sh -c 'TERM=xterm256color ssh -t shells.darmstadt.ccc.de \"tmux attach\"'" ;;
lock) exec sh -c "lock-screen" ;;
suspend) exec sh -c "systemctl suspend" ;;
esac


