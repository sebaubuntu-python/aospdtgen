#=============================================================================
# Copyright (c) 2020-2023 Qualcomm Technologies, Inc.
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

enable_tracing_events()
{
    #enlarge ftrace size
    echo 30720 > /sys/kernel/tracing/buffer_size_kb
    #disable track_prink
    echo 0 > /sys/kernel/tracing/options/trace_printk
    # timer
    echo 1 > /sys/kernel/tracing/events/timer/timer_expire_entry/enable
    echo 1 > /sys/kernel/tracing/events/timer/timer_expire_exit/enable
    echo 1 > /sys/kernel/tracing/events/timer/hrtimer_cancel/enable
    echo 1 > /sys/kernel/tracing/events/timer/hrtimer_expire_entry/enable
    echo 1 > /sys/kernel/tracing/events/timer/hrtimer_expire_exit/enable
    echo 1 > /sys/kernel/tracing/events/timer/hrtimer_init/enable
    echo 1 > /sys/kernel/tracing/events/timer/hrtimer_start/enable
    #enble FTRACE for softirq events
    echo 1 > /sys/kernel/tracing/events/irq/enable
    echo 1 > /sys/kernel/tracing/events/irq/softirq_entry/enable
    echo 1 > /sys/kernel/tracing/events/irq/softirq_exit/enable
    echo 1 > /sys/kernel/tracing/events/irq/softirq_raise/enable
    #enble FTRACE for Workqueue events
    echo 1 > /sys/kernel/tracing/events/workqueue/enable
    echo 1 > /sys/kernel/tracing/events/workqueue/workqueue_execute_start/enable
    # schedular
    #echo 1 > /sys/kernel/tracing/events/sched/sched_cpu_hotplug/enable
    echo 1 > /sys/kernel/tracing/events/sched/sched_migrate_task/enable
    echo 1 > /sys/kernel/tracing/events/sched/sched_pi_setprio/enable
    echo 1 > /sys/kernel/tracing/events/sched/sched_switch/enable
    echo 1 > /sys/kernel/tracing/events/sched/sched_wakeup/enable
    echo 1 > /sys/kernel/tracing/events/sched/sched_wakeup_new/enable
    echo 1 > /sys/kernel/tracing/events/sched/sched_stat_iowait/enable
    echo 1 > /sys/kernel/tracing/events/sched_stat_blocked/enable
    # sound
    echo 1 > /sys/kernel/tracing/events/asoc/snd_soc_reg_read/enable
    echo 1 > /sys/kernel/tracing/events/asoc/snd_soc_reg_write/enable
    # mdp
    echo 1 > /sys/kernel/tracing/events/mdss/mdp_video_underrun_done/enable
    # video
    echo 1 > /sys/kernel/tracing/events/msm_vidc/enable
    # clock
    echo 1 > /sys/kernel/tracing/events/power/clock_set_rate/enable
    echo 1 > /sys/kernel/tracing/events/power/clock_enable/enable
    echo 1 > /sys/kernel/tracing/events/power/clock_disable/enable
    echo 1 > /sys/kernel/tracing/events/power/cpu_frequency/enable
    # regulator
    echo 1 > /sys/kernel/tracing/events/regulator/enable
    # power
    echo 1 > /sys/kernel/tracing/events/msm_low_power/enable
    # fastrpc
    echo 1 > /sys/kernel/tracing/events/fastrpc/enable

    echo 1 > /sys/kernel/tracing/tracing_on
}

# function to disable SF tracing on perf config
sf_tracing_disablement()
{
    # disable SF tracing if its perf config
    if [ ! -d /sys/module/msm_rtb ]
    then
        setprop debug.sf.enable_transaction_tracing 0
    fi
}

# function to enable ftrace events
enable_ftrace_event_tracing()
{
    # bail out if its perf config
    if [ ! -d /sys/module/msm_rtb ]
    then
        return
    fi

    # bail out if ftrace events aren't present
    if [ ! -d /sys/kernel/tracing/events ]
    then
        return
    fi

    enable_tracing_events
}

# function to enable ftrace event transfer to CoreSight STM
enable_stm_events()
{
    # bail out if its perf config
    if [ ! -d /sys/module/msm_rtb ]
    then
        return
    fi
    # bail out if coresight isn't present
    if [ ! -d /sys/bus/coresight ]
    then
        return
    fi
    # bail out if ftrace events aren't present
    if [ ! -d /sys/kernel/tracing/events ]
    then
        return
    fi

    echo $etr_size > /sys/bus/coresight/devices/coresight-tmc-etr/buffer_size
    echo 1 > /sys/bus/coresight/devices/coresight-tmc-etr/$sinkenable
    echo coresight-stm > /sys/class/stm_source/ftrace/stm_source_link
    echo 1 > /sys/bus/coresight/devices/coresight-stm/$srcenable
    echo 1 > /sys/kernel/tracing/tracing_on
    echo 0 > /sys/bus/coresight/devices/coresight-stm/hwevent_enable
}
enable_lpm_with_dcvs_tracing()
{
    # "Configure CPUSS LPM Debug events"
    echo 1 > /sys/bus/coresight/devices/coresight-tpdm-apss/reset
    echo 0x0 0x3 0x1 > /sys/bus/coresight/devices/coresight-tpdm-apss/dsb_edge_ctrl_mask
    echo 0x0 0x3 0 > /sys/bus/coresight/devices/coresight-tpdm-apss/dsb_edge_ctrl
    echo 0x4 0x4 0x1 > /sys/bus/coresight/devices/coresight-tpdm-apss/dsb_edge_ctrl_mask
    echo 0x4 0x4 0 > /sys/bus/coresight/devices/coresight-tpdm-apss/dsb_edge_ctrl
    echo 0x5 0x5 0x1 > /sys/bus/coresight/devices/coresight-tpdm-apss/dsb_edge_ctrl_mask
    echo 0x5 0x5 0 > /sys/bus/coresight/devices/coresight-tpdm-apss/dsb_edge_ctrl
    echo 0x6 0x8 0x1 > /sys/bus/coresight/devices/coresight-tpdm-apss/dsb_edge_ctrl_mask
    echo 0x6 0x8 0 > /sys/bus/coresight/devices/coresight-tpdm-apss/dsb_edge_ctrl
    echo 0xc 0xf 0x1 > /sys/bus/coresight/devices/coresight-tpdm-apss/dsb_edge_ctrl_mask
    echo 0xc 0xf 0x1 > /sys/bus/coresight/devices/coresight-tpdm-apss/dsb_edge_ctrl_mask
    echo 0xc 0xf 0 > /sys/bus/coresight/devices/coresight-tpdm-apss/dsb_edge_ctrl
    echo 0x1d 0x1d 0x1 > /sys/bus/coresight/devices/coresight-tpdm-apss/dsb_edge_ctrl_mask
    echo 0x1d 0x1d 0 > /sys/bus/coresight/devices/coresight-tpdm-apss/dsb_edge_ctrl
    echo 0x2b 0x3f 0x1 > /sys/bus/coresight/devices/coresight-tpdm-apss/dsb_edge_ctrl_mask
    echo 0x2b 0x3f 0 > /sys/bus/coresight/devices/coresight-tpdm-apss/dsb_edge_ctrl
    echo 0x80 0x9a 0x1 > /sys/bus/coresight/devices/coresight-tpdm-apss/dsb_edge_ctrl_mask
    echo 0x80 0x9a 0 > /sys/bus/coresight/devices/coresight-tpdm-apss/dsb_edge_ctrl
    echo 0 0x11111111  > /sys/bus/coresight/devices/coresight-tpdm-apss/dsb_msr
    echo 1 0x66660001  > /sys/bus/coresight/devices/coresight-tpdm-apss/dsb_msr
    echo 2 0x00000000  > /sys/bus/coresight/devices/coresight-tpdm-apss/dsb_msr
    echo 3 0x00100000  > /sys/bus/coresight/devices/coresight-tpdm-apss/dsb_msr
    echo 5 0x11111000  > /sys/bus/coresight/devices/coresight-tpdm-apss/dsb_msr
    echo 6 0x11111111  > /sys/bus/coresight/devices/coresight-tpdm-apss/dsb_msr
    echo 7 0x11111111  > /sys/bus/coresight/devices/coresight-tpdm-apss/dsb_msr
    echo 16 0x11111111  > /sys/bus/coresight/devices/coresight-tpdm-apss/dsb_msr
    echo 17 0x11111111  > /sys/bus/coresight/devices/coresight-tpdm-apss/dsb_msr
    echo 18 0x11111111  > /sys/bus/coresight/devices/coresight-tpdm-apss/dsb_msr
    echo 19 0x00000111  > /sys/bus/coresight/devices/coresight-tpdm-apss/dsb_msr
    echo 0 0xFFFFFFFF > /sys/bus/coresight/devices/coresight-tpdm-apss/dsb_patt_mask
    echo 1 0xFFFFFFFF > /sys/bus/coresight/devices/coresight-tpdm-apss/dsb_patt_mask
    echo 2 0xFFFFFFFF > /sys/bus/coresight/devices/coresight-tpdm-apss/dsb_patt_mask
    echo 3 0xFFFFFFFF > /sys/bus/coresight/devices/coresight-tpdm-apss/dsb_patt_mask
    echo 4 0xFFFFFFFF > /sys/bus/coresight/devices/coresight-tpdm-apss/dsb_patt_mask
    echo 5 0xFFFFFFFF > /sys/bus/coresight/devices/coresight-tpdm-apss/dsb_patt_mask
    echo 6 0xFFFFFFFF > /sys/bus/coresight/devices/coresight-tpdm-apss/dsb_patt_mask
    echo 7 0xFFFFFFFF > /sys/bus/coresight/devices/coresight-tpdm-apss/dsb_patt_mask
    echo 1 > /sys/bus/coresight/devices/coresight-tpdm-apss/dsb_patt_ts
    echo 1 > /sys/bus/coresight/devices/coresight-tpdm-apss/dsb_patt_type
    echo 0 > /sys/bus/coresight/devices/coresight-tpdm-apss/dsb_trig_ts


    # "Configure CPUCP Trace and Debug Bus ACTPM "
    echo 1 > /sys/bus/coresight/devices/coresight-tpdm-actpm/reset
    ### CMB_MSR : [10]: debug_en, [7:6] : 0x0-0x3 : clkdom0-clkdom3 debug_bus
    ###         : [5]: trace_en, [4]: 0b0:continuous mode 0b1 : legacy mode
    ###         : [3:0] : legacy mode : 0x0 : combined_traces 0x1-0x4 : clkdom0-clkdom3
    ### Select CLKDOM0 (L3) debug bus and all CLKDOM trace bus
    echo 0 0x420 > /sys/bus/coresight/devices/coresight-tpdm-actpm/cmb_msr
    echo 0 > /sys/bus/coresight/devices/coresight-tpdm-actpm/mcmb_lanes_select
    echo 1 0 > /sys/bus/coresight/devices/coresight-tpdm-actpm/cmb_mode
    echo 1 > /sys/bus/coresight/devices/coresight-tpda-actpm/cmbchan_mode
    echo 1 > /sys/bus/coresight/devices/coresight-tpdm-actpm/cmb_ts_all
    echo 1 > /sys/bus/coresight/devices/coresight-tpdm-actpm/cmb_patt_ts
    echo 0 0x20000000 > /sys/bus/coresight/devices/coresight-tpdm-actpm/cmb_patt_mask
    echo 0 0x20000000 > /sys/bus/coresight/devices/coresight-tpdm-actpm/cmb_patt_val

    # "Start Trace collection "
    echo 2 > /sys/bus/coresight/devices/coresight-tpdm-apss/enable_datasets
    echo 1 > /sys/bus/coresight/devices/coresight-tpdm-apss/enable_source
    echo 0x4 > /sys/bus/coresight/devices/coresight-tpdm-actpm/enable_datasets
    echo 1 > /sys/bus/coresight/devices/coresight-tpdm-actpm/enable_source

}


enable_stm_hw_events()
{
   #TODO: Add HW events
}

gemnoc_dump()
{
    #; gem_noc_fault_sbm
    echo 0x24183040 1 > $DCC_PATH/config
    echo 0x24183048 1 > $DCC_PATH/config

    #; gem_noc_qns_llcc0_poc_err
    echo 0x24102010 1 > $DCC_PATH/config
    echo 0x24102020 6 > $DCC_PATH/config
    #; gem_noc_qns_llcc2_poc_err
    echo 0x24102410 1 > $DCC_PATH/config
    echo 0x24102420 6 > $DCC_PATH/config
    #; gem_noc_qns_llcc1_poc_err
    echo 0x24142010 1 > $DCC_PATH/config
    echo 0x24142020 6 > $DCC_PATH/config
    #; gem_noc_qns_llcc3_poc_err
    echo 0x24142410 1 > $DCC_PATH/config
    echo 0x24142420 6 > $DCC_PATH/config
    #; gem_noc_qns_cnoc_poc_err
    echo 0x24182010 1 > $DCC_PATH/config
    echo 0x24182020 6 > $DCC_PATH/config
    #; gem_noc_qns_pcie_poc_err
    echo 0x24182410 1 > $DCC_PATH/config
    echo 0x24182420 6 > $DCC_PATH/config

    #; gem_noc_qns_llcc0_poc_dbg
    echo 0x24100810 1 > $DCC_PATH/config
    echo 0x24100838 1 > $DCC_PATH/config
    echo 0x24100830 2 > $DCC_PATH/config
    echo 0x24100830 2 > $DCC_PATH/config
    echo 0x24100830 2 > $DCC_PATH/config
    echo 0x24100830 2 > $DCC_PATH/config
    echo 0x24100838 1 > $DCC_PATH/config
    echo 0x24100830 2 > $DCC_PATH/config
    echo 0x24100830 2 > $DCC_PATH/config
    echo 0x24100830 2 > $DCC_PATH/config
    echo 0x24100830 2 > $DCC_PATH/config
    echo 0x24100838 1 > $DCC_PATH/config
    echo 0x24100830 2 > $DCC_PATH/config
    echo 0x24100830 2 > $DCC_PATH/config
    echo 0x24100830 2 > $DCC_PATH/config
    echo 0x24100830 2 > $DCC_PATH/config
    echo 0x24100838 1 > $DCC_PATH/config
    echo 0x24100830 2 > $DCC_PATH/config
    echo 0x24100830 2 > $DCC_PATH/config
    echo 0x24100830 2 > $DCC_PATH/config
    echo 0x24100830 2 > $DCC_PATH/config
    echo 0x24100808 2 > $DCC_PATH/config
    #; gem_noc_qns_llcc2_poc_dbg
    echo 0x24100C10 1 > $DCC_PATH/config
    echo 0x24100C38 1 > $DCC_PATH/config
    echo 0x24100C30 2 > $DCC_PATH/config
    echo 0x24100C30 2 > $DCC_PATH/config
    echo 0x24100C30 2 > $DCC_PATH/config
    echo 0x24100C30 2 > $DCC_PATH/config
    echo 0x24100C38 1 > $DCC_PATH/config
    echo 0x24100C30 2 > $DCC_PATH/config
    echo 0x24100C30 2 > $DCC_PATH/config
    echo 0x24100C30 2 > $DCC_PATH/config
    echo 0x24100C30 2 > $DCC_PATH/config
    echo 0x24100C38 1 > $DCC_PATH/config
    echo 0x24100C30 2 > $DCC_PATH/config
    echo 0x24100C30 2 > $DCC_PATH/config
    echo 0x24100C30 2 > $DCC_PATH/config
    echo 0x24100C30 2 > $DCC_PATH/config
    echo 0x24100C38 1 > $DCC_PATH/config
    echo 0x24100C30 2 > $DCC_PATH/config
    echo 0x24100C30 2 > $DCC_PATH/config
    echo 0x24100C30 2 > $DCC_PATH/config
    echo 0x24100C30 2 > $DCC_PATH/config
    echo 0x24100C08 2 > $DCC_PATH/config
    #; gem_noc_qns_llcc1_poc_dbg
    echo 0x24140810 1 > $DCC_PATH/config
    echo 0x24140838 1 > $DCC_PATH/config
    echo 0x24140830 2 > $DCC_PATH/config
    echo 0x24140830 2 > $DCC_PATH/config
    echo 0x24140830 2 > $DCC_PATH/config
    echo 0x24140830 2 > $DCC_PATH/config
    echo 0x24140838 1 > $DCC_PATH/config
    echo 0x24140830 2 > $DCC_PATH/config
    echo 0x24140830 2 > $DCC_PATH/config
    echo 0x24140830 2 > $DCC_PATH/config
    echo 0x24140830 2 > $DCC_PATH/config
    echo 0x24140838 1 > $DCC_PATH/config
    echo 0x24140830 2 > $DCC_PATH/config
    echo 0x24140830 2 > $DCC_PATH/config
    echo 0x24140830 2 > $DCC_PATH/config
    echo 0x24140830 2 > $DCC_PATH/config
    echo 0x24140838 1 > $DCC_PATH/config
    echo 0x24140830 2 > $DCC_PATH/config
    echo 0x24140830 2 > $DCC_PATH/config
    echo 0x24140830 2 > $DCC_PATH/config
    echo 0x24140830 2 > $DCC_PATH/config
    echo 0x24140808 2 > $DCC_PATH/config
    #; gem_noc_qns_llcc3_poc_dbg
    echo 0x24140C10 1 > $DCC_PATH/config
    echo 0x24140C38 1 > $DCC_PATH/config
    echo 0x24140C30 2 > $DCC_PATH/config
    echo 0x24140C30 2 > $DCC_PATH/config
    echo 0x24140C30 2 > $DCC_PATH/config
    echo 0x24140C30 2 > $DCC_PATH/config
    echo 0x24140C38 1 > $DCC_PATH/config
    echo 0x24140C30 2 > $DCC_PATH/config
    echo 0x24140C30 2 > $DCC_PATH/config
    echo 0x24140C30 2 > $DCC_PATH/config
    echo 0x24140C30 2 > $DCC_PATH/config
    echo 0x24140C38 1 > $DCC_PATH/config
    echo 0x24140C30 2 > $DCC_PATH/config
    echo 0x24140C30 2 > $DCC_PATH/config
    echo 0x24140C30 2 > $DCC_PATH/config
    echo 0x24140C30 2 > $DCC_PATH/config
    echo 0x24140C38 1 > $DCC_PATH/config
    echo 0x24140C30 2 > $DCC_PATH/config
    echo 0x24140C30 2 > $DCC_PATH/config
    echo 0x24140C30 2 > $DCC_PATH/config
    echo 0x24140C30 2 > $DCC_PATH/config
    echo 0x24140C08 2 > $DCC_PATH/config
    #; gem_noc_qns_cnoc_poc_dbg
    echo 0x24180010 1 > $DCC_PATH/config
    echo 0x24180038 1 > $DCC_PATH/config
    echo 0x24180030 2 > $DCC_PATH/config
    echo 0x24180030 2 > $DCC_PATH/config
    echo 0x24180030 2 > $DCC_PATH/config
    echo 0x24180030 2 > $DCC_PATH/config
    echo 0x24180038 1 > $DCC_PATH/config
    echo 0x24180030 2 > $DCC_PATH/config
    echo 0x24180030 2 > $DCC_PATH/config
    echo 0x24180030 2 > $DCC_PATH/config
    echo 0x24180030 2 > $DCC_PATH/config
    echo 0x24180038 1 > $DCC_PATH/config
    echo 0x24180030 2 > $DCC_PATH/config
    echo 0x24180030 2 > $DCC_PATH/config
    echo 0x24180030 2 > $DCC_PATH/config
    echo 0x24180030 2 > $DCC_PATH/config
    echo 0x24180038 1 > $DCC_PATH/config
    echo 0x24180030 2 > $DCC_PATH/config
    echo 0x24180030 2 > $DCC_PATH/config
    echo 0x24180030 2 > $DCC_PATH/config
    echo 0x24180030 2 > $DCC_PATH/config
    echo 0x24180008 2 > $DCC_PATH/config
    #; gem_noc_qns_pcie_poc_dbg
    echo 0x24180410 1 > $DCC_PATH/config
    echo 0x24180438 1 > $DCC_PATH/config
    echo 0x24180430 2 > $DCC_PATH/config
    echo 0x24180430 2 > $DCC_PATH/config
    echo 0x24180430 2 > $DCC_PATH/config
    echo 0x24180430 2 > $DCC_PATH/config
    echo 0x24180438 1 > $DCC_PATH/config
    echo 0x24180430 2 > $DCC_PATH/config
    echo 0x24180430 2 > $DCC_PATH/config
    echo 0x24180430 2 > $DCC_PATH/config
    echo 0x24180430 2 > $DCC_PATH/config
    echo 0x24180438 1 > $DCC_PATH/config
    echo 0x24180430 2 > $DCC_PATH/config
    echo 0x24180430 2 > $DCC_PATH/config
    echo 0x24180430 2 > $DCC_PATH/config
    echo 0x24180430 2 > $DCC_PATH/config
    echo 0x24180438 1 > $DCC_PATH/config
    echo 0x24180430 2 > $DCC_PATH/config
    echo 0x24180430 2 > $DCC_PATH/config
    echo 0x24180430 2 > $DCC_PATH/config
    echo 0x24180430 2 > $DCC_PATH/config
    echo 0x24180408 2 > $DCC_PATH/config

    #; Coherent_even_chain
    echo 0x24101018 1 > $DCC_PATH/config
    echo 0x24101008 1 > $DCC_PATH/config
    echo 0x24101010 2 > $DCC_PATH/config
    echo 0x24101010 2 > $DCC_PATH/config
    echo 0x24101010 2 > $DCC_PATH/config
    echo 0x24101010 2 > $DCC_PATH/config
    #; NonCoherent_even_chain
    echo 0x24101098 1 > $DCC_PATH/config
    echo 0x24101088 1 > $DCC_PATH/config
    echo 0x24101090 2 > $DCC_PATH/config
    echo 0x24101090 2 > $DCC_PATH/config
    echo 0x24101090 2 > $DCC_PATH/config
    echo 0x24101090 2 > $DCC_PATH/config
    echo 0x24101090 2 > $DCC_PATH/config
    #; Coherent_odd_chain
    echo 0x24141018 1 > $DCC_PATH/config
    echo 0x24141008 1 > $DCC_PATH/config
    echo 0x24141010 2 > $DCC_PATH/config
    echo 0x24141010 2 > $DCC_PATH/config
    echo 0x24141010 2 > $DCC_PATH/config
    echo 0x24141010 2 > $DCC_PATH/config
    #; NonCoherent_odd_chain
    echo 0x24141098 1 > $DCC_PATH/config
    echo 0x24141088 1 > $DCC_PATH/config
    echo 0x24141090 2 > $DCC_PATH/config
    echo 0x24141090 2 > $DCC_PATH/config
    echo 0x24141090 2 > $DCC_PATH/config
    echo 0x24141090 2 > $DCC_PATH/config
    echo 0x24141090 2 > $DCC_PATH/config
    #; Coherent_sys_chain
    echo 0x24181018 1 > $DCC_PATH/config
    echo 0x24181008 1 > $DCC_PATH/config
    echo 0x24181010 2 > $DCC_PATH/config
    echo 0x24181010 2 > $DCC_PATH/config
    echo 0x24181010 2 > $DCC_PATH/config
    #; NonCoherent_sys_chain
    echo 0x24181098 1 > $DCC_PATH/config
    echo 0x24181088 1 > $DCC_PATH/config
    echo 0x24181090 2 > $DCC_PATH/config
    echo 0x24181090 2 > $DCC_PATH/config
    echo 0x24181090 2 > $DCC_PATH/config
    echo 0x24181090 2 > $DCC_PATH/config
    echo 0x24181090 2 > $DCC_PATH/config
    echo 0x24181090 2 > $DCC_PATH/config
    echo 0x24181090 2 > $DCC_PATH/config
    echo 0x24181090 2 > $DCC_PATH/config
    echo 0x24181090 2 > $DCC_PATH/config
    echo 0x24181090 2 > $DCC_PATH/config
    echo 0x24181090 2 > $DCC_PATH/config
    echo 0x24181090 2 > $DCC_PATH/config
}

dc_noc_dump()
{
    #; dc_noc_dch_erl
    echo 0x240e0010 1 > $DCC_PATH/config
    echo 0x240e0020 8 > $DCC_PATH/config
    echo 0x240e0248 1 > $DCC_PATH/config
    #; dc_noc_ch_hm02_erl
    echo 0x245f0010 1 > $DCC_PATH/config
    echo 0x245f0020 8 > $DCC_PATH/config
    echo 0x245f0248 1 > $DCC_PATH/config
    #; dc_noc_ch_hm13_erl
    echo 0x247f0010 1 > $DCC_PATH/config
    echo 0x247f0020 8 > $DCC_PATH/config
    echo 0x247f0248 1 > $DCC_PATH/config
    #; llclpi_noc_erl
    echo 0x24330010 1 > $DCC_PATH/config
    echo 0x24330020 8 > $DCC_PATH/config
    echo 0x24330248 1 > $DCC_PATH/config

    #; dch/DebugChain
    echo 0x240e1018 1 > $DCC_PATH/config
    echo 0x240e1008 1 > $DCC_PATH/config
    echo 0x9  > $DCC_PATH/loop
    echo 0x240e1010 2 > $DCC_PATH/config
    echo 0x1 > $DCC_PATH/loop
    #; ch_hm02/DebugChain
    echo 0x245f2018 1 > $DCC_PATH/config
    echo 0x245f2008 1 > $DCC_PATH/config
    echo 0x3  > $DCC_PATH/loop
    echo 0x245f2010 2 > $DCC_PATH/config
    echo 0x1 > $DCC_PATH/loop
    #; ch_hm13/DebugChain
    echo 0x247f2018 1 > $DCC_PATH/config
    echo 0x247f2008 1 > $DCC_PATH/config
    echo 0x3  > $DCC_PATH/loop
    echo 0x247f2010 2 > $DCC_PATH/config
    echo 0x1 > $DCC_PATH/loop
    #; llclpi_noc/DebugChain
    echo 0x24331018 1 > $DCC_PATH/config
    echo 0x24331008 1 > $DCC_PATH/config
    echo 0x8  > $DCC_PATH/loop
    echo 0x24331010 2 > $DCC_PATH/config
    echo 0x1 > $DCC_PATH/loop
}


lpass_noc_dump()
{
    #; kailua_qtb_lpass_fault_sbm
    echo 0x00506048 1 > $DCC_PATH/config
    #; kailua_qtb_lpass/DebugChain
    echo 0x00510018 1 > $DCC_PATH/config
    echo 0x00510008 1 > $DCC_PATH/config
    echo 0x4  > $DCC_PATH/loop
    echo 0x00510010 2 > $DCC_PATH/config
    echo 0x1 > $DCC_PATH/loop
    #; kailua_qtb_lpass_QTB500/DebugChain
    echo 0x00511018 1 > $DCC_PATH/config
    echo 0x00511008 1 > $DCC_PATH/config
    echo 0x4  > $DCC_PATH/loop
    echo 0x00511010 2 > $DCC_PATH/config
    echo 0x1 > $DCC_PATH/loop

    #; lpass_lpiaon_noc_lpiaon_chipcx_erl
    echo 0x07400010 1 > $DCC_PATH/config
    echo 0x07400020 8 > $DCC_PATH/config
    echo 0x07402048 1 > $DCC_PATH/config
    #; lpass_lpiaon_noc_lpiaon_chipcx/DebugChain
    echo 0x07401018 1 > $DCC_PATH/config
    echo 0x07401008 1 > $DCC_PATH/config
    echo 0x07401010 2 > $DCC_PATH/config
    echo 0x07401010 2 > $DCC_PATH/config

    #; lpass_lpiaon_noc_lpiaon_lpicx_erl
    echo 0x07410010 1 > $DCC_PATH/config
    echo 0x07410020 8 > $DCC_PATH/config
    echo 0x07410248 1 > $DCC_PATH/config
    #; lpass_lpiaon_noc_lpiaon_lpicx/DebugChain
    echo 0x07402018 1 > $DCC_PATH/config
    echo 0x07402008 1 > $DCC_PATH/config
    echo 0x07402010 2 > $DCC_PATH/config
    echo 0x07402010 2 > $DCC_PATH/config
    echo 0x07402010 2 > $DCC_PATH/config

    #; lpass_lpicx_erl
    echo 0x07430010 1 > $DCC_PATH/config
    echo 0x07430020 8 > $DCC_PATH/config
    echo 0x07430248 1 > $DCC_PATH/config
    #; lpass_lpicx/DebugChain
    echo 0x07432018 1 > $DCC_PATH/config
    echo 0x07432008 1 > $DCC_PATH/config
    echo 0xd  > $DCC_PATH/loop
    echo 0x07432010 2 > $DCC_PATH/config
    echo 0x1 > $DCC_PATH/loop

    #; lpass_ag_noc_erl
    echo 0x074e0010 1 > $DCC_PATH/config
    echo 0x074e0020 8 > $DCC_PATH/config
    echo 0x074e0248 1 > $DCC_PATH/config
    #; lpass_ag_noc/DebugChain
    echo 0x074e2018 1 > $DCC_PATH/config
    echo 0x074e2008 1 > $DCC_PATH/config
    echo 0x6  > $DCC_PATH/loop
    echo 0x074e2010 2 > $DCC_PATH/config
    echo 0x1 > $DCC_PATH/loop
}

mmss_noc_dump()
{
    #; mmss_noc_erl
    echo 0x01780010 1 > $DCC_PATH/config
    echo 0x01780020 8 > $DCC_PATH/config
    echo 0x01780248 1 > $DCC_PATH/config
    #; mmss_noc/DebugChain
    echo 0x01782018 1 > $DCC_PATH/config
    echo 0x01782008 1 > $DCC_PATH/config
    echo 0xc  > $DCC_PATH/loop
    echo 0x01782010 2 > $DCC_PATH/config
    echo 0x1 > $DCC_PATH/loop
    #; mmss_noc_QTB500/DebugChain
    echo 0x01783018 1 > $DCC_PATH/config
    echo 0x01783008 1 > $DCC_PATH/config
    echo 0x11  > $DCC_PATH/loop
    echo 0x01783010 2 > $DCC_PATH/config
    echo 0x1 > $DCC_PATH/loop
}

system_noc_dump()
{
    #; system_noc_erl
    echo 0x01680010 1 > $DCC_PATH/config
    echo 0x01680020 8 > $DCC_PATH/config
    echo 0x01681048 1 > $DCC_PATH/config
    #; system_noc/DebugChain
    echo 0x01682018 1 > $DCC_PATH/config
    echo 0x01682008 1 > $DCC_PATH/config
    echo 0x6  > $DCC_PATH/loop
    echo 0x01682010 2 > $DCC_PATH/config
    echo 0x1 > $DCC_PATH/loop
}

aggre_noc_dump()
{
    #; a1_noc_aggre_noc_erl
    echo 0x016e0010 1 > $DCC_PATH/config
    echo 0x016e0020 8 > $DCC_PATH/config
    echo 0x016e0248 1 > $DCC_PATH/config
    #; a1_noc_aggre_noc_south/DebugChain
    echo 0x016e1018 1 > $DCC_PATH/config
    echo 0x016e1008 1 > $DCC_PATH/config
    echo 0x4  > $DCC_PATH/loop
    echo 0x016e1010 2 > $DCC_PATH/config
    echo 0x1 > $DCC_PATH/loop
    #; a1_noc_aggre_noc_ANOC_NIU/DebugChain
    echo 0x016e1098 1 > $DCC_PATH/config
    echo 0x016e1088 1 > $DCC_PATH/config
    echo 0x3  > $DCC_PATH/loop
    echo 0x016e1090 2 > $DCC_PATH/config
    echo 0x1 > $DCC_PATH/loop
    #; a1_noc_aggre_noc_ANOC_QTB/DebugChain
    echo 0x016e1118 1 > $DCC_PATH/config
    echo 0x016e1108 1 > $DCC_PATH/config
    echo 0x7  > $DCC_PATH/loop
    echo 0x016e1110 2 > $DCC_PATH/config
    echo 0x1 > $DCC_PATH/loop

    #; a2_noc_aggre_noc_erl
    echo 0x01700010 1 > $DCC_PATH/config
    echo 0x01700020 8 > $DCC_PATH/config
    echo 0x01700248 1 > $DCC_PATH/config
    #; a2_noc_aggre_noc_center/DebugChain
    echo 0x01701018 1 > $DCC_PATH/config
    echo 0x01701008 1 > $DCC_PATH/config
    echo 0x4  > $DCC_PATH/loop
    echo 0x01701010 2 > $DCC_PATH/config
    echo 0x1 > $DCC_PATH/loop
    #; a2_noc_aggre_noc_east/DebugChain
    echo 0x01701098 1 > $DCC_PATH/config
    echo 0x01701088 1 > $DCC_PATH/config
    echo 0x2  > $DCC_PATH/loop
    echo 0x01701090 2 > $DCC_PATH/config
    echo 0x1 > $DCC_PATH/loop
    #; a2_noc_aggre_noc_north/DebugChain
    echo 0x01701118 1 > $DCC_PATH/config
    echo 0x01701108 1 > $DCC_PATH/config
    echo 0x3  > $DCC_PATH/loop
    echo 0x01701110 2 > $DCC_PATH/config
    echo 0x1 > $DCC_PATH/loop
}

config_noc_dump()
{
    #; cnoc_cfg_erl
    echo 0x01600010 1 > $DCC_PATH/config
    echo 0x01600020 8 > $DCC_PATH/config
    echo 0x01600248 2 > $DCC_PATH/config
    echo 0x01600258 1 > $DCC_PATH/config
    #; cnoc_cfg_center/DebugChain
    echo 0x01602018 1 > $DCC_PATH/config
    echo 0x01602008 1 > $DCC_PATH/config
    echo 0x7  > $DCC_PATH/loop
    echo 0x01602010 2 > $DCC_PATH/config
    echo 0x1 > $DCC_PATH/loop
    #; cnoc_cfg_west/DebugChain
    echo 0x01602098 1 > $DCC_PATH/config
    echo 0x01602088 1 > $DCC_PATH/config
    echo 0x2  > $DCC_PATH/loop
    echo 0x01602090 2 > $DCC_PATH/config
    echo 0x1 > $DCC_PATH/loop
    #; cnoc_cfg_mmnoc/DebugChain
    echo 0x01602118 1 > $DCC_PATH/config
    echo 0x01602108 1 > $DCC_PATH/config
    echo 0x3  > $DCC_PATH/loop
    echo 0x01602110 2 > $DCC_PATH/config
    echo 0x1 > $DCC_PATH/loop
    #; cnoc_cfg_north/DebugChain
    echo 0x01602198 1 > $DCC_PATH/config
    echo 0x01602188 1 > $DCC_PATH/config
    echo 0x3  > $DCC_PATH/loop
    echo 0x01602190 2 > $DCC_PATH/config
    echo 0x1 > $DCC_PATH/loop
    #; cnoc_cfg_south/DebugChain
    echo 0x01602218 1 > $DCC_PATH/config
    echo 0x01602208 1 > $DCC_PATH/config
    echo 0x2  > $DCC_PATH/loop
    echo 0x01602210 2 > $DCC_PATH/config
    echo 0x1 > $DCC_PATH/loop
    #; cnoc_cfg_east/DebugChain
    echo 0x01602298 1 > $DCC_PATH/config
    echo 0x01602288 1 > $DCC_PATH/config
    echo 0x2  > $DCC_PATH/loop
    echo 0x01602290 2 > $DCC_PATH/config
    echo 0x1 > $DCC_PATH/loop

    #; cnoc_main_erl
    echo 0x01500010 1 > $DCC_PATH/config
    echo 0x01500020 8 > $DCC_PATH/config
    echo 0x01500248 1 > $DCC_PATH/config
    echo 0x01500448 1 > $DCC_PATH/config
    #; cnoc_main_center/DebugChain
    echo 0x01502018 1 > $DCC_PATH/config
    echo 0x01502008 1 > $DCC_PATH/config
    echo 0x7  > $DCC_PATH/loop
    echo 0x01502010 2 > $DCC_PATH/config
    echo 0x1 > $DCC_PATH/loop
    #; cnoc_main_north/DebugChain
    echo 0x01502098 1 > $DCC_PATH/config
    echo 0x01502088 1 > $DCC_PATH/config
    echo 0x7  > $DCC_PATH/loop
    echo 0x01502090 2 > $DCC_PATH/config
    echo 0x1 > $DCC_PATH/loop
}

nsp_noc_dump()
{
    #; kailua_qtb_nsp_fault_sbm
    echo 0x00526048 1 > $DCC_PATH/config
    #; kailua_qtb_nsp/DebugChain
    echo 0x00531018 1 > $DCC_PATH/config
    echo 0x00531008 1 > $DCC_PATH/config
    echo 0x4  > $DCC_PATH/loop
    echo 0x00531010 2 > $DCC_PATH/config
    echo 0x1 > $DCC_PATH/loop
    #; kailua_qtb_nsp_QTB500/DebugChain
    echo 0x00532018 1 > $DCC_PATH/config
    echo 0x00532008 1 > $DCC_PATH/config
    echo 0x4  > $DCC_PATH/loop
    echo 0x00532010 2 > $DCC_PATH/config
    echo 0x1 > $DCC_PATH/loop

    #; turing_nsp_erl
    echo 0x320c0010 1 > $DCC_PATH/config
    echo 0x320c0020 8 > $DCC_PATH/config
    echo 0x320c0248 1 > $DCC_PATH/config
    #; turing_nsp_noc/DebugChain
    echo 0x320c1018 1 > $DCC_PATH/config
    echo 0x320c1008 1 > $DCC_PATH/config
    echo 0x5  > $DCC_PATH/loop
    echo 0x320c1010 2 > $DCC_PATH/config
    echo 0x1 > $DCC_PATH/loop
}

