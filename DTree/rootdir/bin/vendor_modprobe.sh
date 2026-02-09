#! /vendor/bin/sh
#=============================================================================
# Copyright (c) 2019-2022 Qualcomm Technologies, Inc.
# All Rights Reserved.
# Confidential and Proprietary - Qualcomm Technologies, Inc.
#=============================================================================

VENDOR_DIR="/vendor/lib/modules"
VENDOR_DLKM_DIR="/vendor_dlkm/lib/modules"

MODPROBE="/vendor/bin/modprobe"

# vendor modules partition could be /vendor/lib/modules or /vendor_dlkm/lib/modules
POSSIBLE_DIRS="${VENDOR_DLKM_DIR} ${VENDOR_DIR}"
audio_arch=`getprop ro.boot.audio`

for dir in ${POSSIBLE_DIRS} ;
do
	if [ ! -e ${dir}/modules.load ]; then
		continue
	fi

	if [ "$audio_arch" == "audioreach" ]; then
		if [ -e ${dir}/modules.audio.ar.blocklist ]; then
			audio_blocklist_expr="$(sed -n -e 's/blocklist \(.*\)/\1/p' ${dir}/modules.audio.ar.blocklist | sed -e 's/-/_/g' -e 's/^/-e /')"
		else
			audio_blocklist_expr="-e %"
		fi
	elif [ "$audio_arch" == "audioreach_vio" ]; then
		if [ -e ${dir}/modules.audio.ar_vio.blocklist ]; then
			audio_blocklist_expr="$(sed -n -e 's/blocklist \(.*\)/\1/p' ${dir}/modules.audio.ar_vio.blocklist | sed -e 's/-/_/g' -e 's/^/-e /')"
		else
			audio_blocklist_expr="-e %"
		fi
	else
		if [ -e ${dir}/modules.audio.legacy.blocklist ]; then
			audio_blocklist_expr="$(sed -n -e 's/blocklist \(.*\)/\1/p' ${dir}/modules.audio.legacy.blocklist | sed -e 's/-/_/g' -e 's/^/-e /')"
		else
			audio_blocklist_expr="-e %"
		fi
	fi

	if [ -e ${dir}/modules.blocklist ]; then
		blocklist_expr="$(sed -n -e 's/blocklist \(.*\)/\1/p' ${dir}/modules.blocklist | sed -e 's/-/_/g' -e 's/^/-e /')"
	else
		# Use pattern that won't be found in modules list so that all modules pass through grep below
		blocklist_expr="-e %"
	fi
	# Filter out modules in blocklist - we would see unnecessary errors otherwise
	load_modules=$(sed = ${dir}/modules.load | sed 'N;s/\n/\t/' | sort -uk2 | sort -nk1 | cut -f2- | grep -w -v ${blocklist_expr} | grep -w -v ${audio_blocklist_expr})
	first_module=$(echo ${load_modules} | cut -d " " -f1)
	other_modules=$(echo ${load_modules} | cut -d " " -f2-)
	if ! ${MODPROBE} -b -s -d ${dir} -a ${first_module} > /dev/null ; then
		continue
	fi
	# load modules individually in case one of them fails to init
	for module in ${other_modules}; do
		( ${MODPROBE} -b -d ${dir} -a ${module} > /dev/null ) &
	done

	wait

	setprop vendor.all.modules.ready 1
	exit 0
done

exit 1
