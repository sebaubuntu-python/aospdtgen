#=============================================================================
# Copyright (c) 2023 Qualcomm Technologies, Inc.
# All Rights Reserved.
# Confidential and Proprietary - Qualcomm Technologies, Inc.
#=============================================================================


rev=`cat /sys/devices/soc0/revision`
ddr_type=`od -An -tx /proc/device-tree/memory/ddr_device_type`
ddr_type4="07"
ddr_type5="08"

# Configure RT parameters:
# Long running RT task detection is confined to consolidated builds.
# Set RT throttle runtime to 50ms more than long running RT
# task detection time.
# Set RT throttle period to 100ms more than RT throttle runtime.
long_running_rt_task_ms=1200
sched_rt_runtime_ms=`expr $long_running_rt_task_ms + 50`
sched_rt_runtime_us=`expr $sched_rt_runtime_ms \* 1000`
sched_rt_period_ms=`expr $sched_rt_runtime_ms + 100`
sched_rt_period_us=`expr $sched_rt_period_ms \* 1000`
echo $sched_rt_period_us > /proc/sys/kernel/sched_rt_period_us
echo $sched_rt_runtime_us > /proc/sys/kernel/sched_rt_runtime_us

# Core control parameters for gold
echo 3 > /sys/devices/system/cpu/cpu3/core_ctl/min_cpus
echo 60 > /sys/devices/system/cpu/cpu3/core_ctl/busy_up_thres
echo 30 > /sys/devices/system/cpu/cpu3/core_ctl/busy_down_thres
echo 100 > /sys/devices/system/cpu/cpu3/core_ctl/offline_delay_ms
echo 4 > /sys/devices/system/cpu/cpu3/core_ctl/task_thres
echo 0 0 1 1 > /sys/devices/system/cpu/cpu3/core_ctl/not_preferred

# Core control parameters for gold+
echo 0 > /sys/devices/system/cpu/cpu7/core_ctl/min_cpus
echo 60 > /sys/devices/system/cpu/cpu7/core_ctl/busy_up_thres
echo 30 > /sys/devices/system/cpu/cpu7/core_ctl/busy_down_thres
echo 100 > /sys/devices/system/cpu/cpu7/core_ctl/offline_delay_ms
echo 1 > /sys/devices/system/cpu/cpu7/core_ctl/task_thres

# Controls how many more tasks should be eligible to run on gold CPUs
# w.r.t number of gold CPUs available to trigger assist (max number of
# tasks eligible to run on previous cluster minus number of CPUs in
# the previous cluster).
#
# Setting to 1 by default which means there should be at least
# 5 tasks eligible to run on gold cluster (tasks running on gold cores
# plus misfit tasks on silver cores) to trigger assitance from gold+.
echo 1 > /sys/devices/system/cpu/cpu7/core_ctl/nr_prev_assist_thresh

# Disable Core control on silver
echo 0 > /sys/devices/system/cpu/cpu0/core_ctl/enable

# Setting b.L scheduler parameters
echo 95 95 > /proc/sys/walt/sched_upmigrate
echo 85 85 > /proc/sys/walt/sched_downmigrate
echo 400 > /proc/sys/walt/sched_group_upmigrate
echo 380 > /proc/sys/walt/sched_group_downmigrate
echo 1 > /proc/sys/walt/sched_walt_rotate_big_tasks
echo 400000000 > /proc/sys/walt/sched_coloc_downmigrate_ns
echo 16000000 16000000 16000000 16000000 16000000 16000000 16000000 5000000 > /proc/sys/walt/sched_coloc_busy_hyst_cpu_ns
echo 248 > /proc/sys/walt/sched_coloc_busy_hysteresis_enable_cpus
echo 10 10 10 10 10 10 10 95 > /proc/sys/walt/sched_coloc_busy_hyst_cpu_busy_pct
echo 8500000 8500000 8500000 8500000 8500000 8500000 8500000 2000000 > /proc/sys/walt/sched_util_busy_hyst_cpu_ns
echo 255 > /proc/sys/walt/sched_util_busy_hysteresis_enable_cpus
echo 1 1 1 1 1 1 1 15 > /proc/sys/walt/sched_util_busy_hyst_cpu_util
echo 40 > /proc/sys/walt/sched_cluster_util_thres_pct
echo 30 > /proc/sys/walt/sched_idle_enough
echo 10 > /proc/sys/walt/sched_ed_boost
echo 1000 > /proc/sys/walt/sched_min_task_util_for_colocation