config_dcc_ddr()
{
    #DDR -DCC starts here.
    #Start Link list #6
	#DDRSS
	echo 0x2407701c > $DCC_PATH/config
	echo 0x24077030 > $DCC_PATH/config
	echo 0x2408005c > $DCC_PATH/config
	echo 0x240800c8 > $DCC_PATH/config
	echo 0x240800d4 > $DCC_PATH/config
	echo 0x240800e0 > $DCC_PATH/config
	echo 0x240800ec > $DCC_PATH/config
	echo 0x240800f8 > $DCC_PATH/config
	echo 0x240801b4 > $DCC_PATH/config
	echo 0x240a80f8 > $DCC_PATH/config
	echo 0x240a80fc > $DCC_PATH/config
	echo 0x240a8100 > $DCC_PATH/config
	echo 0x240a8104 > $DCC_PATH/config
	echo 0x240a8108 > $DCC_PATH/config
	echo 0x240a810c > $DCC_PATH/config
	echo 0x240a8110 > $DCC_PATH/config
	echo 0x240a8178 > $DCC_PATH/config
	echo 0x240a817c > $DCC_PATH/config
	echo 0x240a8180 > $DCC_PATH/config
	echo 0x240a8184 > $DCC_PATH/config
	echo 0x240a8198 > $DCC_PATH/config
	echo 0x240a81a4 > $DCC_PATH/config
	echo 0x240a81b0 > $DCC_PATH/config
	echo 0x240a81bc > $DCC_PATH/config
	echo 0x240a81c8 > $DCC_PATH/config
	echo 0x240a81cc > $DCC_PATH/config
	echo 0x240a81f4 > $DCC_PATH/config
	echo 0x240a8214 > $DCC_PATH/config
	echo 0x240a8290 > $DCC_PATH/config
	echo 0x240a8804 > $DCC_PATH/config
	echo 0x240a880c > $DCC_PATH/config
	echo 0x240a8860 > $DCC_PATH/config
	echo 0x240a8864 > $DCC_PATH/config
	echo 0x240a8868 > $DCC_PATH/config
	echo 0x240ba28c > $DCC_PATH/config
	echo 0x240ba294 > $DCC_PATH/config
	echo 0x240ba29c > $DCC_PATH/config
	echo 0x24186100 > $DCC_PATH/config
	echo 0x24186104 > $DCC_PATH/config
	echo 0x24186108 > $DCC_PATH/config
	echo 0x2418610c > $DCC_PATH/config
	echo 0x24188100 > $DCC_PATH/config
	echo 0x2418d100 > $DCC_PATH/config
	echo 0x24401e64 > $DCC_PATH/config
	echo 0x24401ea0 > $DCC_PATH/config
	echo 0x24403e64 > $DCC_PATH/config
	echo 0x24403ea0 > $DCC_PATH/config
	echo 0x2440527c > $DCC_PATH/config
	echo 0x24405290 > $DCC_PATH/config
	echo 0x244054ec > $DCC_PATH/config
	echo 0x244054f4 > $DCC_PATH/config
	echo 0x24405514 > $DCC_PATH/config
	echo 0x2440551c > $DCC_PATH/config
	echo 0x24405524 > $DCC_PATH/config
	echo 0x24405548 > $DCC_PATH/config
	echo 0x24405550 > $DCC_PATH/config
	echo 0x24405558 > $DCC_PATH/config
	echo 0x244055b8 > $DCC_PATH/config
	echo 0x244055c0 > $DCC_PATH/config
	echo 0x244055ec > $DCC_PATH/config
	echo 0x24405870 > $DCC_PATH/config
	echo 0x244058a0 > $DCC_PATH/config
	echo 0x244058a8 > $DCC_PATH/config
	echo 0x244058b0 > $DCC_PATH/config
	echo 0x244058b8 > $DCC_PATH/config
	echo 0x244058d8 > $DCC_PATH/config
	echo 0x244058dc > $DCC_PATH/config
	echo 0x244058f4 > $DCC_PATH/config
	echo 0x244058fc > $DCC_PATH/config
	echo 0x24405920 > $DCC_PATH/config
	echo 0x24405928 > $DCC_PATH/config
	echo 0x24405944 > $DCC_PATH/config
	echo 0x24406604 > $DCC_PATH/config
	echo 0x2440660c > $DCC_PATH/config
	echo 0x24440310 > $DCC_PATH/config
	echo 0x24440400 > $DCC_PATH/config
	echo 0x24440404 > $DCC_PATH/config
	echo 0x24440410 > $DCC_PATH/config
	echo 0x24440414 > $DCC_PATH/config
	echo 0x24440418 > $DCC_PATH/config
	echo 0x24440428 > $DCC_PATH/config
	echo 0x24440430 > $DCC_PATH/config
	echo 0x24440440 > $DCC_PATH/config
	echo 0x24440448 > $DCC_PATH/config
	echo 0x244404a0 > $DCC_PATH/config
	echo 0x244404b0 > $DCC_PATH/config
	echo 0x244404b4 > $DCC_PATH/config
	echo 0x244404b8 > $DCC_PATH/config
	echo 0x244404d0 > $DCC_PATH/config
	echo 0x244404d4 > $DCC_PATH/config
	echo 0x2444341c > $DCC_PATH/config
	echo 0x24445804 > $DCC_PATH/config
	echo 0x2444590c > $DCC_PATH/config
	echo 0x24445a14 > $DCC_PATH/config
	echo 0x24445c1c > $DCC_PATH/config
	echo 0x24445c38 > $DCC_PATH/config
	echo 0x24449100 > $DCC_PATH/config
	echo 0x24449110 > $DCC_PATH/config
	echo 0x24449120 > $DCC_PATH/config
	echo 0x24449180 > $DCC_PATH/config
	echo 0x24449184 > $DCC_PATH/config
	echo 0x24460618 > $DCC_PATH/config
	echo 0x24460684 > $DCC_PATH/config
	echo 0x2446068c > $DCC_PATH/config
	echo 0x24481e64 > $DCC_PATH/config
	echo 0x24481ea0 > $DCC_PATH/config
	echo 0x24483e64 > $DCC_PATH/config
	echo 0x24483ea0 > $DCC_PATH/config
	echo 0x2448527c > $DCC_PATH/config
	echo 0x24485290 > $DCC_PATH/config
	echo 0x244854ec > $DCC_PATH/config
	echo 0x244854f4 > $DCC_PATH/config
	echo 0x24485514 > $DCC_PATH/config
	echo 0x2448551c > $DCC_PATH/config
	echo 0x24485524 > $DCC_PATH/config
	echo 0x24485548 > $DCC_PATH/config
	echo 0x24485550 > $DCC_PATH/config
	echo 0x24485558 > $DCC_PATH/config
	echo 0x244855b8 > $DCC_PATH/config
	echo 0x244855c0 > $DCC_PATH/config
	echo 0x244855ec > $DCC_PATH/config
	echo 0x24485870 > $DCC_PATH/config
	echo 0x244858a0 > $DCC_PATH/config
	echo 0x244858a8 > $DCC_PATH/config
	echo 0x244858b0 > $DCC_PATH/config
	echo 0x244858b8 > $DCC_PATH/config
	echo 0x244858d8 > $DCC_PATH/config
	echo 0x244858dc > $DCC_PATH/config
	echo 0x244858f4 > $DCC_PATH/config
	echo 0x244858fc > $DCC_PATH/config
	echo 0x24485920 > $DCC_PATH/config
	echo 0x24485928 > $DCC_PATH/config
	echo 0x24485944 > $DCC_PATH/config
	echo 0x24486604 > $DCC_PATH/config
	echo 0x2448660c > $DCC_PATH/config
	echo 0x244c0310 > $DCC_PATH/config
	echo 0x244c0400 > $DCC_PATH/config
	echo 0x244c0404 > $DCC_PATH/config
	echo 0x244c0410 > $DCC_PATH/config
	echo 0x244c0414 > $DCC_PATH/config
	echo 0x244c0418 > $DCC_PATH/config
	echo 0x244c0428 > $DCC_PATH/config
	echo 0x244c0430 > $DCC_PATH/config
	echo 0x244c0440 > $DCC_PATH/config
	echo 0x244c0448 > $DCC_PATH/config
	echo 0x244c04a0 > $DCC_PATH/config
	echo 0x244c04b0 > $DCC_PATH/config
	echo 0x244c04b4 > $DCC_PATH/config
	echo 0x244c04b8 > $DCC_PATH/config
	echo 0x244c04d0 > $DCC_PATH/config
	echo 0x244c04d4 > $DCC_PATH/config
	echo 0x244c341c > $DCC_PATH/config
	echo 0x244c5804 > $DCC_PATH/config
	echo 0x244c590c > $DCC_PATH/config
	echo 0x244c5a14 > $DCC_PATH/config
	echo 0x244c5c1c > $DCC_PATH/config
	echo 0x244c5c38 > $DCC_PATH/config
	echo 0x244c9100 > $DCC_PATH/config
	echo 0x244c9110 > $DCC_PATH/config
	echo 0x244c9120 > $DCC_PATH/config
	echo 0x244c9180 > $DCC_PATH/config
	echo 0x244c9184 > $DCC_PATH/config
	echo 0x244e0618 > $DCC_PATH/config
	echo 0x244e0684 > $DCC_PATH/config
	echo 0x244e068c > $DCC_PATH/config
	echo 0x24601e64 > $DCC_PATH/config
	echo 0x24601ea0 > $DCC_PATH/config
	echo 0x24603e64 > $DCC_PATH/config
	echo 0x24603ea0 > $DCC_PATH/config
	echo 0x2460527c > $DCC_PATH/config
	echo 0x24605290 > $DCC_PATH/config
	echo 0x246054ec > $DCC_PATH/config
	echo 0x246054f4 > $DCC_PATH/config
	echo 0x24605514 > $DCC_PATH/config
	echo 0x2460551c > $DCC_PATH/config
	echo 0x24605524 > $DCC_PATH/config
	echo 0x24605548 > $DCC_PATH/config
	echo 0x24605550 > $DCC_PATH/config
	echo 0x24605558 > $DCC_PATH/config
	echo 0x246055b8 > $DCC_PATH/config
	echo 0x246055c0 > $DCC_PATH/config
	echo 0x246055ec > $DCC_PATH/config
	echo 0x24605870 > $DCC_PATH/config
	echo 0x246058a0 > $DCC_PATH/config
	echo 0x246058a8 > $DCC_PATH/config
	echo 0x246058b0 > $DCC_PATH/config
	echo 0x246058b8 > $DCC_PATH/config
	echo 0x246058d8 > $DCC_PATH/config
	echo 0x246058dc > $DCC_PATH/config
	echo 0x246058f4 > $DCC_PATH/config
	echo 0x246058fc > $DCC_PATH/config
	echo 0x24605920 > $DCC_PATH/config
	echo 0x24605928 > $DCC_PATH/config
	echo 0x24605944 > $DCC_PATH/config
	echo 0x24606604 > $DCC_PATH/config
	echo 0x2460660c > $DCC_PATH/config
	echo 0x24640310 > $DCC_PATH/config
	echo 0x24640400 > $DCC_PATH/config
	echo 0x24640404 > $DCC_PATH/config
	echo 0x24640410 > $DCC_PATH/config
	echo 0x24640414 > $DCC_PATH/config
	echo 0x24640418 > $DCC_PATH/config
	echo 0x24640428 > $DCC_PATH/config
	echo 0x24640430 > $DCC_PATH/config
	echo 0x24640440 > $DCC_PATH/config
	echo 0x24640448 > $DCC_PATH/config
	echo 0x246404a0 > $DCC_PATH/config
	echo 0x246404b0 > $DCC_PATH/config
	echo 0x246404b4 > $DCC_PATH/config
	echo 0x246404b8 > $DCC_PATH/config
	echo 0x246404d0 > $DCC_PATH/config
	echo 0x246404d4 > $DCC_PATH/config
	echo 0x2464341c > $DCC_PATH/config
	echo 0x24645804 > $DCC_PATH/config
	echo 0x2464590c > $DCC_PATH/config
	echo 0x24645a14 > $DCC_PATH/config
	echo 0x24645c1c > $DCC_PATH/config
	echo 0x24645c38 > $DCC_PATH/config
	echo 0x24649100 > $DCC_PATH/config
	echo 0x24649110 > $DCC_PATH/config
	echo 0x24649120 > $DCC_PATH/config
	echo 0x24649180 > $DCC_PATH/config
	echo 0x24649184 > $DCC_PATH/config
	echo 0x24660618 > $DCC_PATH/config
	echo 0x24660684 > $DCC_PATH/config
	echo 0x2466068c > $DCC_PATH/config
	echo 0x24681e64 > $DCC_PATH/config
	echo 0x24681ea0 > $DCC_PATH/config
	echo 0x24683e64 > $DCC_PATH/config
	echo 0x24683ea0 > $DCC_PATH/config
	echo 0x2468527c > $DCC_PATH/config
	echo 0x24685290 > $DCC_PATH/config
	echo 0x246854ec > $DCC_PATH/config
	echo 0x246854f4 > $DCC_PATH/config
	echo 0x24685514 > $DCC_PATH/config
	echo 0x2468551c > $DCC_PATH/config
	echo 0x24685524 > $DCC_PATH/config
	echo 0x24685548 > $DCC_PATH/config
	echo 0x24685550 > $DCC_PATH/config
	echo 0x24685558 > $DCC_PATH/config
	echo 0x246855b8 > $DCC_PATH/config
	echo 0x246855c0 > $DCC_PATH/config
	echo 0x246855ec > $DCC_PATH/config
	echo 0x24685870 > $DCC_PATH/config
	echo 0x246858a0 > $DCC_PATH/config
	echo 0x246858a8 > $DCC_PATH/config
	echo 0x246858b0 > $DCC_PATH/config
	echo 0x246858b8 > $DCC_PATH/config
	echo 0x246858d8 > $DCC_PATH/config
	echo 0x246858dc > $DCC_PATH/config
	echo 0x246858f4 > $DCC_PATH/config
	echo 0x246858fc > $DCC_PATH/config
	echo 0x24685920 > $DCC_PATH/config
	echo 0x24685928 > $DCC_PATH/config
	echo 0x24685944 > $DCC_PATH/config
	echo 0x24686604 > $DCC_PATH/config
	echo 0x2468660c > $DCC_PATH/config
	echo 0x246c0310 > $DCC_PATH/config
	echo 0x246c0400 > $DCC_PATH/config
	echo 0x246c0404 > $DCC_PATH/config
	echo 0x246c0410 > $DCC_PATH/config
	echo 0x246c0414 > $DCC_PATH/config
	echo 0x246c0418 > $DCC_PATH/config
	echo 0x246c0428 > $DCC_PATH/config
	echo 0x246c0430 > $DCC_PATH/config
	echo 0x246c0440 > $DCC_PATH/config
	echo 0x246c0448 > $DCC_PATH/config
	echo 0x246c04a0 > $DCC_PATH/config
	echo 0x246c04b0 > $DCC_PATH/config
	echo 0x246c04b4 > $DCC_PATH/config
	echo 0x246c04b8 > $DCC_PATH/config
	echo 0x246c04d0 > $DCC_PATH/config
	echo 0x246c04d4 > $DCC_PATH/config
	echo 0x246c341c > $DCC_PATH/config
	echo 0x246c5804 > $DCC_PATH/config
	echo 0x246c590c > $DCC_PATH/config
	echo 0x246c5a14 > $DCC_PATH/config
	echo 0x246c5c1c > $DCC_PATH/config
	echo 0x246c5c38 > $DCC_PATH/config
	echo 0x246c9100 > $DCC_PATH/config
	echo 0x246c9110 > $DCC_PATH/config
	echo 0x246c9120 > $DCC_PATH/config
	echo 0x246c9180 > $DCC_PATH/config
	echo 0x246c9184 > $DCC_PATH/config
	echo 0x246e0618 > $DCC_PATH/config
	echo 0x246e0684 > $DCC_PATH/config
	echo 0x246e068c > $DCC_PATH/config
	echo 0x24840310 > $DCC_PATH/config
	echo 0x24840400 > $DCC_PATH/config
	echo 0x24840404 > $DCC_PATH/config
	echo 0x24840410 > $DCC_PATH/config
	echo 0x24840414 > $DCC_PATH/config
	echo 0x24840418 > $DCC_PATH/config
	echo 0x24840428 > $DCC_PATH/config
	echo 0x24840430 > $DCC_PATH/config
	echo 0x24840440 > $DCC_PATH/config
	echo 0x24840448 > $DCC_PATH/config
	echo 0x248404a0 > $DCC_PATH/config
	echo 0x248404b0 > $DCC_PATH/config
	echo 0x248404b4 > $DCC_PATH/config
	echo 0x248404b8 > $DCC_PATH/config
	echo 0x248404d0 > $DCC_PATH/config
	echo 0x248404d4 > $DCC_PATH/config
	echo 0x2484341c > $DCC_PATH/config
	echo 0x24845804 > $DCC_PATH/config
	echo 0x2484590c > $DCC_PATH/config
	echo 0x24845a14 > $DCC_PATH/config
	echo 0x24845c1c > $DCC_PATH/config
	echo 0x24845c38 > $DCC_PATH/config
	echo 0x24849100 > $DCC_PATH/config
	echo 0x24849110 > $DCC_PATH/config
	echo 0x24849120 > $DCC_PATH/config
	echo 0x24849180 > $DCC_PATH/config
	echo 0x24849184 > $DCC_PATH/config
	echo 0x24860618 > $DCC_PATH/config
	echo 0x24860684 > $DCC_PATH/config
	echo 0x2486068c > $DCC_PATH/config
	echo 0x248c0310 > $DCC_PATH/config
	echo 0x248c0400 > $DCC_PATH/config
	echo 0x248c0404 > $DCC_PATH/config
	echo 0x248c0410 > $DCC_PATH/config
	echo 0x248c0414 > $DCC_PATH/config
	echo 0x248c0418 > $DCC_PATH/config
	echo 0x248c0428 > $DCC_PATH/config
	echo 0x248c0430 > $DCC_PATH/config
	echo 0x248c0440 > $DCC_PATH/config
	echo 0x248c0448 > $DCC_PATH/config
	echo 0x248c04a0 > $DCC_PATH/config
	echo 0x248c04b0 > $DCC_PATH/config
	echo 0x248c04b4 > $DCC_PATH/config
	echo 0x248c04b8 > $DCC_PATH/config
	echo 0x248c04d0 > $DCC_PATH/config
	echo 0x248c04d4 > $DCC_PATH/config
	echo 0x248c341c > $DCC_PATH/config
	echo 0x248c5804 > $DCC_PATH/config
	echo 0x248c590c > $DCC_PATH/config
	echo 0x248c5a14 > $DCC_PATH/config
	echo 0x248c5c1c > $DCC_PATH/config
	echo 0x248c5c38 > $DCC_PATH/config
	echo 0x248c9100 > $DCC_PATH/config
	echo 0x248c9110 > $DCC_PATH/config
	echo 0x248c9120 > $DCC_PATH/config
	echo 0x248c9180 > $DCC_PATH/config
	echo 0x248c9184 > $DCC_PATH/config
	echo 0x248e0618 > $DCC_PATH/config
	echo 0x248e0684 > $DCC_PATH/config
	echo 0x248e068c > $DCC_PATH/config
	echo 0x25020348 > $DCC_PATH/config
	echo 0x25020480 > $DCC_PATH/config
	echo 0x25022400 > $DCC_PATH/config
	echo 0x25023220 > $DCC_PATH/config
	echo 0x25023224 > $DCC_PATH/config
	echo 0x25023228 > $DCC_PATH/config
	echo 0x2502322c > $DCC_PATH/config
	echo 0x25023258 > $DCC_PATH/config
	echo 0x2502325c > $DCC_PATH/config
	echo 0x25023308 > $DCC_PATH/config
	echo 0x25023318 > $DCC_PATH/config
	echo 0x25038100 > $DCC_PATH/config
	echo 0x2503c030 > $DCC_PATH/config
	echo 0x25042044 > $DCC_PATH/config
	echo 0x25042048 > $DCC_PATH/config
	echo 0x2504204c > $DCC_PATH/config
	echo 0x250420b0 > $DCC_PATH/config
	echo 0x25042104 > $DCC_PATH/config
	echo 0x25042114 > $DCC_PATH/config
	echo 0x25048004 > $DCC_PATH/config
	echo 0x25048008 > $DCC_PATH/config
	echo 0x2504800c > $DCC_PATH/config
	echo 0x25048010 > $DCC_PATH/config
	echo 0x25048014 > $DCC_PATH/config
	echo 0x2504c030 > $DCC_PATH/config
	echo 0x25050020 > $DCC_PATH/config
	echo 0x2506004c > $DCC_PATH/config
	echo 0x25060050 > $DCC_PATH/config
	echo 0x25060054 > $DCC_PATH/config
	echo 0x25060058 > $DCC_PATH/config
	echo 0x2506005c > $DCC_PATH/config
	echo 0x25060060 > $DCC_PATH/config
	echo 0x25060064 > $DCC_PATH/config
	echo 0x25060068 > $DCC_PATH/config
	echo 0x25220348 > $DCC_PATH/config
	echo 0x25220480 > $DCC_PATH/config
	echo 0x25222400 > $DCC_PATH/config
	echo 0x25223220 > $DCC_PATH/config
	echo 0x25223224 > $DCC_PATH/config
	echo 0x25223228 > $DCC_PATH/config
	echo 0x2522322c > $DCC_PATH/config
	echo 0x25223258 > $DCC_PATH/config
	echo 0x2522325c > $DCC_PATH/config
	echo 0x25223308 > $DCC_PATH/config
	echo 0x25223318 > $DCC_PATH/config
	echo 0x25238100 > $DCC_PATH/config
	echo 0x2523c030 > $DCC_PATH/config
	echo 0x25242044 > $DCC_PATH/config
	echo 0x25242048 > $DCC_PATH/config
	echo 0x2524204c > $DCC_PATH/config
	echo 0x252420b0 > $DCC_PATH/config
	echo 0x25242104 > $DCC_PATH/config
	echo 0x25242114 > $DCC_PATH/config
	echo 0x25248004 > $DCC_PATH/config
	echo 0x25248008 > $DCC_PATH/config
	echo 0x2524800c > $DCC_PATH/config
	echo 0x25248010 > $DCC_PATH/config
	echo 0x25248014 > $DCC_PATH/config
	echo 0x2524c030 > $DCC_PATH/config
	echo 0x25250020 > $DCC_PATH/config
	echo 0x2526004c > $DCC_PATH/config
	echo 0x25260050 > $DCC_PATH/config
	echo 0x25260054 > $DCC_PATH/config
	echo 0x25260058 > $DCC_PATH/config
	echo 0x2526005c > $DCC_PATH/config
	echo 0x25260060 > $DCC_PATH/config
	echo 0x25260064 > $DCC_PATH/config
	echo 0x25260068 > $DCC_PATH/config
	echo 0x25420348 > $DCC_PATH/config
	echo 0x25420480 > $DCC_PATH/config
	echo 0x25422400 > $DCC_PATH/config
	echo 0x25423220 > $DCC_PATH/config
	echo 0x25423224 > $DCC_PATH/config
	echo 0x25423228 > $DCC_PATH/config
	echo 0x2542322c > $DCC_PATH/config
	echo 0x25423258 > $DCC_PATH/config
	echo 0x2542325c > $DCC_PATH/config
	echo 0x25423308 > $DCC_PATH/config
	echo 0x25423318 > $DCC_PATH/config
	echo 0x25438100 > $DCC_PATH/config
	echo 0x2543c030 > $DCC_PATH/config
	echo 0x25442044 > $DCC_PATH/config
	echo 0x25442048 > $DCC_PATH/config
	echo 0x2544204c > $DCC_PATH/config
	echo 0x254420b0 > $DCC_PATH/config
	echo 0x25442104 > $DCC_PATH/config
	echo 0x25442114 > $DCC_PATH/config
	echo 0x25448004 > $DCC_PATH/config
	echo 0x25448008 > $DCC_PATH/config
	echo 0x2544800c > $DCC_PATH/config
	echo 0x25448010 > $DCC_PATH/config
	echo 0x25448014 > $DCC_PATH/config
	echo 0x2544c030 > $DCC_PATH/config
	echo 0x25450020 > $DCC_PATH/config
	echo 0x2546004c > $DCC_PATH/config
	echo 0x25460050 > $DCC_PATH/config
	echo 0x25460054 > $DCC_PATH/config
	echo 0x25460058 > $DCC_PATH/config
	echo 0x2546005c > $DCC_PATH/config
	echo 0x25460060 > $DCC_PATH/config
	echo 0x25460064 > $DCC_PATH/config
	echo 0x25460068 > $DCC_PATH/config
	echo 0x25620348 > $DCC_PATH/config
	echo 0x25620480 > $DCC_PATH/config
	echo 0x25622400 > $DCC_PATH/config
	echo 0x25623220 > $DCC_PATH/config
	echo 0x25623224 > $DCC_PATH/config
	echo 0x25623228 > $DCC_PATH/config
	echo 0x2562322c > $DCC_PATH/config
	echo 0x25623258 > $DCC_PATH/config
	echo 0x2562325c > $DCC_PATH/config
	echo 0x25623308 > $DCC_PATH/config
	echo 0x25623318 > $DCC_PATH/config
	echo 0x25638100 > $DCC_PATH/config
	echo 0x2563c030 > $DCC_PATH/config
	echo 0x25642044 > $DCC_PATH/config
	echo 0x25642048 > $DCC_PATH/config
	echo 0x2564204c > $DCC_PATH/config
	echo 0x256420b0 > $DCC_PATH/config
	echo 0x25642104 > $DCC_PATH/config
	echo 0x25642114 > $DCC_PATH/config
	echo 0x25648004 > $DCC_PATH/config
	echo 0x25648008 > $DCC_PATH/config
	echo 0x2564800c > $DCC_PATH/config
	echo 0x25648010 > $DCC_PATH/config
	echo 0x25648014 > $DCC_PATH/config
	echo 0x2564c030 > $DCC_PATH/config
	echo 0x25650020 > $DCC_PATH/config
	echo 0x2566004c > $DCC_PATH/config
	echo 0x25660050 > $DCC_PATH/config
	echo 0x25660054 > $DCC_PATH/config
	echo 0x25660058 > $DCC_PATH/config
	echo 0x2566005c > $DCC_PATH/config
	echo 0x25660060 > $DCC_PATH/config
	echo 0x25660064 > $DCC_PATH/config
	echo 0x25660068 > $DCC_PATH/config
	echo 0x25820348 > $DCC_PATH/config
	echo 0x25820480 > $DCC_PATH/config
	echo 0x25822400 > $DCC_PATH/config
	echo 0x25823220 > $DCC_PATH/config
	echo 0x25823224 > $DCC_PATH/config
	echo 0x25823228 > $DCC_PATH/config
	echo 0x2582322c > $DCC_PATH/config
	echo 0x25823258 > $DCC_PATH/config
	echo 0x2582325c > $DCC_PATH/config
	echo 0x25823308 > $DCC_PATH/config
	echo 0x25823318 > $DCC_PATH/config
	echo 0x25838100 > $DCC_PATH/config
	echo 0x2583c030 > $DCC_PATH/config
	echo 0x25842044 > $DCC_PATH/config
	echo 0x25842048 > $DCC_PATH/config
	echo 0x2584204c > $DCC_PATH/config
	echo 0x258420b0 > $DCC_PATH/config
	echo 0x25842104 > $DCC_PATH/config
	echo 0x25842114 > $DCC_PATH/config
	echo 0x25848004 > $DCC_PATH/config
	echo 0x25848008 > $DCC_PATH/config
	echo 0x2584800c > $DCC_PATH/config
	echo 0x25848010 > $DCC_PATH/config
	echo 0x25848014 > $DCC_PATH/config
	echo 0x2584c030 > $DCC_PATH/config
	echo 0x25850020 > $DCC_PATH/config
	echo 0x2586004c > $DCC_PATH/config
	echo 0x25860050 > $DCC_PATH/config
	echo 0x25860054 > $DCC_PATH/config
	echo 0x25860058 > $DCC_PATH/config
	echo 0x2586005c > $DCC_PATH/config
	echo 0x25860060 > $DCC_PATH/config
	echo 0x25860064 > $DCC_PATH/config
	echo 0x25860068 > $DCC_PATH/config
	echo 0x25a20348 > $DCC_PATH/config
	echo 0x25a20480 > $DCC_PATH/config
	echo 0x25a22400 > $DCC_PATH/config
	echo 0x25a23220 > $DCC_PATH/config
	echo 0x25a23224 > $DCC_PATH/config
	echo 0x25a23228 > $DCC_PATH/config
	echo 0x25a2322c > $DCC_PATH/config
	echo 0x25a23258 > $DCC_PATH/config
	echo 0x25a2325c > $DCC_PATH/config
	echo 0x25a23308 > $DCC_PATH/config
	echo 0x25a23318 > $DCC_PATH/config
	echo 0x25a38100 > $DCC_PATH/config
	echo 0x25a3c030 > $DCC_PATH/config
	echo 0x25a42044 > $DCC_PATH/config
	echo 0x25a42048 > $DCC_PATH/config
	echo 0x25a4204c > $DCC_PATH/config
	echo 0x25a420b0 > $DCC_PATH/config
	echo 0x25a42104 > $DCC_PATH/config
	echo 0x25a42114 > $DCC_PATH/config
	echo 0x25a48004 > $DCC_PATH/config
	echo 0x25a48008 > $DCC_PATH/config
	echo 0x25a4800c > $DCC_PATH/config
	echo 0x25a48010 > $DCC_PATH/config
	echo 0x25a48014 > $DCC_PATH/config
	echo 0x25a4c030 > $DCC_PATH/config
	echo 0x25a50020 > $DCC_PATH/config
	echo 0x25a6004c > $DCC_PATH/config
	echo 0x25a60050 > $DCC_PATH/config
	echo 0x25a60054 > $DCC_PATH/config
	echo 0x25a60058 > $DCC_PATH/config
	echo 0x25a6005c > $DCC_PATH/config
	echo 0x25a60060 > $DCC_PATH/config
	echo 0x25a60064 > $DCC_PATH/config
	echo 0x25a60068 > $DCC_PATH/config
	########## > $DCC_PATH/config ####LLCC LCP & LB ##
	echo 0x250a002c > $DCC_PATH/config
	echo 0x250a009c > $DCC_PATH/config
	echo 0x250a00a0 > $DCC_PATH/config
	echo 0x250a00a8 > $DCC_PATH/config
	echo 0x250a00ac > $DCC_PATH/config
	echo 0x250a00b0 > $DCC_PATH/config
	echo 0x250a00b8 > $DCC_PATH/config
	echo 0x250a00c0 > $DCC_PATH/config
	echo 0x250a00c4 > $DCC_PATH/config
	echo 0x250a00cc > $DCC_PATH/config
	echo 0x250a00d0 > $DCC_PATH/config
	echo 0x250a00d4 > $DCC_PATH/config
	echo 0x250a00d8 > $DCC_PATH/config
	echo 0x250a00e0 > $DCC_PATH/config
	echo 0x250a00e8 > $DCC_PATH/config
	echo 0x250a00f0 > $DCC_PATH/config
	echo 0x250a00f0 > $DCC_PATH/config
	echo 0x250a0100 > $DCC_PATH/config
	echo 0x250a0108 > $DCC_PATH/config
	echo 0x250a0110 > $DCC_PATH/config
	echo 0x250a0118 > $DCC_PATH/config
	echo 0x250a0120 > $DCC_PATH/config
	echo 0x250a0128 > $DCC_PATH/config
	echo 0x250a1010 > $DCC_PATH/config
	echo 0x250a1070 > $DCC_PATH/config
	echo 0x250a3004 > $DCC_PATH/config
	echo 0x254a002c > $DCC_PATH/config
	echo 0x254a009c > $DCC_PATH/config
	echo 0x254a00a0 > $DCC_PATH/config
	echo 0x254a00a8 > $DCC_PATH/config
	echo 0x254a00ac > $DCC_PATH/config
	echo 0x254a00b0 > $DCC_PATH/config
	echo 0x254a00b8 > $DCC_PATH/config
	echo 0x254a00c0 > $DCC_PATH/config
	echo 0x254a00c4 > $DCC_PATH/config
	echo 0x254a00cc > $DCC_PATH/config
	echo 0x254a00d0 > $DCC_PATH/config
	echo 0x254a00d4 > $DCC_PATH/config
	echo 0x254a00d8 > $DCC_PATH/config
	echo 0x254a00e0 > $DCC_PATH/config
	echo 0x254a00e8 > $DCC_PATH/config
	echo 0x254a00f0 > $DCC_PATH/config
	echo 0x254a00f0 > $DCC_PATH/config
	echo 0x254a0100 > $DCC_PATH/config
	echo 0x254a0108 > $DCC_PATH/config
	echo 0x254a0110 > $DCC_PATH/config
	echo 0x254a0118 > $DCC_PATH/config
	echo 0x254a0120 > $DCC_PATH/config
	echo 0x254a0128 > $DCC_PATH/config
	echo 0x254a1010 > $DCC_PATH/config
	echo 0x254a1070 > $DCC_PATH/config
	echo 0x254a3004 > $DCC_PATH/config
	echo 0x252a002c > $DCC_PATH/config
	echo 0x252a009c > $DCC_PATH/config
	echo 0x252a00a0 > $DCC_PATH/config
	echo 0x252a00a8 > $DCC_PATH/config
	echo 0x252a00ac > $DCC_PATH/config
	echo 0x252a00b0 > $DCC_PATH/config
	echo 0x252a00b8 > $DCC_PATH/config
	echo 0x252a00c0 > $DCC_PATH/config
	echo 0x252a00c4 > $DCC_PATH/config
	echo 0x252a00cc > $DCC_PATH/config
	echo 0x252a00d0 > $DCC_PATH/config
	echo 0x252a00d4 > $DCC_PATH/config
	echo 0x252a00d8 > $DCC_PATH/config
	echo 0x252a00e0 > $DCC_PATH/config
	echo 0x252a00e8 > $DCC_PATH/config
	echo 0x252a00f0 > $DCC_PATH/config
	echo 0x252a00f0 > $DCC_PATH/config
	echo 0x252a0100 > $DCC_PATH/config
	echo 0x252a0108 > $DCC_PATH/config
	echo 0x252a0110 > $DCC_PATH/config
	echo 0x252a0118 > $DCC_PATH/config
	echo 0x252a0120 > $DCC_PATH/config
	echo 0x252a0128 > $DCC_PATH/config
	echo 0x252a1010 > $DCC_PATH/config
	echo 0x252a1070 > $DCC_PATH/config
	echo 0x252a3004 > $DCC_PATH/config
	echo 0x256a002c > $DCC_PATH/config
	echo 0x256a009c > $DCC_PATH/config
	echo 0x256a00a0 > $DCC_PATH/config
	echo 0x256a00a8 > $DCC_PATH/config
	echo 0x256a00ac > $DCC_PATH/config
	echo 0x256a00b0 > $DCC_PATH/config
	echo 0x256a00b8 > $DCC_PATH/config
	echo 0x256a00c0 > $DCC_PATH/config
	echo 0x256a00c4 > $DCC_PATH/config
	echo 0x256a00cc > $DCC_PATH/config
	echo 0x256a00d0 > $DCC_PATH/config
	echo 0x256a00d4 > $DCC_PATH/config
	echo 0x256a00d8 > $DCC_PATH/config
	echo 0x256a00e0 > $DCC_PATH/config
	echo 0x256a00e8 > $DCC_PATH/config
	echo 0x256a00f0 > $DCC_PATH/config
	echo 0x256a00f0 > $DCC_PATH/config
	echo 0x256a0100 > $DCC_PATH/config
	echo 0x256a0108 > $DCC_PATH/config
	echo 0x256a0110 > $DCC_PATH/config
	echo 0x256a0118 > $DCC_PATH/config
	echo 0x256a0120 > $DCC_PATH/config
	echo 0x256a0128 > $DCC_PATH/config
	echo 0x256a1010 > $DCC_PATH/config
	echo 0x256a1070 > $DCC_PATH/config
	echo 0x256a3004 > $DCC_PATH/config
	echo 0x25076020 > $DCC_PATH/config
	echo 0x25076024 > $DCC_PATH/config
	echo 0x25076028 > $DCC_PATH/config
	echo 0x25076034 > $DCC_PATH/config
	echo 0x25076038 > $DCC_PATH/config
	echo 0x25076040 > $DCC_PATH/config
	echo 0x25076058 > $DCC_PATH/config
	echo 0x25076060 > $DCC_PATH/config
	echo 0x25076064 > $DCC_PATH/config
	echo 0x25076200 > $DCC_PATH/config
	echo 0x25077020 > $DCC_PATH/config
	echo 0x25077030 > $DCC_PATH/config
	echo 0x25077034 > $DCC_PATH/config
	echo 0x25077038 > $DCC_PATH/config
	echo 0x2507703c > $DCC_PATH/config
	echo 0x25077040 > $DCC_PATH/config
	echo 0x25077044 > $DCC_PATH/config
	echo 0x25077048 > $DCC_PATH/config
	echo 0x2507704c > $DCC_PATH/config
	echo 0x25077050 > $DCC_PATH/config
	echo 0x25077054 > $DCC_PATH/config
	echo 0x25077058 > $DCC_PATH/config
	echo 0x2507705c > $DCC_PATH/config
	echo 0x25077060 > $DCC_PATH/config
	echo 0x25077064 > $DCC_PATH/config
	echo 0x25077068 > $DCC_PATH/config
	echo 0x2507706c > $DCC_PATH/config
	echo 0x25077070 > $DCC_PATH/config
	echo 0x25077074 > $DCC_PATH/config
	echo 0x25077078 > $DCC_PATH/config
	echo 0x2507707c > $DCC_PATH/config
	echo 0x25077084 > $DCC_PATH/config
	echo 0x25077090 > $DCC_PATH/config
	echo 0x25077094 > $DCC_PATH/config
	echo 0x25077098 > $DCC_PATH/config
	echo 0x2507709C > $DCC_PATH/config
	echo 0x250770a0 > $DCC_PATH/config
	echo 0x25077218 > $DCC_PATH/config
	echo 0x2507721c > $DCC_PATH/config
	echo 0x25077220 > $DCC_PATH/config
	echo 0x25077224 > $DCC_PATH/config
	echo 0x25077228 > $DCC_PATH/config
	echo 0x2507722c > $DCC_PATH/config
	echo 0x25077230 > $DCC_PATH/config
	echo 0x25077234 > $DCC_PATH/config
	echo 0x25476020 > $DCC_PATH/config
	echo 0x25476024 > $DCC_PATH/config
	echo 0x25476028 > $DCC_PATH/config
	echo 0x25476034 > $DCC_PATH/config
	echo 0x25476038 > $DCC_PATH/config
	echo 0x25476040 > $DCC_PATH/config
	echo 0x25476058 > $DCC_PATH/config
	echo 0x25476060 > $DCC_PATH/config
	echo 0x25476064 > $DCC_PATH/config
	echo 0x25476200 > $DCC_PATH/config
	echo 0x25477020 > $DCC_PATH/config
	echo 0x25477030 > $DCC_PATH/config
	echo 0x25477034 > $DCC_PATH/config
	echo 0x25477038 > $DCC_PATH/config
	echo 0x2547703c > $DCC_PATH/config
	echo 0x25477040 > $DCC_PATH/config
	echo 0x25477044 > $DCC_PATH/config
	echo 0x25477048 > $DCC_PATH/config
	echo 0x2547704c > $DCC_PATH/config
	echo 0x25477050 > $DCC_PATH/config
	echo 0x25477054 > $DCC_PATH/config
	echo 0x25477058 > $DCC_PATH/config
	echo 0x2547705c > $DCC_PATH/config
	echo 0x25477060 > $DCC_PATH/config
	echo 0x25477064 > $DCC_PATH/config
	echo 0x25477068 > $DCC_PATH/config
	echo 0x2547706c > $DCC_PATH/config
	echo 0x25477070 > $DCC_PATH/config
	echo 0x25477074 > $DCC_PATH/config
	echo 0x25477078 > $DCC_PATH/config
	echo 0x2547707c > $DCC_PATH/config
	echo 0x25477084 > $DCC_PATH/config
	echo 0x25477090 > $DCC_PATH/config
	echo 0x25477094 > $DCC_PATH/config
	echo 0x25477098 > $DCC_PATH/config
	echo 0x2547709C > $DCC_PATH/config
	echo 0x254770a0 > $DCC_PATH/config
	echo 0x25477218 > $DCC_PATH/config
	echo 0x2547721c > $DCC_PATH/config
	echo 0x25477220 > $DCC_PATH/config
	echo 0x25477224 > $DCC_PATH/config
	echo 0x25477228 > $DCC_PATH/config
	echo 0x2547722c > $DCC_PATH/config
	echo 0x25477230 > $DCC_PATH/config
	echo 0x25477234 > $DCC_PATH/config
	echo 0x25276020 > $DCC_PATH/config
	echo 0x25276024 > $DCC_PATH/config
	echo 0x25276028 > $DCC_PATH/config
	echo 0x25276034 > $DCC_PATH/config
	echo 0x25276038 > $DCC_PATH/config
	echo 0x25276040 > $DCC_PATH/config
	echo 0x25276058 > $DCC_PATH/config
	echo 0x25276060 > $DCC_PATH/config
	echo 0x25276064 > $DCC_PATH/config
	echo 0x25276200 > $DCC_PATH/config
	echo 0x25277020 > $DCC_PATH/config
	echo 0x25277030 > $DCC_PATH/config
	echo 0x25277034 > $DCC_PATH/config
	echo 0x25277038 > $DCC_PATH/config
	echo 0x2527703c > $DCC_PATH/config
	echo 0x25277040 > $DCC_PATH/config
	echo 0x25277044 > $DCC_PATH/config
	echo 0x25277048 > $DCC_PATH/config
	echo 0x2527704c > $DCC_PATH/config
	echo 0x25277050 > $DCC_PATH/config
	echo 0x25277054 > $DCC_PATH/config
	echo 0x25277058 > $DCC_PATH/config
	echo 0x2527705c > $DCC_PATH/config
	echo 0x25277060 > $DCC_PATH/config
	echo 0x25277064 > $DCC_PATH/config
	echo 0x25277068 > $DCC_PATH/config
	echo 0x2527706c > $DCC_PATH/config
	echo 0x25277070 > $DCC_PATH/config
	echo 0x25277074 > $DCC_PATH/config
	echo 0x25277078 > $DCC_PATH/config
	echo 0x2527707c > $DCC_PATH/config
	echo 0x25277084 > $DCC_PATH/config
	echo 0x25277090 > $DCC_PATH/config
	echo 0x25277094 > $DCC_PATH/config
	echo 0x25277098 > $DCC_PATH/config
	echo 0x2527709C > $DCC_PATH/config
	echo 0x252770a0 > $DCC_PATH/config
	echo 0x25277218 > $DCC_PATH/config
	echo 0x2527721c > $DCC_PATH/config
	echo 0x25277220 > $DCC_PATH/config
	echo 0x25277224 > $DCC_PATH/config
	echo 0x25277228 > $DCC_PATH/config
	echo 0x2527722c > $DCC_PATH/config
	echo 0x25277230 > $DCC_PATH/config
	echo 0x25277234 > $DCC_PATH/config
	echo 0x25676020 > $DCC_PATH/config
	echo 0x25676024 > $DCC_PATH/config
	echo 0x25676028 > $DCC_PATH/config
	echo 0x25676034 > $DCC_PATH/config
	echo 0x25676038 > $DCC_PATH/config
	echo 0x25676040 > $DCC_PATH/config
	echo 0x25676058 > $DCC_PATH/config
	echo 0x25676060 > $DCC_PATH/config
	echo 0x25676064 > $DCC_PATH/config
	echo 0x25676200 > $DCC_PATH/config
	echo 0x25677020 > $DCC_PATH/config
	echo 0x25677030 > $DCC_PATH/config
	echo 0x25677034 > $DCC_PATH/config
	echo 0x25677038 > $DCC_PATH/config
	echo 0x2567703c > $DCC_PATH/config
	echo 0x25677040 > $DCC_PATH/config
	echo 0x25677044 > $DCC_PATH/config
	echo 0x25677048 > $DCC_PATH/config
	echo 0x2567704c > $DCC_PATH/config
	echo 0x25677050 > $DCC_PATH/config
	echo 0x25677054 > $DCC_PATH/config
	echo 0x25677058 > $DCC_PATH/config
	echo 0x2567705c > $DCC_PATH/config
	echo 0x25677060 > $DCC_PATH/config
	echo 0x25677064 > $DCC_PATH/config
	echo 0x25677068 > $DCC_PATH/config
	echo 0x2567706c > $DCC_PATH/config
	echo 0x25677070 > $DCC_PATH/config
	echo 0x25677074 > $DCC_PATH/config
	echo 0x25677078 > $DCC_PATH/config
	echo 0x2567707c > $DCC_PATH/config
	echo 0x25677084 > $DCC_PATH/config
	echo 0x25677090 > $DCC_PATH/config
	echo 0x25677094 > $DCC_PATH/config
	echo 0x25677098 > $DCC_PATH/config
	echo 0x2567709C > $DCC_PATH/config
	echo 0x256770a0 > $DCC_PATH/config
	echo 0x25677218 > $DCC_PATH/config
	echo 0x2567721c > $DCC_PATH/config
	echo 0x25677220 > $DCC_PATH/config
	echo 0x25677224 > $DCC_PATH/config
	echo 0x25677228 > $DCC_PATH/config
	echo 0x2567722c > $DCC_PATH/config
	echo 0x25677230 > $DCC_PATH/config
	echo 0x25677234 > $DCC_PATH/config
	########## > $DCC_PATH/config ###LPI#
	echo 0x250a6008 > $DCC_PATH/config
	echo 0x250a600c > $DCC_PATH/config
	echo 0x250a6010 > $DCC_PATH/config
	echo 0x250a7008 > $DCC_PATH/config
	echo 0x250a700c > $DCC_PATH/config
	echo 0x250a7010 > $DCC_PATH/config
	echo 0x254a6008 > $DCC_PATH/config
	echo 0x254a600c > $DCC_PATH/config
	echo 0x254a6010 > $DCC_PATH/config
	echo 0x254a7008 > $DCC_PATH/config
	echo 0x254a700c > $DCC_PATH/config
	echo 0x254a7010 > $DCC_PATH/config
	echo 0x252a6008 > $DCC_PATH/config
	echo 0x252a600c > $DCC_PATH/config
	echo 0x252a6010 > $DCC_PATH/config
	echo 0x252a7008 > $DCC_PATH/config
	echo 0x252a700c > $DCC_PATH/config
	echo 0x252a7010 > $DCC_PATH/config
	echo 0x256a6008 > $DCC_PATH/config
	echo 0x256a600c > $DCC_PATH/config
	echo 0x256a6010 > $DCC_PATH/config
	echo 0x256a7008 > $DCC_PATH/config
	echo 0x256a700c > $DCC_PATH/config
	echo 0x256a7010 > $DCC_PATH/config
	echo 0x2507718c > $DCC_PATH/config
	echo 0x250771b0 > $DCC_PATH/config
	echo 0x25077204 > $DCC_PATH/config
	echo 0x25077208 > $DCC_PATH/config
	echo 0x2507720c > $DCC_PATH/config
	echo 0x25077210 > $DCC_PATH/config
	echo 0x25077214 > $DCC_PATH/config
	echo 0x25023210 > $DCC_PATH/config
	echo 0x25025010 > $DCC_PATH/config
	echo 0x25025000 > $DCC_PATH/config
	echo 0x25040064 > $DCC_PATH/config
	echo 0x25040070 > $DCC_PATH/config
	echo 0x25040074 > $DCC_PATH/config
	echo 0x25040078 > $DCC_PATH/config
	echo 0x2504007c > $DCC_PATH/config
	echo 0x25040080 > $DCC_PATH/config
	echo 0x2504002c > $DCC_PATH/config
	echo 0x25040030 > $DCC_PATH/config
	echo 0x25040034 > $DCC_PATH/config
	echo 0x25040038 > $DCC_PATH/config
	echo 0x25040048 > $DCC_PATH/config
	echo 0x2504004c > $DCC_PATH/config
	echo 0x25040050 > $DCC_PATH/config
	echo 0x25040054 > $DCC_PATH/config
	echo 0x25040058 > $DCC_PATH/config
	echo 0x25040060 > $DCC_PATH/config
	echo 0x2547718c > $DCC_PATH/config
	echo 0x254771b0 > $DCC_PATH/config
	echo 0x25477204 > $DCC_PATH/config
	echo 0x25477208 > $DCC_PATH/config
	echo 0x2547720c > $DCC_PATH/config
	echo 0x25477210 > $DCC_PATH/config
	echo 0x25477214 > $DCC_PATH/config
	echo 0x25423210 > $DCC_PATH/config
	echo 0x25425010 > $DCC_PATH/config
	echo 0x25425000 > $DCC_PATH/config
	echo 0x25440064 > $DCC_PATH/config
	echo 0x25440070 > $DCC_PATH/config
	echo 0x25440074 > $DCC_PATH/config
	echo 0x25440078 > $DCC_PATH/config
	echo 0x2544007c > $DCC_PATH/config
	echo 0x25440080 > $DCC_PATH/config
	echo 0x2544002c > $DCC_PATH/config
	echo 0x25440030 > $DCC_PATH/config
	echo 0x25440034 > $DCC_PATH/config
	echo 0x25440038 > $DCC_PATH/config
	echo 0x25440048 > $DCC_PATH/config
	echo 0x2544004c > $DCC_PATH/config
	echo 0x25440050 > $DCC_PATH/config
	echo 0x25440054 > $DCC_PATH/config
	echo 0x25440058 > $DCC_PATH/config
	echo 0x25440060 > $DCC_PATH/config
	echo 0x2527718c > $DCC_PATH/config
	echo 0x252771b0 > $DCC_PATH/config
	echo 0x25277204 > $DCC_PATH/config
	echo 0x25277208 > $DCC_PATH/config
	echo 0x2527720c > $DCC_PATH/config
	echo 0x25277210 > $DCC_PATH/config
	echo 0x25277214 > $DCC_PATH/config
	echo 0x25223210 > $DCC_PATH/config
	echo 0x25225010 > $DCC_PATH/config
	echo 0x25225000 > $DCC_PATH/config
	echo 0x25240064 > $DCC_PATH/config
	echo 0x25240070 > $DCC_PATH/config
	echo 0x25240074 > $DCC_PATH/config
	echo 0x25240078 > $DCC_PATH/config
	echo 0x2524007c > $DCC_PATH/config
	echo 0x25240080 > $DCC_PATH/config
	echo 0x2524002c > $DCC_PATH/config
	echo 0x25240030 > $DCC_PATH/config
	echo 0x25240034 > $DCC_PATH/config
	echo 0x25240038 > $DCC_PATH/config
	echo 0x25240048 > $DCC_PATH/config
	echo 0x2524004c > $DCC_PATH/config
	echo 0x25240050 > $DCC_PATH/config
	echo 0x25240054 > $DCC_PATH/config
	echo 0x25240058 > $DCC_PATH/config
	echo 0x25240060 > $DCC_PATH/config
	echo 0x2567718c > $DCC_PATH/config
	echo 0x256771b0 > $DCC_PATH/config
	echo 0x25677204 > $DCC_PATH/config
	echo 0x25677208 > $DCC_PATH/config
	echo 0x2567720c > $DCC_PATH/config
	echo 0x25677210 > $DCC_PATH/config
	echo 0x25677214 > $DCC_PATH/config
	echo 0x25623210 > $DCC_PATH/config
	echo 0x25625010 > $DCC_PATH/config
	echo 0x25625000 > $DCC_PATH/config
	echo 0x25640064 > $DCC_PATH/config
	echo 0x25640070 > $DCC_PATH/config
	echo 0x25640074 > $DCC_PATH/config
	echo 0x25640078 > $DCC_PATH/config
	echo 0x2564007c > $DCC_PATH/config
	echo 0x25640080 > $DCC_PATH/config
	echo 0x2564002c > $DCC_PATH/config
	echo 0x25640030 > $DCC_PATH/config
	echo 0x25640034 > $DCC_PATH/config
	echo 0x25640038 > $DCC_PATH/config
	echo 0x25640048 > $DCC_PATH/config
	echo 0x2564004c > $DCC_PATH/config
	echo 0x25640050 > $DCC_PATH/config
	echo 0x25640054 > $DCC_PATH/config
	echo 0x25640058 > $DCC_PATH/config
	echo 0x25640060 > $DCC_PATH/config
		########## > $DCC_PATH/config ####DARE######################
	echo 0x250a9004 > $DCC_PATH/config
	echo 0x250a9010 > $DCC_PATH/config
	echo 0x250a9014 > $DCC_PATH/config
	echo 0x250a9018 > $DCC_PATH/config
	echo 0x250a9020 > $DCC_PATH/config
	echo 0x250a9024 > $DCC_PATH/config
	echo 0x250a9028 > $DCC_PATH/config
	echo 0x250a9030 > $DCC_PATH/config
	echo 0x250a9034 > $DCC_PATH/config
	echo 0x250a9038 > $DCC_PATH/config
	echo 0x250a9040 > $DCC_PATH/config
	echo 0x250a9044 > $DCC_PATH/config
	echo 0x250a9048 > $DCC_PATH/config
	echo 0x250a9050 > $DCC_PATH/config
	echo 0x250a9054 > $DCC_PATH/config
	echo 0x250a9058 > $DCC_PATH/config
	echo 0x250aa004 > $DCC_PATH/config
	echo 0x250aa010 > $DCC_PATH/config
	echo 0x250aa014 > $DCC_PATH/config
	echo 0x250aa018 > $DCC_PATH/config
	echo 0x250aa020 > $DCC_PATH/config
	echo 0x250aa024 > $DCC_PATH/config
	echo 0x250aa028 > $DCC_PATH/config
	echo 0x250aa030 > $DCC_PATH/config
	echo 0x250aa034 > $DCC_PATH/config
	echo 0x250aa038 > $DCC_PATH/config
	echo 0x250aa040 > $DCC_PATH/config
	echo 0x250aa044 > $DCC_PATH/config
	echo 0x250aa048 > $DCC_PATH/config
	echo 0x250aa050 > $DCC_PATH/config
	echo 0x250aa054 > $DCC_PATH/config
	echo 0x250aa058 > $DCC_PATH/config
	echo 0x250b001c > $DCC_PATH/config
	echo 0x250b101c > $DCC_PATH/config
	echo 0x250b201c > $DCC_PATH/config
	echo 0x250b301c > $DCC_PATH/config
	echo 0x250b401c > $DCC_PATH/config
	echo 0x250b501c > $DCC_PATH/config
	echo 0x250b601c > $DCC_PATH/config
	echo 0x250b701c > $DCC_PATH/config
	echo 0x250b801c > $DCC_PATH/config
	echo 0x250b901c > $DCC_PATH/config
	echo 0x250ba01c > $DCC_PATH/config
	echo 0x250bb01c > $DCC_PATH/config
	echo 0x250bc01c > $DCC_PATH/config
	echo 0x250bd01c > $DCC_PATH/config
	echo 0x250be01c > $DCC_PATH/config
	echo 0x250bf01c > $DCC_PATH/config
	echo 0x254a9004 > $DCC_PATH/config
	echo 0x254a9010 > $DCC_PATH/config
	echo 0x254a9014 > $DCC_PATH/config
	echo 0x254a9018 > $DCC_PATH/config
	echo 0x254a9020 > $DCC_PATH/config
	echo 0x254a9024 > $DCC_PATH/config
	echo 0x254a9028 > $DCC_PATH/config
	echo 0x254a9030 > $DCC_PATH/config
	echo 0x254a9034 > $DCC_PATH/config
	echo 0x254a9038 > $DCC_PATH/config
	echo 0x254a9040 > $DCC_PATH/config
	echo 0x254a9044 > $DCC_PATH/config
	echo 0x254a9048 > $DCC_PATH/config
	echo 0x254a9050 > $DCC_PATH/config
	echo 0x254a9054 > $DCC_PATH/config
	echo 0x254a9058 > $DCC_PATH/config
	echo 0x254aa004 > $DCC_PATH/config
	echo 0x254aa010 > $DCC_PATH/config
	echo 0x254aa014 > $DCC_PATH/config
	echo 0x254aa018 > $DCC_PATH/config
	echo 0x254aa020 > $DCC_PATH/config
	echo 0x254aa024 > $DCC_PATH/config
	echo 0x254aa028 > $DCC_PATH/config
	echo 0x254aa030 > $DCC_PATH/config
	echo 0x254aa034 > $DCC_PATH/config
	echo 0x254aa038 > $DCC_PATH/config
	echo 0x254aa040 > $DCC_PATH/config
	echo 0x254aa044 > $DCC_PATH/config
	echo 0x254aa048 > $DCC_PATH/config
	echo 0x254aa050 > $DCC_PATH/config
	echo 0x254aa054 > $DCC_PATH/config
	echo 0x254aa058 > $DCC_PATH/config
	echo 0x254b001c > $DCC_PATH/config
	echo 0x254b101c > $DCC_PATH/config
	echo 0x254b201c > $DCC_PATH/config
	echo 0x254b301c > $DCC_PATH/config
	echo 0x254b401c > $DCC_PATH/config
	echo 0x254b501c > $DCC_PATH/config
	echo 0x254b601c > $DCC_PATH/config
	echo 0x254b701c > $DCC_PATH/config
	echo 0x254b801c > $DCC_PATH/config
	echo 0x254b901c > $DCC_PATH/config
	echo 0x254ba01c > $DCC_PATH/config
	echo 0x254bb01c > $DCC_PATH/config
	echo 0x254bc01c > $DCC_PATH/config
	echo 0x254bd01c > $DCC_PATH/config
	echo 0x254be01c > $DCC_PATH/config
	echo 0x254bf01c > $DCC_PATH/config
	echo 0x252a9004 > $DCC_PATH/config
	echo 0x252a9010 > $DCC_PATH/config
	echo 0x252a9014 > $DCC_PATH/config
	echo 0x252a9018 > $DCC_PATH/config
	echo 0x252a9020 > $DCC_PATH/config
	echo 0x252a9024 > $DCC_PATH/config
	echo 0x252a9028 > $DCC_PATH/config
	echo 0x252a9030 > $DCC_PATH/config
	echo 0x252a9034 > $DCC_PATH/config
	echo 0x252a9038 > $DCC_PATH/config
	echo 0x252a9040 > $DCC_PATH/config
	echo 0x252a9044 > $DCC_PATH/config
	echo 0x252a9048 > $DCC_PATH/config
	echo 0x252a9050 > $DCC_PATH/config
	echo 0x252a9054 > $DCC_PATH/config
	echo 0x252a9058 > $DCC_PATH/config
	echo 0x252aa004 > $DCC_PATH/config
	echo 0x252aa010 > $DCC_PATH/config
	echo 0x252aa014 > $DCC_PATH/config
	echo 0x252aa018 > $DCC_PATH/config
	echo 0x252aa020 > $DCC_PATH/config
	echo 0x252aa024 > $DCC_PATH/config
	echo 0x252aa028 > $DCC_PATH/config
	echo 0x252aa030 > $DCC_PATH/config
	echo 0x252aa034 > $DCC_PATH/config
	echo 0x252aa038 > $DCC_PATH/config
	echo 0x252aa040 > $DCC_PATH/config
	echo 0x252aa044 > $DCC_PATH/config
	echo 0x252aa048 > $DCC_PATH/config
	echo 0x252aa050 > $DCC_PATH/config
	echo 0x252aa054 > $DCC_PATH/config
	echo 0x252aa058 > $DCC_PATH/config
	echo 0x252b001c > $DCC_PATH/config
	echo 0x252b101c > $DCC_PATH/config
	echo 0x252b201c > $DCC_PATH/config
	echo 0x252b301c > $DCC_PATH/config
	echo 0x252b401c > $DCC_PATH/config
	echo 0x252b501c > $DCC_PATH/config
	echo 0x252b601c > $DCC_PATH/config
	echo 0x252b701c > $DCC_PATH/config
	echo 0x252b801c > $DCC_PATH/config
	echo 0x252b901c > $DCC_PATH/config
	echo 0x252ba01c > $DCC_PATH/config
	echo 0x252bb01c > $DCC_PATH/config
	echo 0x252bc01c > $DCC_PATH/config
	echo 0x252bd01c > $DCC_PATH/config
	echo 0x252be01c > $DCC_PATH/config
	echo 0x252bf01c > $DCC_PATH/config
	echo 0x256a9004 > $DCC_PATH/config
	echo 0x256a9010 > $DCC_PATH/config
	echo 0x256a9014 > $DCC_PATH/config
	echo 0x256a9018 > $DCC_PATH/config
	echo 0x256a9020 > $DCC_PATH/config
	echo 0x256a9024 > $DCC_PATH/config
	echo 0x256a9028 > $DCC_PATH/config
	echo 0x256a9030 > $DCC_PATH/config
	echo 0x256a9034 > $DCC_PATH/config
	echo 0x256a9038 > $DCC_PATH/config
	echo 0x256a9040 > $DCC_PATH/config
	echo 0x256a9044 > $DCC_PATH/config
	echo 0x256a9048 > $DCC_PATH/config
	echo 0x256a9050 > $DCC_PATH/config
	echo 0x256a9054 > $DCC_PATH/config
	echo 0x256a9058 > $DCC_PATH/config
	echo 0x256aa004 > $DCC_PATH/config
	echo 0x256aa010 > $DCC_PATH/config
	echo 0x256aa014 > $DCC_PATH/config
	echo 0x256aa018 > $DCC_PATH/config
	echo 0x256aa020 > $DCC_PATH/config
	echo 0x256aa024 > $DCC_PATH/config
	echo 0x256aa028 > $DCC_PATH/config
	echo 0x256aa030 > $DCC_PATH/config
	echo 0x256aa034 > $DCC_PATH/config
	echo 0x256aa038 > $DCC_PATH/config
	echo 0x256aa040 > $DCC_PATH/config
	echo 0x256aa044 > $DCC_PATH/config
	echo 0x256aa048 > $DCC_PATH/config
	echo 0x256aa050 > $DCC_PATH/config
	echo 0x256aa054 > $DCC_PATH/config
	echo 0x256aa058 > $DCC_PATH/config
	echo 0x256b001c > $DCC_PATH/config
	echo 0x256b101c > $DCC_PATH/config
	echo 0x256b201c > $DCC_PATH/config
	echo 0x256b301c > $DCC_PATH/config
	echo 0x256b401c > $DCC_PATH/config
	echo 0x256b501c > $DCC_PATH/config
	echo 0x256b601c > $DCC_PATH/config
	echo 0x256b701c > $DCC_PATH/config
	echo 0x256b801c > $DCC_PATH/config
	echo 0x256b901c > $DCC_PATH/config
	echo 0x256ba01c > $DCC_PATH/config
	echo 0x256bb01c > $DCC_PATH/config
	echo 0x256bc01c > $DCC_PATH/config
	echo 0x256bd01c > $DCC_PATH/config
	echo 0x256be01c > $DCC_PATH/config
	echo 0x256bf01c > $DCC_PATH/config
	#LLCC_BROADCAST_ORLLCC_LCP_REGION
	echo 0x258a4040 > $DCC_PATH/config
	echo 0x258a4044 > $DCC_PATH/config
	echo 0x258a4048 > $DCC_PATH/config
	echo 0x258a404c > $DCC_PATH/config
	echo 0x258a4050 > $DCC_PATH/config
	echo 0x258a4054 > $DCC_PATH/config
	echo 0x258a4058 > $DCC_PATH/config
	echo 0x258a405c > $DCC_PATH/config
	echo 0x258a4060 > $DCC_PATH/config
	echo 0x258a4064 > $DCC_PATH/config
	echo 0x258a4068 > $DCC_PATH/config
	echo 0x258a406c > $DCC_PATH/config
	echo 0x258a4070 > $DCC_PATH/config
	echo 0x258a4074 > $DCC_PATH/config
	echo 0x258a4078 > $DCC_PATH/config
	echo 0x258a407c > $DCC_PATH/config
	echo 0x258a4080 > $DCC_PATH/config
	echo 0x258a4084 > $DCC_PATH/config
	echo 0x258a4088 > $DCC_PATH/config
	echo 0x258a408c > $DCC_PATH/config
	echo 0x258a4090 > $DCC_PATH/config
	echo 0x258a4094 > $DCC_PATH/config
	echo 0x258a4098 > $DCC_PATH/config
	echo 0x258a409c > $DCC_PATH/config
	echo 0x258a40a0 > $DCC_PATH/config
	echo 0x258a40a4 > $DCC_PATH/config
	echo 0x258a40a8 > $DCC_PATH/config
	echo 0x258a40ac > $DCC_PATH/config
	echo 0x258a40b0 > $DCC_PATH/config
	echo 0x258a40b4 > $DCC_PATH/config
	echo 0x258a40b8 > $DCC_PATH/config
	echo 0x258a40bc > $DCC_PATH/config
	echo 0x258a40c0 > $DCC_PATH/config
	echo 0x258a40c4 > $DCC_PATH/config
	echo 0x258a40c8 > $DCC_PATH/config
	echo 0x258a40cc > $DCC_PATH/config
	echo 0x258a40d0 > $DCC_PATH/config
	echo 0x258a40d4 > $DCC_PATH/config
	echo 0x258a40d8 > $DCC_PATH/config
	echo 0x258a40dc > $DCC_PATH/config
	echo 0x258a40e0 > $DCC_PATH/config
	echo 0x258a40e4 > $DCC_PATH/config
	echo 0x258a40e8 > $DCC_PATH/config
	echo 0x258a40ec > $DCC_PATH/config
	echo 0x258a40f0 > $DCC_PATH/config
	echo 0x258a40f4 > $DCC_PATH/config
	echo 0x258a40f8 > $DCC_PATH/config
	echo 0x258a40fc > $DCC_PATH/config
	echo 0x258b0000 > $DCC_PATH/config
	echo 0x258b1000 > $DCC_PATH/config
	echo 0x258b2000 > $DCC_PATH/config
	echo 0x258b3000 > $DCC_PATH/config
	echo 0x258b4000 > $DCC_PATH/config
	echo 0x258b5000 > $DCC_PATH/config
	echo 0x258b6000 > $DCC_PATH/config
	echo 0x258b7000 > $DCC_PATH/config
	echo 0x258b8000 > $DCC_PATH/config
	echo 0x258b9000 > $DCC_PATH/config
	echo 0x258ba000 > $DCC_PATH/config
	echo 0x258bb000 > $DCC_PATH/config
	echo 0x258bc000 > $DCC_PATH/config
	echo 0x258bd000 > $DCC_PATH/config
	echo 0x258be000 > $DCC_PATH/config
	echo 0x258bf000 > $DCC_PATH/config
	echo 0x258b005c > $DCC_PATH/config
	echo 0x258b105c > $DCC_PATH/config
	echo 0x258b205c > $DCC_PATH/config
	echo 0x258b305c > $DCC_PATH/config
	echo 0x258b405c > $DCC_PATH/config
	echo 0x258b505c > $DCC_PATH/config
	echo 0x258b605c > $DCC_PATH/config
	echo 0x258b705c > $DCC_PATH/config
	echo 0x258b805c > $DCC_PATH/config
	echo 0x258b905c > $DCC_PATH/config
	echo 0x258ba05c > $DCC_PATH/config
	echo 0x258bb05c > $DCC_PATH/config
	echo 0x258bc05c > $DCC_PATH/config
	echo 0x258bd05c > $DCC_PATH/config
	echo 0x258be05c > $DCC_PATH/config
	echo 0x258bf05c > $DCC_PATH/config

    #End Link list #6


}

