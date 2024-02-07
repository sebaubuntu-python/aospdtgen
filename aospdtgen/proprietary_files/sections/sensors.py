#
# Copyright (C) 2022 The LineageOS Project
#
# SPDX-License-Identifier: Apache-2.0
#

from aospdtgen.proprietary_files.section import Section, register_section

class SensorsSection(Section):
	name = "Sensors"
	interfaces = [
		"android.hardware.sensors",
		"motorola.hardware.sensorscalibrate",
		"vendor-oplus-hardware-oplusSensor",
		"vendor.qti.hardware.sensorscalibrate",
	]
	hardware_modules = [
		"sensors",
	]
	binaries = [
		"init.qcom.sensors.sh",
		"sensors.qti",
		"sscrpcd",
	]
	patterns = [
		"lib(64)?/sensors\..*\.so",
	]

class SensorsConfigsSection(Section):
	name = "Sensors configs"
	folders = [
		"etc/motorola/sensors",
		"etc/sensor",
		"etc/sensors",
	]

register_section(SensorsSection)
register_section(SensorsConfigsSection)