#Set early upmigrate tunables
freq_to_migrate=1228800
silver_fmax=`cat /sys/devices/system/cpu/cpufreq/policy0/scaling_max_freq`
silver_early_upmigrate="$((1024 * $silver_fmax / $freq_to_migrate))"
silver_early_downmigrate="$((((1024 * $silver_fmax) / (((10*$freq_to_migrate) - $silver_fmax) / 10))))"
sched_upmigrate=`cat /proc/sys/walt/sched_upmigrate`
sched_downmigrate=`cat /proc/sys/walt/sched_downmigrate`
sched_upmigrate=${sched_upmigrate:0:2}
sched_downmigrate=${sched_downmigrate:0:2}
gold_early_upmigrate="$((1024 * 100 / $sched_upmigrate))"
gold_early_downmigrate="$((1024 * 100 / $sched_downmigrate))"
echo $silver_early_downmigrate $gold_early_downmigrate > /proc/sys/walt/sched_early_downmigrate
echo $silver_early_upmigrate $gold_early_upmigrate > /proc/sys/walt/sched_early_upmigrate

# set the threshold for low latency task boost feature which prioritize
# binder activity tasks
echo 325 > /proc/sys/walt/walt_low_latency_task_threshold

# cpuset parameters
echo 0-2 > /dev/cpuset/background/cpus
echo 0-2 > /dev/cpuset/system-background/cpus

# Turn off scheduler boost at the end
echo 0 > /proc/sys/walt/sched_boost

# Reset the RT boost, which is 1024 (max) by default.
echo 0 > /proc/sys/kernel/sched_util_clamp_min_rt_default

# Limit kswapd in cpu0-6
echo `ps -elf | grep -v grep | grep kswapd0 | awk '{print $2}'` > /dev/cpuset/kswapd-like/tasks
echo `ps -elf | grep -v grep | grep kcompactd0 | awk '{print $2}'` > /dev/cpuset/kswapd-like/tasks

# configure governor settings for silver cluster
echo "uag" > /sys/devices/system/cpu/cpufreq/policy0/scaling_governor
echo 0 > /sys/devices/system/cpu/cpufreq/policy0/walt/down_rate_limit_us
echo 0 > /sys/devices/system/cpu/cpufreq/policy0/walt/up_rate_limit_us
if [ $rev == "1.0" ] || [ $rev == "1.1" ]; then
	echo 1324800 > /sys/devices/system/cpu/cpufreq/policy0/uag/hispeed_freq
else
	echo 1267200 > /sys/devices/system/cpu/cpufreq/policy0/uag/hispeed_freq
fi
echo 556800 > /sys/devices/system/cpu/cpufreq/policy0/scaling_min_freq
echo 1 > /sys/devices/system/cpu/cpufreq/policy0/walt/pl

# configure input boost settings
if [ $rev == "1.0" ] || [ $rev == "1.1" ]; then
	echo 1382800 0 0 0 0 0 0 0 > /proc/sys/walt/input_boost/input_boost_freq
else
	echo 1228800 0 0 0 0 0 0 0 > /proc/sys/walt/input_boost/input_boost_freq
fi
echo 100 > /proc/sys/walt/input_boost/input_boost_ms

# configure governor settings for gold cluster
echo "uag" > /sys/devices/system/cpu/cpufreq/policy3/scaling_governor
echo 0 > /sys/devices/system/cpu/cpufreq/policy3/walt/down_rate_limit_us
echo 0 > /sys/devices/system/cpu/cpufreq/policy3/walt/up_rate_limit_us
if [ $rev == "1.0" ] || [ $rev == "1.1" ]; then
	echo 1555200 > /sys/devices/system/cpu/cpufreq/policy3/uag/hispeed_freq
else
	echo 1555200 > /sys/devices/system/cpu/cpufreq/policy3/uag/hispeed_freq
