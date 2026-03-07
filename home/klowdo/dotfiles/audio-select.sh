#!/usr/bin/env bash

selectedSink=$(
	ponymix list-short --sink |
		awk -F '\t' '{print $4}' |
		wofi -i -M fuzzy -d \
			-p "Audio setup?" --hide-scroll --allow-markup --width=650 --height=400
)

if [[ -n $selectedSink ]]; then

	selectedSinkID=$(ponymix list-short --sink | awk -F '\t' -v desc="$selectedSink" '$4 == desc {print $2}')
	ponymix set-default --output -d "$selectedSinkID"
fi

mic=$(
	ponymix list-short --input |
		awk -F '\t' '{print $4}' |
		wofi -i -M fuzzy -d -p "Mic setup?" \
			--hide-scroll --allow-markup --width=650 --height=400
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
