#!/bin/env bash

# Configure names of external and internal displays
EXTERNAL="HDMI-A-1"
INTERNAL="eDP-1"

function show() {
	way-displays --delete DISABLED "$1" >/dev/null
}

function hide() {
	way-displays -s DISABLED "$1" >/dev/null
}

OPT_INTERNAL="Internal display"
OPT_EXTERNAL="External display"
OPT_BOTH="Both displays"

function menu() {
	echo "${OPT_INTERNAL}"
	echo "${OPT_EXTERNAL}"
	echo "${OPT_BOTH}"
}

OPTION=$( (menu) | wofi -dmenu -p "Configure displays")

# Invoke way-displays. Only hide a display if showing the other display
# succeeded. This reduces the chances to end up with both displays turned off,
# which is typically rather inconvenient.
if [ "${OPTION}" == "${OPT_INTERNAL}" ]; then
	show "${INTERNAL}" && hide "${EXTERNAL}"
elif [ "${OPTION}" == "${OPT_EXTERNAL}" ]; then
	show "${EXTERNAL}" && hide "${INTERNAL}"
elif [ "${OPTION}" == "${OPT_BOTH}" ]; then
	show "${EXTERNAL}"
	show "${INTERNAL}"
fi