config_dcc_rpmh()
{
    echo 0xB281024 > $DCC_PATH/config
    echo 0xBDE1034 > $DCC_PATH/config

    #RPMH_PDC_APSS
    echo 0xB201020 2 > $DCC_PATH/config
    echo 0xB211020 2 > $DCC_PATH/config
    echo 0xB221020 2 > $DCC_PATH/config
    echo 0xB231020 2 > $DCC_PATH/config
    echo 0xB204520 > $DCC_PATH/config
}

config_dcc_apss_rscc()
{
    #APSS_RSCC_RSC register
    echo 0x17A00010 > $DCC_PATH/config
    echo 0x17A10010 > $DCC_PATH/config
    echo 0x17A20010 > $DCC_PATH/config
    echo 0x17A30010 > $DCC_PATH/config
    echo 0x17A00030 > $DCC_PATH/config
    echo 0x17A10030 > $DCC_PATH/config
    echo 0x17A20030 > $DCC_PATH/config
    echo 0x17A30030 > $DCC_PATH/config
    echo 0x17A00038 > $DCC_PATH/config
    echo 0x17A10038 > $DCC_PATH/config
    echo 0x17A20038 > $DCC_PATH/config
    echo 0x17A30038 > $DCC_PATH/config
    echo 0x17A00040 > $DCC_PATH/config
    echo 0x17A10040 > $DCC_PATH/config
    echo 0x17A20040 > $DCC_PATH/config
    echo 0x17A30040 > $DCC_PATH/config
    echo 0x17A00048 > $DCC_PATH/config
    echo 0x17A00400 3 > $DCC_PATH/config
    echo 0x17A10400 3 > $DCC_PATH/config
    echo 0x17A20400 3 > $DCC_PATH/config
    echo 0x17A30400 3 > $DCC_PATH/config
}

config_dcc_misc()
{
    #secure WDOG register
    echo 0xC230000 6 > $DCC_PATH/config
}

config_dcc_epss()
{
    #EPSSFAST_SEQ_MEM_r register
    echo 0x17D10200 256 > $DCC_PATH/config
}

config_dcc_gict()
{
    echo 0x17120000  > $DCC_PATH/config
    echo 0x17120008  > $DCC_PATH/config
    echo 0x17120010  > $DCC_PATH/config
    echo 0x17120018  > $DCC_PATH/config
    echo 0x17120020  > $DCC_PATH/config
    echo 0x17120028  > $DCC_PATH/config
    echo 0x17120040  > $DCC_PATH/config
    echo 0x17120048  > $DCC_PATH/config
    echo 0x17120050  > $DCC_PATH/config
    echo 0x17120058  > $DCC_PATH/config
    echo 0x17120060  > $DCC_PATH/config
    echo 0x17120068  > $DCC_PATH/config
    echo 0x17120080  > $DCC_PATH/config
    echo 0x17120088  > $DCC_PATH/config
    echo 0x17120090  > $DCC_PATH/config
    echo 0x17120098  > $DCC_PATH/config
    echo 0x171200a0  > $DCC_PATH/config
    echo 0x171200a8  > $DCC_PATH/config
    echo 0x171200c0  > $DCC_PATH/config
    echo 0x171200c8  > $DCC_PATH/config
    echo 0x171200d0  > $DCC_PATH/config
    echo 0x171200d8  > $DCC_PATH/config
    echo 0x171200e0  > $DCC_PATH/config
    echo 0x171200e8  > $DCC_PATH/config
    echo 0x17120100  > $DCC_PATH/config
    echo 0x17120108  > $DCC_PATH/config
    echo 0x17120110  > $DCC_PATH/config
    echo 0x17120118  > $DCC_PATH/config
    echo 0x17120120  > $DCC_PATH/config
    echo 0x17120128  > $DCC_PATH/config
    echo 0x17120140  > $DCC_PATH/config
    echo 0x17120148  > $DCC_PATH/config
    echo 0x17120150  > $DCC_PATH/config
    echo 0x17120158  > $DCC_PATH/config
    echo 0x17120160  > $DCC_PATH/config
    echo 0x17120168  > $DCC_PATH/config
    echo 0x17120180  > $DCC_PATH/config
    echo 0x17120188  > $DCC_PATH/config
    echo 0x17120190  > $DCC_PATH/config
    echo 0x17120198  > $DCC_PATH/config
    echo 0x171201a0  > $DCC_PATH/config
    echo 0x171201a8  > $DCC_PATH/config
    echo 0x171201c0  > $DCC_PATH/config
    echo 0x171201c8  > $DCC_PATH/config
    echo 0x171201d0  > $DCC_PATH/config
    echo 0x171201d8  > $DCC_PATH/config
    echo 0x171201e0  > $DCC_PATH/config
    echo 0x171201e8  > $DCC_PATH/config
    echo 0x17120200  > $DCC_PATH/config
    echo 0x17120208  > $DCC_PATH/config
    echo 0x17120210  > $DCC_PATH/config
    echo 0x17120218  > $DCC_PATH/config
    echo 0x17120220  > $DCC_PATH/config
    echo 0x17120228  > $DCC_PATH/config
    echo 0x17120240  > $DCC_PATH/config
    echo 0x17120248  > $DCC_PATH/config
    echo 0x17120250  > $DCC_PATH/config
    echo 0x17120258  > $DCC_PATH/config
    echo 0x17120260  > $DCC_PATH/config
    echo 0x17120268  > $DCC_PATH/config
    echo 0x17120280  > $DCC_PATH/config
    echo 0x17120288  > $DCC_PATH/config
    echo 0x17120290  > $DCC_PATH/config
    echo 0x17120298  > $DCC_PATH/config
    echo 0x171202a0  > $DCC_PATH/config
    echo 0x171202a8  > $DCC_PATH/config
    echo 0x171202c0  > $DCC_PATH/config
    echo 0x171202c8  > $DCC_PATH/config
    echo 0x171202d0  > $DCC_PATH/config
    echo 0x171202d8  > $DCC_PATH/config
    echo 0x171202e0  > $DCC_PATH/config
    echo 0x171202e8  > $DCC_PATH/config
    echo 0x17120300  > $DCC_PATH/config
    echo 0x17120308  > $DCC_PATH/config
    echo 0x17120310  > $DCC_PATH/config
    echo 0x17120318  > $DCC_PATH/config
    echo 0x17120320  > $DCC_PATH/config
    echo 0x17120328  > $DCC_PATH/config
    echo 0x17120340  > $DCC_PATH/config
    echo 0x17120348  > $DCC_PATH/config
    echo 0x17120350  > $DCC_PATH/config
    echo 0x17120358  > $DCC_PATH/config
    echo 0x17120360  > $DCC_PATH/config
    echo 0x17120368  > $DCC_PATH/config
    echo 0x17120380  > $DCC_PATH/config
    echo 0x17120388  > $DCC_PATH/config
    echo 0x17120390  > $DCC_PATH/config
    echo 0x17120398  > $DCC_PATH/config
    echo 0x171203a0  > $DCC_PATH/config
    echo 0x171203a8  > $DCC_PATH/config
    echo 0x171203c0  > $DCC_PATH/config
    echo 0x171203c8  > $DCC_PATH/config
    echo 0x171203d0  > $DCC_PATH/config
    echo 0x171203d8  > $DCC_PATH/config
    echo 0x171203e0  > $DCC_PATH/config
    echo 0x171203e8  > $DCC_PATH/config
    echo 0x17120400  > $DCC_PATH/config
    echo 0x17120408  > $DCC_PATH/config
    echo 0x17120410  > $DCC_PATH/config
    echo 0x17120418  > $DCC_PATH/config
    echo 0x17120420  > $DCC_PATH/config
    echo 0x17120428  > $DCC_PATH/config
    echo 0x17120440  > $DCC_PATH/config
    echo 0x17120448  > $DCC_PATH/config
    echo 0x17120450  > $DCC_PATH/config
    echo 0x17120458  > $DCC_PATH/config
    echo 0x17120460  > $DCC_PATH/config
    echo 0x17120468  > $DCC_PATH/config
    echo 0x17120480  > $DCC_PATH/config
    echo 0x17120488  > $DCC_PATH/config
    echo 0x17120490  > $DCC_PATH/config
    echo 0x17120498  > $DCC_PATH/config
    echo 0x171204a0  > $DCC_PATH/config
    echo 0x171204a8  > $DCC_PATH/config
    echo 0x171204c0  > $DCC_PATH/config
    echo 0x171204c8  > $DCC_PATH/config
    echo 0x171204d0  > $DCC_PATH/config
    echo 0x171204d8  > $DCC_PATH/config
    echo 0x171204e0  > $DCC_PATH/config
    echo 0x171204e8  > $DCC_PATH/config
    echo 0x17120500  > $DCC_PATH/config
    echo 0x17120508  > $DCC_PATH/config
    echo 0x17120510  > $DCC_PATH/config
    echo 0x17120518  > $DCC_PATH/config
    echo 0x17120520  > $DCC_PATH/config
    echo 0x17120528  > $DCC_PATH/config
    echo 0x17120540  > $DCC_PATH/config
    echo 0x17120548  > $DCC_PATH/config
    echo 0x17120550  > $DCC_PATH/config
    echo 0x17120558  > $DCC_PATH/config
    echo 0x17120560  > $DCC_PATH/config
    echo 0x17120568  > $DCC_PATH/config
    echo 0x17120580  > $DCC_PATH/config
    echo 0x17120588  > $DCC_PATH/config
    echo 0x17120590  > $DCC_PATH/config
    echo 0x17120598  > $DCC_PATH/config
    echo 0x171205a0  > $DCC_PATH/config
    echo 0x171205a8  > $DCC_PATH/config
    echo 0x171205c0  > $DCC_PATH/config
    echo 0x171205c8  > $DCC_PATH/config
    echo 0x171205d0  > $DCC_PATH/config
    echo 0x171205d8  > $DCC_PATH/config
    echo 0x171205e0  > $DCC_PATH/config
    echo 0x171205e8  > $DCC_PATH/config
    echo 0x17120600  > $DCC_PATH/config
    echo 0x17120608  > $DCC_PATH/config
    echo 0x17120610  > $DCC_PATH/config
    echo 0x17120618  > $DCC_PATH/config
    echo 0x17120620  > $DCC_PATH/config
    echo 0x17120628  > $DCC_PATH/config
    echo 0x17120640  > $DCC_PATH/config
    echo 0x17120648  > $DCC_PATH/config
    echo 0x17120650  > $DCC_PATH/config
    echo 0x17120658  > $DCC_PATH/config
    echo 0x17120660  > $DCC_PATH/config
    echo 0x17120668  > $DCC_PATH/config
    echo 0x17120680  > $DCC_PATH/config
    echo 0x17120688  > $DCC_PATH/config
    echo 0x17120690  > $DCC_PATH/config
    echo 0x17120698  > $DCC_PATH/config
    echo 0x171206a0  > $DCC_PATH/config
    echo 0x171206a8  > $DCC_PATH/config
    echo 0x171206c0  > $DCC_PATH/config
    echo 0x171206c8  > $DCC_PATH/config
    echo 0x171206d0  > $DCC_PATH/config
    echo 0x171206d8  > $DCC_PATH/config
    echo 0x171206e0  > $DCC_PATH/config
    echo 0x171206e8  > $DCC_PATH/config
    echo 0x1712e000  > $DCC_PATH/config
}