fi
echo 537600 > /sys/devices/system/cpu/cpufreq/policy3/scaling_min_freq
echo 1 > /sys/devices/system/cpu/cpufreq/policy3/walt/pl
#target_loads
echo "80 2188800:95" > /sys/devices/system/cpu/cpufreq/policy3/uag/target_loads

# configure governor settings for gold+ cluster
echo "uag" > /sys/devices/system/cpu/cpufreq/policy7/scaling_governor
echo 0 > /sys/devices/system/cpu/cpufreq/policy7/walt/down_rate_limit_us
echo 0 > /sys/devices/system/cpu/cpufreq/policy7/walt/up_rate_limit_us
if [ $rev == "1.0" ] || [ $rev == "1.1" ]; then
	echo 1593600 > /sys/devices/system/cpu/cpufreq/policy7/uag/hispeed_freq
else
	echo 1728000 > /sys/devices/system/cpu/cpufreq/policy7/uag/hispeed_freq
fi
echo 748800 > /sys/devices/system/cpu/cpufreq/policy7/scaling_min_freq
echo 1 > /sys/devices/system/cpu/cpufreq/policy7/walt/pl
#target_loads
echo "80 2342400:95" > /sys/devices/system/cpu/cpufreq/policy7/uag/target_loads

# configure bus-dcvs
bus_dcvs="/sys/devices/system/cpu/bus_dcvs"

for device in $bus_dcvs/*
do
	cat $device/hw_min_freq > $device/boost_freq
done

for llccbw in $bus_dcvs/LLCC/*bwmon-llcc
do
	echo "4577 7110 9155 12298 14236 15258" > $llccbw/mbps_zones
	echo 4 > $llccbw/sample_ms
	echo 80 > $llccbw/io_percent
	echo 20 > $llccbw/hist_memory
	echo 5 > $llccbw/hyst_length
	echo 1 > $llccbw/idle_length
	echo 30 > $llccbw/down_thres
	echo 0 > $llccbw/guard_band_mbps
	echo 250 > $llccbw/up_scale
	echo 1600 > $llccbw/idle_mbps
	echo 806000 > $llccbw/max_freq
	echo 40 > $llccbw/window_ms
done

for ddrbw in $bus_dcvs/DDR/*bwmon-ddr
do
	echo "2086 5931 6515 7980 12191 16259" > $ddrbw/mbps_zones
	echo 4 > $ddrbw/sample_ms
	echo 80 > $ddrbw/io_percent
	echo 20 > $ddrbw/hist_memory
	echo 5 > $ddrbw/hyst_length
	echo 1 > $ddrbw/idle_length
	echo 30 > $ddrbw/down_thres
	echo 0 > $ddrbw/guard_band_mbps
	echo 250 > $ddrbw/up_scale
	echo 1600 > $ddrbw/idle_mbps
	echo 2736000 > $ddrbw/max_freq
	echo 40 > $ddrbw/window_ms
done

for latfloor in $bus_dcvs/*/*latfloor
do
	echo 25000 > $latfloor/ipm_ceil
done

