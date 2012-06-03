#!/bin/sh

mkdir -p ./config
mkdir -p ./config/games
mkdir -p ./config/ips
mkdir -p ./config/localisation
mkdir -p ./config/presets
mkdir -p ./recordings
mkdir -p ./roms
mkdir -p ./savestates
mkdir -p ./screenshots
mkdir -p ./support
mkdir -p ./support/previews
mkdir -p ./support/titles
mkdir -p ./support/icons
mkdir -p ./support/cheats
mkdir -p ./support/hiscores
mkdir -p ./support/samples
mkdir -p ./support/ips
mkdir -p ./support/neocdz
mkdir -p ./neocdiso

#sudo -n /usr/pandora/scripts/op_lcdrate.sh 50

cpu="$(cat /proc/pandora/cpu_mhz_max)"
nub0="$(cat /proc/pandora/nub0/mode)"
nub1="$(cat /proc/pandora/nub1/mode)"

echo absolute > /proc/pandora/nub0/mode
echo absolute > /proc/pandora/nub1/mode

sleep 1

for i
do
	if [ "$i" = "--filter=1" ]; then
		sudo /usr/pandora/scripts/op_videofir.sh none_up
		echo "filter change to none"
	fi
	if [ "$i" = "--filter=0" ]; then
		sudo /usr/pandora/scripts/op_videofir.sh default_up
		echo "filter change to default"
	fi

done

export SDL_VIDEODRIVER=omapdss
export SDL_OMAP_LAYER_SIZE=800x480
#export SDL_OMAP_LAYER_SIZE=300x480
export SDL_OMAP_VSYNC=0
LD_PRELOAD=./libSDL-1.2.so.0 ./fba $1 $2 $3 $4 $5 $6 $7 $8 $9
#./fba $1 $2 $3 $4 $5 $6 $7 $8 $9

sudo /usr/pandora/scripts/op_videofir.sh default_up

echo $nub0 > /proc/pandora/nub0/mode
echo $nub1 > /proc/pandora/nub1/mode
echo $cpu > /proc/pandora/cpu_mhz_max
if [ -e /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor ]; then
	# must poke cpufreq so it does the actual clock transition
	# according to new limits
	gov=$(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor)
	echo $gov > /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
fi


./picorestore

#sudo -n /usr/pandora/scripts/op_lcdrate.sh 60
