#!/usr/bin/env bash

# complete -W "up down status" vpn.sh

CONN_NAME=worldstream

postRouting() {
	INT=$1
	VPNIP=$2
	sudo iptables -t nat -j SNAT -I POSTROUTING -o "$INT" -d 0.0.0.0/0 -s "$RANGE" --to-source "$VPNIP"

}

cleanPostRouting() {
	while read -r RULES; do
		sudo iptables -t nat "${RULES}"
	done < <(sudo iptables -t nat -S | grep -- '--to-source' | sed 's/^-A/-D/')
}

vpnIP() {
	sudo /usr/sbin/ipsec status | grep -E "$CONN_NAME\{[[:digit:]]+}:   " | awk '{print $2}' | cut -d/ -f1
}

RANGE=172.29.0.0/16
INTERFACES=("enp0s20f0u1u1" "wlp0s20f3")
# HOMEDNS=192.168.1.252
HOMEDNS=192.168.1.1
DNS1=10.10.16.10
DNS2=10.10.17.10

if [ "$1" == 'up' ]; then
	sudo ipsec up "$CONN_NAME" || exit 1

	# Not needed when bypass-lan enabled
	# sudo ip rule add to $RANGE table main pre 199

	for INT in "${INTERFACES[@]}"; do
		postRouting "$INT" "$(vpnIP)"
		sudo resolvectl dns "$INT" "$DNS1" "$DNS2"
	done

elif [ "$1" == 'down' ]; then
	sudo ipsec down "$CONN_NAME"

	# Not needed when bypass-lan enabled
	# sudo ip rule delete to $RANGE table main pre 199

	for INT in "${INTERFACES[@]}"; do
		sudo resolvectl dns "$INT" "$HOMEDNS"
	done

	cleanPostRouting
elif [ "$1" == 'status' ]; then
	sudo ipsec status "$CONN_NAME"

	# ip rule show
elif [ "$1" == 'repostrouting' ]; then
	cleanPostRouting
	for INT in "${INTERFACES[@]}"; do
		postRouting "$INT" "$(vpnIP)"
	done
else
	echo "have no idea what to do"
fi