config_dcc_lpm_pcu()
{
    #PCU -DCC for LPM path
    #  Read only registers
    echo 0x17800010 1 > $DCC_PATH/config
    echo 0x17800024 1 > $DCC_PATH/config
    echo 0x17800038 1 > $DCC_PATH/config
    echo 0x1780003C 1 > $DCC_PATH/config
    echo 0x17800040 1 > $DCC_PATH/config
    echo 0x17800044 1 > $DCC_PATH/config
    echo 0x17800048 1 > $DCC_PATH/config
    echo 0x1780004C 1 > $DCC_PATH/config
    echo 0x17800058 1 > $DCC_PATH/config
    echo 0x1780005C 1 > $DCC_PATH/config
    echo 0x17800060 1 > $DCC_PATH/config
    echo 0x17800064 1 > $DCC_PATH/config
    echo 0x1780006C 1 > $DCC_PATH/config
    echo 0x178000F0 1 > $DCC_PATH/config
    echo 0x178000F4 1 > $DCC_PATH/config

    echo 0x17810010 1 > $DCC_PATH/config
    echo 0x17810024 1 > $DCC_PATH/config
    echo 0x17810038 1 > $DCC_PATH/config
    echo 0x1781003C 1 > $DCC_PATH/config
    echo 0x17810040 1 > $DCC_PATH/config
    echo 0x17810044 1 > $DCC_PATH/config
    echo 0x17810048 1 > $DCC_PATH/config
    echo 0x1781004C 1 > $DCC_PATH/config
    echo 0x17810058 1 > $DCC_PATH/config
    echo 0x1781005C 1 > $DCC_PATH/config
    echo 0x17810060 1 > $DCC_PATH/config
    echo 0x17810064 1 > $DCC_PATH/config
    echo 0x1781006C 1 > $DCC_PATH/config
    echo 0x178100F0 1 > $DCC_PATH/config
    echo 0x178100F4 1 > $DCC_PATH/config

    echo 0x17820010 1 > $DCC_PATH/config
    echo 0x17820024 1 > $DCC_PATH/config
    echo 0x17820038 1 > $DCC_PATH/config
    echo 0x1782003C 1 > $DCC_PATH/config
    echo 0x17820040 1 > $DCC_PATH/config
    echo 0x17820044 1 > $DCC_PATH/config
    echo 0x17820048 1 > $DCC_PATH/config
    echo 0x1782004C 1 > $DCC_PATH/config
    echo 0x17820058 1 > $DCC_PATH/config
    echo 0x1782005C 1 > $DCC_PATH/config
    echo 0x17820060 1 > $DCC_PATH/config
    echo 0x17820064 1 > $DCC_PATH/config
    echo 0x178200F0 1 > $DCC_PATH/config
    echo 0x178200F4 1 > $DCC_PATH/config

    echo 0x17830010 1 > $DCC_PATH/config
    echo 0x17830024 1 > $DCC_PATH/config
    echo 0x17830038 1 > $DCC_PATH/config
    echo 0x1783003C 1 > $DCC_PATH/config
    echo 0x17830040 1 > $DCC_PATH/config
    echo 0x17830044 1 > $DCC_PATH/config
    echo 0x17830048 1 > $DCC_PATH/config
    echo 0x1783004C 1 > $DCC_PATH/config
    echo 0x17830058 1 > $DCC_PATH/config
    echo 0x1783005C 1 > $DCC_PATH/config
    echo 0x17830060 1 > $DCC_PATH/config
    echo 0x17830064 1 > $DCC_PATH/config
    echo 0x178300F0 1 > $DCC_PATH/config
    echo 0x178300F4 1 > $DCC_PATH/config

    echo 0x17840010 1 > $DCC_PATH/config
    echo 0x17840024 1 > $DCC_PATH/config
    echo 0x17840038 1 > $DCC_PATH/config
    echo 0x1784003C 1 > $DCC_PATH/config
    echo 0x17840040 1 > $DCC_PATH/config
    echo 0x17840044 1 > $DCC_PATH/config
    echo 0x17840048 1 > $DCC_PATH/config
    echo 0x1784004C 1 > $DCC_PATH/config
    echo 0x17840058 1 > $DCC_PATH/config
    echo 0x1784005C 1 > $DCC_PATH/config
    echo 0x17840060 1 > $DCC_PATH/config
    echo 0x17840064 1 > $DCC_PATH/config
    echo 0x178400F0 1 > $DCC_PATH/config
    echo 0x178400F4 1 > $DCC_PATH/config

    echo 0x17850010 1 > $DCC_PATH/config
    echo 0x17850024 1 > $DCC_PATH/config
    echo 0x17850038 1 > $DCC_PATH/config
    echo 0x1785003C 1 > $DCC_PATH/config
    echo 0x17850040 1 > $DCC_PATH/config
    echo 0x17850044 1 > $DCC_PATH/config
    echo 0x17850048 1 > $DCC_PATH/config
    echo 0x1785004C 1 > $DCC_PATH/config
    echo 0x17850058 1 > $DCC_PATH/config
    echo 0x1785005C 1 > $DCC_PATH/config
    echo 0x17850060 1 > $DCC_PATH/config
    echo 0x17850064 1 > $DCC_PATH/config
    echo 0x178500F0 1 > $DCC_PATH/config
    echo 0x178500F4 1 > $DCC_PATH/config

    echo 0x17860010 1 > $DCC_PATH/config
    echo 0x17860024 1 > $DCC_PATH/config
    echo 0x17860038 1 > $DCC_PATH/config
    echo 0x1786003C 1 > $DCC_PATH/config
    echo 0x17860040 1 > $DCC_PATH/config
    echo 0x17860044 1 > $DCC_PATH/config
    echo 0x17860048 1 > $DCC_PATH/config
    echo 0x1786004C 1 > $DCC_PATH/config
    echo 0x17860058 1 > $DCC_PATH/config
    echo 0x1786005C 1 > $DCC_PATH/config
    echo 0x17860060 1 > $DCC_PATH/config
    echo 0x17860064 1 > $DCC_PATH/config
    echo 0x178600F0 1 > $DCC_PATH/config
    echo 0x178600F4 1 > $DCC_PATH/config

    echo 0x17870010 1 > $DCC_PATH/config
    echo 0x17870024 1 > $DCC_PATH/config
    echo 0x17870038 1 > $DCC_PATH/config
    echo 0x1787003C 1 > $DCC_PATH/config
    echo 0x17870040 1 > $DCC_PATH/config
    echo 0x17870044 1 > $DCC_PATH/config
    echo 0x17870048 1 > $DCC_PATH/config
    echo 0x1787004C 1 > $DCC_PATH/config
    echo 0x17870058 1 > $DCC_PATH/config
    echo 0x1787005C 1 > $DCC_PATH/config
    echo 0x17870060 1 > $DCC_PATH/config
    echo 0x17870064 1 > $DCC_PATH/config
    echo 0x178700F0 1 > $DCC_PATH/config
    echo 0x178700F4 1 > $DCC_PATH/config

    echo 0x178A0010 1 > $DCC_PATH/config
    echo 0x178A0024 1 > $DCC_PATH/config
    echo 0x178A0038 1 > $DCC_PATH/config
    echo 0x178A003C 1 > $DCC_PATH/config
    echo 0x178A0040 1 > $DCC_PATH/config
    echo 0x178A0044 1 > $DCC_PATH/config
    echo 0x178A0048 1 > $DCC_PATH/config
    echo 0x178A004C 1 > $DCC_PATH/config
    echo 0x178A006C 1 > $DCC_PATH/config
    echo 0x178A0070 1 > $DCC_PATH/config
    echo 0x178A0074 1 > $DCC_PATH/config
    echo 0x178A0078 1 > $DCC_PATH/config
    echo 0x178A007C 1 > $DCC_PATH/config
    echo 0x178A0084 1 > $DCC_PATH/config
    echo 0x178A00F4 1 > $DCC_PATH/config
    echo 0x178A00F8 1 > $DCC_PATH/config
    echo 0x178A00FC 1 > $DCC_PATH/config
    echo 0x178A0100 1 > $DCC_PATH/config
    echo 0x178A0104 1 > $DCC_PATH/config
    echo 0x178A0118 1 > $DCC_PATH/config
    echo 0x178A011C 1 > $DCC_PATH/config
    echo 0x178A0120 1 > $DCC_PATH/config
    echo 0x178A0124 1 > $DCC_PATH/config
    echo 0x178A0128 1 > $DCC_PATH/config
    echo 0x178A012C 1 > $DCC_PATH/config
    echo 0x178A0130 1 > $DCC_PATH/config
    echo 0x178A0134 1 > $DCC_PATH/config
    echo 0x178A0138 1 > $DCC_PATH/config
    echo 0x178A0158 1 > $DCC_PATH/config
    echo 0x178A015C 1 > $DCC_PATH/config
    echo 0x178A0160 1 > $DCC_PATH/config
    echo 0x178A0164 1 > $DCC_PATH/config
    echo 0x178A0168 1 > $DCC_PATH/config
    echo 0x178A0170 1 > $DCC_PATH/config
    echo 0x178A0174 1 > $DCC_PATH/config
    echo 0x178A0188 1 > $DCC_PATH/config
    echo 0x178A018C 1 > $DCC_PATH/config
    echo 0x178A0190 1 > $DCC_PATH/config
    echo 0x178A0194 1 > $DCC_PATH/config
    echo 0x178A0198 1 > $DCC_PATH/config
    echo 0x178A01AC 1 > $DCC_PATH/config
    echo 0x178A01B0 1 > $DCC_PATH/config
    echo 0x178A01B4 1 > $DCC_PATH/config
    echo 0x178A01B8 1 > $DCC_PATH/config
    echo 0x178A01BC 1 > $DCC_PATH/config
    echo 0x178A01C0 1 > $DCC_PATH/config
    echo 0x178A01C8 1 > $DCC_PATH/config

    echo 0x17880010 1 > $DCC_PATH/config
    echo 0x17880024 1 > $DCC_PATH/config
    echo 0x17880038 1 > $DCC_PATH/config
    echo 0x1788003C 1 > $DCC_PATH/config
    echo 0x17880040 1 > $DCC_PATH/config
    echo 0x17880044 1 > $DCC_PATH/config
    echo 0x17880048 1 > $DCC_PATH/config
    echo 0x1788004C 1 > $DCC_PATH/config

    echo 0x17890010 1 > $DCC_PATH/config
    echo 0x17890024 1 > $DCC_PATH/config
    echo 0x17890038 1 > $DCC_PATH/config
    echo 0x1789003C 1 > $DCC_PATH/config
    echo 0x17890040 1 > $DCC_PATH/config
    echo 0x17890044 1 > $DCC_PATH/config
    echo 0x17890048 1 > $DCC_PATH/config
    echo 0x1789004C 1 > $DCC_PATH/config

    # echo 0x18598020 1 > $DCC_PATH/config

    # echo 0x1859001C 1 > $DCC_PATH/config
    # echo 0x18590020 1 > $DCC_PATH/config
    # echo 0x18590064 1 > $DCC_PATH/config
    # echo 0x18590068 1 > $DCC_PATH/config
    # echo 0x1859006C 1 > $DCC_PATH/config
    # echo 0x18590070 1 > $DCC_PATH/config
    # echo 0x18590074 1 > $DCC_PATH/config
    # echo 0x18590078 1 > $DCC_PATH/config
    # echo 0x1859008C 1 > $DCC_PATH/config
    # echo 0x185900DC 1 > $DCC_PATH/config
    # echo 0x185900E8 1 > $DCC_PATH/config
    # echo 0x185900EC 1 > $DCC_PATH/config
    # echo 0x185900F0 1 > $DCC_PATH/config
    # echo 0x18590300 1 > $DCC_PATH/config
    # echo 0x1859030C 1 > $DCC_PATH/config
    # echo 0x18590320 1 > $DCC_PATH/config
    # echo 0x1859034C 1 > $DCC_PATH/config
    # echo 0x185903BC 1 > $DCC_PATH/config
    # echo 0x185903C0 1 > $DCC_PATH/config

    # echo 0x1859101C 1 > $DCC_PATH/config
    # echo 0x18591020 1 > $DCC_PATH/config
    # echo 0x18591064 1 > $DCC_PATH/config
    # echo 0x18591068 1 > $DCC_PATH/config
    # echo 0x1859106C 1 > $DCC_PATH/config
    # echo 0x18591070 1 > $DCC_PATH/config
    # echo 0x18591074 1 > $DCC_PATH/config
    # echo 0x18591078 1 > $DCC_PATH/config
    # echo 0x1859108C 1 > $DCC_PATH/config
    # echo 0x185910DC 1 > $DCC_PATH/config
    # echo 0x185910E8 1 > $DCC_PATH/config
    # echo 0x185910EC 1 > $DCC_PATH/config
    # echo 0x185910F0 1 > $DCC_PATH/config
    # echo 0x18591300 1 > $DCC_PATH/config
    # echo 0x1859130C 1 > $DCC_PATH/config
    # echo 0x18591320 1 > $DCC_PATH/config
    # echo 0x1859134C 1 > $DCC_PATH/config
    # echo 0x185913BC 1 > $DCC_PATH/config
    # echo 0x185913C0 1 > $DCC_PATH/config

    # echo 0x1859201C 1 > $DCC_PATH/config
    # echo 0x18592020 1 > $DCC_PATH/config
    # echo 0x18592064 1 > $DCC_PATH/config
    # echo 0x18592068 1 > $DCC_PATH/config
    # echo 0x1859206C 1 > $DCC_PATH/config
    # echo 0x18592070 1 > $DCC_PATH/config
    # echo 0x18592074 1 > $DCC_PATH/config
    # echo 0x18592078 1 > $DCC_PATH/config
    # echo 0x1859208C 1 > $DCC_PATH/config
    # echo 0x185920DC 1 > $DCC_PATH/config
    # echo 0x185920E8 1 > $DCC_PATH/config
    # echo 0x185920EC 1 > $DCC_PATH/config
    # echo 0x185920F0 1 > $DCC_PATH/config
    # echo 0x18592300 1 > $DCC_PATH/config
    # echo 0x1859230C 1 > $DCC_PATH/config
    # echo 0x18592320 1 > $DCC_PATH/config
    # echo 0x1859234C 1 > $DCC_PATH/config
    # echo 0x185923BC 1 > $DCC_PATH/config
    # echo 0x185923C0 1 > $DCC_PATH/config

    # echo 0x1859301C 1 > $DCC_PATH/config
    # echo 0x18593020 1 > $DCC_PATH/config
    # echo 0x18593064 1 > $DCC_PATH/config
    # echo 0x18593068 1 > $DCC_PATH/config
    # echo 0x1859306C 1 > $DCC_PATH/config
    # echo 0x18593070 1 > $DCC_PATH/config
    # echo 0x18593074 1 > $DCC_PATH/config
    # echo 0x18593078 1 > $DCC_PATH/config
    # echo 0x1859308C 1 > $DCC_PATH/config
    # echo 0x185930DC 1 > $DCC_PATH/config
    # echo 0x185930E8 1 > $DCC_PATH/config
    # echo 0x185930EC 1 > $DCC_PATH/config
    # echo 0x185930F0 1 > $DCC_PATH/config
    # echo 0x18593300 1 > $DCC_PATH/config
    # echo 0x1859330C 1 > $DCC_PATH/config
    # echo 0x18593320 1 > $DCC_PATH/config
    # echo 0x1859334C 1 > $DCC_PATH/config
    # echo 0x185933BC 1 > $DCC_PATH/config
    # echo 0x185933C0 1 > $DCC_PATH/config

    # echo 0x18300000 1 > $DCC_PATH/config
    # echo 0x1830000C 1 > $DCC_PATH/config
    # echo 0x18300018 1 > $DCC_PATH/config

    # echo 0x17C21000 1 > $DCC_PATH/config
    # echo 0x17C21004 1 > $DCC_PATH/config

    # echo 0x18393A84 1 > $DCC_PATH/config
    # echo 0x18393A88 1 > $DCC_PATH/config

    # echo 0x183A3A84 1 > $DCC_PATH/config
    # echo 0x183A3A88 1 > $DCC_PATH/config
}
config_dcc_lpm()
{
    #PPU PWPR/PWSR/DISR register
    echo 0x178A0204  > $DCC_PATH/config
    echo 0x178A0244  > $DCC_PATH/config
    echo 0x17E30000  > $DCC_PATH/config
    echo 0x17E30008  > $DCC_PATH/config
    echo 0x17E30010  > $DCC_PATH/config
    echo 0x17E80000  > $DCC_PATH/config
    echo 0x17E80008  > $DCC_PATH/config
    echo 0x17E80010  > $DCC_PATH/config
    echo 0x17F80000  > $DCC_PATH/config
    echo 0x17F80008  > $DCC_PATH/config
    echo 0x17F80010  > $DCC_PATH/config
    echo 0x18080000  > $DCC_PATH/config
    echo 0x18080008  > $DCC_PATH/config
    echo 0x18080010  > $DCC_PATH/config
    echo 0x18180000  > $DCC_PATH/config
    echo 0x18180008  > $DCC_PATH/config
    echo 0x18180010  > $DCC_PATH/config
    echo 0x18280000  > $DCC_PATH/config
    echo 0x18280008  > $DCC_PATH/config
    echo 0x18280010  > $DCC_PATH/config
    echo 0x18380000  > $DCC_PATH/config
    echo 0x18380008  > $DCC_PATH/config
    echo 0x18380010  > $DCC_PATH/config
    echo 0x18480000  > $DCC_PATH/config
    echo 0x18480008  > $DCC_PATH/config
    echo 0x18480010  > $DCC_PATH/config
    echo 0x18580000  > $DCC_PATH/config
    echo 0x18580008  > $DCC_PATH/config
    echo 0x18580010  > $DCC_PATH/config
}
config_dcc_core()
{
    # core hang
    echo 0x1780005C 1 > $DCC_PATH/config
    echo 0x1781005C 1 > $DCC_PATH/config
    echo 0x1782005C 1 > $DCC_PATH/config
    echo 0x1783005C 1 > $DCC_PATH/config
    echo 0x1784005C 1 > $DCC_PATH/config
    echo 0x1785005C 1 > $DCC_PATH/config
    echo 0x1786005C 1 > $DCC_PATH/config
    echo 0x1787005C 1 > $DCC_PATH/config
    echo 0x1740003C 1 > $DCC_PATH/config

    #MIBU Debug registers
    echo 0x17600238 1 > $DCC_PATH/config
    echo 0x17600240 11 > $DCC_PATH/config
    echo 0x17600530 > $DCC_PATH/config
    echo 0x1760051C > $DCC_PATH/config
    echo 0x17600524 > $DCC_PATH/config
    echo 0x1760052C > $DCC_PATH/config
    echo 0x17600518 > $DCC_PATH/config
    echo 0x17600520 > $DCC_PATH/config
    echo 0x17600528 > $DCC_PATH/config

    #CHI (GNOC) Hang counters
    echo 0x17600404 3 > $DCC_PATH/config
    echo 0x1760041C 3 > $DCC_PATH/config
    echo 0x17600434 1 > $DCC_PATH/config
    echo 0x1760043C 1 > $DCC_PATH/config
    echo 0x17600440 1 > $DCC_PATH/config

    #SYSCO and other misc debug
    echo 0x17400438 1 > $DCC_PATH/config
    echo 0x17600044 1 > $DCC_PATH/config
    echo 0x17600500 1 > $DCC_PATH/config

    #PPUHWSTAT_STS
    echo 0x17600504 5 > $DCC_PATH/config

    #CPRh
    echo 0x17900908 1 > $DCC_PATH/config
    echo 0x17900C18 1 > $DCC_PATH/config
    echo 0x17901908 1 > $DCC_PATH/config
    echo 0x17901C18 1 > $DCC_PATH/config

    echo 0x17B90810 1 > $DCC_PATH/config
    echo 0x17B90C50 1 > $DCC_PATH/config
    echo 0x17B90814 1 > $DCC_PATH/config
    echo 0x17B90C54 1 > $DCC_PATH/config
    echo 0x17B90818 1 > $DCC_PATH/config
    echo 0x17B90C58 1 > $DCC_PATH/config
    echo 0x17B93A04 2 > $DCC_PATH/config
    echo 0x17BA0810 1 > $DCC_PATH/config
    echo 0x17BA0C50 1 > $DCC_PATH/config
    echo 0x17BA0814 1 > $DCC_PATH/config
    echo 0x17BA0C54 1 > $DCC_PATH/config
    echo 0x17BA0818 1 > $DCC_PATH/config
    echo 0x17BA0C58 1 > $DCC_PATH/config
    echo 0x17BA3A04 2 > $DCC_PATH/config

    echo 0x17B93000 80 > $DCC_PATH/config
    echo 0x17BA3000 80 > $DCC_PATH/config

    #rpmh
    echo 0x0C201244 1 > $DCC_PATH/config
    echo 0x0C202244 1 > $DCC_PATH/config
    echo 0x17B00000 1 > $DCC_PATH/config

    #L3-ACD
    echo 0x17A94030 1 > $DCC_PATH/config
    echo 0x17A9408C 1 > $DCC_PATH/config
    echo 0x17A9409C 0x78 > $DCC_PATH/config_write
    echo 0x17A9409C 0x0  > $DCC_PATH/config_write
    echo 0x17A94048 0x1  > $DCC_PATH/config_write
    echo 0x17A94090 0x0  > $DCC_PATH/config_write
    echo 0x17A94090 0x25 > $DCC_PATH/config_write
    echo 0x17A94098 1 > $DCC_PATH/config
    echo 0x17A94048 0x1D > $DCC_PATH/config_write
    echo 0x17A94090 0x0  > $DCC_PATH/config_write
    echo 0x17A94090 0x25 > $DCC_PATH/config_write
    echo 0x17A94098 1 > $DCC_PATH/config

    #SILVER-ACD
    echo 0x17A90030 1 > $DCC_PATH/config
    echo 0x17A9008C 1 > $DCC_PATH/config
    echo 0x17A9009C 0x78 > $DCC_PATH/config_write
    echo 0x17A9009C 0x0  > $DCC_PATH/config_write
    echo 0x17A90048 0x1  > $DCC_PATH/config_write
    echo 0x17A90090 0x0  > $DCC_PATH/config_write
    echo 0x17A90090 0x25 > $DCC_PATH/config_write
    echo 0x17A90098 1 > $DCC_PATH/config
    echo 0x17A90048 0x1D > $DCC_PATH/config_write
    echo 0x17A90090 0x0  > $DCC_PATH/config_write
    echo 0x17A90090 0x25 > $DCC_PATH/config_write
    echo 0x17A90098 1 > $DCC_PATH/config


    #GOLD-ACD
    echo 0x17A92030 1 > $DCC_PATH/config
    echo 0x17A9208C 1 > $DCC_PATH/config
    echo 0x17A9209C 0x78 > $DCC_PATH/config_write
    echo 0x17A9209C 0x0  > $DCC_PATH/config_write
    echo 0x17A92048 0x1  > $DCC_PATH/config_write
    echo 0x17A92090 0x0  > $DCC_PATH/config_write
    echo 0x17A92090 0x25 > $DCC_PATH/config_write
    echo 0x17A92098 1 > $DCC_PATH/config
    echo 0x17A92048 0x1D > $DCC_PATH/config_write
    echo 0x17A92090 0x0  > $DCC_PATH/config_write
    echo 0x17A92090 0x25 > $DCC_PATH/config_write
    echo 0x17A92098 1 > $DCC_PATH/config

    #GOLDPLUS-ACD
    echo 0x17A96030 1 > $DCC_PATH/config
    echo 0x17A9608C 1 > $DCC_PATH/config
    echo 0x17A9609C 0x78 > $DCC_PATH/config_write
    echo 0x17A9609C 0x0  > $DCC_PATH/config_write
    echo 0x17A96048 0x1  > $DCC_PATH/config_write
    echo 0x17A96090 0x0  > $DCC_PATH/config_write
    echo 0x17A96090 0x25 > $DCC_PATH/config_write
    echo 0x17A96098 1 > $DCC_PATH/config
    echo 0x17A96048 0x1D > $DCC_PATH/config_write
    echo 0x17A96090 0x0  > $DCC_PATH/config_write
    echo 0x17A96090 0x25 > $DCC_PATH/config_write
    echo 0x17A96098 1 > $DCC_PATH/config

    echo 0x17D98024 1 > $DCC_PATH/config
    echo 0x13822000 1 > $DCC_PATH/config

    #Security Control Core for Binning info
    echo 0x221C20A4 1 > $DCC_PATH/config

    #SoC version
    echo 0x01FC8000 1 > $DCC_PATH/config

    #WDOG BIT Config
    echo 0x17400038 1 > $DCC_PATH/config

    #Curr Freq
    echo 0x17D91020 > $DCC_PATH/config
    echo 0x17D92020 > $DCC_PATH/config
    echo 0x17D93020 > $DCC_PATH/config
    echo 0x17D90020 > $DCC_PATH/config

    #OSM Seq curr addr
    echo 0x17D9134C > $DCC_PATH/config
    echo 0x17D9234C > $DCC_PATH/config
    echo 0x17D9334C > $DCC_PATH/config
    echo 0x17D9034C > $DCC_PATH/config

    #DCVS_IN_PROGRESS
    echo 0x17D91300 > $DCC_PATH/config
    echo 0x17D92300 > $DCC_PATH/config
    echo 0x17D93300 > $DCC_PATH/config
    echo 0x17D90300 > $DCC_PATH/config
}

config_dcc_gic()
{
    echo 0x17100104 29 > $DCC_PATH/config
    echo 0x17100204 29 > $DCC_PATH/config
    echo 0x17100384 29 > $DCC_PATH/config
    echo 0x178A0250 > $DCC_PATH/config
    echo 0x178A0254 > $DCC_PATH/config
    echo 0x178A025C > $DCC_PATH/config
}

config_adsp()
{
    echo 0x32302028 1 > $DCC_PATH/config
    echo 0x320A4404 1 > $DCC_PATH/config
    echo 0x320A4408 1 > $DCC_PATH/config
    echo 0x323B0404 1 > $DCC_PATH/config
    echo 0x323B0408 1 > $DCC_PATH/config
    #echo 0xB2B1020 1 > $DCC_PATH/config
    #echo 0xB2B1024 1 > $DCC_PATH/config
}

enable_dcc_pll_status()
{
   #TODO: need to be updated

}

config_dcc_tsens()
{
    echo 0x0C222004 1 > $DCC_PATH/config
    echo 0x0C271014 1 > $DCC_PATH/config
    echo 0x0C2710E0 1 > $DCC_PATH/config
    echo 0x0C2710EC 1 > $DCC_PATH/config
    echo 0x0C2710A0 16 > $DCC_PATH/config
    echo 0x0C2710E8 1 > $DCC_PATH/config
    echo 0x0C27113C 1 > $DCC_PATH/config
    echo 0x0C223004 1 > $DCC_PATH/config
    echo 0x0C272014 1 > $DCC_PATH/config
    echo 0x0C2720E0 1 > $DCC_PATH/config
    echo 0x0C2720EC 1 > $DCC_PATH/config
    echo 0x0C2720A0 16 > $DCC_PATH/config
    echo 0x0C2720E8 1 > $DCC_PATH/config
    echo 0x0C27213C 1 > $DCC_PATH/config
    echo 0x0C224004 1 > $DCC_PATH/config
    echo 0x0C273014 1 > $DCC_PATH/config
    echo 0x0C2730E0 1 > $DCC_PATH/config
    echo 0x0C2730EC 1 > $DCC_PATH/config
    echo 0x0C2730A0 16 > $DCC_PATH/config
    echo 0x0C2730E8 1 > $DCC_PATH/config
    echo 0x0C27313C 1 > $DCC_PATH/config
}

