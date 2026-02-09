#!/system/bin/sh

while true;
do dumpsys activity service OTraceDaemonService systrace --start
date
echo capturing ...
sleep 7200;
date
dumpsys activity service OTraceDaemonService systrace --stop
sleep 10;
date
done
