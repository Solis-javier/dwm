#!/usr/bin/bash

interval=0

## Cpu Info
cpu_info() {
	cpu_load=$(grep -o "^[^ ]*" /proc/loadavg)

	printf "^c#3b414d^ ^b#7ec7a2^ "
	printf "^c#abb2bf^ ^b#353b45^ $cpu_load"
}

## Memory
memory() {
	printf "^c#C678DD^^b#1e222a^   $(free -h | awk '/^Mem/ { print $3 }' | sed s/i//g) "
}

## Wi-fi
wlan() {
	case "$(cat /sys/class/net/w*/operstate 2>/dev/null)" in
		up) printf "^c#3b414d^^b#7aa2f7^  ^d^%s" " ^c#7aa2f7^Connected " ;;
		down) printf "^c#3b414d^^b#E06C75^ 睊 ^d^%s" " ^c#E06C75^Disconnected " ;;
	esac
}

## Time
clock() {
	printf "^c#1e222a^^b#668ee3^  "
	#printf "^c#1e222a^^b#7aa2f7^ $(date '+%a, %I:%M %p') "
	printf "^c#1e222a^^b#7aa2f7^ $(date '+%a, %d-%m-%Y, %I:%M %p') "
}

## System Update
updates() {
	updates=$(checkupdates | wc -l)

	if [ -z "$updates" ]; then
		printf "^c#98C379^^b#FFC300^  Updated"
	else
		printf "^c#98C379^^b#ff5733^^b#222222^ $updates"" updates"
		printf "^c#ff5555^"
	fi
}

# 	curl


get_weather()
{
	#curl -s v2.wttr.in/resistencia | grep -e "Weather" | sed -n 2p | sed s/Weather://g | sed 's/,//g' | sed 's/+//g' | sed 's/°C.*/°C/' | sed 's/.*m//'
	curl -s v2.wttr.in/resistencia | grep -e "Weather" | sed -n 2p | sed s/Weather://g | sed 's/,//g' | sed 's/+//g' | sed 's/°C.*/°C/'| awk '{print "^b#FFFFFF^^b#222222^", ""$3"", ""$4""}'   
}


if [ $(( 10#$(date '+%S') % 30 )) -eq 0 ]; then
	get_weather
fi

## Battery Info


## Brightness

## Main
while true; do
  [ "$interval" == 0 ] || [ $(("$interval" % 3600)) == 0 ] && updates=$(updates) && weather_is=$(get_weather)
  interval=$((interval + 1))

  sleep 1 && xsetroot -name "$updates $weather_is $(cpu_info) $(memory) $(wlan) $(clock)"
done
