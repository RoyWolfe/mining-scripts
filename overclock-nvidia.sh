#!/bin/bash
# COMMANDS:
# when installing a new GPU, run with "-init" parameter to set up xconfig setting


## Config variable stuff
# _LO is for -silent switch to be more quiet

CLOCK=150
CLOCK_LO=0
MEM=1000
MEM_LO=0
DEFAULTWATTS=130
DEFAULTWATTS_LO=75
FANSPEED=90
FANSPEED_LO=45

# TODO: use this table for wattages, rather than blanket number above
declare -A wattages=( [0]=130 [1]=120 [2]=130 [3]=110 [4]=130 [5]=130 [6]=115 [7]=130 [8]=130 [9]=130 [10]=130 )
# for w in "${!wattages[@]}"; do echo "$w - ${wattages[$w]}"; done
# reset all clocks: nvidia-smi --rac

# Command line handling

POSITIONAL=()
while [[ $# -gt 0 ]]
do
key="$1"

case $key in
    -init)
    INIT=1
    shift # past argument
    ;;
    -silent)
    SILENT=1
    shift # past argument
    ;;
    *)    # unknown option
    POSITIONAL+=("$1") # save it in an array for later
    shift # past argument
    ;;
esac
done
set -- "${POSITIONAL[@]}" # restore positional parameters

## Do the thing

CMD='/usr/bin/nvidia-settings -t'
SMICMD='/usr/bin/nvidia-smi'
XCONFCMD='/usr/bin/nvidia-xconfig'

NUMGPU="$(nvidia-smi -L | wc -l)"
echo "Setting up ${NUMGPU} GPU(s)"

export DISPLAY=:0
export XAUTHORITY=/var/run/lightdm/root/:0

#echo "performance" >/sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
#echo "performance" >/sys/devices/system/cpu/cpu1/cpufreq/scaling_governor
#echo 2800000 > /sys/devices/system/cpu/cpu0/cpufreq/scaling_min_freq
#echo 2800000 > /sys/devices/system/cpu/cpu0/cpufreq/scaling_min_freq

if [ $(id -u) -ne 0 ]
then
    echo "Please run as root"
    exit 1
fi

if [ $INIT  ]
then
    export DISPLAY=:0
    echo "Generating xconfig ..."
    $XCONFCMD -a --cool-bits=31 --allow-empty-initial-configuration
    echo "Restarting lightdm ..."
    service lightdm restart
fi

if [ $SILENT ]
then
    CLOCK=$CLOCK_LO
    MEM=$MEM_LO
    DEFAULTWATTS=$DEFAULTWATTS_LO
    FANSPEED=$FANSPEED_LO
fi

i=0
while [ $i -lt $NUMGPU ];
do
    echo "Setting persistence and wattage for # $i ..."

    MYWATT=${wattages[$i]}
    if [[ -z $MYWATT ]]
    then
        echo "Wattage for $i not found using default."
        MYWATT=$DEFAULTWATTS
    fi

    if [[ $SILENT ]]
    then
        MYWATT=$DEFAULTWATTS
    fi

    echo "Setting wattage to $MYWATT for GPU $i"
    $SMICMD -i $i -pm 1
    $SMICMD -i $i -pl $MYWATT
    $SMICMD -i $i -ac 4004,1911

    echo "Setting clock offsets for # $i ($CLOCK / $MEM) ..."
    $CMD -a [gpu:$i]/GPUPowerMizerMode=3 -a [gpu:$i]/GPUFanControlState=1 -a [fan:$i]/GPUTargetFanSpeed=$FANSPEED
    $CMD -a [gpu:$i]/GPUGraphicsClockOffset[3]=$CLOCK -a [gpu:$i]/GPUMemoryTransferRateOffset[3]=$MEM

    let i=i+1
done

