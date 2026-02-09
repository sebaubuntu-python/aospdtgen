#=============================================================================
# Copyright (c) 2020-2023 Qualcomm Technologies, Inc.
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

#Please ensure that the tunables are set as per the product variant

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

# Disable Core control on silver
echo 0 > /sys/devices/system/cpu/cpu0/core_ctl/enable

# Disable Core control on gold
echo 0 > /sys/devices/system/cpu/cpu3/core_ctl/enable

# Setting b.L scheduler parameters
echo 95 95 > /proc/sys/walt/sched_upmigrate
echo 85 85 > /proc/sys/walt/sched_downmigrate
echo 100 > /proc/sys/walt/sched_group_upmigrate
echo 85 > /proc/sys/walt/sched_group_downmigrate
echo 1 > /proc/sys/walt/sched_walt_rotate_big_tasks
echo 400000000 > /proc/sys/walt/sched_coloc_downmigrate_ns
echo 16000000 16000000 16000000 16000000 16000000 16000000 16000000 > /proc/sys/walt/sched_coloc_busy_hyst_cpu_ns
echo 248 > /proc/sys/walt/sched_coloc_busy_hysteresis_enable_cpus
echo 10 10 10 10 10 10 10 95 > /proc/sys/walt/sched_coloc_busy_hyst_cpu_busy_pct
echo 8500000 8500000 8500000 8500000 8500000 8500000 8500000 > /proc/sys/walt/sched_util_busy_hyst_cpu_ns
echo 255 > /proc/sys/walt/sched_util_busy_hysteresis_enable_cpus
echo 1 1 1 1 1 1 1 > /proc/sys/walt/sched_util_busy_hyst_cpu_util
echo 40 > /proc/sys/walt/sched_cluster_util_thres_pct
echo 30 > /proc/sys/walt/sched_idle_enough
echo 10 > /proc/sys/walt/sched_ed_boost

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

# configure governor settings for silver cluster
echo "walt" > /sys/devices/system/cpu/cpufreq/policy0/scaling_governor
echo 0 > /sys/devices/system/cpu/cpufreq/policy0/walt/down_rate_limit_us
echo 0 > /sys/devices/system/cpu/cpufreq/policy0/walt/up_rate_limit_us
if [ $rev == "1.0" ] || [ $rev == "1.1" ]; then
	echo 1324800 > /sys/devices/system/cpu/cpufreq/policy0/walt/hispeed_freq
elif [ $rev == "2.0" ]; then
	echo 1344000 > /sys/devices/system/cpu/cpufreq/policy0/walt/hispeed_freq
else
	echo 1267200 > /sys/devices/system/cpu/cpufreq/policy0/walt/hispeed_freq
fi
echo 556800 > /sys/devices/system/cpu/cpufreq/policy0/scaling_min_freq
echo 1 > /sys/devices/system/cpu/cpufreq/policy0/walt/pl

# configure input boost settings
if [ $rev == "1.0" ] || [ $rev == "1.1" ]; then
	echo 1382800 0 0 0 0 0 0 > /proc/sys/walt/input_boost/input_boost_freq
else
	echo 1228800 0 0 0 0 0 0 > /proc/sys/walt/input_boost/input_boost_freq
fi
echo 100 > /proc/sys/walt/input_boost/input_boost_ms

# configure governor settings for gold cluster
echo "walt" > /sys/devices/system/cpu/cpufreq/policy3/scaling_governor
echo 0 > /sys/devices/system/cpu/cpufreq/policy3/walt/down_rate_limit_us
echo 0 > /sys/devices/system/cpu/cpufreq/policy3/walt/up_rate_limit_us
if [ $rev == "1.0" ] || [ $rev == "1.1" ]; then
	echo 1555200 > /sys/devices/system/cpu/cpufreq/policy3/walt/hispeed_freq
elif [ $rev == "2.0" ]; then
	echo 1536000 > /sys/devices/system/cpu/cpufreq/policy3/walt/hispeed_freq
else
	echo 1555200 > /sys/devices/system/cpu/cpufreq/policy3/walt/hispeed_freq
fi
echo 537600 > /sys/devices/system/cpu/cpufreq/policy3/scaling_min_freq
echo 1 > /sys/devices/system/cpu/cpufreq/policy3/walt/pl

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

setprop vendor.post_boot.parsed 1