config_smmu()
{
    echo 0x15002204 1 > $DCC_PATH/config  #APPS_SMMU_TBU_PWR_STATUS
    #SMMU_500_APPS_REG_WRAPPER_BASE=0x151CC000
    #ANOC_1

    echo 0x1A000C 1 > $DCC_PATH/config #GCC_AGGRE_NOC_TBU1_CBCR
    echo 0x1A0010 1 > $DCC_PATH/config # GCC_AGGRE_NOC_TBU1_SREGR

    #let "APPS_SMMU_DEBUG_TESTBUS_SEL_ANOC_1_SEC = $SMMU_500_APPS_REG_WRAPPER_BASE+0x4050 = 0x151D0050"
    #let "APPS_SMMU_DEBUG_TESTBUS_ANOC_1_SEC = $SMMU_500_APPS_REG_WRAPPER_BASE+0x4058 = 0x151D0058"

    echo 0x151D0050 0x40 > $DCC_PATH/config_write #APPS_SMMU_DEBUG_TESTBUS_SEL_ANOC_1_SEC
    echo 0x151D0058 1 > $DCC_PATH/config #APPS_SMMU_DEBUG_TESTBUS_ANOC_1_SEC

    echo 0x151D0050 0x80 > $DCC_PATH/config_write #APPS_SMMU_DEBUG_TESTBUS_SEL_ANOC_1_SEC
    echo 0x151D0058 1 > $DCC_PATH/config #APPS_SMMU_DEBUG_TESTBUS_ANOC_1_SEC

    echo 0x151D0050 0xC0 > $DCC_PATH/config_write #APPS_SMMU_DEBUG_TESTBUS_SEL_ANOC_1_SEC
    echo 0x151D0058 1 > $DCC_PATH/config #APPS_SMMU_DEBUG_TESTBUS_ANOC_1_SEC

    echo 0x151D0050 0x87 > $DCC_PATH/config_write #APPS_SMMU_DEBUG_TESTBUS_SEL_ANOC_1_SEC
    echo 0x151D0058 1 > $DCC_PATH/config #APPS_SMMU_DEBUG_TESTBUS_ANOC_1_SEC

    echo 0x151D0050 0xAF > $DCC_PATH/config_write #APPS_SMMU_DEBUG_TESTBUS_SEL_ANOC_1_SEC
    echo 0x151D0058 1 > $DCC_PATH/config #APPS_SMMU_DEBUG_TESTBUS_ANOC_1_SEC

    echo 0x151D0050 0xBC > $DCC_PATH/config_write #APPS_SMMU_DEBUG_TESTBUS_SEL_ANOC_1_SEC
    echo 0x151D0058 1 > $DCC_PATH/config #APPS_SMMU_DEBUG_TESTBUS_ANOC_1_SEC

    #ANOC_2
    #echo 0x19001c 0x1 > $DCC_PATH/config_write
    echo 0x1A0014 1 > $DCC_PATH/config #GCC_AGGRE_NOC_TBU2_CBCR
    echo 0x1A0018 1 > $DCC_PATH/config #GCC_AGGRE_NOC_TBU2_SREGR

    #let "APPS_SMMU_DEBUG_TESTBUS_SEL_ANOC_2_HLOS1_NS = $SMMU_500_APPS_REG_WRAPPER_BASE+0x9050 = 0x151D5050"
    #let "APPS_SMMU_DEBUG_TESTBUS_ANOC_2_HLOS1_NS = $SMMU_500_APPS_REG_WRAPPER_BASE+0x9058 = 0x151D5058"

    echo 0x151D5050 0x40 > $DCC_PATH/config_write
    echo 0x151D5058 1 > $DCC_PATH/config

    echo 0x151D5050 0x80 > $DCC_PATH/config_write
    echo 0x151D5058 1 > $DCC_PATH/config #APPS_SMMU_DEBUG_TESTBUS_ANOC_2_HLOS1_NS
    #echo 0x1518905C 1 > $DCC_PATH/config #APPS_SMMU_DEBUG_TESTBUS_ANOC_2_HLOS1_NS

    echo 0x151D5050 0xC0 > $DCC_PATH/config_write
    echo 0x151D5058 1 > $DCC_PATH/config #APPS_SMMU_DEBUG_TESTBUS_ANOC_2_HLOS1_NS
    #echo 0x1518905C 1 > $DCC_PATH/config #APPS_SMMU_DEBUG_TESTBUS_ANOC_2_HLOS1_NS

    echo 0x151D5050 0x87 > $DCC_PATH/config_write
    echo 0x151D5058 1 > $DCC_PATH/config #APPS_SMMU_DEBUG_TESTBUS_ANOC_2_HLOS1_NS
    #echo 0x1518905C 1 > $DCC_PATH/config #APPS_SMMU_DEBUG_TESTBUS_ANOC_2_HLOS1_NS

    echo 0x151D5050 0xAF > $DCC_PATH/config_write
    echo 0x151D5058 1 > $DCC_PATH/config #APPS_SMMU_DEBUG_TESTBUS_ANOC_2_HLOS1_NS
    #echo 0x1518905C 1 > $DCC_PATH/config #APPS_SMMU_DEBUG_TESTBUS_ANOC_2_HLOS1_NS

    echo 0x151D5050 0xBC > $DCC_PATH/config_write
    echo 0x151D5058 1 > $DCC_PATH/config #APPS_SMMU_DEBUG_TESTBUS_ANOC_2_HLOS1_NS
    #echo 0x1518905C 1 > $DCC_PATH/config #APPS_SMMU_DEBUG_TESTBUS_ANOC_2_HLOS1_NS

    #MNOC_SF_0
    #echo 0x109010 0x1 > $DCC_PATH/config_write
    echo 0x12C018 1 > $DCC_PATH/config #GCC_MMNOC_TBU_SF0_CBCR
    echo 0x12C01C 1 > $DCC_PATH/config #GCC_MMNOC_TBU_SF0_SREGR

    #let "APPS_SMMU_DEBUG_TESTBUS_SEL_MNOC_SF_0_HLOS1_NS = $SMMU_500_APPS_REG_WRAPPER_BASE+0x25050 = 0x151F1050"
    #let "APPS_SMMU_DEBUG_TESTBUS_MNOC_SF_0_HLOS1_NS = $SMMU_500_APPS_REG_WRAPPER_BASE+0x25058 = 0x151F1058"

    echo 0x151F1050 0x40 > $DCC_PATH/config_write #APPS_SMMU_DEBUG_TESTBUS_SEL_MNOC_SF_0_HLOS1_NS(0x151F1050)
    echo 0x151F1058 1 > $DCC_PATH/config #APPS_SMMU_DEBUG_TESTBUS_MNOC_SF_0_HLOS1_NS(0x151F1058)
    #echo 0x151A505C 1 > $DCC_PATH/config #APPS_SMMU_DEBUG_TESTBUS_MNOC_SF_0_HLOS1_NS

    echo 0x151F1050 0x80 > $DCC_PATH/config_write
    echo 0x151F1058 1 > $DCC_PATH/config #APPS_SMMU_DEBUG_TESTBUS_MNOC_SF_0_HLOS1_NS
    #echo 0x151A505C 1 > $DCC_PATH/config #APPS_SMMU_DEBUG_TESTBUS_MNOC_SF_0_HLOS1_NS
    #okay till here

    echo 0x151F1050 0xC0 > $DCC_PATH/config_write
    echo 0x151F1058 1 > $DCC_PATH/config #APPS_SMMU_DEBUG_TESTBUS_MNOC_SF_0_HLOS1_NS
    #echo 0x151A505C 1 > $DCC_PATH/config #APPS_SMMU_DEBUG_TESTBUS_MNOC_SF_0_HLOS1_NS

    echo 0x151F1050 0x87 > $DCC_PATH/config_write
    echo 0x151F1058 1 > $DCC_PATH/config #APPS_SMMU_DEBUG_TESTBUS_MNOC_SF_0_HLOS1_NS
    #echo 0x151A505C 1 > $DCC_PATH/config #APPS_SMMU_DEBUG_TESTBUS_MNOC_SF_0_HLOS1_NS

    echo 0x151F1050 0xAF > $DCC_PATH/config_write
    echo 0x151F1058 1 > $DCC_PATH/config #APPS_SMMU_DEBUG_TESTBUS_MNOC_SF_0_HLOS1_NS
    #echo 0x151A505C 1 > $DCC_PATH/config #APPS_SMMU_DEBUG_TESTBUS_MNOC_SF_0_HLOS1_NS

    echo 0x151F1050 0xBC > $DCC_PATH/config_write
    echo 0x151F1058 1 > $DCC_PATH/config #APPS_SMMU_DEBUG_TESTBUS_MNOC_SF_0_HLOS1_NS
    #echo 0x151A505C 1 > $DCC_PATH/config #APPS_SMMU_DEBUG_TESTBUS_MNOC_SF_0_HLOS1_NS



    #MNOC_SF_1
    #echo 0x109018 0x1 > $DCC_PATH/config_write
    echo 0x12C024 1 > $DCC_PATH/config #GCC_MMNOC_TBU_SF1_SREGR
    echo 0x12C020 1 > $DCC_PATH/config #GCC_MMNOC_TBU_SF1_CBCR

    #let "APPS_SMMU_DEBUG_TESTBUS_SEL_MNOC_SF_1_HLOS1_NS = $SMMU_500_APPS_REG_WRAPPER_BASE+0x29050 = 0x151F5050"
    #let "APPS_SMMU_DEBUG_TESTBUS_MNOC_SF_1_HLOS1_NS = $SMMU_500_APPS_REG_WRAPPER_BASE+0x29058 = 0x151F5058"

    echo 0x151F5050 0x40 > $DCC_PATH/config_write #APPS_SMMU_DEBUG_TESTBUS_SEL_MNOC_SF_1_HLOS1_NS(0x151F5050)
    #echo $APPS_SMMU_DEBUG_TESTBUS_SEL_MNOC_SF_1_HLOS1_NS 1 > $DCC_PATH/config #XPU violation issue while config it as read
    echo 0x151F5058 1 > $DCC_PATH/config #APPS_SMMU_DEBUG_TESTBUS_MNOC_SF_1_HLOS1_NS(0x151F5058)
    ##echo 0x151A905C 1 > $DCC_PATH/config #APPS_SMMU_DEBUG_TESTBUS_MNOC_SF_1_HLOS1_NS
    #
    echo 0x151F5050 0x80 > $DCC_PATH/config_write
    echo 0x151F5058 1 > $DCC_PATH/config #APPS_SMMU_DEBUG_TESTBUS_MNOC_SF_1_HLOS1_NS

    echo 0x151F5050 0xC0 > $DCC_PATH/config_write
    echo 0x151F5058 1 > $DCC_PATH/config #APPS_SMMU_DEBUG_TESTBUS_MNOC_SF_1_HLOS1_NS
    ##echo 0x151A905C 1 > $DCC_PATH/config #APPS_SMMU_DEBUG_TESTBUS_MNOC_SF_1_HLOS1_NS
    #
    echo 0x151F5050 0x87 > $DCC_PATH/config_write
    echo 0x151F5058 1 > $DCC_PATH/config #APPS_SMMU_DEBUG_TESTBUS_MNOC_SF_1_HLOS1_NS
    ##echo 0x151A905C 1 > $DCC_PATH/config #APPS_SMMU_DEBUG_TESTBUS_MNOC_SF_1_HLOS1_NS
    #
    echo 0x151F5050 0xAF > $DCC_PATH/config_write
    echo 0x151F5058 1 > $DCC_PATH/config #APPS_SMMU_DEBUG_TESTBUS_MNOC_SF_1_HLOS1_NS
    ##echo 0x151A905C 1 > $DCC_PATH/config #APPS_SMMU_DEBUG_TESTBUS_MNOC_SF_1_HLOS1_NS
    #
    echo 0x151F5050 0xBC > $DCC_PATH/config_write
    echo 0x151F5058 1 > $DCC_PATH/config #APPS_SMMU_DEBUG_TESTBUS_MNOC_SF_1_HLOS1_NS
    #echo 0x151A905C 1 > $DCC_PATH/config #APPS_SMMU_DEBUG_TESTBUS_MNOC_SF_1_HLOS1_NS

    ##MNOC_HF_0
    #echo 0x109020 0x1 > $DCC_PATH/config_write
    echo 0x12C02C 1 > $DCC_PATH/config #GCC_MMNOC_TBU_HF0_SREGR
    echo 0x12C028 1 > $DCC_PATH/config #GCC_MMNOC_TBU_HF0_CBCR
    #echo 0x1518C010 0x10000 > $DCC_PATH/config_write #APPS_SMMU_CLIENT_DEBUG_SSD_INDEX_HYP_HLOS_EN_mnoc_hf_0_SEC__CLIENT_DEBUG_HYP_HLOS_EN = 1

    #let "APPS_SMMU_DEBUG_TESTBUS_SEL_MNOC_HF_0_HLOS1_NS = $SMMU_500_APPS_REG_WRAPPER_BASE+0xD050 = 0x151D9050"
    #let "APPS_SMMU_DEBUG_TESTBUS_MNOC_HF_0_HLOS1_NS = $SMMU_500_APPS_REG_WRAPPER_BASE+0xD058 = 0x151D9058"

    echo 0x151D9050 0x40 > $DCC_PATH/config_write #APPS_SMMU_DEBUG_TESTBUS_SEL_MNOC_HF_0_HLOS1_NS(0x151D9050)
    echo 0x151D9058 1 > $DCC_PATH/config #APPS_SMMU_DEBUG_TESTBUS_MNOC_HF_0_HLOS1_NS(0x151D9058)
    #echo 0x1518D05C 1 > $DCC_PATH/config #APPS_SMMU_DEBUG_TESTBUS_MNOC_HF_0_HLOS1_NS

    echo 0x151D9050 0x80 > $DCC_PATH/config_write
    echo 0x151D9058 1 > $DCC_PATH/config #APPS_SMMU_DEBUG_TESTBUS_MNOC_HF_0_HLOS1_NS
    #echo 0x1518D05C 1 > $DCC_PATH/config #APPS_SMMU_DEBUG_TESTBUS_MNOC_HF_0_HLOS1_NS

    echo 0x151D9050 0xC0 > $DCC_PATH/config_write
    echo 0x151D9058 1 > $DCC_PATH/config #APPS_SMMU_DEBUG_TESTBUS_MNOC_HF_0_HLOS1_NS
    #echo 0x1518D05C 1 > $DCC_PATH/config #APPS_SMMU_DEBUG_TESTBUS_MNOC_HF_0_HLOS1_NS

    echo 0x151D9050 0x87 > $DCC_PATH/config_write
    echo 0x151D9058 1 > $DCC_PATH/config #APPS_SMMU_DEBUG_TESTBUS_MNOC_HF_0_HLOS1_NS
    #echo 0x1518D05C 1 > $DCC_PATH/config #APPS_SMMU_DEBUG_TESTBUS_MNOC_HF_0_HLOS1_NS

    echo 0x151D9050 0xAF > $DCC_PATH/config_write
    echo 0x151D9058 1 > $DCC_PATH/config #APPS_SMMU_DEBUG_TESTBUS_MNOC_HF_0_HLOS1_NS
    #echo 0x1518D05C 1 > $DCC_PATH/config #APPS_SMMU_DEBUG_TESTBUS_MNOC_HF_0_HLOS1_NS

    echo 0x151D9050 0xBC > $DCC_PATH/config_write
    echo 0x151D9058 1 > $DCC_PATH/config #0x151D9058
    #echo 0x1518D05C 1 > $DCC_PATH/config #APPS_SMMU_DEBUG_TESTBUS_MNOC_HF_0_HLOS1_NS

    #MNOC_HF_1
    #echo 0x109028 0x1 > $DCC_PATH/config_write
    echo 0x12C034 1 > $DCC_PATH/config #GCC_MMNOC_TBU_HF1_SREGR
    echo 0x12C030 1 > $DCC_PATH/config #GCC_MMNOC_TBU_HF1_CBCR
    #echo 0x1518C010 0x10000 > $DCC_PATH/config_write #APPS_SMMU_CLIENT_DEBUG_SSD_INDEX_HYP_HLOS_EN_mnoc_hf_0_SEC__CLIENT_DEBUG_HYP_HLOS_EN = 1

    #let "APPS_SMMU_DEBUG_TESTBUS_SEL_MNOC_HF_1_HLOS1_NS = $SMMU_500_APPS_REG_WRAPPER_BASE+0x11050 = 0x151DD050"
    #let "APPS_SMMU_DEBUG_TESTBUS_MNOC_HF_1_HLOS1_NS = $SMMU_500_APPS_REG_WRAPPER_BASE+0x11058 = 0x151DD058"

    echo 0x151DD050 0x40 > $DCC_PATH/config_write #APPS_SMMU_DEBUG_TESTBUS_SEL_MNOC_HF_1_HLOS1_NS(0x151DD050)
    echo 0x151DD058 1 > $DCC_PATH/config #APPS_SMMU_DEBUG_TESTBUS_MNOC_HF_1_HLOS1_NS(0x151DD058)
    #echo 0x1519105C 1 > $DCC_PATH/config #APPS_SMMU_DEBUG_TESTBUS_MNOC_HF_1_HLOS1_NS

    echo 0x151DD050 0x80 > $DCC_PATH/config_write
    echo 0x151DD058 1 > $DCC_PATH/config #APPS_SMMU_DEBUG_TESTBUS_MNOC_HF_1_HLOS1_NS
    #echo 0x1519105C 1 > $DCC_PATH/config #APPS_SMMU_DEBUG_TESTBUS_MNOC_HF_1_HLOS1_NS

    echo 0x151DD050 0xC0 > $DCC_PATH/config_write
    echo 0x151DD058 1 > $DCC_PATH/config #APPS_SMMU_DEBUG_TESTBUS_MNOC_HF_1_HLOS1_NS
    #echo 0x1519105C 1 > $DCC_PATH/config #APPS_SMMU_DEBUG_TESTBUS_MNOC_HF_1_HLOS1_NS

    echo 0x151DD050 0x87 > $DCC_PATH/config_write
    echo 0x151DD058 1 > $DCC_PATH/config #APPS_SMMU_DEBUG_TESTBUS_MNOC_HF_1_HLOS1_NS
    #echo 0x1519105C 1 > $DCC_PATH/config #APPS_SMMU_DEBUG_TESTBUS_MNOC_HF_1_HLOS1_NS

    echo 0x151DD050 0xAF > $DCC_PATH/config_write
    echo 0x151DD058 1 > $DCC_PATH/config #APPS_SMMU_DEBUG_TESTBUS_MNOC_HF_1_HLOS1_NS
    #echo 0x1519105C 1 > $DCC_PATH/config #APPS_SMMU_DEBUG_TESTBUS_MNOC_HF_1_HLOS1_NS

    echo 0x151DD050 0xBC > $DCC_PATH/config_write
    echo 0x151DD058 1 > $DCC_PATH/config #APPS_SMMU_DEBUG_TESTBUS_MNOC_HF_1_HLOS1_NS
    ##echo 0x1519105C 1 > $DCC_PATH/config #APPS_SMMU_DEBUG_TESTBUS_MNOC_HF_1_HLOS1_NS


    #COMPUTE_DSP_0
    #echo 0x145004 0x1 > $DCC_PATH/config_write
    echo 0x1A9018 1 > $DCC_PATH/config #GCC_TURING_Q6_TBU0_SREGR
    echo 0x1A9014 1 > $DCC_PATH/config #GCC_TURING_Q6_TBU0_CBCR

    #let "APPS_SMMU_DEBUG_TESTBUS_SEL_COMPUTE_DSP_0_HLOS1_NS = $SMMU_500_APPS_REG_WRAPPER_BASE+0x19050 = 0x151E5050"
    #let "APPS_SMMU_DEBUG_TESTBUS_COMPUTE_DSP_0_HLOS1_NS = $SMMU_500_APPS_REG_WRAPPER_BASE+0x19058 = 0x151E5058"

    echo 0x151E5050 0x40 > $DCC_PATH/config_write #APPS_SMMU_DEBUG_TESTBUS_SEL_COMPUTE_DSP_0_HLOS1_NS(0x151E5050)
    echo 0x151E5058 1 > $DCC_PATH/config #APPS_SMMU_DEBUG_TESTBUS_COMPUTE_DSP_0_HLOS1_NS(0x151E5058)
    #echo 0x1519905C 1 > $DCC_PATH/config #APPS_SMMU_DEBUG_TESTBUS_COMPUTE_DSP_0_HLOS1_NS

    echo 0x151E5050 0x80 > $DCC_PATH/config_write
    echo 0x151E5058 1 > $DCC_PATH/config #APPS_SMMU_DEBUG_TESTBUS_COMPUTE_DSP_0_HLOS1_NS
    #echo 0x1519905C 1 > $DCC_PATH/config #APPS_SMMU_DEBUG_TESTBUS_COMPUTE_DSP_0_HLOS1_NS

    echo 0x151E5050 0xC0 > $DCC_PATH/config_write
    echo 0x151E5058 1 > $DCC_PATH/config #APPS_SMMU_DEBUG_TESTBUS_COMPUTE_DSP_0_HLOS1_NS
    #echo 0x1519905C 1 > $DCC_PATH/config #APPS_SMMU_DEBUG_TESTBUS_COMPUTE_DSP_0_HLOS1_NS

    echo 0x151E5050 0x87 > $DCC_PATH/config_write
    echo 0x151E5058 1 > $DCC_PATH/config #0x151E5058
    #echo 0x1519905C 1 > $DCC_PATH/config #APPS_SMMU_DEBUG_TESTBUS_COMPUTE_DSP_0_HLOS1_NS

    echo 0x151E5050 0xAF > $DCC_PATH/config_write
    echo 0x151E5058 1 > $DCC_PATH/config #APPS_SMMU_DEBUG_TESTBUS_COMPUTE_DSP_0_HLOS1_NS
    #echo 0x1519905C 1 > $DCC_PATH/config #APPS_SMMU_DEBUG_TESTBUS_COMPUTE_DSP_0_HLOS1_NS

    echo 0x151E5050 0xBC > $DCC_PATH/config_write
    echo 0x151E5058 1 > $DCC_PATH/config #APPS_SMMU_DEBUG_TESTBUS_COMPUTE_DSP_0_HLOS1_NS
    #echo 0x1519905C 1 > $DCC_PATH/config #APPS_SMMU_DEBUG_TESTBUS_COMPUTE_DSP_0_HLOS1_NS

    ##COMPUTE_DSP_1
    #echo 0x14500C 0x1 > $DCC_PATH/config_write
    echo 0x1A9020 1 > $DCC_PATH/config #GCC_TURING_Q6_TBU1_SREGR
    echo 0x1A901C 1 > $DCC_PATH/config #GCC_TURING_Q6_TBU1_CBCR

    #let "APPS_SMMU_DEBUG_TESTBUS_SEL_COMPUTE_DSP_1_HLOS1_NS = $SMMU_500_APPS_REG_WRAPPER_BASE+0x15050 = 0x151E1050"
    #let "APPS_SMMU_DEBUG_TESTBUS_COMPUTE_DSP_1_HLOS1_NS = $SMMU_500_APPS_REG_WRAPPER_BASE+0x15058 = 0x151E1058"

    echo 0x151E1050 0x40 > $DCC_PATH/config_write #APPS_SMMU_DEBUG_TESTBUS_SEL_COMPUTE_DSP_1_HLOS1_NS(0x151E1050)
    echo 0x151E1058 1 > $DCC_PATH/config #APPS_SMMU_DEBUG_TESTBUS_COMPUTE_DSP_1_HLOS1_NS(0x151E1058)
    #echo 0x1519505C 1 > $DCC_PATH/config #APPS_SMMU_DEBUG_TESTBUS_COMPUTE_DSP_1_HLOS1_NS

    echo 0x151E1050 0x80 > $DCC_PATH/config_write
    echo 0x151E1058 1 > $DCC_PATH/config #APPS_SMMU_DEBUG_TESTBUS_COMPUTE_DSP_1_HLOS1_NS
    #echo 0x1519505C 1 > $DCC_PATH/config #APPS_SMMU_DEBUG_TESTBUS_COMPUTE_DSP_1_HLOS1_NS

    echo 0x151E1050 0xC0 > $DCC_PATH/config_write
    echo 0x151E1058 1 > $DCC_PATH/config #APPS_SMMU_DEBUG_TESTBUS_COMPUTE_DSP_1_HLOS1_NS
    #echo 0x1519505C 1 > $DCC_PATH/config #APPS_SMMU_DEBUG_TESTBUS_COMPUTE_DSP_1_HLOS1_NS

    echo 0x151E1050 0x87 > $DCC_PATH/config_write
    echo 0x151E1058 1 > $DCC_PATH/config #APPS_SMMU_DEBUG_TESTBUS_COMPUTE_DSP_1_HLOS1_NS
    #echo 0x1519505C 1 > $DCC_PATH/config #APPS_SMMU_DEBUG_TESTBUS_COMPUTE_DSP_1_HLOS1_NS

    echo 0x151E1050 0xAF > $DCC_PATH/config_write
    echo 0x151E1058 1 > $DCC_PATH/config #APPS_SMMU_DEBUG_TESTBUS_COMPUTE_DSP_1_HLOS1_NS
    #echo 0x1519505C 1 > $DCC_PATH/config #APPS_SMMU_DEBUG_TESTBUS_COMPUTE_DSP_1_HLOS1_NS

    echo 0x151E1050 0xBC > $DCC_PATH/config_write
    echo 0x151E1058 1 > $DCC_PATH/config #APPS_SMMU_DEBUG_TESTBUS_COMPUTE_DSP_1_HLOS1_NS
    #echo 0x1519505C 1 > $DCC_PATH/config #APPS_SMMU_DEBUG_TESTBUS_COMPUTE_DSP_1_HLOS1_NS

    ##LPASS
    #echo 0x190004 0x1 > $DCC_PATH/config_write
    echo 0x1A0008 1 > $DCC_PATH/config #GCC_AGGRE_NOC_AUDIO_TBU_SREGR
    echo 0x1A0004 1 > $DCC_PATH/config #GCC_AGGRE_NOC_AUDIO_TBU_CBCR

    #let "APPS_SMMU_DEBUG_TESTBUS_SEL_LPASS_HLOS1_NS = $SMMU_500_APPS_REG_WRAPPER_BASE+0x1D050 = 0x151E9050"
    #let "APPS_SMMU_DEBUG_TESTBUS_LPASS_HLOS1_NS = $SMMU_500_APPS_REG_WRAPPER_BASE+0x1D058 = 0x151E9058"

    echo 0x151E9050 0x40 > $DCC_PATH/config_write #APPS_SMMU_DEBUG_TESTBUS_SEL_LPASS_HLOS1_NS(0x151E9050)
    echo 0x151E9058 1 > $DCC_PATH/config #APPS_SMMU_DEBUG_TESTBUS_LPASS_HLOS1_NS(0x151E9058)
    #echo 0x1519D05C 1 > $DCC_PATH/config #APPS_SMMU_DEBUG_TESTBUS_LPASS_HLOS1_NS

    echo 0x151E9050 0x80 > $DCC_PATH/config_write
    echo 0x151E9058 1 > $DCC_PATH/config #APPS_SMMU_DEBUG_TESTBUS_LPASS_HLOS1_NS
    #echo 0x1519D05C 1 > $DCC_PATH/config #APPS_SMMU_DEBUG_TESTBUS_LPASS_HLOS1_NS

    echo 0x151E9050 0xC0 > $DCC_PATH/config_write
    echo 0x151E9058 1 > $DCC_PATH/config #APPS_SMMU_DEBUG_TESTBUS_LPASS_HLOS1_NS
    #echo 0x1519D05C 1 > $DCC_PATH/config #APPS_SMMU_DEBUG_TESTBUS_LPASS_HLOS1_NS

    echo 0x151E9050 0x87 > $DCC_PATH/config_write
    echo 0x151E9058 1 > $DCC_PATH/config #APPS_SMMU_DEBUG_TESTBUS_LPASS_HLOS1_NS
    #echo 0x1519D05C 1 > $DCC_PATH/config #APPS_SMMU_DEBUG_TESTBUS_LPASS_HLOS1_NS

    echo 0x151E9050 0xAF > $DCC_PATH/config_write
    echo 0x151E9058 1 > $DCC_PATH/config #APPS_SMMU_DEBUG_TESTBUS_LPASS_HLOS1_NS
    #echo 0x1519D05C 1 > $DCC_PATH/config #APPS_SMMU_DEBUG_TESTBUS_LPASS_HLOS1_NS

    echo 0x151E9050 0xBC > $DCC_PATH/config_write
    echo 0x151E9058 1 > $DCC_PATH/config #APPS_SMMU_DEBUG_TESTBUS_LPASS_HLOS1_NS
    ##echo 0x1519D05C 1 > $DCC_PATH/config #APPS_SMMU_DEBUG_TESTBUS_LPASS_HLOS1_NS

    ##ANOC_PCIE
    #echo 0x19000C 0x1 > $DCC_PATH/config_write
    echo 0x120028 1 > $DCC_PATH/config #GCC_AGGRE_NOC_PCIE_TBU_SREGR
    echo 0x120024 1 > $DCC_PATH/config #GCC_AGGRE_NOC_PCIE_TBU_CBCR

    #let "APPS_SMMU_DEBUG_TESTBUS_SEL_ANOC_PCIE_HLOS1_NS = $SMMU_500_APPS_REG_WRAPPER_BASE+0x21050 = 0x151ED050"
    #let "APPS_SMMU_DEBUG_TESTBUS_ANOC_PCIE_HLOS1_NS = $SMMU_500_APPS_REG_WRAPPER_BASE+0x21058 = 0x151ED058"

    echo 0x151ED050 0x40 > $DCC_PATH/config_write #APPS_SMMU_DEBUG_TESTBUS_SEL_ANOC_PCIE_HLOS1_NS(0x151ED050)
    echo 0x151ED058 1 > $DCC_PATH/config #APPS_SMMU_DEBUG_TESTBUS_ANOC_PCIE_HLOS1_NS(0x151ED058)
    #echo 0x151A105C 1 > $DCC_PATH/config #APPS_SMMU_DEBUG_TESTBUS_ANOC_PCIE_HLOS1_NS

    echo 0x151ED050 0x80 > $DCC_PATH/config_write
    echo 0x151ED058 1 > $DCC_PATH/config #APPS_SMMU_DEBUG_TESTBUS_ANOC_PCIE_HLOS1_NS
    #echo 0x151A105C 1 > $DCC_PATH/config #APPS_SMMU_DEBUG_TESTBUS_ANOC_PCIE_HLOS1_NS

    echo 0x151ED050 0xC0 > $DCC_PATH/config_write
    echo 0x151ED058 1 > $DCC_PATH/config #APPS_SMMU_DEBUG_TESTBUS_ANOC_PCIE_HLOS1_NS
    #echo 0x151A105C 1 > $DCC_PATH/config #APPS_SMMU_DEBUG_TESTBUS_ANOC_PCIE_HLOS1_NS

    echo 0x151ED050 0x87 > $DCC_PATH/config_write
    echo 0x151ED058 1 > $DCC_PATH/config #APPS_SMMU_DEBUG_TESTBUS_ANOC_PCIE_HLOS1_NS
    #echo 0x151A105C 1 > $DCC_PATH/config #APPS_SMMU_DEBUG_TESTBUS_ANOC_PCIE_HLOS1_NS

    echo 0x151ED050 0xAF > $DCC_PATH/config_write
    echo 0x151ED058 1 > $DCC_PATH/config #APPS_SMMU_DEBUG_TESTBUS_ANOC_PCIE_HLOS1_NS
    #echo 0x151A105C 1 > $DCC_PATH/config #APPS_SMMU_DEBUG_TESTBUS_ANOC_PCIE_HLOS1_NS

    echo 0x151ED050 0xBC > $DCC_PATH/config_write
    echo 0x151ED058 1 > $DCC_PATH/config #APPS_SMMU_DEBUG_TESTBUS_ANOC_PCIE_HLOS1_NS
    ##echo 0x151A105C 1 > $DCC_PATH/config #APPS_SMMU_DEBUG_TESTBUS_ANOC_PCIE_HLOS1_NS

    #TCU change
    #echo 0x183008 0x1 > $DCC_PATH/config_write
    echo 0x193008 1 > $DCC_PATH/config #GCC_MMU_TCU_CBCR
    echo 0x19300C 1 > $DCC_PATH/config #GCC_MMU_TCU_SREGR
    #echo 0x15002300 0x40000000 > $DCC_PATH/config_write
    #
    echo 0x15002670 1 > $DCC_PATH/config #0x0, APPS_SMMU_MMU2QSS_AND_SAFE_WAIT_CNTR
    echo 0x15002204 1 > $DCC_PATH/config #0x3ff, APPS_SMMU_TBU_PWR_STATUS
    echo 0x150025DC 1 > $DCC_PATH/config #0x0, #APPS_SMMU_STATS_SYNC_INV_TBU_ACK
    echo 0x150075DC 1 > $DCC_PATH/config #0x0, #APPS_SMMU_STATS_SYNC_INV_TBU_ACK_NS
    echo 0x15002300 1 > $DCC_PATH/config #0x10, #APPS_SMMU_CUSTOM_CFG
    echo 0x150022FC 1 > $DCC_PATH/config #0x0, #APPS_SMMU_CUSTOM_CFG_SEC
    echo 0x15002648 1 > $DCC_PATH/config #0x0, #APPS_SMMU_SAFE_SEC_CFG

}

