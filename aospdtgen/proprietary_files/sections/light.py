#
# Copyright (C) 2022 The LineageOS Project
#
# SPDX-License-Identifier: Apache-2.0
#

from aospdtgen.proprietary_files.section import Section, register_section

class LightSection(Section):
	name = "Light"
	interfaces = [
		"android.hardware.light",
	]
	hardware_modules = [
		"lights",
	]

register_section(LightSection)
