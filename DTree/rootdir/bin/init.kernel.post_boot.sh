#=============================================================================
# Copyright (c) 2019-2022 Qualcomm Technologies, Inc.
# All Rights Reserved.
# Confidential and Proprietary - Qualcomm Technologies, Inc.
#
# Copyright (c) 2009-2012, 2014-2019, The Linux Foundation. All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#     * Redistributions of source code must retain the above copyright
#       notice, this list of conditions and the following disclaimer.
#     * Redistributions in binary form must reproduce the above copyright
#       notice, this list of conditions and the following disclaimer in the
#       documentation and/or other materials provided with the distribution.
#     * Neither the name of The Linux Foundation nor
#       the names of its contributors may be used to endorse or promote
#       products derived from this software without specific prior written
#       permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NON-INFRINGEMENT ARE DISCLAIMED.  IN NO EVENT SHALL THE COPYRIGHT OWNER OR
# CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
# EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
# PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;
# OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
# WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR
# OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
# ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#=============================================================================

function configure_zram_parameters() {
	MemTotalStr=`cat /proc/meminfo | grep MemTotal`
	MemTotal=${MemTotalStr:16:8}

	low_ram=`getprop ro.config.low_ram`

	# Zram disk - 75% for Go and < 2GB devices .
	# For >2GB Non-Go devices, size = 50% of RAM size. Limit the size to 4GB.
	# And enable lz4 zram compression for Go targets.

	let RamSizeGB="( $MemTotal / 1048576 ) + 1"
	diskSizeUnit=M
	if [ $RamSizeGB -le 2 ]; then
		let zRamSizeMB="( $RamSizeGB * 1024 ) * 3 / 4"
	else
		let zRamSizeMB="( $RamSizeGB * 1024 ) / 2"
	fi

	# use MB avoid 32 bit overflow
	if [ $zRamSizeMB -gt 4096 ]; then
		let zRamSizeMB=4096
	fi

	if [ "$low_ram" == "true" ]; then
		echo lz4 > /sys/block/zram0/comp_algorithm
	fi

	if [ -f /sys/block/zram0/disksize ]; then
		if [ -f /sys/block/zram0/use_dedup ]; then
			echo 1 > /sys/block/zram0/use_dedup
		fi
		echo "$zRamSizeMB""$diskSizeUnit" > /sys/block/zram0/disksize

		# ZRAM may use more memory than it saves if SLAB_STORE_USER
		# debug option is enabled.
		if [ -e /sys/kernel/slab/zs_handle ]; then
			echo 0 > /sys/kernel/slab/zs_handle/store_user
		fi
		if [ -e /sys/kernel/slab/zspage ]; then
			echo 0 > /sys/kernel/slab/zspage/store_user
		fi

		mkswap /dev/block/zram0
		swapon /dev/block/zram0 -p 32758
	fi
}

#ifdef OPLUS_FEATURE_ZRAM_OPT
function oplus_configure_zram_parameters() {
    MemTotalStr=`cat /proc/meminfo | grep MemTotal`
    MemTotal=${MemTotalStr:16:8}

    echo lz4 > /sys/block/zram0/comp_algorithm
    echo 160 > /sys/module/zram_opt/parameters/vm_swappiness
    echo 60 > /sys/module/zram_opt/parameters/direct_vm_swappiness
    echo 0 > /proc/sys/vm/page-cluster

    if [ -f /sys/block/zram0/disksize ]; then
        if [ -f /sys/block/zram0/use_dedup ]; then
            echo 1 > /sys/block/zram0/use_dedup
        fi

        if [ $MemTotal -le 524288 ]; then
            #config 384MB zramsize with ramsize 512MB
            echo 402653184 > /sys/block/zram0/disksize
        elif [ $MemTotal -le 1048576 ]; then
            #config 768MB zramsize with ramsize 1GB
            echo 805306368 > /sys/block/zram0/disksize
        elif [ $MemTotal -le 2097152 ]; then
            #config 1GB+256MB zramsize with ramsize 2GB
            echo lz4 > /sys/block/zram0/comp_algorithm
            echo 1342177280 > /sys/block/zram0/disksize
        elif [ $MemTotal -le 3145728 ]; then
            #config 1GB+512MB zramsize with ramsize 3GB
            echo 1610612736 > /sys/block/zram0/disksize
        elif [ $MemTotal -le 4194304 ]; then
            #config 2GB+512MB zramsize with ramsize 4GB
            echo 2684354560 > /sys/block/zram0/disksize
        elif [ $MemTotal -le 6291456 ]; then
            #config 3GB zramsize with ramsize 6GB
            echo 3221225472 > /sys/block/zram0/disksize
        else
            #config 4GB zramsize with ramsize >=8GB
            echo 4294967296 > /sys/block/zram0/disksize
        fi
        mkswap /dev/block/zram0
        swapon /dev/block/zram0 -p 32758
    fi
}