config_gpu()
{
    echo 0x03D0201C 1 > $DCC_PATH/config
    echo 0x03D00000 1 > $DCC_PATH/config
    echo 0x03D00008 1 > $DCC_PATH/config
    echo 0x03D00044 1 > $DCC_PATH/config
    echo 0x03D00058 1 > $DCC_PATH/config
    echo 0x03D0005C 1 > $DCC_PATH/config
    echo 0x03D00060 1 > $DCC_PATH/config
    echo 0x03D00064 1 > $DCC_PATH/config
    echo 0x03D00068 1 > $DCC_PATH/config
    echo 0x03D0006C 1 > $DCC_PATH/config
    echo 0x03D0007C 1 > $DCC_PATH/config
    echo 0x03D00080 1 > $DCC_PATH/config
    echo 0x03D00084 1 > $DCC_PATH/config
    echo 0x03D00088 1 > $DCC_PATH/config
    echo 0x03D0008C 1 > $DCC_PATH/config
    echo 0x03D00090 1 > $DCC_PATH/config
    echo 0x03D00094 1 > $DCC_PATH/config
    echo 0x03D00098 1 > $DCC_PATH/config
    echo 0x03D0009C 1 > $DCC_PATH/config
    echo 0x03D000A0 1 > $DCC_PATH/config
    echo 0x03D000A4 1 > $DCC_PATH/config
    echo 0x03D000A8 1 > $DCC_PATH/config
    echo 0x03D000AC 1 > $DCC_PATH/config
    echo 0x03D000B0 1 > $DCC_PATH/config
    echo 0x03D000B4 1 > $DCC_PATH/config
    echo 0x03D000B8 1 > $DCC_PATH/config
    echo 0x03D000BC 1 > $DCC_PATH/config
    echo 0x03D000C0 1 > $DCC_PATH/config
    echo 0x03D000C4 1 > $DCC_PATH/config
    echo 0x03D000C8 1 > $DCC_PATH/config
    echo 0x03D000E0 1 > $DCC_PATH/config
    echo 0x03D000E4 1 > $DCC_PATH/config
    echo 0x03D000E8 1 > $DCC_PATH/config
    echo 0x03D000EC 1 > $DCC_PATH/config
    echo 0x03D000F0 1 > $DCC_PATH/config
    echo 0x03D00108 1 > $DCC_PATH/config
    echo 0x03D00110 1 > $DCC_PATH/config
    echo 0x03D0011C 1 > $DCC_PATH/config
    echo 0x03D00124 1 > $DCC_PATH/config
    echo 0x03D00128 1 > $DCC_PATH/config
    echo 0x03D00130 1 > $DCC_PATH/config
    echo 0x03D00140 1 > $DCC_PATH/config
    echo 0x03D00158 1 > $DCC_PATH/config
    echo 0x03D001CC 1 > $DCC_PATH/config
    echo 0x03D001D0 1 > $DCC_PATH/config
    echo 0x03D001D4 1 > $DCC_PATH/config
    echo 0x03D002B4 1 > $DCC_PATH/config
    echo 0x03D002B8 1 > $DCC_PATH/config
    echo 0x03D002C0 1 > $DCC_PATH/config
    echo 0x03D002D0 1 > $DCC_PATH/config
    echo 0x03D002E0 1 > $DCC_PATH/config
    echo 0x03D002F0 1 > $DCC_PATH/config
    echo 0x03D00300 1 > $DCC_PATH/config
    echo 0x03D00310 1 > $DCC_PATH/config
    echo 0x03D00320 1 > $DCC_PATH/config
    echo 0x03D00330 1 > $DCC_PATH/config
    echo 0x03D00340 1 > $DCC_PATH/config
    echo 0x03D00350 1 > $DCC_PATH/config
    echo 0x03D00360 1 > $DCC_PATH/config
    echo 0x03D00370 1 > $DCC_PATH/config
    echo 0x03D00380 1 > $DCC_PATH/config
    echo 0x03D00390 1 > $DCC_PATH/config
    echo 0x03D003A0 1 > $DCC_PATH/config
    echo 0x03D003B0 1 > $DCC_PATH/config
    echo 0x03D003C0 1 > $DCC_PATH/config
    echo 0x03D003D0 1 > $DCC_PATH/config
    echo 0x03D003E0 1 > $DCC_PATH/config
    echo 0x03D00400 1 > $DCC_PATH/config
    echo 0x03D00410 1 > $DCC_PATH/config
    echo 0x03D00414 1 > $DCC_PATH/config
    echo 0x03D00418 1 > $DCC_PATH/config
    echo 0x03D0041C 1 > $DCC_PATH/config
    echo 0x03D00420 1 > $DCC_PATH/config
    echo 0x03D00424 1 > $DCC_PATH/config
    echo 0x03D00428 1 > $DCC_PATH/config
    echo 0x03D0042C 1 > $DCC_PATH/config
    echo 0x03D0043C 1 > $DCC_PATH/config
    echo 0x03D00440 1 > $DCC_PATH/config
    echo 0x03D00444 1 > $DCC_PATH/config
    echo 0x03D00448 1 > $DCC_PATH/config
    echo 0x03D0044C 1 > $DCC_PATH/config
    echo 0x03D00450 1 > $DCC_PATH/config
    echo 0x03D00454 1 > $DCC_PATH/config
    echo 0x03D00458 1 > $DCC_PATH/config
    echo 0x03D0045C 1 > $DCC_PATH/config
    echo 0x03D00460 1 > $DCC_PATH/config
    echo 0x03D00464 1 > $DCC_PATH/config
    echo 0x03D00468 1 > $DCC_PATH/config
    echo 0x03D0046C 1 > $DCC_PATH/config
    echo 0x03D00470 1 > $DCC_PATH/config
    echo 0x03D00474 1 > $DCC_PATH/config
    echo 0x03D004BC 1 > $DCC_PATH/config
    echo 0x03D00800 1 > $DCC_PATH/config
    echo 0x03D00804 1 > $DCC_PATH/config
    echo 0x03D00808 1 > $DCC_PATH/config
    echo 0x03D0080C 1 > $DCC_PATH/config
    echo 0x03D00810 1 > $DCC_PATH/config
    echo 0x03D00814 1 > $DCC_PATH/config
    echo 0x03D00818 1 > $DCC_PATH/config
    echo 0x03D0081C 1 > $DCC_PATH/config
    echo 0x03D00820 1 > $DCC_PATH/config
    echo 0x03D00824 1 > $DCC_PATH/config
    echo 0x03D00828 1 > $DCC_PATH/config
    echo 0x03D0082C 1 > $DCC_PATH/config
    echo 0x03D00830 1 > $DCC_PATH/config
    echo 0x03D00834 1 > $DCC_PATH/config
    echo 0x03D00840 1 > $DCC_PATH/config
    echo 0x03D00844 1 > $DCC_PATH/config
    echo 0x03D00848 1 > $DCC_PATH/config
    echo 0x03D0084C 1 > $DCC_PATH/config
    echo 0x03D00854 1 > $DCC_PATH/config
    echo 0x03D00858 1 > $DCC_PATH/config
    echo 0x03D0085C 1 > $DCC_PATH/config
    echo 0x03D00860 1 > $DCC_PATH/config
    echo 0x03D00864 1 > $DCC_PATH/config
    echo 0x03D00868 1 > $DCC_PATH/config
    echo 0x03D0086C 1 > $DCC_PATH/config
    echo 0x03D00870 1 > $DCC_PATH/config
    echo 0x03D00874 1 > $DCC_PATH/config
    echo 0x03D00878 1 > $DCC_PATH/config
    echo 0x03D0087C 1 > $DCC_PATH/config
    echo 0x03D00880 1 > $DCC_PATH/config
    echo 0x03D00884 1 > $DCC_PATH/config
    echo 0x03D00888 1 > $DCC_PATH/config
    echo 0x03D0088C 1 > $DCC_PATH/config
    echo 0x03D00890 1 > $DCC_PATH/config
    echo 0x03D00894 1 > $DCC_PATH/config
    echo 0x03D00898 1 > $DCC_PATH/config
    echo 0x03D0089C 1 > $DCC_PATH/config
    echo 0x03D008A0 1 > $DCC_PATH/config
    echo 0x03D008A4 1 > $DCC_PATH/config
    echo 0x03D008A8 1 > $DCC_PATH/config
    echo 0x03D008AC 1 > $DCC_PATH/config
    echo 0x03D008B0 1 > $DCC_PATH/config
    echo 0x03D008B4 1 > $DCC_PATH/config
    echo 0x03D008B8 1 > $DCC_PATH/config
    echo 0x03D008BC 1 > $DCC_PATH/config
    echo 0x03D008C0 1 > $DCC_PATH/config
    echo 0x03D008C4 1 > $DCC_PATH/config
    echo 0x03D008C8 1 > $DCC_PATH/config
    echo 0x03D008CC 1 > $DCC_PATH/config
    echo 0x03D008D0 1 > $DCC_PATH/config
    echo 0x03D008D4 1 > $DCC_PATH/config
    echo 0x03D008D8 1 > $DCC_PATH/config
    echo 0x03D008DC 1 > $DCC_PATH/config
    echo 0x03D008E0 1 > $DCC_PATH/config
    echo 0x03D008E4 1 > $DCC_PATH/config
    echo 0x03D008E8 1 > $DCC_PATH/config
    echo 0x03D008EC 1 > $DCC_PATH/config
    echo 0x03D008F0 1 > $DCC_PATH/config
    echo 0x03D008F4 1 > $DCC_PATH/config
    echo 0x03D008F8 1 > $DCC_PATH/config
    echo 0x03D008FC 1 > $DCC_PATH/config
    echo 0x03D00900 1 > $DCC_PATH/config
    echo 0x03D00904 1 > $DCC_PATH/config
    echo 0x03D00908 1 > $DCC_PATH/config
    echo 0x03D0090C 1 > $DCC_PATH/config
    echo 0x03D00980 1 > $DCC_PATH/config
    echo 0x03D00984 1 > $DCC_PATH/config
    echo 0x03D00988 1 > $DCC_PATH/config
    echo 0x03D0098C 1 > $DCC_PATH/config
    echo 0x03D00990 1 > $DCC_PATH/config
    echo 0x03D00994 1 > $DCC_PATH/config
    echo 0x03D00998 1 > $DCC_PATH/config
    echo 0x03D0099C 1 > $DCC_PATH/config
    echo 0x03D009A0 1 > $DCC_PATH/config
    echo 0x03D009C8 1 > $DCC_PATH/config
    echo 0x03D009CC 1 > $DCC_PATH/config
    echo 0x03D009D0 1 > $DCC_PATH/config
    echo 0x03D00A04 1 > $DCC_PATH/config
    echo 0x03D00A08 1 > $DCC_PATH/config
    echo 0x03D00A0C 1 > $DCC_PATH/config
    echo 0x03D00A10 1 > $DCC_PATH/config
    echo 0x03D00A14 1 > $DCC_PATH/config
    echo 0x03D00A18 1 > $DCC_PATH/config
    echo 0x03D00A1C 1 > $DCC_PATH/config
    echo 0x03D00A20 1 > $DCC_PATH/config
    echo 0x03D00A24 1 > $DCC_PATH/config
    echo 0x03D00A28 1 > $DCC_PATH/config
    echo 0x03D00A2C 1 > $DCC_PATH/config
    echo 0x03D00A30 1 > $DCC_PATH/config
    echo 0x03D00A34 1 > $DCC_PATH/config
    echo 0x03D01444 1 > $DCC_PATH/config
    echo 0x03D014D4 1 > $DCC_PATH/config
    echo 0x03D014D8 1 > $DCC_PATH/config
    echo 0x03D017EC 1 > $DCC_PATH/config
    echo 0x03D017F0 1 > $DCC_PATH/config
    echo 0x03D017F4 1 > $DCC_PATH/config
    echo 0x03D017F8 1 > $DCC_PATH/config
    echo 0x03D017FC 1 > $DCC_PATH/config
    echo 0x03D99800 1 > $DCC_PATH/config
    echo 0x03D99804 1 > $DCC_PATH/config
    echo 0x03D99808 1 > $DCC_PATH/config
    echo 0x03D9980C 1 > $DCC_PATH/config
    echo 0x03D99810 1 > $DCC_PATH/config
    echo 0x03D99814 1 > $DCC_PATH/config
    echo 0x03D99818 1 > $DCC_PATH/config
    echo 0x03D9981C 1 > $DCC_PATH/config
    echo 0x03D99828 1 > $DCC_PATH/config
    echo 0x03D9983C 1 > $DCC_PATH/config
    echo 0x03D998AC 1 > $DCC_PATH/config
    echo 0x0018101C 1 > $DCC_PATH/config
    echo 0x00181020 1 > $DCC_PATH/config
    echo 0x03D94000 1 > $DCC_PATH/config
    echo 0x03D94004 1 > $DCC_PATH/config
    echo 0x03D95000 1 > $DCC_PATH/config
    echo 0x03D95004 1 > $DCC_PATH/config
    echo 0x03D95008 1 > $DCC_PATH/config
    echo 0x03D9500C 1 > $DCC_PATH/config
    echo 0x03D96000 1 > $DCC_PATH/config
    echo 0x03D96004 1 > $DCC_PATH/config
    echo 0x03D96008 1 > $DCC_PATH/config
    echo 0x03D9600C 1 > $DCC_PATH/config
    echo 0x03D97000 1 > $DCC_PATH/config
    echo 0x03D97004 1 > $DCC_PATH/config
    echo 0x03D97008 1 > $DCC_PATH/config
    echo 0x03D9700C 1 > $DCC_PATH/config
    echo 0x03D98000 1 > $DCC_PATH/config
    echo 0x03D98004 1 > $DCC_PATH/config
    echo 0x03D98008 1 > $DCC_PATH/config
    echo 0x03D9800C 1 > $DCC_PATH/config
    echo 0x03D99000 1 > $DCC_PATH/config
    echo 0x03D99004 1 > $DCC_PATH/config
    echo 0x03D99008 1 > $DCC_PATH/config
    echo 0x03D9900C 1 > $DCC_PATH/config
    echo 0x03D99010 1 > $DCC_PATH/config
    echo 0x03D99014 1 > $DCC_PATH/config
    echo 0x03D99050 1 > $DCC_PATH/config
    echo 0x03D99054 1 > $DCC_PATH/config
    echo 0x03D99058 1 > $DCC_PATH/config
    echo 0x03D9905C 1 > $DCC_PATH/config
    echo 0x03D99060 1 > $DCC_PATH/config
    echo 0x03D99064 1 > $DCC_PATH/config
    echo 0x03D99068 1 > $DCC_PATH/config
    echo 0x03D9906C 1 > $DCC_PATH/config
    echo 0x03D99070 1 > $DCC_PATH/config
    echo 0x03D99074 1 > $DCC_PATH/config
    echo 0x03D990A8 1 > $DCC_PATH/config
    echo 0x03D990AC 1 > $DCC_PATH/config
    echo 0x03D990B8 1 > $DCC_PATH/config
    echo 0x03D990BC 1 > $DCC_PATH/config
    echo 0x03D990C0 1 > $DCC_PATH/config
    echo 0x03D990C8 1 > $DCC_PATH/config
    echo 0x03D99104 1 > $DCC_PATH/config
    echo 0x03D99108 1 > $DCC_PATH/config
    echo 0x03D9910C 1 > $DCC_PATH/config
    echo 0x03D99110 1 > $DCC_PATH/config
    echo 0x03D99114 1 > $DCC_PATH/config
    echo 0x03D99118 1 > $DCC_PATH/config
    echo 0x03D9911C 1 > $DCC_PATH/config
    echo 0x03D99120 1 > $DCC_PATH/config
    echo 0x03D99130 1 > $DCC_PATH/config
    echo 0x03D99134 1 > $DCC_PATH/config
    echo 0x03D9913C 1 > $DCC_PATH/config
    echo 0x03D99140 1 > $DCC_PATH/config
    echo 0x03D99144 1 > $DCC_PATH/config
    echo 0x03D99148 1 > $DCC_PATH/config
    echo 0x03D9914C 1 > $DCC_PATH/config
    echo 0x03D99150 1 > $DCC_PATH/config
    echo 0x03D99154 1 > $DCC_PATH/config
    echo 0x03D99198 1 > $DCC_PATH/config
    echo 0x03D9919C 1 > $DCC_PATH/config
    echo 0x03D991A0 1 > $DCC_PATH/config
    echo 0x03D991E0 1 > $DCC_PATH/config
    echo 0x03D991E4 1 > $DCC_PATH/config
    echo 0x03D991E8 1 > $DCC_PATH/config
    echo 0x03D99224 1 > $DCC_PATH/config
    echo 0x03D99228 1 > $DCC_PATH/config
    echo 0x03D99280 1 > $DCC_PATH/config
    echo 0x03D99284 1 > $DCC_PATH/config
    echo 0x03D99288 1 > $DCC_PATH/config
    echo 0x03D9928C 1 > $DCC_PATH/config
    echo 0x03D992CC 1 > $DCC_PATH/config
    echo 0x03D992D0 1 > $DCC_PATH/config
    echo 0x03D992D4 1 > $DCC_PATH/config
    echo 0x03D99314 1 > $DCC_PATH/config
    echo 0x03D99318 1 > $DCC_PATH/config
    echo 0x03D9931C 1 > $DCC_PATH/config
    echo 0x03D99358 1 > $DCC_PATH/config
    echo 0x03D9935C 1 > $DCC_PATH/config
    echo 0x03D99360 1 > $DCC_PATH/config
    echo 0x03D993A0 1 > $DCC_PATH/config
    echo 0x03D993A4 1 > $DCC_PATH/config
    echo 0x03D993E4 1 > $DCC_PATH/config
    echo 0x03D993E8 1 > $DCC_PATH/config
    echo 0x03D993EC 1 > $DCC_PATH/config
    echo 0x03D993F0 1 > $DCC_PATH/config
    echo 0x03D9942C 1 > $DCC_PATH/config
    echo 0x03D99430 1 > $DCC_PATH/config
    echo 0x03D99470 1 > $DCC_PATH/config
    echo 0x03D99474 1 > $DCC_PATH/config
    echo 0x03D99478 1 > $DCC_PATH/config
    echo 0x03D99500 1 > $DCC_PATH/config
    echo 0x03D99504 1 > $DCC_PATH/config
    echo 0x03D99508 1 > $DCC_PATH/config
    echo 0x03D9950C 1 > $DCC_PATH/config
    echo 0x03D99528 1 > $DCC_PATH/config
    echo 0x03D9952C 1 > $DCC_PATH/config
    echo 0x03D99530 1 > $DCC_PATH/config
    echo 0x03D99534 1 > $DCC_PATH/config
    echo 0x03D99538 1 > $DCC_PATH/config
    echo 0x03D9953C 1 > $DCC_PATH/config
    echo 0x03D99540 1 > $DCC_PATH/config
    echo 0x03D99544 1 > $DCC_PATH/config
    echo 0x03D99548 1 > $DCC_PATH/config
    echo 0x03D9954C 1 > $DCC_PATH/config
    echo 0x03D99550 1 > $DCC_PATH/config
    echo 0x03D99554 1 > $DCC_PATH/config
    echo 0x03D99558 1 > $DCC_PATH/config
    echo 0x03D9955C 1 > $DCC_PATH/config
    echo 0x03D99560 1 > $DCC_PATH/config
    echo 0x03D99564 1 > $DCC_PATH/config
    echo 0x03D99568 1 > $DCC_PATH/config
    echo 0x03D9956C 1 > $DCC_PATH/config
    echo 0x03D99570 1 > $DCC_PATH/config
    echo 0x03D99574 1 > $DCC_PATH/config
    echo 0x03D99578 1 > $DCC_PATH/config
    echo 0x03D9957C 1 > $DCC_PATH/config
    echo 0x03D99580 1 > $DCC_PATH/config
    echo 0x03D99584 1 > $DCC_PATH/config
    echo 0x03D99588 1 > $DCC_PATH/config
    echo 0x03D9958C 1 > $DCC_PATH/config
    echo 0x03D99590 1 > $DCC_PATH/config
    echo 0x03D99594 1 > $DCC_PATH/config
    echo 0x03D99598 1 > $DCC_PATH/config
    echo 0x03D9959C 1 > $DCC_PATH/config
    echo 0x03D995A0 1 > $DCC_PATH/config
    echo 0x03D995A4 1 > $DCC_PATH/config
    echo 0x03D995A8 1 > $DCC_PATH/config
    echo 0x03D995AC 1 > $DCC_PATH/config
    echo 0x03D995B0 1 > $DCC_PATH/config
    echo 0x03D995B4 1 > $DCC_PATH/config
    echo 0x03D995B8 1 > $DCC_PATH/config
    echo 0x03D995BC 1 > $DCC_PATH/config
    echo 0x03D995C0 1 > $DCC_PATH/config
    echo 0x03D3B000 1 > $DCC_PATH/config
    echo 0x03D3B004 1 > $DCC_PATH/config
    echo 0x03D3B014 1 > $DCC_PATH/config
    echo 0x03D3B01C 1 > $DCC_PATH/config
    echo 0x03D3B028 1 > $DCC_PATH/config
    echo 0x03D3B0AC 1 > $DCC_PATH/config
    echo 0x03D3B100 1 > $DCC_PATH/config
    echo 0x03D3B104 1 > $DCC_PATH/config
    echo 0x03D3B114 1 > $DCC_PATH/config
    echo 0x03D3B11C 1 > $DCC_PATH/config
    echo 0x03D3B128 1 > $DCC_PATH/config
    echo 0x03D3B1AC 1 > $DCC_PATH/config
    echo 0x03D90000 1 > $DCC_PATH/config
    echo 0x03D90004 1 > $DCC_PATH/config
    echo 0x03D90008 1 > $DCC_PATH/config
    echo 0x03D9000C 1 > $DCC_PATH/config
    echo 0x03D90010 1 > $DCC_PATH/config
    echo 0x03D90014 1 > $DCC_PATH/config
    echo 0x03D90018 1 > $DCC_PATH/config
    echo 0x03D9001C 1 > $DCC_PATH/config
    echo 0x03D90020 1 > $DCC_PATH/config
    echo 0x03D90024 1 > $DCC_PATH/config
    echo 0x03D90028 1 > $DCC_PATH/config
    echo 0x03D9002C 1 > $DCC_PATH/config
    echo 0x03D90030 1 > $DCC_PATH/config
    echo 0x03D90034 1 > $DCC_PATH/config
    echo 0x03D90038 1 > $DCC_PATH/config
    echo 0x03D91000 1 > $DCC_PATH/config
    echo 0x03D91004 1 > $DCC_PATH/config
    echo 0x03D91008 1 > $DCC_PATH/config
    echo 0x03D9100C 1 > $DCC_PATH/config
    echo 0x03D91010 1 > $DCC_PATH/config
    echo 0x03D91014 1 > $DCC_PATH/config
    echo 0x03D91018 1 > $DCC_PATH/config
    echo 0x03D9101C 1 > $DCC_PATH/config
    echo 0x03D91020 1 > $DCC_PATH/config
    echo 0x03D91024 1 > $DCC_PATH/config
    echo 0x03D91028 1 > $DCC_PATH/config
    echo 0x03D9102C 1 > $DCC_PATH/config
    echo 0x03D91030 1 > $DCC_PATH/config
    echo 0x03D91034 1 > $DCC_PATH/config
    echo 0x03D91038 1 > $DCC_PATH/config
    echo 0x03D50000 1 > $DCC_PATH/config
    echo 0x03D50004 1 > $DCC_PATH/config
    echo 0x03D50008 1 > $DCC_PATH/config
    echo 0x03D5000C 1 > $DCC_PATH/config
    echo 0x03D50010 1 > $DCC_PATH/config
    echo 0x03D50014 1 > $DCC_PATH/config
    echo 0x03D50018 1 > $DCC_PATH/config
    echo 0x03D5001C 1 > $DCC_PATH/config
    echo 0x03D50020 1 > $DCC_PATH/config
    echo 0x03D50024 1 > $DCC_PATH/config
    echo 0x03D50028 1 > $DCC_PATH/config
    echo 0x03D5002C 1 > $DCC_PATH/config
    echo 0x03D50030 1 > $DCC_PATH/config
    echo 0x03D50034 1 > $DCC_PATH/config
    echo 0x03D50038 1 > $DCC_PATH/config
    echo 0x03D5003C 1 > $DCC_PATH/config
    echo 0x03D50040 1 > $DCC_PATH/config
    echo 0x03D50044 1 > $DCC_PATH/config
    echo 0x03D50048 1 > $DCC_PATH/config
    echo 0x03D5004C 1 > $DCC_PATH/config
    echo 0x03D50050 1 > $DCC_PATH/config
    echo 0x03D500D0 1 > $DCC_PATH/config
    echo 0x03D500D8 1 > $DCC_PATH/config
    echo 0x03D50100 1 > $DCC_PATH/config
    echo 0x03D50104 1 > $DCC_PATH/config
    echo 0x03D50108 1 > $DCC_PATH/config
    echo 0x03D50200 1 > $DCC_PATH/config
    echo 0x03D50204 1 > $DCC_PATH/config
    echo 0x03D50208 1 > $DCC_PATH/config
    echo 0x03D5020C 1 > $DCC_PATH/config
    echo 0x03D50210 1 > $DCC_PATH/config
    echo 0x03D50400 1 > $DCC_PATH/config
    echo 0x03D50404 1 > $DCC_PATH/config
    echo 0x03D50408 1 > $DCC_PATH/config
    echo 0x03D50450 1 > $DCC_PATH/config
    echo 0x03D50460 1 > $DCC_PATH/config
    echo 0x03D50464 1 > $DCC_PATH/config
    echo 0x03D50490 1 > $DCC_PATH/config
    echo 0x03D50494 1 > $DCC_PATH/config
    echo 0x03D50498 1 > $DCC_PATH/config
    echo 0x03D5049C 1 > $DCC_PATH/config
    echo 0x03D504A0 1 > $DCC_PATH/config
    echo 0x03D504A4 1 > $DCC_PATH/config
    echo 0x03D504A8 1 > $DCC_PATH/config
    echo 0x03D504AC 1 > $DCC_PATH/config
    echo 0x03D504B0 1 > $DCC_PATH/config
    echo 0x03D504B4 1 > $DCC_PATH/config
    echo 0x03D504B8 1 > $DCC_PATH/config
    echo 0x03D50500 1 > $DCC_PATH/config
    echo 0x03D50600 1 > $DCC_PATH/config
    echo 0x03D50D00 1 > $DCC_PATH/config
    echo 0x03D50D04 1 > $DCC_PATH/config
    echo 0x03D50D10 1 > $DCC_PATH/config
    echo 0x03D50D14 1 > $DCC_PATH/config
    echo 0x03D50D18 1 > $DCC_PATH/config
    echo 0x03D50D1C 1 > $DCC_PATH/config
    echo 0x03D50D30 1 > $DCC_PATH/config
    echo 0x03D50D34 1 > $DCC_PATH/config
    echo 0x03D50D38 1 > $DCC_PATH/config
    echo 0x03D50D3C 1 > $DCC_PATH/config
    echo 0x03D50D40 1 > $DCC_PATH/config
    echo 0x03D53D44 1 > $DCC_PATH/config
    echo 0x03D53D4C 1 > $DCC_PATH/config
    echo 0x03D53D50 1 > $DCC_PATH/config
    echo 0x03D8E100 1 > $DCC_PATH/config
    echo 0x03D8E104 1 > $DCC_PATH/config
    echo 0x03D8EC00 1 > $DCC_PATH/config
    echo 0x03D8EC04 1 > $DCC_PATH/config
    echo 0x03D8EC0C 1 > $DCC_PATH/config
    echo 0x03D8EC14 1 > $DCC_PATH/config
    echo 0x03D8EC18 1 > $DCC_PATH/config
    echo 0x03D8EC1C 1 > $DCC_PATH/config
    echo 0x03D8EC20 1 > $DCC_PATH/config
    echo 0x03D8EC24 1 > $DCC_PATH/config
    echo 0x03D8EC28 1 > $DCC_PATH/config
    echo 0x03D8EC2C 1 > $DCC_PATH/config
    echo 0x03D8EC30 1 > $DCC_PATH/config
    echo 0x03D8EC34 1 > $DCC_PATH/config
    echo 0x03D8EC38 1 > $DCC_PATH/config
    echo 0x03D8EC40 1 > $DCC_PATH/config
    echo 0x03D8EC44 1 > $DCC_PATH/config
    echo 0x03D8EC48 1 > $DCC_PATH/config
    echo 0x03D8EC4C 1 > $DCC_PATH/config
    echo 0x03D8EC54 1 > $DCC_PATH/config
    echo 0x03D8EC58 1 > $DCC_PATH/config
    echo 0x03D8EC80 1 > $DCC_PATH/config
    echo 0x03D8ECA0 1 > $DCC_PATH/config
    echo 0x03D8ECC0 1 > $DCC_PATH/config
    echo 0x03D7D000 1 > $DCC_PATH/config
    echo 0x03D7D004 1 > $DCC_PATH/config
    echo 0x03D7D008 1 > $DCC_PATH/config
    echo 0x03D7D00C 1 > $DCC_PATH/config
    echo 0x03D7D010 1 > $DCC_PATH/config
    echo 0x03D7D014 1 > $DCC_PATH/config
    echo 0x03D7D018 1 > $DCC_PATH/config
    echo 0x03D7D01C 1 > $DCC_PATH/config
    echo 0x03D7D020 1 > $DCC_PATH/config
    echo 0x03D7D024 1 > $DCC_PATH/config
    echo 0x03D7D028 1 > $DCC_PATH/config
    echo 0x03D7D02C 1 > $DCC_PATH/config
    echo 0x03D7D030 1 > $DCC_PATH/config
    echo 0x03D7D034 1 > $DCC_PATH/config
    echo 0x03D7D03C 1 > $DCC_PATH/config
    echo 0x03D7D040 1 > $DCC_PATH/config
    echo 0x03D7D044 1 > $DCC_PATH/config
    echo 0x03D7D400 1 > $DCC_PATH/config
    echo 0x03D7D41C 1 > $DCC_PATH/config
    echo 0x03D7D424 1 > $DCC_PATH/config
    echo 0x03D7D428 1 > $DCC_PATH/config
    echo 0x03D7D42C 1 > $DCC_PATH/config
    echo 0x03D7E000 1 > $DCC_PATH/config
    echo 0x03D7E004 1 > $DCC_PATH/config
    echo 0x03D7E008 1 > $DCC_PATH/config
    echo 0x03D7E00C 1 > $DCC_PATH/config
    echo 0x03D7E010 1 > $DCC_PATH/config
    echo 0x03D7E01C 1 > $DCC_PATH/config
    echo 0x03D7E020 1 > $DCC_PATH/config
    echo 0x03D7E02C 1 > $DCC_PATH/config
    echo 0x03D7E030 1 > $DCC_PATH/config
    echo 0x03D7E03C 1 > $DCC_PATH/config
    echo 0x03D7E044 1 > $DCC_PATH/config
    echo 0x03D7E04C 1 > $DCC_PATH/config
    echo 0x03D7E050 1 > $DCC_PATH/config
    echo 0x03D7E054 1 > $DCC_PATH/config
    echo 0x03D7E058 1 > $DCC_PATH/config
    echo 0x03D7E05C 1 > $DCC_PATH/config
    echo 0x03D7E064 1 > $DCC_PATH/config
    echo 0x03D7E068 1 > $DCC_PATH/config
    echo 0x03D7E06C 1 > $DCC_PATH/config
    echo 0x03D7E070 1 > $DCC_PATH/config
    echo 0x03D7E090 1 > $DCC_PATH/config
    echo 0x03D7E094 1 > $DCC_PATH/config
    echo 0x03D7E098 1 > $DCC_PATH/config
    echo 0x03D7E09C 1 > $DCC_PATH/config
    echo 0x03D7E0A0 1 > $DCC_PATH/config
    echo 0x03D7E0A4 1 > $DCC_PATH/config
    echo 0x03D7E0A8 1 > $DCC_PATH/config
    echo 0x03D7E0B4 1 > $DCC_PATH/config
    echo 0x03D7E0B8 1 > $DCC_PATH/config
    echo 0x03D7E0BC 1 > $DCC_PATH/config
    echo 0x03D7E0C0 1 > $DCC_PATH/config
    echo 0x03D7E100 1 > $DCC_PATH/config
    echo 0x03D7E104 1 > $DCC_PATH/config
    echo 0x03D7E108 1 > $DCC_PATH/config
    echo 0x03D7E10C 1 > $DCC_PATH/config
    echo 0x03D7E110 1 > $DCC_PATH/config
    echo 0x03D7E114 1 > $DCC_PATH/config
    echo 0x03D7E118 1 > $DCC_PATH/config
    echo 0x03D7E11C 1 > $DCC_PATH/config
    echo 0x03D7E120 1 > $DCC_PATH/config
    echo 0x03D7E124 1 > $DCC_PATH/config
    echo 0x03D7E128 1 > $DCC_PATH/config
    echo 0x03D7E12C 1 > $DCC_PATH/config
    echo 0x03D7E130 1 > $DCC_PATH/config
    echo 0x03D7E134 1 > $DCC_PATH/config
    echo 0x03D7E138 1 > $DCC_PATH/config
    echo 0x03D7E13C 1 > $DCC_PATH/config
    echo 0x03D7E140 1 > $DCC_PATH/config
    echo 0x03D7E144 1 > $DCC_PATH/config
    echo 0x03D7E148 1 > $DCC_PATH/config
    echo 0x03D7E14C 1 > $DCC_PATH/config
    echo 0x03D7E180 1 > $DCC_PATH/config
    echo 0x03D7E1C0 1 > $DCC_PATH/config
    echo 0x03D7E1C4 1 > $DCC_PATH/config
    echo 0x03D7E1C8 1 > $DCC_PATH/config
    echo 0x03D7E1CC 1 > $DCC_PATH/config
    echo 0x03D7E1D0 1 > $DCC_PATH/config
    echo 0x03D7E1D4 1 > $DCC_PATH/config
    echo 0x03D7E1D8 1 > $DCC_PATH/config
    echo 0x03D7E1DC 1 > $DCC_PATH/config
    echo 0x03D7E1E0 1 > $DCC_PATH/config
    echo 0x03D7E1E4 1 > $DCC_PATH/config
    echo 0x03D7E1FC 1 > $DCC_PATH/config
    echo 0x03D7E220 1 > $DCC_PATH/config
    echo 0x03D7E224 1 > $DCC_PATH/config
    echo 0x03D7E300 1 > $DCC_PATH/config
    echo 0x03D7E304 1 > $DCC_PATH/config
    echo 0x03D7E30C 1 > $DCC_PATH/config
    echo 0x03D7E310 1 > $DCC_PATH/config
    echo 0x03D7E340 1 > $DCC_PATH/config
    echo 0x03D7E3B0 1 > $DCC_PATH/config
    echo 0x03D7E3C0 1 > $DCC_PATH/config
    echo 0x03D7E3C4 1 > $DCC_PATH/config
    echo 0x03D7E440 1 > $DCC_PATH/config
    echo 0x03D7E444 1 > $DCC_PATH/config
    echo 0x03D7E448 1 > $DCC_PATH/config
    echo 0x03D7E44C 1 > $DCC_PATH/config
    echo 0x03D7E450 1 > $DCC_PATH/config
    echo 0x03D7E480 1 > $DCC_PATH/config
    echo 0x03D7E484 1 > $DCC_PATH/config
    echo 0x03D7E490 1 > $DCC_PATH/config
    echo 0x03D7E494 1 > $DCC_PATH/config
    echo 0x03D7E4A0 1 > $DCC_PATH/config
    echo 0x03D7E4A4 1 > $DCC_PATH/config
    echo 0x03D7E4B0 1 > $DCC_PATH/config
    echo 0x03D7E4B4 1 > $DCC_PATH/config
    echo 0x03D7E500 1 > $DCC_PATH/config
    echo 0x03D7E508 1 > $DCC_PATH/config
    echo 0x03D7E50C 1 > $DCC_PATH/config
    echo 0x03D7E510 1 > $DCC_PATH/config
    echo 0x03D7E520 1 > $DCC_PATH/config
    echo 0x03D7E524 1 > $DCC_PATH/config
    echo 0x03D7E528 1 > $DCC_PATH/config
    echo 0x03D7E53C 1 > $DCC_PATH/config
    echo 0x03D7E540 1 > $DCC_PATH/config
    echo 0x03D7E544 1 > $DCC_PATH/config
    echo 0x03D7E560 1 > $DCC_PATH/config
    echo 0x03D7E564 1 > $DCC_PATH/config
    echo 0x03D7E568 1 > $DCC_PATH/config
    echo 0x03D7E574 1 > $DCC_PATH/config
    echo 0x03D7E588 1 > $DCC_PATH/config
    echo 0x03D7E590 1 > $DCC_PATH/config
    echo 0x03D7E594 1 > $DCC_PATH/config
    echo 0x03D7E598 1 > $DCC_PATH/config
    echo 0x03D7E59C 1 > $DCC_PATH/config
    echo 0x03D7E5A0 1 > $DCC_PATH/config
    echo 0x03D7E5A4 1 > $DCC_PATH/config
    echo 0x03D7E5A8 1 > $DCC_PATH/config
    echo 0x03D7E5AC 1 > $DCC_PATH/config
    echo 0x03D7E5C0 1 > $DCC_PATH/config
    echo 0x03D7E5C4 1 > $DCC_PATH/config
    echo 0x03D7E5C8 1 > $DCC_PATH/config
    echo 0x03D7E5CC 1 > $DCC_PATH/config
    echo 0x03D7E5D0 1 > $DCC_PATH/config
    echo 0x03D7E5D4 1 > $DCC_PATH/config
    echo 0x03D7E5D8 1 > $DCC_PATH/config
    echo 0x03D7E5DC 1 > $DCC_PATH/config
    echo 0x03D7E5E0 1 > $DCC_PATH/config
    echo 0x03D7E5E4 1 > $DCC_PATH/config
    echo 0x03D7E600 1 > $DCC_PATH/config
    echo 0x03D7E604 1 > $DCC_PATH/config
    echo 0x03D7E610 1 > $DCC_PATH/config
    echo 0x03D7E614 1 > $DCC_PATH/config
    echo 0x03D7E618 1 > $DCC_PATH/config
    echo 0x03D7E648 1 > $DCC_PATH/config
    echo 0x03D7E64C 1 > $DCC_PATH/config
    echo 0x03D7E658 1 > $DCC_PATH/config
    echo 0x03D7E65C 1 > $DCC_PATH/config
    echo 0x03D7E660 1 > $DCC_PATH/config
    echo 0x03D7E664 1 > $DCC_PATH/config
    echo 0x03D7E668 1 > $DCC_PATH/config
    echo 0x03D7E66C 1 > $DCC_PATH/config
    echo 0x03D7E670 1 > $DCC_PATH/config
    echo 0x03D7E674 1 > $DCC_PATH/config
    echo 0x03D7E678 1 > $DCC_PATH/config
    echo 0x03D7E700 1 > $DCC_PATH/config
    echo 0x03D7E714 1 > $DCC_PATH/config
    echo 0x03D7E718 1 > $DCC_PATH/config
    echo 0x03D7E71C 1 > $DCC_PATH/config
    echo 0x03D7E720 1 > $DCC_PATH/config
    echo 0x03D7E724 1 > $DCC_PATH/config
    echo 0x03D7E728 1 > $DCC_PATH/config
    echo 0x03D7E72C 1 > $DCC_PATH/config
    echo 0x03D7E730 1 > $DCC_PATH/config
    echo 0x03D7E734 1 > $DCC_PATH/config
    echo 0x03D7E738 1 > $DCC_PATH/config
    echo 0x03D7E73C 1 > $DCC_PATH/config
    echo 0x03D7E740 1 > $DCC_PATH/config
    echo 0x03D7E744 1 > $DCC_PATH/config
    echo 0x03D7E748 1 > $DCC_PATH/config
    echo 0x03D7E74C 1 > $DCC_PATH/config
    echo 0x03D7E750 1 > $DCC_PATH/config
    echo 0x03D7E7C0 1 > $DCC_PATH/config
    echo 0x03D7E7C4 1 > $DCC_PATH/config
    echo 0x03D7E7E0 1 > $DCC_PATH/config
    echo 0x03D7E7E4 1 > $DCC_PATH/config
    echo 0x03D7E7E8 1 > $DCC_PATH/config

}

config_sdc_wa()
{
    echo 0x00185000 1 > $DCC_PATH/config
    echo 0x00185000 1  > $DCC_PATH/config_write
    echo 0x00185000 1 > $DCC_PATH/config
    echo 0x1084C000 1 1 > $DCC_PATH/config
    echo 0x10C06000 1 1 > $DCC_PATH/config
    echo 0x1084C000 0 1 > $DCC_PATH/config_write
    echo 0x10C06000 0 1 > $DCC_PATH/config_write
    echo 0x1084C000 1 1 > $DCC_PATH/config
    echo 0x10C06000 1 1 > $DCC_PATH/config
    echo 0x01FC4080 3 > $DCC_PATH/config
    echo 0x01FC4090 1 > $DCC_PATH/config
}

config_lpass()
{
    #LPASS RSC
    echo 0x6802028 1 > $DCC_PATH/config
    echo 0x68B0408 1 > $DCC_PATH/config
    echo 0x68B0404 1 > $DCC_PATH/config
    echo 0x7200408 1 > $DCC_PATH/config
    echo 0x7200404 1 > $DCC_PATH/config
}

config_qdsp_lpm()
{
    # LPASS
    echo 0x6802028 1 > $DCC_PATH/config
    echo 0x68B0404 2 > $DCC_PATH/config
    echo 0x68B0208 3 > $DCC_PATH/config
    echo 0x68B0228 3 > $DCC_PATH/config
    echo 0x68B0248 3 > $DCC_PATH/config
    echo 0x68B0268 3 > $DCC_PATH/config
    echo 0x7200404 2 > $DCC_PATH/config
    echo 0x7200208 3 > $DCC_PATH/config
    echo 0x7200228 3 > $DCC_PATH/config
    echo 0x7200248 3 > $DCC_PATH/config
    echo 0x7200268 3 > $DCC_PATH/config

    # NSP
    echo 0x32302028 1 > $DCC_PATH/config
    echo 0x323B0404 2 > $DCC_PATH/config
    echo 0x323B0208 3 > $DCC_PATH/config
    echo 0x323B0228 3 > $DCC_PATH/config
    echo 0x323B0248 3 > $DCC_PATH/config
    echo 0x323B0268 3 > $DCC_PATH/config
    echo 0x320A4404 2 > $DCC_PATH/config
    echo 0x320A4208 3 > $DCC_PATH/config
    echo 0x320A4228 3 > $DCC_PATH/config
    echo 0x320A4248 3 > $DCC_PATH/config
    echo 0x320A4268 3 > $DCC_PATH/config

    # MODEM
    echo 0x4082028 1 > $DCC_PATH/config
    echo 0x4130404 2 > $DCC_PATH/config
    echo 0x4130208 3 > $DCC_PATH/config
    echo 0x4130228 3 > $DCC_PATH/config
    echo 0x4130248 3 > $DCC_PATH/config
    echo 0x4130268 3 > $DCC_PATH/config
    echo 0x4200404 2 > $DCC_PATH/config
    echo 0x4200208 3 > $DCC_PATH/config
    echo 0x4200228 3 > $DCC_PATH/config
    echo 0x4200248 3 > $DCC_PATH/config
    echo 0x4200268 3 > $DCC_PATH/config
}

config_dcc_anoc_pcie()
{
    echo 0x110004 1 > $DCC_PATH/config
    echo 0x110008 1 > $DCC_PATH/config
    echo 0x11003C 1 > $DCC_PATH/config
    echo 0x110040 1 > $DCC_PATH/config
    echo 0x110044 1 > $DCC_PATH/config
    echo 0x11015C 1 > $DCC_PATH/config
    echo 0x110160 1 > $DCC_PATH/config
    echo 0x110464 1 > $DCC_PATH/config
    echo 0x110468 1 > $DCC_PATH/config
    #RPMH_SYS_NOC_CMD_DFSR
    echo 0x176040 1 > $DCC_PATH/config
}

enable_dcc()
{
    #TODO: Add DCC configuration
    DCC_PATH="/sys/bus/platform/devices/100ff000.dcc_v2"
    soc_version=`cat /sys/devices/soc0/revision`
    soc_version=${soc_version/./}

    if [ ! -d $DCC_PATH ]; then
        echo "DCC does not exist on this build."
        return
    fi

    echo 0 > $DCC_PATH/enable
    echo 1 > $DCC_PATH/config_reset
    echo 6 > $DCC_PATH/curr_list
    echo cap > $DCC_PATH/func_type
    echo sram > $DCC_PATH/data_sink
    #config_dcc_tsens
    config_sdc_wa
    config_qdsp_lpm
    config_dcc_core
    #config_smmu

    gemnoc_dump
    config_gpu
    config_dcc_lpm_pcu
    config_dcc_lpm
    config_dcc_ddr
    config_adsp

    echo 4 > $DCC_PATH/curr_list
    echo cap > $DCC_PATH/func_type
    echo sram > $DCC_PATH/data_sink
    dc_noc_dump
    config_lpass
    mmss_noc_dump
    system_noc_dump
    aggre_noc_dump
    config_noc_dump

    config_dcc_gic
    config_dcc_rpmh
    config_dcc_apss_rscc
    config_dcc_misc
    config_dcc_epss
    config_dcc_gict
    config_dcc_anoc_pcie

    #echo 3 > $DCC_PATH/curr_list
    #echo cap > $DCC_PATH/func_type
    #echo sram > $DCC_PATH/data_sink
    #config_confignoc
    #enable_dcc_pll_status

    echo  1 > $DCC_PATH/enable
}

##################################
# ACTPM trace API - usage example
##################################

actpm_traces_configure()
{
  echo ++++++++++++++++++++++++++++++++++++++
  echo actpm_traces_configure
  echo ++++++++++++++++++++++++++++++++++++++

  echo 1 > /sys/bus/coresight/devices/coresight-tpdm-actpm/reset
  ### CMB_MSR : [10]: debug_en, [7:6] : 0x0-0x3 : clkdom0-clkdom3 debug_bus
  ###         : [5]: trace_en, [4]: 0b0:continuous mode 0b1 : legacy mode
  ###         : [3:0] : legacy mode : 0x0 : combined_traces 0x1-0x4 : clkdom0-clkdom3
  echo 0 0x420 > /sys/bus/coresight/devices/coresight-tpdm-actpm/cmb_msr
  echo 0 > /sys/bus/coresight/devices/coresight-tpdm-actpm/mcmb_lanes_select
  echo 1 0 > /sys/bus/coresight/devices/coresight-tpdm-actpm/cmb_mode
  #echo 1 > /sys/bus/coresight/devices/coresight-tpda-actpm/cmbchan_mode
  echo 1 > /sys/bus/coresight/devices/coresight-tpdm-actpm/cmb_ts_all
  echo 1 > /sys/bus/coresight/devices/coresight-tpdm-actpm/cmb_patt_ts
  echo 0 0x20000000 > /sys/bus/coresight/devices/coresight-tpdm-actpm/cmb_patt_mask
  echo 0 0x20000000 > /sys/bus/coresight/devices/coresight-tpdm-actpm/cmb_patt_val

}

