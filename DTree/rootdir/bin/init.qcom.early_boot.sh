#! /vendor/bin/sh

# Copyright (c) 2012-2013,2016,2018-2020 The Linux Foundation. All rights reserved.
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

export PATH=/vendor/bin

# Set platform variables
if [ -f /sys/devices/soc0/hw_platform ]; then
    soc_hwplatform=`cat /sys/devices/soc0/hw_platform` 2> /dev/null
else
    soc_hwplatform=`cat /sys/devices/system/soc/soc0/hw_platform` 2> /dev/null
fi
if [ -f /sys/devices/soc0/soc_id ]; then
    soc_hwid=`cat /sys/devices/soc0/soc_id` 2> /dev/null
else
    soc_hwid=`cat /sys/devices/system/soc/soc0/id` 2> /dev/null
fi
if [ -f /sys/devices/soc0/platform_version ]; then
    soc_hwver=`cat /sys/devices/soc0/platform_version` 2> /dev/null
else
    soc_hwver=`cat /sys/devices/system/soc/soc0/platform_version` 2> /dev/null
fi

if [ -f /sys/class/drm/card0-DSI-1/modes ]; then
    echo "detect" > /sys/class/drm/card0-DSI-1/status
    mode_file=/sys/class/drm/card0-DSI-1/modes
    while read line; do
        fb_width=${line%%x*};
        break;
    done < $mode_file
elif [ -f /sys/class/graphics/fb0/virtual_size ]; then
    res=`cat /sys/class/graphics/fb0/virtual_size` 2> /dev/null
    fb_width=${res%,*}
fi

log -t BOOT -p i "MSM target '$1', SoC '$soc_hwplatform', HwID '$soc_hwid', SoC ver '$soc_hwver'"

#For drm based display driver
vbfile=/sys/module/drm/parameters/vblankoffdelay
if [ -w $vbfile ]; then
    echo -1 >  $vbfile
else
    log -t DRM_BOOT -p w "file: '$vbfile' or perms doesn't exist"
fi

function set_density_by_fb() {
    #put default density based on width
    if [ -z $fb_width ]; then
        setprop vendor.display.lcd_density 320
    else
        if [ $fb_width -ge 1600 ]; then
           setprop vendor.display.lcd_density 640
        elif [ $fb_width -ge 1440 ]; then
           setprop vendor.display.lcd_density 560
        elif [ $fb_width -ge 1080 ]; then
           setprop vendor.display.lcd_density 480
        elif [ $fb_width -ge 720 ]; then
           setprop vendor.display.lcd_density 320 #for 720X1280 resolution
        elif [ $fb_width -ge 480 ]; then
            setprop vendor.display.lcd_density 240 #for 480X854 QRD resolution
        else
            setprop vendor.display.lcd_density 160
        fi
    fi
}

