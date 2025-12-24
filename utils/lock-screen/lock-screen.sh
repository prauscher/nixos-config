#!/bin/sh

swaylock -f -i $(find /home/prauscher/Nextcloud/wallpapers/ -type f | shuf -n 1)