function oplus_configure_hybridswap() {
	kernel_version=`uname -r`

	if [[ "$kernel_version" == "5.1"* ]]; then
		echo 160 > /sys/module/oplus_bsp_zram_opt/parameters/vm_swappiness
	else
		echo 160 > /sys/module/zram_opt/parameters/vm_swappiness
	fi

	echo 0 > /proc/sys/vm/page-cluster

	# FIXME: set system memcg pata in init.kernel.post_boot-lahaina.sh temporary
	echo 500 > /dev/memcg/system/memory.app_score
	echo systemserver > /dev/memcg/system/memory.name
}

#/*Add swappiness tunning parameters*/
function oplus_configure_tuning_swappiness() {
	local MemTotalStr=`cat /proc/meminfo | grep MemTotal`
	local MemTotal=${MemTotalStr:16:8}
	local para_path=/proc/sys/vm
	local kernel_version=`uname -r`
	local prjname=`getprop ro.boot.prjname`

	chp_support=0
	if [ -f "/proc/cont_pte_hugepage/stat" ]; then
		chp_support=1
	fi

	if [[ "$kernel_version" == "5.1"* ]]; then
		para_path=/sys/module/oplus_bsp_zram_opt/parameters
	fi

	if [ $MemTotal -le 6291456 ]; then
		echo 0 > $para_path/vm_swappiness_threshold1
		echo 0 > $para_path/swappiness_threshold1_size
		echo 0 > $para_path/vm_swappiness_threshold2
		echo 0 > $para_path/swappiness_threshold2_size
	elif [ $MemTotal -le 8388608 ]; then
		echo 70  > $para_path/vm_swappiness_threshold1
		echo 2000 > $para_path/swappiness_threshold1_size
		echo 90  > $para_path/vm_swappiness_threshold2
		echo 1500 > $para_path/swappiness_threshold2_size
	else
		if [ $chp_support -eq 1 ] ; then
			echo 60  > $para_path/vm_swappiness_threshold1
			echo 80  > $para_path/vm_swappiness_threshold2
		else
			echo 70  > $para_path/vm_swappiness_threshold1
			echo 90  > $para_path/vm_swappiness_threshold2
		fi
		echo 4096 > $para_path/swappiness_threshold1_size
		echo 2048 > $para_path/swappiness_threshold2_size
	fi
	#xueying zram
	if [ -n "$prjname" ]; then
		case $prjname in
			"22003"|"22203"|"22899")
				echo 50 > $para_path/vm_swappiness_threshold1
				echo 4096 > $para_path/swappiness_threshold1_size
				echo 70 > $para_path/vm_swappiness_threshold2
				echo 2048 > $para_path/swappiness_threshold2_size
				;;
			*)
				;;
		esac
	fi
}
#endif /*OPLUS_FEATURE_ZRAM_OPT*/

