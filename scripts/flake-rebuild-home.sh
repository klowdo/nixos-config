#!/usr/bin/env bash

if [ -n "$1" ]; then
	HOST=$1
else
	HOST="$(hostname)"
fi

home-manager switch --flake ".#klowdo@$HOST" --show-trace
