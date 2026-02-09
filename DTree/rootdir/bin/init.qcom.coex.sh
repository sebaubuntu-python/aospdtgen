#! /vendor/bin/sh

# Copyright (c) 2009-2010, 2012, The Linux Foundation. All rights reserved.
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

LOG_TAG="qcom-bt-wlan-coex"
LOG_NAME="${0}:"

coex_pid=""
ath_wlan_supported=`getprop wlan.driver.ath`

loge ()
{
  /system/bin/log -t $LOG_TAG -p e "$LOG_NAME $@"
}

logi ()
{
  /system/bin/log -t $LOG_TAG -p i "$LOG_NAME $@"
}

failed ()
{
  loge "$1: exit code $2"
  exit $2
}

start_coex ()
{
  case "$ath_wlan_supported" in
      "2")
       echo "ATH WLAN Chip ID AR6004 is enabled"
       /system/bin/abtfilt -d -z -n -m -a -w wlan0 &
      ;;
      "1")
       echo "ATH WLAN Chip ID is enabled"
       # Must have -d -z -n -v -s -w wlan0 parameters for atheros btfilter.
       /system/bin/abtfilt -d -z -n -v -q -s -w wlan0 &
      ;;
      "0")
       echo "WCN WLAN Chip ID is enabled"
       # Must have -o turned on to avoid daemon (otherwise we cannot get pid)
       /system/bin/btwlancoex -o $opt_flags &
      ;;
      *)
       echo "NO WLAN Chip ID is enabled, so enabling ATH as default"
       # Must have -d -z -n -v -s -w wlan0 parameters for atheros btfilter.
       /system/bin/abtfilt -d -z -n -v -q -s -w wlan0 &
      ;;
  esac
  coex_pid=$!
  logi "start_coex: pid = $coex_pid"
}

kill_coex ()
{
  logi "kill_coex: pid = $coex_pid"
  kill -TERM $coex_pid
  # this shell doesn't exit now -- wait returns for normal exit
}

# mimic coex options parsing -- maybe a waste of effort
USAGE="${0} [-o] [-c] [-r] [-i] [-h]"

while getopts "ocrih" f
do
  case $f in
  o | c | r | i | h)  opt_flags="$opt_flags -$f" ;;
  \?)     echo $USAGE; exit 1;;
  esac
done

# init does SIGTERM on ctl.stop for service
trap "kill_coex" TERM INT

#Selectively start coex module
target=`getprop ro.board.platform`

if [ "$target" == "msm8960" ] && [ "$ath_wlan_supported" != "2" ]; then
     logi "btwlancoex/abtfilt is not needed"
else
     # Build settings may not produce the coex executable
     if ls /system/bin/btwlancoex || ls /system/bin/abtfilt
     then
         start_coex
         wait $coex_pid
         logi "Coex stopped"
     else
         logi "btwlancoex/abtfilt not available"
     fi
fi
exit 0
