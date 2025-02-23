#!/usr/bin/env bash

if [ -n "$1" ]; then
	HOST=$1
else
	HOST=$(hostname)
fi

sudo nixos-rebuild --flake ".#$HOST" install
