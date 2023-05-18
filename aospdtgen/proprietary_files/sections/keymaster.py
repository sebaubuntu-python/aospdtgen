#
# Copyright (C) 2022 The LineageOS Project
#
# SPDX-License-Identifier: Apache-2.0
#

from aospdtgen.proprietary_files.section import Section, register_section

class KeymasterSection(Section):
	name = "Keymaster"
	interfaces = [
		"android.hardware.keymaster",
		"vendor.mediatek.hardware.keymaster_attestation",
	]
	hardware_modules = [
		"keystore",
		"kmsetkey",
	]

register_section(KeymasterSection)