actpm_traces_start()
{
  echo ++++++++++++++++++++++++++++++++++++++
  echo actpm_traces_start
  echo ++++++++++++++++++++++++++++++++++++++
  # "Start actpm Trace collection "
  echo 0x4 > /sys/bus/coresight/devices/coresight-tpdm-actpm/enable_datasets
  echo 1 > /sys/bus/coresight/devices/coresight-tpdm-actpm/enable_source
}

stm_traces_configure()
{
  echo ++++++++++++++++++++++++++++++++++++++
  echo stm_traces_configure
  echo ++++++++++++++++++++++++++++++++++++++
  echo 0 > /sys/bus/coresight/devices/coresight-stm/hwevent_enable
}

stm_traces_start()
{
  echo ++++++++++++++++++++++++++++++++++++++
  echo stm_traces_start
  echo ++++++++++++++++++++++++++++++++++++++
  echo 1 > /sys/bus/coresight/devices/coresight-stm/enable_source
}

ipm_traces_configure()
{
  echo 1 > /sys/bus/coresight/devices/coresight-tpdm-apss/reset
  echo 0x0 0x3f 0x1 > /sys/bus/coresight/devices/coresight-tpdm-apss/dsb_edge_ctrl_mask
  echo 0x0 0x3f 0 > /sys/bus/coresight/devices/coresight-tpdm-apss/dsb_edge_ctrl
  #gic HW events
  echo 0xfb 0xfc 0x1 > /sys/bus/coresight/devices/coresight-tpdm-apss/dsb_edge_ctrl_mask
  echo 0xfb 0xfc 0 > /sys/bus/coresight/devices/coresight-tpdm-apss/dsb_edge_ctrl
  echo 0 0x00000000  > /sys/bus/coresight/devices/coresight-tpdm-apss/dsb_msr
  echo 1 0x00000000  > /sys/bus/coresight/devices/coresight-tpdm-apss/dsb_msr
  echo 2 0x00000000  > /sys/bus/coresight/devices/coresight-tpdm-apss/dsb_msr
  echo 3 0x00000000  > /sys/bus/coresight/devices/coresight-tpdm-apss/dsb_msr
  echo 4 0x00000000  > /sys/bus/coresight/devices/coresight-tpdm-apss/dsb_msr
  echo 5 0x00000000  > /sys/bus/coresight/devices/coresight-tpdm-apss/dsb_msr
  echo 6 0x00000000  > /sys/bus/coresight/devices/coresight-tpdm-apss/dsb_msr
  echo 7 0x00000000  > /sys/bus/coresight/devices/coresight-tpdm-apss/dsb_msr
  echo 1 > /sys/bus/coresight/devices/coresight-tpdm-apss/dsb_patt_ts
  echo 1 > /sys/bus/coresight/devices/coresight-tpdm-apss/dsb_patt_type
  echo 0 > /sys/bus/coresight/devices/coresight-tpdm-apss/dsb_trig_ts
  echo 0 0xFFFFFFFF > /sys/bus/coresight/devices/coresight-tpdm-apss/dsb_patt_mask
  echo 1 0xFFFFFFFF > /sys/bus/coresight/devices/coresight-tpdm-apss/dsb_patt_mask
  echo 2 0xFFFFFFFF > /sys/bus/coresight/devices/coresight-tpdm-apss/dsb_patt_mask
  echo 3 0xFFFFFFFF > /sys/bus/coresight/devices/coresight-tpdm-apss/dsb_patt_mask
  echo 4 0xFFFFFFFF > /sys/bus/coresight/devices/coresight-tpdm-apss/dsb_patt_mask
  echo 5 0xFFFFFFFF > /sys/bus/coresight/devices/coresight-tpdm-apss/dsb_patt_mask
  echo 6 0xFFFFFFFF > /sys/bus/coresight/devices/coresight-tpdm-apss/dsb_patt_mask
  echo 7 0xFFFFFFFF > /sys/bus/coresight/devices/coresight-tpdm-apss/dsb_patt_mask

  echo 1 > /sys/bus/coresight/devices/coresight-tpdm-apss-llm/reset
  echo 0x0 0x2 0x1 > /sys/bus/coresight/devices/coresight-tpdm-apss-llm/dsb_edge_ctrl_mask
  echo 0x0 0x2 0 > /sys/bus/coresight/devices/coresight-tpdm-apss-llm/dsb_edge_ctrl
  echo 0x8a 0x8b 0x1 > /sys/bus/coresight/devices/coresight-tpdm-apss-llm/dsb_edge_ctrl_mask
  echo 0x8a 0x8b 0 > /sys/bus/coresight/devices/coresight-tpdm-apss-llm/dsb_edge_ctrl
  echo 0xb8 0xca 0x1 > /sys/bus/coresight/devices/coresight-tpdm-apss-llm/dsb_edge_ctrl_mask
  echo 0xb8 0xca 0 > /sys/bus/coresight/devices/coresight-tpdm-apss-llm/dsb_edge_ctrl
  echo 1 > /sys/bus/coresight/devices/coresight-tpdm-apss-llm/dsb_patt_ts
  echo 1 > /sys/bus/coresight/devices/coresight-tpdm-apss-llm/dsb_patt_type
  echo 0 > /sys/bus/coresight/devices/coresight-tpdm-apss-llm/dsb_trig_ts
  echo 0 0xFFFFFFFF > /sys/bus/coresight/devices/coresight-tpdm-apss-llm/dsb_patt_mask
  echo 1 0xFFFFFFFF > /sys/bus/coresight/devices/coresight-tpdm-apss-llm/dsb_patt_mask
  echo 2 0xFFFFFFFF > /sys/bus/coresight/devices/coresight-tpdm-apss-llm/dsb_patt_mask
  echo 3 0xFFFFFFFF > /sys/bus/coresight/devices/coresight-tpdm-apss-llm/dsb_patt_mask
  echo 4 0xFFFFFFFF > /sys/bus/coresight/devices/coresight-tpdm-apss-llm/dsb_patt_mask
  echo 5 0xFFFFFFFF > /sys/bus/coresight/devices/coresight-tpdm-apss-llm/dsb_patt_mask
  echo 6 0xFFFFFFFF > /sys/bus/coresight/devices/coresight-tpdm-apss-llm/dsb_patt_mask
  echo 7 0xFFFFFFFF > /sys/bus/coresight/devices/coresight-tpdm-apss-llm/dsb_patt_mask

}

ipm_traces_start()
{
  # "Start ipm Trace collection "
  echo 2 > /sys/bus/coresight/devices/coresight-tpdm-apss/enable_datasets
  echo 1 > /sys/bus/coresight/devices/coresight-tpdm-apss/enable_source
  echo 2 > /sys/bus/coresight/devices/coresight-tpdm-apss-llm/enable_datasets
  echo 1 > /sys/bus/coresight/devices/coresight-tpdm-apss-llm/enable_source

}

enable_cpuss_hw_events()
{
    actpm_traces_configure
    ipm_traces_configure
    stm_traces_configure

    ipm_traces_start
    stm_traces_start
    actpm_traces_start
}

adjust_permission()
{
    #add permission for block_size, mem_type, mem_size nodes to collect diag over QDSS by ODL
    #application by "oem_2902" group
    chown -h root.oem_2902 /sys/devices/platform/soc/10048000.tmc/coresight-tmc-etr/block_size
    chmod 660 /sys/devices/platform/soc/10048000.tmc/coresight-tmc-etr/block_size
    chown -h root.oem_2902 /sys/devices/platform/soc/10048000.tmc/coresight-tmc-etr/buffer_size
    chmod 660 /sys/devices/platform/soc/10048000.tmc/coresight-tmc-etr/buffer_size
    chmod 660 /sys/devices/platform/soc/10048000.tmc/coresight-tmc-etr/out_mode
    chown -h root.oem_2902 /sys/devices/platform/soc/1004f000.tmc/coresight-tmc-etr1/block_size
    chmod 660 /sys/devices/platform/soc/1004f000.tmc/coresight-tmc-etr1/block_size
    chown -h root.oem_2902 /sys/devices/platform/soc/1004f000.tmc/coresight-tmc-etr1/buffer_size
    chmod 660 /sys/devices/platform/soc/1004f000.tmc/coresight-tmc-etr1/buffer_size
    chmod 660 /sys/devices/platform/soc/1004f000.tmc/coresight-tmc-etr1/out_mode
    chmod 660 /sys/devices/platform/soc/1004f000.tmc/coresight-tmc-etr1/enable_sink
    chmod 660 /sys/devices/platform/soc/soc:modem_diag/coresight-modem-diag/enable_source
    chown -h root.oem_2902 /sys/bus/coresight/reset_source_sink
    chmod 660 /sys/bus/coresight/reset_source_sink
}

enable_schedstats()
{
    # bail out if its perf config
    if [ ! -d /sys/module/msm_rtb ]
    then
        return
    fi

    if [ -f /proc/sys/kernel/sched_schedstats ]
    then
        echo 1 > /proc/sys/kernel/sched_schedstats
    fi
}

enable_cpuss_register()
{
	echo 1 > /sys/bus/platform/devices/soc:mem_dump/register_reset

	echo 0x17000000 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17000008 0x48 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17000054 0x20 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x170000f0 0xc > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17000100 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17008000 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17100000 0x10 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17100020 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17100030 0xc > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17100084 0x74 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17100104 0x74 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17100184 0x74 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17100204 0x74 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17100284 0x74 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17100304 0x74 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17100384 0x74 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17100420 0x3a0 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17100c08 0xe8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17100d04 0x74 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17100e08 0xe8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106100 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106108 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106110 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106118 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106120 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106128 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106130 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106138 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106140 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106148 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106150 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106158 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106160 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106168 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106170 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106178 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106180 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106188 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106190 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106198 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171061a0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171061a8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171061b0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171061b8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171061c0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171061c8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171061d0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171061d8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171061e0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171061e8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171061f0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171061f8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106200 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106208 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106210 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106218 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106220 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106228 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106230 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106238 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106240 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106248 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106250 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106258 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106260 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106268 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106270 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106278 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106280 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106288 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106290 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106298 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171062a0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171062a8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171062b0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171062b8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171062c0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171062c8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171062d0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171062d8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171062e0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171062e8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171062f0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171062f8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106300 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106308 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106310 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106318 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106320 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106328 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106330 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106338 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106340 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106348 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106350 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106358 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106360 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106368 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106370 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106378 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106380 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106388 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106390 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106398 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171063a0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171063a8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171063b0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171063b8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171063c0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171063c8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171063d0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171063d8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171063e0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171063e8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171063f0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171063f8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106400 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106408 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106410 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106418 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106420 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106428 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106430 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106438 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106440 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106448 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106450 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106458 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106460 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106468 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106470 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106478 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106480 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106488 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106490 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106498 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171064a0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171064a8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171064b0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171064b8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171064c0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171064c8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171064d0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171064d8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171064e0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171064e8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171064f0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171064f8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106500 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106508 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106510 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106518 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106520 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106528 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106530 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106538 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106540 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106548 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106550 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106558 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106560 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106568 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106570 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106578 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106580 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106588 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106590 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106598 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171065a0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171065a8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171065b0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171065b8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171065c0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171065c8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171065d0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171065d8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171065e0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171065e8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171065f0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171065f8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106600 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106608 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106610 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106618 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106620 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106628 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106630 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106638 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106640 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106648 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106650 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106658 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106660 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106668 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106670 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106678 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106680 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106688 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106690 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106698 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171066a0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171066a8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171066b0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171066b8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171066c0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171066c8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171066d0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171066d8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171066e0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171066e8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171066f0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171066f8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106700 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106708 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106710 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106718 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106720 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106728 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106730 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106738 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106740 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106748 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106750 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106758 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106760 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106768 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106770 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106778 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106780 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106788 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106790 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106798 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171067a0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171067a8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171067b0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171067b8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171067c0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171067c8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171067d0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171067d8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171067e0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171067e8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171067f0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171067f8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106800 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106808 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106810 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106818 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106820 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106828 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106830 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106838 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106840 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106848 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106850 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106858 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106860 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106868 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106870 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106878 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106880 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106888 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106890 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106898 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171068a0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171068a8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171068b0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171068b8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171068c0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171068c8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171068d0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171068d8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171068e0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171068e8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171068f0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171068f8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106900 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106908 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106910 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106918 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106920 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106928 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106930 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106938 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106940 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106948 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106950 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106958 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106960 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106968 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106970 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106978 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106980 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106988 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106990 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106998 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171069a0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171069a8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171069b0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171069b8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171069c0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171069c8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171069d0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171069d8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171069e0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171069e8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171069f0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171069f8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106a00 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106a08 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106a10 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106a18 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106a20 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106a28 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106a30 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106a38 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106a40 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106a48 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106a50 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106a58 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106a60 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106a68 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106a70 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106a78 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106a80 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106a88 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106a90 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106a98 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106aa0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106aa8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106ab0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106ab8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106ac0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106ac8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106ad0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106ad8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106ae0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106ae8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106af0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106af8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106b00 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106b08 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106b10 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106b18 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106b20 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106b28 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106b30 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106b38 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106b40 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106b48 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106b50 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106b58 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106b60 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106b68 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106b70 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106b78 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106b80 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106b88 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106b90 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106b98 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106ba0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106ba8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106bb0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106bb8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106bc0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106bc8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106bd0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106bd8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106be0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106be8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106bf0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106bf8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106c00 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106c08 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106c10 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106c18 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106c20 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106c28 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106c30 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106c38 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106c40 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106c48 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106c50 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106c58 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106c60 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106c68 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106c70 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106c78 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106c80 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106c88 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106c90 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106c98 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106ca0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106ca8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106cb0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106cb8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106cc0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106cc8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106cd0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106cd8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106ce0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106ce8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106cf0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106cf8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106d00 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106d08 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106d10 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106d18 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106d20 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106d28 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106d30 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106d38 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106d40 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106d48 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106d50 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106d58 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106d60 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106d68 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106d70 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106d78 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106d80 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106d88 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106d90 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106d98 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106da0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106da8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106db0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106db8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106dc0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106dc8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106dd0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106dd8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106de0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106de8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106df0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106df8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106e00 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106e08 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106e10 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106e18 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106e20 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106e28 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106e30 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106e38 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106e40 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106e48 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106e50 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106e58 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106e60 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106e68 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106e70 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106e78 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106e80 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106e88 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106e90 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106e98 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106ea0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106ea8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106eb0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106eb8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106ec0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106ec8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106ed0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106ed8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106ee0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106ee8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106ef0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106ef8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106f00 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106f08 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106f10 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106f18 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106f20 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106f28 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106f30 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106f38 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106f40 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106f48 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106f50 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106f58 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106f60 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106f68 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106f70 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106f78 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106f80 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106f88 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106f90 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106f98 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106fa0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106fa8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106fb0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106fb8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106fc0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106fc8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106fd0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106fd8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106fe0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106fe8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106ff0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17106ff8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107000 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107008 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107010 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107018 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107020 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107028 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107030 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107038 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107040 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107048 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107050 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107058 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107060 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107068 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107070 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107078 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107080 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107088 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107090 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107098 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171070a0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171070a8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171070b0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171070b8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171070c0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171070c8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171070d0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171070d8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171070e0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171070e8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171070f0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171070f8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107100 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107108 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107110 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107118 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107120 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107128 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107130 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107138 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107140 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107148 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107150 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107158 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107160 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107168 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107170 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107178 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107180 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107188 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107190 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107198 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171071a0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171071a8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171071b0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171071b8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171071c0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171071c8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171071d0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171071d8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171071e0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171071e8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171071f0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171071f8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107200 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107208 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107210 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107218 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107220 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107228 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107230 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107238 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107240 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107248 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107250 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107258 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107260 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107268 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107270 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107278 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107280 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107288 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107290 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107298 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171072a0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171072a8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171072b0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171072b8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171072c0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171072c8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171072d0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171072d8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171072e0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171072e8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171072f0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171072f8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107300 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107308 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107310 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107318 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107320 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107328 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107330 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107338 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107340 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107348 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107350 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107358 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107360 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107368 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107370 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107378 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107380 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107388 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107390 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107398 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171073a0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171073a8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171073b0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171073b8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171073c0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171073c8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171073d0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171073d8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171073e0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171073e8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171073f0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171073f8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107400 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107408 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107410 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107418 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107420 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107428 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107430 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107438 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107440 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107448 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107450 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107458 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107460 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107468 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107470 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107478 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107480 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107488 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107490 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107498 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171074a0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171074a8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171074b0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171074b8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171074c0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171074c8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171074d0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171074d8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171074e0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171074e8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171074f0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171074f8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107500 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107508 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107510 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107518 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107520 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107528 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107530 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107538 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107540 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107548 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107550 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107558 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107560 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107568 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107570 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107578 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107580 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107588 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107590 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107598 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171075a0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171075a8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171075b0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171075b8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171075c0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171075c8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171075d0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171075d8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171075e0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171075e8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171075f0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171075f8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107600 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107608 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107610 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107618 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107620 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107628 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107630 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107638 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107640 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107648 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107650 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107658 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107660 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107668 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107670 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107678 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107680 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107688 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107690 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107698 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171076a0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171076a8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171076b0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171076b8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171076c0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171076c8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171076d0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171076d8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171076e0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171076e8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171076f0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171076f8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107700 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107708 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107710 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107718 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107720 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107728 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107730 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107738 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107740 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107748 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107750 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107758 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107760 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107768 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107770 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107778 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107780 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107788 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107790 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107798 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171077a0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171077a8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171077b0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171077b8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171077c0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171077c8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171077d0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171077d8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171077e0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171077e8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171077f0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171077f8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107800 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107808 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107810 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107818 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107820 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107828 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107830 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107838 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107840 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107848 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107850 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107858 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107860 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107868 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107870 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107878 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107880 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107888 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107890 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107898 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171078a0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171078a8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171078b0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171078b8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171078c0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171078c8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171078d0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171078d8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171078e0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171078e8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171078f0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171078f8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107900 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107908 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107910 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107918 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107920 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107928 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107930 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107938 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107940 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107948 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107950 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107958 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107960 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107968 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107970 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107978 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107980 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107988 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107990 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107998 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171079a0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171079a8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171079b0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171079b8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171079c0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171079c8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171079d0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171079d8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171079e0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171079e8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171079f0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171079f8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107a00 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107a08 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107a10 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107a18 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107a20 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107a28 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107a30 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107a38 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107a40 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107a48 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107a50 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107a58 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107a60 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107a68 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107a70 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107a78 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107a80 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107a88 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107a90 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107a98 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107aa0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107aa8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107ab0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107ab8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107ac0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107ac8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107ad0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107ad8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107ae0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107ae8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107af0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107af8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107b00 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107b08 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107b10 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107b18 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107b20 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107b28 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107b30 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107b38 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107b40 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107b48 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107b50 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107b58 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107b60 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107b68 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107b70 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107b78 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107b80 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107b88 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107b90 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107b98 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107ba0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107ba8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107bb0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107bb8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107bc0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107bc8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107bd0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107bd8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107be0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107be8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107bf0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107bf8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107c00 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107c08 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107c10 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107c18 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107c20 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107c28 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107c30 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107c38 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107c40 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107c48 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107c50 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107c58 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107c60 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107c68 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107c70 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107c78 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107c80 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107c88 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107c90 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107c98 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107ca0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107ca8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107cb0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107cb8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107cc0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107cc8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107cd0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107cd8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107ce0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107ce8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107cf0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107cf8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107d00 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107d08 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107d10 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107d18 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107d20 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107d28 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107d30 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107d38 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107d40 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107d48 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107d50 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107d58 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107d60 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107d68 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107d70 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107d78 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107d80 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107d88 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107d90 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107d98 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107da0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107da8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107db0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107db8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107dc0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107dc8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107dd0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107dd8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107de0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107de8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107df0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17107df8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1710e008 0xe8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1710e104 0x74 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1710e184 0x74 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1710e204 0x74 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1710ea00 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1710ea08 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1710ea10 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1710ea18 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1710ea20 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1710ea28 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1710ea30 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1710ea38 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1710ea40 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1710ea48 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1710ea50 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1710ea58 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1710ea60 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1710ea68 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1710ea70 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1710f000 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1710ffd0 0x30 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17110008 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17110fcc 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1711ffd0 0x34 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17120008 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17120010 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17120018 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17120020 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17120028 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17120040 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17120048 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17120050 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17120058 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17120060 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17120068 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17120080 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17120088 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17120090 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17120098 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171200a0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171200a8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171200c0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171200c8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171200d0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171200d8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171200e0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171200e8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17120100 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17120108 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17120110 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17120118 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17120120 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17120128 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17120140 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17120148 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17120150 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17120158 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17120160 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17120168 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17120180 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17120188 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17120190 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17120198 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171201a0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171201a8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171201c0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171201c8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171201d0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171201d8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171201e0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171201e8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17120200 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17120208 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17120210 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17120218 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17120220 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17120228 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17120240 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17120248 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17120250 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17120258 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17120260 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17120268 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17120280 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17120288 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17120290 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17120298 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171202a0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171202a8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171202c0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171202c8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171202d0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171202d8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171202e0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171202e8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17120300 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17120308 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17120310 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17120318 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17120320 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17120328 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17120340 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17120348 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17120350 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17120358 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17120360 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17120368 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17120380 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17120388 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17120390 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17120398 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171203a0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171203a8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171203c0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171203c8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171203d0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171203d8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171203e0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171203e8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17120400 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17120408 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17120410 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17120418 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17120420 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17120428 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17120440 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17120448 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17120450 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17120458 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17120460 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17120468 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17120480 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17120488 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17120490 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17120498 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171204a0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171204a8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171204c0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171204c8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171204d0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171204d8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171204e0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171204e8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17120500 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17120508 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17120510 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17120518 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17120520 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17120528 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17120540 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17120548 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17120550 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17120558 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17120560 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17120568 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17120580 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17120588 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17120590 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17120598 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171205a0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171205a8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171205c0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171205c8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171205d0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171205d8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171205e0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171205e8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17120600 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17120608 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17120610 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17120618 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17120620 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17120628 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17120640 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17120648 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17120650 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17120658 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17120660 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17120668 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17120680 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17120688 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17120690 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17120698 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171206a0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171206a8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171206c0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171206c8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171206d0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171206d8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171206e0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171206e8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1712e000 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1712e800 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1712e808 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1712ffbc 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1712ffc8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1712ffd0 0x44 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17130400 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17130600 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17130a00 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17130c00 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17130c20 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17130c40 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17130c60 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17130c80 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17130cc0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17130e00 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17130e50 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17130fb8 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17130fcc 0x34 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17140000 0xc > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17140010 0xc > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17140020 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17140028 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17140030 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17140080 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17140088 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17140090 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17140100 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17140108 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17140110 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1714c000 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1714c008 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1714c010 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1714f000 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1714ffd0 0x30 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17180000 0xc > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17180014 0x18 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17180070 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17180078 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171800c0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1718ffd0 0x30 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17190080 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17190100 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17190180 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17190200 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17190280 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17190300 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17190380 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17190400 0x40 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17190c00 0x10 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17190d00 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17190e00 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1719c000 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1719c008 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1719c010 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1719c018 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1719c100 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1719c180 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1719f000 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1719f010 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171a0070 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171a0078 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171a0088 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171a0120 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171ac000 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171ac100 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171ae100 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171c0000 0xc > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171c0014 0x18 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171c0070 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171c0078 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171c00c0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171cffd0 0x30 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171d0080 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171d0100 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171d0180 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171d0200 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171d0280 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171d0300 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171d0380 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171d0400 0x40 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171d0c00 0x10 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171d0d00 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171d0e00 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171dc000 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171dc008 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171dc010 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171dc018 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171dc100 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171dc180 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171df000 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171df010 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171e0070 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171e0078 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171e0088 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171e0120 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171ec000 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171ec100 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x171ee100 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17200000 0xc > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17200014 0x18 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17200070 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17200078 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x172000c0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1720ffd0 0x30 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17210080 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17210100 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17210180 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17210200 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17210280 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17210300 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17210380 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17210400 0x40 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17210c00 0x10 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17210d00 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17210e00 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1721c000 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1721c008 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1721c010 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1721c018 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1721c100 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1721c180 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1721f000 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1721f010 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17220070 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17220078 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17220088 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17220120 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1722c000 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1722c100 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1722e100 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17240000 0xc > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17240014 0x18 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17240070 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17240078 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x172400c0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1724ffd0 0x30 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17250080 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17250100 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17250180 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17250200 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17250280 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17250300 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17250380 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17250400 0x40 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17250c00 0x10 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17250d00 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17250e00 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1725c000 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1725c008 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1725c010 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1725c018 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1725c100 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1725c180 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1725f000 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1725f010 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17260070 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17260078 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17260088 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17260120 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1726c000 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1726c100 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1726e100 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17280000 0xc > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17280014 0x18 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17280070 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17280078 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x172800c0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1728ffd0 0x30 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17290080 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17290100 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17290180 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17290200 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17290280 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17290300 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17290380 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17290400 0x40 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17290c00 0x10 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17290d00 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17290e00 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1729c000 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1729c008 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1729c010 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1729c018 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1729c100 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1729c180 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1729f000 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1729f010 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x172a0070 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x172a0078 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x172a0088 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x172a0120 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x172ac000 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x172ac100 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x172ae100 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x172c0000 0xc > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x172c0014 0x18 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x172c0070 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x172c0078 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x172c00c0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x172cffd0 0x30 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x172d0080 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x172d0100 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x172d0180 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x172d0200 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x172d0280 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x172d0300 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x172d0380 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x172d0400 0x40 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x172d0c00 0x10 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x172d0d00 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x172d0e00 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x172dc000 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x172dc008 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x172dc010 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x172dc018 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x172dc100 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x172dc180 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x172df000 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x172df010 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x172e0070 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x172e0078 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x172e0088 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x172e0120 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x172ec000 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x172ec100 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x172ee100 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17300000 0xc > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17300014 0x18 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17300070 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17300078 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173000c0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1730ffd0 0x30 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17310080 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17310100 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17310180 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17310200 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17310280 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17310300 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17310380 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17310400 0x40 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17310c00 0x10 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17310d00 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17310e00 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1731c000 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1731c008 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1731c010 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1731c018 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1731c100 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1731c180 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1731f000 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1731f010 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17320070 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17320078 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17320088 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17320120 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1732c000 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1732c100 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1732e100 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17340000 0xc > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17340014 0x18 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17340070 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17340078 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173400c0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1734ffd0 0x30 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17350080 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17350100 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17350180 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17350200 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17350280 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17350300 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17350380 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17350400 0x40 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17350c00 0x10 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17350d00 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17350e00 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1735c000 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1735c008 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1735c010 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1735c018 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1735c100 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1735c180 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1735f000 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1735f010 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17360070 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17360078 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17360088 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17360120 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1736c000 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1736c100 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1736e100 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17380000 0x10 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17380020 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17380030 0xc > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17380084 0x74 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17380104 0x74 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17380184 0x74 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17380204 0x74 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17380284 0x74 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17380304 0x74 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17380384 0x74 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17380420 0x3a0 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17380c08 0xe8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17380d04 0x74 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17380e08 0xe8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386100 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386108 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386110 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386118 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386120 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386128 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386130 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386138 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386140 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386148 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386150 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386158 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386160 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386168 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386170 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386178 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386180 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386188 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386190 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386198 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173861a0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173861a8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173861b0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173861b8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173861c0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173861c8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173861d0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173861d8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173861e0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173861e8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173861f0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173861f8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386200 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386208 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386210 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386218 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386220 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386228 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386230 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386238 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386240 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386248 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386250 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386258 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386260 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386268 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386270 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386278 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386280 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386288 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386290 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386298 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173862a0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173862a8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173862b0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173862b8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173862c0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173862c8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173862d0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173862d8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173862e0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173862e8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173862f0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173862f8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386300 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386308 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386310 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386318 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386320 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386328 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386330 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386338 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386340 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386348 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386350 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386358 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386360 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386368 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386370 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386378 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386380 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386388 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386390 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386398 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173863a0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173863a8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173863b0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173863b8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173863c0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173863c8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173863d0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173863d8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173863e0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173863e8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173863f0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173863f8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386400 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386408 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386410 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386418 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386420 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386428 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386430 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386438 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386440 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386448 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386450 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386458 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386460 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386468 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386470 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386478 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386480 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386488 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386490 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386498 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173864a0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173864a8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173864b0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173864b8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173864c0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173864c8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173864d0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173864d8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173864e0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173864e8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173864f0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173864f8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386500 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386508 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386510 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386518 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386520 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386528 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386530 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386538 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386540 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386548 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386550 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386558 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386560 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386568 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386570 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386578 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386580 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386588 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386590 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386598 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173865a0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173865a8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173865b0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173865b8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173865c0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173865c8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173865d0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173865d8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173865e0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173865e8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173865f0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173865f8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386600 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386608 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386610 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386618 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386620 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386628 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386630 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386638 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386640 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386648 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386650 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386658 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386660 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386668 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386670 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386678 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386680 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386688 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386690 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386698 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173866a0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173866a8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173866b0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173866b8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173866c0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173866c8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173866d0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173866d8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173866e0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173866e8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173866f0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173866f8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386700 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386708 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386710 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386718 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386720 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386728 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386730 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386738 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386740 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386748 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386750 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386758 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386760 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386768 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386770 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386778 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386780 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386788 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386790 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386798 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173867a0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173867a8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173867b0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173867b8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173867c0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173867c8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173867d0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173867d8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173867e0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173867e8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173867f0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173867f8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386800 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386808 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386810 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386818 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386820 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386828 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386830 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386838 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386840 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386848 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386850 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386858 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386860 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386868 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386870 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386878 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386880 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386888 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386890 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386898 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173868a0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173868a8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173868b0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173868b8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173868c0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173868c8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173868d0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173868d8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173868e0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173868e8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173868f0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173868f8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386900 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386908 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386910 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386918 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386920 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386928 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386930 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386938 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386940 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386948 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386950 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386958 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386960 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386968 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386970 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386978 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386980 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386988 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386990 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386998 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173869a0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173869a8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173869b0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173869b8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173869c0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173869c8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173869d0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173869d8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173869e0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173869e8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173869f0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173869f8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386a00 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386a08 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386a10 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386a18 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386a20 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386a28 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386a30 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386a38 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386a40 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386a48 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386a50 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386a58 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386a60 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386a68 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386a70 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386a78 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386a80 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386a88 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386a90 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386a98 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386aa0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386aa8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386ab0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386ab8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386ac0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386ac8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386ad0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386ad8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386ae0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386ae8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386af0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386af8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386b00 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386b08 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386b10 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386b18 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386b20 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386b28 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386b30 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386b38 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386b40 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386b48 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386b50 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386b58 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386b60 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386b68 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386b70 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386b78 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386b80 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386b88 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386b90 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386b98 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386ba0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386ba8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386bb0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386bb8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386bc0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386bc8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386bd0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386bd8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386be0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386be8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386bf0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386bf8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386c00 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386c08 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386c10 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386c18 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386c20 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386c28 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386c30 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386c38 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386c40 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386c48 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386c50 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386c58 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386c60 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386c68 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386c70 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386c78 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386c80 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386c88 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386c90 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386c98 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386ca0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386ca8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386cb0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386cb8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386cc0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386cc8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386cd0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386cd8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386ce0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386ce8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386cf0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386cf8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386d00 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386d08 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386d10 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386d18 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386d20 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386d28 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386d30 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386d38 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386d40 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386d48 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386d50 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386d58 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386d60 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386d68 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386d70 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386d78 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386d80 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386d88 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386d90 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386d98 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386da0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386da8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386db0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386db8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386dc0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386dc8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386dd0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386dd8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386de0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386de8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386df0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386df8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386e00 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386e08 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386e10 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386e18 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386e20 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386e28 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386e30 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386e38 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386e40 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386e48 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386e50 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386e58 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386e60 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386e68 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386e70 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386e78 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386e80 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386e88 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386e90 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386e98 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386ea0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386ea8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386eb0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386eb8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386ec0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386ec8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386ed0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386ed8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386ee0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386ee8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386ef0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386ef8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386f00 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386f08 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386f10 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386f18 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386f20 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386f28 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386f30 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386f38 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386f40 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386f48 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386f50 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386f58 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386f60 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386f68 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386f70 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386f78 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386f80 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386f88 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386f90 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386f98 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386fa0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386fa8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386fb0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386fb8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386fc0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386fc8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386fd0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386fd8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386fe0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386fe8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386ff0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17386ff8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387000 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387008 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387010 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387018 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387020 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387028 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387030 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387038 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387040 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387048 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387050 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387058 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387060 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387068 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387070 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387078 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387080 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387088 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387090 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387098 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173870a0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173870a8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173870b0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173870b8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173870c0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173870c8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173870d0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173870d8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173870e0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173870e8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173870f0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173870f8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387100 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387108 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387110 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387118 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387120 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387128 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387130 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387138 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387140 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387148 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387150 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387158 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387160 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387168 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387170 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387178 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387180 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387188 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387190 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387198 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173871a0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173871a8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173871b0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173871b8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173871c0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173871c8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173871d0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173871d8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173871e0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173871e8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173871f0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173871f8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387200 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387208 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387210 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387218 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387220 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387228 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387230 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387238 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387240 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387248 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387250 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387258 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387260 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387268 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387270 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387278 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387280 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387288 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387290 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387298 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173872a0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173872a8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173872b0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173872b8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173872c0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173872c8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173872d0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173872d8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173872e0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173872e8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173872f0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173872f8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387300 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387308 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387310 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387318 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387320 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387328 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387330 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387338 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387340 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387348 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387350 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387358 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387360 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387368 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387370 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387378 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387380 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387388 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387390 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387398 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173873a0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173873a8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173873b0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173873b8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173873c0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173873c8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173873d0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173873d8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173873e0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173873e8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173873f0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173873f8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387400 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387408 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387410 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387418 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387420 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387428 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387430 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387438 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387440 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387448 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387450 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387458 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387460 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387468 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387470 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387478 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387480 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387488 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387490 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387498 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173874a0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173874a8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173874b0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173874b8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173874c0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173874c8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173874d0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173874d8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173874e0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173874e8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173874f0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173874f8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387500 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387508 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387510 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387518 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387520 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387528 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387530 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387538 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387540 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387548 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387550 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387558 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387560 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387568 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387570 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387578 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387580 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387588 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387590 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387598 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173875a0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173875a8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173875b0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173875b8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173875c0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173875c8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173875d0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173875d8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173875e0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173875e8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173875f0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173875f8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387600 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387608 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387610 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387618 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387620 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387628 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387630 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387638 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387640 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387648 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387650 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387658 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387660 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387668 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387670 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387678 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387680 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387688 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387690 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387698 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173876a0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173876a8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173876b0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173876b8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173876c0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173876c8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173876d0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173876d8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173876e0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173876e8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173876f0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173876f8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387700 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387708 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387710 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387718 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387720 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387728 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387730 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387738 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387740 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387748 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387750 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387758 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387760 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387768 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387770 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387778 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387780 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387788 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387790 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387798 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173877a0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173877a8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173877b0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173877b8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173877c0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173877c8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173877d0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173877d8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173877e0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173877e8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173877f0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173877f8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387800 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387808 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387810 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387818 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387820 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387828 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387830 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387838 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387840 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387848 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387850 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387858 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387860 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387868 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387870 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387878 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387880 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387888 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387890 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387898 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173878a0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173878a8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173878b0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173878b8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173878c0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173878c8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173878d0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173878d8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173878e0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173878e8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173878f0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173878f8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387900 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387908 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387910 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387918 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387920 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387928 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387930 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387938 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387940 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387948 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387950 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387958 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387960 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387968 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387970 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387978 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387980 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387988 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387990 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387998 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173879a0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173879a8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173879b0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173879b8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173879c0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173879c8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173879d0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173879d8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173879e0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173879e8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173879f0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x173879f8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387a00 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387a08 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387a10 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387a18 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387a20 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387a28 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387a30 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387a38 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387a40 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387a48 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387a50 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387a58 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387a60 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387a68 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387a70 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387a78 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387a80 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387a88 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387a90 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387a98 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387aa0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387aa8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387ab0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387ab8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387ac0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387ac8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387ad0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387ad8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387ae0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387ae8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387af0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387af8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387b00 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387b08 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387b10 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387b18 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387b20 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387b28 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387b30 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387b38 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387b40 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387b48 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387b50 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387b58 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387b60 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387b68 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387b70 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387b78 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387b80 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387b88 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387b90 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387b98 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387ba0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387ba8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387bb0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387bb8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387bc0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387bc8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387bd0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387bd8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387be0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387be8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387bf0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387bf8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387c00 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387c08 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387c10 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387c18 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387c20 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387c28 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387c30 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387c38 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387c40 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387c48 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387c50 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387c58 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387c60 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387c68 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387c70 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387c78 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387c80 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387c88 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387c90 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387c98 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387ca0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387ca8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387cb0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387cb8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387cc0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387cc8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387cd0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387cd8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387ce0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387ce8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387cf0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387cf8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387d00 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387d08 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387d10 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387d18 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387d20 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387d28 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387d30 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387d38 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387d40 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387d48 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387d50 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387d58 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387d60 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387d68 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387d70 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387d78 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387d80 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387d88 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387d90 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387d98 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387da0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387da8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387db0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387db8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387dc0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387dc8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387dd0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387dd8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387de0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387de8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387df0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17387df8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1738e008 0xe8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1738e104 0x74 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1738e184 0x74 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1738e204 0x74 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1738ea00 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1738ea08 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1738ea10 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1738ea18 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1738ea20 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1738ea28 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1738ea30 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1738ea38 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1738ea40 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1738ea48 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1738ea50 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1738ea58 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1738ea60 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1738ea68 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1738ea70 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1738f000 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1738ffd0 0x30 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17400004 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17400038 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17400044 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x174000f0 0x84 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17400200 0x84 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17400438 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17400444 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17410000 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1741000c 0x10 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17410020 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17411000 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1741100c 0x10 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17411020 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17420000 0xc > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17420040 0x1c > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17420080 0x38 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17420fc0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17420fd0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17420fe0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17420ff0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17421000 0x40 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17421fd0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17422000 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17422020 0x20 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17422fd0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17423000 0x40 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17423fd0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17425000 0x40 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17425fd0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17426000 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17426020 0x20 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17426fd0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17427000 0x40 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17427fd0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17429000 0x40 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17429fd0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1742b000 0x40 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1742bfd0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1742d000 0x40 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1742dfd0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17600004 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17600010 0xc > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17600024 0xc > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17600034 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17600040 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17600050 0xc > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17600080 0xc > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17600094 0x40 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x176000d8 0x54 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17600134 0x28 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17600160 0xc > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17600170 0xc > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17600180 0x10 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17600210 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17600234 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17600240 0x2c > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x176002b4 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17600404 0xc > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1760041c 0xc > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17600434 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1760043c 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17600460 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17600470 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17600480 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17600490 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x176004a0 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x176004b0 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x176004c0 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x176004d0 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x176004e0 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x176004f0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17600500 0x34 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17600600 0x28 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x176009fc 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17601000 0x30 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17602000 0x104 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17603000 0x30 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17604000 0x104 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17605000 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17606000 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17607000 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17608004 0xc > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17608020 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1760f000 0x5c > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17610000 0xc > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17610010 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17610020 0x20 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17611000 0xc > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17611010 0xc > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17612000 0xc > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17612010 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17612018 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17612040 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17612200 0xc > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17612210 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17612400 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17612490 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17614000 0x10 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17614100 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17614208 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17614304 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17614500 0x18 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17615000 0x20 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17615030 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17615040 0x20 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17615070 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17615080 0x20 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x176150b0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x176150c0 0x20 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x176150f0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17615100 0x20 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17615130 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17615140 0x20 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17615170 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17615180 0x20 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x176151b0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x176151c0 0x20 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x176151f0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17615200 0x20 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17615230 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17615240 0x20 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17615270 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17615280 0x20 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x176152b0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x176152c0 0x20 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x176152f0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17615300 0x20 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17615330 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17615340 0x20 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17615370 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17615380 0x20 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x176153b0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x176153c0 0x20 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x176153f0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17615400 0x20 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17615430 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17615440 0x20 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17615470 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17615480 0x20 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x176154b0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x176154c0 0x20 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x176154f0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17615500 0x20 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17615530 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17615540 0x20 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17615570 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17615580 0x20 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x176155b0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x176155c0 0x20 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x176155f0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17615600 0x20 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17615630 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17615640 0x20 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17615670 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17615680 0x20 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x176156b0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x176156c0 0x20 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x176156f0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17615700 0x20 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17615730 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17615740 0x20 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17615770 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17615780 0x20 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x176157b0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x176157c0 0x20 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x176157f0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17615800 0x20 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17615830 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17615840 0x20 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17615870 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17615880 0x20 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x176158b0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x176158c0 0x20 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x176158f0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17615900 0x20 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17615930 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17615940 0x20 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17615970 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17615980 0x20 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x176159b0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x176159c0 0x20 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x176159f0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17615a00 0x20 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17615a30 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17615a40 0x20 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17615a70 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17615a80 0x20 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17615ab0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17615ac0 0x20 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17615af0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17615b00 0x20 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17615b30 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17615b40 0x20 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17615b70 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17615b80 0x20 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17615bb0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17615bc0 0x20 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17615bf0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17618000 0x10 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17618100 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17618208 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17618304 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17618500 0x18 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17619000 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1761900c 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17619014 0xc > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17619030 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17619040 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1761904c 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17619054 0xc > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17619070 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17619080 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1761908c 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17619094 0xc > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x176190b0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x176190c0 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x176190cc 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x176190d4 0xc > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x176190f0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17619100 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1761910c 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17619114 0xc > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17619130 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17619140 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1761914c 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17619154 0xc > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17619170 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17619180 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1761918c 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17619194 0xc > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x176191b0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x176191c0 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x176191cc 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x176191d4 0xc > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x176191f0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17619200 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1761920c 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17619214 0xc > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17619230 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17619240 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1761924c 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17619254 0xc > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17619270 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17619280 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1761928c 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17619294 0xc > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x176192b0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x176192c0 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x176192cc 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x176192d4 0xc > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x176192f0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17619300 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1761930c 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17619314 0xc > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17619330 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17619340 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1761934c 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17619354 0xc > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17619370 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17619380 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1761938c 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17619394 0xc > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x176193b0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x176193c0 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x176193cc 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x176193d4 0xc > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x176193f0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17619400 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1761940c 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17619414 0xc > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17619430 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17619440 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1761944c 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17619454 0xc > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17619470 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17619480 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1761948c 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17619494 0xc > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x176194b0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x176194c0 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x176194cc 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x176194d4 0xc > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x176194f0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17619500 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1761950c 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17619514 0xc > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17619530 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17619540 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1761954c 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17619554 0xc > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17619570 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17619580 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1761958c 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17619594 0xc > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x176195b0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x176195c0 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x176195cc 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x176195d4 0xc > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x176195f0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17619600 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1761960c 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17619614 0xc > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17619630 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17619640 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1761964c 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17619654 0xc > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17619670 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17619680 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1761968c 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17619694 0xc > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x176196b0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x176196c0 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x176196cc 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x176196d4 0xc > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x176196f0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17619700 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1761970c 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17619714 0xc > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17619730 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17619740 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1761974c 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17619754 0xc > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17619770 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17619780 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1761978c 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17619794 0xc > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x176197b0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x176197c0 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x176197cc 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x176197d4 0xc > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x176197f0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17800000 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17800008 0x48 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17800054 0x20 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x178000f0 0xc > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17800100 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17810000 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17810008 0x48 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17810054 0x20 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x178100f0 0xc > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17810100 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17820000 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17820008 0x48 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17820054 0x20 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x178200f0 0xc > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17820100 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17830000 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17830008 0x48 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17830054 0x20 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x178300f0 0xc > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17830100 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17838000 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17840000 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17840008 0x48 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17840054 0x20 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x178400f0 0xc > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17840100 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17848000 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17850000 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17850008 0x48 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17850054 0x20 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x178500f0 0xc > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17850100 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17858000 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17860000 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17860008 0x48 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17860054 0x20 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x178600f0 0xc > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17860100 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17868000 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17870000 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17870008 0x48 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17870054 0x20 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x178700f0 0xc > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17870100 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17878000 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17880000 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17880008 0x48 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17880068 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x178800f0 0x18 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17888000 0x18 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17890000 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17890008 0x48 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17890068 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x178900f0 0x18 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17898000 0x18 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x178a0000 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x178a0008 0x48 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x178a0054 0x34 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x178a0090 0x1dc > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x178c0000 0x248 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x178c8000 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x178c8008 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x178c8010 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x178c8018 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x178c8020 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x178c8028 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x178c8030 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x178c8038 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x178c8040 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x178c8048 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x178c8050 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x178c8058 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x178c8060 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x178c8068 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x178c8070 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x178c8078 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x178c8080 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x178c8088 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x178c8090 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x178c8098 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x178c80a0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x178c80a8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x178c80b0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x178c80b8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x178c80c0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x178c80c8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x178c80d0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x178c80d8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x178c80e0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x178c80e8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x178c80f0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x178c80f8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x178c8100 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x178c8108 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x178c8110 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x178c8118 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x178cc000 0x24 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x178cc030 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x178cc040 0x48 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x178cc090 0x88 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17900000 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1790000c 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17900040 0x18 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17900900 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17900c00 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17900c0c 0x18 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17900c40 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17900fd0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17901000 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x1790100c 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17901040 0x18 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17901900 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17901c00 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17901c0c 0x18 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17901c40 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17901fd0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a00000 0xd4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a000d8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a00100 0xc > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a00110 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a0011c 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a00200 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a00224 0x10 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a00244 0x10 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a00264 0x10 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a00284 0x10 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a002a4 0x10 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a002c4 0x10 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a002e4 0x10 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a00400 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a00450 0x18 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a00490 0x3c > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a00550 0x200 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a00d00 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a00d10 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a00d18 0x19c > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a00fc0 0x24 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a00fe8 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a01000 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a01018 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a01030 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a01048 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a01060 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a01078 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a01090 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a010a8 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a010c0 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a010d8 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a010f0 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a01108 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a01120 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a01138 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a01150 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a01260 0x24 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a01288 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a012a0 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a012b8 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a012d0 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a012e8 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a01300 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a01318 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a01330 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a01348 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a01360 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a01378 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a01390 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a013a8 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a013c0 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a013d8 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a013f0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a01500 0x24 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a01528 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a01540 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a01558 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a01570 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a01588 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a015a0 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a015b8 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a015d0 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a015e8 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a01600 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a01618 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a01630 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a01648 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a01660 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a01678 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a01690 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a10000 0x4c > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a10050 0x84 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a100d8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a10100 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a10108 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a10204 0x10 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a10224 0x10 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a10244 0x10 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a10264 0x10 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a10284 0x10 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a102a4 0x10 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a102c4 0x10 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a102e4 0x10 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a10400 0xc > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a10450 0x18 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a104a0 0x2c > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a10550 0x200 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a10d00 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a10d10 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a10d18 0x19c > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a10fc0 0x24 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a10fe8 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a11000 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a11018 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a11030 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a11048 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a11060 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a11078 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a11090 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a110a8 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a110c0 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a110d8 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a110f0 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a11108 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a11120 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a11138 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a11150 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a11260 0x24 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a11288 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a112a0 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a112b8 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a112d0 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a112e8 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a11300 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a11318 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a11330 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a11348 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a11360 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a11378 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a11390 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a113a8 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a113c0 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a113d8 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a113f0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a11500 0x24 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a11528 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a11540 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a11558 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a11570 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a11588 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a115a0 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a115b8 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a115d0 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a115e8 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a11600 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a11618 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a11630 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a11648 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a11660 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a11678 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a11690 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a20000 0x4c > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a20050 0x84 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a200d8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a20100 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a20108 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a20204 0x10 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a20224 0x10 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a20244 0x10 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a20264 0x10 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a20284 0x10 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a202a4 0x10 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a202c4 0x10 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a202e4 0x10 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a20400 0xc > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a20450 0x18 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a204a0 0x2c > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a20550 0x200 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a20d00 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a20d10 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a20d18 0x19c > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a20fc0 0x24 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a20fe8 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a21000 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a21018 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a21030 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a21048 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a21060 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a21078 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a21090 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a210a8 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a210c0 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a210d8 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a210f0 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a21108 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a21120 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a21138 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a21150 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a21260 0x24 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a21288 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a212a0 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a212b8 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a212d0 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a212e8 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a21300 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a21318 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a21330 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a21348 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a21360 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a21378 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a21390 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a213a8 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a213c0 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a213d8 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a213f0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a21500 0x24 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a21528 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a21540 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a21558 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a21570 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a21588 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a215a0 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a215b8 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a215d0 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a215e8 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a21600 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a21618 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a21630 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a21648 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a21660 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a21678 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a21690 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a217a0 0x24 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a217c8 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a217e0 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a217f8 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a21810 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a21828 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a21840 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a21858 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a21870 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a21888 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a218a0 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a218b8 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a218d0 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a218e8 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a21900 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a21918 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a21930 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a21a40 0x24 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a21a68 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a21a80 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a21a98 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a21ab0 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a21ac8 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a21ae0 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a21af8 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a21b10 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a21b28 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a21b40 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a21b58 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a21b70 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a21b88 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a21ba0 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a21bb8 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a21bd0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a21ce0 0x24 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a21d08 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a21d20 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a21d38 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a21d50 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a21d68 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a21d80 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a21d98 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a21db0 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a21dc8 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a21de0 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a21df8 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a21e10 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a21e28 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a21e40 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a21e58 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a21e70 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a21f80 0x24 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a21fa8 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a21fc0 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a21fd8 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a21ff0 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a22008 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a22020 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a22038 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a22050 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a22068 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a22080 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a22098 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a220b0 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a220c8 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a220e0 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a220f8 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a22110 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a30000 0x4c > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a30050 0x84 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a300d8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a30100 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a30108 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a30204 0x10 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a30224 0x10 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a30244 0x10 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a30264 0x10 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a30284 0x10 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a302a4 0x10 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a302c4 0x10 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a302e4 0x10 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a30400 0xc > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a30450 0x18 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a304a0 0x2c > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a30550 0x200 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a30d00 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a30d10 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a30d18 0x19c > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a30fc0 0x24 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a30fe8 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a31000 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a31018 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a31030 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a31048 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a31060 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a31078 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a31090 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a310a8 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a310c0 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a310d8 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a310f0 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a31108 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a31120 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a31138 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a31150 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a31260 0x24 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a31288 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a312a0 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a312b8 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a312d0 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a312e8 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a31300 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a31318 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a31330 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a31348 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a31360 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a31378 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a31390 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a313a8 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a313c0 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a313d8 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a313f0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a80000 0x44 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a82000 0x44 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a84000 0x44 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a86000 0x44 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a8c000 0x18 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a8e000 0x400 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a90000 0x5c > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a90080 0x58 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a92000 0x5c > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a92080 0x58 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a94000 0x5c > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a94080 0x58 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a96000 0x5c > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17a96080 0x58 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17aa0000 0xb0 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17aa00fc 0x50 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17aa0200 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17aa0300 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17aa0400 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17aa0500 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17aa0600 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17aa0700 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b00000 0x120 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b70000 0xc > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b70010 0x20 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b70090 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b700a0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b700c0 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b70100 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b70110 0x18 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b70190 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b701a0 0x18 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b70220 0x18 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b702a0 0x18 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b70320 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b70380 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b70390 0x40 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b70410 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b70420 0x40 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b704a0 0x40 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b70520 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b70580 0xc > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b70600 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b70610 0x30 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b70680 0xc > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b70700 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b70710 0x60 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b70790 0x60 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b70810 0x60 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b70890 0x60 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b70910 0x60 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b70990 0x60 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b70a10 0x60 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b70a90 0x60 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b70b10 0x60 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b70b90 0x60 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b70c00 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b70c10 0x60 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b70c90 0x60 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b70d10 0x60 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b70d90 0x60 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b70e10 0x60 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b70e90 0x60 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b70f10 0x60 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b70f90 0x60 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b71010 0x60 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b71080 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b71090 0x40 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b71110 0x40 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b71190 0x40 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b71210 0x40 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b71290 0x40 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b71310 0x40 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b71380 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b71390 0x20 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b71410 0x20 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b71490 0x200 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b71c90 0x20 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b71d10 0x20 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b71d90 0x20 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b71e10 0x20 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b71e90 0x20 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b71f10 0x20 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b71f90 0x20 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b72010 0x20 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b72080 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b72090 0x20 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b72110 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b72120 0x1c > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b72140 0x20 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b721c0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b721d0 0x30 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b72260 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b72270 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b72300 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b72320 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b72340 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b72360 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b72370 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b72390 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b723b0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b723d0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b723f0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b72410 0xc > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b78000 0xc > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b78010 0x10 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b78090 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b780a0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b780c0 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b78100 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b78110 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b78190 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b781a0 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b78220 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b782a0 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b78320 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b78380 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b78390 0x30 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b78410 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b78420 0x30 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b784a0 0x30 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b78520 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b78580 0xc > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b78600 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b78610 0x30 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b78680 0xc > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b78700 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b78710 0x20 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b78790 0x20 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b78810 0x20 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b78890 0x20 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b78910 0x20 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b78990 0x20 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b78a10 0x20 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b78a90 0x20 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b78b10 0x20 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b78b90 0x20 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b78c00 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b78c10 0x20 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b78c90 0x20 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b78d10 0x20 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b78d90 0x20 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b78e10 0x20 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b78e90 0x20 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b78f10 0x20 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b78f90 0x20 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b79010 0x20 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b79080 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b79090 0x18 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b79110 0x18 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b79190 0x18 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b79210 0x18 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b79290 0x18 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b79310 0x18 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b79380 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b79390 0x10 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b79410 0x10 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b79490 0x100 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b79c90 0x10 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b79d10 0x10 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b79d90 0x10 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b79e10 0x10 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b79e90 0x10 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b79f10 0x10 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b79f90 0x10 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b7a010 0x10 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b7a080 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b7a090 0x10 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b7a110 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b7a120 0x1c > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b7a140 0x10 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b7a1c0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b7a1d0 0x20 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b7a260 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b7a270 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b7a300 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b7a320 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b7a340 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b7a360 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b7a370 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b7a390 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b7a3b0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b7a3d0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b7a3f0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b7a410 0xc > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b90000 0x18 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b90020 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b90050 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b90070 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b90080 0x64 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b90100 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b90120 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b90140 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b90200 0x3c > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b90700 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b9070c 0xc > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b90780 0x80 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b90808 0x18 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b90824 0xc > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b90840 0x40 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b90c48 0x18 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b90c64 0xc > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b90c80 0x40 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b93000 0x140 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b93500 0x140 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b93a00 0xc > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b93a24 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b93a2c 0xc4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b93b00 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b93b20 0xc > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b93b30 0x2c > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b93b64 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b93b70 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b93b90 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17b93c00 0x8c > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17ba0000 0x18 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17ba0020 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17ba0050 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17ba0070 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17ba0080 0x64 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17ba0100 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17ba0120 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17ba0140 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17ba0200 0x24 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17ba0700 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17ba070c 0xc > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17ba0780 0x80 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17ba0808 0x18 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17ba0824 0xc > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17ba0840 0x40 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17ba0c48 0x18 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17ba0c64 0xc > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17ba0c80 0x40 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17ba3000 0x140 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17ba3500 0x140 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17ba3a00 0xc > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17ba3a24 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17ba3a2c 0xc4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17ba3b00 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17ba3b20 0xc > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17ba3b30 0x2c > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17ba3b64 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17ba3b70 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17ba3b90 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17ba3c00 0x8c > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17c000e8 0x154 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17c01000 0x25c > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17c20000 0xc > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17c21000 0xc > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17d10000 0x20 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17d10200 0x49c > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17d10700 0x11c > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17d10900 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17d30000 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17d34000 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17d3bff8 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17d40000 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17d40008 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17d40010 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17d40018 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17d40020 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17d40028 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17d50000 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17d50040 0xc > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17d50050 0xc > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17d50100 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17d50138 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17d50178 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17d50e00 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17d90000 0x10 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17d90014 0x68 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17d90080 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17d900b0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17d900b8 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17d900d0 0x24 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17d90100 0xa0 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17d90200 0xa0 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17d90300 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17d90320 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17d9034c 0x7c > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17d903e0 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17d90404 0xc > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17d90420 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17d90430 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17d90450 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17d90470 0xc > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17d91000 0x10 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17d91014 0x68 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17d91080 0x1c > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17d910b0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17d910b8 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17d910d0 0x24 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17d91100 0xa0 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17d91200 0xa0 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17d91300 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17d91320 0xc > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17d9134c 0x88 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17d913e0 0x10 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17d91404 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17d91420 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17d91430 0xc > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17d91450 0xc > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17d91470 0xc > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17d92000 0x10 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17d92014 0x68 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17d92080 0x20 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17d920b0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17d920b8 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17d920d0 0x24 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17d92100 0xa0 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17d92200 0xa0 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17d92300 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17d92320 0x10 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17d9234c 0x8c > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17d923e0 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17d92404 0x20 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17d92430 0x10 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17d92450 0x10 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17d92470 0xc > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17d93000 0x10 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17d93014 0x68 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17d93080 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17d930b0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17d930b8 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17d930d0 0x24 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17d93100 0xa0 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17d93200 0xa0 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17d93300 0x14 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17d93320 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17d9334c 0x80 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17d933e0 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17d93404 0x20 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17d93430 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17d93450 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17d93470 0xc > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17d98000 0x60 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17e00000 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17e00008 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17e00010 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17e00018 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17e00020 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17e00028 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17e00030 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17e00038 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17e00040 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17e00048 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17e00050 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17e00060 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17e00068 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17e10000 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17e10008 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17e10018 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17e10020 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17e10030 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17e100f0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17e100f8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17e10100 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17e11000 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17e20000 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17e20008 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17e20010 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17e20018 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17e20020 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17e20028 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17e20030 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17e20038 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17e20800 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17e20808 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17e20810 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17e20e00 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17e20e10 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17e20fa8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17e20fbc 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17e20fc8 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17e20fd0 0x30 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17e30000 0xc > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17e30010 0x18 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17e30030 0x18 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17e30050 0xc > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17e30170 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17e30fb0 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17e30fc8 0x38 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17e80000 0xc > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17e80010 0x18 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17e80030 0x18 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17e80050 0xc > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17e80170 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17e80fb0 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17e80fc8 0x38 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17e90000 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17e90008 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17e90010 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17e90018 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17e90100 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17e90108 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17e90110 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17e90400 0x10 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17e90480 0xc > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17e90c00 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17e90c20 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17e90ce0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17e90e00 0xc > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17e90fa8 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17e90fbc 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17e90fcc 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17e90fe0 0x20 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17eb0000 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17eb0010 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17f80000 0xc > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17f80010 0x18 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17f80030 0x18 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17f80050 0xc > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17f80170 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17f80fb0 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17f80fc8 0x38 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17f90000 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17f90008 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17f90010 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17f90018 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17f90100 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17f90108 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17f90110 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17f90400 0x10 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17f90480 0xc > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17f90c00 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17f90c20 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17f90ce0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17f90e00 0xc > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17f90fa8 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17f90fbc 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17f90fcc 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17f90fe0 0x20 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17fb0000 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17fb0010 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x18080000 0xc > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x18080010 0x18 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x18080030 0x18 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x18080050 0xc > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x18080170 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x18080fb0 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x18080fc8 0x38 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x18090000 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x18090008 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x18090010 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x18090018 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x18090100 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x18090108 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x18090110 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x18090400 0x10 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x18090480 0xc > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x18090c00 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x18090c20 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x18090ce0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x18090e00 0xc > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x18090fa8 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x18090fbc 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x18090fcc 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x18090fe0 0x20 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x180b0000 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x180b0010 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x18180000 0xc > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x18180010 0x18 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x18180030 0x18 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x18180050 0xc > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x18180170 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x18180fb0 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x18180fc8 0x38 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x18190000 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x18190008 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x18190010 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x18190018 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x18190100 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x18190108 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x18190110 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x18190400 0x10 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x18190480 0xc > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x18190c00 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x18190c20 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x18190ce0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x18190e00 0xc > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x18190fa8 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x18190fbc 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x18190fcc 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x18190fe0 0x20 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x181b0000 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x181b0010 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x18280000 0xc > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x18280010 0x18 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x18280030 0x18 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x18280050 0xc > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x18280170 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x18280fb0 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x18280fc8 0x38 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x18290000 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x18290008 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x18290010 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x18290018 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x18290100 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x18290108 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x18290110 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x18290400 0x10 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x18290480 0xc > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x18290c00 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x18290c20 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x18290ce0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x18290e00 0xc > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x18290fa8 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x18290fbc 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x18290fcc 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x18290fe0 0x20 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x182b0000 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x182b0010 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x18380000 0xc > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x18380010 0x18 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x18380030 0x18 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x18380050 0xc > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x18380170 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x18380fb0 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x18380fc8 0x38 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x18390000 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x18390008 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x18390010 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x18390018 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x18390100 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x18390108 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x18390110 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x18390400 0x10 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x18390480 0x10 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x18390c00 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x18390c20 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x18390ce0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x18390e00 0xc > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x18390fa8 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x18390fbc 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x18390fcc 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x18390fe0 0x20 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x18480000 0xc > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x18480010 0x18 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x18480030 0x18 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x18480050 0xc > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x18480170 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x18480fb0 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x18480fc8 0x38 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x18490000 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x18490008 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x18490010 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x18490018 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x18490100 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x18490108 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x18490110 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x18490400 0x10 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x18490480 0x10 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x18490c00 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x18490c20 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x18490ce0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x18490e00 0xc > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x18490fa8 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x18490fbc 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x18490fcc 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x18490fe0 0x20 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x18580000 0xc > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x18580010 0x18 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x18580030 0x18 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x18580050 0xc > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x18580170 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x18580fb0 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x18580fc8 0x38 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x18590000 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x18590008 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x18590010 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x18590018 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x18590100 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x18590108 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x18590110 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x18590400 0x10 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x18590480 0x10 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x18590c00 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x18590c20 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x18590ce0 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x18590e00 0xc > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x18590fa8 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x18590fbc 0x4 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x18590fcc 0x8 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x18590fe0 0x20 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17d00000 0x10000 > /sys/bus/platform/devices/soc:mem_dump/register_config
	echo 0x17d20000 0x10000 > /sys/bus/platform/devices/soc:mem_dump/register_config
}

