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
	]
	hardware_modules = [
		"power",
	]

register_section(PowerSection)
