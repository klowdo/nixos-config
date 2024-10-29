#!/usr/bin/env bash


##### get ids #####
pa_sink_id(){
	local sinkName=$1
	pactl list short sinks | grep "$sinkName" | awk '{print $1}' 
}
pa_card_id(){
	local cardName=$1
	pactl list short cards | grep "$cardName" | awk '{print $1}' 
}

pa_source_id(){
	local sourceName=$1
	pactl list short sources | grep "input"  | grep "$sourceName" | awk '{print $1}'
}

#
set_source(){
	local source_name=$1
	local source_id=$(pa_source_id $source_name)
	pactl set-default-source $source_id 
}
  
##### SET ACTIONS #####
set_profile(){
	local sink_name=$1
	local profile_name=$2
	local card_id=$(pa_card_id $sink_name)
        pactl set-card-profile $card_id $profile_name
	local sink_id=$(pa_sink_id $sink_name)
	pactl set-default-sink $sink_id 
}

set_output(){
	local sink_name=$1
	local sink_id=$(pa_sink_id $sink_name)
	pactl set-default-sink $sink_id 
}

##### SETUPS ##### 
headsetCall(){
	set_source "Jabra_Link_380"
	set_profile "Jabra_Link_380" "output:iec958-stereo+input:mono-fallback"
	set_output "Jabra_Link_380" 
}

headsetMusic(){
	set_profile "Jabra_Link_380" "output:analog-stereo+input:mono-fallback"
	set_output "Jabra_Link_380"
}

laptop(){
	set_source "skl_hda_dsp_generic"
	set_output "skl_hda_dsp_generic"
}

homeSpeakers(){
	set_source "HP_Z40c_G3_USB"
	set_output "KT_USB_Audio"
}

choises="laptop"
choises+="\\nHeadset (Music)"
choises+="\\nHeadset (Call)"
choises+="\\nHome Speakers"

 choice=$(echo -e "$choises" | wofi -d -p "Audio setup?" --hide-scroll --allow-markup  --width=600 --height=400)
 
case "$choice" in
	"Headset (Music)") headsetMusic & ;;
	"Headset (Call)") headsetCall & ;;
 "Home Speakers") homeSpeakers & ;;
 laptop) laptop & ;;
esac



