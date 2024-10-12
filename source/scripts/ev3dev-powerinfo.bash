#!/usr/bin/bash

HAS_DATA=0

print_generic_info() {
	for pwr_supply in /sys/class/power_supply/*; do
		if [[ -e "$pwr_supply/uevent" ]]; then
			HAS_DATA=1
			echo "Power supply info"
			echo "================="
			cat $pwr_supply/uevent
			echo
		fi
	done
}

print_power_info() {
	for pwr_supply in /sys/class/power_supply/*; do
		if [[ -e "$pwr_supply/current_now" ]]; then
			HAS_DATA=1
			echo "Power usage"
			echo "==========="
			uVolts=`cat $pwr_supply/voltage_now`
			intVolts=`expr $uVolts / 1000000`
			decmicroVolts=`expr $uVolts - $intVolts \* 1000000`
			decmiliVolts=`expr $decmicroVolts / 1000`
			printf "%-20s: %4d.%03d  V\n" "Voltage" $intVolts $decmiliVolts

			uAmps=`cat $pwr_supply/current_now`
			intmiliAmps=`expr $uAmps / 1000`
			decmiliAmps=`expr $uAmps - $intmiliAmps \* 1000`
			printf "%-20s: %4d.%03d mA\n" "Current" $intmiliAmps $decmiliAmps

			miliVolts=`expr $intVolts \* 1000 + $decmiliVolts`
			miliAmps=`expr $intmiliAmps`
			uWatts=`expr $miliVolts \* $miliAmps`
			intWatts=`expr $uWatts / 1000000`
			decmicroWatts=`expr $uWatts - $intWatts \* 1000000`
			decmiliWatts=`expr $decmicroWatts / 1000`
			printf "%-20s: %4d.%03d  W\n" "Power" $intWatts $decmiliWatts
			echo
		else
			print_generic_info
		fi
	done
}

print_power_info

if [[ $HAS_DATA == 0 ]]; then
	echo "No power supply found!"
fi
