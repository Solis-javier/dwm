#!/usr/bin/bash

interval=0

SEP1="["
SEP2="]"

## Cpu Info
cpu_info() {
	cpu_load=$(grep -o "^[^ ]*" /proc/loadavg)

	printf " "
	printf " $cpu_load"
}

## Memory
memory() {
	printf "  $(free -h | awk '/^Mem/ { print $3 }' | sed s/i//g) "
}

## Wi-fi
wlan() {
	case "$(cat /sys/class/net/w*/operstate 2>/dev/null)" in
		up) printf "  Connected " ;;
		down) printf " 睊 Disconnected " ;;
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
		printf "  Updated"
	else
		printf "  $updates "" updates"
		
	fi
}

# 	curl

#get_weather()
#{
#	#curl -s v2.wttr.in/resistencia | grep -e "Weather" | sed -n 2p | sed s/Weather://g | sed 's/,//g' | sed 's/+//g' | sed 's/°C.*/°C/' | sed 's/.*m//'
#	curl -s v2.wttr.in/resistencia | grep -e "Weather" | sed -n 2p | sed s/Weather://g | sed 's/,//g' | sed 's/+//g' | sed 's/°C.*/°C/'| awk '{print "^b#400040^^b#400040^", ""$3"", ""$4""}'   
#}

# _[][][][][][][[][][][][][][][][][][][][][][][][][][][][]][][][][][][][][][][][][][][][][][][][][][][][][]

# Date is formatted like like this: "[Mon 01-01-00 00:00:00]"
dwm_date () {
    printf "%s" "$SEP1"
    if [ "$IDENTIFIER" = "unicode" ]; then
        printf "📆 %s" "$(date "+%a %d-%m-%y %T")"
    else
        #printf "DAT %s" "$(date "+%a %d-%m-%y %T")"
        printf " %s" "$(date "+%a %d-%m-%y %T")"
    fi
    printf "%s\n" "$SEP2"
}

dwm_weather() {
    LOCATION=Resistencia

    printf "%s" "$SEP1"
    if [ "$IDENTIFIER" = "unicode" ]; then
        printf "%s" "$(curl -s wttr.in/$LOCATION?format=1)" 
    else
        printf " %s" "$(curl -s wttr.in/$LOCATION?format=1 | grep -o ".[0-9].*")"
    fi
    printf "%s" "$SEP2"
}

dwm_keyboard () {
    printf "%s" "$SEP1"
    if [ "$IDENTIFIER" = "unicode" ]; then
        printf "⌨ %s" "$(setxkbmap -query | awk '/layout/{print $2}')"
    else
        printf " %s" "$(setxkbmap -query | awk '/layout/{print $2}')"
    fi
    printf "%s\n" "$SEP2"
}

dwm_pulse () {
    VOL=$(pamixer --get-volume)
    STATE=$(pamixer --get-mute)
    
  	printf "%s" "$SEP1"
    if [ "$IDENTIFIER" = "unicode" ]; then
       	if [ "$STATE" = "true" ] || [ "$VOL" -eq 0 ]; then
           	printf "🔇"
       	elif [ "$VOL" -gt 0 ] && [ "$VOL" -le 33 ]; then
         	  printf "🔈 %s%%" "$VOL"
       	elif [ "$VOL" -gt 33 ] && [ "$VOL" -le 66 ]; then
         	  printf "🔉 %s%%" "$VOL"
       	else
         	  printf "🔊 %s%%" "$VOL"
       	fi
    else
     	  if [ "$STATE" = "true" ] || [ "$VOL" -eq 0 ]; then
       	    printf ""
       	elif [ "$VOL" -gt 0 ] && [ "$VOL" -le 33 ]; then
         	  printf " %s%%" "$VOL"
       	elif [ "$VOL" -gt 33 ] && [ "$VOL" -le 66 ]; then
         	  printf " %s%%" "$VOL"
        elif [ "$VOL" -gt 33 ] && [ "$VOL" -le 153 ]; then
        		printf " %s%%" "$VOL" 	  
       	else
       			VOL="MAX"
          	printf "^c#FF0000^  %s%" "$VOL"
          	printf "^c#bbbbbb^"
       		
       	fi
    fi
    	printf "%s\n" "$SEP2"    
}

dwm_connman () {
    printf "%s" "$SEP1"
    if [ "$IDENTIFIER" = "unicode" ]; then
        printf "🌐 "
    else
        printf "NET "
    fi

    # get the connmanctl service name
    # this is a UID starting with 'vpn_', 'wifi_', or 'ethernet_', we dont care for the vpn one
    # if the servicename string is empty, there is no online connection
    SERVICENAME=$(connmanctl services | grep -E "^\*AO|^\*O" | grep -Eo 'wifi_.*|ethernet_.*')

    if [ ! "$SERVICENAME" ]; then
        printf "OFFLINE"
        printf "%s\n" "$SEP2"
        return
    else
        STRENGTH=$(connmanctl services "$SERVICENAME" | sed -n -e 's/Strength =//p' | tr -d ' ')
        CONNAME=$(connmanctl services "$SERVICENAME" | sed -n -e 's/Name =//p' | tr -d ' ')
        IP=$(connmanctl services "$SERVICENAME" | grep 'IPv4 =' | awk '{print $5}' | sed -n -e 's/Address=//p' | tr -d ',')
    fi

    # if STRENGTH is empty, we have a wired connection
    if [ "$STRENGTH" ]; then
        printf "%s %s %s%%" "$IP" "$CONNAME" "$STRENGTH"
    else
        printf "%s %s" "$IP" "$CONNAME"
    fi

    printf "%s\n" "$SEP2"
}