cpuss_spr_setup()
{
    echo 1 > /sys/bus/platform/devices/soc:mem_dump/sprs_register_reset

    echo 1 0 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 2 0 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 3 0 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 4 0 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 5 0 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 6 0 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 7 0 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 8 0 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 9 0 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 11 0 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 13 0 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 14 0 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 15 0 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 16 0 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 17 0 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 18 0 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 19 0 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 21 0 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 22 0 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 23 0 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 24 0 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 25 0 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 26 0 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 27 0 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 28 0 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 29 0 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 30 0 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 31 0 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 32 0 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 33 0 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 34 0 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 35 0 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 36 0 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 37 0 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 38 0 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 43 0 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 44 0 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 45 0 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 46 0 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 47 0 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 48 0 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 49 0 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 51 0 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 52 0 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 53 0 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 54 0 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 55 0 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 56 0 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 57 0 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 58 0 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 59 0 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 60 0 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 61 0 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 62 0 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 67 0 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 68 0 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 69 0 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 70 0 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 72 0 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 73 0 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 74 0 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 75 0 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 76 0 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 77 0 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 1 1 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 2 1 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 3 1 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 4 1 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 5 1 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 6 1 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 7 1 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 8 1 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 9 1 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 11 1 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 13 1 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 14 1 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 15 1 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 16 1 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 17 1 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 18 1 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 19 1 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 21 1 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 22 1 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 23 1 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 24 1 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 25 1 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 26 1 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 27 1 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 28 1 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 29 1 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 30 1 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 31 1 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 32 1 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 33 1 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 34 1 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 35 1 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 36 1 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 37 1 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 38 1 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 43 1 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 44 1 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 45 1 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 46 1 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 47 1 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 48 1 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 49 1 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 51 1 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 52 1 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 53 1 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 54 1 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 55 1 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 56 1 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 57 1 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 58 1 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 59 1 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 60 1 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 61 1 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 62 1 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 67 1 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 68 1 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 69 1 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 70 1 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 72 1 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 73 1 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 74 1 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 75 1 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 76 1 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 77 1 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 1 2 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 2 2 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 3 2 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 4 2 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 5 2 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 6 2 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 7 2 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 8 2 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 9 2 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 11 2 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 13 2 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 14 2 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 15 2 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 16 2 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 17 2 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 18 2 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 19 2 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 21 2 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 22 2 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 23 2 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 24 2 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 25 2 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 26 2 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 27 2 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 28 2 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 29 2 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 30 2 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 31 2 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 32 2 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 33 2 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 34 2 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 35 2 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 36 2 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 37 2 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 38 2 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 43 2 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 44 2 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 45 2 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 46 2 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 47 2 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 48 2 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 49 2 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 51 2 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 52 2 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 53 2 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 54 2 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 55 2 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 56 2 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 57 2 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 58 2 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 59 2 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 60 2 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 61 2 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 62 2 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 67 2 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 68 2 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 69 2 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 70 2 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 72 2 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 73 2 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 74 2 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 75 2 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 76 2 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 77 2 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 1 3 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 2 3 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 3 3 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 4 3 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 5 3 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 6 3 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 7 3 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 8 3 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 9 3 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 10 3 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 13 3 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 14 3 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 15 3 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 16 3 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 17 3 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 18 3 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 19 3 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 21 3 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 22 3 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 23 3 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 24 3 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 25 3 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 26 3 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 27 3 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 28 3 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 29 3 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 30 3 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 31 3 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 32 3 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 33 3 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 34 3 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 35 3 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 36 3 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 37 3 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 38 3 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 43 3 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 44 3 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 45 3 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 46 3 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 47 3 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 48 3 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 49 3 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 51 3 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 52 3 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 53 3 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 54 3 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 55 3 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 56 3 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 57 3 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 58 3 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 59 3 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 60 3 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 61 3 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 62 3 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 63 3 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 64 3 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 65 3 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 66 3 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 67 3 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 68 3 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 69 3 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 70 3 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 72 3 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 73 3 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 74 3 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 75 3 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 76 3 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 77 3 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 1 4 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 2 4 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 3 4 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 4 4 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 5 4 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 6 4 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 7 4 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 8 4 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 9 4 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 10 4 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 13 4 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 14 4 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 15 4 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 16 4 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 17 4 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 18 4 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 19 4 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 21 4 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 22 4 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 23 4 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 24 4 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 25 4 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 26 4 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 27 4 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 28 4 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 29 4 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 30 4 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 31 4 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 32 4 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 33 4 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 34 4 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 35 4 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 36 4 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 37 4 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 38 4 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 43 4 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 44 4 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 45 4 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 46 4 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 47 4 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 48 4 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 49 4 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 51 4 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 52 4 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 53 4 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 54 4 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 55 4 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 56 4 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 57 4 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 58 4 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 59 4 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 60 4 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 61 4 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 62 4 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 63 4 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 64 4 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 65 4 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 66 4 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 67 4 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 68 4 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 69 4 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 70 4 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 72 4 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 73 4 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 74 4 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 75 4 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 76 4 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 77 4 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 1 5 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 2 5 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 3 5 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 4 5 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 5 5 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 6 5 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 7 5 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 8 5 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 9 5 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 10 5 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 13 5 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 14 5 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 15 5 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 16 5 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 17 5 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 18 5 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 19 5 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 20 5 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 21 5 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 22 5 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 23 5 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 24 5 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 25 5 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 26 5 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 27 5 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 28 5 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 29 5 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 30 5 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 31 5 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 32 5 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 33 5 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 34 5 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 35 5 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 36 5 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 37 5 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 38 5 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 43 5 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 44 5 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 45 5 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 46 5 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 47 5 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 48 5 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 49 5 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 51 5 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 52 5 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 53 5 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 54 5 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 55 5 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 56 5 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 57 5 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 58 5 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 59 5 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 60 5 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 61 5 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 62 5 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 63 5 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 64 5 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 65 5 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 66 5 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 67 5 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 68 5 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 69 5 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 70 5 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 72 5 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 73 5 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 74 5 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 75 5 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 76 5 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 77 5 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 1 6 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 2 6 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 3 6 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 4 6 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 5 6 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 6 6 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 7 6 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 8 6 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 9 6 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 10 6 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 13 6 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 14 6 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 15 6 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 16 6 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 17 6 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 18 6 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 19 6 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 20 6 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 21 6 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 22 6 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 23 6 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 24 6 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 25 6 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 26 6 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 27 6 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 28 6 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 29 6 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 30 6 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 31 6 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 32 6 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 33 6 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 34 6 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 35 6 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 36 6 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 37 6 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 38 6 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 43 6 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 44 6 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 45 6 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 46 6 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 47 6 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 48 6 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 49 6 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 51 6 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 52 6 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 53 6 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 54 6 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 55 6 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 56 6 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 57 6 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 58 6 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 59 6 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 60 6 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 61 6 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 62 6 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 63 6 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 64 6 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 65 6 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 66 6 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 67 6 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 68 6 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 69 6 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 70 6 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 72 6 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 73 6 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 74 6 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 75 6 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 76 6 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 77 6 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 1 7 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 2 7 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 3 7 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 4 7 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 5 7 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 6 7 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 7 7 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 8 7 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 9 7 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 10 7 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 13 7 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 14 7 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 15 7 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 16 7 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 17 7 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 18 7 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 19 7 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 20 7 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 21 7 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 22 7 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 23 7 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 24 7 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 25 7 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 26 7 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 27 7 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 28 7 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 29 7 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 30 7 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 31 7 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 32 7 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 33 7 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 34 7 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 35 7 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 36 7 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 37 7 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 38 7 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 43 7 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 44 7 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 45 7 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 46 7 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 47 7 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 48 7 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 49 7 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 51 7 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 52 7 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 53 7 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 54 7 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 55 7 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 56 7 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 57 7 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 58 7 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 59 7 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 60 7 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 61 7 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 62 7 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 63 7 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 64 7 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 65 7 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 66 7 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 67 7 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 68 7 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 69 7 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 70 7 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 72 7 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 73 7 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 74 7 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 75 7 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 76 7 > /sys/bus/platform/devices/soc:mem_dump/spr_config
    echo 77 7 > /sys/bus/platform/devices/soc:mem_dump/spr_config
}

enable_buses_and_interconnect_tracefs_debug()
{
    if [ -d $tracefs ] && [ "$(getprop persist.vendor.tracing.enabled)" -eq "1" ]; then
        mkdir $tracefs/instances/hsuart
        #UART
        echo 800 > $tracefs/instances/hsuart/buffer_size_kb
        echo 1 > $tracefs/instances/hsuart/events/serial/enable
        echo 1 > $tracefs/instances/hsuart/tracing_on

        #SPI
        mkdir $tracefs/instances/spi_qup
        echo 20 > $tracefs/instances/spi_qup/buffer_size_kb
        echo 1 > $tracefs/instances/spi_qup/events/qup_spi_trace/enable
        echo 1 > $tracefs/instances/spi_qup/tracing_on

        #I2C
        mkdir $tracefs/instances/i2c_qup
        echo 20 > $tracefs/instances/i2c_qup/buffer_size_kb
        echo 1 > $tracefs/instances/i2c_qup/events/qup_i2c_trace/enable
        echo 1 > $tracefs/instances/i2c_qup/tracing_on

        #SLIMBUS
        mkdir $tracefs/instances/slimbus
        echo 1 > $tracefs/instances/slimbus/events/slimbus/slimbus_dbg/enable
        echo 1 > $tracefs/instances/slimbus/tracing_on

        #CLOCK, REGULATOR, INTERCONNECT, RPMH
        mkdir $tracefs/instances/clock_reg
        echo 1 > $tracefs/instances/clock_reg/events/clk/enable
        echo 1 > $tracefs/instances/clock_reg/events/regulator/enable
        echo 1 > $tracefs/instances/clock_reg/events/interconnect/enable
        echo 1 > $tracefs/instances/clock_reg/events/rpmh/enable
        echo 1 > $tracefs/instances/clock_reg/tracing_on
    fi
}

create_stp_policy()
{
    mkdir /config/stp-policy/coresight-stm:p_ost.policy
    chmod 660 /config/stp-policy/coresight-stm:p_ost.policy
    mkdir /config/stp-policy/coresight-stm:p_ost.policy/default
    chmod 660 /config/stp-policy/coresight-stm:p_ost.policy/default
    echo 0x10 > /sys/bus/coresight/devices/coresight-stm/traceid
}

#function to enable cti flush for etf
enable_cti_flush_for_etf()
{
    # bail out if its perf config
    if [ ! -d /sys/module/msm_rtb ]
    then
        return
    fi

    echo 1 >/sys/bus/coresight/devices/coresight-cti-swao_cti/enable
    echo 0 24 >/sys/bus/coresight/devices/coresight-cti-swao_cti/channels/trigin_attach
    echo 0 1 >/sys/bus/coresight/devices/coresight-cti-swao_cti/channels/trigout_attach
}

#function to enable cti flush for etr
enable_cti_flush_for_etr()
{
    # bail out if its perf config
    if [ ! -d /sys/module/msm_rtb ]
    then
        return
    fi

    echo 1 > /sys/bus/coresight/devices/coresight-cti-qc_cti/enable
    echo 1 3 > /sys/bus/coresight/devices/coresight-cti-qc_cti/channels/trigout_attach
    echo 1 53 > /sys/bus/coresight/devices/coresight-cti-qc_cti/channels/trigin_attach
}



ftrace_disable=`getprop persist.debug.ftrace_events_disable`
coresight_config=`getprop persist.debug.coresight.config`
tracefs=/sys/kernel/tracing
srcenable="enable"
enable_debug()
{
    echo "kalama debug"
    etr_size="0x2000000"
    srcenable="enable_source"
    sinkenable="enable_sink"
    create_stp_policy
    echo "Enabling STM events on kalama."
    adjust_permission
    enable_stm_events
    enable_cti_flush_for_etf
    enable_cti_flush_for_etr
    # enable_lpm_with_dcvs_tracing
    if [ "$ftrace_disable" != "Yes" ]; then
        enable_ftrace_event_tracing
	enable_buses_and_interconnect_tracefs_debug
    fi
    # removing core hang config from postboot as core hang detection is enabled from sysini
    enable_dcc
    enable_cpuss_hw_events
    enable_schedstats
    # setprop ro.dbg.coresight.stm_cfg_done 1
    enable_cpuss_register
    cpuss_spr_setup
    sf_tracing_disablement
}

enable_debug
