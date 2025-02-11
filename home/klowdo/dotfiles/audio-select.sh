#!/usr/bin/env bash

CONFIG_FILE=${1:-./audio-config.yml}

available="$(ponymix list-short --sink | awk -F '\t' '{print $4}')"

known="$(yq '.pairs[].name' -r $CONFIG_FILE)"

selected=$(
	printf '%s\n%s\n' "$known" "$available" | \
	 wofi -i -M fuzzy -d \
	-p "Audio setup?" --hide-scroll --allow-markup  --width=650 --height=400
)

if [[ -z $selected ]]; then
 exit 0
fi

if yq -e ".pairs[] | select(.name == \"$selected\")" $CONFIG_FILE >/dev/null 2>&1; then
	mic=$(yq -e ".pairs[] | select(.name == \"$selected\")| .mic" -r $CONFIG_FILE)
	selected=$(yq -e ".pairs[] | select(.name == \"$selected\")| .speaker" -r $CONFIG_FILE)

	selectedMic=$(ponymix list-short --input | grep -i "$mic" |grep -i -v "monitor" | awk -F '\t' '{print $2}')
else 

	mic=$(
		ponymix list-short --sink | \
		awk -F '\t' '{print $4}' | \
		wofi -i -M fuzzy -d  -p "Mic setup?" \
		 --hide-scroll --allow-markup  --width=650 --height=400
	)

	selectedMic=$(ponymix list-short --input | grep -i "$mic"  | awk -F '\t' '{print $2}')

fi

selectedSink=$(ponymix list-short --sink | grep -i "$selected" | awk -F '\t' '{print $2}')

ponymix set-default --input -d "$selectedMic"
ponymix set-default --sink -d "$selectedSink"


echo "----MIC OUTPUT----"
echo "speaker for $selected"
ponymix list-short --input | grep "$selectedMic"

echo "----SPEAKER OUTPUT----"

echo "speaker for $selected"
ponymix list-short --sink | grep "$selectedSink"

echo "----OUTPUT----"