function configure_read_ahead_kb_values() {
	MemTotalStr=`cat /proc/meminfo | grep MemTotal`
	MemTotal=${MemTotalStr:16:8}

	dmpts=$(ls /sys/block/*/queue/read_ahead_kb | grep -e dm -e mmc -e sd)
	# dmpts holds below read_ahead_kb nodes if exists:
	# /sys/block/dm-0/queue/read_ahead_kb to /sys/block/dm-10/queue/read_ahead_kb
	# /sys/block/sda/queue/read_ahead_kb to /sys/block/sdh/queue/read_ahead_kb

	# Set 128 for <= 4GB &
	# set 512 for >= 5GB targets.
	if [ $MemTotal -le 4194304 ]; then
		ra_kb=128
	else
		ra_kb=512
	fi
	if [ -f /sys/block/mmcblk0/bdi/read_ahead_kb ]; then
		echo $ra_kb > /sys/block/mmcblk0/bdi/read_ahead_kb
	fi
	if [ -f /sys/block/mmcblk0rpmb/bdi/read_ahead_kb ]; then
		echo $ra_kb > /sys/block/mmcblk0rpmb/bdi/read_ahead_kb
	fi
	for dm in $dmpts; do
		dm_dev=`echo $dm |cut -d/ -f4`
		if [ "$dm_dev" = "" ]; then
			is_erofs=""
		else
			is_erofs=`mount |grep erofs |grep "${dm_dev} "`
		fi
		if [ "$is_erofs" = "" ]; then
			if [ `cat $(dirname $dm)/../removable` -eq 0 ]; then
				echo $ra_kb > $dm
			fi
		else
			echo 128 > $dm
		fi
	done
}

function configure_memory_parameters() {
	# Set Memory parameters.
	#
	# Set per_process_reclaim tuning parameters
	# All targets will use vmpressure range 50-70,
	# All targets will use 512 pages swap size.
	#
	# Set Low memory killer minfree parameters
	# 32 bit Non-Go, all memory configurations will use 15K series
	# 32 bit Go, all memory configurations will use uLMK + Memcg
	# 64 bit will use Google default LMK series.
	#
	# Set ALMK parameters (usually above the highest minfree values)
	# vmpressure_file_min threshold is always set slightly higher
	# than LMK minfree's last bin value for all targets. It is calculated as
	# vmpressure_file_min = (last bin - second last bin ) + last bin
	#
	# Set allocstall_threshold to 0 for all targets.
	#

#ifdef OPLUS_FEATURE_ZRAM_OPT
	# For vts test which has replace system.img
	if [ -L "/product" ]; then
		oplus_configure_zram_parameters
	else
		if [ -f /sys/block/zram0/hybridswap_enable ]; then
			oplus_configure_hybridswap
		else
			oplus_configure_zram_parameters
		fi
	fi
	oplus_configure_tuning_swappiness
#else
	# configure_zram_parameters
#endif /*OPLUS_FEATURE_ZRAM_OPT*/
	configure_read_ahead_kb_values
	echo 100 > /proc/sys/vm/swappiness

	# Disable periodic kcompactd wakeups. We do not use THP, so having many
	# huge pages is not as necessary.
	echo 0 > /proc/sys/vm/compaction_proactiveness

	# With THP enabled, the kernel greatly increases min_free_kbytes over its
	# default value. Disable THP to prevent resetting of min_free_kbytes
	# value during online/offline pages.
	if [ -f /sys/kernel/mm/transparent_hugepage/enabled ]; then
		echo never > /sys/kernel/mm/transparent_hugepage/enabled
	fi

	MemTotalStr=`cat /proc/meminfo | grep MemTotal`
	MemTotal=${MemTotalStr:16:8}
	let RamSizeGB="( $MemTotal / 1048576 ) + 1"

	# Set the min_free_kbytes to standard kernel value
	if [ $RamSizeGB -ge 8 ]; then
		echo 11584 > /proc/sys/vm/min_free_kbytes
	elif [ $RamSizeGB -ge 4 ]; then
		echo 8192 > /proc/sys/vm/min_free_kbytes
	elif [ $RamSizeGB -ge 2 ]; then
		echo 5792 > /proc/sys/vm/min_free_kbytes
	else
		echo 4096 > /proc/sys/vm/min_free_kbytes
	fi

	# configure boost pool
	if [ $RamSizeGB -ge 10 ]; then
		echo 128000 > /proc/boost_pool/camera_pages
	fi
}

configure_memory_parameters

if [ -f /sys/devices/soc0/soc_id ]; then
	platformid=`cat /sys/devices/soc0/soc_id`
fi

case "$platformid" in
	"519"|"536"|"600"|"601"|"603"|"604")
		#Pass as an argument the max number of clusters supported on the SOC
		/vendor/bin/sh /vendor/bin/init.kernel.post_boot-kalama.sh 3
		;;
	*)
		echo "***WARNING***: Invalid SoC ID\n\t No postboot settings applied!!\n"
		source init.kernel.post_boot-kalama.sh fallback_setting
		;;
esac
