#! /vendor/bin/sh

# Copyright (c) 2012-2013, 2016-2020, The Linux Foundation. All rights reserved.
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
#
# pick from android/device/qcom/common/rootdir/etc/init.qcom.post_boot.sh


#sleep 10s
#echo "tip : cpu0 online only for power save in ftm mode"
#echo 1 > /sys/devices/system/cpu/cpu0/online
#echo 0 > /sys/devices/system/cpu/cpu1/online
#echo 0 > /sys/devices/system/cpu/cpu2/online
#echo 0 > /sys/devices/system/cpu/cpu3/online
#echo 0 > /sys/devices/system/cpu/cpu4/online
#echo 0 > /sys/devices/system/cpu/cpu5/online
#echo 0 > /sys/devices/system/cpu/cpu6/online
#echo 0 > /sys/devices/system/cpu/cpu7/online

sleep 5s
stop mediaextractor
stop credstore
stop iorapd
stop qvrd
stop oppo_kevents
stop spu_service
stop vendor.qcc-trd


stop alarm-hal-1-0
stop media
stop vendor.media.omx
stop mediametrics
stop atlasservice
stop dpmd
stop android.thermal-hal
stop thermal-engine
stop health-hal-2-1
stop perf-hal-2-2
stop vendor-qti-media-c2-hal-1-0
stop vendor.rmt_storage
stop storaged
stop oppoasserttip
stop initopluslog


#sleep 2s
#stop ueventd
#stop oppo_adbd
#stop logcat_loose
#stop ftm-klogd
#stop vendor.cameras-provider-2-4


