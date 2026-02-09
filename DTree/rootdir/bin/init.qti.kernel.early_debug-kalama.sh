#=============================================================================
# Copyright (c) 2022 Qualcomm Technologies, Inc.
# All Rights Reserved.
# Confidential and Proprietary - Qualcomm Technologies, Inc.
#
# Copyright (c) 2014-2017, The Linux Foundation. All rights reserved.
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

enable_sched_events()
{
    local instance=/sys/kernel/tracing

    echo > $instance/trace
    echo > $instance/set_event

    # timer
    echo 1 > $instance/events/timer/timer_expire_entry/enable
    echo 1 > $instance/events/timer/timer_expire_exit/enable
    echo 1 > $instance/events/timer/hrtimer_cancel/enable
    echo 1 > $instance/events/timer/hrtimer_expire_entry/enable
    echo 1 > $instance/events/timer/hrtimer_expire_exit/enable
    echo 1 > $instance/events/timer/hrtimer_init/enable
    echo 1 > $instance/events/timer/hrtimer_start/enable
    #enble FTRACE for softirq events
    echo 1 > $instance/events/irq/enable
    #enble FTRACE for Workqueue events
    echo 1 > $instance/events/workqueue/enable
    # sched
    echo 1 > $instance/events/sched/sched_cpu_hotplug/enable
    echo 1 > $instance/events/sched/sched_migrate_task/enable
    echo 1 > $instance/events/sched/sched_pi_setprio/enable
    echo 1 > $instance/events/sched/sched_switch/enable
    echo 1 > $instance/events/sched/sched_wakeup/enable
    echo 1 > $instance/events/sched/sched_wakeup_new/enable
    echo 1 > $instance/events/schedwalt/halt_cpus/enable
    echo 1 > $instance/events/schedwalt/halt_cpus_start/enable
    # hot-plug
    echo 1 > $instance/events/cpuhp/enable

    echo 1 > $instance/events/power/cpu_frequency/enable

    echo 1 > $instance/tracing_on
}

enable_rproc_events()
{
    local instance=/sys/kernel/tracing/instances/rproc_qcom

    mkdir $instance
    echo > $instance/trace
    echo > $instance/set_event

    # enable rproc events as soon as available
    /vendor/bin/init.qti.write.sh $instance/events/rproc_qcom/enable 1

    echo 1 > $instance/tracing_on
}

# Suspend events are also noisy when going into suspend/resume
enable_suspend_events()
{
    local instance=/sys/kernel/tracing/instances/suspend

    mkdir $instance
    echo > $instance/trace
    echo > $instance/set_event

    echo 1 > $instance/events/power/suspend_resume/enable
    echo 1 > $instance/events/power/device_pm_callback_start/enable
    echo 1 > $instance/events/power/device_pm_callback_end/enable

    echo 1 > $instance/tracing_on
}

enable_clock_reg_events()
{
    local instance=/sys/kernel/tracing/instances/clock_reg

    mkdir $instance
    echo > $instance/trace
    echo > $instance/set_event

    # clock
    echo 1 > $instance/events/clk/enable
    echo 1 > $instance/events/clk_qcom/enable

    # interconnect
    echo 1 > $instance/events/interconnect/enable

    # regulator
    echo 1 > $instance/events/regulator/enable

    #thermal
    echo 1 > /sys/kernel/tracing/events/thermal/thermal_pre_core_offline/enable
    echo 1 > /sys/kernel/tracing/events/thermal/thermal_post_core_offline/enable
    echo 1 > /sys/kernel/tracing/events/thermal/thermal_pre_core_online/enable
    echo 1 > /sys/kernel/tracing/events/thermal/thermal_post_core_online/enable
    echo 1 > /sys/kernel/tracing/events/thermal/thermal_pre_frequency_mit/enable
    echo 1 > /sys/kernel/tracing/events/thermal/thermal_post_frequency_mit/enable

    # rpmh
    echo 1 > $instance/events/rpmh/enable

    echo 1 > $instance/tracing_on
}

enable_memory_events()
{
    local instance=/sys/kernel/tracing/instances/memory

    mkdir $instance
    echo > $instance/trace
    echo > $instance/set_event

    #memory pressure events/oom
    echo 1 > $instance/events/psi/psi_event/enable
    echo 1 > $instance/events/psi/psi_window_vmstat/enable
    echo 1 > $instance/events/arm_smmu/enable

    echo 1 > $instance/tracing_on
}

# binder tracing can be noisy
enable_binder_events()
{
    local instance=/sys/kernel/tracing/instances/binder

    mkdir $instance
    echo > $instance/trace
    echo > $instance/set_event

    echo 1 > $instance/events/binder/enable

    echo 1 > $instance/tracing_on
}

enable_tracing_events()
{
    # bail out if its perf config
    if [ ! -d /sys/module/msm_rtb ] ; then
        return
    fi

    # bail out if ftrace events aren't present
    if [ ! -d /sys/kernel/tracing/events ] ; then
        return
    fi

    enable_sched_events
    enable_rproc_events
    enable_suspend_events
    enable_binder_events
    enable_clock_reg_events
    enable_memory_events
}

enable_tracing_events
