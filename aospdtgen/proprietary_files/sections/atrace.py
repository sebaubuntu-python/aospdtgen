#
# Copyright (C) 2022 The LineageOS Project
#
# SPDX-License-Identifier: Apache-2.0
#

from aospdtgen.proprietary_files.section import Section, register_section

class AtraceSection(Section):
	name = "Atrace"
	interfaces = [
		"android.hardware.atrace",
	]

register_section(AtraceSection)