target=`getprop ro.board.platform`
case "$target" in
    "msm7630_surf" | "msm7630_1x" | "msm7630_fusion")
        case "$soc_hwplatform" in
            "FFA" | "SVLTE_FFA")
                # linking to surf_keypad_qwerty.kcm.bin instead of surf_keypad_numeric.kcm.bin so that
                # the UI keyboard works fine.
                ln -s  /system/usr/keychars/surf_keypad_qwerty.kcm.bin /system/usr/keychars/surf_keypad.kcm.bin
                ;;
            "Fluid")
                setprop vendor.display.lcd_density 240
                setprop qcom.bt.dev_power_class 2
                ;;
            *)
                ln -s  /system/usr/keychars/surf_keypad_qwerty.kcm.bin /system/usr/keychars/surf_keypad.kcm.bin
                ;;
        esac
        ;;
     "sm6150")
         case "$soc_hwplatform" in
             "ADP")
                 setprop vendor.display.lcd_density 160
                 ;;
         esac
         case "$soc_hwid" in
             365|366)
                 sku_ver=`cat /sys/devices/platform/soc/aa00000.qcom,vidc1/sku_version` 2> /dev/null
                 setprop vendor.media.target.version 1
                 if [ $sku_ver -eq 1 ]; then
                     setprop vendor.media.target.version 2
                 fi
                 ;;
             355|369|377|384)
                 setprop vendor.chre.enabled 0
                 ;;
             *)
         esac
         ;;
    "msm8660")
        case "$soc_hwplatform" in
            "Fluid")
                setprop vendor.display.lcd_density 240
                ;;
            "Dragon")
                setprop ro.sound.alsa "WM8903"
                ;;
        esac
        ;;

    "msm8960")
        # lcd density is write-once. Hence the separate switch case
        case "$soc_hwplatform" in
            "Liquid")
                if [ "$soc_hwver" == "196608" ]; then # version 0x30000 is 3D sku
                    setprop ro.sf.hwrotation 90
                fi

                setprop vendor.display.lcd_density 160
                ;;
            "MTP")
                setprop vendor.display.lcd_density 240
                ;;
            *)
                case "$soc_hwid" in
                    "109")
                        setprop vendor.display.lcd_density 160
                        ;;
                    *)
                        setprop vendor.display.lcd_density 240
                        ;;
                esac
            ;;
        esac

        #Set up composition type based on the target
        case "$soc_hwid" in
            87)
                #8960
                setprop debug.composition.type dyn
                ;;
            153|154|155|156|157|138)
                #8064 V2 PRIME | 8930AB | 8630AB | 8230AB | 8030AB | 8960AB
                setprop debug.composition.type c2d
                ;;
            *)
        esac
        ;;

    "msm8974")
        case "$soc_hwplatform" in
            "Liquid")
                setprop vendor.display.lcd_density 160
                # Liquid do not have hardware navigation keys, so enable
                # Android sw navigation bar
                setprop ro.hw.nav_keys 0
                ;;
            "Dragon")
                setprop vendor.display.lcd_density 240
                ;;
            *)
                setprop vendor.display.lcd_density 320
                ;;
        esac
        ;;

    "msm8226")
        case "$soc_hwplatform" in
            *)
                setprop vendor.display.lcd_density 320
                ;;
        esac
        ;;

    "msm8610" | "apq8084" | "mpq8092")
        case "$soc_hwplatform" in
            *)
                setprop vendor.display.lcd_density 240
                ;;
        esac
        ;;
    "apq8084")
        case "$soc_hwplatform" in
            "Liquid")
                setprop vendor.display.lcd_density 320
                # Liquid do not have hardware navigation keys, so enable
                # Android sw navigation bar
                setprop ro.hw.nav_keys 0
                ;;
            "SBC")
                setprop vendor.display.lcd_density 200
                # SBC do not have hardware navigation keys, so enable
                # Android sw navigation bar
                setprop qemu.hw.mainkeys 0
                ;;
            *)
                setprop vendor.display.lcd_density 480
                ;;
        esac
        ;;
    "msm8996")
        case "$soc_hwplatform" in
            "Dragon")
                setprop vendor.display.lcd_density 240
                setprop qemu.hw.mainkeys 0
                ;;
            "ADP")
                setprop vendor.display.lcd_density 160
                setprop qemu.hw.mainkeys 0
                ;;
            "SBC")
                setprop vendor.display.lcd_density 240
                setprop qemu.hw.mainkeys 0
                ;;
            *)
                setprop vendor.display.lcd_density 560
                ;;
        esac
        ;;
    "msm8937" | "msm8940")
        # Set vendor.opengles.version based on chip id.
        # MSM8937 and MSM8940  variants supports OpenGLES 3.1
        # 196608 is decimal for 0x30000 to report version 3.0
        # 196609 is decimal for 0x30001 to report version 3.1
        # 196610 is decimal for 0x30002 to report version 3.2
        case "$soc_hwid" in
            294|295|296|297|298|313|353|354|363|364)
                setprop vendor.opengles.version 196610
                if [ $soc_hwid = 354 ]
                then
                    setprop vendor.media.target.version 1
                    log -t BOOT -p i "SDM429 early_boot prop set for: HwID '$soc_hwid'"
                fi
                ;;
            303|307|308|309|320)
                # Vulkan is not supported for 8917 variants
                setprop vendor.opengles.version 196608
                setprop persist.graphics.vulkan.disable true
                ;;
            *)
                setprop vendor.opengles.version 196608
                ;;
        esac
        ;;
    "msm8909")
        case "$soc_hwplatform" in
            *)
                setprop persist.graphics.vulkan.disable true
                ;;
        esac
        ;;
    "msm8998" | "apq8098_latv")
        case "$soc_hwplatform" in
            *)
                setprop vendor.display.lcd_density 560
                ;;
        esac
        ;;
    "sdm845")
        case "$soc_hwplatform" in
            *)
                if [ $fb_width -le 1600 ]; then
                    setprop vendor.display.lcd_density 560
                else
                    setprop vendor.display.lcd_density 640
                fi
                ;;
        esac
        ;;
    "msmnile")
        case "$soc_hwplatform" in
            *)
                if [ $fb_width -le 1600 ]; then
                    setprop vendor.display.lcd_density 560
                else
                    setprop vendor.display.lcd_density 640
                fi
                ;;
        esac
        ;;
    "kona")
        case "$soc_hwplatform" in
            *)
                if [ $fb_width -le 1600 ]; then
                    setprop vendor.display.lcd_density 560
                else
                    setprop vendor.display.lcd_density 640
                fi
                ;;
        esac
        ;;
    "lito")
        case "$soc_hwid" in
            400|440)
                sku_ver=`cat /sys/devices/platform/soc/aa00000.qcom,vidc1/sku_version` 2> /dev/null
                if [ $sku_ver -eq 1 ]; then
                    setprop vendor.media.target.version 1
                fi
                ;;
            434|459)
                sku_ver=`cat /sys/devices/platform/soc/aa00000.qcom,vidc1/sku_version` 2> /dev/null
                setprop vendor.media.target.version 2
                if [ $sku_ver -eq 1 ]; then
                    setprop vendor.media.target.version 3
                fi
                ;;
        esac
        ;;
    "bengal")
        case "$soc_hwid" in
            441)
                setprop vendor.fastrpc.disable.cdsprpcd.daemon 1
                setprop vendor.gralloc.disable_ubwc 1

                # 196609 is decimal for 0x30001 to report version 3.1
                setprop vendor.opengles.version 196609
                ;;
            471)
                #scuba APQ
                setprop vendor.gralloc.disable_ubwc 1
                ;;
        esac
        ;;
    "sdm710" | "msmpeafowl")
        case "$soc_hwplatform" in
            *)
                if [ $fb_width -le 1600 ]; then
                    setprop vendor.display.lcd_density 560
                else
                    setprop vendor.display.lcd_density 640
                fi

                sku_ver=`cat /sys/devices/platform/soc/aa00000.qcom,vidc1/sku_version` 2> /dev/null
                if [ $sku_ver -eq 1 ]; then
                    setprop vendor.media.target.version 1
                fi
                ;;
        esac
        ;;
    "msm8953")
        cap_ver = 1
                if [ -e "/sys/devices/platform/soc/1d00000.qcom,vidc/capability_version" ]; then
                    cap_ver=`cat /sys/devices/platform/soc/1d00000.qcom,vidc/capability_version` 2> /dev/null
                else
                    cap_ver=`cat /sys/devices/soc/1d00000.qcom,vidc/capability_version` 2> /dev/null
                fi

                if [ $cap_ver -eq 1 ]; then
                    setprop vendor.media.target.version 1
                fi
                ;;
    #Set property to differentiate SDM660 & SDM455
    #SOC ID for SDM455 is 385
    "sdm660")
        case "$soc_hwplatform" in
            *)
                if [ $fb_width -le 1600 ]; then
                    setprop vendor.display.lcd_density 560
                else
                    setprop vendor.display.lcd_density 640
                fi

                if [ $soc_hwid -eq 385 ]; then
                    setprop vendor.media.target.version 1
                fi
                ;;
        esac
        ;;
    "holi")
        setprop vendor.media.target_variant "_holi"
        ;;
