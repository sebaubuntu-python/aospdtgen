#!/vendor/bin/sh
#=============================================================================
# Copyright (c) 2021 Qualcomm Technologies, Inc.
# All Rights Reserved.
# Confidential and Proprietary - Qualcomm Technologies, Inc.
#=============================================================================

write_with_check() {
	local i=60
	while [ $i -gt 0 ]
	do
		if [ -f "$1" ]; then
			break
		fi

		sleep 1
		i=$(($i-1))
	done

	if [ ! -f "$1" ]; then
		exit 1
	fi

	echo $2 > $1
}

write_with_check "$1" "$2"