dwm_resources () {
	# get all the infos first to avoid high resources usage
	free_output=$(free -h | grep Mem)
	df_output=$(df -h $df_check_location | tail -n 1)
	# Used and total memory
	MEMUSED=$(echo $free_output | awk '{print $3}')
	MEMTOT=$(echo $free_output | awk '{print $2}')
	# CPU temperature
	CPU=$(top -bn1 | grep Cpu | awk '{print $2}')%
	#CPU=$(sysctl -n hw.sensors.cpu0.temp0 | cut -d. -f1)
	# Used and total storage in /home (rounded to 1024B)
	STOUSED=$(echo $df_output | awk '{print $3}')
	STOTOT=$(echo $df_output | awk '{print $2}')
	STOPER=$(echo $df_output | awk '{print $5}')

	printf "%s" "$SEP1"
	if [ "$IDENTIFIER" = "unicode" ]; then
		printf "💻 MEM %s/%s CPU %s STO %s/%s: %s" "$MEMUSED" "$MEMTOT" "$CPU" "$STOUSED" "$STOTOT" "$STOPER"
	else
		printf "STA | MEM %s/%s CPU %s STO %s/%s: %s" "$MEMUSED" "$MEMTOT" "$CPU" "$STOUSED" "$STOTOT" "$STOPER"
	fi
	printf "%s\n" "$SEP2"
}

# Dependancies: wpa_cli
dwm_wpa() {
   CONSTATE=$(wpa_cli status | sed -n '/wpa_state/s/^.*=//p')

   case $CONSTATE in
      'COMPLETED')
         CONSSID=$(wpa_cli status | sed -n '/\<ssid\>/s/^.*=//p')
         CONIP=$(wpa_cli status | sed -n '/ip_address/s/^.*=//p')
         CONRSSI=$(wpa_cli signal_poll | sed -n '/AVG_RSSI/s/^.*=//p')
         if [ "$CONRSSI" -gt -35 ]; then   
            printf "%s" "$SEP1"
            printf "\uF927 %s %s" "$CONSSID" "$CONIP"
            printf "%s\n" "$SEP2"
         elif [ "$CONRSSI" -ge -55 ] && [ "$CONRSSI" -lt -35 ]; then   
            printf "%s" "$SEP1"
            printf "\uF924 %s %s" "$CONSSID" "$CONIP"
            printf "%s\n" "$SEP2"
         elif [ "$CONRSSI" -ge -75 ] && [ "$CONRSSI" -lt -55 ]; then   
            printf "%s" "$SEP1"
            printf "\uF921 %s %s" "$CONSSID" "$CONIP"
            printf "%s\n" "$SEP2"
         else 
            printf "%s" "$SEP1"
            printf "\uF91E %s %s" "$CONSSID" "$CONIP"
            printf "%s\n" "$SEP2"
         fi
         ;;
#======================================================================#
      'DISCONNECTED')
         printf "%s" "$SEP1"
         printf "\uF92D %s" "$CONSTATE"
         printf "%s\n" "$SEP2"
         ;;
      'INTERFACE_DISABLED')
         printf "%s" "$SEP1"
         printf "\uF92D %s" "$CONSTATE"
         printf "%s\n" "$SEP2"
         ;;
#======================================================================#
      'SCANNING')
         printf "%s" "$SEP1"
         printf "\uF92A %s" "$CONSTATE"
         printf "%s\n" "$SEP2"
         ;;
      'ASSOCIATING')
         printf "%s" "$SEP1"
         printf "\uF92A %s" "$CONSTATE"
         printf "%s\n" "$SEP2"
         ;;
      'ASSOCIATED')
         printf "%s" "$SEP1"
         printf "\uF92A %s" "$CONSTATE"
         printf "%s\n" "$SEP2"
         ;;
      'AUTHENTICATING')
         printf "%s" "$SEP1"
         printf "\uF92A %s" "$CONSTATE"
         printf "%s\n" "$SEP2"
         ;;
#======================================================================#
      '4WAY_HANDSHAKE')
         printf "%s" "$SEP1"
         printf "\uF92B %s" "$CONSTATE"
         printf "%s\n" "$SEP2"
         ;;
      'GROUP_HANDSHAKE')
         printf "%s" "$SEP1"
         printf "\uF92B %s" "$CONSTATE"
         printf "%s\n" "$SEP2"
         ;;
      'INACTIVE')
         printf "%s" "$SEP1"
         printf "\uF92B %s" "$CONSTATE"
         printf "%s\n" "$SEP2"
         ;;
   esac
}

# _[][][][][][][[][][][][][][][][][][][][][][][][][][][][]][][][][][][][][][][][][][][][][][][][][][][][][]

if [ $(( 10#$(date '+%S') % 30 )) -eq 0 ]; then
	dwm_weather
fi

## Battery Info


## Brightness

## Main
while true; do
  [ "$interval" == 0 ] || [ $(("$interval" % 3600)) == 0 ] && updates=$(updates)
  interval=$((interval + 1))

  sleep 1 && xsetroot -name "$updates $(dwm_keyboard) $(dwm_weather) $(dwm_pulse) $(dwm_date)"
done