esac

baseband=`getprop ro.baseband`
#enable atfwd daemon all targets except sda, apq, qcs
case "$baseband" in
    "apq" | "sda" | "qcs" )
        setprop persist.vendor.radio.atfwd.start false;;
    *)
        setprop persist.vendor.radio.atfwd.start true;;
esac

#set default lcd density
#Since lcd density has read only
#property, it will not overwrite previous set
#property if any target is setting forcefully.
set_density_by_fb


# set Lilliput LCD density for ADP
product=`getprop ro.board.platform`

case "$product" in
        "msmnile_au")
         setprop vendor.display.lcd_density 160
         echo 902400000 > /sys/class/devfreq/soc:qcom,cpu0-cpu-l3-lat/min_freq
         echo 1612800000 > /sys/class/devfreq/soc:qcom,cpu0-cpu-l3-lat/max_freq
         echo 902400000 > /sys/class/devfreq/soc:qcom,cpu4-cpu-l3-lat/min_freq
         echo 1612800000 > /sys/class/devfreq/soc:qcom,cpu4-cpu-l3-lat/max_freq
         ;;
        *)
        ;;
esac
case "$product" in
        "sm6150_au")
         setprop vendor.display.lcd_density 160
         ;;
        *)
        ;;
esac
case "$product" in
        "sdmshrike_au")
         setprop vendor.display.lcd_density 160
         ;;
        *)
        ;;
