#! /vendor/bin/sh
#=============================================================================
# Copyright (c) 2020, 2021 Qualcomm Technologies, Inc.
# All Rights Reserved.
# Confidential and Proprietary - Qualcomm Technologies, Inc.
#=============================================================================

soc_id=`cat /sys/devices/soc0/soc_id` 2> /dev/null

# Store soc_id in ro.vendor.qti.soc_id
setprop ro.vendor.qti.soc_id $soc_id

# For chipsets in QCV family, convert soc_id to soc_name
# and store it in ro.vendor.qti.soc_name.

if [ "$soc_id" -eq 608 ]; then
    setprop ro.vendor.qti.soc_name crow
    setprop ro.vendor.qti.soc_model SM7550
elif [ "$soc_id" -eq 557 ]; then
    setprop ro.vendor.qti.soc_name pineapple
    setprop ro.vendor.qti.soc_model SM8650
elif [ "$soc_id" -eq 519 ] || [ "$soc_id" -eq 536 ]; then
    setprop ro.vendor.qti.soc_name kalama
    setprop ro.vendor.qti.soc_model SM8550
    setprop ro.vendor.media_performance_class 33
elif [ "$soc_id" -eq 600 ] || [ "$soc_id" -eq 601 ]; then
    setprop ro.vendor.qti.soc_name kalama
    setprop ro.vendor.qti.soc_model SG8275
    setprop ro.vendor.media_performance_class 33
elif [ "$soc_id" -eq 603 ]; then
    setprop ro.vendor.qti.soc_name kalama
    setprop ro.vendor.qti.soc_model QCS8550
elif [ "$soc_id" -eq 604 ]; then
    setprop ro.vendor.qti.soc_name kalama
    setprop ro.vendor.qti.soc_model QCM8550
elif [ "$soc_id" -eq 457 ] || [ "$soc_id" -eq 482 ]; then
    setprop ro.vendor.qti.soc_name taro
    setprop ro.vendor.qti.soc_model SM8450
elif [ "$soc_id" -eq 506 ]; then
    setprop ro.vendor.qti.soc_name diwali
    setprop ro.vendor.qti.soc_model SM7450
elif [ "$soc_id" -eq 530 ] || [ "$soc_id" -eq 531 ] ; then
    setprop ro.vendor.qti.soc_name cape
    setprop ro.vendor.qti.soc_model SM8475
elif [ "$soc_id" -eq 415 ] || [ "$soc_id" -eq 439 ] || [ "$soc_id" -eq 456 ] ||
   [ "$soc_id" -eq 501 ] || [ "$soc_id" -eq 502 ]; then
    setprop ro.vendor.qti.soc_name lahaina
    setprop ro.vendor.qti.soc_model SM8350
elif [ "$soc_id" -eq 450 ]; then
    setprop ro.vendor.qti.soc_name shima
    setprop ro.vendor.qti.soc_model SM7350
elif [ "$soc_id" -eq 475 ] || [ "$soc_id" -eq 499 ] || [ "$soc_id" -eq 497 ] ||
     [ "$soc_id" -eq 498 ] || [ "$soc_id" -eq 515 ]; then
    setprop ro.vendor.qti.soc_name yupik
    setprop ro.vendor.qti.soc_model SM7325
fi
