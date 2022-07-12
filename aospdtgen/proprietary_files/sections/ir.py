#
# Copyright (C) 2022 The LineageOS Project
#
# SPDX-License-Identifier: Apache-2.0
#

from aospdtgen.proprietary_files.section import Section, register_section

class IrSection(Section):
	name = "IR"
	interfaces = [
		"android.hardware.ir",
	]
	hardware_modules = [
		"consumerir",
	]

register_section(IrSection)
