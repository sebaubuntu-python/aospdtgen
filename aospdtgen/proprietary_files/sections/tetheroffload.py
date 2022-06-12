#
# Copyright (C) 2022 The LineageOS Project
#
# SPDX-License-Identifier: Apache-2.0
#

from aospdtgen.proprietary_files.section import Section, register_section

class TetherOffloadSection(Section):
	name = "Tether offload"
	interfaces = [
		"android.hardware.tetheroffload.config",
		"android.hardware.tetheroffload.control",
	]

register_section(TetherOffloadSection)
