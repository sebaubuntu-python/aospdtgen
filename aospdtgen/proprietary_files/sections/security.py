#
# Copyright (C) 2024 The LineageOS Project
#
# SPDX-License-Identifier: Apache-2.0
#

from aospdtgen.proprietary_files.section import Section, register_section

class SecuritySection(Section):
	name = "Security"
	interfaces = [
		"android.hardware.security.keymint",
		"android.hardware.security.rkp",
		"android.hardware.security.secureclock",
		"android.hardware.security.sharedsecret",
	]

register_section(SecuritySection)
