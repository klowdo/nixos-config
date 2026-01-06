#!/usr/bin/env bash

# Source the defaults configuration
source ~/.config/defaults.sh

selectedSink=$(
	ponymix list-short --sink |
		awk -F '\t' '{print $4}' |
		$DEFAULT_DMENU -p "Audio setup?"
)

if [[ -n $selectedSink ]]; then

	selectedSinkID=$(ponymix list-short --sink | awk -F '\t' -v desc="$selectedSink" '$4 == desc {print $2}')
	ponymix set-default --output -d "$selectedSinkID"
fi

mic=$(
	ponymix list-short --input |
		awk -F '\t' '{print $4}' |
		$DEFAULT_DMENU -p "Mic setup?"
)

if [[ -n $mic ]]; then
	selectedMicID=$(ponymix list-short --input | awk -F '\t' -v desc="$mic" '$4 == desc {print $2}')
	ponymix set-default --input -d "$selectedMicID"
fi

echo "----MIC OUTPUT----"
echo "mic for $mic"
ponymix list-short --input | grep "$selectedMicID"

echo "----SPEAKER OUTPUT----"

echo "speaker for $selectedSink"
ponymix list-short --sink | grep "$selectedSinkID"

echo "----OUTPUT----"
