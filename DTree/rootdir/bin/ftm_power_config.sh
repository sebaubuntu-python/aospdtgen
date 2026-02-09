#!/system/bin/sh
FTM_TARGET_PATH="/mnt/vendor/oplusreserve/ftm_admin"
mkdir -p $FTM_TARGET_PATH

echo "ftm_power_config start" >> /dev/kmsg
/vendor/bin/sh /vendor/bin/init.qcom.post_boot.sh
echo s2idle > /sys/power/mem_sleep
sleep 2
echo 0 > /sys/devices/system/cpu/cpu4/online
echo 0 > /sys/devices/system/cpu/cpu5/online
echo 0 > /sys/devices/system/cpu/cpu6/online
echo 0 > /sys/devices/system/cpu/cpu7/online
echo 0 > /sys/devices/system/cpu/cpu3/online
echo 0 > /sys/devices/system/cpu/cpu2/online
echo 518400 > /sys/devices/system/cpu/cpufreq/policy0/scaling_min_freq
echo 883200 > /sys/devices/system/cpu/cpufreq/policy0/scaling_max_freq

echo "ftm_power_config ftrace config start" >> /dev/kmsg
echo 0 > /sys/kernel/tracing/tracing_on
echo "" > /sys/kernel/tracing/set_event
echo "" > /sys/kernel/tracing/trace
echo power:cpu_idle power:cpu_frequency power:cpu_frequency_switch_start msm_low_power:* sched:sched_switch sched:sched_wakeup sched:sched_wakeup_new  sched:sched_enq_deq_task >> /sys/kernel/tracing/set_event
echo power:memlat_dev_update power:memlat_dev_meas msm_bus:bus_update_request msm_bus:* power:bw_hwmon_update power:bw_hwmon_meas >> /sys/kernel/tracing/set_event
echo power:bw_hwmon_meas power:bw_hwmon_update>> /sys/kernel/tracing/set_event
echo clk:clk_set_rate clk:clk_enable clk:clk_disable >> /sys/kernel/tracing/set_event
echo power:clock_set_rate power:clock_enable power:clock_disable msm_bus:bus_update_request >> /sys/kernel/tracing/set_event
echo cpufreq_interactive:cpufreq_interactive_target cpufreq_interactive:cpufreq_interactive_setspeed >> /sys/kernel/tracing/set_event
echo irq:* >> /sys/kernel/tracing/set_event
echo mdss:mdp_mixer_update mdss:mdp_sspp_change mdss:mdp_commit >> /sys/kernel/tracing/set_event
echo workqueue:* >> /sys/kernel/tracing/set_event
echo kgsl:kgsl_pwrlevel kgsl:kgsl_buslevel kgsl:kgsl_pwr_set_state >> /sys/kernel/tracing/set_event
echo regulator:regulator_set_voltage_complete regulator:regulator_disable_complete regulator:regulator_enable_complete >> /sys/kernel/tracing/set_event
echo thermal:* >> /sys/kernel/tracing/set_event
cat /sys/kernel/tracing/set_event
echo 40000 > /sys/kernel/tracing/buffer_size_kb
cat /sys/kernel/tracing/buffer_size_kb

sleep 2
echo "ftm_power_config capture ftrace start" >> /dev/kmsg
echo 0 > /sys/kernel/tracing/tracing_on && echo "" > /sys/kernel/tracing/trace && sleep 1 && echo 1 > /sys/kernel/tracing/tracing_on && sleep 50 && echo 0 > /sys/kernel/tracing/tracing_on && cat /sys/kernel/tracing/trace > $FTM_TARGET_PATH/trace.txt&

rev=`cat /sys/devices/soc0/revision`
if [ $rev == "1.0" ]; then

	echo 0  >  /sys/devices/system/cpu/cpu0/cpuidle/state1/disable
	echo 0  >  /sys/devices/system/cpu/cpu1/cpuidle/state1/disable
	echo 0  >  /sys/devices/system/cpu/cpu2/cpuidle/state1/disable
	echo 0  >  /sys/devices/system/cpu/cpu3/cpuidle/state1/disable
	echo 0  >  /sys/devices/system/cpu/cpu4/cpuidle/state1/disable
	echo 0  >  /sys/devices/system/cpu/cpu5/cpuidle/state1/disable
	echo 0  >  /sys/devices/system/cpu/cpu6/cpuidle/state1/disable
	echo 0  >  /sys/devices/system/cpu/cpu7/cpuidle/state1/disable
	echo "post_boot_wakelock" > /sys/power/wake_unlock

fi

echo 0 > /sys/devices/system/cpu/qcom_lpm/parameters/sleep_disabled
baseband=`getprop ro.baseband`
echo "ftm_power_config done baseband=$baseband" >> /dev/kmsg
