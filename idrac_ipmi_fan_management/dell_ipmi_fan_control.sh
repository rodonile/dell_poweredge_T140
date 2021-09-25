#!/bin/bash
######################################################################
# Setup
######################################################################
PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin
echo "******************************"
echo "***********CRONJOB************"
echo "******************************"
echo
DATE=$(date +%d-%m-%Y--%H:%M:%S)
echo "PROFILE: MEDIUM FAN SPEEDS (DAILY OPERATION, LOW AND ALMOST UNAUDIBLE NOISE). 30% fan speed at stable conditions."
echo "EXECUTION TIME: ${DATE}"
echo
#
IDRACIP="<IDRAC_IP_ADDRESS>" # modify
IDRACUSER="<IDRAC_IP_USER>"  # modify
IDRACPASSWORD="<IDRAC_IP_PASSWORD>" # modify
#
echo "TEMPERATURE READINGS:"
# You might need to adapt the following commands based on your sensors names...
T_amb=$(ipmitool -I lanplus -H $IDRACIP -U $IDRACUSER -P $IDRACPASSWORD sensor reading "Fan1" "Fan2" "Inlet Temp" "Temp" | grep 'Inlet Temp' | cut -d" " -f10)
T_cpu=$(ipmitool -I lanplus -H $IDRACIP -U $IDRACUSER -P $IDRACPASSWORD sensor reading "Fan1" "Fan2" "Inlet Temp" "Temp" | grep '^Temp'| cut -d" " -f15)
echo "  ${IDRACIP}: -- ambient temperature -- $T_amb"
echo "  ${IDRACIP}: -- CPU temperature -- $T_cpu"
echo
#
######################################################################
# Fan management algorithm (30% fan speed at stable conditions)
######################################################################
echo "ALGORITHM DECISIONS:"
#
if (( $T_amb > 50 || $T_cpu > 85 ))
then
	echo "  --> enable dynamic fan control"
    ipmitool -I lanplus -H $IDRACIP -U $IDRACUSER -P $IDRACPASSWORD raw 0x30 0x30 0x01 0x01
#
# Range 1: T_amb [33-36] and T_cpu [55-65]
elif (( $T_amb > 33 && $T_amb <= 36 )) || (( $T_cpu > 55 && $T_cpu <= 65 ));
then
    PERCENTAGE_FAN_SPEED="35"
    HEX_SPEED="$(printf '%x\n' $PERCENTAGE_FAN_SPEED)"
    STATICSPEEDBASE16="0x$HEX_SPEED"
    echo "  --> disable dynamic fan control"
    echo "  --> set static fan speed at $PERCENTAGE_FAN_SPEED % PWM (hex = $STATICSPEEDBASE16)"
    ipmitool -I lanplus -H $IDRACIP -U $IDRACUSER -P $IDRACPASSWORD raw 0x30 0x30 0x01 0x00
    ipmitool -I lanplus -H $IDRACIP -U $IDRACUSER -P $IDRACPASSWORD raw 0x30 0x30 0x02 0xff $STATICSPEEDBASE16
#
# Range 2: T_amb [36-40] and T_cpu [65-70]
elif (( $T_amb > 36 && $T_amb <= 40 )) || (( $T_cpu > 65 && $T_cpu <= 70 ));
then
    PERCENTAGE_FAN_SPEED="40"
    HEX_SPEED="$(printf '%x\n' $PERCENTAGE_FAN_SPEED)"
    STATICSPEEDBASE16="0x$HEX_SPEED"
    echo "  --> disable dynamic fan control"
    echo "  --> set static fan speed at $PERCENTAGE_FAN_SPEED % PWM (hex = $STATICSPEEDBASE16)"
    ipmitool -I lanplus -H $IDRACIP -U $IDRACUSER -P $IDRACPASSWORD raw 0x30 0x30 0x01 0x00
    ipmitool -I lanplus -H $IDRACIP -U $IDRACUSER -P $IDRACPASSWORD raw 0x30 0x30 0x02 0xff $STATICSPEEDBASE16
#
# Range 3: T_amb [40-45] and T_cpu [70-77]
elif (( $T_amb > 40 && $T_amb <= 45 )) || (( $T_cpu > 70 && $T_cpu <= 77 ));
then
    PERCENTAGE_FAN_SPEED="45"
    HEX_SPEED="$(printf '%x\n' $PERCENTAGE_FAN_SPEED)"
    STATICSPEEDBASE16="0x$HEX_SPEED"
    echo "  --> disable dynamic fan control"
    echo "  --> set static fan speed at $PERCENTAGE_FAN_SPEED % PWM (hex = $STATICSPEEDBASE16)"
    ipmitool -I lanplus -H $IDRACIP -U $IDRACUSER -P $IDRACPASSWORD raw 0x30 0x30 0x01 0x00
    ipmitool -I lanplus -H $IDRACIP -U $IDRACUSER -P $IDRACPASSWORD raw 0x30 0x30 0x02 0xff $STATICSPEEDBASE16
#
# Range 3: T_amb [45-50] and T_cpu [77-85]
elif (( $T_amb > 45 && $T_amb <= 50 )) || (( $T_cpu > 77 && $T_cpu <= 85 ));
then
    PERCENTAGE_FAN_SPEED="50"
    HEX_SPEED="$(printf '%x\n' $PERCENTAGE_FAN_SPEED)"
    STATICSPEEDBASE16="0x$HEX_SPEED"
    echo "  --> disable dynamic fan control"
    echo "  --> set static fan speed at $PERCENTAGE_FAN_SPEED % PWM (hex = $STATICSPEEDBASE16)"
    ipmitool -I lanplus -H $IDRACIP -U $IDRACUSER -P $IDRACPASSWORD raw 0x30 0x30 0x01 0x00
    ipmitool -I lanplus -H $IDRACIP -U $IDRACUSER -P $IDRACPASSWORD raw 0x30 0x30 0x02 0xff $STATICSPEEDBASE16
else
    # Stable conditions --> fan speed at 30%
    PERCENTAGE_FAN_SPEED="30"
    HEX_SPEED="$(printf '%x\n' $PERCENTAGE_FAN_SPEED)"
    STATICSPEEDBASE16="0x$HEX_SPEED"
    echo "  --> disable dynamic fan control"
    echo "  --> set static fan speed at $PERCENTAGE_FAN_SPEED % PWM (hex = $STATICSPEEDBASE16)"
    ipmitool -I lanplus -H $IDRACIP -U $IDRACUSER -P $IDRACPASSWORD raw 0x30 0x30 0x01 0x00
    ipmitool -I lanplus -H $IDRACIP -U $IDRACUSER -P $IDRACPASSWORD raw 0x30 0x30 0x02 0xff $STATICSPEEDBASE16
fi
#
echo "FULL SENSORS READINGS:"
ipmitool -I lanplus -H $IDRACIP -U $IDRACUSER -P $IDRACPASSWORD sensor reading "Fan1" "Fan2" "Inlet Temp" "Temp"
echo "******************************"
echo
