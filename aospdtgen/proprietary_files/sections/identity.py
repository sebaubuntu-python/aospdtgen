#
# Copyright (C) 2022 The LineageOS Project
#
# SPDX-License-Identifier: Apache-2.0
#

from aospdtgen.proprietary_files.section import Section, register_section

class IdentitySection(Section):
	name = "Identity"
	interfaces = [
		"android.hardware.identity",
	]

register_section(IdentitySection)