for l3gold in $bus_dcvs/L3/*gold
do
	echo 4000 > $l3gold/ipm_ceil
done

for l3prime in $bus_dcvs/L3/*prime
do
	echo 20000 > $l3prime/ipm_ceil
done

for qosgold in $bus_dcvs/DDRQOS/*gold
do
	echo 50 > $qosgold/ipm_ceil
done

for qosprime in $bus_dcvs/DDRQOS/*prime
do
	echo 100 > $qosprime/ipm_ceil
done

for ddrprime in $bus_dcvs/DDR/*prime
do
	echo 25 > $ddrprime/freq_scale_pct
	echo 1500 > $ddrprime/freq_scale_floor_mhz
	echo 2726 > $ddrprime/freq_scale_ceil_mhz
done

echo s2idle > /sys/power/mem_sleep
echo N > /sys/devices/system/cpu/qcom_lpm/parameters/sleep_disabled

# Let kernel know our image version/variant/crm_version
if [ -f /sys/devices/soc0/select_image ]; then
	image_version="10:"
	image_version+=`getprop ro.build.id`
	image_version+=":"
	image_version+=`getprop ro.build.version.incremental`
	image_variant=`getprop ro.product.name`
	image_variant+="-"
	image_variant+=`getprop ro.build.type`
	oem_version=`getprop ro.build.version.codename`
	echo 10 > /sys/devices/soc0/select_image
	echo $image_version > /sys/devices/soc0/image_version
	echo $image_variant > /sys/devices/soc0/image_variant
	echo $oem_version > /sys/devices/soc0/image_crm_version
fi

echo 4 > /proc/sys/kernel/printk

# Change console log level as per console config property
console_config=`getprop persist.vendor.console.silent.config`
case "$console_config" in
	"1")
		echo "Enable console config to $console_config"
		echo 0 > /proc/sys/kernel/printk
	;;
	*)
		echo "Enable console config to $console_config"
	;;
esac
get_num_logical_cores_in_physical_cluster()
{
	i=0
	logical_cores=(0 0 0 0 0 0)
	if [ -f /sys/devices/system/cpu/cpu0/topology/cluster_id ] ; then
		physical_cluster="cluster_id"
	else
		physical_cluster="physical_package_id"
	fi
	for i in `ls -d /sys/devices/system/cpu/cpufreq/policy[0-9]*`
	do
		if [ -e $i ] ; then
			num_cores=$(cat $i/related_cpus | wc -w)
			first_cpu=$(echo "$i" | sed 's/[^0-9]*//g')
			cluster_id=$(cat /sys/devices/system/cpu/cpu$first_cpu/topology/$physical_cluster)
			logical_cores[cluster_id]=$num_cores
		fi
	done
	cpu_topology=""
	j=0
	physical_cluster_count=$1
	while [[ $j -lt $physical_cluster_count ]]; do
		cpu_topology+=${logical_cores[$j]}
		if [ $j -lt $physical_cluster_count-1 ]; then
			cpu_topology+="_"
		fi
		j=$((j+1))
	done
	echo $cpu_topology
}

#Implementing this mechanism to jump to powersave governor if the script is not running
#as it would be an indication for devs for debug purposes.
fallback_setting()
{
	governor="powersave"
	for i in `ls -d /sys/devices/system/cpu/cpufreq/policy[0-9]*`
	do
		if [ -f $i/scaling_governor ] ; then
			echo $governor > $i/scaling_governor
		fi
	done
}

variant=$(get_num_logical_cores_in_physical_cluster "$1")
echo "CPU topology: ${variant}"
case "$variant" in
	"3_4_1")
	/vendor/bin/sh /vendor/bin/init.kernel.post_boot-kalama_default_3_4_1.sh
	;;
	"3_2_1")
	/vendor/bin/sh /vendor/bin/init.kernel.post_boot-kalama_3_2_1.sh
	;;
	"3_4_0")
	/vendor/bin/sh /vendor/bin/init.kernel.post_boot-kalama_3_4_0.sh
	;;
	*)
	echo "***WARNING***: Postboot script not present for the variant ${variant}"
	fallback_setting
	;;
esac

chown -h system.system /sys/devices/system/cpu/cpufreq/policy0/walt/target_loads
chown -h system.system /sys/devices/system/cpu/cpufreq/policy3/walt/target_loads
chown -h system.system /sys/devices/system/cpu/cpufreq/policy7/walt/target_loads

#oplus_kernel_cpu
# config cpufreq_bouncing parameters for gold cluster
echo "1,1,17,30,2,50,1,50"  > /sys/module/cpufreq_bouncing/parameters/config
# config cpufreq_bouncing parameters for gold+ cluster
echo "2,1,15,30,2,50,1,50"  > /sys/module/cpufreq_bouncing/parameters/config
#config power effiecny tunning parameters
echo 1 > /sys/module/cpufreq_effiency/parameters/affect_mode
echo "307200,45000,1344000,52000,0"  > /sys/module/cpufreq_effiency/parameters/cluster0_effiency
echo "499200,50000,2054400,55000,0"  > /sys/module/cpufreq_effiency/parameters/cluster1_effiency
echo "595200,55000,1977600,60000,0"  > /sys/module/cpufreq_effiency/parameters/cluster2_effiency

#config fg and top cpu shares
echo 5120 > /dev/cpuctl/top-app/cpu.shares
echo 4096 > /dev/cpuctl/foreground/cpu.shares

setprop vendor.post_boot.parsed 1
