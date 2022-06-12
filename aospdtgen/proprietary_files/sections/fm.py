#
# Copyright (C) 2022 The LineageOS Project
#
# SPDX-License-Identifier: Apache-2.0
#

from aospdtgen.proprietary_files.section import Section, register_section

class FmSection(Section):
	name = "FM"
	interfaces = [
		"vendor.qti.hardware.fm",
	]

register_section(FmSection)
