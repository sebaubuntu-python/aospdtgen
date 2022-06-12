#
# Copyright (C) 2022 The LineageOS Project
#
# SPDX-License-Identifier: Apache-2.0
#

from aospdtgen.proprietary_files.section import Section, register_section

class AlarmSection(Section):
	name = "Alarm"
	interfaces = [
		"vendor.qti.hardware.alarm",
	]
	apps = [
		"PowerOffAlarm",
	]
	binaries = [
		"power_off_alarm",
		"poweroffm64",
	]

register_section(AlarmSection)
