#
# Copyright (C) 2022 The LineageOS Project
#
# SPDX-License-Identifier: Apache-2.0
#

from aospdtgen.proprietary_files.section import Section, register_section

class PowerSection(Section):
	name = "Power"
	interfaces = [
		"android.hardware.power",
		"vendor-oplus-hardware-power-powermonitor",
		"vendor.qti.hardware.power.powermodule",
		"vendor.mediatek.hardware.mtkpower",
	]
	hardware_modules = [
		"power",
	]

class PowerConfigsSection(Section):
	name = "Power configs"
	folders = [
		"etc/pwr",
	]

register_section(PowerSection)
register_section(PowerConfigsSection)
