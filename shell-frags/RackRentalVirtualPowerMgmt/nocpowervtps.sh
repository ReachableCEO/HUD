#!/bin/bash

###############################################################################
#function declarations
###############################################################################

usage()
#Usage message
{

	echo "$0 needs to be invoked with two required argument: 
----------------------------------------------------------------------------
            --jig ottov<xx>
            --action (One of: on,off,cycle)
----------------------------------------------------------------------------"

exit 0
}

error_out() 
#Error reporting code
{
echo "A critical error has occured. Please see above line for portion that failed."
echo "This script will now exit..."
exit 1
}

bail_out()
#Exit code
{
echo "Exiting...."
exit 0
}



###############################################################################
#Start execution
###############################################################################

if [[ $# -eq 0 ]]; then
usage
fi

if [ "$1" = "-help" ]; then
usage
fi

COUNTER=0
ARGS=("$@")
while [ $COUNTER -lt $# ]
do
    arg=${ARGS[$COUNTER]}
    let COUNTER=COUNTER+1
    nextArg=${ARGS[$COUNTER]}
            argKey="$arg"
            argVal="$nextArg"
            skipNext=1

	case "$argKey" in
		--jig)
			export USER_SUPPLIED_VMNAME="$argVal"
		;;
		--action)
			export USER_SUPPLIED_ACTION="$argVal"
		;;
		-h|--help|-help|--h)
            usage
            exit
		
	esac
done

#Check for proper inputs

#Check for vmName
echo "Checking if DUT name was provided..."
if [ -z "$USER_SUPPLIED_VMNAME" ]; then
error_out
else
	echo "Using DUT $USER_SUPPLIED_VMNAME"
fi

#Check for action
echo "Checking if action was provided..."
if [ -z $USER_SUPPLIED_ACTION ]; then
error_out
else
	echo "Performing action $USER_SUPPLIED_ACTION"
fi

echo "All preflight checks passsed. Proceeding with power operation."


export LMOUT="$(labman device $USER_SUPPLIED_VMNAME)"
export VCENTER_FQDN="$(echo "$LMOUT" | grep -w 'VM Management Server' |awk -F ':' '{print $2}'|sed 's/ //g')"
export VMHOSTFULL="$(echo "$LMOUT" | grep -w 'VM Host' |awk -F ':' '{print $2}'|sed 's/ //g')"



if [ $(echo $VMHOSTFULL | grep esxi -c) -eq 1 ]; then

	if [ "$USER_SUPPLIED_ACTION" = on ] ; then
		echo "Powering $USER_SUPPLIED_VMNAME in $VCENTER_FQDN on..."
		powershell /local/powervtps/nocpowervtps/esxi-PowerOn.ps1 $VCENTER_FQDN $USER_SUPPLIED_VMNAME
	fi

	if [ "$USER_SUPPLIED_ACTION" = off ] ; then
		echo "Powering $USER_SUPPLIED_VMNAME in $VCENTER_FQDN off..."
		powershell /local/powervtps/nocpowervtps/esxi-PowerOff.ps1 $VCENTER_FQDN $USER_SUPPLIED_VMNAME
	fi

	if [ "$USER_SUPPLIED_ACTION" = cycle ] ; then
		echo "Cycling $USER_SUPPLIED_VMNAME in $VCENTER_FQDN..."
		powershell /local/powervtps/nocpowervtps/esxi-PowerCycle.ps1 $VCENTER_FQDN $USER_SUPPLIED_VMNAME
	fi

fi

if [ $(echo $VMHOSTFULL | grep kvm -c) -eq 1 ]; then

	if [ "$USER_SUPPLIED_ACTION" = on ] ; then
		echo "Powering $USER_SUPPLIED_VMNAME on $VMHOSTFULL on..."
		bash /local/powervtps/nocpowervtps/kvm-PowerOn.sh $VMHOSTFULL $USER_SUPPLIED_VMNAME
	fi

	if [ "$USER_SUPPLIED_ACTION" = off ] ; then
		echo "Powering $USER_SUPPLIED_VMNAME on $VMHOSTFULL off..."
		bash /local/powervtps/nocpowervtps/kvm-PowerOff.sh $VMHOSTFULL $USER_SUPPLIED_VMNAME
	fi

	if [ "$USER_SUPPLIED_ACTION" = cycle ] ; then
		echo "Cycling $USER_SUPPLIED_VMNAME on $VMHOSTFULL..."
		bash /local/powervtps/nocpowervtps/kvm-PowerCycle.sh $VMHOSTFULL $USER_SUPPLIED_VMNAME
	fi
fi