esac

case "$product" in
        "msmnile_gvmq")
         setprop vendor.display.lcd_density 160
         ;;
        *)
        ;;
esac
# Setup display nodes & permissions
# HDMI can be fb1 or fb2
# Loop through the sysfs nodes and determine
# the HDMI(dtv panel)

function set_perms() {
    #Usage set_perms <filename> <ownership> <permission>
    chown -h $2 $1
    chmod $3 $1
}

# check for the type of driver FB or DRM
fb_driver=/sys/class/graphics/fb0
if [ -e "$fb_driver" ]
then
    # check for mdp caps
    file=/sys/class/graphics/fb0/mdp/caps
    if [ -f "$file" ]
    then
        setprop vendor.gralloc.disable_ubwc 1
        cat $file | while read line; do
          case "$line" in
                    *"ubwc"*)
                    setprop vendor.gralloc.enable_fb_ubwc 1
                    setprop vendor.gralloc.disable_ubwc 0
                esac
        done
    fi
else
    set_perms /sys/devices/virtual/hdcp/msm_hdcp/min_level_change system.graphics 0660
fi

# allow system_graphics group to access pmic secure_mode node
set_perms /sys/class/lcd_bias/secure_mode system.graphics 0660
set_perms /sys/class/leds/wled/secure_mode system.graphics 0660

boot_reason=`cat /proc/sys/kernel/boot_reason`
reboot_reason=`getprop ro.boot.alarmboot`
if [ "$boot_reason" = "3" ] || [ "$reboot_reason" = "true" ]; then
    setprop ro.vendor.alarm_boot true
else
    setprop ro.vendor.alarm_boot false
fi

# copy GPU frequencies to vendor property
if [ -f /sys/class/kgsl/kgsl-3d0/gpu_available_frequencies ]; then
    gpu_freq=`cat /sys/class/kgsl/kgsl-3d0/gpu_available_frequencies` 2> /dev/null
    setprop vendor.gpu.available_frequencies "$gpu_freq"
fi
