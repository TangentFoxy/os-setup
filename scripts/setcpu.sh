#!/bin/sh

# set/overrides the max cpu frequency used by the current scaler
# original code from https://www.pantz.org/software/cpufreq/usingcpufreqonlinux.html

if [ "$#" -eq 0 ] || [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
	echo "usage: $(basename $0) MAX_CPU_FREQ"
	echo
	exit 0
fi

MAX_CPU_FREQ=$(cat /sys/devices/system/cpu/cpu0/cpufreq/cpuinfo_max_freq)
MIN_CPU_FREQ=$(cat /sys/devices/system/cpu/cpu0/cpufreq/cpuinfo_min_freq)
CHOSEN_PERCENTAGE=$1
CHOSEN_FREQUENCY=$(expr $MAX_CPU_FREQ / 100 \* $CHOSEN_PERCENTAGE)

# TODO: check CHOSEN_FREQUENCY is greater than MIN_CPU_FREQ?

echo "$(basename $0) info: overriding max CPU frequency to $CHOSEN_FREQUENCY" >&2
for f in /sys/devices/system/cpu/*/cpufreq/scaling_max_freq; do
	sudo sh -c "echo -n $CHOSEN_FREQUENCY > $f" 
done
